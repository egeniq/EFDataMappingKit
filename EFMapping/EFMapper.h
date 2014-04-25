//
//  EFMapper.h
//  EFDataMappingKit
//
//  Created by Johan Kool on 23/4/2014.
//  Copyright (c) 2014 Egeniq. All rights reserved.
//

/**
 *  Block called when the mapper needs to instantiate a class
 *
 *  Note that the initializer may be called for subclasses of the class under which you registered it too!
 *
 *  @param aClass Requested class
 *  @param values Values to be applied to the instance
 *
 *  @return A class instance
 */
typedef id (^EFMappingInitializerBlock)(Class aClass, NSDictionary *values);

/**
 *  EFMapper maps data such as those coming from JSON onto an instance using mappings. The mappings are also used to simplify implementing the NSCoding protocol for a class, and to create a dictionary representation of an instance.
 */
@interface EFMapper : NSObject

#pragma mark - Singleton

/**
 *  Convenience singleton
 *
 *  You don't have to use EFMapper as a singleton, but it can often be convenient.
 *
 *  @return A EFMapper instance
 */
+ (instancetype)sharedInstance;

#pragma mark - Mappings

/**
 *  Mappings to be used for setting values on instances of a class
 *
 *  Mappings are also used for subclasses of the class, unless more specific mappings for that subclass are registered.
 *
 *  @param mappings Array of EFMapping instances
 *  @param aClass   Class for which the mappings should be used
 */
- (void)registerMappings:(NSArray *)mappings forClass:(Class)aClass;

#pragma mark - Initializers

/**
 *  Register initializer to be called when the mapper needs to instantiate a class
 *
 *  The initializer is also used for subclasses of the class, unless a more initializer mappings for that subclass is registered. If no initializer is registed, alloc and init will be called on the class.
 *
 *  @param initializerBlock Block returning class instance
 *  @param aClass           Class for which the initializer should be used
 */
- (void)registerInitializer:(EFMappingInitializerBlock)initializerBlock forClass:(Class)aClass;

#pragma mark - Validating and applying values

/**
 *  Validate values to be applied to an instance of a class
 *
 *  Verifies wether the values in a dictionary can be successfully applied on the instance of a class using its mappings. This basically means that values get checked on wether they are of the right type.
 *
 *  @param values The values to be validated
 *  @param aClass Class of object
 *  @param error  Error when invalid values are encountered
 *
 *  @return YES if all values are valid, NO otherwise
 */
- (BOOL)validateValues:(NSDictionary *)values forClass:(Class)aClass error:(NSError **)error;

/**
 *  Validate values to be applied to an instance
 *
 *  Verifies wether the values in a dictionary can be successfully applied on the instance of a class using its mappings. This basically means that values get checked on wether they are of the right type. In this method instances also get a chance to validate a value using the standard KVO validation. To use this implement -[validate<Key>:error:] method in your class.
 *
 *  @param values   The values to be validated
 *  @param onObject The object
 *  @param error    Error when invalid values are encountered
 *
 *  @return YES if all values are valid, NO otherwise
 */
- (BOOL)validateValues:(NSDictionary *)values onObject:(id)object error:(NSError **)error;

/**
 *  Apply values to an instance
 *
 *  First validates the values, and if all are found to be valid applies them on the instance of a class using its mappings.
 *
 *  @param values The values to be applied
 *  @param object The object
 *  @param error  Error when invalid values are encountered
 *
 *  @return YES if all values are valid, NO otherwise
 */
- (BOOL)setValues:(NSDictionary *)values onObject:(id)object error:(NSError **)error;

/**
 *  Initializes an object and applies values
 *
 *  @param aClass Class of object
 *  @param values The values to be applied
 *  @param error  Error when invalid values are encountered
 *
 *  @return New object if all values are valid, nil otherwise
 */
- (id)objectOfClass:(Class)aClass withValues:(NSDictionary *)values error:(NSError **)error;

#pragma mark - NSCoding support

/**
 *  Encodes an instance using mappings
 *
 *  @param object The object
 *  @param aCoder The NSCoder object from the -[encodeWithCoder:] method
 */
- (void)encodeObject:(id)object withCoder:(NSCoder *)aCoder;

/**
 *  Decodes an instance using mappings
 *
 *  The coding confirms to NSSecureCoding, so you may wish to return YES from -[ requiresSecureCoding] in your subclass.
 *
 *  @param object   The object
 *  @param aDecoder The NSCoder object from the -[initWithCoder:] method
 */
- (void)decodeObject:(id)object withCoder:(NSCoder *)aDecoder;

#pragma mark - Dictionary representation

/**
 *  Registers the keys that should be included in a dictionary representation
 *
 *  By default all external keys defined in the mappings for the class are included.
 *
 *  @param keys     Array of NSString keys
 *  @param aClass   Class of object
 */
- (void)registerDictionaryRepresentationKeys:(NSArray *)keys forClass:(Class)aClass;

/**
 *  Creates a dictionary representation
 *
 *  The dictionary is created using the passed in array of keys. For classes without any mappings, the object is included as is. If a value is nil, or its reverse transformation fails, the key will be set to NSNull.
 *
 *  @param object   The object
 *  @param keys     The keys to include in the dictionary, pass nil to include all
 *
 *  @return Dictionary representation of the object
 */
- (id)dictionaryRepresentationOfObject:(id)object forKeys:(NSArray *)keys;

/**
 *  Creates a dictionary representation
 *
 *  The dictionary is created using the external keys as registered with the mapper, or if none registered those registered for the mappings of the class. For classes without any mappings, the object is included as is. If a value is nil, or its reverse transformation fails, the key will be set to NSNull.
 *
 *  @return Dictionary representation of the object
 */
- (id)dictionaryRepresentationOfObject:(id)object;

@end
