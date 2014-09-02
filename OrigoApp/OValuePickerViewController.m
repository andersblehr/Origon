//
//  OValuePickerViewController.m
//  OrigoApp
//
//  Created by Anders Blehr on 17.10.12.
//  Copyright (c) 2012 Rhelba Source. All rights reserved.
//

#import "OValuePickerViewController.h"


@interface OValuePickerViewController () <OTableViewController> {
@private
    OTableViewCell *_checkedCell;
    NSMutableArray *_pickedValues;
    BOOL _isMultiValuePicker;
    
    id<OSettings> _settings;
    NSString *_settingKey;

    id<OOrigo> _origo;
    NSString *_role;
    NSString *_roleType;
    UIBarButtonItem *_multiRoleButtonOff;
    UIBarButtonItem *_multiRoleButtonOn;
}

@end


@implementation OValuePickerViewController

#pragma mark - Auxiliary methods

- (NSArray *)roleHolders
{
    NSArray *roleHolders = nil;
    
    if ([self aspectIs:kAspectMemberRole]) {
        roleHolders = [_origo membersWithRole:_role];
    } else if ([self aspectIs:kAspectOrganiserRole]) {
        roleHolders = [_origo organisersWithRole:_role];
    } else if ([self aspectIs:kAspectParentRole]) {
        roleHolders = [_origo parentsWithRole:_role];
    }
    
    return roleHolders;
}


#pragma mark - Selector implementations

- (void)toggleMultiRole
{
    if ([_pickedValues count] < 2) {
        if (_isMultiValuePicker) {
            self.navigationItem.rightBarButtonItem = _multiRoleButtonOff;
        } else {
            self.navigationItem.rightBarButtonItem = _multiRoleButtonOn;
        }
        
        _isMultiValuePicker = !_isMultiValuePicker;
    }
}


#pragma mark - View lifecycle

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.isModal && _isMultiValuePicker) {
        if (self.didCancel) {
            if ([self targetIs:kTargetRole]) {
                for (id<OMember> roleHolder in [self roleHolders]) {
                    [[_origo membershipForMember:roleHolder] removeRole:_role ofType:_roleType];
                }
            }
        } else {
            self.returnData = _pickedValues;
        }
    }
    
    [super viewWillDisappear:animated];
}


#pragma mark - OTableViewController protocol conformance

- (void)loadState
{
    if ([self targetIs:kTargetSetting]) {
        _settingKey = self.target;
        _settings = [OSettings settings];
        
        self.title = NSLocalizedString(_settingKey, kStringPrefixSettingTitle);
    } else {
        self.usesPlainTableViewStyle = YES;
        
        if ([self targetIs:kTargetMembers]) {
            _isMultiValuePicker = YES;
        } else if ([self targetIs:kTargetRole]) {
            _origo = self.meta;
            _role = [self.target isEqualToString:kTargetRole] ? nil : self.target;
            
            NSString *placeholder = nil;
            
            if ([self aspectIs:kAspectMemberRole]) {
                _roleType = kRoleTypeMemberRole;
                _pickedValues = _role ? [[_origo membersWithRole:_role] mutableCopy] : nil;
                placeholder = NSLocalizedString(_origo.type, kStringPrefixMemberRoleTitle);
            } else if ([self aspectIs:kAspectOrganiserRole]) {
                _roleType = kRoleTypeOrganiserRole;
                _pickedValues = _role ? [[_origo organisersWithRole:_role] mutableCopy] : nil;
                placeholder = NSLocalizedString(_origo.type, kStringPrefixOrganiserRoleTitle);
            } else if ([self aspectIs:kAspectParentRole]) {
                _roleType = kRoleTypeParentRole;
                _pickedValues = _role ? [[_origo parentsWithRole:_role] mutableCopy] : nil;
                placeholder = NSLocalizedString(@"Contact role", @"");
            }
            
            [self setEditableTitle:_role placeholder:placeholder];
            [self setSubtitle:[OUtil commaSeparatedListOfItems:_pickedValues conjoinLastItem:NO]];
            
            _isMultiValuePicker = ([_pickedValues count] > 1);
            
            if (!_isMultiValuePicker && ([_pickedValues count] < 2)) {
                _multiRoleButtonOff = [UIBarButtonItem multiRoleButtonWithTarget:self selected:NO];
                _multiRoleButtonOn = [UIBarButtonItem multiRoleButtonWithTarget:self selected:YES];
                
                [self.navigationItem addRightBarButtonItem:_multiRoleButtonOff];
            }
        }
    }
    
    if (self.isModal) {
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem cancelButtonWithTarget:self];
        
        if (_isMultiValuePicker) {
            self.navigationItem.rightBarButtonItem = [UIBarButtonItem doneButtonWithTarget:self];
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }
    
    if (!_pickedValues) {
        _pickedValues = [NSMutableArray array];
    }
}


- (void)loadData
{
    if ([self targetIs:kTargetSetting]) {
        // TODO
    } else {
        if ([self targetIs:kTargetRole]) {
            if ([self aspectIs:kAspectMemberRole]) {
                [self setData:[_origo regulars] sectionIndexLabelKey:kPropertyKeyName];
            } else if ([self aspectIs:kAspectOrganiserRole]) {
                [self setData:[_origo organisers] sectionIndexLabelKey:kPropertyKeyName];
            } else if ([self aspectIs:kAspectParentRole]) {
                [self setData:[_origo guardians] sectionIndexLabelKey:kPropertyKeyName];
            }
        } else {
            [self setData:self.meta sectionIndexLabelKey:kPropertyKeyName];
        }
    }
}


- (void)loadListCell:(OTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([self targetIs:kTargetSetting]) {
        cell.checked = [[self dataAtIndexPath:indexPath] isEqual:[_settings valueForSettingKey:_settingKey]];
    } else {
        id<OMember> candidate = [self dataAtIndexPath:indexPath];
        
        cell.textLabel.text = [candidate publicName];
        cell.imageView.image = [OUtil smallImageForMember:candidate];
        
        if ([_pickedValues count]) {
            cell.checked = [_pickedValues containsObject:candidate];
        }
        
        if ([candidate isJuvenile]) {
            cell.detailTextLabel.text = [OUtil guardianInfoForMember:candidate];
        } else if ([self aspectIs:kAspectParentRole]) {
            cell.detailTextLabel.text = [OUtil commaSeparatedListOfItems:[candidate wards] conjoinLastItem:NO];
        } else {
            cell.detailTextLabel.text = [[candidate residence] shortAddress];
        }
    }
    
    if (cell.checked && !_isMultiValuePicker) {
        _checkedCell = cell;
    }
}


- (void)didSelectCell:(OTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.selected = NO;
    cell.checked = _isMultiValuePicker ? !cell.checked : YES;
    
    id oldValue = nil;
    id pickedValue = [self dataAtIndexPath:indexPath];
    
    if (cell.checked) {
        if (!_isMultiValuePicker && (_checkedCell != cell)) {
            if (_checkedCell) {
                oldValue = [self dataAtIndexPath:[self.tableView indexPathForCell:_checkedCell]];
                
                _checkedCell.checked = NO;
                [_pickedValues removeAllObjects];
            }
            
            _checkedCell = cell;
        }
        
        [_pickedValues addObject:pickedValue];
    } else {
        [_pickedValues removeObject:pickedValue];
    }
    
    if ([self targetIs:kTargetSetting]) {
        [_settings setValue:pickedValue forSettingKey:_settingKey];
        [self.navigationController popViewControllerAnimated:YES];
    } else if ([self targetIs:kTargetMember]) {
        self.returnData = pickedValue;
        [self.dismisser dismissModalViewController:self];
    } else if ([self targetIs:kTargetRole]) {
        if (cell.checked) {
            [[_origo membershipForMember:pickedValue] addRole:_role ofType:_roleType];
            
            if (!_isMultiValuePicker) {
                [[_origo membershipForMember:oldValue] removeRole:_role ofType:_roleType];
            }
        } else {
            [[_origo membershipForMember:pickedValue] removeRole:_role ofType:_roleType];
        }
        
        [self setSubtitle:[OUtil commaSeparatedListOfItems:[_pickedValues sortedArrayUsingSelector:@selector(compare:)] conjoinLastItem:NO]];
        
        if (_isMultiValuePicker) {
            if (self.isModal) {
                if ([_pickedValues count]) {
                    if (self.navigationItem.rightBarButtonItem == _multiRoleButtonOn) {
                        self.navigationItem.rightBarButtonItem = [UIBarButtonItem doneButtonWithTarget:self];
                    }
                }
                
                self.navigationItem.rightBarButtonItem.enabled = ([_pickedValues count] > 0);
            }
        } else {
            if (self.isModal) {
                [self.dismisser dismissModalViewController:self];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
            
    }
}


- (void)titleWillChange:(NSString *)newTitle
{
    if (_role) {
        for (id<OMember> roleHolder in [self roleHolders]) {
            id<OMembership> membership = [_origo membershipForMember:roleHolder];
            
            [membership addRole:newTitle ofType:_roleType];
            [membership removeRole:_role ofType:_roleType];
        }
    }
    
    _role = newTitle;
}

@end
