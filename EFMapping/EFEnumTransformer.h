//
//  EFEnumTransformer.h
//  EFDataMappingKit
//
//  Created by Johan Kool on 2/6/2014.
//  Copyright (c) 2014 Egeniq. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  A transformer to simplify mapping between strings and enum values
 */
@interface EFEnumTransformer : NSValueTransformer

/**
 *  Convenience method for creating a transformer to map type strings to enum values
 *
 *  For the enum mapping dictionary the keys should be the values from your enum wrapped in a NSNumber and the objects should be corresponding strings.
 *
 *  @param enumMapping The enum mapping dictionary
 *
 *  @return An enum transformer
 */
+ (instancetype)transformerWithEnumMapping:(NSDictionary *)enumMapping;

/**
 *  Creates a transformer to map type strings to enum values
 *
 *  For the enum mapping dictionary the keys should be the values from your enum wrapped in a NSNumber and the objects should be corresponding strings.
 *
 *  @param enumMapping The enum mapping dictionary
 *
 *  @return An enum transformer
 */
- (instancetype)initWithEnumMapping:(NSDictionary *)enumMapping;

/**
 *  The enum mapping dictionary
 */
@property (nonatomic, strong) NSDictionary *enumMapping;

@end
