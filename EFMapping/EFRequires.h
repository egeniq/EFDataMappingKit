//
//  EFRequires.h
//  MappingKit
//
//  Created by Johan Kool on 23/4/2014.
//  Copyright (c) 2014 Egeniq. All rights reserved.
//

@protocol EFRequires <NSObject>

- (BOOL)evaluateForValue:(id)value;

@end

typedef BOOL (^EFMappingEvaluationBlock)(id value);

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
