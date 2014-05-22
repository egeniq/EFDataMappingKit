//!Helper functions on String
if (typeof String.prototype.toCamel !== 'function') {
    String.prototype.toCamel = function(){
        return this.replace(/[-_ ]([a-z])/g, function (g) { return g[1].toUpperCase(); });
    };
}

if (typeof String.prototype.toSingular !== 'function') {
    String.prototype.toSingular = function(){
        return singularize(this); // => "word"
    };
}

if (typeof String.prototype.toIvarName !== 'function') {
    String.prototype.toIvarName = function(){
        return this.toCamel();
    };
}

if (typeof String.prototype.toClassName !== 'function') {
    String.prototype.toClassName = function(prefix){
        return this.toCamel().addPrefix(prefix);
    };
}

if (typeof String.prototype.addPrefix !== 'function') {
    String.prototype.addPrefix = function(prefix){
        return prefix + this.substring(0, 1).toUpperCase() + this.substring(1);
    };
}

if (typeof String.prototype.format !== 'function') {
    String.prototype.format = function() {
        var str = this.toString();
        if (!arguments.length)
            return str;
        var args = typeof arguments[0],
            args = (("string" == args || "number" == args) ? arguments : arguments[0]);
        for (arg in args)
            str = str.replace(RegExp("\\{" + arg + "\\}", "gi"), args[arg]);
        return str;
    }
}

//!Global variable
var zip = null;

//!Main entry functions
function generate() {
    // Clear previous output
    $('div#output').html('<div class="output"></div>');
    
    // Gather input
    try {
        var input = $("#inputJSON").val();
        var json = $.parseJSON(input);
    }
    catch (exception) {
        showError(exception);
        return;
    }
    
    var prefix = $("#inputPrefix").val();
    var project = $("#inputProject").val();
    var root = $("#inputRoot").val();
    if (root == "") {
        root = "root";
    }
    var today = new Date;
    var date = today.getDate() + "/" + (today.getMonth() + 1) +"/" + today.getFullYear();
    var year = today.getFullYear();
    var user = $("#inputUser").val();
    
    // Create class descriptions
    var classDescriptions = new Object;
    if (containsObject(json)) {
        var camelKey = root.toClassName(prefix);
        classDescription(classDescriptions, prefix, camelKey, json);
    } else {
        showError("Expected a dictionary as root");
        return;
    }
     
    // Create files
    var files = new Object;
    files[prefix + "Mapper.h"] = interfaceMapper(prefix, project, date, year, user);
    files[prefix + "Mapper.m"] = implementationMapperForClassDescriptions(classDescriptions, prefix, project, date, year, user);
    for (var key in classDescriptions) {
        addFilesForClassDescription(files, classDescriptions[key], project, date, year, user);
    }
    
    // Create zip
    zip = new JSZip();
    for (var key in files) {
        zip.file(key, files[key]);
    }
    
    // Create HTML output
    var filePanels = "";
    for (var key in files) {
        filePanels += "<div class=\"panel panel-default\">\
    <div class=\"panel-heading\">\
      <h4 class=\"panel-title\">\
        <a data-toggle=\"collapse\" data-parent=\"#accordion\" href=\"#collapse"+ key.replace(/[\.+]/g, "") +"\">\
          <span class=\"glyphicon glyphicon-file\"></span> " + key + "\
        </a>\
      </h4>\
    </div>\
    <div id=\"collapse"+key.replace(/[\.+]/g, "")+"\" class=\"panel-collapse collapse\">\
      <div class=\"panel-body\"><pre><code languages=\"objectivec\">" + files[key].replace("<", "&lt;").replace(">", "&gt;") + "</code></pre></div></div></div>";
    }
    
    // Download zip button
    $('<div class="panel-group" id="accordion">'+filePanels + '</div><p><button type="button" class="btn btn-default" onclick="downloadZip()"><span class="glyphicon glyphicon-circle-arrow-down"></span> Download Zip Archive</button> <span class="help-block">Safari users: add the \'.zip\' extension to the downloaded file manually.</span></p>').insertBefore('.output');
    
    // Run code highlighter
    $('pre code').each(function(i, e) {hljs.highlightBlock(e)});
}

function downloadZip() {
    if (zip == null) {
        showError('Nothing to download');
        return;
    }
    location.href="data:application/zip;base64," + zip.generate({type:"base64"});
}

//!Helper functions
function showError(error) {
    $('<div class="alert alert-danger alert-dismissable"><button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button><strong>Error!</strong> ' + error + '</div>').insertBefore('.output');
}

function containsObject(json) {
    if (typeof json === 'object' && !Array.isArray(json)) {
        return (Object.keys(json).length > 0);
    } else {
        return false;
    }
}

//!Descriptions & mappings
function classDescription(classDescriptions, prefix, name, json) {
    var description = new Object;
    description.name = name;
    description.mappings = [];
    description.customClasses = [];
    for (var key in json) {
        var jsonForKey = json[key];
        if (Array.isArray(jsonForKey)) {
            var camelKey = key.toIvarName();
            var mapping = mappingDescription(prefix, key, camelKey, jsonForKey);
            description.mappings.push(mapping);
            
            if (mapping.customClass == true) {
                description.customClasses.push(mapping.internalClass);
                var nameForKey = key.toSingular().toClassName(prefix);
                classDescription(classDescriptions, prefix, nameForKey, jsonForKey[0]);
            }
        } else if (containsObject(jsonForKey)) {
            var nameForKey = key.toClassName(prefix);
            classDescription(classDescriptions, prefix, nameForKey, jsonForKey);
            
            var camelKey = key.toIvarName();
            var mapping = mappingDescription(prefix, key, camelKey, jsonForKey);
            description.mappings.push(mapping);
            if (mapping.customClass == true) {
                description.customClasses.push(mapping.internalClass);
            }
        } else {
            var camelKey = key.toIvarName();
            var mapping = mappingDescription(prefix, key, camelKey, jsonForKey);
            description.mappings.push(mapping);
            if (mapping.customClass == true) {
                description.customClasses.push(mapping.internalClass);
            }
        }
    }
    classDescriptions[name] = description;
}

function mappingDescription(prefix, key, camelKey, json) {
    var type = typeof json;
    var mapping = new Object;
    mapping.internalKey = camelKey;
    mapping.externalKey = key;
    if (type == 'string') {
        mapping.type = 'NSString *';
        mapping.property = "copy";
        mapping.internalClass = 'NSString';
   } else if (type == 'number') {
        mapping.type = 'NSNumber *';
        mapping.property = "strong";
        mapping.internalClass = 'NSNumber';
    } else if (type == 'boolean') {
        mapping.type = 'BOOL ';
        mapping.property = "assign";
        mapping.internalClass = 'NSNumber';
    } else if (Array.isArray(json)) {
        var subJson = json[0];
        var submapping = mappingDescription(prefix, key, camelKey, subJson);
        mapping.type = 'NSArray *';
        mapping.property = "copy";
        mapping.collection = true;
        mapping.collectionClass = 'NSArray';
        mapping.internalClass = submapping.internalClass;
        mapping.customClass = submapping.customClass;
    } else {
        var className = key.toSingular().toClassName(prefix);
        mapping.type = className + ' *';
        mapping.property = "strong";
        mapping.internalClass = className;
        mapping.customClass = true;
    }
    return mapping;
}

//!File generation
function addFilesForClassDescription(files, description, project, date, year, user) {
    files[description.name + ".h"] = interfaceForClassDescription(description, project, date, year, user);
    files[description.name + ".m"] = implementationForClassDescription(description, project, date, year, user);
    files[description.name + "+Mappings.h"] = interfaceMappingsForClassDescription(description, project, date, year, user);
    files[description.name + "+Mappings.m"] = implementationMappingsForClassDescription(description, project, date, year, user);
}

//!Entity templates
function interfaceForClassDescription(description, project, date, year, user) {
    var text = "//\n\
// {name}.h\n\
// {project}\n\
//\n\
// Created by EFDataMappingKit Generator on {date}.\n\
// Copyright (c) {year} {user}. All rights reserved.\n\
//\n\
\n\
#import <Foundation/Foundation.h>\n\
\n\
{classDeclarations}\
@interface {name} : NSObject\n\
\n\
\{properties}\n\
@end\n\
\n\
";
    return text.format({name: description.name, project: project, date: date, year: year, user: user, classDeclarations: classDeclarationsForClassDescription(description), properties: propertiesForClassDescription(description)});
}

function classDeclarationsForClassDescription(description) {
    var text = "";
    for (var i = 0; i < description.customClasses.length; i++) {
        var className = description.customClasses[i];
        text += "@class {className};\n".format({className: className});
    }
    if (description.customClasses.length > 0) {
        text += "\n";
    }
    return text;
}

function propertiesForClassDescription(description) {
    var text = "";
    for (var i = 0; i < description.mappings.length; i++) {
        var mapping = description.mappings[i];
        text += "@property (nonatomic, {property}) {type}{internalKey};\n".format({property: mapping.property, type: mapping.type, internalKey: mapping.internalKey});
    }
    return text;
}

function implementationForClassDescription(description, project, date, year, user) {
    var text = "//\n\
// {name}.m\n\
// {project}\n\
//\n\
// Created by EFDataMappingKit Generator on {date}.\n\
// Copyright (c) {year} {user}. All rights reserved.\n\
//\n\
\n\
#import \"{name}.h\"\n\
\n\
@implementation {name}\n\
\n\
@end\n\
\n\
";
    return text.format({name: description.name, project: project, date: date, year: year, user: user});
}

//!Mappings templates
function interfaceMappingsForClassDescription(description, project, date, year, user) {
    var text = "//\n\
// {name}+Mappings.h\n\
// {project}\n\
//\n\
// Created by EFDataMappingKit Generator on {date}.\n\
// Copyright (c) {year} {user}. All rights reserved.\n\
//\n\
\n\
#import \"{name}.h\"\n\
\n\
@interface {name} (Mappings)\n\
\n\
\+ (NSArray *)mappings;\n\
\n\
@end\n\
\n\
";
    return text.format({name: description.name, project: project, date: date, year: year, user: user});
}

function mappingsForClassDescription(description) {
    var text = "";
    for (var i = 0; i < description.mappings.length; i++) {
        var mapping = description.mappings[i];
        if (mapping.collection == true) {
            text += "             [EFMapping mappingForArray:^(EFMapping *m) {\n\
                 m.externalKey = @\"{externalKey}\";\n\
                 m.internalKey = @\"{internalKey}\";\n\
                 m.internalClass = [{internalClass} class];\n\
             }],\n".format({externalKey: mapping.externalKey, internalKey: mapping.internalKey, internalClass: mapping.internalClass});
        } else {
            text += "             [EFMapping mapping:^(EFMapping *m) {\n\
                 m.externalKey = @\"{externalKey}\";\n\
                 m.internalKey = @\"{internalKey}\";\n\
                 m.internalClass = [{internalClass} class];\n\
             }],\n".format({externalKey: mapping.externalKey, internalKey: mapping.internalKey, internalClass: mapping.internalClass});
        }
    }
    return text;
}

function implementationMappingsForClassDescription(description, project, date, year, user) {
    var text = "//\n\
// {name}+Mappings.m\n\
// {project}\n\
//\n\
// Created by EFDataMappingKit Generator on {date}.\n\
// Copyright (c) {year} {user}. All rights reserved.\n\
//\n\
\n\
#import \"{name}+Mappings.h\"\n\
\n\
{imports}\
#import <EFDataMappingKit/EFDataMappingKit.h>\n\
\n\
@implementation {name} (Mappings)\n\
\n\
+ (NSArray *)mappings {\n\
    return @[\n\
{mappings}\n\
            ];\n\
}\n\
\n\
@end\n\
\n\
";
    return text.format({name: description.name, project: project, date: date, year: year, user: user, imports: importsForClassDescription(description), mappings: mappingsForClassDescription(description)});
}

function importsForClassDescription(description) {
    var text = "";
    for (var i = 0; i < description.customClasses.length; i++) {
        var className = description.customClasses[i];
        text += "#import \"{className}.h\"\n".format({className: className});
    }
    return text;
}

//!Mapper template
function interfaceMapper(prefix, project, date, year, user) {
    var text = "//\n\
// {prefix}Mapper.h\n\
// {project}\n\
//\n\
// Created by EFDataMappingKit Generator on {date}.\n\
// Copyright (c) {year} {user}. All rights reserved.\n\
//\n\
\n\
#import <EFDataMappingKit/EFDataMappingKit.h>\n\
\n\
@interface {prefix}Mapper : EFMapper\n\
\n\
@end\n\
\n\
";
    return text.format({prefix: prefix, project: project, date: date, year: year, user: user});
}

function implementationMapperForClassDescriptions(descriptions, prefix, project, date, year, user) {
    var text = "//\n\
// {prefix}Mapper.m\n\
// {project}\n\
//\n\
// Created by EFDataMappingKit Generator on {date}.\n\
// Copyright (c) {year} {user}. All rights reserved.\n\
//\n\
\n\
#import \"{prefix}Mapper.h\"\n\
\n\
{imports}\
\n\
@implementation {prefix}Mapper\n\
\n\
- (id)init {\n\
    self = [super init];\n\
    if (self) {\n\
{mappingRegistrations}\
    }\n\
    return self;\n\
}\n\
\n\
@end\n\
\n\
";
    return text.format({prefix: prefix, project: project, date: date, year: year, user: user, imports: importsForClassDescriptions(descriptions), mappingRegistrations: mappingRegistrationsForClassDescriptions(descriptions)});
}

function importsForClassDescriptions(descriptions) {
    var text = "";
    for (var description in descriptions) {
        text += "#import \"{className}+Mappings.h\"\n".format({className: description});
    }
    return text;
}

function mappingRegistrationsForClassDescriptions(descriptions) {
    var text = "";
    for (var description in descriptions) {
        text += "        [self registerMappings:[{className} mappings] forClass:[{className} class]];\n".format({className: description});
    }
    return text;
}