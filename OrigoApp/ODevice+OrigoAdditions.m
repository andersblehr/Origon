//
//  ODevice+OrigoAdditions.m
//  OrigoApp
//
//  Created by Anders Blehr on 17.10.12.
//  Copyright (c) 2012 Rhelba Source. All rights reserved.
//

#import "ODevice+OrigoAdditions.h"

NSString *kDeviceType_iPhone = @"iPhone";
NSString *kDeviceType_iPad = @"iPad";
NSString *kDeviceType_iPodTouch = @"iPod";


@implementation ODevice (OrigoAdditions)

#pragma mark - Selector implementations

- (NSComparisonResult)compare:(ODevice *)other
{
    return [other.name compare:self.name];
}


#pragma mark - Instance access

+ (instancetype)device
{
    NSString *deviceId = [OMeta m].deviceId;
    
    if (!deviceId) {
        deviceId = [ODefaults userDefaultForKey:kDefaultsKeyDeviceId];
    }
    
    ODevice *device = [[OMeta m].context entityWithId:deviceId];
    
    if (!device) {
        device = [[OMeta m].context insertEntityOfClass:[self class] inOrigo:[[OMeta m].user stash] entityId:deviceId];
        device.type = [UIDevice currentDevice].model;
        device.name = [UIDevice currentDevice].name;
        device.user = [OMeta m].user;
    }
    
    return device;
}


#pragma mark - Type inference

- (BOOL)isOfType:(NSString *)deviceType
{
    return [self.type hasPrefix:deviceType];
}


#pragma mark - Touching device

- (void)touch
{
    if ([self hasExpired]) {
        [self unexpire];
    }
    
    if (![self.name isEqualToString:[UIDevice currentDevice].name]) {
        self.name = [UIDevice currentDevice].name;
    }
}


#pragma mark - OReplicatedEntity (OrigoAdditions) overrides

- (void)expire
{
    if (![self.entityId isEqualToString:[OMeta m].deviceId]) {
        [super expire];
    }
}

@end
