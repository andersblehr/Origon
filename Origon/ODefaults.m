//
//  ODefaults.m
//  Origon
//
//  Created by Anders Blehr on 17.10.12.
//  Copyright (c) 2012 Rhelba Source. All rights reserved.
//

#import "ODefaults.h"

NSString * const kDefaultsKeyAuthExpiryDate = @"origo.date.authExpiry";
NSString * const kDefaultsKeyDeviceId = @"origo.id.device";
NSString * const kDefaultsKeyUserEmail = @"origo.user.email";
NSString * const kDefaultsKeyLastReplicationDate = @"origo.date.lastReplication";
NSString * const kDefaultsKeyUserId = @"origo.id.user";

static NSString *userEmail = nil;
static NSString *userId = nil;


@implementation ODefaults

#pragma mark - Auxiliary methods

+ (NSString *)userKeyForKey:(NSString *)key
{
    NSString *userKey = nil;
    NSString *userQualifier = nil;

    if ([key isEqualToString:kDefaultsKeyUserId]) {
        if (!userEmail) {
            userEmail = [self globalDefaultForKey:kDefaultsKeyUserEmail];
        }
        
        userQualifier = userEmail;
    } else {
        if (!userId) {
            userId = [self userDefaultForKey:kDefaultsKeyUserId];
        }
        
        userQualifier = userId;
    }
    
    if (userQualifier) {
        userKey = [NSString stringWithFormat:@"%@$%@", key, userQualifier];
    }
    
    return userKey;
}


#pragma mark - Global defaults convenience methods

+ (void)setGlobalDefault:(id)globalDefault forKey:(NSString *)key
{
    if (globalDefault) {
        if ([key isEqualToString:kDefaultsKeyUserEmail]) {
            userEmail = globalDefault;
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:globalDefault forKey:key];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
}


+ (id)globalDefaultForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}


+ (void)removeGlobalDefaultForKey:(NSString *)key
{
    [self setGlobalDefault:nil forKey:key];
}


#pragma mark - User defaults convenience methods

+ (void)setUserDefault:(id)userDefault forKey:(NSString *)key
{
    if (userDefault && [key isEqualToString:kDefaultsKeyUserId]) {
        userId = userDefault;
    }
    
    NSString *userKey = [self userKeyForKey:key];
    
    if (userKey) {
        [self setGlobalDefault:userDefault forKey:userKey];
    }
}


+ (id)userDefaultForKey:(NSString *)key
{
    NSString *userKey = [self userKeyForKey:key];
    
    return userKey ? [self globalDefaultForKey:userKey] : nil;
}


+ (void)removeUserDefaultForKey:(NSString *)key
{
    [self setUserDefault:nil forKey:key];
}


#pragma mark - Resetting user information

+ (void)resetUser
{
    userEmail = nil;
    userId = nil;
}

@end