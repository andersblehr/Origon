//
//  NSString+OrigonAdditions.m
//  Origon
//
//  Created by Anders Blehr on 17.10.12.
//  Copyright (c) 2012 Rhelba Source. All rights reserved.
//

#import "NSString+OrigonAdditions.h"

NSString * const kCharacters0_9 = @"0123456789";

NSString * const kSeparatorColon = @":";
NSString * const kSeparatorComma = @", ";
NSString * const kSeparatorHash = @"#";
NSString * const kSeparatorHat = @"^";
NSString * const kSeparatorNewline = @"\n";
NSString * const kSeparatorParagraph = @"\n\n";
NSString * const kSeparatorSpace = @" ";
NSString * const kSeparatorTilde = @"~";

NSString * const kSeparatorList = @";";
NSString * const kSeparatorMapping = @":";
NSString * const kSeparatorSegments = @"|";
NSString * const kSeparatorAlternates = @"|";

static CGFloat const kMatchingEditDistancePercentage = 0.4f;


@implementation NSString (OrigonAdditions)

#pragma mark - Auxiliary methods

- (NSInteger)levenshteinDistanceToString:(NSString *)string
{
    // Borrowed from Rosetta Code: http://rosettacode.org/wiki/Levenshtein_distance#Objective-C
    
    NSInteger sl = [self length];
    NSInteger tl = [string length];
    NSInteger *d = calloc(sizeof(*d), (sl+1) * (tl+1));
    
#define d(i, j) d[((j) * sl) + (i)]
    for (NSInteger i = 0; i <= sl; i++) {
        d(i, 0) = i;
    }
    for (NSInteger j = 0; j <= tl; j++) {
        d(0, j) = j;
    }
    for (NSInteger j = 1; j <= tl; j++) {
        for (NSInteger i = 1; i <= sl; i++) {
            if ([self characterAtIndex:i-1] == [string characterAtIndex:j-1]) {
                d(i, j) = d(i-1, j-1);
            } else {
                d(i, j) = MIN(d(i-1, j), MIN(d(i, j-1), d(i-1, j-1))) + 1;
            }
        }
    }
    
    NSInteger r = d(sl, tl);
#undef d
    
    free(d);
    
    return r;
}


#pragma mark - Convenience methods

- (BOOL)hasValue
{
    return [self length] > 0;
}


- (BOOL)containsString:(NSString *)string
{
    return [self rangeOfString:string].location != NSNotFound;
}


- (BOOL)containsCharacter:(const char)character
{
    return [self containsString:[NSString stringWithFormat:@"%c", character]];
}


- (BOOL)fuzzyMatches:(NSString *)other
{
    NSString *string1 = [[self stringByRemovingRedundantWhitespaceKeepNewlines:NO] lowercaseString];
    NSString *string2 = [[other stringByRemovingRedundantWhitespaceKeepNewlines:NO] lowercaseString];
    
    NSArray *words1 = [string1 componentsSeparatedByString:kSeparatorSpace];
    NSArray *words2 = [string2 componentsSeparatedByString:kSeparatorSpace];
    
    if (words1.count > words2.count) {
        id temp = words1;
        
        words1 = words2;
        words2 = temp;
    }
    
    NSMutableArray *matchableWords2 = [words2 mutableCopy];
    BOOL wordsMatch = YES;
    
    for (NSString *word1 in words1) {
        if (wordsMatch) {
            NSInteger shortestEditDistance = NSIntegerMax;
            NSString *matchedWord2 = nil;
            
            for (NSString *word2 in matchableWords2) {
                NSInteger editDistance = [word1 levenshteinDistanceToString:word2];
                
                if (editDistance < shortestEditDistance) {
                    shortestEditDistance = editDistance;
                    matchedWord2 = word2;
                }
            }
            
            wordsMatch = (CGFloat)shortestEditDistance / (CGFloat)[word1 length] <= kMatchingEditDistancePercentage;
            
            if (wordsMatch) {
                [matchableWords2 removeObject:matchedWord2];
            }
        }
    }
    
    return wordsMatch;
}


#pragma mark - Size and line count assessment

- (CGSize)sizeWithFont:(UIFont *)font maxWidth:(CGFloat)maxWidth
{
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:self attributes:@{NSFontAttributeName:font}];
    CGRect boundingRect = [attributedText boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    return CGSizeMake(boundingRect.size.width, boundingRect.size.height);
}


- (NSInteger)lineCountWithFont:(UIFont *)font maxWidth:(CGFloat)maxWidth
{
    return lrintf([self sizeWithFont:font maxWidth:maxWidth].height / font.lineHeight);
}


- (NSInteger)lineCount
{
    return [self lines].count;
}


- (NSArray *)lines
{
    return [self componentsSeparatedByString:kSeparatorNewline];
}


#pragma mark - Generic string operations

- (NSString *)stringByRemovingRedundantWhitespaceKeepNewlines:(BOOL)keepNewlines
{
    NSString *doubleSpace = [kSeparatorSpace stringByAppendingString:kSeparatorSpace];
    NSString *doubleNewline = [kSeparatorNewline stringByAppendingString:kSeparatorNewline];
    NSString *spaceNewline = [kSeparatorSpace stringByAppendingString:kSeparatorNewline];
    NSString *newlineSpace = [kSeparatorNewline stringByAppendingString:kSeparatorSpace];
    
    NSString *copy = [NSString stringWithString:self];
    NSString *copyBeforePass = nil;
    
    while (![copy isEqualToString:copyBeforePass]) {
        copyBeforePass = copy;
        
        copy = [copy stringByReplacingSubstring:doubleSpace withString:kSeparatorSpace];
        copy = [copy stringByReplacingSubstring:doubleNewline withString:kSeparatorNewline];
        
        if (keepNewlines) {
            copy = [copy stringByReplacingSubstring:spaceNewline withString:kSeparatorNewline];
            copy = [copy stringByReplacingSubstring:newlineSpace withString:kSeparatorNewline];
        } else {
            copy = [copy stringByReplacingSubstring:kSeparatorNewline withString:kSeparatorSpace];
        }
        
        if ([copy hasPrefix:kSeparatorSpace] || [copy hasPrefix:kSeparatorNewline]) {
            copy = [copy substringFromIndex:1];
        }
        
        if ([copy hasSuffix:kSeparatorSpace] || [copy hasSuffix:kSeparatorNewline]) {
            copy = [copy substringToIndex:[copy length] - 1];
        }
    }
    
    return copy;
}


- (NSString *)stringByReplacingSubstring:(NSString *)substring withString:(NSString *)string
{
    NSMutableString *reworkedString = [NSMutableString stringWithString:self];
    
    if (substring && string) {
        [reworkedString replaceOccurrencesOfString:substring withString:string options:NSLiteralSearch range:NSMakeRange(0, [self length])];
    }
    
    return reworkedString;
}


- (NSString *)stringByAppendingString:(NSString *)string separator:(NSString *)separator
{
    NSString *reworkedString = self;
    
    if ([self hasValue]) {
        reworkedString = [reworkedString stringByAppendingString:separator];
    }
    
    return [reworkedString stringByAppendingString:string];
}


- (NSString *)stringByAppendingCapitalisedString:(NSString *)string
{
    return [self stringByAppendingString:[string stringByCapitalisingFirstLetter]];
}


- (NSString *)stringByCapitalisingFirstLetter
{
    return [[[self substringWithRange:NSMakeRange(0, 1)] uppercaseString] stringByAppendingString:[self substringFromIndex:1]];
}


- (NSString *)stringByLowercasingFirstLetter
{
    return [[[self substringWithRange:NSMakeRange(0, 1)] lowercaseString] stringByAppendingString:[self substringFromIndex:1]];
}


- (NSString *)stringByConditionallyLowercasingFirstLetter
{
    BOOL shouldLowercase = [[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:[self characterAtIndex:1]];
    
    return shouldLowercase ? [self stringByLowercasingFirstLetter] : self;
}


- (NSString *)stringByLowercasingAndRemovingWhitespace
{
    NSString *flattenedString = @"";
    
    for (NSInteger i = 0; i < [self length]; i++) {
        NSString *character = [self substringWithRange:NSMakeRange(i, 1)];
        
        if (![character isEqualToString:kSeparatorSpace]) {
            flattenedString = [flattenedString stringByAppendingString:[character lowercaseString]];
        }
    }
    
    return flattenedString;
}


#pragma mark - Specialised string operations

- (NSString *)givenName
{
    return [self componentsSeparatedByString:kSeparatorSpace][0];
}


- (NSString *)localisedCountryName
{
    NSString *countryName = nil;
    
    if ([[NSLocale ISOCountryCodes] containsObject:self]) {
        countryName = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:self];
    }
    
    return countryName;
}

@end
