//
//  OPhoneNumberFormatter.m
//  OrigoApp
//
//  Created by Anders Blehr on 17.10.12.
//  Copyright (c) 2012 Rhelba Creations. All rights reserved.
//

#import "OPhoneNumberFormatter.h"

static NSString * const kTemplateGeneric = @"^[0]#* #@";
static NSString * const kFormatTokens = @"^*@+0123456789#N-()/ ";
static NSString * const kWildcardTokens = @"*@";
static NSString * const kCharacters2_9 = @"23456789";
static NSString * const kWhitespaceCharacters = @"-()/ ";
static NSString * const kPrintableCharacters = @"+0123456789-()/ ";

static NSString * const kTokenCanonical = @"^";
static NSString * const kTokenOptionalBegin = @"[";
static NSString * const kTokenOptionalEnd = @"]";
static NSString * const kTokenGroupBegin = @"{";
static NSString * const kTokenGroupSeparator = @"|";
static NSString * const kTokenGroupEnd = @"}";
static NSString * const kTokenPlus = @"+";
static NSString * const kTokenNumberAny = @"#";
static NSString * const kTokenNumber2_9 = @"N";
static NSString * const kTokenWildcardStrict = @"*";
static NSString * const kTokenWildcardTolerant = @"@";

static NSArray *_internationalFormats;
static NSArray *_supportedRegionIdentifiers = nil;
static NSMutableDictionary *_countryCodesByCountryCallingCode = nil;
static NSMutableDictionary *_templatesByRegionIdentifier = nil;
static NSMutableDictionary *_formattersByCountryCode = nil;

NSString * const kCharacters0_9 = @"0123456789";


@implementation OPhoneNumberFormatter

#pragma mark - Auxiliary methods

- (void)loadCountryCallingCodeToCountryCodeMappings
{
    _countryCodesByCountryCallingCode = [NSMutableDictionary dictionary];
    
    NSArray *mappings = [[OStrings stringForKey:metaCountryCodesByCountryCallingCode] componentsSeparatedByString:kSeparatorList];
    
    for (NSString *mapping in mappings) {
        NSArray *keyAndValue = [mapping componentsSeparatedByString:kSeparatorMapping];
        
        _countryCodesByCountryCallingCode[keyAndValue[0]] = keyAndValue[1];
    }
}


- (void)loadRegionToTemplateMappings
{
    _templatesByRegionIdentifier = [NSMutableDictionary dictionary];
    
    NSArray *mappings = [[OStrings stringForKey:metaPhoneNumberTemplatesByRegion] componentsSeparatedByString:kSeparatorList];
    
    for (NSString *mapping in mappings) {
        NSArray *keysAndValue = [mapping componentsSeparatedByString:kSeparatorMapping];
        NSArray *regionIdentifiers = [keysAndValue[0] componentsSeparatedByString:kSeparatorAlternates];
        
        for (NSString *regionIdentifier in regionIdentifiers) {
            _templatesByRegionIdentifier[regionIdentifier] = keysAndValue[1];
        }
    }
    
    _supportedRegionIdentifiers = [_templatesByRegionIdentifier allKeys];
}


- (NSString *)countryCodeFromPhoneNumber:(NSString *)phoneNumber
{
    NSString *countryCallingCode = nil;
    
    for (int i = 1; !countryCallingCode && (i < [phoneNumber length]); i++) {
        if ([kWhitespaceCharacters containsCharacter:[phoneNumber characterAtIndex:i]]) {
            countryCallingCode = [phoneNumber substringWithRange:NSMakeRange(1, i - 1)];
        }
    }
    
    return countryCallingCode ? _countryCodesByCountryCallingCode[countryCallingCode] : nil;
}


- (OPhoneNumberFormatter *)formatterForCountryCode:(NSString *)countryCode
{
    if (![[_formattersByCountryCode allKeys] containsObject:countryCode]) {
        _formattersByCountryCode[countryCode] = [[OPhoneNumberFormatter alloc] initWithRegionIdentifier:countryCode];
    }
    
    OPhoneNumberFormatter *formatter = _formattersByCountryCode[countryCode];
    
    return (formatter != self) ? formatter : nil;
}


#pragma mark - Parsing templates into formats

- (NSMutableArray *)flattenFormats:(NSMutableArray *)formats
{
    NSMutableArray *flattenedFormats = [NSMutableArray array];
    
    for (id format in formats) {
        if ([format isKindOfClass:[NSString class]]) {
            [flattenedFormats addObject:format];
        } else {
            [flattenedFormats addObjectsFromArray:[self flattenFormats:format]];
        }
    }
    
    return flattenedFormats;
}


- (NSMutableArray *)leafFormatsFromFormats:(NSMutableArray *)formats
{
    if (([formats count] == 1) && [formats[0] respondsToSelector:@selector(appendFormat:)]) {
        [formats addObject:[NSMutableString stringWithString:formats[0]]];
    }
    
    return [formats lastObject];
}


- (NSMutableArray *)levelFormats:(NSArray *)formats includeLeaves:(BOOL)includedLeaves
{
    NSMutableArray *levelFormats = [NSMutableArray array];
    
    for (int level = _optionalNestingLevel; level < [formats count]; level++) {
        NSMutableArray *nestedFormats = formats[level];
        
        for (int groupLevel = 0; groupLevel < _groupNestingLevel; groupLevel++) {
            nestedFormats = [nestedFormats lastObject];
            
            if ((groupLevel == _groupNestingLevel - 1) && includedLeaves) {
                nestedFormats = [self leafFormatsFromFormats:nestedFormats];
            }
        }
        
        [levelFormats addObject:nestedFormats];
    }
    
    return levelFormats;
}


- (void)appendToken:(NSString *)token toFormats:(id)formats
{
    if ([formats respondsToSelector:@selector(appendFormat:)]) {
        if (![token isEqualToString:kTokenCanonical] || ![formats containsString:kTokenCanonical]) {
            [formats appendString:token];
        }
    } else {
        for (id subformats in formats) {
            [self appendToken:token toFormats:subformats];
        }
    }
}


- (NSArray *)formatsFromTemplate:(NSString *)template
{
    // NOTE: Does not work with optional levels inside groups; e.g., {a[b]c|d[e]}
    
    _optionalNestingLevel = 0;
    _groupNestingLevel = 0;
    
    NSMutableArray *formats = [NSMutableArray arrayWithObject:[NSMutableArray arrayWithObject:[NSMutableString string]]];
    
    for (int i = 0; i < [template length]; i++) {
        NSString *token = [template substringWithRange:NSMakeRange(i, 1)];
        
        if ([kFormatTokens containsString:token]) {
            for (NSMutableArray *levelFormats in [self levelFormats:formats includeLeaves:YES]) {
                [self appendToken:token toFormats:levelFormats];
            }
        } else if ([token isEqualToString:kTokenOptionalBegin]) {
            _optionalNestingLevel++;
            
            if (_optionalNestingLevel == [formats count]) {
                formats[_optionalNestingLevel] = [NSMutableArray arrayWithObject:[NSMutableString stringWithString:formats[_optionalNestingLevel - 1][0]]];
            }
        } else if ([token isEqualToString:kTokenOptionalEnd]) {
            _optionalNestingLevel--;
        } else if ([token isEqualToString:kTokenGroupBegin]) {
            for (NSMutableArray *levelFormats in [self levelFormats:formats includeLeaves:NO]) {
                [levelFormats addObject:[NSMutableArray arrayWithObject:[NSMutableString stringWithString:[levelFormats lastObject]]]];
            }
            
            _groupNestingLevel++;
        } else if ([token isEqualToString:kTokenGroupSeparator]) {
            for (NSMutableArray *levelFormats in [self levelFormats:formats includeLeaves:NO]) {
                [levelFormats addObject:[NSMutableString stringWithString:levelFormats[0]]];
            }
        } else if ([token isEqualToString:kTokenGroupEnd]) {
            for (NSMutableArray *levelFormats in [self levelFormats:formats includeLeaves:NO]) {
                [levelFormats removeObjectAtIndex:0];
            }
            
            _groupNestingLevel--;
            
            if (!_groupNestingLevel) {
                for (NSMutableArray *levelFormats in formats) {
                    [levelFormats removeObjectAtIndex:0];
                }
            }
        }
    }
    
    return [self flattenFormats:formats];
}


- (NSMutableArray *)formatsFromTemplates:(NSString *)templates
{
    NSMutableArray *formats = [NSMutableArray array];
    
    for (NSString *template in [templates componentsSeparatedByString:kSeparatorList]) {
        [formats addObjectsFromArray:[self formatsFromTemplate:template]];
    }
    
    return formats;
}


#pragma mark - Matching phone numbers

- (NSString *)flattenPhoneNumber:(NSString *)phoneNumber
{
    NSMutableString *digits = [NSMutableString string];
    
    for (int i = 0; i < [phoneNumber length]; i++) {
        NSString *character = [phoneNumber substringWithRange:NSMakeRange(i, 1)];
        
        if ([kCharacters0_9 containsString:character] || [character isEqualToString:kTokenPlus]) {
            [digits appendString:character];
        }
    }
    
    return digits;
}


- (NSString *)nextToken
{
    NSString *token = nil;
    
    if (_tokenOffset < [_format length]) {
        token = [_format substringWithRange:NSMakeRange(_tokenOffset, 1)];
        
        _tokenOffset++;
    }
    
    return token;
}


- (NSString *)matchCharacter:(NSString *)character
{
    NSString *matchedCharacters = nil;
    
    if ([kPrintableCharacters containsString:character]) {
        NSString *token = [self nextToken];
        
        if (token) {
            if ([token isEqualToString:character] && ![kWildcardTokens containsString:token]) {
                matchedCharacters = character;
            } else if ([token isEqualToString:kTokenCanonical]) {
                _canonicalOffset = [_formattedPhoneNumber length];
                matchedCharacters = [self matchCharacter:character];
            } else if ([kWildcardTokens containsString:token]) {
                if ([kWhitespaceCharacters containsString:character]) {
                    if ([token isEqualToString:kTokenWildcardStrict]) {
                        matchedCharacters = [self matchCharacter:character];
                    } else {
                        _tokenOffset -= 1;
                        matchedCharacters = character;
                    }
                } else {
                    _tokenOffset -= 2;
                    matchedCharacters = [self matchCharacter:character];
                }
            } else if ([kWhitespaceCharacters containsString:character]) {
                _tokenOffset--;
                matchedCharacters = [NSString string];
            } else if ([kWhitespaceCharacters containsString:token]) {
                matchedCharacters = [self matchCharacter:character];
                
                if (matchedCharacters) {
                    matchedCharacters = [token stringByAppendingString:matchedCharacters];
                }
            } else if ([kCharacters0_9 containsString:character]) {
                if ([token isEqualToString:kTokenNumberAny]) {
                    matchedCharacters = [kCharacters0_9 containsString:character] ? character : nil;
                } else if ([token isEqualToString:kTokenNumber2_9]) {
                    matchedCharacters = [kCharacters2_9 containsString:character] ? character : nil;
                } else if ([token isEqualToString:character]) {
                    matchedCharacters = character;
                }
            }
        }
    } else {
        matchedCharacters = [NSString string];
    }
    
    return matchedCharacters;
}


- (BOOL)matchPhoneNumber:(NSString *)phoneNumber toFormat:(NSString *)format
{
    _format = format;
    _tokenOffset = 0;
    _canonicalOffset = 0;
    _formattedPhoneNumber = [NSString string];
    
    int i = 0;
    
    for (; _formattedPhoneNumber && (i < [phoneNumber length]); i++) {
        NSString *character = [phoneNumber substringWithRange:NSMakeRange(i, 1)];
        NSString *segment = [self matchCharacter:character];
        
        if (segment) {
            _formattedPhoneNumber = [_formattedPhoneNumber stringByAppendingString:segment];
        } else {
            _formattedPhoneNumber = nil;
        }
    }
    
    return (_formattedPhoneNumber != nil);
}


- (void)matchInternationalPhoneNumber:(NSString *)phoneNumber
{
    if (([phoneNumber length] > 1)) {
        BOOL isInternationalPhoneNumber = NO;
        
        for (NSString *format in _internationalFormats) {
            if (!isInternationalPhoneNumber) {
                isInternationalPhoneNumber = [self matchPhoneNumber:phoneNumber toFormat:format];
            }
        }
        
        if (isInternationalPhoneNumber) {
            NSString *countryCode = [self countryCodeFromPhoneNumber:_formattedPhoneNumber];
            
            if (countryCode && [_supportedRegionIdentifiers containsObject:countryCode]) {
                _formattedPhoneNumber = [[self formatterForCountryCode:countryCode] formatPhoneNumber:phoneNumber];
            }
        }
    }
}


#pragma mark - Initialisation

- (id)initWithRegionIdentifier:(NSString *)regionIdentifier
{
    self = [super init];
    
    if (self) {
        if (!_formattersByCountryCode) {
            _formattersByCountryCode = [NSMutableDictionary dictionary];
            _internationalFormats = [self formatsFromTemplate:[OStrings stringForKey:metaInternationalTemplate]];
            
            [self loadCountryCallingCodeToCountryCodeMappings];
            [self loadRegionToTemplateMappings];
        }
        
        if ([_supportedRegionIdentifiers containsObject:regionIdentifier]) {
            _formats = [self formatsFromTemplates:_templatesByRegionIdentifier[regionIdentifier]];
        } else {
            _formats = [self formatsFromTemplates:kTemplateGeneric];
        }
    }
    
    return self;
}


- (id)init
{
    return [self initWithRegionIdentifier:[NSLocale regionIdentifier]];
}


#pragma mark - Format or canonicalise phone number

- (NSString *)formatPhoneNumber:(NSString *)phoneNumber
{
    BOOL matchesFormat = NO;
    
    for (int i = 0; !matchesFormat && (i < [_formats count]); i++) {
        matchesFormat = [self matchPhoneNumber:phoneNumber toFormat:_formats[i]];
    }
    
    if (!matchesFormat && [phoneNumber hasPrefix:kTokenPlus]) {
        [self matchInternationalPhoneNumber:phoneNumber];
    }
    
    if (!_formattedPhoneNumber) {
        _formattedPhoneNumber = [self flattenPhoneNumber:phoneNumber];
    }
    
    return _formattedPhoneNumber;
}


- (NSString *)canonicalisePhoneNumber:(NSString *)phoneNumber
{
    [self formatPhoneNumber:phoneNumber];
    
    return [_formattedPhoneNumber substringFromIndex:_canonicalOffset];
}

@end