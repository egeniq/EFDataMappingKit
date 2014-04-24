//
//  EFMapper.h
//  MappingKit
//
//  Created by Johan Kool on 23/4/2014.
//  Copyright (c) 2014 Egeniq. All rights reserved.
//

#import "MappingKit.h"

typedef id (^EFMappingInitializerBlock)(Class aClass, NSDictionary *values);

@interface EFMapper : NSObject

- (void)registerMappings:(NSArray *)mappings forClass:(Class)aClass;
- (void)registerInitializer:(EFMappingInitializerBlock)initializerBlock forClass:(Class)aClass;
- (BOOL)validateValues:(NSDictionary *)values forClass:(Class)aClass error:(NSError **)error;
- (BOOL)setValues:(NSDictionary *)values onObject:(id)object error:(NSError **)error;
- (id)objectOfClass:(Class)aClass withValues:(NSDictionary *)values error:(NSError **)error;

- (void)encodeObject:(id)object withCoder:(NSCoder *)aCoder;
- (void)decodeObject:(id)object withCoder:(NSCoder *)aDecoder;

- (id)copyObject:(id)object deepCopy:(BOOL)deepCopy;

- (void)registerDictionaryRepresentationKeys:(NSArray *)keys forClass:(Class)aClass;
- (id)dictionaryRepresentationOfObject:(id)object forKeys:(NSArray *)keys;
- (id)dictionaryRepresentationOfObject:(id)object;

@end
