//
//  EFMapping.m
//  MappingKit
//
//  Created by Johan Kool on 23/4/2014.
//  Copyright (c) 2014 Egeniq. All rights reserved.
//

#import "EFMapping.h"

@implementation EFMapping

+ (instancetype)mappingForType:(MappingType)type externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey internalClass:(Class)internalClass collectionClass:(Class)collectionClass formatter:(NSFormatter *)formatter transformer:(NSValueTransformer *)transformer transformationBlock:(EFMappingTransformationBlock)transformationBlock  {
    return [self mappingForType:MappingTypeId externalKey:externalKey internalKey:internalKey internalClass:internalClass collectionClass:collectionClass formatter:formatter transformer:transformer transformationBlock:transformationBlock requires:nil];
}

+ (instancetype)mappingForType:(MappingType)type externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey internalClass:(Class)internalClass collectionClass:(Class)collectionClass formatter:(NSFormatter *)formatter transformer:(NSValueTransformer *)transformer transformationBlock:(EFMappingTransformationBlock)transformationBlock requires:(id <EFRequires>)requires {
    NSParameterAssert(externalKey);
    NSParameterAssert(internalKey);
    EFMapping *mapping = [[[self class] alloc] init];
    mapping.type = type;
    mapping.externalKey = externalKey;
    mapping.internalKey = internalKey;
    mapping.collectionClass = collectionClass;
    mapping.internalClass = internalClass;
    mapping.formatter = formatter;
    mapping.transformer = transformer;
    mapping.transformationBlock = transformationBlock;
    mapping.requires = requires;
    return mapping;
}

#pragma mark - Number (incl. BOOL, integer, floats etc.)
+ (instancetype)mappingForNumberWithKey:(NSString *)key {
    return [self mappingForType:MappingTypeId externalKey:key internalKey:key internalClass:[NSNumber class] collectionClass:Nil formatter:nil transformer:nil transformationBlock:nil];
}

+ (instancetype)mappingForNumberWithExternalKey:(NSString *)externalKey internalKey:(NSString *)internalKey {
    return [self mappingForType:MappingTypeId externalKey:externalKey internalKey:internalKey internalClass:[NSNumber class] collectionClass:Nil formatter:nil transformer:nil transformationBlock:nil];
}

+ (instancetype)mappingForNumberWithExternalKey:(NSString *)externalKey internalKey:(NSString *)internalKey formatter:(NSFormatter *)formatter {
    return [self mappingForType:MappingTypeId externalKey:externalKey internalKey:internalKey internalClass:[NSNumber class] collectionClass:Nil formatter:formatter transformer:nil transformationBlock:nil];
}

+ (instancetype)mappingForNumberWithExternalKey:(NSString *)externalKey internalKey:(NSString *)internalKey transformer:(NSValueTransformer *)transformer {
    return [self mappingForType:MappingTypeId externalKey:externalKey internalKey:internalKey internalClass:[NSNumber class] collectionClass:Nil formatter:nil transformer:transformer transformationBlock:nil];
}

+ (instancetype)mappingForNumberWithExternalKey:(NSString *)externalKey internalKey:(NSString *)internalKey transformationBlock:(EFMappingTransformationBlock)transformationBlock {
    return [self mappingForType:MappingTypeId externalKey:externalKey internalKey:internalKey internalClass:[NSNumber class] collectionClass:Nil formatter:nil transformer:nil transformationBlock:transformationBlock];
}

#pragma mark - NSString
+ (instancetype)mappingForStringWithKey:(NSString *)key {
    return [self mappingForType:MappingTypeId externalKey:key internalKey:key internalClass:[NSString class] collectionClass:Nil formatter:nil transformer:nil transformationBlock:nil];
}

+ (instancetype)mappingForStringWithExternalKey:(NSString *)externalKey internalKey:(NSString *)internalKey {
    return [self mappingForType:MappingTypeId externalKey:externalKey internalKey:internalKey internalClass:[NSString class] collectionClass:Nil formatter:nil transformer:nil transformationBlock:nil];
}

+ (instancetype)mappingForStringWithExternalKey:(NSString *)externalKey internalKey:(NSString *)internalKey formatter:(NSFormatter *)formatter {
    return [self mappingForType:MappingTypeId externalKey:externalKey internalKey:internalKey internalClass:[NSString class] collectionClass:Nil formatter:formatter transformer:nil transformationBlock:nil];
}

+ (instancetype)mappingForStringWithExternalKey:(NSString *)externalKey internalKey:(NSString *)internalKey transformer:(NSValueTransformer *)transformer {
    return [self mappingForType:MappingTypeId externalKey:externalKey internalKey:internalKey internalClass:[NSString class] collectionClass:Nil formatter:nil transformer:transformer transformationBlock:nil];
}

+ (instancetype)mappingForStringWithExternalKey:(NSString *)externalKey internalKey:(NSString *)internalKey transformationBlock:(EFMappingTransformationBlock)transformationBlock {
    return [self mappingForType:MappingTypeId externalKey:externalKey internalKey:internalKey internalClass:[NSString class] collectionClass:Nil formatter:nil transformer:nil transformationBlock:transformationBlock];
}

#pragma mark - Classes
+ (instancetype)mappingForClass:(Class)internalClass key:(NSString *)key {
    return [self mappingForType:MappingTypeId externalKey:key internalKey:key internalClass:internalClass collectionClass:Nil formatter:nil transformer:nil transformationBlock:nil];
}

+ (instancetype)mappingForClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey {
    return [self mappingForType:MappingTypeId externalKey:externalKey internalKey:internalKey internalClass:internalClass collectionClass:Nil formatter:nil transformer:nil transformationBlock:nil];
}

+ (instancetype)mappingForClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey requires:(id <EFRequires>)requirements {
    return [self mappingForType:MappingTypeId externalKey:externalKey internalKey:internalKey internalClass:internalClass collectionClass:Nil formatter:nil transformer:nil transformationBlock:nil requires:requirements];
}


+ (instancetype)mappingForClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey formatter:(NSFormatter *)formatter {
    return [self mappingForType:MappingTypeId externalKey:externalKey internalKey:internalKey internalClass:internalClass collectionClass:Nil formatter:formatter transformer:nil transformationBlock:nil];
}

+ (instancetype)mappingForClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey transformer:(NSValueTransformer *)transformer {
    return [self mappingForType:MappingTypeId externalKey:externalKey internalKey:internalKey internalClass:internalClass collectionClass:Nil formatter:nil transformer:transformer transformationBlock:nil];
}

+ (instancetype)mappingForClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey transformationBlock:(EFMappingTransformationBlock)transformationBlock {
    return [self mappingForType:MappingTypeId externalKey:externalKey internalKey:internalKey internalClass:internalClass collectionClass:Nil formatter:nil transformer:nil transformationBlock:transformationBlock];
}

#pragma mark - NSArray of classes
+ (instancetype)mappingForArrayOfClass:(Class)internalClass key:(NSString *)key {
    return [self mappingForType:MappingTypeCollection externalKey:key internalKey:key internalClass:internalClass collectionClass:[NSArray class] formatter:nil transformer:nil transformationBlock:nil];
}

+ (instancetype)mappingForArrayOfClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey {
    return [self mappingForType:MappingTypeCollection externalKey:externalKey internalKey:internalKey internalClass:internalClass collectionClass:[NSArray class] formatter:nil transformer:nil transformationBlock:nil];
}

+ (instancetype)mappingForArrayOfClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey formatter:(NSFormatter *)formatter {
    return [self mappingForType:MappingTypeCollection externalKey:externalKey internalKey:internalKey internalClass:internalClass collectionClass:[NSArray class] formatter:formatter transformer:nil transformationBlock:nil];
}

+ (instancetype)mappingForArrayOfClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey transformer:(NSValueTransformer *)transformer {
    return [self mappingForType:MappingTypeCollection externalKey:externalKey internalKey:internalKey internalClass:internalClass collectionClass:[NSArray class] formatter:nil transformer:transformer transformationBlock:nil];
}

+ (instancetype)mappingForArrayOfClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey transformationBlock:(EFMappingTransformationBlock)transformationBlock {
    return [self mappingForType:MappingTypeCollection externalKey:externalKey internalKey:internalKey internalClass:internalClass collectionClass:[NSArray class] formatter:nil transformer:nil transformationBlock:transformationBlock];
}

#pragma mark - NSDictionary of classes
+ (instancetype)mappingForDictionaryOfClass:(Class)internalClass key:(NSString *)key {
    return [self mappingForType:MappingTypeCollection externalKey:key internalKey:key internalClass:internalClass collectionClass:[NSDictionary class] formatter:nil transformer:nil transformationBlock:nil];
}

+ (instancetype)mappingForDictionaryOfClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey {
    return [self mappingForType:MappingTypeCollection externalKey:externalKey internalKey:internalKey internalClass:internalClass collectionClass:[NSDictionary class] formatter:nil transformer:nil transformationBlock:nil];
}

+ (instancetype)mappingForDictionaryOfClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey formatter:(NSFormatter *)formatter {
    return [self mappingForType:MappingTypeCollection externalKey:externalKey internalKey:internalKey internalClass:internalClass collectionClass:[NSDictionary class] formatter:formatter transformer:nil transformationBlock:nil];
}

+ (instancetype)mappingForDictionaryOfClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey transformer:(NSValueTransformer *)transformer {
    return [self mappingForType:MappingTypeCollection externalKey:externalKey internalKey:internalKey internalClass:internalClass collectionClass:[NSDictionary class] formatter:nil transformer:transformer transformationBlock:nil];
}

+ (instancetype)mappingForDictionaryOfClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey transformationBlock:(EFMappingTransformationBlock)transformationBlock {
    return [self mappingForType:MappingTypeCollection externalKey:externalKey internalKey:internalKey internalClass:internalClass collectionClass:[NSDictionary class] formatter:nil transformer:nil transformationBlock:transformationBlock];
}

#pragma mark - Generic collection of classes
+ (instancetype)mappingForCollection:(Class)collectionClass ofClass:(Class)internalClass key:(NSString *)key {
    return [self mappingForType:MappingTypeCollection externalKey:key internalKey:key internalClass:internalClass collectionClass:collectionClass formatter:nil transformer:nil transformationBlock:nil];
}

+ (instancetype)mappingForCollection:(Class)collectionClass ofClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey {
    return [self mappingForType:MappingTypeCollection externalKey:externalKey internalKey:internalKey internalClass:internalClass collectionClass:collectionClass formatter:nil transformer:nil transformationBlock:nil];
}

+ (instancetype)mappingForCollection:(Class)collectionClass ofClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey formatter:(NSFormatter *)formatter {
    return [self mappingForType:MappingTypeCollection externalKey:externalKey internalKey:internalKey internalClass:internalClass collectionClass:collectionClass formatter:formatter transformer:nil transformationBlock:nil];
}

+ (instancetype)mappingForCollection:(Class)collectionClass ofClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey transformer:(NSValueTransformer *)transformer {
    return [self mappingForType:MappingTypeCollection externalKey:externalKey internalKey:internalKey internalClass:internalClass collectionClass:collectionClass formatter:nil transformer:transformer transformationBlock:nil];
}

+ (instancetype)mappingForCollection:(Class)collectionClass ofClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey transformationBlock:(EFMappingTransformationBlock)transformationBlock {
    return [self mappingForType:MappingTypeCollection externalKey:externalKey internalKey:internalKey internalClass:internalClass collectionClass:collectionClass formatter:nil transformer:nil transformationBlock:transformationBlock];
}

@end
