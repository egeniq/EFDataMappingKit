//
//  EFMapping.m
//  EFDataMappingKit
//
//  Created by Johan Kool on 23/4/2014.
//  Copyright (c) 2014 Egeniq. All rights reserved.
//

#import "EFMapping.h"

#import "EFMapping-Private.h"

@implementation EFMapping

+ (instancetype)mapping:(EFMappingFactoryBlock)factoryBlock {
    __block EFMapping *mapping = [[[self class] alloc] init];
    mapping.type = EFMappingTypeId;
    factoryBlock(mapping);
    return mapping;
}

+ (instancetype)mappingForArray:(EFMappingFactoryBlock)factoryBlock {
    __block EFMapping *mapping = [[[self class] alloc] init];
    mapping.type = EFMappingTypeCollection;
    mapping.collectionClass = [NSArray class];
    factoryBlock(mapping);
    return mapping;
}

+ (instancetype)mappingForDictionary:(EFMappingFactoryBlock)factoryBlock {
    __block EFMapping *mapping = [[[self class] alloc] init];
    mapping.type = EFMappingTypeCollection;
    mapping.collectionClass = [NSDictionary class];
    factoryBlock(mapping);
    return mapping;
}

+ (instancetype)mappingForType:(EFMappingType)type externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey internalClass:(Class)internalClass collectionClass:(Class)collectionClass formatter:(NSFormatter *)formatter transformer:(NSValueTransformer *)transformer transformationBlock:(EFMappingTransformationBlock)transformationBlock requires:(id <EFRequires>)requires {
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
    return [self mappingForType:EFMappingTypeId externalKey:key internalKey:key internalClass:[NSNumber class] collectionClass:Nil formatter:nil transformer:nil transformationBlock:nil requires:nil];
}

+ (instancetype)mappingForNumberWithExternalKey:(NSString *)externalKey internalKey:(NSString *)internalKey {
    return [self mappingForType:EFMappingTypeId externalKey:externalKey internalKey:internalKey internalClass:[NSNumber class] collectionClass:Nil formatter:nil transformer:nil transformationBlock:nil requires:nil];
}

#pragma mark - NSString
+ (instancetype)mappingForStringWithKey:(NSString *)key {
    return [self mappingForType:EFMappingTypeId externalKey:key internalKey:key internalClass:[NSString class] collectionClass:Nil formatter:nil transformer:nil transformationBlock:nil requires:nil];
}

+ (instancetype)mappingForStringWithExternalKey:(NSString *)externalKey internalKey:(NSString *)internalKey {
    return [self mappingForType:EFMappingTypeId externalKey:externalKey internalKey:internalKey internalClass:[NSString class] collectionClass:Nil formatter:nil transformer:nil transformationBlock:nil requires:nil];
}

#pragma mark - Classes
+ (instancetype)mappingForClass:(Class)internalClass key:(NSString *)key {
    return [self mappingForType:EFMappingTypeId externalKey:key internalKey:key internalClass:internalClass collectionClass:Nil formatter:nil transformer:nil transformationBlock:nil requires:nil];
}

+ (instancetype)mappingForClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey {
    return [self mappingForType:EFMappingTypeId externalKey:externalKey internalKey:internalKey internalClass:internalClass collectionClass:Nil formatter:nil transformer:nil transformationBlock:nil requires:nil];
}

#pragma mark - NSArray of classes
+ (instancetype)mappingForArrayOfClass:(Class)internalClass key:(NSString *)key {
    return [self mappingForType:EFMappingTypeCollection externalKey:key internalKey:key internalClass:internalClass collectionClass:[NSArray class] formatter:nil transformer:nil transformationBlock:nil requires:nil];
}

+ (instancetype)mappingForArrayOfClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey {
    return [self mappingForType:EFMappingTypeCollection externalKey:externalKey internalKey:internalKey internalClass:internalClass collectionClass:[NSArray class] formatter:nil transformer:nil transformationBlock:nil requires:nil];
}

- (void)setKey:(NSString *)key {
    self.internalKey = key;
    self.externalKey = key;
}

@end
