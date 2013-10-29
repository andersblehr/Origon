//
//  UIFont+OrigoExtensions.h
//  OrigoApp
//
//  Created by Anders Blehr on 17.10.12.
//  Copyright (c) 2012 Rhelba Creations. All rights reserved.
//

#import "OrigoApp.h"

@interface UIFont (OrigoExtensions)

+ (UIFont *)navigationBarTitleFont;
+ (UIFont *)navigationBarSubtitleFont;
+ (UIFont *)headerFont;
+ (UIFont *)footerFont;
+ (UIFont *)titleFont;
+ (UIFont *)detailFont;
+ (UIFont *)listTextFont;
+ (UIFont *)listDetailFont;

+ (CGFloat)titleFieldHeight;
+ (CGFloat)detailFieldHeight;
+ (CGFloat)detailLineHeight;

- (CGFloat)textFieldHeight;

@end
