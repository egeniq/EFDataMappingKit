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
 *  <#Description#>
 *
 *  @param mapping <#mapping description#>
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
 *  <#Description#>
 *
 *  @param factoryBlock Block in which you apply to properties to be used for this mapping
 *
 *  @return `EFMapping` instance
 */
+ (instancetype)mappingForArray:(EFMappingFactoryBlock)factoryBlock;

/**
 *  <#Description#>
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
 *  <#Description#>
 */
@property (nonatomic, assign) Class internalClass;

/**
 *  <#Description#>
 */
@property (nonatomic, strong) NSFormatter *formatter;

/**
 *  <#Description#>
 */
@property (nonatomic, strong) NSValueTransformer *transformer;

/**
 *  <#Description#>
 */
@property (nonatomic, copy) EFMappingTransformationBlock transformationBlock;

/**
 *  An `EFRequires` instance, or an `NSArray` of `EFRequires` instances, for which the incoming value should pass
 */
@property (nonatomic, strong) id <EFRequires> requires;

#pragma mark - Number (incl. BOOL, integer, floats etc.)
/** @name Number (incl. BOOL, integer, floats etc.) */
/**
 *  <#Description#>
 *
 *  @param key <#key description#>
 *
 *  @return `EFMapping` instance
 */
+ (instancetype)mappingForNumberWithKey:(NSString *)key;

/**
 *  <#Description#>
 *
 *  @param externalKey <#externalKey description#>
 *  @param internalKey <#internalKey description#>
 *
 *  @return `EFMapping` instance
 */
+ (instancetype)mappingForNumberWithExternalKey:(NSString *)externalKey internalKey:(NSString *)internalKey;

#pragma mark - NSString
/** @name NSString */
/**
 *  <#Description#>
 *
 *  @param key <#key description#>
 *
 *  @return `EFMapping` instance
 */
+ (instancetype)mappingForStringWithKey:(NSString *)key;

/**
 *  <#Description#>
 *
 *  @param externalKey <#externalKey description#>
 *  @param internalKey <#internalKey description#>
 *
 *  @return `EFMapping` instance
 */
+ (instancetype)mappingForStringWithExternalKey:(NSString *)externalKey internalKey:(NSString *)internalKey;

#pragma mark - Classes
/** @name Classes */
/**
 *  <#Description#>
 *
 *  @param internalClass <#internalClass description#>
 *  @param key           <#key description#>
 *
 *  @return `EFMapping` instance
 */
+ (instancetype)mappingForClass:(Class)internalClass key:(NSString *)key;

/**
 *  <#Description#>
 *
 *  @param internalClass <#internalClass description#>
 *  @param externalKey   <#externalKey description#>
 *  @param internalKey   <#internalKey description#>
 *
 *  @return `EFMapping` instance
 */
+ (instancetype)mappingForClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey;

#pragma mark - NSArray of classes
/** @name NSArray of classes */
/**
 *  <#Description#>
 *
 *  @param internalClass <#internalClass description#>
 *  @param key           <#key description#>
 *
 *  @return `EFMapping` instance
 */
+ (instancetype)mappingForArrayOfClass:(Class)internalClass key:(NSString *)key;

/**
 *  <#Description#>
 *
 *  @param internalClass <#internalClass description#>
 *  @param externalKey   <#externalKey description#>
 *  @param internalKey   <#internalKey description#>
 *
 *  @return `EFMapping` instance
 */
+ (instancetype)mappingForArrayOfClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey;

@end
