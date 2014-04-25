//
//  EFRequires.m
//  EFDataMappingKit
//
//  Created by Johan Kool on 23/4/2014.
//  Copyright (c) 2014 Egeniq. All rights reserved.
//

#import "EFRequires.h"

@interface EFRequires ()

@property (nonatomic, copy) EFMappingEvaluationBlock evaluationBlock;

@end

@implementation EFRequires

+ (instancetype)exists {
    EFRequires *requires = [[[self class] alloc] init];
    requires.evaluationBlock = ^BOOL (id value) {
        return (value != nil);
    };
    return requires;
}

+ (instancetype)passes:(EFMappingEvaluationBlock)evaluationBlock {
    EFRequires *requires = [[[self class] alloc] init];
    requires.evaluationBlock = evaluationBlock;
    return requires;
}

+ (instancetype)largerThan:(NSNumber *)compareValue {
    EFRequires *requires = [[[self class] alloc] init];
    requires.evaluationBlock = ^BOOL (id value) {
        return [value compare:compareValue] == NSOrderedDescending;
    };
    return requires;
}

+ (instancetype)largerThanOrEqualTo:(NSNumber *)compareValue {
    EFRequires *requires = [[[self class] alloc] init];
    requires.evaluationBlock = ^BOOL (id value) {
        return [value compare:compareValue] != NSOrderedAscending;
    };
    return requires;
}

+ (instancetype)equalTo:(NSNumber *)compareValue {
    EFRequires *requires = [[[self class] alloc] init];
    requires.evaluationBlock = ^BOOL (id value) {
        return [value compare:compareValue] == NSOrderedSame;
    };
    return requires;
}

+ (instancetype)smallerThan:(NSNumber *)compareValue {
    EFRequires *requires = [[[self class] alloc] init];
    requires.evaluationBlock = ^BOOL (id value) {
        return [value compare:compareValue] == NSOrderedAscending;
    };
    return requires;
}

+ (instancetype)smallerThanOrEqualTo:(NSNumber *)compareValue {
    EFRequires *requires = [[[self class] alloc] init];
    requires.evaluationBlock = ^BOOL (id value) {
        return [value compare:compareValue] != NSOrderedDescending;
    };
    return requires;
}

+ (instancetype)either:(id <EFRequires>)requirements1 or:(id <EFRequires>)requirements2 {
    EFRequires *requires = [[[self class] alloc] init];
    requires.evaluationBlock = ^BOOL (id value) {
        return ([requirements1 evaluateForValue:value] || [requirements2 evaluateForValue:value]);
    };
    return requires;
}

+ (instancetype)not:(id <EFRequires>)requirements {
    EFRequires *requires = [[[self class] alloc] init];
    requires.evaluationBlock = ^BOOL (id value) {
        return ![requirements evaluateForValue:value];
    };
    return requires;
}

- (BOOL)evaluateForValue:(id)value {
    if (!self.evaluationBlock) {
        // This shouldn't happen!
        return YES;
    }
    return self.evaluationBlock(value);
}

@end

@implementation NSArray (EFRequires)

- (BOOL)evaluateForValue:(id)value {
    for (EFRequires *requires in self) {
        if (![requires evaluateForValue:value]) {
            return NO;
        }
    }
    return YES;
}

@end
