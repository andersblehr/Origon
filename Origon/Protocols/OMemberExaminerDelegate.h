//
//  OMemberExaminerDelegate.h
//  Origon
//
//  Created by Anders Blehr on 17.10.12.
//  Copyright (c) 2012 Rhelba Source. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OMemberExaminerDelegate <NSObject>

@required
- (void)examinerDidFinishExamination;
- (void)examinerDidCancelExamination;

@end
