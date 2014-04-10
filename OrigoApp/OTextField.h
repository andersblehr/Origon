//
//  OTextField.h
//  OrigoApp
//
//  Created by Anders Blehr on 17.10.12.
//  Copyright (c) 2012 Rhelba Source. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const kBorderWidth;
extern CGFloat const kBorderWidthNonRetina;

@interface OTextField : UITextField<OTextInput> {
@private
    id<OTableViewInputDelegate> _inputDelegate;
}

- (instancetype)initWithKey:(NSString *)key delegate:(id)delegate;

@end
