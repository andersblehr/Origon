//
//  OSettingListViewController.m
//  OrigoApp
//
//  Created by Anders Blehr on 17.10.12.
//  Copyright (c) 2012 Rhelba Creations. All rights reserved.
//

#import "OSettingListViewController.h"

#import "UIBarButtonItem+OrigoExtensions.h"
#import "UITableView+OrigoExtensions.h"

#import "OLocator.h"
#import "OLogging.h"
#import "OMeta.h"
#import "OState.h"
#import "OStrings.h"
#import "OTableViewCell.h"

#import "OSettings+OrigoExtensions.h"

#import "OTabBarController.h"

static NSString * const kSegueToSettingView = @"sequeFromSettingListToSettingView";

static NSInteger const kSettingsSectionKey = 0;


@implementation OSettingListViewController

#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = [OStrings stringForKey:strTabBarTitleSettings];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem signOutButtonWithTarget:self];
}


#pragma mark - UIViewController overrides

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kSegueToSettingView]) {
        [self prepareForPushSegue:segue];
    }
}


#pragma mark - OTableViewControllerInstance conformance

- (void)initialiseState
{
    self.target = kTargetUser;
    
    if (![OMeta m].settings.countryCode) {
        [OMeta m].settings.countryCode = [[OMeta m] inferredCountryCode];
    }
}


- (void)initialiseDataSource
{
    [self setData:[[OMeta m].settings settingKeys] forSectionWithKey:kSettingsSectionKey];
}


- (BOOL)hasFooterForSectionWithKey:(NSInteger)sectionKey
{
    return NO;
}


- (void)didSelectCell:(OTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:kSegueToSettingView sender:self];
}


#pragma mark - OTableViewListCellDelegate conformance

- (void)populateListCell:(OTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSString *settingKey = [self dataAtIndexPath:indexPath];
    
    cell.textLabel.text = [OStrings labelForSettingKey:settingKey];
    cell.detailTextLabel.text = [[OMeta m].settings displayValueForSettingKey:settingKey];
}


- (UITableViewCellStyle)styleForIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellStyleValue1;
}

@end