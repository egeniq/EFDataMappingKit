//
//  NSDateFormatter+EFMapping.m
//  EFDataMappingKit
//
//  Created by Johan Kool on 1/6/2014.
//  Copyright (c) 2014 Egeniq. All rights reserved.
//

#import "NSDateFormatter+EFMapping.h"

@implementation NSDateFormatter (EFMapping)

+ (NSDateFormatter *)ef_rfc3339DateFormatter {
    NSDateFormatter *rfc3339DateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];

    [rfc3339DateFormatter setLocale:enUSPOSIXLocale];
    [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

    return rfc3339DateFormatter;
}

@end
