//
//  NSJSONSerialization+OrigonAdditions.h
//  Origon
//
//  Created by Anders Blehr on 17.10.12.
//  Copyright (c) 2012 Rhelba Source. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSJSONSerialization (OrigonAdditions)

+ (NSData *)serialise:(id)object;
+ (id)deserialise:(NSData *)JSONData;

@end
