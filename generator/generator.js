if (typeof String.prototype.toCamel !== 'function') {
    String.prototype.toCamel = function(){
        return this.replace(/[-_ ]([a-z])/g, function (g) { return g[1].toUpperCase(); });
    };
}

if (typeof String.prototype.toSingular !== 'function') {
    String.prototype.toSingular = function(){
    
   // var singularize = require("inflection").singularize
    return singularize(this); // => "word"
   // this.replace(/([ies]$)/g, function (g) { return "y"; });
       // return this.replace(/([s]$)/g, function (g) { return ""; });
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

var zip = null;

function generate() {
    $('div#output').html(' <div class="output"></div>');
    
    try {
        var input = $("#inputJSON").val();
        input.replace(/[\u2018\u2019]/g, "'").replace(/[\u201C\u201D]/g, '"')
        var json = $.parseJSON(input);
    }
    catch (exception) {
        $('<div class="alert alert-danger alert-dismissable"><button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button><strong>Error!</strong> ' + exception + '</div>').insertBefore('.output');
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
    
    var classDescriptions = new Object;
    
    if (containsObject(json)) {
        var camelKey = root.toClassName(prefix);
        classDescription(classDescriptions, prefix, camelKey, json);
    } else {
        $('<div class="alert alert-danger alert-dismissable"><button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button><strong>Error!</strong> ' + 'Expected a dictionary as root' + '</div>').insertBefore('.output');
        return;
    }
    
   //console.log(classDescriptions.keys());
    
    var files = new Object;
    
    for (var key in classDescriptions) {
        addFilesForClassDescription(files, classDescriptions[key], project, date, year, user);
    }
    
    zip = new JSZip();
    
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
      <div class=\"panel-body\"><pre><code languages=\"objectivec\">" + files[key] + "</code></pre></div></div></div>";
      
      zip.file(key, files[key]);
    }
    
     $('<div class="panel-group" id="accordion">'+filePanels + '</div><p><button type="button" class="btn btn-default" onclick="downloadZip()"><span class="glyphicon glyphicon-circle-arrow-down"></span> Download Zip Archive</button> <span class="help-block">Safari users: add the \'.zip\' extension to the downloaded file manually.</span></p>').insertBefore('.output');
    
    $('pre code').each(function(i, e) {hljs.highlightBlock(e)});
    
    
}

function downloadZip() {
    if (zip == null) {
        $('<div class="alert alert-danger alert-dismissable"><button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button><strong>Error!</strong> ' + 'Nothing to download' + '</div>').insertBefore('.output');
        return;
    }
    var content = null;
    if (JSZip.support.uint8array) {
        content = zip.generate({type : "uint8array"});
    } else {
        content = zip.generate({type : "string"});
    }
    location.href="data:application/zip;base64," + zip.generate({type:"base64"});
}

function containsObject(json) {
    if (typeof json === 'object' && !Array.isArray(json)) {
        return (Object.keys(json).length > 0);
    } else {
        return false;
    }
}

function classDescription(classDescriptions, prefix, name, json) {
    var description = new Object;
    description.name = name;
    description.mappings = [];
    for (var key in json) {
        var jsonForKey = json[key];
        if (Array.isArray(jsonForKey)) {
            var camelKey = key.toIvarName();
            var mapping = mappingDescription(prefix, key, camelKey, jsonForKey);
            description.mappings.push(mapping);
            
            if (mapping.customClass == true) {
                var nameForKey = key.toSingular().toClassName(prefix);
                classDescription(classDescriptions, prefix, nameForKey, jsonForKey[0]);
            }
        } else if (containsObject(jsonForKey)) {
            var nameForKey = key.toClassName(prefix);
            classDescription(classDescriptions, prefix, nameForKey, jsonForKey);
            
            var camelKey = key.toIvarName();
            var mapping = mappingDescription(prefix, key, camelKey, jsonForKey);
            description.mappings.push(mapping);
        } else {
            var camelKey = key.toIvarName();
            var mapping = mappingDescription(prefix, key, camelKey, jsonForKey);
            description.mappings.push(mapping);
        }
    }
    console.log("Adding description for " + name);
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

function addFilesForClassDescription(files, description, project, date, year, user) {
    files[description.name + ".h"] = interfaceForClassDescription(description, project, date, year, user);
    files[description.name + ".m"] = implementationForClassDescription(description, project, date, year, user);
    files[description.name + "+Mappings.h"] = interfaceMappingsForClassDescription(description, project, date, year, user);
    files[description.name + "+Mappings.m"] = implementationMappingsForClassDescription(description, project, date, year, user);
}

function interfaceForClassDescription(description, project, date, year, user) {
    var text = "//\n\
// {name}.h\n\
// {project}\n\
//\n\
// Created by EFDataMappingKit Generator on {date}.\n\
// Copyright (c) {year} {user}. All rights reserved.\n\
//\n\
\n\
@interface {name} : NSObject\n\
\n\
\{properties}\n\
@end\n\
\n\
";
    return text.format({name: description.name, project: project, date: date, year: year, user: user, properties: propertiesForClassDescription(description)});
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
@implementation {name}\n\
\n\
@end\n\
\n\
";
    return text.format({name: description.name, project: project, date: date, year: year, user: user});
}

function interfaceMappingsForClassDescription(description, project, date, year, user) {
    var text = "//\n\
// {name}+Mappings.h\n\
// {project}\n\
//\n\
// Created by EFDataMappingKit Generator on {date}.\n\
// Copyright (c) {year} {user}. All rights reserved.\n\
//\n\
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
    return text.format({name: description.name, project: project, date: date, year: year, user: user, mappings: mappingsForClassDescription(description)});
}

