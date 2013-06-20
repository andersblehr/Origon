//
//  OTableViewControllerInstance.h
//  OrigoApp
//
//  Created by Anders Blehr on 17.01.13.
//  Copyright (c) 2013 Rhelba Creations. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OTableViewCell.h"

@protocol OTableViewControllerInstance <NSObject>

@required
- (void)initialiseState;
- (void)initialiseDataSource;

@optional
- (BOOL)hasHeaderForSectionWithKey:(NSInteger)sectionKey;
- (BOOL)hasFooterForSectionWithKey:(NSInteger)sectionKey;
- (NSString *)textForHeaderInSectionWithKey:(NSInteger)sectionKey;
- (NSString *)textForFooterInSectionWithKey:(NSInteger)sectionKey;

- (NSString *)reuseIdentifierForIndexPath:(NSIndexPath *)indexPath;
- (void)willDisplayCell:(OTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)didSelectCell:(OTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

- (void)didResumeFromBackground;

@end
