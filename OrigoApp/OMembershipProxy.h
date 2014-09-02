//
//  OMembershipProxy.h
//  OrigoApp
//
//  Created by Anders Blehr on 01.05.14.
//  Copyright (c) 2014 Rhelba Source. All rights reserved.
//

#import "OEntityProxy.h"

extern NSString * const kMembershipTypeRoot;
extern NSString * const kMembershipTypeResidency;
extern NSString * const kMembershipTypeParticipancy;
extern NSString * const kMembershipTypeAssociate;

extern NSString * const kMembershipStatusInvited;
extern NSString * const kMembershipStatusWaiting;
extern NSString * const kMembershipStatusActive;
extern NSString * const kMembershipStatusRejected;
extern NSString * const kMembershipStatusExpired;

extern NSString * const kRoleTypeMemberRole;
extern NSString * const kRoleTypeOrganiserRole;
extern NSString * const kRoleTypeParentRole;


@protocol OMembership <OEntity>

@optional
@property (nonatomic) id<OOrigo> origo;
@property (nonatomic) id<OMember> member;
@property (nonatomic) NSString *type;
@property (nonatomic) NSNumber *isAdmin;
@property (nonatomic) NSString *status;
@property (nonatomic) NSString *roles;

- (BOOL)isInvited;
- (BOOL)isActive;
- (BOOL)isRejected;

- (BOOL)isFull;
- (BOOL)isParticipancy;
- (BOOL)isResidency;
- (BOOL)isAssociate;

- (BOOL)hasRoleOfType:(NSString *)type;
- (void)addRole:(NSString *)role ofType:(NSString *)type;
- (void)removeRole:(NSString *)role ofType:(NSString *)type;
- (NSArray *)memberRoles;
- (NSArray *)organiserRoles;
- (NSArray *)parentRoles;
- (NSArray *)allRoles;
- (NSString *)roleTypeForRole:(NSString *)role;

- (void)promoteToFull;
- (void)demoteToAssociate;
- (void)alignWithOrigoIsAssociate:(BOOL)isAssociate;

@end


@interface OMembershipProxy : OEntityProxy<OMembership>

+ (instancetype)proxyForMember:(id<OMember>)member inOrigo:(id<OOrigo>)origo;

@end
