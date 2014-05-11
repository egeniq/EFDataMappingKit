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

+ (instancetype)exists;
+ (instancetype)passes:(EFMappingEvaluationBlock)evaluationBlock;
+ (instancetype)largerThan:(NSNumber *)value;
+ (instancetype)largerThanOrEqualTo:(NSNumber *)value;
+ (instancetype)equalTo:(NSNumber *)value;
+ (instancetype)smallerThan:(NSNumber *)value;
+ (instancetype)smallerThanOrEqualTo:(NSNumber *)value;
+ (instancetype)either:(id <EFRequires>)requirements1 or:(id <EFRequires>)requirements2;
+ (instancetype)not:(id <EFRequires>)requirements;

@end

@interface NSArray (EFRequires) <EFRequires>

@end
