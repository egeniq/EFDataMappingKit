//
//  EFMappingError.m
//  EFDataMappingKit
//
//  Created by Johan Kool on 23/4/2014.
//  Copyright (c) 2014 Egeniq. All rights reserved.
//

#import "EFMappingError.h"

NSString * const EFMappingErrorDomain = @"EFMappingErrorDomain";
NSString * const EFMappingErrorValidationErrorsKey = @"validationErrors";

NSString* EFPrettyMappingErrorWithIndentation(NSError *error, NSUInteger indentationLevel) {
    if ([error.domain isEqualToString:EFMappingErrorDomain]) {
        NSMutableString *string = [NSMutableString string];
        [string appendString:error.userInfo[NSLocalizedDescriptionKey]];
        id errors = error.userInfo[EFMappingErrorValidationErrorsKey];
        NSString *tabs = [@"\n" stringByPaddingToLength:indentationLevel + 2 withString:@"\t" startingAtIndex:0];
        if ([errors isKindOfClass:[NSArray class]]) {
            [string appendString:@":"];
            [errors enumerateObjectsUsingBlock:^(NSError *subError, NSUInteger idx, BOOL *stop) {
                [string appendFormat:@"%@%lu: %@", tabs, (unsigned long)idx, EFPrettyMappingErrorWithIndentation(subError, indentationLevel + 1)];
            }];
        } else if ([errors isKindOfClass:[NSDictionary class]]) {
            [string appendString:@":"];
            [errors enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSError *subError, BOOL *stop) {
                [string appendFormat:@"%@%@: %@", tabs, key, EFPrettyMappingErrorWithIndentation(subError, indentationLevel + 1)];
            }];
        }
        return string;
    } else {
        return [error description];
    }
}

NSString* EFPrettyMappingError(NSError *error) {
    return EFPrettyMappingErrorWithIndentation(error, 0);
}