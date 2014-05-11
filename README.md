EFDataMappingKit
================
Mapping data from an API to a database. Serializing objects to persistent storage. In most data heavy applications we are constantly converting from one type of data to another. 

REST apis are beautiful and easily parsed, but even with pure REST apis there is hardly ever a clean 1 on 1 mapping between what you get from the server and what you process inside the app.

We've been using some simple mapping mechanisms that allow us to easily and declaratively map data from one format to another. 

We'll have to add some getting started documentation and it's far from ready, but we thought we'd share it anyway because it may benefit others.

Adding EFDataMappingKit to your project
=======================================
EFDataMappingKit has a Podspec available, so if you use CocoaPods add

   pod 'EFDataMappingKit'

to your Podfile.


Using EFDataMappingKit
======================

Step 1. Creating an EFMapper
----------------------------
You can use the shared instance, but you don't have too.

Step 2. Register mappings
-------------------------
You register an array of EFMapping objects for each entity class.

An mapping describes how a value retrieved from an external source should be mapped on an internal entity.

For each mapping you need to specify at least the externalKey and internalKey (or use key to set both the same) and you need to specify what kind of value you expect. For primitives such as BOOL, int, CGFloat use NSNumber.

Use formatter, transformer and transformBlock if you need make some changes to a value. This works great with NSDateFormatter for dates. 

You can further declare your requirements for the value by setting one or more EFRequires on the requires property.

Step 3. Register initializers
----------------------------
This step is optional. If no initializer is specified an object is created by calling alloc and init on it.

Step 4. Applying values
-----------------------
You apply your values either to an already existing instance, or you can ask for a new object to be initialized. Before applying the values, the mapper will validate the values and let you know about any issues.

Advanced mappings
=================

Transforming values
-------------------


Value requirements
------------------
On the requires property of a mapping you can either set one EFRequires instances, or an array of EFRequires instances. All EFRequires should pass for a value to be considered. You can create more complex requirements using [EFRequires either:or:] and [EFRequires not:].

Collections
-----------
An array or dictionary with values.


Other
=====
EFDataMappingKit can do a few more things to make use of the mappings.

NSCoding support
----------------
Implement the NSCoding protocol.

Dictionary representation
-------------------------
You can turn your entity back into a dictionary/JSON representation.