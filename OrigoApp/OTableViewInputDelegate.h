//
//  OTableViewInputDelegate.h
//  OrigoApp
//
//  Created by Anders Blehr on 17.06.13.
//  Copyright (c) 2013 Rhelba Creations. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OTableViewInputDelegate <NSObject>

@required
- (BOOL)inputIsValid;
- (void)processInput;

@optional
- (BOOL)willValidateInputForKey:(NSString *)key;
- (BOOL)inputValue:(id)inputValue isValidForKey:(NSString *)key;
- (NSDictionary *)additionalInputValues;
- (id)targetEntity;

@end
