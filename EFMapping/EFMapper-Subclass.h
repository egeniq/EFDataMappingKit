//
//  EFMapper-Subclass.h
//  EFDataMappingKit
//
//  Created by Johan Kool on 25/4/2014.
//  Copyright (c) 2014 Egeniq. All rights reserved.
//

#import "EFMapper.h"

@class EFMapping;

/**
 *  Override these methods when implementing custom `EFMapper` subclasses.
 */
@interface EFMapper ()

/**
 *  Transforms (if needed) any incoming value
 *
 *  @param value   Incoming value
 *  @param mapping `EFMapping` instance
 *  @param reverse Perform any transformation in reverse
 *  @param error   On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify `nil` for this parameter if you do not want the error information.
 *
 *  @return Transformed value or nil if error occurred
 */
- (id)transformValue:(id)value mapping:(EFMapping *)mapping reverse:(BOOL)reverse error:(NSError **)error;

/**
 *  Validates an incoming value
 *
 *  @param value        Incoming transformed value
 *  @param isCollection Indicates wether the incoming value is a collection
 *  @param mapping      `EFMapping` instance
 *  @param error        On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify `nil` for this parameter if you do not want the error information.
 *
 *  @return YES if value is valid, otherwise NO
 */
- (BOOL)validateValue:(id)value isCollection:(BOOL)isCollection mapping:(EFMapping *)mapping error:(NSError **)error;

/**
 *  Applies incoming value to an object
 *
 *  @param value        Incoming transformed and validated value
 *  @param object       Object on which the value should be set
 *  @param isCollection Indicates wether the incoming value is a collection
 *  @param mapping      `EFMapping` instance
 */
- (void)setValue:(id)value onObject:(id)object isCollection:(BOOL)isCollection mapping:(EFMapping *)mapping;

@end
