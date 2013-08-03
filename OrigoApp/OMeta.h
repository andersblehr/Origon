//
//  OMeta.h
//  OrigoApp
//
//  Created by Anders Blehr on 17.10.12.
//  Copyright (c) 2012 Rhelba Creations. All rights reserved.
//

#import "OrigoApp.h"

extern NSString * const kBundleId;

extern NSString * const kGenderFemale;
extern NSString * const kGenderMale;

extern NSInteger const kAgeThresholdToddler;
extern NSInteger const kAgeThresholdInSchool;
extern NSInteger const kAgeThresholdTeen;
extern NSInteger const kAgeOfConsent;
extern NSInteger const kAgeOfMajority;

extern NSString * const kLanguageHungarian;

extern NSString * const kIconFileOrigo;
extern NSString * const kIconFileHousehold;
extern NSString * const kIconFileMan;
extern NSString * const kIconFileWoman;
extern NSString * const kIconFileBoy;
extern NSString * const kIconFileGirl;
extern NSString * const kIconFileInfant;
extern NSString * const kIconFileLocationArrow;

extern NSString * const kInputKeyActivate;
extern NSString * const kInputKeyActivationCode;
extern NSString * const kInputKeyAuthEmail;
extern NSString * const kInputKeyPassword;
extern NSString * const kInputKeyRepeatPassword;
extern NSString * const kInputKeySignIn;

extern NSString * const kJSONKeyActivationCode;
extern NSString * const kJSONKeyDeviceId;
extern NSString * const kJSONKeyEmail;
extern NSString * const kJSONKeyEntityClass;
extern NSString * const kJSONKeyPasswordHash;

extern NSString * const kPropertyKeyAddress;
extern NSString * const kPropertyKeyCountry;
extern NSString * const kPropertyKeyDateOfBirth;
extern NSString * const kPropertyKeyDescriptionText;
extern NSString * const kPropertyKeyEmail;
extern NSString * const kPropertyKeyEntityId;
extern NSString * const kPropertyKeyFatherId;
extern NSString * const kPropertyKeyGender;
extern NSString * const kPropertyKeyHashCode;
extern NSString * const kPropertyKeyIsAwaitingDeletion;
extern NSString * const kPropertyKeyIsExpired;
extern NSString * const kPropertyKeyMobilePhone;
extern NSString * const kPropertyKeyMotherId;
extern NSString * const kPropertyKeyName;
extern NSString * const kPropertyKeyOrigoId;
extern NSString * const kPropertyKeyPasswordHash;
extern NSString * const kPropertyKeyTelephone;

extern NSString * const kRelationshipKeyMember;
extern NSString * const kRelationshipKeyOrigo;

extern NSString * const kDefaultsKeyAuthInfo;
extern NSString * const kDefaultsKeyDirtyEntities;
extern NSString * const kDefaultsKeyStringDate;

@interface OMeta : NSObject {
@private
    Reachability *_internetReachability;
    
    NSNumber *_isSignedIn;
    NSDate *_authTokenExpiryDate;
}

@property (nonatomic, readonly) BOOL internetConnectionIsWiFi;
@property (nonatomic, readonly) BOOL internetConnectionIsWWAN;
@property (nonatomic, readonly) BOOL userDidJustSignUp;

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *userEmail;
@property (strong, nonatomic) NSString *deviceId;
@property (strong, nonatomic) NSString *lastReplicationDate;

@property (strong, nonatomic, readonly) NSString *authToken;
@property (strong, nonatomic, readonly) NSString *appVersion;
@property (strong, nonatomic, readonly) NSString *displayLanguage;

@property (strong, nonatomic, readonly) OMember *user;
@property (strong, nonatomic, readonly) OSettings *settings;
@property (strong, nonatomic, readonly) OReplicator *replicator;
@property (strong, nonatomic, readonly) OLocator *locator;

@property (strong, nonatomic, readonly) UIDatePicker *sharedDatePicker;
@property (weak, nonatomic, readonly) NSManagedObjectContext *context;

+ (OMeta *)m;

- (void)userDidSignUp;
- (void)userDidSignIn;
- (void)userDidSignOut;

- (BOOL)userIsSignedIn;
- (BOOL)userIsRegistered;
- (BOOL)userIsAllSet;

- (BOOL)internetConnectionIsAvailable;
- (BOOL)shouldUseEasternNameOrder;
- (BOOL)deviceIsSimulator;

- (NSArray *)supportedCountryCodes;
- (NSString *)inferredCountryCode;

@end
