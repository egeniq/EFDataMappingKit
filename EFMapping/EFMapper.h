//
//  EFMapper.h
//  MappingKit
//
//  Created by Johan Kool on 23/4/2014.
//  Copyright (c) 2014 Egeniq. All rights reserved.
//

#import "MappingKit.h"

typedef id (^EFMappingInitializerBlock)(Class aClass, NSDictionary *values);

/**
 *  Category on NSObject that maps data such as those coming from JSON onto an instance using mappings. The mappings are also used to simplify implementing the NSCoding protocol for a class, and to create a dictionary representation of an instance.
 */
@interface EFMapper : NSObject

#pragma mark - Mappings
/**
 *  Mappings to be used for setting values on instances of this class
 *
 *  Default implementation returns nil.
 *
 *  @return Array of EFMapping instances
 */
- (void)registerMappings:(NSArray *)mappings forClass:(Class)aClass;
- (void)registerInitializer:(EFMappingInitializerBlock)initializerBlock forClass:(Class)aClass;


#pragma mark - Validating and applying values
/**
 *  Validate values to be applied to instance
 *
 *  Verifies wether the values in a dictionary can be successfully applied on the instance of a class using its mappings. This basically means that values get checked on wether they are of the right type. Instances get a chance to validate a value using the standard KVO validation. To use this implement -[validate<Key>:error:] method in your class.
 *
 *  @param values The values to be validated
 *  @param error  Error when invalid values are encountered
 *
 *  @return YES if all values are valid, NO otherwise
 */
- (BOOL)validateValues:(NSDictionary *)values forClass:(Class)aClass error:(NSError **)error;

/**
 *  Apply values to instance
 *
 *  First validates the values, and if all are found to be valid applies them on the instance of a class using its mappings.
 *
 *  @param values The values to be applied
 *  @param error  Error when invalid values are encountered
 *
 *  @return YES if all values are valid, NO otherwise
 */
- (BOOL)setValues:(NSDictionary *)values onObject:(id)object error:(NSError **)error;
- (id)objectOfClass:(Class)aClass withValues:(NSDictionary *)values error:(NSError **)error;

#pragma mark - NSCoding support
/**
 *  Encodes an instance using mappings
 *
 *  @param aCoder The NSCoder object from the -[encodeWithCoder:] method
 */
- (void)encodeObject:(id)object withCoder:(NSCoder *)aCoder;

/**
 *  Decodes an instance using mappings
 *
 *  The coding confirms to NSSecureCoding, so you may wish to return YES from -[ requiresSecureCoding] in your subclass.
 *
 *  @param aDecoder The NSCoder object from the -[initWithCoder:] method
 */
- (void)decodeObject:(id)object withCoder:(NSCoder *)aDecoder;

// Feature idea
//- (id)copyObject:(id)object deepCopy:(BOOL)deepCopy;

#pragma mark - Dictionary representation

/**
 *  The keys that should be included in a dictionary representation
 *
 *  By default returns nil, which means that all external keys defined in the mappings of the class are included.
 *
 *  @return Array of NSString keys
 */
- (void)registerDictionaryRepresentationKeys:(NSArray *)keys forClass:(Class)aClass;

/**
 *  Creates a dictionary representation
 *
 *  The dictionary is created using the passed in array of keys. For classes not returning any mappings, the object is included as is. If a value is nil, or its reverse transformation fails, the key will be set to NSNull.
 *
 *  @param keys The keys to include in the dictionary, pass nil to include all
 *
 *  @return Dictionary representation of the object
 */
- (id)dictionaryRepresentationOfObject:(id)object forKeys:(NSArray *)keys;

/**
 *  Creates a dictionary representation
 *
 *  The dictionary is created using the external keys as returned by +[dictionaryRepresentationKeys], or if that method returns nil those defined in the mappings of the class. For classes not returning any mappings, the object is included as is. If a value is nil, or its reverse transformation fails, the key will be set to NSNull.
 *
 *  @return Dictionary representation of the object
 */
- (id)dictionaryRepresentationOfObject:(id)object;

@end
