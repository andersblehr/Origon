//
//  OOrigo+OrigoExtensions.h
//  OrigoApp
//
//  Created by Anders Blehr on 17.10.12.
//  Copyright (c) 2012 Rhelba Creations. All rights reserved.
//

#import "OOrigo.h"

@class OMember, OMembership;

@interface OOrigo (OrigoExtensions)

- (NSString *)listName;
- (NSString *)listDetails;

- (id)addMember:(OMember *)member;
- (id)addResident:(OMember *)resident;

- (BOOL)isMemberRoot;
- (BOOL)isResidence;
- (BOOL)hasAddress;
- (BOOL)hasTelephone;

- (OMembership *)userMembership;
- (BOOL)userIsMember;
- (BOOL)userIsAdmin;
- (BOOL)hasMemberWithEmail:(NSString *)email;

- (NSComparisonResult)compare:(OOrigo *)other;

@end