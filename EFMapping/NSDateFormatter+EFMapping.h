//
//  NSDateFormatter+EFMapping.h
//  EFDataMappingKit
//
//  Created by Johan Kool on 1/6/2014.
//  Copyright (c) 2014 Egeniq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (EFMapping)

/**
 *  Returns a date formatter for RFC 3339 date time string (see http://tools.ietf.org/html/rfc3339 ). Note that this does not handle all possible RFC 3339 date time strings, just one of the most common styles: "2014-06-01T09:34:45Z".
 *
 *  @return RFC 3339 Date formatter
 */
+ (NSDateFormatter *)ef_rfc3339DateFormatter;

@end
