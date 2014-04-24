//
//  EFMappingTest.m
//  Spaarspot
//
//  Created by Johan Kool on 23/3/2014.
//  Copyright (c) 2014 Spaarspot. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MappingKit.h"

@interface EFSample : NSObject

@property (nonatomic, copy) NSString *guid;
@property (nonatomic, assign) NSInteger myPoints;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) EFSample *sample;
@property (nonatomic, copy) NSArray *relatedSamples;

@end

@implementation EFSample

+ (NSArray *)mappings {
    static NSArray *mappings = nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    if (!mappings) {
        mappings = @[[EFMapping mappingForClass:[NSString class] externalKey:@"id" internalKey:@"guid"],
                     [EFMapping mappingForNumberWithExternalKey:@"pts_mine" internalKey:@"myPoints"],
                     [EFMapping mappingForClass:[NSDate class] externalKey:@"created_at" internalKey:@"creationDate" formatter:dateFormatter],
                     [EFMapping mappingForClass:[EFSample class] key:@"sample"],
                     [EFMapping mappingForArrayOfClass:[EFSample class] externalKey:@"related_samples" internalKey:@"relatedSamples"],
                     [EFMapping mappingForClass:[NSString class]
                                    externalKey:@"id2"
                                    internalKey:@"guid2"
                                       requires:[EFRequires exists]],
                     [EFMapping mappingForClass:[NSNumber class]
                                    externalKey:@"id3"
                                    internalKey:@"guid3"
                                       requires:@[[EFRequires exists], [EFRequires largerThan:@0], [EFRequires smallerThan:@1000]]],
                     [EFMapping mappingForClass:[NSNumber class]
                                    externalKey:@"id4"
                                    internalKey:@"guid4"
                                       requires:@[[EFRequires exists], [EFRequires either:[EFRequires equalTo:@2000]
                                                                                       or:@[[EFRequires largerThan:@0], [EFRequires smallerThanOrEqualTo:@1000]]]]]
                     ];
    }
    return mappings;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        //       [self decodeUsingMappingsWithCoder:aDecoder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:0 forKey:@"version"];
    //    [self encodeUsingMappingsWithCoder:aCoder];
}

@end

@interface EFMappingTest : XCTestCase {
    EFSample *_sample1;
    EFSample *_sample2;
    NSDictionary *_validDictionary;
    NSDictionary *_invalidDictionary;
}

@end

@implementation EFMappingTest

- (void)setUp {
    [super setUp];

    _sample1 = [[EFSample alloc] init];
    _sample2 = [[EFSample alloc] init];
    _validDictionary = @{@"id": @"1",
                         @"pts_mine": @10,
                         @"created_at": @"2014-04-01",
                         @"sample": @{@"id": @"2", @"pts_mine": @20},
                         @"related_samples": @[@{@"id": @"3", @"pts_mine": @30},
                                               @{@"id": @"4", @"pts_mine": @40}],
                         @"unknown_key": @"foobarbaz"};
    _invalidDictionary = @{@"id": @1,
                           @"pts_mine": @10,
                           @"created_at": @"2014-04-01",
                           @"sample": @{@"id": @"2", @"pts_mine": @20},
                           @"related_samples": @[@{@"id": @"3", @"pts_mine": @30},
                                                 @{@"id": @4, @"pts_mine": @40}]};
}

- (void)tearDown {
    _sample1 = nil;
    _sample2 = nil;
    _validDictionary = nil;
    _invalidDictionary = nil;

    [super tearDown];
}

- (void)testValidatingValues {
//    NSError *error = nil;
//    BOOL valid1 = [_sample1 validateValues:_validDictionary error:&error];
//
//    XCTAssertTrue(valid1, @"Expected values to be valid but found error %@", error);
//
//    BOOL valid2 = [_sample2 validateValues:_invalidDictionary error:&error];
//
//    XCTAssertFalse(valid2, @"Expected values to be invalid but found no error %@", error);
}

- (void)testSettingValues {
    EFMapper *mapper = [[EFMapper alloc] init];
    [mapper registerMappings:@[[EFMapping mappingForClass:[NSString class] externalKey:@"id" internalKey:@"guid" requires:[EFRequires exists]]] forClass:[EFSample class]];

    NSError *error;
    EFSample *sample = [mapper objectOfClass:[EFSample class] withValues:@{@"id": @"1"} error:&error];
    XCTAssertEqualObjects(sample.guid, @"1", @"guid error: %@", EFPrettyMappingError(error));

    EFSample *sample2 = [mapper objectOfClass:[EFSample class] withValues:@{@"id": [NSNull null]} error:&error];
    XCTAssertNil(sample2, @"Expected error for missing guid");
    NSLog(@"%@", EFPrettyMappingError(error));
}

- (void)testTransformingValues {
//    NSError *error = nil;
//    BOOL valid1 = [_sample1 setValues:_validDictionary error:&error];
//
//    XCTAssertTrue(valid1, @"Expected values to be valid but found error %@", error);
//
//    XCTAssertTrue([_sample1.creationDate isKindOfClass:[NSDate class]], @"Expected a date");
//
//    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:_sample1.creationDate];
//    XCTAssertEqual(components.year, 2014, @"Expected year 2014");
//    XCTAssertEqual(components.month, 4, @"Expected month 4");
//    XCTAssertEqual(components.day, 1, @"Expected day 1");
}

- (void)testEncoding {

}

- (void)testEncodingSubclasses {

}

- (void)testCreatingDictionaryRepresentation {
//    [_sample1 setValues:_validDictionary error:NULL];
//    NSDictionary *dictionaryRepresentation = [_sample1 dictionaryRepresentation];
//
//    XCTAssertNotNil(dictionaryRepresentation, @"Expected something");
}

- (void)testRequirements {
    XCTAssertTrue([[EFRequires exists] evaluateForValue:@"bla"], @"Value exist");
    XCTAssertFalse([[EFRequires exists] evaluateForValue:nil], @"Value exist");

    XCTAssertTrue([[EFRequires passes:^BOOL(id value) {
        return YES;
    }] evaluateForValue:@"bla"], @"Value passes");
    XCTAssertFalse([[EFRequires passes:^BOOL(id value) {
        return NO;
    }] evaluateForValue:@"bla"], @"Value passes");

    XCTAssertTrue([[EFRequires largerThan:@2] evaluateForValue:@3], @"Value larger than");
    XCTAssertFalse([[EFRequires largerThan:@2] evaluateForValue:@2], @"Value larger than");
    XCTAssertFalse([[EFRequires largerThan:@2] evaluateForValue:@1], @"Value larger than");

    XCTAssertTrue([[EFRequires largerThanOrEqualTo:@2] evaluateForValue:@3], @"Value larger than or equal to");
    XCTAssertTrue([[EFRequires largerThanOrEqualTo:@2] evaluateForValue:@2], @"Value larger than or equal to");
    XCTAssertFalse([[EFRequires largerThanOrEqualTo:@2] evaluateForValue:@1], @"Value larger than or equal to");

    XCTAssertFalse([[EFRequires equalTo:@2] evaluateForValue:@3], @"Value equal to");
    XCTAssertTrue([[EFRequires equalTo:@2] evaluateForValue:@2], @"Value equal to");
    XCTAssertFalse([[EFRequires equalTo:@2] evaluateForValue:@1], @"Value equal to");

    XCTAssertFalse([[EFRequires smallerThan:@2] evaluateForValue:@3], @"Value smaller than");
    XCTAssertFalse([[EFRequires smallerThan:@2] evaluateForValue:@2], @"Value smaller than");
    XCTAssertTrue([[EFRequires smallerThan:@2] evaluateForValue:@1], @"Value smaller than");

    XCTAssertFalse([[EFRequires smallerThanOrEqualTo:@2] evaluateForValue:@3], @"Value smaller than or equal to");
    XCTAssertTrue([[EFRequires smallerThanOrEqualTo:@2] evaluateForValue:@2], @"Value smaller than or equal to");
    XCTAssertTrue([[EFRequires smallerThanOrEqualTo:@2] evaluateForValue:@1], @"Value smaller than or equal to");

    NSArray *array = @[[EFRequires largerThan:@2], [EFRequires smallerThan:@4]];
    XCTAssertTrue([array evaluateForValue:@3], @"Value inside range");
    XCTAssertFalse([array evaluateForValue:@1], @"Value outside range");

    XCTAssertFalse([[EFRequires not:array] evaluateForValue:@3], @"Value inverted");
    XCTAssertTrue([[EFRequires not:array] evaluateForValue:@1], @"Value inverted");

    XCTAssertTrue([[EFRequires either:array or:[EFRequires equalTo:@10]] evaluateForValue:@3], @"Value or");
    XCTAssertTrue([[EFRequires either:array or:[EFRequires equalTo:@10]] evaluateForValue:@10], @"Value or");
    XCTAssertFalse([[EFRequires either:array or:[EFRequires equalTo:@10]] evaluateForValue:@1], @"Value or");
}

@end
