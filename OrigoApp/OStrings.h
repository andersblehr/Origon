//
//  OStrings.h
//  OrigoApp
//
//  Created by Anders Blehr on 17.10.12.
//  Copyright (c) 2012 Rhelba Creations. All rights reserved.
//

#import <Foundation/Foundation.h>

// Cross-view strings
extern NSString * const strButtonOK;
extern NSString * const strButtonEdit;
extern NSString * const strButtonNext;
extern NSString * const strButtonDone;
extern NSString * const strButtonContinue;
extern NSString * const strButtonCancel;
extern NSString * const strButtonSignOut;
extern NSString * const strAlertTextNoInternet;
extern NSString * const strAlertTextServerError;
extern NSString * const strTermAddress;
extern NSString * const strTermCountry;

// OAuthView strings
extern NSString * const strLabelSignIn;
extern NSString * const strLabelActivate;
extern NSString * const strFooterSignInOrRegister;
extern NSString * const strFooterActivate;
extern NSString * const strFooterActivateEmail;
extern NSString * const strPlaceholderAuthEmail;
extern NSString * const strPlaceholderPassword;
extern NSString * const strPlaceholderActivationCode;
extern NSString * const strPlaceholderRepeatPassword;
extern NSString * const strPlaceholderPleaseWait;
extern NSString * const strButtonHaveCode;
extern NSString * const strButtonStartOver;
extern NSString * const strButtonAccept;
extern NSString * const strButtonDecline;
extern NSString * const strAlertTitleActivationFailed;
extern NSString * const strAlertTextActivationFailed;
extern NSString * const strAlertTitleWelcomeBack;
extern NSString * const strAlertTextWelcomeBack;
extern NSString * const strAlertTitleIncompleteRegistration;
extern NSString * const strAlertTextIncompleteRegistration;

// OOrigoListView strings
extern NSString * const strTabBarTitleOrigo;
extern NSString * const strViewTitleWardOrigoList;
extern NSString * const strHeaderWardsOrigos;
extern NSString * const strHeaderMyOrigos;
extern NSString * const strFooterOrigoCreationFirst;
extern NSString * const strFooterOrigoCreation;
extern NSString * const strFooterOrigoCreationWards;
extern NSString * const strButtonCountryOfLocation;
extern NSString * const strButtonCountryOther;
extern NSString * const strAlertTitleCountry;
extern NSString * const strAlertTextCountry;
extern NSString * const strSheetTitleCountryLocate;
extern NSString * const strSheetTitleCountryNoLocate;
extern NSString * const strSheetTitleOrigoType;
extern NSString * const strTermMe;
extern NSString * const strTermYourChild;
extern NSString * const strTermHim;
extern NSString * const strTermHer;
extern NSString * const strTermHimOrHer;
extern NSString * const strTermForName;

// OMemberListView strings
extern NSString * const strViewTitleMembers;
extern NSString * const strViewTitleHousehold;
extern NSString * const strHeaderContacts;
extern NSString * const strHeaderHouseholdMembers;
extern NSString * const strHeaderOrigoMembers;
extern NSString * const strFooterResidence;
extern NSString * const strFooterSchoolClass;
extern NSString * const strFooterPreschoolClass;
extern NSString * const strFooterSportsTeam;
extern NSString * const strFooterOtherOrigo;
extern NSString * const strButtonNewHousemate;
extern NSString * const strButtonDeleteMember;

// OOrigoView strings
extern NSString * const strDefaultResidenceName;
extern NSString * const strViewTitleNewOrigo;
extern NSString * const strLabelAddress;
extern NSString * const strLabelTelephone;
extern NSString * const strHeaderAddresses;
extern NSString * const strPlaceholderAddress;
extern NSString * const strPlaceholderTelephone;

// OMemberView strings
extern NSString * const strViewTitleAboutMe;
extern NSString * const strViewTitleNewMember;
extern NSString * const strViewTitleNewHouseholdMember;
extern NSString * const strLabelEmail;
extern NSString * const strLabelMobilePhone;
extern NSString * const strLabelDateOfBirth;
extern NSString * const strLabelAbbreviatedEmail;
extern NSString * const strLabelAbbreviatedMobilePhone;
extern NSString * const strLabelAbbreviatedDateOfBirth;
extern NSString * const strLabelAbbreviatedTelephone;
extern NSString * const strPlaceholderPhoto;
extern NSString * const strPlaceholderName;
extern NSString * const strPlaceholderEmail;
extern NSString * const strPlaceholderDateOfBirth;
extern NSString * const strPlaceholderMobilePhone;
extern NSString * const strFooterMember;
extern NSString * const strButtonNewAddress;
extern NSString * const strButtonInviteToHousehold;
extern NSString * const strButtonMergeHouseholds;
extern NSString * const strAlertTitleMemberExists;
extern NSString * const strAlertTextMemberExists;
extern NSString * const strAlertTitleUserEmailChange;
extern NSString * const strAlertTextUserEmailChange;
extern NSString * const strAlertTitleEmailChangeFailed;
extern NSString * const strAlertTextEmailChangeFailed;
extern NSString * const strSheetTitleGenderSelf;
extern NSString * const strSheetTitleGenderSelfMinor;
extern NSString * const strSheetTitleGenderMember;
extern NSString * const strSheetTitleGenderMinor;
extern NSString * const strSheetTitleExistingResidence;
extern NSString * const strTermFemale;
extern NSString * const strTermFemaleMinor;
extern NSString * const strTermMale;
extern NSString * const strTermMaleMinor;

// OCalendarView strings
extern NSString * const strTabBarTitleCalendar;

// OTaskListView strings
extern NSString * const strTabBarTitleTasks;

// OMessageListView strings
extern NSString * const strTabBarTitleMessages;
extern NSString * const strDefaultMessageBoardName;

// OSettingListView strings
extern NSString * const strTabBarTitleSettings;
extern NSString * const strSettingTitleCountry;
extern NSString * const strSettingTextCountry;

// OSettingView strings
extern NSString * const strLabelCountrySettings;
extern NSString * const strLabelCountryLocation;
extern NSString * const strFooterCountryInfoParenthesis;
extern NSString * const strFooterCountryInfoLocate;

// Origo type strings
extern NSString * const strOrigoTypeResidence;
extern NSString * const strOrigoTypeOrganisation;
extern NSString * const strOrigoTypeAssociation;
extern NSString * const strOrigoTypeSchoolClass;
extern NSString * const strOrigoTypePreschoolClass;
extern NSString * const strOrigoTypeSportsTeam;
extern NSString * const strOrigoTypeOther;
extern NSString * const strNewOrigoOfTypeResidence;
extern NSString * const strNewOrigoOfTypeOrganisation;
extern NSString * const strNewOrigoOfTypeAssociation;
extern NSString * const strNewOrigoOfTypeSchoolClass;
extern NSString * const strNewOrigoOfTypePreschoolClass;
extern NSString * const strNewOrigoOfTypeSportsTeam;
extern NSString * const strNewOrigoOfTypeOther;

// Meta strings
extern NSString * const metaSupportedCountryCodes;
extern NSString * const metaContactRolesSchoolClass;
extern NSString * const metaContactRolesPreschoolClass;
extern NSString * const metaContactRolesAssociation;
extern NSString * const metaContactRolesSportsTeam;


@interface OStrings : NSObject

+ (BOOL)hasStrings;
+ (void)refreshIfNeeded;

+ (NSString *)stringForKey:(NSString *)key;
+ (NSString *)labelForKey:(NSString *)key;
+ (NSString *)placeholderForKey:(NSString *)key;

+ (NSString *)titleForOrigoType:(NSString *)origoType;
+ (NSString *)titleForContactRole:(NSString *)contactRole;
+ (NSString *)titleForSettingKey:(NSString *)settingKey;
+ (NSString *)textForSettingKey:(NSString *)settingKey;

@end
