//
//  NSObject+EFMapping.h
//  EFMapping
//
//  Created by Johan Kool on 20/3/2014.
//  Copyright (c) 2014 Johan Kool. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const EFMappingErrorDomain;
extern NSString * const EFMappingErrorValidationErrorsKey;

typedef NS_ENUM(NSInteger, EFMappingErrorCode) {
    EFMappingInvalidValues = 1,
    EFMappingTransformationError = 2,
    EFMappingUnexpectedClass = 3
};

typedef id (^EFMappingTransformationBlock)(id, BOOL reverse);

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
+ (instancetype)mappingForClass:(Class)internalClass key:(NSString *)key;
+ (instancetype)mappingForClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey;
+ (instancetype)mappingForClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey formatter:(NSFormatter *)formatter;
+ (instancetype)mappingForClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey transformer:(NSValueTransformer *)transformer;
+ (instancetype)mappingForClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey transformationBlock:(EFMappingTransformationBlock)transformationBlock;

#pragma mark - NSArray of classes
+ (instancetype)mappingArrayOfClass:(Class)internalClass key:(NSString *)key;
+ (instancetype)mappingArrayOfClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey;
+ (instancetype)mappingArrayOfClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey formatter:(NSFormatter *)formatter;
+ (instancetype)mappingArrayOfClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey transformer:(NSValueTransformer *)transformer;
+ (instancetype)mappingArrayOfClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey transformationBlock:(EFMappingTransformationBlock)transformationBlock;

#pragma mark - NSDictionary of classes
+ (instancetype)mappingDictionaryOfClass:(Class)internalClass key:(NSString *)key;
+ (instancetype)mappingDictionaryOfClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey;
+ (instancetype)mappingDictionaryOfClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey formatter:(NSFormatter *)formatter;
+ (instancetype)mappingDictionaryOfClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey transformer:(NSValueTransformer *)transformer;
+ (instancetype)mappingDictionaryOfClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey transformationBlock:(EFMappingTransformationBlock)transformationBlock;

#pragma mark - Generic collection of classes
+ (instancetype)mappingCollection:(Class)collectionClass ofClass:(Class)internalClass key:(NSString *)key;
+ (instancetype)mappingCollection:(Class)collectionClass ofClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey;
+ (instancetype)mappingCollection:(Class)collectionClass ofClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey formatter:(NSFormatter *)formatter;
+ (instancetype)mappingCollection:(Class)collectionClass ofClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey transformer:(NSValueTransformer *)transformer;
+ (instancetype)mappingCollection:(Class)collectionClass ofClass:(Class)internalClass externalKey:(NSString *)externalKey internalKey:(NSString *)internalKey transformationBlock:(EFMappingTransformationBlock)transformationBlock;

@end

@interface NSObject (EFMapping)

#pragma mark - Mappings
+ (NSArray *)mappings;

#pragma mark - Validating and applying values
- (BOOL)validateValues:(NSDictionary *)values error:(NSError **)error;
- (BOOL)setValues:(NSDictionary *)values error:(NSError **)error;

#pragma mark - NSCoding support
/**
 * Encodes an instance using mappings
 *
 * @param aCoder The NSCoder object from the -[encodeWithCoder:] method
 */
- (void)encodeUsingMappingsWithCoder:(NSCoder *)aCoder;

/**
 * Decodes an instance using mappings
 *
 * The coding confirms to NSSecureCoding, so you may wish to return 
 * YES from -[ requiresSecureCoding] in your subclass.
 *
 * @param aDecoder The NSCoder object from the -[initWithCoder:] method
 */
- (void)decodeUsingMappingsWithCoder:(NSCoder *)aDecoder;

#pragma mark - Dictionary representation
/**
 * Creates a dictionary representation
 *
 * The dictionary is created using the external keys as defined in the mappings of the class.
 * For classes not returning any mappings, the object is included as is.
 * If a value is nil, or its reverse transformation fails, the key will be set to NSNull.
 *
 * @param keys The keys to include in the dictionary, pass nil to include all
 * @return Dictionary representation of the object
 */
- (id)dictionaryRepresentationForKeys:(NSArray *)keys;

/**
 * Creates a dictionary representation
 *
 * Includes all external keys defined in the mappings of the class.
 *
 * @return Dictionary representation of the object
 */
- (id)dictionaryRepresentation;

@end
