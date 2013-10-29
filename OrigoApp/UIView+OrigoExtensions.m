//
//  UIView+OrigoExtensions.m
//  OrigoApp
//
//  Created by Anders Blehr on 17.10.12.
//  Copyright (c) 2012 Rhelba Creations. All rights reserved.
//

#import "UIView+OrigoExtensions.h"

static CGFloat const kCellShadowRadius = 1.f;
static CGFloat const kCellShadowOffset = 0.f;
static CGFloat const kFieldShadowRadius = 3.f;
static CGFloat const kFieldShadowOffset = 3.f;
static CGFloat const kFieldShadowHeightShrinkage = 1.f;
static CGFloat const kImageShadowRadius = 1.f;
static CGFloat const kImageShadowOffset = 1.5f;

static NSString * const kKeyPathShadowPath = @"shadowPath";


@implementation UIView (OrigoExtensions)

#pragma mark - Auxiliary methods

- (UIBezierPath *)shadowPathForTextField
{
    CGFloat fieldShadowOriginY = self.bounds.origin.y + kFieldShadowOffset;
    CGFloat fieldShadowHeight = self.bounds.size.height - kFieldShadowHeightShrinkage;
    
    return [UIBezierPath bezierPathWithRect:CGRectMake(self.bounds.origin.x, fieldShadowOriginY, self.bounds.size.width, fieldShadowHeight)];
}


- (void)addShadowWithPath:(UIBezierPath *)path colour:(UIColor *)colour radius:(CGFloat)radius offset:(CGFloat)offset
{
    self.layer.shadowPath = path.CGPath;
    self.layer.shadowColor = colour.CGColor;
    self.layer.shadowOpacity = 1.f;
    self.layer.shadowRadius = radius;
    self.layer.shadowOffset = CGSizeMake(0.f, offset);
    
    self.layer.masksToBounds = NO;
}


#pragma mark - Shadows

- (void)addSeparatorsForTableViewCell
{
    [self addShadowWithPath:[UIBezierPath bezierPathWithRect:self.bounds] colour:[UIColor tableViewSeparatorColour] radius:kCellShadowRadius offset:kCellShadowOffset];
}


- (void)addDropShadowForPhotoFrame
{
    [self addShadowWithPath:[UIBezierPath bezierPathWithRect:CGRectMake(0.f, 0.f, kPhotoFrameWidth, kPhotoFrameWidth)] colour:[UIColor darkGrayColor] radius:kImageShadowRadius offset:kImageShadowOffset];
}


- (void)redrawDropShadow
{
    CGPathRef redrawnShadowPath;
    
    if ([self isKindOfClass:UITextField.class] || [self isKindOfClass:UITextView.class]) {
        redrawnShadowPath = [self shadowPathForTextField].CGPath;
    } else {
        redrawnShadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    }
    
    CABasicAnimation *redrawAnimation = [CABasicAnimation animationWithKeyPath:kKeyPathShadowPath];
    redrawAnimation.duration = kCellAnimationDuration;
    redrawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    redrawAnimation.fromValue = (__bridge id)self.layer.shadowPath;
    redrawAnimation.toValue = (__bridge id)redrawnShadowPath;
    
    [self.layer addAnimation:redrawAnimation forKey:nil];
    self.layer.shadowPath = redrawnShadowPath;
}

@end
