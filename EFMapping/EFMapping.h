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
 *  If for some reason the transformation cannot be performed, return a NSError instance indicating the reason. To create a dictionary representation you may be asked to perform the transformation in reverse. This is done via the reverse flag.
 *
 *  @param id      Value from external source
 *  @param reverse Perform the transformation in reverse
 *
 *  @return Transformed value, or NSError instance if transformation failed
 */
typedef id (^EFMappingTransformationBlock)(id, BOOL reverse);

@class EFMapping;

typedef void (^EFMappingFactoryBlock)(EFMapping *);

/**
 *  EFMapping instances define how data from an external source, such as JSON, needs to be applied to instances.
 */
@interface EFMapping : NSObject

+ (instancetype)mapping:(EFMappingFactoryBlock)factoryBlock;
+ (instancetype)mappingForArray:(EFMappingFactoryBlock)factoryBlock;
+ (instancetype)mappingForDictionary:(EFMappingFactoryBlock)factoryBlock;

- (void)setKey:(NSString *)key;
@property (nonatomic, copy) NSString *externalKey;
@property (nonatomic, copy) NSString *internalKey;
@property (nonatomic, assign) Class internalClass;

@property (nonatomic, strong) NSFormatter *formatter;
@property (nonatomic, strong) NSValueTransformer *transformer;
@property (nonatomic, copy) EFMappingTransformationBlock transformationBlock;

@property (nonatomic, strong) id <EFRequires> requires;

#pragma mark - Number (incl. BOOL, integer, floats etc.)
+ (instancetype)mappingForNumberWithKey:(NSString *)key;
+ (instancetype)mappingForNumberWithExternalKey:(NSString *)externalKey internalKey:(NSString *)internalKey;

#pragma mark - NSString
+ (instancetype)mappingForStringWithKey:(NSString *)key;
+ (instancetype)mappingForStringWithExternalKey:(NSString *)externalKey internalKey:(NSString *)internalKey;

#pragma mark - Classes
+ (instancetype)mappingForClass:(Class)internalClass key:(NSString *)key;
+ (instancetype)mappingForClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey;

#pragma mark - NSArray of classes
+ (instancetype)mappingForArrayOfClass:(Class)internalClass key:(NSString *)key;
+ (instancetype)mappingForArrayOfClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey;

@end
