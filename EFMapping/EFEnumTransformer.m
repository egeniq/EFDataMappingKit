//
//  EFEnumTransformer.m
//  EFDataMappingKit
//
//  Created by Johan Kool on 2/6/2014.
//  Copyright (c) 2014 Egeniq. All rights reserved.
//

#import "EFEnumTransformer.h"

@implementation EFEnumTransformer

+ (instancetype)transformerWithEnumMapping:(NSDictionary *)enumMapping {
    return [[[self class] alloc] initWithEnumMapping:enumMapping];
}

- (id)initWithEnumMapping:(NSDictionary *)enumMapping {
    self = [super init];
    if (self) {
        _enumMapping = enumMapping;
    }
    return self;
}

+ (Class)transformedValueClass {
    return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)transformedValue:(id)value {
    return @([[[self.enumMapping allKeysForObject:value] firstObject] integerValue]);
}

- (id)reverseTransformedValue:(id)value {
    return self.enumMapping[value];
}

@end
