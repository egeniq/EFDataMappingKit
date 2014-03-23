//
//  EFMappingTest.m
//  Spaarspot
//
//  Created by Johan Kool on 23/3/2014.
//  Copyright (c) 2014 Spaarspot. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSObject+EFMapping.h"

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
    NSDateFormatter *dateFormatter = nil;
    if (!mappings) {
        mappings = @[[EFMapping mappingForClass:[NSString class] externalKey:@"id" internalKey:@"guid"],
                     [EFMapping mappingForNumberWithExternalKey:@"pts_mine" internalKey:@"myPoints"],
                     [EFMapping mappingForClass:[NSDate class] externalKey:@"created_at" internalKey:@"creationDate" formatter:dateFormatter],
                     [EFMapping mappingForClass:[EFSample class] key:@"sample"],
                     [EFMapping mappingArrayOfClass:[EFSample class] externalKey:@"related_samples" internalKey:@"relatedSamples"]
                     ];
    }
    return mappings;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        [self decodeUsingMappingsWithCoder:aDecoder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:0 forKey:@"version"];
    [self encodeUsingMappingsWithCoder:aCoder];
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
                         @"created_at": [NSDate date],
                         @"sample": @{@"id": @"2", @"pts_mine": @20},
                         @"related_samples": @[@{@"id": @"3", @"pts_mine": @30},
                                               @{@"id": @"4", @"pts_mine": @40}],
                         @"unknown_key": @"foobarbaz"};
    _invalidDictionary = @{@"id": @1,
                           @"pts_mine": @10,
                           @"created_at": [NSDate date],
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
    NSError *error = nil;
    BOOL valid1 = [_sample1 validateValues:_validDictionary error:&error];

    XCTAssertTrue(valid1, @"Expected values to be valid but found error %@", error);

    BOOL valid2 = [_sample2 validateValues:_invalidDictionary error:&error];

    XCTAssertFalse(valid2, @"Expected values to be invalid but found no error %@", error);
}

- (void)testSettingValues {
    [_sample1 setValues:_validDictionary error:NULL];

    XCTAssertEqualObjects(_sample1.guid, @"1", @"guid");
    XCTAssertEqual(_sample1.myPoints, 10, @"Expected points");
    XCTAssertEqual([_sample1.relatedSamples count], 2, @"Expected 2 related samples");

}

- (void)testTransformingValues {

}

- (void)testEncoding {

}

- (void)testEncodingSubclasses {

}

- (void)testCreatingDictionaryRepresentation {
    [_sample1 setValues:_validDictionary error:NULL];
    NSDictionary *dictionaryRepresentation = [_sample1 dictionaryRepresentation];

    XCTAssertNotNil(dictionaryRepresentation, @"Expected something");
}

@end
