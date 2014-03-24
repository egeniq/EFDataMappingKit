//
//  NSObject+EFMapping.h
//  EFMapping
//
//  Created by Johan Kool on 20/3/2014.
//  Copyright (c) 2014 Johan Kool. All rights reserved.
//

#import "NSObject+EFMapping.h"

NSString * const EFMappingErrorDomain = @"EFMappingErrorDomain";
NSString * const EFMappingErrorValidationErrorsKey = @"validationErrors";

typedef NS_ENUM(NSUInteger, MappingType) {
    MappingTypeId,
    MappingTypeCollection
};

@interface EFMapping ()

@property (nonatomic, assign) NSUInteger type;
@property (nonatomic, copy) NSString *externalKey;
@property (nonatomic, copy) NSString *internalKey;
@property (nonatomic, assign) Class collectionClass;
@property (nonatomic, assign) Class internalClass;

@property (nonatomic, strong) NSFormatter *formatter;
@property (nonatomic, strong) NSValueTransformer *transformer;
@property (nonatomic, copy) EFMappingTransformationBlock transformationBlock;

@end

@implementation EFMapping

+ (instancetype)mappingForType:(MappingType)type externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey internalClass:(Class)internalClass collectionClass:(Class)collectionClass formatter:(NSFormatter *)formatter transformer:(NSValueTransformer *)transformer transformationBlock:(EFMappingTransformationBlock)transformationBlock {
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

@implementation NSObject (EFMapping)

#pragma mark - Mappings
+ (NSArray *)mappings {
    return nil;
}

#pragma mark - Validating and applying values
- (BOOL)validateValues:(NSDictionary *)values error:(NSError **)error {
    NSMutableDictionary *errors = [NSMutableDictionary dictionary];

    NSArray *mappings = [[self class] mappings];
    for (EFMapping *mapping in mappings) {
        id incomingObject = values[mapping.externalKey];
        if (!incomingObject) {
            continue;
        }

        if ([incomingObject isKindOfClass:[NSNull class]]) {
            continue;
        }

        switch (mapping.type) {
            case MappingTypeId: {
                NSError *validationError = nil;
                incomingObject = [self validateObject:incomingObject mapping:mapping error:&validationError];
                if (!incomingObject) {
                    errors[mapping.internalKey] = validationError;
                }
            }
                break;
            case MappingTypeCollection:
                if ([mapping.collectionClass isSubclassOfClass:[NSArray class]] && [incomingObject isKindOfClass:[NSArray class]]) {
                    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[incomingObject count]];
                    NSMutableArray *errorsInArray = [NSMutableArray array];
                    for (__strong id object in incomingObject) {
                        NSError *validationError = nil;
                        object = [self validateObject:object mapping:mapping error:&validationError];
                        if (!object) {
                            [errorsInArray addObject:validationError];
                        } else {
                            [array addObject:object];
                        }
                    }
                    if ([errorsInArray count] > 0) {
                        NSString *description = [NSString stringWithFormat:@"Encountered %lu validation error(s) in array for key %@", (unsigned long)[errorsInArray count], mapping.internalKey];
                        NSError *validationError = [NSError errorWithDomain:EFMappingErrorDomain code:EFMappingUnexpectedClass userInfo:@{NSLocalizedDescriptionKey: description, EFMappingErrorValidationErrorsKey: errorsInArray}];
                        errors[mapping.internalKey] = validationError;
                    }
                    incomingObject = [[mapping.collectionClass alloc] initWithArray:array];
                } else if ([mapping.collectionClass isSubclassOfClass:[NSDictionary class]] && [incomingObject isKindOfClass:[NSDictionary class]]) {
                    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:[incomingObject count]];
                    NSMutableDictionary *errorsInDictionary = [NSMutableDictionary dictionary];
                    [incomingObject enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
                        NSError *validationError = nil;
                        object = [self validateObject:object mapping:mapping error:&validationError];
                        if (!object) {
                            errorsInDictionary[key] = validationError;
                        } else {
                            dictionary[key] = object;
                        }
                    }];
                    if ([errorsInDictionary count] > 0) {
                        NSString *description = [NSString stringWithFormat:@"Encountered %lu validation error(s) in dictionary for key %@", (unsigned long)[errorsInDictionary count], mapping.internalKey];
                        NSError *validationError = [NSError errorWithDomain:EFMappingErrorDomain code:EFMappingUnexpectedClass userInfo:@{NSLocalizedDescriptionKey: description, EFMappingErrorValidationErrorsKey: errorsInDictionary}];
                        errors[mapping.internalKey] = validationError;
                    }
                    incomingObject = [[mapping.collectionClass alloc] initWithDictionary:dictionary];
                } else {
                    NSString *description = [NSString stringWithFormat:@"Did not expect value (%@) of class %@ for key %@ but %@ instance", incomingObject, NSStringFromClass([incomingObject class]), mapping.internalKey, NSStringFromClass(mapping.collectionClass)];
                    NSError *validationError = [NSError errorWithDomain:EFMappingErrorDomain code:EFMappingUnexpectedClass userInfo:@{NSLocalizedDescriptionKey: description}];
                    errors[mapping.internalKey] = validationError;
                }
                break;
            default:
                break;
        }

        // NSKeyValueCoding validation
        NSError *validationError;
        BOOL valid = [self validateValue:&incomingObject forKey:mapping.internalKey error:&validationError];
        if (!valid) {
            errors[mapping.internalKey] = validationError;
        }
    }

    if ([errors count] > 0) {
        if (error != NULL) {
            NSString *description = [NSString stringWithFormat:NSLocalizedString(@"Encountered %d validation error(s) in %@", @""), [errors count], NSStringFromClass([self class])];
            *error = [NSError errorWithDomain:EFMappingErrorDomain code:EFMappingInvalidValues userInfo:@{NSLocalizedDescriptionKey: description, EFMappingErrorValidationErrorsKey: errors}];
        }
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)setValues:(NSDictionary *)values error:(NSError **)error {
    BOOL valid = [self validateValues:values error:error];
    if (!valid) {
        return NO;
    }

    NSArray *mappings = [[self class] mappings];
    for (EFMapping *mapping in mappings) {
        id incomingObject = values[mapping.externalKey];
        if (!incomingObject) {
            // not in dictionary, leave as is
            continue;
        }

        if ([incomingObject isKindOfClass:[NSNull class]]) {
            // null, remove
            [self setValue:nil forKey:mapping.internalKey];
            continue;
        }

        switch (mapping.type) {
            case MappingTypeId:
                incomingObject = [self transformObject:incomingObject mapping:mapping reverse:NO error:NULL];
                if (![incomingObject isKindOfClass:mapping.internalClass]) {
                    // if dictionary convert
                    if ([incomingObject isKindOfClass:[NSDictionary class]] && [mapping.internalClass mappings]) {
                        id convertedObject = [[mapping.internalClass alloc] init];
                        [convertedObject setValues:incomingObject error:error];
                        incomingObject = convertedObject;
                    } else {
                        continue;
                    }
                }
                break;
            case MappingTypeCollection:
                if ([mapping.collectionClass isSubclassOfClass:[NSArray class]]) {
                    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[incomingObject count]];
                    for (id object in incomingObject) {
                        [array addObject:[self transformObject:object mapping:mapping reverse:NO error:NULL]];
                    }
                    incomingObject = [[mapping.collectionClass alloc] initWithArray:array];
                } else if ([mapping.collectionClass isSubclassOfClass:[NSDictionary class]]) {
                    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:[incomingObject count]];
                    [incomingObject enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
                        dictionary[key] = [self transformObject:object mapping:mapping reverse:NO error:NULL];
                    }];
                    incomingObject = [[mapping.collectionClass alloc] initWithDictionary:dictionary];
                } else {
                    continue;
                }
                break;
            default:
                break;
        }

        // NSKeyValueCoding validation: gives classes a chance to implement validation too
        [self validateValue:&incomingObject forKey:mapping.internalKey error:NULL];
        [self setValue:incomingObject forKey:mapping.internalKey];
    }
    return YES;
}

#pragma mark - Helper methods
- (id)transformObject:(id)incomingObject mapping:(EFMapping *)mapping reverse:(BOOL)reverse error:(NSError **)error {
    if (mapping.formatter && [incomingObject isKindOfClass:[NSString class]]) {
        id formattedObject;
        NSString *errorDescription = nil;
        if ([mapping.formatter getObjectValue:&formattedObject forString:incomingObject errorDescription:&errorDescription]) {
            incomingObject = formattedObject;
        } else {
            *error = [NSError errorWithDomain:EFMappingErrorDomain code:EFMappingTransformationError userInfo:@{NSLocalizedDescriptionKey: errorDescription}];
            incomingObject = nil;
        }
    }
    if (mapping.transformer) {
        incomingObject = [mapping.transformer transformedValue:incomingObject];
    }
    if (mapping.transformationBlock) {
        incomingObject = mapping.transformationBlock(incomingObject, reverse);
        if ([incomingObject isKindOfClass:[NSError class]]) {
            *error = (NSError *)incomingObject;
            incomingObject = nil;
        }
    }
    return incomingObject;
}

- (id)validateObject:(id)incomingObject mapping:(EFMapping *)mapping error:(NSError **)error {
    NSError *validationError = nil;
    incomingObject = [self transformObject:incomingObject mapping:mapping reverse:NO error:&validationError];
    if (!incomingObject) {
        *error = validationError;
        return nil;
    }
    if (![incomingObject isKindOfClass:mapping.internalClass]) {
        // if dictionary try to convert
        if ([incomingObject isKindOfClass:[NSDictionary class]] && [mapping.internalClass mappings]) {
            id convertedObject = [[mapping.internalClass alloc] init];
            NSError *validationError;
            BOOL valid = [convertedObject validateValues:incomingObject error:&validationError];
            if (!valid) {
                *error = validationError;
                return nil;
            }
        } else {
            NSString *description = [NSString stringWithFormat:@"Did not expect value (%@) of class %@ for key %@ but %@ instance%@", incomingObject, NSStringFromClass([incomingObject class]), mapping.internalKey, NSStringFromClass(mapping.internalClass), [mapping.internalClass mappings] ? @" or NSDictionary" : @""];
            NSError *validationError = [NSError errorWithDomain:EFMappingErrorDomain code:EFMappingUnexpectedClass userInfo:@{NSLocalizedDescriptionKey: description}];
            *error = validationError;
            return nil;
        }
    }
    return incomingObject;
}

#pragma mark - NSCoding support
- (void)encodeUsingMappingsWithCoder:(NSCoder *)aCoder {
    NSArray *mappings = [[self class] mappings];
    for (EFMapping *mapping in mappings) {
        [aCoder encodeObject:[self valueForKey:mapping.internalKey] forKey:mapping.internalKey];
    }
}

- (void)decodeUsingMappingsWithCoder:(NSCoder *)aDecoder {
    NSArray *mappings = [[self class] mappings];
    for (EFMapping *mapping in mappings) {
        switch (mapping.type) {
            case MappingTypeId:
                [self setValue:[aDecoder decodeObjectOfClass:mapping.internalClass forKey:mapping.internalKey] forKey:mapping.internalKey];
                break;
            case MappingTypeCollection:
                [self setValue:[aDecoder decodeObjectOfClass:mapping.collectionClass forKey:mapping.internalKey] forKey:mapping.internalKey];
                break;
            default:
                break;
        }
    }
}

#pragma mark - Dictionary representation
+ (NSArray *)dictionaryRepresentationKeys {
    return nil;
}

- (id)dictionaryRepresentation {
    return [self dictionaryRepresentationForKeys:[[self class] dictionaryRepresentationKeys]];
}

- (id)dictionaryRepresentationForKeys:(NSArray *)keys {
    NSArray *mappings = [[self class] mappings];
    if (mappings) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        for (EFMapping *mapping in mappings) {
            // only include requested keys, nil means all
            if (keys && ![keys containsObject:mapping.externalKey]) {
                continue;
            }

            if (mapping.type == MappingTypeCollection) {
                if ([mapping.collectionClass isSubclassOfClass:[NSArray class]]) {
                    NSArray *value = [self valueForKey:mapping.internalKey];
                    NSMutableArray *dictionaryRepresentation = [NSMutableArray arrayWithCapacity:[value count]];
                    for (__strong id object in value) {
                        NSError *error = nil;
                        object = [self transformObject:object mapping:mapping reverse:YES error:&error];
                        if (object) {
                            [dictionaryRepresentation addObject:[object dictionaryRepresentation]];
                        } else {
                            [dictionaryRepresentation addObject:[NSNull null]];
                        }
                    }
                    dictionary[mapping.externalKey] = dictionaryRepresentation;
                } else if ([mapping.collectionClass isSubclassOfClass:[NSDictionary class]]) {
                    NSDictionary *value = [self valueForKey:mapping.internalKey];
                    NSMutableDictionary *dictionaryRepresentation = [NSMutableDictionary dictionaryWithCapacity:[value count]];
                    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
                        NSError *error = nil;
                        object = [self transformObject:object mapping:mapping reverse:YES error:&error];
                        if (object) {
                            dictionaryRepresentation[key] = [object dictionaryRepresentation];
                        } else {
                            dictionaryRepresentation[key] = [NSNull null];
                        }
                    }];
                    dictionary[mapping.externalKey] = dictionaryRepresentation;
                } else {
                    continue;
                }
            } else {
                id object = [self valueForKey:mapping.internalKey];
                if (object) {
                    NSError *error = nil;
                    object = [self transformObject:object mapping:mapping reverse:YES error:&error];
                    if (object) {
                        dictionary[mapping.externalKey] = [object dictionaryRepresentation];
                    } else {
                        dictionary[mapping.externalKey] = [NSNull null];
                    }
                } else {
                    dictionary[mapping.externalKey] = [NSNull null];
                }
            }
        }
        return [dictionary copy];
    } else {
        return self;
    }
}

@end
