//
//  EFMapper.m
//  EFDataMappingKit
//
//  Created by Johan Kool on 23/4/2014.
//  Copyright (c) 2014 Egeniq. All rights reserved.
//

#import "EFMapper.h"

#import "EFMapper-Subclass.h"
#import "EFMapping-Private.h"
#import "EFMappingError.h"

@interface EFMapper ()

@property (nonatomic, strong) NSMutableDictionary *mappers;
@property (nonatomic, strong) NSMutableDictionary *mappings;
@property (nonatomic, strong) NSMutableDictionary *initializers;
@property (nonatomic, strong) NSMutableDictionary *dictionaryKeys;

@end

@implementation EFMapper

+ (instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });

    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _mappers = [NSMutableDictionary dictionary];
        _mappings = [NSMutableDictionary dictionary];
        _initializers = [NSMutableDictionary dictionary];
        _dictionaryKeys = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)registerMapper:(EFMapper *)mapper forClass:(Class)aClass {
    if (mapper) {
        self.mappers[NSStringFromClass(aClass)] = mapper;
    } else {
        [self.mappers removeObjectForKey:NSStringFromClass(aClass)];
    }
}

- (EFMapper *)mapperForClass:(Class)aClass {
    EFMapper *mapper = self.mappers[NSStringFromClass(aClass)];
    if (mapper) {
        return mapper;
    } else {
        Class superClass = [aClass superclass];
        if (superClass != Nil) {
            return [self mapperForClass:superClass];
        } else {
            return self;
        }
    }
}

- (void)registerMappings:(NSArray *)mappings forClass:(Class)aClass {
    if (mappings) {
        self.mappings[NSStringFromClass(aClass)] = mappings;
    } else {
        [self.mappings removeObjectForKey:NSStringFromClass(aClass)];
    }
}

- (NSArray *)mappingsForClass:(Class)aClass {
    NSArray *mappings = self.mappings[NSStringFromClass(aClass)];
    if (mappings) {
        return mappings;
    } else {
        Class superClass = [aClass superclass];
        if (superClass != Nil) {
            return [self mappingsForClass:superClass];
        } else {
            return nil;
        }
    }
}

- (void)registerInitializer:(EFMappingInitializerBlock)initializerBlock forClass:(Class)aClass {
    if (initializerBlock) {
        self.initializers[NSStringFromClass(aClass)] = [initializerBlock copy];
    } else {
        [self.initializers removeObjectForKey:NSStringFromClass(aClass)];
    }
}

- (EFMappingInitializerBlock)initializerForClass:(Class)aClass {
    EFMappingInitializerBlock initializer = self.initializers[NSStringFromClass(aClass)];
    if (initializer) {
        return initializer;
    } else {
        Class superClass = [aClass superclass];
        if (superClass != Nil) {
            return [self initializerForClass:superClass];
        } else {
            return nil;
        }
    }
}

- (BOOL)validateValues:(NSDictionary *)values forClass:(Class)aClass error:(NSError **)error {
    return [self validateValues:values forClass:aClass onObject:nil error:error];
}

- (BOOL)validateValues:(NSDictionary *)values onObject:(id)object error:(NSError **)error {
    return [self validateValues:values forClass:[object class] onObject:object error:error];
}

- (BOOL)validateValues:(NSDictionary *)values forClass:(Class)aClass onObject:(id)object error:(NSError **)error {
    // Forward to registered mapper
    EFMapper *mapper = [self mapperForClass:aClass];
    if (mapper != self) {
        return [mapper validateValues:values forClass:aClass onObject:object error:error];
    }

    NSMutableDictionary *errors = [NSMutableDictionary dictionary];

    NSArray *mappings = [self mappingsForClass:aClass];
    for (EFMapping *mapping in mappings) {
        id value = values[mapping.externalKey];

        switch (mapping.type) {
            case EFMappingTypeId: {
                NSError *transformError = nil;
                id transformedValue = [self transformValue:value mapping:mapping reverse:NO error:&transformError];
                if (value && !transformedValue) {
                    errors[mapping.internalKey] = transformError;
                }

                NSError *validationError = nil;
                BOOL valid = [self validateValue:transformedValue isCollection:NO mapping:mapping error:&validationError];
                if (!valid) {
                    errors[mapping.internalKey] = validationError;
                }

                if (object) {
                    // NSKeyValueCoding validation
                    NSError *validationError;
                    BOOL valid = [object validateValue:&value forKey:mapping.internalKey error:&validationError];
                    if (!valid) {
                        errors[mapping.internalKey] = validationError;
                    }
                }
            }
                break;
            case EFMappingTypeCollection:
                if ([mapping.collectionClass isSubclassOfClass:[NSArray class]] && [value isKindOfClass:[NSArray class]]) {
                    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[value count]];
                    NSMutableArray *errorsInArray = [NSMutableArray array];
                    for (__strong id child in value) {
                        NSError *transformError = nil;
                        id transformedValue = [self transformValue:child mapping:mapping reverse:NO error:&transformError];
                        if (child && !transformedValue) {
                            [errorsInArray addObject:transformError];
                        }

                        NSError *validationError = nil;
                        BOOL valid = [self validateValue:transformedValue isCollection:NO mapping:mapping error:&validationError];
                        if (!valid) {
                            [errorsInArray addObject:validationError];
                        } else {
                            [array addObject:transformedValue];
                        }
                    }

                    if ([errorsInArray count] > 0) {
                        NSString *description = [NSString stringWithFormat:@"Encountered %lu validation error(s) in array for key %@", (unsigned long)[errorsInArray count], mapping.internalKey];
                        NSError *validationError = [NSError errorWithDomain:EFMappingErrorDomain code:EFMappingUnexpectedClass userInfo:@{NSLocalizedDescriptionKey: description, EFMappingErrorValidationErrorsKey: errorsInArray}];
                        errors[mapping.internalKey] = validationError;
                    } else {
                        // Don't apply transform, that is for the internal classes!

                        NSError *validationError = nil;
                        BOOL valid = [self validateValue:value isCollection:YES mapping:mapping error:&validationError];
                        if (!valid) {
                            errors[mapping.internalKey] = validationError;
                        }

                        if (object) {
                            // NSKeyValueCoding validation
                            NSError *validationError;
                            BOOL valid = [object validateValue:&value forKey:mapping.internalKey error:&validationError];
                            if (!valid) {
                                errors[mapping.internalKey] = validationError;
                            }
                        }
                    }
                } else if ([mapping.collectionClass isSubclassOfClass:[NSDictionary class]] && [value isKindOfClass:[NSDictionary class]]) {
                    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:[value count]];
                    NSMutableDictionary *errorsInDictionary = [NSMutableDictionary dictionary];
                    [value enumerateKeysAndObjectsUsingBlock:^(id key, id child, BOOL *stop) {
                        NSError *transformError = nil;
                        id transformedValue = [self transformValue:child mapping:mapping reverse:NO error:&transformError];
                        if (child && !transformedValue) {
                            errorsInDictionary[key] = transformError;
                        }

                        NSError *validationError = nil;
                        BOOL valid = [self validateValue:transformedValue isCollection:NO mapping:mapping error:&validationError];
                        if (!valid) {
                            errorsInDictionary[key] = validationError;
                        } else {
                            dictionary[key] = child;
                        }
                    }];

                    if ([errorsInDictionary count] > 0) {
                        NSString *description = [NSString stringWithFormat:@"Encountered %lu validation error(s) in dictionary for key %@", (unsigned long)[errorsInDictionary count], mapping.internalKey];
                        NSError *validationError = [NSError errorWithDomain:EFMappingErrorDomain code:EFMappingUnexpectedClass userInfo:@{NSLocalizedDescriptionKey: description, EFMappingErrorValidationErrorsKey: errorsInDictionary}];
                        errors[mapping.internalKey] = validationError;
                    } else {
                        // Don't apply transform, that is for the internal classes!

                        NSError *validationError = nil;
                        BOOL valid = [self validateValue:value isCollection:YES mapping:mapping error:&validationError];
                        if (!valid) {
                            errors[mapping.internalKey] = validationError;
                        }

                        if (object) {
                            // NSKeyValueCoding validation
                            NSError *validationError;
                            BOOL valid = [object validateValue:&value forKey:mapping.internalKey error:&validationError];
                            if (!valid) {
                                errors[mapping.internalKey] = validationError;
                            }
                        }
                    }
                } else {
                    // Don't apply transform, that is for the internal classes!

                    NSError *validationError = nil;
                    BOOL valid = [self validateValue:value isCollection:YES mapping:mapping error:&validationError];
                    if (!valid) {
                        errors[mapping.internalKey] = validationError;
                    }

                    if (object) {
                        // NSKeyValueCoding validation
                        NSError *validationError;
                        BOOL valid = [object validateValue:&value forKey:mapping.internalKey error:&validationError];
                        if (!valid) {
                            errors[mapping.internalKey] = validationError;
                        }
                    }
                }
                break;
            default:
                break;
        }
    }

    if ([errors count] > 0) {
        if (error != NULL) {
            NSString *description = [NSString stringWithFormat:NSLocalizedString(@"Encountered %d validation error(s) in %@", @""), [errors count], NSStringFromClass(aClass)];
            *error = [NSError errorWithDomain:EFMappingErrorDomain code:EFMappingInvalidValues userInfo:@{NSLocalizedDescriptionKey: description, EFMappingErrorValidationErrorsKey: errors}];
        }
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)setValues:(NSDictionary *)values onObject:(id)object error:(NSError **)error {
    // Forward to registered mapper
    EFMapper *mapper = [self mapperForClass:[object class]];
    if (mapper != self) {
        return [mapper setValues:values onObject:object error:error];
    }

    BOOL valid = [self validateValues:values onObject:object error:error];
    if (!valid) {
        return NO;
    }

    NSArray *mappings = [self mappingsForClass:[object class]];
    for (EFMapping *mapping in mappings) {
        id value = values[mapping.externalKey];

        switch (mapping.type) {
            case EFMappingTypeId: {
                id transformedValue = [self transformValue:value mapping:mapping reverse:NO error:NULL];
                [self setValue:transformedValue onObject:object isCollection:NO mapping:mapping];
            }
                break;
            case EFMappingTypeCollection:
                if ([mapping.collectionClass isSubclassOfClass:[NSArray class]]) {
                    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[value count]];
                    for (id child in value) {
                        id transformedChild = [self transformValue:child mapping:mapping reverse:NO error:NULL];
                        if (![transformedChild isKindOfClass:mapping.internalClass] && [transformedChild isKindOfClass:[NSDictionary class]] && [self mappingsForClass:mapping.internalClass]) {
                            transformedChild = [self objectOfClass:mapping.internalClass withValues:transformedChild error:error];
                        }
                        if (transformedChild) {
                            [array addObject:transformedChild];
                        }
                    }
                    id collectionValue = [[mapping.collectionClass alloc] initWithArray:array];
                    [self setValue:collectionValue onObject:object isCollection:YES mapping:mapping];
                } else if ([mapping.collectionClass isSubclassOfClass:[NSDictionary class]]) {
                    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:[value count]];
                    [value enumerateKeysAndObjectsUsingBlock:^(id key, id child, BOOL *stop) {
                        id transformedChild = [self transformValue:child mapping:mapping reverse:NO error:NULL];
                        if (![transformedChild isKindOfClass:mapping.internalClass] && [transformedChild isKindOfClass:[NSDictionary class]] && [self mappingsForClass:mapping.internalClass]) {
                            transformedChild = [self objectOfClass:mapping.internalClass withValues:transformedChild error:error];
                        }
                        if (transformedChild) {
                            dictionary[key] = transformedChild;
                        }
                    }];
                    id collectionValue = [[mapping.collectionClass alloc] initWithDictionary:dictionary];
                    [self setValue:collectionValue onObject:object isCollection:YES mapping:mapping];
                } else {
                    continue;
                }
                break;
            default:
                break;
        }
    }
    return YES;
}

- (id)objectOfClass:(Class)aClass withValues:(NSDictionary *)values error:(NSError **)error {
    EFMapper *mapper = [self mapperForClass:aClass];
    if (mapper != self) {
        return [mapper objectOfClass:aClass withValues:values error:error];
    }

    EFMappingInitializerBlock initializer = [self initializerForClass:aClass];
    id object = nil;
    if (initializer) {
        object = initializer(aClass, values);
    } else {
        object = [[aClass alloc] init];
    }

    if (!object) {
        // For some reason the initialisation failed
        if (error != NULL) {
            *error = [NSError errorWithDomain:EFMappingErrorDomain code:EFMappingInitialisationFailed userInfo:nil];
        }
        return nil;
    }

    BOOL result = [self setValues:values onObject:object error:error];
    return result ? object : nil;
}

#pragma mark - Helper methods
- (id)transformValue:(id)value mapping:(EFMapping *)mapping reverse:(BOOL)reverse error:(NSError **)error {
    if (mapping.formatter && !reverse && [value isKindOfClass:[NSString class]]) {
        id formattedValue;
        NSString *errorDescription = nil;
        if ([mapping.formatter getObjectValue:&formattedValue forString:value errorDescription:&errorDescription]) {
            value = formattedValue;
        } else {
            *error = [NSError errorWithDomain:EFMappingErrorDomain code:EFMappingTransformationError userInfo:@{NSLocalizedDescriptionKey: errorDescription}];
            value = nil;
        }
    } else if (mapping.formatter && reverse && [value isKindOfClass:mapping.internalClass]) {
        NSString *formattedString;
        formattedString = [mapping.formatter stringForObjectValue:value];
        value = formattedString;
    }
    if (mapping.transformer) {
        value = [mapping.transformer transformedValue:value];
    }
    if (mapping.transformationBlock) {
        value = mapping.transformationBlock(value, reverse);
        if ([value isKindOfClass:[NSError class]]) {
            *error = (NSError *)value;
            value = nil;
        }
    }
    return value;
}

- (BOOL)validateValue:(id)value isCollection:(BOOL)isCollection mapping:(EFMapping *)mapping error:(NSError **)error {
    if ([value isKindOfClass:[NSNull class]]) {
        value = nil;
    }

    BOOL allowed = YES;
    if (mapping.requires) {
        allowed = [mapping.requires evaluateForValue:value];
    }
    if (!allowed) {
        if (error != NULL) {
            NSString *description = [NSString stringWithFormat:@"Did not pass requirements for value (%@) of class %@ for key %@", value, NSStringFromClass([value class]), mapping.internalKey];
            *error = [NSError errorWithDomain:EFMappingErrorDomain code:EFMappingRequirementsFailed userInfo:@{NSLocalizedDescriptionKey: description}];
        };
        return NO;
    }

    if (isCollection) {
        if (value && ![value isKindOfClass:mapping.collectionClass]) {
            if (error != NULL) {
                NSString *description = [NSString stringWithFormat:@"Did not expect value (%@) of class %@ for key %@ but %@ instance", value, NSStringFromClass([value class]), mapping.internalKey, NSStringFromClass(mapping.collectionClass)];
                *error = [NSError errorWithDomain:EFMappingErrorDomain code:EFMappingUnexpectedClass userInfo:@{NSLocalizedDescriptionKey: description}];
            }
            return NO;
        }
    } else {
        if (value && ![value isKindOfClass:mapping.internalClass]) {
            // if dictionary try to convert
            if ([value isKindOfClass:[NSDictionary class]] && [self mappingsForClass:mapping.internalClass]) {
                BOOL valid = [self validateValues:value forClass:mapping.internalClass error:error];
                if (!valid) {
                    return NO;
                }
            } else {
                if (error != NULL) {
                    NSString *description = [NSString stringWithFormat:@"Did not expect value (%@) of class %@ for key %@ but %@ instance%@", value, NSStringFromClass([value class]), mapping.internalKey, NSStringFromClass(mapping.internalClass), [self mappingsForClass:mapping.internalClass] ? @" or NSDictionary" : @""];
                    *error = [NSError errorWithDomain:EFMappingErrorDomain code:EFMappingUnexpectedClass userInfo:@{NSLocalizedDescriptionKey: description}];
                }
                return NO;
            }
        }
    }
    return YES;
}

- (void)setValue:(id)value onObject:(id)object isCollection:(BOOL)isCollection mapping:(EFMapping *)mapping {
    if (!value) {
        // not in dictionary, leave as is
        return;
    }

    if ([value isKindOfClass:[NSNull class]]) {
        // null, remove
        value = nil;
    }

    if (![value isKindOfClass:mapping.internalClass] && !isCollection) {
        // if dictionary convert
        if ([value isKindOfClass:[NSDictionary class]] && [self mappingsForClass:mapping.internalClass]) {
            value = [self objectOfClass:mapping.internalClass withValues:value error:NULL];
        }
    }

    if (!value) {
        // TODO: Use default?
    }

    // NSKeyValueCoding validation: gives classes a chance to implement validation too
    [object validateValue:&value forKey:mapping.internalKey error:NULL];

    [object setValue:value forKey:mapping.internalKey];
}

#pragma mark - NSCoding support
- (void)encodeObject:(id)object withCoder:(NSCoder *)aCoder {
    // Forward to registered mapper
    EFMapper *mapper = [self mapperForClass:[object class]];
    if (mapper != self) {
        return [mapper encodeObject:object withCoder:aCoder];
    }

    NSArray *mappings = [self mappingsForClass:[object class]];
    for (EFMapping *mapping in mappings) {
        [aCoder encodeObject:[object valueForKey:mapping.internalKey] forKey:mapping.internalKey];
    }
}

- (void)decodeObject:(id)object withCoder:(NSCoder *)aDecoder {
    // Forward to registered mapper
    EFMapper *mapper = [self mapperForClass:[object class]];
    if (mapper != self) {
        return [mapper decodeObject:object withCoder:aDecoder];
    }

    NSArray *mappings = [self mappingsForClass:[object class]];
    for (EFMapping *mapping in mappings) {
        switch (mapping.type) {
            case EFMappingTypeId:
                [object setValue:[aDecoder decodeObjectOfClass:mapping.internalClass forKey:mapping.internalKey] forKey:mapping.internalKey];
                break;
            case EFMappingTypeCollection:
                [object setValue:[aDecoder decodeObjectOfClass:mapping.collectionClass forKey:mapping.internalKey] forKey:mapping.internalKey];
                break;
            default:
                break;
        }
    }
}

// Feature idea
//- (id)copyObject:(id)object deepCopy:(BOOL)deepCopy {
//
//}

#pragma mark - Dictionary representation
- (void)registerDictionaryRepresentationKeys:(NSArray *)keys forClass:(Class)aClass {
    if (keys) {
        self.dictionaryKeys[NSStringFromClass(aClass)] = keys;
    } else {
        [self.dictionaryKeys removeObjectForKey:NSStringFromClass(aClass)];
    }
}

- (NSArray *)dictionaryRepresentationKeysForClass:(Class)aClass {
    NSArray *dictionaryKeys = self.dictionaryKeys[NSStringFromClass(aClass)];
    if (dictionaryKeys) {
        return dictionaryKeys;
    } else {
        Class superClass = [aClass superclass];
        if (superClass != Nil) {
            return [self dictionaryRepresentationKeysForClass:superClass];
        } else {
            return nil;
        }
    }
}

- (id)dictionaryRepresentationOfObject:(id)object forKeys:(NSArray *)keys {
    // Forward to registered mapper
    EFMapper *mapper = [self mapperForClass:[object class]];
    if (mapper != self) {
        return [mapper dictionaryRepresentationOfObject:object forKeys:keys];
    }

    if ([object isKindOfClass:[NSArray class]]) {
        // If the object is an array
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:[object count]];
        for (id child in object) {
            id representation = [self dictionaryRepresentationOfObject:child];
            if (representation) {
                [array addObject:representation];
            } else {
                [array addObject:[NSNull null]];
            }
        }
        return [array copy];
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        // If the object is a dictionary
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:[object count]];
        [object enumerateKeysAndObjectsUsingBlock:^(id key, id child, BOOL *stop) {
            id representation = [self dictionaryRepresentationOfObject:child];
            if (representation) {
                dictionary[key] = representation;
            } else {
                dictionary[key] = [NSNull null];
            };
        }];
        return [dictionary copy];
    } else {
        NSArray *mappings = [self mappingsForClass:[object class]];
        if (mappings) {
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
            for (EFMapping *mapping in mappings) {
                // only include requested keys, nil means all
                if (keys && ![keys containsObject:mapping.externalKey]) {
                    continue;
                }

                if (mapping.type == EFMappingTypeCollection) {
                    if ([mapping.collectionClass isSubclassOfClass:[NSArray class]]) {
                        NSArray *value = [object valueForKey:mapping.internalKey];
                        NSMutableArray *dictionaryRepresentation = [NSMutableArray arrayWithCapacity:[value count]];
                        for (__strong id child in value) {
                            NSError *error = nil;
                            child = [self transformValue:child mapping:mapping reverse:YES error:&error];
                            if (child) {
                                [dictionaryRepresentation addObject:[self dictionaryRepresentationOfObject:child]];
                            } else {
                                [dictionaryRepresentation addObject:[NSNull null]];
                            }
                        }
                        dictionary[mapping.externalKey] = dictionaryRepresentation;
                    } else if ([mapping.collectionClass isSubclassOfClass:[NSDictionary class]]) {
                        NSDictionary *value = [object valueForKey:mapping.internalKey];
                        NSMutableDictionary *dictionaryRepresentation = [NSMutableDictionary dictionaryWithCapacity:[value count]];
                        [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id child, BOOL *stop) {
                            NSError *error = nil;
                            child = [self transformValue:child mapping:mapping reverse:YES error:&error];
                            if (child) {
                                dictionaryRepresentation[key] = [self dictionaryRepresentationOfObject:child];
                            } else {
                                dictionaryRepresentation[key] = [NSNull null];
                            }
                        }];
                        dictionary[mapping.externalKey] = dictionaryRepresentation;
                    } else {
                        continue;
                    }
                } else {
                    id child = [object valueForKey:mapping.internalKey];
                    if (child) {
                        NSError *error = nil;
                        child = [self transformValue:child mapping:mapping reverse:YES error:&error];
                        if (object) {
                            dictionary[mapping.externalKey] = [self dictionaryRepresentationOfObject:child];
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
            return object;
        }
    }
}

- (id)dictionaryRepresentationOfObject:(id)object {
    // Forward to registered mapper
    EFMapper *mapper = [self mapperForClass:[object class]];
    if (mapper != self) {
        return [mapper dictionaryRepresentationOfObject:object];
    }

    return [self dictionaryRepresentationOfObject:object forKeys:[self dictionaryRepresentationKeysForClass:[object class]]];
}

@end
