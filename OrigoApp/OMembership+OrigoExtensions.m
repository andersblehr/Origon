//
//  OMembership+OrigoExtensions.m
//  OrigoApp
//
//  Created by Anders Blehr on 17.10.12.
//  Copyright (c) 2012 Rhelba Creations. All rights reserved.
//

#import "OMembership+OrigoExtensions.h"

#import "NSManagedObjectContext+OrigoExtensions.h"

#import "OMeta.h"
#import "OState.h"

#import "OMember+OrigoExtensions.h"
#import "OOrigo+OrigoExtensions.h"
#import "OReplicatedEntity+OrigoExtensions.h"

static NSString * const kMembershipTypeMemberRoot = @"~";
static NSString * const kMembershipTypeResidency = @"R";
static NSString * const kMembershipTypeParticipancy = @"S";
static NSString * const kMembershipTypeAssociate = @"A";


@implementation OMembership (OrigoExtensions)

#pragma mark - Selector implementations

- (NSComparisonResult)compare:(OMembership *)other
{
    NSComparisonResult result = NSOrderedSame;
    
    if ([OState s].viewIsMemberList) {
        result = [self.member compare:other.member];
    } else if ([OState s].viewIsOrigoList || [OState s].viewIsMemberDetail) {
        result = [self.origo compare:other.origo];
    }
    
    return result;
}


#pragma mark - Meta information

- (BOOL)hasContactRole
{
    return ([self.contactRole length] > 0);
}


- (BOOL)isFull
{
    return ([self isParticipancy] || [self isResidency]);
}


- (BOOL)isParticipancy
{
    return [self.type isEqualToString:kMembershipTypeParticipancy];
}


- (BOOL)isResidency
{
    return [self.type isEqualToString:kMembershipTypeResidency];
}


- (BOOL)isAssociate
{
    return [self.type isEqualToString:kMembershipTypeAssociate];
}


#pragma mark - Promoting & demoting

- (void)promoteToFull
{
    if ([self isAssociate]) {
        [[OMeta m].context insertAdditionalCrossReferencesForFullMembership:self];
        
        [self alignWithOrigoIsAssociate:NO];
    }
}


- (void)demoteToAssociate
{
    if ([self isFull]) {
        [[OMeta m].context expireAdditionalCrossReferencesForFullMembership:self];
        
        [self alignWithOrigoIsAssociate:YES];
    }
}


- (void)alignWithOrigoIsAssociate:(BOOL)isAssociate
{
    if (isAssociate) {
        self.type = kMembershipTypeAssociate;
    } else if ([self.origo isOfType:kOrigoTypeMemberRoot]) {
        self.type = kMembershipTypeMemberRoot;
    } else if ([self.origo isOfType:kOrigoTypeResidence]) {
        self.type = kMembershipTypeResidency;
    } else {
        self.type = kMembershipTypeParticipancy;
    }
}


#pragma mark - OReplicatedEntity (OrigoExtensions) overrides

- (BOOL)isTransient
{
    return ([super isTransient] || [self.origo isTransient]);
}


- (void)expire
{
    if (![self isAssociate] && [self.origo indirectlyKnowsAboutMember:self.member]) {
        [self demoteToAssociate];
    } else {
        if ([self shouldReplicateOnExpiry]) {
            [super expire];
            
            self.contactRole = nil;
            self.contactType = nil;
            self.isActive = @NO;
            self.isAdmin = @NO;
            
            [[OMeta m].context expireCrossReferencesForMembership:self];
        } else {
            [super expire];
        }
        
        if ([self.member isUser]) {
            for (OMembership *membership in [self.origo allMemberships]) {
                if (![membership.member isKnownByUser]) {
                    [[OMeta m].context deleteEntity:membership.member];
                }
                
                [[OMeta m].context deleteEntity:membership];
            }
            
            [[OMeta m].context deleteEntity:self.origo];
        } else if (![self.member isKnownByUser]) {
            for (OMembership *membership in [self.member allMemberships]) {
                [[membership.origo membershipForMember:[OMeta m].user] expire];
                [[OMeta m].context deleteEntity:membership];
            }
            
            [[OMeta m].context deleteEntity:self.member];
        }
    }
}

@end
