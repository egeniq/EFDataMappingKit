//
//  EFRequires.h
//  EFDataMappingKit
//
//  Created by Johan Kool on 23/4/2014.
//  Copyright (c) 2014 Egeniq. All rights reserved.
//

@protocol EFRequires <NSObject>

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
 *  Expresses requirements that a value should confirm too.
 */
@interface EFRequires : NSObject <EFRequires>

/** @name Existence */
/**
 *  <#Description#>
 *
 *  @return EFRequire instance
 */
+ (instancetype)exists;

/** @name Custom */
/**
 *  <#Description#>
 *
 *  @param evaluationBlock <#evaluationBlock description#>
 *
 *  @return `EFRequires` instance
 */
+ (instancetype)passes:(EFMappingEvaluationBlock)evaluationBlock;

/** @name Numbers */
/**
 *  <#Description#>
 *
 *  @param value <#value description#>
 *
 *  @return `EFRequires` instance
 */
+ (instancetype)largerThan:(NSNumber *)value;

/**
 *  <#Description#>
 *
 *  @param value <#value description#>
 *
 *  @return `EFRequires` instance
 */
+ (instancetype)largerThanOrEqualTo:(NSNumber *)value;

/**
 *  <#Description#>
 *
 *  @param value <#value description#>
 *
 *  @return `EFRequires` instance
 */
+ (instancetype)equalTo:(NSNumber *)value;

/**
 *  <#Description#>
 *
 *  @param value <#value description#>
 *
 *  @return `EFRequires` instance
 */
+ (instancetype)smallerThan:(NSNumber *)value;

/**
 *  <#Description#>
 *
 *  @param value <#value description#>
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

@interface NSArray (EFRequires) <EFRequires>

@end
