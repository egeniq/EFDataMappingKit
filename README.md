EFDataMappingKit
================
Mapping data from an API to a database. Serializing objects to persistent storage. In most data heavy applications we are constantly converting from one type of data to another. 

REST apis are beautiful and easily parsed, but even with pure REST apis there is hardly ever a clean 1-on-1 mapping between what you get from the server and what you process inside the app.

We've been using some simple mapping mechanisms that allow us to easily and declaratively map data from one format to another. 

We'll have to add some getting started documentation and it's far from ready, but we thought we'd share it anyway because it may benefit others.


Adding EFDataMappingKit to your project
=======================================
EFDataMappingKit has a Podspec available, so if you use CocoaPods add
```
pod 'EFDataMappingKit'
```
to your Podfile.


Documentation
=============

Documentation is available [here](http://egeniq.github.io/EFDataMappingKit/).


Code Generator
==============

Still in early development, but a nice little code generator is available [here](http://egeniq.github.io/EFDataMappingKit/generator/). It takes your JSON and creates basic mappings for you.


Using EFDataMappingKit
======================

Let's take this example of JSON describing a user:

```json
{
    "user_id": 42,
    "username": "john.doe",
    "messages": [
        {
            "message_id": 1,
            "published_at": "2014-02-13",
            "read": true,
            "text": "FYI, tomorrow night I am hanging out with the guys!"
        },
        {
            "message_id": 2,
            "published_at": "2014-02-14",
            "read": false,
            "text": "Just kidding, romantic dinner by candle light awaits you!"
        },
        {
            "message_id": 3,
            "published_at": "2014-02-15",
            "read": false,
            "text": "Darling?!"
        }
    ],
    "website": "http://www.example.com"
}

```

and map it to our `MYUser` and `MYMessage` objects which have these interfaces:

```objective-c
@interface MYUser : NSObject

@property (nonatomic, assign) NSUInteger userId;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, strong) NSURL *website;

@end
```

```objective-c
@interface MYMessage : NSObject

@property (nonatomic, assign) NSUInteger messageId;
@property (nonatomic, strong) NSDate *publicationDate;
@property (nonatomic, assign) BOOL read;
@property (nonatomic, copy) NSString *text;

@end
```

Step 1. Create a mapper
-----------------------
You can use the shared instance:

```objective-c
EFMapper *mapper = [EFMapper sharedInstance];
```

but you don't have too:

```objective-c
EFMapper *mapper = [[EFMapper alloc] init];
```

Step 2. Define mappings
-----------------------
A mapping describes how a value retrieved from an external source should be mapped on an internal entity.

For each mapping you need to specify at least the `externalKey` and `internalKey` (or use `key` to set both the same) and you need to specify what kind of value you expect. For primitives such as `BOOL`, `int`, `CGFloat` use `NSNumber`.

We recommend creating a category on your entity class and adding `+ mappings` method there.

In `MYUser (Mappings)` implementation:

```objective-c
+ (NSArray *)mappings {
    return @[
        [EFMapping mapping:^(EFMapping *m) {
            m.internalClass = [NSNumber class];
            m.externalKey = @"user_id";
            m.internalKey = @"userId";
            m.requires = [EFRequires exists];
        }],
        [EFMapping mapping:^(EFMapping *m) {
            m.internalClass = [NSString class];
            m.key = @"username";
            m.requires = [EFRequires exists];
        }],
        [EFMapping mappingForArray:^(EFMapping *m) {
            m.internalClass = [MYMessage class];
            m.key = @"messages";
        }],
        [EFMapping mapping:^(EFMapping *m) {
            m.internalClass = [NSURL class];
            m.key = @"website";
            m.transformationBlock = ^id(id value, BOOL reverse) {
                if (reverse) {
                    return [(NSURL *)value absoluteString];
                } else {
                    return [NSURL URLWithString:(NSString *)value];
                }
            }; 
        }]
    ];
}
```

In `MYMessage (Mappings)` implementation:

```objective-c
+ (NSArray *)mappings {
    return @[
        [EFMapping mapping:^(EFMapping *m) {
            m.internalClass = [NSNumber class];
            m.externalKey = @"message_id";
            m.internalKey = @"messageId";
            m.requires = [EFRequires exists];
        }],
        [EFMapping mapping:^(EFMapping *m) {
            m.internalClass = [NSDate class];
            m.externalKey = @"published_at";
            m.internalKey = @"pulicationDate";
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            m.formatter = dateFormatter;
        }],
        [EFMapping mappingForNumberWithKey:@"read"],
        [EFMapping mappingForStringWithKey:@"text"]
    ];
}
```

Use `formatter`, `transformer` and `transformBlock` if you need make some changes to a value. This works great with `NSDateFormatter` for dates. You can further declare your requirements for the value by setting one or more `EFRequires` on the `requires` property.


Step 3. Register mappings
-------------------------

You register an array of `EFMapping` objects for each entity class.

```objective-c
EFMapper *mapper = [EFMapper sharedInstance];

[mapper registerMappings:[MYUser mappings] forClass:[MYUser class]];
[mapper registerMappings:[MYMessage mappings] forClass:[MYMessage class]];
```

Step 4. Apply values
--------------------
You apply your values either to an already existing instance or you can ask for a new object to be initialized. Before applying the values, the mapper will validate the values and let you know about any issues.

To apply to an existing object:

```objective-c
EFMapper *mapper = [EFMapper sharedInstance];
NSDictionary *incomingValues = ...;
MYUser *existingObject = ...;
NSError *error;

if (![mapper setValues:incomingValues onObject:existingObject error:&error]) {
    NSLog(@"Could not set values due to error: %@", EFPrettyMappingError(error));
}
```

To create a new object:

```objective-c
EFMapper *mapper = [EFMapper sharedInstance];
NSDictionary *incomingValues = ...;
NSError *error;

MYUser *newObject = [mapper objectOfClass:[MYUser class] withValues:incomingValues error:&error]);
if (!newObject) {
    NSLog(@"Could not create new object due to error: %@", EFPrettyMappingError(error));
}
```


Advanced mappings
=================

Transforming values
-------------------
Use `formatter`, `transformer` and `transformBlock` if you need make some changes to a value. This works great with `NSDateFormatter` for dates.

Value requirements
------------------
On the requires property of a mapping you can either set one `EFRequires` instances, or an array of `EFRequires` instances. All `EFRequires` should pass for a value to be considered. You can create more complex requirements using `+[EFRequires either:or:]` and `+[EFRequires not:]`.

Collections
-----------
An array or dictionary with values.

Register initializers
---------------------
Registering initializers is optional. If no initializer is specified an object is created by calling `alloc` and `init` on it. It is also valid to return an existing object if you wish to avoid having multiple instances of the same entity. Beware of introducing retain loops if you take this approach.

```objective-c
EFMapper *mapper = [[EFMapper alloc] init];
[mapper registerInitializer:^id(__unsafe_unretained Class aClass, NSDictionary *values) {
    NSString *username = values[@"user_name"];
    return [[aClass alloc] initWithUsername:username];
} forClass:[MYUser class]];
```

Register custom mappers
-----------------------
In some cases you may have special needs for a specific class. You can register custom mappers 


Other
=====
EFDataMappingKit can do a few more things to make use of the mappings.

NSCoding support
----------------
You can use the mappings also to quickly add the `NSCoding` protocol to your objects.

```objective-c
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        [[EFMapper sharedInstance] decodeObject:self withCoder:aDecoder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:0 forKey:@"version"];
    [[EFMapper sharedInstance] encodeObject:self withCoder:aCoder];
}
```

These methods should only be called once during the encoding and decoding processes, so if the super class of your object already calls the encoding and decoding methods of `EFMapper`, don't call them again in your subclass.

Dictionary representation
-------------------------
You can turn your entity back into a dictionary/JSON representation.

```objective-c
EFMapper *mapper = [EFMapper sharedInstance];
MYUser *userObject = ...;
NSDictionary *userDictionaryRepresentation = [mapper dictionaryRepresentationOfObject:userObject];
```

By default all keys are returned, though you can limit these to a subset using `-[EFMapper registerDictionaryRepresentationKeys:forClass:]`.
