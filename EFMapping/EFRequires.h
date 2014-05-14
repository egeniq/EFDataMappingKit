//
//  EFRequires.h
//  EFDataMappingKit
//
//  Created by Johan Kool on 23/4/2014.
//  Copyright (c) 2014 Egeniq. All rights reserved.
//

/**
 *  Protocol implemented by `EFRequires` and `NSArray` for evaluating values
 */
@protocol EFRequires <NSObject>

/**
 *  Evaluates if values conforms to requirement
 *
 *  @param value Value to evaluate
 *
 *  @return YES if value passes validation, NO otherwise
 */
- (BOOL)evaluateForValue:(id)value;

@end

/**
 *  Block determing wether a value conforms to requirements
 *
 *  @param value The value to evaluate
 *
 *  @return YES is requirement is met, NO otherwise
 */
typedef BOOL (^EFMappingEvaluationBlock)(id value);

/**
 *  Expresses requirements that a value should conform too.
 */
@interface EFRequires : NSObject <EFRequires>

/** @name Existence */
/**
 *  Requires a value exists
 *
 *  @return EFRequire instance
 */
+ (instancetype)exists;

/** @name Custom */
/**
 *  Requires a value passes evaluation
 *
 *  @param evaluationBlock Block evaluating the value
 *
 *  @return `EFRequires` instance
 */
+ (instancetype)passes:(EFMappingEvaluationBlock)evaluationBlock;

/** @name Numbers */
/**
 *  Requires a value is larger than certain treshold
 *
 *  @param value Threshold
 *
 *  @return `EFRequires` instance
 */
+ (instancetype)largerThan:(NSNumber *)value;

/**
 *  Requires a value is larger than or equal to certain treshold
 *
 *  @param value Threshold
 *
 *  @return `EFRequires` instance
 */
+ (instancetype)largerThanOrEqualTo:(NSNumber *)value;

/**
 *  Requires a value is equal to certain treshold
 *
 *  @param value Threshold
 *
 *  @return `EFRequires` instance
 */
+ (instancetype)equalTo:(NSNumber *)value;

/**
 *  Requires a value is smaller than certain treshold
 *
 *  @param value Threshold
 *
 *  @return `EFRequires` instance
 */
+ (instancetype)smallerThan:(NSNumber *)value;

/**
 *  Requires a value is smaller than or equal to certain treshold
 *
 *  @param value Threshold
 *
 *  @return `EFRequires` instance
 */
+ (instancetype)smallerThanOrEqualTo:(NSNumber *)value;

/** @name Logic */
/**
 *  Either or both of the (array of) requirements need to pass
 *
 *  @param requirements1 An `EFRequires` instance, or an `NSArray` of `EFRequires` instances
 *  @param requirements2 An `EFRequires` instance, or an `NSArray` of `EFRequires` instances
 *
 *  @return `EFRequires` instance
 */
+ (instancetype)either:(id <EFRequires>)requirements1 or:(id <EFRequires>)requirements2;

/**
 *  Negates the result of the (array of) requirement(s)
 *
 *  @param requirements An `EFRequires` instance, or an `NSArray` of `EFRequires` instances
 *
 *  @return `EFRequires` instance
 */
+ (instancetype)not:(id <EFRequires>)requirements;

@end

/**
 *  `NSArray` implements the `EFRequires` protocol
 */
@interface NSArray (EFRequires) <EFRequires>

@end
