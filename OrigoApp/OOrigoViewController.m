//
//  OOrigoViewController.m
//  OrigoApp
//
//  Created by Anders Blehr on 17.10.12.
//  Copyright (c) 2012 Rhelba Creations. All rights reserved.
//

#import "OOrigoViewController.h"

#import "NSManagedObjectContext+OrigoExtensions.h"
#import "NSString+OrigoExtensions.h"
#import "UIBarButtonItem+OrigoExtensions.h"
#import "UITableView+OrigoExtensions.h"

#import "OEntityObservingDelegate.h"
#import "OModalViewControllerDelegate.h"

#import "OLogging.h"
#import "OMeta.h"
#import "OState.h"
#import "OStrings.h"
#import "OTableViewCell.h"
#import "OTextField.h"
#import "OTextView.h"

#import "OMember.h"
#import "OMembership.h"
#import "OOrigo+OrigoExtensions.h"
#import "OReplicatedEntity+OrigoExtensions.h"

#import "OMemberListViewController.h"

static NSString * const kModalSegueToMemberListView = @"modalFromOrigoToMemberListView";


@implementation OOrigoViewController

#pragma mark - Auxiliary methods

- (void)toggleEditMode
{
    static UIBarButtonItem *editButton = nil;
    static UIBarButtonItem *backButton = nil;
    
    [_origoCell toggleEditMode];
    
    if (self.state.actionIsEdit) {
        editButton = self.navigationItem.rightBarButtonItem;
        backButton = self.navigationItem.leftBarButtonItem;
        
        if (!_cancelButton) {
            _cancelButton = [UIBarButtonItem cancelButtonWithTarget:self];
            _nextButton = [UIBarButtonItem nextButtonWithTarget:self];
            _doneButton = [UIBarButtonItem doneButtonWithTarget:self];
        }
        
        self.navigationItem.rightBarButtonItem = _nextButton;
        self.navigationItem.leftBarButtonItem = _cancelButton;
    } else if (self.state.actionIsDisplay) {
        [self.view endEditing:YES];
        
        self.navigationItem.rightBarButtonItem = editButton;
        self.navigationItem.leftBarButtonItem = backButton;
    }
    
    OLogState;
}


#pragma mark - Selector implementations

- (void)moveToNextInputField
{
    if (_currentField == _addressView) {
        [_telephoneField becomeFirstResponder];
    }
}


- (void)didCancelEditing
{
    if (self.state.actionIsRegister) {
        [[OMeta m].context deleteEntity:_origo];
        
        [_delegate dismissModalViewControllerWithIdentitifier:kOrigoViewControllerId];
    } else {
        _addressView.text = _origo.address;
        _telephoneField.text = _origo.telephone;
        
        [self toggleEditMode];
    }
}


- (void)didFinishEditing
{
    if ([[_addressView finalText] length] > 0) {
        _origo.address = [_addressView finalText];
        _origo.telephone = [_telephoneField finalText];
        
        if (self.state.actionIsRegister) {
            if (_membership && [_origo isResidence]) { // TODO: Use aspect for this?
                [OMeta m].user.activeSince = [NSDate date];
                [_delegate dismissModalViewControllerWithIdentitifier:kOrigoViewControllerId];
            } else {
                if ([_origo isResidence]) {
                    _membership = [_origo addResident:_member];
                } else {
                    _membership = [_origo addMember:_member];
                }
                
                [self performSegueWithIdentifier:kModalSegueToMemberListView sender:self];
            }
        } else if (self.state.actionIsEdit) {
            [self toggleEditMode];
            [_entityObservingDelegate reloadEntity];
        }
        
        [[OMeta m].context replicateIfNeeded];
    } else {
        [_origoCell shakeCellVibrateDevice:NO];
    }
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setBackground];
    
    if (_origo) {
        self.title = [_origo isResidence] ? [OStrings stringForKey:strTermAddress] : _origo.name;
    } else {
        if ([_origo.type isEqualToString:kOrigoTypeDefault]) {
            self.title = [OStrings stringForKey:strViewTitleNewOrigo];
        } else {
            self.title = [OStrings stringForKey:_origo.type];
        }
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.state.actionIsRegister) {
        _nextButton = [UIBarButtonItem nextButtonWithTarget:self];
        _doneButton = [UIBarButtonItem doneButtonWithTarget:self];
        
        self.navigationItem.rightBarButtonItem = _nextButton;
        
        if (!([_origo isResidence] && self.state.aspectIsSelf)) {
            self.navigationItem.leftBarButtonItem = [UIBarButtonItem cancelButtonWithTarget:self];
        }
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.state.actionIsInput) {
        [_addressView becomeFirstResponder];
    } else if ([_origo userIsAdmin]) {
        _origoCell.editable = YES;
    }
    
    OLogState;
}


#pragma mark - Segue handling

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kModalSegueToMemberListView]) {
        OMemberListViewController *memberListViewController = segue.destinationViewController;
        memberListViewController.origo = self.origo;
        memberListViewController.delegate = self.delegate;
    }
}


#pragma mark - Overrides

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}


#pragma mark - OTableViewControllerDelegate conformance

- (void)setPrerequisites
{
    if (_membership) {
        _origo = _membership.origo;
        _member = _membership.member;
    }
}


- (void)setState
{
    self.state.targetIsOrigo = YES;
    self.state.actionIsDisplay = ![OState s].actionIsInput;
    [self.state setAspectForOrigo:_origo];
}


#pragma mark - UITableViewDataSource conformance

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _origo ? [_origo cellHeight] : [OOrigo defaultCellHeight];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_origo) {
        _origoCell = [tableView cellForEntity:_origo delegate:self];
    } else {
        _origoCell = [tableView cellForEntityClass:OOrigo.class delegate:self];
    }
    
    _addressView = [_origoCell textFieldForKeyPath:kKeyPathAddress];
    _telephoneField = [_origoCell textFieldForKeyPath:kKeyPathTelephone];
    
    return _origoCell;
}


#pragma mark - UITableViewDelegate conformance

- (void)tableView:(UITableView *)tableView willDisplayCell:(OTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell willAppearTrailing:YES];
}


#pragma mark - UITextFieldDelegate conformance

- (void)textFieldDidBeginEditing:(OTextField *)textField
{
    if (self.state.actionIsDisplay) {
        [self toggleEditMode];
    }
    
    self.navigationItem.rightBarButtonItem = _doneButton;
    
    _currentField = textField;
    
    textField.hasEmphasis = YES;
}


- (void)textFieldDidEndEditing:(OTextField *)textField
{
    textField.hasEmphasis = NO;
}


#pragma mark - UITextViewDelegate conformance

- (void)textViewDidBeginEditing:(OTextView *)textView
{
    if (self.state.actionIsDisplay) {
        [self toggleEditMode];
    }
    
    self.navigationItem.rightBarButtonItem = _nextButton;
    
    _currentField = textView;
    
    textView.hasEmphasis = YES;
}


- (void)textViewDidChange:(OTextView *)textView
{
    [_origoCell redrawIfNeeded];
}


- (void)textViewDidEndEditing:(OTextView *)textView
{
    textView.hasEmphasis = NO;
}

@end
