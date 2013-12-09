//
//  UIBarButtonItem+OrigoAdditions.h
//  OrigoApp
//
//  Created by Anders Blehr on 17.10.12.
//  Copyright (c) 2012 Rhelba Creations. All rights reserved.
//

#import "OrigoApp.h"

@interface UIBarButtonItem (OrigoAdditions)

+ (UIBarButtonItem *)settingsButtonWithTarget:(id)target;
+ (UIBarButtonItem *)plusButtonWithTarget:(id)target;
+ (UIBarButtonItem *)actionButtonWithTarget:(id)target;
+ (UIBarButtonItem *)lookupButtonWithTarget:(id)target;
+ (UIBarButtonItem *)nextButtonWithTarget:(id)target;
+ (UIBarButtonItem *)cancelButtonWithTarget:(id)target;
+ (UIBarButtonItem *)doneButtonWithTarget:(id)target;
+ (UIBarButtonItem *)signOutButtonWithTarget:(id)target;
+ (UIBarButtonItem *)sendTextButtonWithTarget:(id)target;
+ (UIBarButtonItem *)phoneCallButtonWithTarget:(id)target;
+ (UIBarButtonItem *)sendEmailButtonWithTarget:(id)target;
+ (UIBarButtonItem *)flexibleSpace;

@end