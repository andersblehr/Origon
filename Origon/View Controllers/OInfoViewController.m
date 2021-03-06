//
//  OInfoViewController.m
//  Origon
//
//  Created by Anders Blehr on 11.10.14.
//  Copyright (c) 2014 Rhelba Source. All rights reserved.
//

#import "OInfoViewController.h"

static NSInteger const kSectionKeyGeneral = 0;
static NSInteger const kSectionKeyParents = 1;
static NSInteger const kSectionKeyMembership = 2;


@interface OInfoViewController () <OTableViewController> {
@private
    id _entity;
}

@end


@implementation OInfoViewController

#pragma mark - Auxiliary methods

- (NSArray *)displayableKeys
{
    NSMutableArray *displayableKeys = [NSMutableArray array];
    
    if ([_entity conformsToProtocol:@protocol(OOrigo)]) {
        id<OOrigo> origo = _entity;
        
        if (![origo isResidence] || [origo userIsAdmin] || ![origo hasAdmin]) {
            if (![origo isResidence] || [self aspectIs:kAspectHousehold]) {
                [displayableKeys addObject:kPropertyKeyName];
            }
            
            if (![origo isResidence]) {
                [displayableKeys addObject:kPropertyKeyType];
            }
            
            [displayableKeys addObject:kPropertyKeyCreatedBy];
            
            if ([_entity modifiedBy]) {
                [displayableKeys addObject:kPropertyKeyModifiedBy];
            }
        }
        
        if (![origo isOfType:@[kOrigoTypeStash, kOrigoTypePrivate, kOrigoTypeResidence]]) {
            [displayableKeys addObject:kLabelKeyAdmins];
            
            if ([origo userIsAdmin]) {
                [displayableKeys addObject:kPropertyKeyPermissions];
            }
            
            [displayableKeys addObject:kPropertyKeyJoinCode];
        }
    } else if ([_entity conformsToProtocol:@protocol(OMember)]) {
        id<OMember> member = _entity;
        
        if ((![member isActive] && ![member isManaged]) || [member isHousemateOfUser]) {
            if ([member userCanEdit]) {
                [displayableKeys addObject:kPropertyKeyGender];
            }
            
            if ([self aspectIs:kAspectHousehold]) {
                if ([member.createdIn hasValue]) {
                    [displayableKeys addObject:kPropertyKeyCreatedIn];
                }
            }
            
            [displayableKeys addObject:kPropertyKeyCreatedBy];
            
            if ([_entity modifiedBy]) {
                [displayableKeys addObject:kPropertyKeyModifiedBy];
            }
        }
        
        if (![member isActive]) {
            [displayableKeys addObject:kPropertyKeyActiveSince];
        }
    }
    
    return displayableKeys;
}


- (void)listCell:(OTableViewCell *)cell loadDetailsForInstigatorWithId:(NSString *)instigatorId
{
    id<OMember> instigator = [[OMeta m].context entityWithId:instigatorId];
    
    if (instigator) {
        cell.detailTextLabel.text = [instigator shortName];
        
        if ([instigator isUser] || [[_entity entityId] isEqualToString:instigator.entityId]) {
            cell.selectable = NO;
        } else {
            cell.destinationId = kIdentifierMember;
            cell.destinationTarget = instigator;
        }
    } else {
        // TODO: Look up remotely
    }
}


#pragma mark - OTableViewController conformance

- (void)loadState
{
    _entity = [self.entity proxy];
    
    if ([_entity conformsToProtocol:@protocol(OOrigo)]) {
        id<OOrigo> origo = _entity;
        
        if ([origo isResidence]) {
            self.title = OLocalizedString(@"About this household", @"");
        } else {
            self.title = OLocalizedString(@"About this list", @"");
        }
        
        self.navigationItem.backBarButtonItem = [UIBarButtonItem backButtonWithTitle:OLocalizedString(@"About", @"")];
    } else if ([_entity conformsToProtocol:@protocol(OMember)]) {
        id<OMember> member = _entity;
        
        self.title = member.name;
        self.navigationItem.backBarButtonItem = [UIBarButtonItem backButtonWithTitle:[member givenName]];
    }
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem closeButtonWithTarget:self];
}


- (void)loadData
{
    [self setData:[self displayableKeys] forSectionWithKey:kSectionKeyGeneral];
    
    if ([_entity conformsToProtocol:@protocol(OOrigo)]) {
        id<OOrigo> origo = _entity;
        
        if (![origo isOfType:@[kOrigoTypeResidence, kOrigoTypePrivate]]) {
            id<OMembership> membership = [origo userMembership];
        
            [self setData:@[kPropertyKeyType, kPropertyKeyCreatedBy] forSectionWithKey:kSectionKeyMembership];
            
            if (membership.modifiedBy) {
                [self appendData:@[kPropertyKeyModifiedBy] toSectionWithKey:kSectionKeyMembership];
            }
        }
    } else if ([_entity conformsToProtocol:@protocol(OMember)]) {
        id<OMember> member = _entity;
        
        if ([member isJuvenile] && ([member isUser] || [member isWardOfUser])) {
            [self setData:@[kPropertyKeyMotherId, kPropertyKeyFatherId] forSectionWithKey:kSectionKeyParents];
        }
        
    }
}


- (void)loadListCell:(OTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger sectionKey = [self sectionKeyForIndexPath:indexPath];
    
    cell.selectable = NO;
    
    if (sectionKey == kSectionKeyGeneral) {
        NSString *displayKey = [self dataAtIndexPath:indexPath];
        
        cell.textLabel.text = OLocalizedString(displayKey, kStringPrefixLabel);
        
        if ([displayKey isEqualToString:kPropertyKeyCreatedBy]) {
            if ([_entity conformsToProtocol:@protocol(OOrigo)]) {
                cell.textLabel.text = OLocalizedString(displayKey, kStringPrefixAlternateLabel);
            }
            
            [self listCell:cell loadDetailsForInstigatorWithId:[_entity createdBy]];
        } else if ([displayKey isEqualToString:kPropertyKeyModifiedBy]) {
            [self listCell:cell loadDetailsForInstigatorWithId:[_entity modifiedBy]];
        } else if ([_entity conformsToProtocol:@protocol(OOrigo)]) {
            id<OOrigo> origo = [_entity instance];
            
            if ([displayKey isEqualToString:kPropertyKeyName]) {
                cell.detailTextLabel.text = [origo displayName];
            } else if ([displayKey isEqualToString:kPropertyKeyType]) {
                if ([origo isPrivate] && [[origo owner] isJuvenile]) {
                    cell.detailTextLabel.text = OLocalizedString(@"Private list of friends", @"");
                } else {
                    cell.detailTextLabel.text = OLocalizedString(origo.type, kStringPrefixOrigoTitle);
                }
                
                if (self.isOnline) {
                    BOOL canEdit = [origo userIsAdmin] && ![origo isResidence] && ![origo isCommunity];
                    
                    if (canEdit && [origo isPrivate]) {
                        canEdit = ![origo isPinned];
                    }
                    
                    if (canEdit && [[OMeta m].user isJuvenile]) {
                        canEdit = [origo isPrivate];
                    }
                    
                    if (canEdit) {
                        cell.destinationId = kIdentifierValuePicker;
                        cell.destinationTarget = kTargetOrigoType;
                    }
                }
            } else if ([displayKey isEqualToString:kPropertyKeyJoinCode]) {
                cell.destinationId = kIdentifierJoiner;
                cell.destinationTarget = kTargetJoinCode;
                
                if ([origo.joinCode hasValue]) {
                    cell.detailTextLabel.text = origo.joinCode;
                } else {
                    cell.notificationView = [OButton infoButton];
                }
            } else if ([displayKey isEqualToString:kLabelKeyAdmins]) {
                NSInteger adminCount = [origo admins].count;
                
                if (adminCount > 1) {
                    cell.textLabel.text = [[OLanguage nouns][_administrator_][pluralIndefinite] stringByCapitalisingFirstLetter];
                } else {
                    cell.textLabel.text = [[OLanguage nouns][_administrator_][singularIndefinite] stringByCapitalisingFirstLetter];
                }
                
                cell.detailTextLabel.text = [OUtil commaSeparatedListOfMembers:[origo admins] inOrigo:origo subjective:NO];
                
                if ([origo userIsAdmin]) {
                    if (self.isOnline) {
                        cell.destinationId = kIdentifierValuePicker;
                    } else if (adminCount > 1) {
                        cell.destinationId = kIdentifierValueList;
                    }
                } else if (adminCount > 1) {
                    cell.destinationId = kIdentifierValueList;
                } else if (adminCount == 1) {
                    cell.destinationId = kIdentifierMember;
                    cell.destinationTarget = [origo admins][0];
                }
            } else if ([displayKey isEqualToString:kPropertyKeyPermissions]) {
                cell.textLabel.text = OLocalizedString(@"User permissions", @"");
                cell.detailTextLabel.text = [origo displayPermissions];
                
                if (self.isOnline) {
                    cell.destinationId = kIdentifierValueList;
                }
            }
        } else if ([_entity conformsToProtocol:@protocol(OMember)]) {
            id<OMember> member = _entity;
            
            if ([displayKey isEqualToString:kPropertyKeyGender]) {
                cell.detailTextLabel.text = [[OLanguage genderTermForGender:member.gender isJuvenile:[member isJuvenile]] stringByCapitalisingFirstLetter];
                
                if ([member userCanEdit] && self.isOnline) {
                    cell.destinationId = kIdentifierValuePicker;
                    cell.destinationTarget = kTargetGender;
                }
            } else if ([displayKey isEqualToString:kPropertyKeyCreatedIn]) {
                NSArray *components = [member.createdIn componentsSeparatedByString:kSeparatorList];
                
                if ([components[0] isEqualToString:kOrigoTypePrivate]) {
                    NSInteger numberOfComponents = components.count;
                    
                    if (numberOfComponents == 1) {
                        cell.detailTextLabel.text = OLocalizedString(kOrigoTypePrivate, kStringPrefixTitle);
                    } else if (numberOfComponents == 2) {
                        cell.detailTextLabel.text = [NSString stringWithFormat:OLocalizedString(@"%@'s friends", @""), components[1]];
                    }
                } else {
                    id<OOrigo> createdIn = [[OMeta m].context entityWithId:components[0]];
                    
                    if (createdIn) {
                        cell.detailTextLabel.text = [createdIn displayName];
                        cell.destinationId = kIdentifierOrigo;
                        cell.destinationTarget = createdIn;
                    } else {
                        cell.detailTextLabel.text = components[1];
                    }
                }
            } else if ([displayKey isEqualToString:kPropertyKeyActiveSince]) {
                cell.textLabel.text = [NSString stringWithFormat:OLocalizedString(@"On %@", @""), [OMeta m].appName];
                
                if ([member isManaged]) {
                    cell.detailTextLabel.text = OLocalizedString(@"Through household", @"");
                } else {
                    cell.detailTextLabel.text = OLocalizedString(@"No", @"");
                }
            }
        }
    } else if (sectionKey == kSectionKeyParents) {
        NSString *propertyKey = [self dataAtIndexPath:indexPath];
        
        cell.textLabel.text = OLocalizedString(propertyKey, kStringPrefixLabel);
        
        if ([propertyKey isEqualToString:kPropertyKeyMotherId]) {
            cell.detailTextLabel.text = [_entity mother].name;
        } else {
            cell.detailTextLabel.text = [_entity father].name;
        }

        cell.destinationId = kIdentifierValuePicker;
        cell.destinationTarget = @{propertyKey: kAspectParent};
        cell.destinationMeta = _entity;
    } else if (sectionKey == kSectionKeyMembership) {
        id<OOrigo> origo = _entity;
        id<OMembership> membership = [origo userMembership];
        
        NSString *propertyKey = [self dataAtIndexPath:indexPath];
        
        if ([propertyKey isEqualToString:kPropertyKeyType]) {
            cell.textLabel.text = OLocalizedString(@"My membership", @"");
            
            if ([origo userIsAdmin]) {
                cell.detailTextLabel.text = [[OLanguage nouns][_administrator_][singularIndefinite] stringByCapitalisingFirstLetter];
            } else if ([membership organiserRoles].count) {
                cell.detailTextLabel.text = OLocalizedString(origo.type, kStringPrefixOrganiserTitle);
            } else if ([membership parentRoles].count) {
                cell.detailTextLabel.text = [[OLanguage nouns][_parentContact_][singularIndefinite] stringByCapitalisingFirstLetter];
            } else if ([[OMeta m].user wardsInOrigo:origo].count) {
                cell.detailTextLabel.text = [[OLanguage nouns][_guardian_][singularIndefinite] stringByCapitalisingFirstLetter];
            } else if ([membership roles].count) {
                cell.detailTextLabel.text = [[OUtil commaSeparatedListOfNouns:[membership roles] conjoin:NO] stringByCapitalisingFirstLetter];
            } else if ([membership isParticipancy]) {
                cell.detailTextLabel.text = OLocalizedString(@"Regular member", @"");
            } else if ([membership isCommunityMembership]) {
                cell.detailTextLabel.text = OLocalizedString(@"Community member", @"");
            }
        } else {
            cell.textLabel.text = OLocalizedString(propertyKey, kStringPrefixLabel);
            
            if ([propertyKey isEqualToString:kPropertyKeyCreatedBy]) {
                [self listCell:cell loadDetailsForInstigatorWithId:membership.createdBy];
            } else if ([propertyKey isEqualToString:kPropertyKeyModifiedBy]) {
                [self listCell:cell loadDetailsForInstigatorWithId:membership.modifiedBy];
            }
        }
    }
}


- (UITableViewCellStyle)listCellStyleForSectionWithKey:(NSInteger)sectionKey
{
    return UITableViewCellStyleValue1;
}


- (BOOL)hasHeaderForSectionWithKey:(NSInteger)sectionKey
{
    return NO;
}


- (BOOL)hasFooterForSectionWithKey:(NSInteger)sectionKey
{
    return sectionKey == kSectionKeyGeneral || sectionKey == kSectionKeyMembership;
}


- (id)footerContentForSectionWithKey:(NSInteger)sectionKey
{
    NSString *footerContent = nil;
    
    if (sectionKey == kSectionKeyGeneral) {
        if ([_entity conformsToProtocol:@protocol(OOrigo)]) {
            footerContent = [NSString stringWithFormat:OLocalizedString(@"Created %@.", @""), [[_entity dateCreated] localisedDateString]];
        } else if ([_entity conformsToProtocol:@protocol(OMember)]) {
            footerContent = [NSString stringWithFormat:OLocalizedString(@"Registered %@.", @""), [[_entity dateCreated] localisedDateString]];
            
            if ([_entity isActive] && ([_entity isHousemateOfUser] || [_entity isTeenOrOlder])) {
                footerContent = [footerContent stringByAppendingString:[NSString stringWithFormat:OLocalizedString(@"Active on %@ since %@.", @""), [OMeta m].appName, [[_entity activeSince] localisedDateString]] separator:kSeparatorNewline];
            }
        }
        
        if ([_entity modifiedBy]) {
            footerContent = [footerContent stringByAppendingString:[NSString stringWithFormat:OLocalizedString(@"Last modified %@.", @""), [[_entity dateReplicated] localisedDateString]] separator:kSeparatorNewline];
        }
    } else if (sectionKey == kSectionKeyMembership) {
        id<OMembership> membership = [_entity userMembership];
        
        footerContent = [NSString stringWithFormat:OLocalizedString(@"Registered %@.", @""), [membership.dateCreated localisedDateString]];
        
        if (membership.modifiedBy) {
            footerContent = [footerContent stringByAppendingString:[NSString stringWithFormat:OLocalizedString(@"Last modified %@.", @""), [membership.dateReplicated localisedDateString]] separator:kSeparatorNewline];
        }
    }
    
    return footerContent;
}


- (NSString *)emptyTableViewFooterText
{
    return [self footerContentForSectionWithKey:kSectionKeyGeneral];
}


- (void)onlineStatusDidChange
{
    [self reloadSectionWithKey:kSectionKeyGeneral];
}

@end
