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
 *  <#Description#>
 *
 *  @param value   <#value description#>
 *  @param mapping <#mapping description#>
 *  @param reverse <#reverse description#>
 *  @param error   <#error description#>
 *
 *  @return <#return value description#>
 */
- (id)transformValue:(id)value mapping:(EFMapping *)mapping reverse:(BOOL)reverse error:(NSError **)error;

/**
 *  <#Description#>
 *
 *  @param value        <#value description#>
 *  @param isCollection <#isCollection description#>
 *  @param mapping      <#mapping description#>
 *  @param error        <#error description#>
 *
 *  @return <#return value description#>
 */
- (BOOL)validateValue:(id)value isCollection:(BOOL)isCollection mapping:(EFMapping *)mapping error:(NSError **)error;

/**
 *  <#Description#>
 *
 *  @param value        <#value description#>
 *  @param object       <#object description#>
 *  @param isCollection <#isCollection description#>
 *  @param mapping      <#mapping description#>
 */
- (void)setValue:(id)value onObject:(id)object isCollection:(BOOL)isCollection mapping:(EFMapping *)mapping;

@end
