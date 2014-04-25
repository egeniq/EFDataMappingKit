//
//  EFMapper.m
//  MappingKit
//
//  Created by Johan Kool on 23/4/2014.
//  Copyright (c) 2014 Egeniq. All rights reserved.
//

#import "EFMapper.h"

#import "EFMapping-Private.h"

@interface EFMapper ()

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
        _mappings = [NSMutableDictionary dictionary];
        _initializers = [NSMutableDictionary dictionary];
        _dictionaryKeys = [NSMutableDictionary dictionary];
    }
    return self;
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
    NSMutableDictionary *errors = [NSMutableDictionary dictionary];

    NSArray *mappings = [self mappingsForClass:aClass];
    for (EFMapping *mapping in mappings) {
        id incomingObject = values[mapping.externalKey];
//        if (!incomingObject) {
//            // not in dictionary, leave as is
//            continue;
//        }

        if ([incomingObject isKindOfClass:[NSNull class]]) {
            incomingObject = nil;
        }

        BOOL allowed = YES;
        if (mapping.requires) {
            allowed = [mapping.requires evaluateForValue:incomingObject];
        }
        if (!allowed) {
            NSString *description = [NSString stringWithFormat:@"Did not pass requirements for value (%@) of class %@ for key %@", incomingObject, NSStringFromClass([incomingObject class]), mapping.internalKey];
            NSError *validationError = [NSError errorWithDomain:EFMappingErrorDomain code:EFMappingRequirementsFailed userInfo:@{NSLocalizedDescriptionKey: description}];
            errors[mapping.internalKey] = validationError;
            continue;
        }

        switch (mapping.type) {
            case EFMappingTypeId: {
                NSError *validationError = nil;
                incomingObject = [self validateObject:incomingObject mapping:mapping error:&validationError];
                if (!incomingObject) {
                    errors[mapping.internalKey] = validationError;
                }
            }
                break;
            case EFMappingTypeCollection:
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
                    if (allowed && !incomingObject) {
                        // TODO: This is weird
                    } else {
                        NSString *description = [NSString stringWithFormat:@"Did not expect value (%@) of class %@ for key %@ but %@ instance", incomingObject, NSStringFromClass([incomingObject class]), mapping.internalKey, NSStringFromClass(mapping.collectionClass)];
                        NSError *validationError = [NSError errorWithDomain:EFMappingErrorDomain code:EFMappingUnexpectedClass userInfo:@{NSLocalizedDescriptionKey: description}];
                        errors[mapping.internalKey] = validationError;
                    }
                }
                break;
            default:
                break;
        }

        // NSKeyValueCoding validation
        if (object) {
            NSError *validationError;
            BOOL valid = [object validateValue:&incomingObject forKey:mapping.internalKey error:&validationError];
            if (!valid) {
                errors[mapping.internalKey] = validationError;
            }
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
    BOOL valid = [self validateValues:values onObject:object error:error];
    if (!valid) {
        return NO;
    }

    NSArray *mappings = [self mappingsForClass:[object class]];
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
            case EFMappingTypeId:
                incomingObject = [self transformObject:incomingObject mapping:mapping reverse:NO error:NULL];
                if (![incomingObject isKindOfClass:mapping.internalClass]) {
                    // if dictionary convert
                    if ([incomingObject isKindOfClass:[NSDictionary class]] && [self mappingsForClass:mapping.internalClass]) {
                        if (![incomingObject isKindOfClass:mapping.internalClass] && [object isKindOfClass:[NSDictionary class]] && [self mappingsForClass:mapping.internalClass]) {
                            incomingObject = [self objectOfClass:mapping.internalClass withValues:incomingObject error:error];
                        }
                        // TODO: Check for nil!
                    } else {
                        continue;
                    }
                }
                break;
            case EFMappingTypeCollection:
                if ([mapping.collectionClass isSubclassOfClass:[NSArray class]]) {
                    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[incomingObject count]];
                    for (__strong id child in incomingObject) {
                        child = [self transformObject:child mapping:mapping reverse:NO error:NULL];
                        if (![child isKindOfClass:mapping.internalClass] && [child isKindOfClass:[NSDictionary class]] && [self mappingsForClass:mapping.internalClass]) {
                            child = [self objectOfClass:mapping.internalClass withValues:child error:error];
                        }
                        // TODO: Check for nil!
                        [array addObject:child];
                    }
                    incomingObject = [[mapping.collectionClass alloc] initWithArray:array];
                } else if ([mapping.collectionClass isSubclassOfClass:[NSDictionary class]]) {
                    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:[incomingObject count]];
                    [incomingObject enumerateKeysAndObjectsUsingBlock:^(id key, id child, BOOL *stop) {
                        child = [self transformObject:child mapping:mapping reverse:NO error:NULL];
                        if (![child isKindOfClass:mapping.internalClass] && [child isKindOfClass:[NSDictionary class]] && [self mappingsForClass:mapping.internalClass]) {
                            child = [self objectOfClass:mapping.internalClass withValues:child error:error];
                        }
                        // TODO: Check for nil!
                        dictionary[key] = child;
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
        [object validateValue:&incomingObject forKey:mapping.internalKey error:NULL];
        [object setValue:incomingObject forKey:mapping.internalKey];
    }
    return YES;
}

- (id)objectOfClass:(Class)aClass withValues:(NSDictionary *)values error:(NSError **)error {
    EFMappingInitializerBlock initializer = [self initializerForClass:aClass];
    id object = nil;
    if (initializer) {
        object = initializer(aClass, values);
    } else {
        object = [[aClass alloc] init];
    }

    if (!object) {
        // For some reason the initialisation failed
        if (*error != NULL) {
            *error = [NSError errorWithDomain:EFMappingErrorDomain code:EFMappingInitialisationFailed userInfo:nil];
        }
        return nil;
    }

    BOOL result = [self setValues:values onObject:object error:error];
    return result ? object : nil;
}

#pragma mark - Helper methods
- (id)transformObject:(id)incomingObject mapping:(EFMapping *)mapping reverse:(BOOL)reverse error:(NSError **)error {
    if (mapping.formatter && !reverse && [incomingObject isKindOfClass:[NSString class]]) {
        id formattedObject;
        NSString *errorDescription = nil;
        if ([mapping.formatter getObjectValue:&formattedObject forString:incomingObject errorDescription:&errorDescription]) {
            incomingObject = formattedObject;
        } else {
            *error = [NSError errorWithDomain:EFMappingErrorDomain code:EFMappingTransformationError userInfo:@{NSLocalizedDescriptionKey: errorDescription}];
            incomingObject = nil;
        }
    } else if (mapping.formatter && reverse && [incomingObject isKindOfClass:mapping.internalClass]) {
        NSString *formattedString;
        formattedString = [mapping.formatter stringForObjectValue:incomingObject];
        incomingObject = formattedString;
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
        if ([incomingObject isKindOfClass:[NSDictionary class]] && [self mappingsForClass:mapping.internalClass]) {
            NSError *validationError;
            BOOL valid = [self validateValues:incomingObject forClass:mapping.internalClass error:&validationError];
            if (!valid) {
                *error = validationError;
                return nil;
            }
        } else {
            NSString *description = [NSString stringWithFormat:@"Did not expect value (%@) of class %@ for key %@ but %@ instance%@", incomingObject, NSStringFromClass([incomingObject class]), mapping.internalKey, NSStringFromClass(mapping.internalClass), [self mappingsForClass:mapping.internalClass] ? @" or NSDictionary" : @""];
            NSError *validationError = [NSError errorWithDomain:EFMappingErrorDomain code:EFMappingUnexpectedClass userInfo:@{NSLocalizedDescriptionKey: description}];
            *error = validationError;
            return nil;
        }
    }
    return incomingObject;
}

#pragma mark - NSCoding support
- (void)encodeObject:(id)object withCoder:(NSCoder *)aCoder {
    NSArray *mappings = [self mappingsForClass:[object class]];
    for (EFMapping *mapping in mappings) {
        [aCoder encodeObject:[object valueForKey:mapping.internalKey] forKey:mapping.internalKey];
    }
}

- (void)decodeObject:(id)object withCoder:(NSCoder *)aDecoder {
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
                            child = [self transformObject:child mapping:mapping reverse:YES error:&error];
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
                            child = [self transformObject:child mapping:mapping reverse:YES error:&error];
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
                        child = [self transformObject:child mapping:mapping reverse:YES error:&error];
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
    return [self dictionaryRepresentationOfObject:object forKeys:[self dictionaryRepresentationKeysForClass:[object class]]];
}

@end
