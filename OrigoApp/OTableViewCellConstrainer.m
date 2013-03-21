//
//  OTableViewCellConstrainer.m
//  OrigoApp
//
//  Created by Anders Blehr on 18.11.12.
//  Copyright (c) 2012 Rhelba Creations. All rights reserved.
//

#import "OTableViewCellConstrainer.h"

#import "NSDate+OrigoExtensions.h"
#import "UIFont+OrigoExtensions.h"

#import "OState.h"
#import "OTableViewCell.h"
#import "OTableViewCellBlueprint.h"
#import "OTextView.h"

#import "OReplicatedEntity.h"

static NSString * const kVConstraintsInitial          = @"V:|-10-";
static NSString * const kVConstraintsInitialWithTitle = @"V:|-44-";

static NSString * const kVConstraintsElementTopmost   = @"[%@(22)]";
static NSString * const kVConstraintsElement          = @"-%.f-[%@(22)]";
static NSString * const kHConstraintsLabel            = @"H:|-25-[%@]-25-|";
static NSString * const kHConstraintsTextField        = @"H:|-55-[%@]-55-|";

static NSString * const kVConstraintsTitleBanner      = @"V:|-(-1)-[titleBanner(39)]";
static NSString * const kHConstraintsTitleBanner      = @"H:|-(-1)-[titleBanner]-(-1)-|";
static NSString * const kVConstraintsTitle            = @"[%@(24)]-10-";
static NSString * const kHConstraintsTitle            = @"H:|-6-[%@]-6-|";
static NSString * const kHConstraintsTitleWithPhoto   = @"H:|-6-[%@]-6-[photoFrame(55)]-10-|";
static NSString * const kVConstraintsPhoto            = @"V:|-10-[photoFrame(55)]";
static NSString * const kVConstraintsPhotoPrompt      = @"V:|-3-[photoPrompt]-3-|";
static NSString * const kHConstraintsPhotoPrompt      = @"H:|-3-[photoPrompt]-3-|";

static NSString * const kVConstraintsLabel            = @"-%.f-[%@(22)]";
static NSString * const kVConstraintsTextField        = @"[%@(%.f)]";

static NSString * const kHConstraintsWithPhoto        = @"H:|-10-[%@(>=55)]-3-[%@]-6-[photoFrame]-10-|";
static NSString * const kHConstraints                 = @"H:|-10-[%@(>=55)]-3-[%@]-6-|";


@implementation OTableViewCellConstrainer

#pragma mark - Auxiliary methods

- (BOOL)elementsAreVisibleForKey:(NSString *)key
{
    BOOL elementsAreVisible = YES;
    
    if (_cell.entity) {
        NSArray *entityAttributeKeys = [[[_cell.entity entity] attributesByName] allKeys];
        
        if ([entityAttributeKeys containsObject:key]) {
            id value = [_cell.entity valueForKey:key];
            
            if (value && [value isKindOfClass:NSString.class]) {
                elementsAreVisible = ([value length] > 0);
            } else if (!value) {
                elementsAreVisible = NO;
            }
            
            elementsAreVisible = elementsAreVisible || _cell.localState.actionIsInput;
        }
    }
    
    return elementsAreVisible;
}


- (void)configureElementsIfNeededForKey:(NSString *)key
{
    id label = [_cell labelForKey:key];
    id textField = [_cell textFieldForKey:key];
    
    if ([self elementsAreVisibleForKey:key]) {
        if (label && [label isHidden]) {
            [label setHidden:NO];
        }
        
        if (textField && [textField isHidden]) {
            [textField setHidden:NO];
            
            id value = [_cell.entity valueForKey:key];
            
            if (value && (![[textField text] length])) {
                if ([value isKindOfClass:NSString.class]) {
                    [textField setText:value];
                } else if ([value isKindOfClass:NSDate.class]) {
                    [textField setText:[value localisedDateString]];
                }
            }
        }
    } else {
        if (label && ![label isHidden]) {
            [label setHidden:YES];
            [label setFrame:CGRectZero];
        }
        
        if (textField && ![textField isHidden]) {
            [textField setHidden:YES];
            [textField setFrame:CGRectZero];
        }
    }
}


#pragma mark - Generating visual constraints strings

- (NSArray *)titleConstraints
{
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    if (_blueprint.titleKey) {
        NSString *titleName = [_blueprint.titleKey stringByAppendingString:kViewKeySuffixTextField];
        
        [self configureElementsIfNeededForKey:_blueprint.titleKey];
        
        [constraints addObject:kVConstraintsTitleBanner];
        [constraints addObject:kHConstraintsTitleBanner];
        
        if (_blueprint.hasPhoto) {
            [constraints addObject:[NSString stringWithFormat:kHConstraintsTitleWithPhoto, titleName]];
            [constraints addObject:kVConstraintsPhoto];
            [constraints addObject:kVConstraintsPhotoPrompt];
            [constraints addObject:kHConstraintsPhotoPrompt];
        } else {
            [constraints addObject:[NSString stringWithFormat:kHConstraintsTitle, titleName]];
        }
    }
    
    return constraints;
}


- (NSString *)labeledVerticalLabelConstraints
{
    NSString *constraints = _blueprint.titleKey ? kVConstraintsInitialWithTitle : kVConstraintsInitial;
    
    BOOL isTopmostLabel = YES;
    id precedingTextField = nil;
    
    for (NSString *key in _blueprint.detailKeys) {
        [self configureElementsIfNeededForKey:key];
        
        if ([self elementsAreVisibleForKey:key]) {
            NSString *constraint = nil;
            NSString *labelName = [key stringByAppendingString:kViewKeySuffixLabel];
            
            if (isTopmostLabel) {
                constraint = [NSString stringWithFormat:kVConstraintsElementTopmost, labelName];
                isTopmostLabel = NO;
            } else {
                CGFloat padding = 0.f;
                
                if (precedingTextField && [precedingTextField isKindOfClass:OTextView.class]) {
                    padding = [(OTextView *)precedingTextField height] - [UIFont detailFieldHeight];
                }
                
                constraint = [NSString stringWithFormat:kVConstraintsLabel, padding, labelName];
            }
            
            precedingTextField = [_cell textFieldForKey:key];
            constraints = [constraints stringByAppendingString:constraint];
        }
    }
    
    return constraints;
}


- (NSString *)labeledVerticalTextFieldConstraints
{
    NSString *constraints = kVConstraintsInitial;
    
    if (_blueprint.titleKey) {
        NSString *titleName = [_blueprint.titleKey stringByAppendingString:kViewKeySuffixTextField];
        NSString *constraint = [NSString stringWithFormat:kVConstraintsTitle, titleName];
        
        constraints = [constraints stringByAppendingString:constraint];
    }
    
    for (NSString *key in _blueprint.detailKeys) {
        [self configureElementsIfNeededForKey:key];
        
        if ([self elementsAreVisibleForKey:key]) {
            id textField = [_cell textFieldForKey:key];
            
            CGFloat textFieldHeight = [UIFont detailFieldHeight];
            
            if ([textField isKindOfClass:OTextView.class]) {
                textFieldHeight = [(OTextView *)textField height];
            }
            
            NSString *textFieldName = [key stringByAppendingString:kViewKeySuffixTextField];
            NSString *constraint = [NSString stringWithFormat:kVConstraintsTextField, textFieldName, textFieldHeight];
            
            constraints = [constraints stringByAppendingString:constraint];
        }
    }
    
    return constraints;
}


- (NSArray *)labeledHorizontalConstraints
{
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    NSInteger rowNumber = 0;
    
    for (NSString *key in _blueprint.detailKeys) {
        [self configureElementsIfNeededForKey:key];
        
        if ([self elementsAreVisibleForKey:key]) {
            NSString *labelName = [key stringByAppendingString:kViewKeySuffixLabel];
            NSString *textFieldName = [key stringByAppendingString:kViewKeySuffixTextField];
            NSString *constraint = nil;
            
            if (_blueprint.hasPhoto && (rowNumber++ < 2)) {
                constraint = [NSString stringWithFormat:kHConstraintsWithPhoto, labelName, textFieldName];
            } else {
                constraint = [NSString stringWithFormat:kHConstraints, labelName, textFieldName];
            }
            
            [constraints addObject:constraint];
        }
    }
    
    return constraints;
}


- (NSString *)centredVerticalConstraints
{
    NSString *constraints = kVConstraintsInitial;
    
    BOOL isTopmostElement = YES;
    BOOL isBelowLabel = NO;
    
    for (NSString *key in _blueprint.allKeys) {
        [self configureElementsIfNeededForKey:key];
        
        if ([self elementsAreVisibleForKey:key]) {
            NSString *constraint = nil;
            NSString *elementName = nil;
            
            if ([_cell labelForKey:key]) {
                elementName = [key stringByAppendingString:kViewKeySuffixLabel];
            } else if ([_cell textFieldForKey:key]) {
                elementName = [key stringByAppendingString:kViewKeySuffixTextField];
            }
            
            if (isTopmostElement) {
                constraint = [NSString stringWithFormat:kVConstraintsElementTopmost, elementName];
                isTopmostElement = NO;
            } else {
                CGFloat spacing = isBelowLabel ? kDefaultCellPadding / 3 : 1.f;
                constraint = [NSString stringWithFormat:kVConstraintsElement, spacing, elementName];
            }
            
            constraints = [constraints stringByAppendingString:constraint];
            isBelowLabel = [elementName hasSuffix:kViewKeySuffixLabel];
        }
    }
    
    return constraints;
}


- (NSArray *)centredHorizontalConstraints
{
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    for (NSString *key in _blueprint.allKeys) {
        [self configureElementsIfNeededForKey:key];
        
        if ([self elementsAreVisibleForKey:key]) {
            NSString *constraint = nil;
            
            if ([_cell labelForKey:key]) {
                NSString *elementName = [key stringByAppendingString:kViewKeySuffixLabel];
                constraint = [NSString stringWithFormat:kHConstraintsLabel, elementName];
            } else if ([_cell textFieldForKey:key]) {
                NSString *elementName = [key stringByAppendingString:kViewKeySuffixTextField];
                constraint = [NSString stringWithFormat:kHConstraintsTextField, elementName];
            }
            
            [constraints addObject:constraint];
        }
    }
    
    return constraints;
}


#pragma mark - Initialisation

- (id)initWithBlueprint:(OTableViewCellBlueprint *)blueprint cell:(OTableViewCell *)cell
{
    self = [super init];
    
    if (self) {
        _blueprint = blueprint;
        _cell = cell;
    }
    
    return self;
}


#pragma mark - Retrieving constraints

- (NSDictionary *)constraintsWithAlignmentOptions
{
    NSMutableDictionary *constraints = [[NSMutableDictionary alloc] init];
    
    if (_blueprint) {
        NSNumber *allTrailingOptions = [NSNumber numberWithInteger:NSLayoutFormatAlignAllTrailing];
        NSNumber *noAlignmentOptions = [NSNumber numberWithInteger:0];
        
        if (_blueprint.fieldsAreLabeled) {
            NSMutableArray *allTrailingConstraints = [[NSMutableArray alloc] init];
            [allTrailingConstraints addObject:[self labeledVerticalLabelConstraints]];
            
            NSMutableArray *nonAlignedConstraints = [[NSMutableArray alloc] init];
            [nonAlignedConstraints addObjectsFromArray:[self titleConstraints]];
            [nonAlignedConstraints addObject:[self labeledVerticalTextFieldConstraints]];
            [nonAlignedConstraints addObjectsFromArray:[self labeledHorizontalConstraints]];
            
            [constraints setObject:allTrailingConstraints forKey:allTrailingOptions];
            [constraints setObject:nonAlignedConstraints forKey:noAlignmentOptions];
        } else {
            NSMutableArray *nonAlignedConstraints = [[NSMutableArray alloc] init];
            [nonAlignedConstraints addObject:[self centredVerticalConstraints]];
            [nonAlignedConstraints addObjectsFromArray:[self centredHorizontalConstraints]];
            
            [constraints setObject:nonAlignedConstraints forKey:noAlignmentOptions];
        }
        
//        int i = 0;
//        for (NSNumber *alignmentOptions in [constraints allKeys]) {
//            NSArray *constraintsWithOptions = [constraints objectForKey:alignmentOptions];
//            
//            for (NSString *visualConstraints in constraintsWithOptions) {
//                OLogDebug(@"\nVisual constraint (%d): %@", i++, visualConstraints);
//            }
//        }
    }
    
    return constraints;
}

@end