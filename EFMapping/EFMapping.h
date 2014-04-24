//
//  EFMapping.h
//  MappingKit
//
//  Created by Johan Kool on 23/4/2014.
//  Copyright (c) 2014 Egeniq. All rights reserved.
//

#import "MappingKit.h"

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

/**
 *  Classes return an array of EFMapping instances to define how data from an external source, such as JSON, needs to be applied to its instances.
 */
@interface EFMapping : NSObject

#pragma mark - Number (incl. BOOL, integer, floats etc.)
+ (instancetype)mappingForNumberWithKey:(NSString *)key;
+ (instancetype)mappingForNumberWithExternalKey:(NSString *)externalKey internalKey:(NSString *)internalKey;
+ (instancetype)mappingForNumberWithExternalKey:(NSString *)externalKey internalKey:(NSString *)internalKey formatter:(NSFormatter *)formatter;
+ (instancetype)mappingForNumberWithExternalKey:(NSString *)externalKey internalKey:(NSString *)internalKey transformer:(NSValueTransformer *)transformer;
+ (instancetype)mappingForNumberWithExternalKey:(NSString *)externalKey internalKey:(NSString *)internalKey transformationBlock:(EFMappingTransformationBlock)transformationBlock;

#pragma mark - NSString
+ (instancetype)mappingForStringWithKey:(NSString *)key;
+ (instancetype)mappingForStringWithExternalKey:(NSString *)externalKey internalKey:(NSString *)internalKey;
+ (instancetype)mappingForStringWithExternalKey:(NSString *)externalKey internalKey:(NSString *)internalKey formatter:(NSFormatter *)formatter;
+ (instancetype)mappingForStringWithExternalKey:(NSString *)externalKey internalKey:(NSString *)internalKey transformer:(NSValueTransformer *)transformer;
+ (instancetype)mappingForStringWithExternalKey:(NSString *)externalKey internalKey:(NSString *)internalKey transformationBlock:(EFMappingTransformationBlock)transformationBlock;

#pragma mark - Classes
//+ (instancetype)mappingForClass:(Class)internalClass from:(NSString *)externalKey to:(NSString *)internalKey transforms:(id <EFTransforms>)transforms requires:(id <EFRequires>)requirements;

+ (instancetype)mappingForClass:(Class)internalClass key:(NSString *)key;
+ (instancetype)mappingForClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey;
+ (instancetype)mappingForClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey requires:(id <EFRequires>)requirements;
+ (instancetype)mappingForClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey formatter:(NSFormatter *)formatter;
+ (instancetype)mappingForClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey transformer:(NSValueTransformer *)transformer;
+ (instancetype)mappingForClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey transformationBlock:(EFMappingTransformationBlock)transformationBlock;

#pragma mark - NSArray of classes
+ (instancetype)mappingForArrayOfClass:(Class)internalClass key:(NSString *)key;
+ (instancetype)mappingForArrayOfClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey;
+ (instancetype)mappingForArrayOfClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey formatter:(NSFormatter *)formatter;
+ (instancetype)mappingForArrayOfClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey transformer:(NSValueTransformer *)transformer;
+ (instancetype)mappingForArrayOfClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey transformationBlock:(EFMappingTransformationBlock)transformationBlock;

#pragma mark - NSDictionary of classes
+ (instancetype)mappingForDictionaryOfClass:(Class)internalClass key:(NSString *)key;
+ (instancetype)mappingForDictionaryOfClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey;
+ (instancetype)mappingForDictionaryOfClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey formatter:(NSFormatter *)formatter;
+ (instancetype)mappingForDictionaryOfClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey transformer:(NSValueTransformer *)transformer;
+ (instancetype)mappingForDictionaryOfClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey transformationBlock:(EFMappingTransformationBlock)transformationBlock;

#pragma mark - Generic collection of classes
+ (instancetype)mappingForCollection:(Class)collectionClass ofClass:(Class)internalClass key:(NSString *)key;
+ (instancetype)mappingForCollection:(Class)collectionClass ofClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey;
+ (instancetype)mappingForCollection:(Class)collectionClass ofClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey formatter:(NSFormatter *)formatter;
+ (instancetype)mappingForCollection:(Class)collectionClass ofClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey transformer:(NSValueTransformer *)transformer;
+ (instancetype)mappingForCollection:(Class)collectionClass ofClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey transformationBlock:(EFMappingTransformationBlock)transformationBlock;

@end

typedef NS_ENUM(NSUInteger, MappingType) {
    MappingTypeId,
    MappingTypeCollection
};

@interface EFMapping ()

@property (nonatomic, assign) MappingType type;
@property (nonatomic, copy) NSString *externalKey;
@property (nonatomic, copy) NSString *internalKey;
@property (nonatomic, assign) Class collectionClass;
@property (nonatomic, assign) Class internalClass;

@property (nonatomic, strong) NSFormatter *formatter;
@property (nonatomic, strong) NSValueTransformer *transformer;
@property (nonatomic, copy) EFMappingTransformationBlock transformationBlock;

@property (nonatomic, strong) id <EFRequires> requires;

@end
