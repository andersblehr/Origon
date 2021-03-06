//
//  NSLocale+OrigonAdditions.m
//  Origon
//
//  Created by Anders Blehr on 17.10.12.
//  Copyright (c) 2012 Rhelba Source. All rights reserved.
//

#import "NSLocale+OrigonAdditions.h"


@implementation NSLocale (OrigonAdditions)

+ (NSString *)countryCode
{
    return [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
}


+ (NSString *)regionIdentifier
{
    NSArray *multiLingualCountryCodes = @[@"CA"];
    NSString *regionIdentifier = [self countryCode];
    
    if ([multiLingualCountryCodes containsObject:regionIdentifier]) {
        regionIdentifier = [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];
    }
    
    return regionIdentifier;
}

@end
