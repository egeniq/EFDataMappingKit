//
//  EFMapping-Private.h
//  EFDataMappingKit
//
//  Created by Johan Kool on 25/4/2014.
//  Copyright (c) 2014 Egeniq. All rights reserved.
//

#import "EFMapping.h"

typedef NS_ENUM(NSUInteger, EFMappingType) {
    EFMappingTypeId,
    EFMappingTypeCollection
};

@interface EFMapping ()

@property (nonatomic, assign) EFMappingType type;
@property (nonatomic, assign) Class collectionClass;

@end
