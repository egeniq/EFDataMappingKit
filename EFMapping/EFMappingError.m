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

NSString* EFPrettyMappingError(NSError *error) {
    if ([error.domain isEqualToString:EFMappingErrorDomain]) {
        NSMutableString *string = [NSMutableString string];
        if (error.code == EFMappingInvalidValues) {
            [string appendFormat:@"%@:", error.userInfo[NSLocalizedDescriptionKey]];
            id errors = error.userInfo[EFMappingErrorValidationErrorsKey];
            if ([errors isKindOfClass:[NSArray class]]) {
                [errors enumerateObjectsUsingBlock:^(NSError *subError, NSUInteger idx, BOOL *stop) {
                    [string appendFormat:@"\n\t- %lu: %@", (unsigned long)idx, subError.userInfo[NSLocalizedDescriptionKey]];
                }];
            } else if ([errors isKindOfClass:[NSDictionary class]]) {
                [errors enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSError *subError, BOOL *stop) {
                    [string appendFormat:@"\n\t- %@: %@", key, subError.userInfo[NSLocalizedDescriptionKey]];
                }];
            }
        } else {
            // Do some recursive stuff here!
        }
        [string appendString:@"\n"];
        return string;
    } else {
        return [error description];
    }
}