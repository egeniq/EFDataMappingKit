//
//  EFMapping.h
//  EFDataMappingKit
//
//  Created by Johan Kool on 23/4/2014.
//  Copyright (c) 2014 Egeniq. All rights reserved.
//

#import "EFRequires.h"

/**
 *  Block used to transform a value received from an external source
 *
 *  If for some reason the transformation cannot be performed, return a `NSError` instance indicating the reason. To create a dictionary representation you may be asked to perform the transformation in reverse. This is done via the reverse flag.
 *
 *  @param value   Value from external source
 *  @param reverse Perform the transformation in reverse
 *
 *  @return Transformed value, or `NSError` instance if transformation failed
 */
typedef id (^EFMappingTransformationBlock)(id value, BOOL reverse);

@class EFMapping;

/**
 *  Block in which you apply to properties to be used for a mapping
 *
 *  @param mapping `EFMapping` instance to setup
 */
typedef void (^EFMappingFactoryBlock)(EFMapping *mapping);

/**
 *  `EFMapping` instances define how data from an external source, such as JSON, needs to be applied to instances.
 */
@interface EFMapping : NSObject

/** @name Factories */
/**
 *  Factory method for creating an `EFMapping` instance
 *
 *  @param factoryBlock Block in which you apply to properties to be used for this mapping
 *
 *  @return `EFMapping` instance
 */
+ (instancetype)mapping:(EFMappingFactoryBlock)factoryBlock;

/**
 *  Factory method for creating an `EFMapping` instance for an array
 *
 *  @param factoryBlock Block in which you apply to properties to be used for this mapping
 *
 *  @return `EFMapping` instance
 */
+ (instancetype)mappingForArray:(EFMappingFactoryBlock)factoryBlock;

/**
 *  Factory method for creating an `EFMapping` instance for a dictionary
 *
 *  @param factoryBlock Block in which you apply to properties to be used for this mapping
 *
 *  @return `EFMapping` instance
 */
+ (instancetype)mappingForDictionary:(EFMappingFactoryBlock)factoryBlock;

/** @name Properties */
/**
 *  Key used in the external source
 */
@property (nonatomic, copy) NSString *externalKey;

/**
 *  Key used in local entities
 */
@property (nonatomic, copy) NSString *internalKey;

/**
 *  Convenience method to set both the externalKey and internalKey properties to the same value
 *
 *  @param key Key to set on externalKey and internalKey
 */
- (void)setKey:(NSString *)key;

/**
 *  Class of value in local entity
 */
@property (nonatomic, assign) Class internalClass;

/**
 *  Formatter applied to value before setting it on local entity
 */
@property (nonatomic, strong) NSFormatter *formatter;

/**
 *  Value transformer applied to value before setting it on local entity
 */
@property (nonatomic, strong) NSValueTransformer *transformer;

/**
 *  Block applied to value before setting it on local entity
 */
@property (nonatomic, copy) EFMappingTransformationBlock transformationBlock;

/**
 *  An `EFRequires` instance, or an `NSArray` of `EFRequires` instances, for which the incoming value should pass
 */
@property (nonatomic, strong) id <EFRequires> requires;

#pragma mark - Number (incl. BOOL, integer, floats etc.)
/** @name Number (incl. BOOL, integer, floats etc.) */
/**
 *  Convenience method for creating a number mapping
 *
 *  @param key Key to set on externalKey and internalKey
 *
 *  @return `EFMapping` instance
 */
+ (instancetype)mappingForNumberWithKey:(NSString *)key;

/**
 *  Convenience method for creating a number mapping
 *
 *  @param externalKey Key used in the external source
 *  @param internalKey Key used in local entities
 *
 *  @return `EFMapping` instance
 */
+ (instancetype)mappingForNumberWithExternalKey:(NSString *)externalKey internalKey:(NSString *)internalKey;

#pragma mark - NSString
/** @name NSString */
/**
 *  Convenience method for creating a string mapping
 *
 *  @param key Key to set on externalKey and internalKey
 *
 *  @return `EFMapping` instance
 */
+ (instancetype)mappingForStringWithKey:(NSString *)key;

/**
 *  Convenience method for creating a string mapping
 *
 *  @param externalKey Key used in the external source
 *  @param internalKey Key used in local entities
 *
 *  @return `EFMapping` instance
 */
+ (instancetype)mappingForStringWithExternalKey:(NSString *)externalKey internalKey:(NSString *)internalKey;

#pragma mark - Classes
/** @name Classes */
/**
 *  Convenience method for creating a class mapping
 *
 *  @param internalClass Class of value in local entity
 *  @param key           Key to set on externalKey and internalKey
 *
 *  @return `EFMapping` instance
 */
+ (instancetype)mappingForClass:(Class)internalClass key:(NSString *)key;

/**
 *  Convenience method for creating a class mapping
 *
 *  @param internalClass Class of value in local entity
 *  @param externalKey   Key used in the external source
 *  @param internalKey   Key used in local entities
 *
 *  @return `EFMapping` instance
 */
+ (instancetype)mappingForClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey;

#pragma mark - NSArray of classes
/** @name NSArray of classes */
/**
 *  Convenience method for creating a class mapping for an array
 *
 *  @param internalClass Class of value in local entity
 *  @param key           Key to set on externalKey and internalKey
 *
 *  @return `EFMapping` instance
 */
+ (instancetype)mappingForArrayOfClass:(Class)internalClass key:(NSString *)key;

/**
 *  Convenience method for creating a class mapping for an array
 *
 *  @param internalClass Class of value in local entity
 *  @param externalKey   Key used in the external source
 *  @param internalKey   Key used in local entities
 *
 *  @return `EFMapping` instance
 */
+ (instancetype)mappingForArrayOfClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey;

@end
