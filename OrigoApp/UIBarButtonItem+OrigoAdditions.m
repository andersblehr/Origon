//
//  UIBarButtonItem+OrigoAdditions.m
//  OrigoApp
//
//  Created by Anders Blehr on 17.10.12.
//  Copyright (c) 2012 Rhelba Creations. All rights reserved.
//

#import "UIBarButtonItem+OrigoAdditions.h"

static UIBarButtonItem *_flexibleSpace = nil;


@implementation UIBarButtonItem (OrigoAdditions)

#pragma mark - Auxiliary methods

+ (UIBarButtonItem *)barButtonWithIcon:(NSString *)iconFile target:(id)target action:(SEL)action
{
    UIImage *image = [UIImage imageNamed:iconFile];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds = CGRectMake(0.f, 0.f, image.size.width, image.size.height);
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}


#pragma mark - Bar button shorthands

+ (UIBarButtonItem *)settingsButtonWithTarget:(id)target
{
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:kIconFileSettings] style:UIBarButtonItemStylePlain target:target action:@selector(openSettings)];
}


+ (UIBarButtonItem *)plusButtonWithTarget:(id)target
{
    UIBarButtonItem *button = nil;
    
    if ([OMeta systemIs_iOS6x]) {
        button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:kIconFilePlus] style:UIBarButtonItemStylePlain target:target action:@selector(addItem)];
    } else {
        button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:target action:@selector(addItem)];
    }
    
    return button;
}


+ (UIBarButtonItem *)actionButtonWithTarget:(id)target
{
    UIBarButtonItem *button = nil;
    
    if ([OMeta systemIs_iOS6x]) {
        button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:kIconFileAction] style:UIBarButtonItemStylePlain target:target action:@selector(presentActionSheet)];
    } else {
        button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:target action:@selector(presentActionSheet)];
    }
    
    return button;
}


+ (UIBarButtonItem *)lookupButtonWithTarget:(id)target
{
    UIBarButtonItem *button = nil;
    
    if ([OMeta systemIs_iOS6x]) {
        button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:kIconFileLookup] style:UIBarButtonItemStylePlain target:target action:@selector(performLookup)];
    } else {
        button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:target action:@selector(performLookup)];
    }
    
    return button;
}


+ (UIBarButtonItem *)nextButtonWithTarget:(id)target
{
    return [[UIBarButtonItem alloc] initWithTitle:[OStrings stringForKey:strButtonNext] style:UIBarButtonItemStylePlain target:target action:@selector(moveToNextInputField)];
}


+ (UIBarButtonItem *)cancelButtonWithTarget:(id)target
{
    return [[UIBarButtonItem alloc] initWithTitle:[OStrings stringForKey:strButtonCancel] style:UIBarButtonItemStylePlain target:target action:@selector(didCancelEditing)];
}


+ (UIBarButtonItem *)doneButtonWithTarget:(id)target
{
    return [[UIBarButtonItem alloc] initWithTitle:[OStrings stringForKey:strButtonDone] style:UIBarButtonItemStyleDone target:target action:@selector(didFinishEditing)];
}


+ (UIBarButtonItem *)signOutButtonWithTarget:(id)target
{
    return [[UIBarButtonItem alloc] initWithTitle:[OStrings stringForKey:strButtonSignOut] style:UIBarButtonItemStylePlain target:target action:@selector(signOut)];
}


+ (UIBarButtonItem *)sendTextButtonWithTarget:(id)target
{
    UIBarButtonItem *barButtonItem = nil;
    SEL action = @selector(processTextRequest);
    
    if ([OMeta systemIs_iOS6x]) {
        barButtonItem = [UIBarButtonItem barButtonWithIcon:kIconFileSendText_iOS6x target:target action:action];
    } else {
        barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:kIconFileSendText] style:UIBarButtonItemStylePlain target:target action:action];
    }
    
    return barButtonItem;
}


+ (UIBarButtonItem *)phoneCallButtonWithTarget:(id)target
{
    UIBarButtonItem *barButtonItem = nil;
    SEL action = @selector(processCallRequest);
    
    if ([OMeta systemIs_iOS6x]) {
        barButtonItem = [UIBarButtonItem barButtonWithIcon:kIconFilePlacePhoneCall_iOS6x target:target action:action];
    } else {
        barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:kIconFilePlacePhoneCall] style:UIBarButtonItemStylePlain target:target action:action];
    }
    
    return barButtonItem;
}


+ (UIBarButtonItem *)sendEmailButtonWithTarget:(id)target
{
    UIBarButtonItem *barButtonItem = nil;
    SEL action = @selector(processEmailRequest);
    
    if ([OMeta systemIs_iOS6x]) {
        barButtonItem = [UIBarButtonItem barButtonWithIcon:kIconFileSendEmail_iOS6x target:target action:action];
    } else {
        barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:kIconFileSendEmail] style:UIBarButtonItemStylePlain target:target action:action];
    }
    
    return barButtonItem;
}


+ (UIBarButtonItem *)flexibleSpace
{
    if (!_flexibleSpace) {
        _flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    }
    
    return _flexibleSpace;
}

@end