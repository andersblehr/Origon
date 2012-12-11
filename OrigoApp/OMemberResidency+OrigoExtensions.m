//
//  OMemberResidency+OrigoExtensions.m
//  OrigoApp
//
//  Created by Anders Blehr on 17.10.12.
//  Copyright (c) 2012 Rhelba Creations. All rights reserved.
//

#import "OMemberResidency+OrigoExtensions.h"

#import "NSManagedObjectContext+OrigoExtensions.h"

#import "OMeta.h"

#import "OMember.h"
#import "OOrigo.h"

#import "OReplicatedEntity+OrigoExtensions.h"


@implementation OMemberResidency (OrigoExtensions)


#pragma mark - OReplicateEntity (OReplicateEntityExtentions) overrides

- (BOOL)propertyIsTransient:(NSString *)property
{
    BOOL isTransient = [super propertyIsTransient:property];
    
    isTransient = isTransient || [property isEqualToString:@"resident"];
    isTransient = isTransient || [property isEqualToString:@"residence"];
    
    return isTransient;
}


- (void)internaliseRelationships
{
    [super internaliseRelationships];
    
    self.resident = self.member;
    self.residence = self.origo;
}

@end