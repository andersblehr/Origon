//
//  UIColor+OrigoAdditions.m
//  OrigoApp
//
//  Created by Anders Blehr on 17.10.12.
//  Copyright (c) 2012 Rhelba Creations. All rights reserved.
//

#import "UIColor+OrigoAdditions.h"


@implementation UIColor (OrigoAdditions)

#pragma mark - Core iOS 7 palette RGB shorthands

+ (UIColor *)manateeColour // Grey
{
    return [UIColor colorWithRed:142/255.f green:142/255.f blue:147/255.f alpha:1.f];
}


+ (UIColor *)radicalRedColour
{
    return [UIColor colorWithRed:255/255.f green:45/255.f blue:85/255.f alpha:1.f];
}


+ (UIColor *)redOrangeColour
{
    return [UIColor colorWithRed:255/255.f green:59/255.f blue:48/255.f alpha:1.f];
}


+ (UIColor *)pizazzColour // Orange
{
    return [UIColor colorWithRed:255/255.f green:149/255.f blue:0/255.f alpha:1.f];
}


+ (UIColor *)supernovaColour // Yellow
{
    return [UIColor colorWithRed:255/255.f green:204/255.f blue:0/255.f alpha:1.f];
}


+ (UIColor *)emeraldColour // Green
{
    return [UIColor colorWithRed:76/255.f green:217/255.f blue:100/255.f alpha:1.f];
}


+ (UIColor *)malibuColour // Bright blue
{
    return [UIColor colorWithRed:90/255.f green:200/255.f blue:250/255.f alpha:1.f];
}


+ (UIColor *)curiousBlueColour // Soft blue
{
    return [UIColor colorWithRed:52/255.f green:170/255.f blue:220/255.f alpha:1.f];
}


+ (UIColor *)azureRadianceColour // Standard UI blue
{
    return [UIColor colorWithRed:0/255.f green:122/255.f blue:255/255.f alpha:1.f];
}


+ (UIColor *)indigoColour
{
    return [UIColor colorWithRed:88/255.f green:86/255.f blue:214/255.f alpha:1.f];
}


#pragma mark - iOS 7 default colours


+ (UIColor *)toolbarShadowColour
{
    return [UIColor colorWithRed:245/255.f green:245/255.f blue:246/255.f alpha:1.f];
}


+ (UIColor *)tableViewBackgroundColour
{
    return [UIColor colorWithRed:239/255.f green:239/255.f blue:244/255.f alpha:1.f];
}


+ (UIColor *)tableViewSeparatorColour
{
    return [UIColor colorWithRed:200/255.f green:199/255.f blue:204/255.f alpha:1.f];
}


+ (UIColor *)cellBackgroundColour
{
    return [UIColor whiteColor];
}


+ (UIColor *)selectedCellBackgroundColour
{
    return [UIColor tableViewSeparatorColour];
}


+ (UIColor *)alertViewBackgroundColour
{
    return [UIColor colorWithRed:226.f/255 green:226.f/255 blue:226.f/255 alpha:1.f];
}


#pragma mark - Interface colours

+ (UIColor *)windowTintColour
{
    return [UIColor pizazzColour];
}


+ (UIColor *)titleBackgroundColour
{
    return [UIColor windowTintColour];
}


+ (UIColor *)titlePlaceholderColour
{
    return [UIColor colorWithWhite:1.f alpha:0.6f];
}


+ (UIColor *)imagePlaceholderBackgroundColour
{
    return [UIColor tableViewBackgroundColour];
}


+ (UIColor *)iOS6BarButtonItemColour
{
    return [UIColor colorWithRed:255/255.f green:192/255.f blue:104/255.f alpha:1.f];
}


#pragma mark - Text colours

+ (UIColor *)textColour
{
    return [UIColor blackColor];
}


+ (UIColor *)placeholderTextColour
{
    return [OMeta systemIs_iOS6x] ? [UIColor lightGrayColor] : [UIColor colorWithRed:0/255.f green:0/255.f blue:25/255.f alpha:0.22f];
}


+ (UIColor *)headerTextColour
{
    return [UIColor darkGrayColor];
}


+ (UIColor *)footerTextColour
{
    return [UIColor darkGrayColor];
}


+ (UIColor *)titleTextColour
{
    return [UIColor whiteColor];
}


+ (UIColor *)labelTextColour
{
    return [UIColor windowTintColour];
}


+ (UIColor *)imagePlaceholderTextColour
{
    return [UIColor whiteColor];
}

@end