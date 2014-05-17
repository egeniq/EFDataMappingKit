if (typeof String.prototype.toCamel !== 'function') {
    String.prototype.toCamel = function(){
        return this.replace(/[-_]([a-z])/g, function (g) { return g[1].toUpperCase(); })
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

function generate() {
    $('div#output').html(' <div class="output"></div>');
    
    try {
        var json = $.parseJSON($("#inputJSON").val());
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
        var camelKey = root.toCamel().addPrefix(prefix);
        classDescription(classDescriptions, prefix, camelKey, json);
    } else {
        $('<div class="alert alert-danger alert-dismissable"><button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button><strong>Error!</strong> ' + 'Expected a dictionary as root' + '</div>').insertBefore('.output');
        return;
    }
    
    var files = new Object;
    
    for (var key in classDescriptions) {
        addFilesForClassDescription(files, classDescriptions[key], project, date, year, user);
    }
    
    for (var key in files) {
        $('<pre><code language=\"objectivec\">'+files[key]+'</code></pre>').insertBefore('.output');
    }
    $('pre code').each(function(i, e) {hljs.highlightBlock(e)});
    
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
        if (containsObject(jsonForKey)) {
            var camelKey = key.toCamel().addPrefix(prefix);
            classDescription(classDescriptions, prefix, camelKey, jsonForKey);
            
            var camelKey = key.toCamel();
            var mappings = mappingsDescription(prefix, key, camelKey, jsonForKey);
            description.mappings.push(mappings);
        } else {
            var camelKey = key.toCamel();
            var mappings = mappingsDescription(prefix, key, camelKey, jsonForKey);
            description.mappings.push(mappings);
        }
    }
    classDescriptions[key] = description;
}

function mappingsDescription(prefix, key, camelKey, json) {
    var type = typeof json;
    var mappings = new Object;
    mappings['internalKey'] = camelKey;
    mappings['externalKey'] = key;
    if (type == 'string') {
        mappings['type'] = 'NSString *';
        mappings['property'] = "copy";
        mappings['internalClass'] = 'NSString';
    } else if (type == 'number') {
        mappings['type'] = 'NSNumber *';
        mappings['property'] = "strong";
        mappings['internalClass'] = 'NSNumber';
    } else if (type == 'boolean') {
        mappings['type'] = 'BOOL ';
        mappings['property'] = "assign";
        mappings['internalClass'] = 'NSNumber';
    } else if (Array.isArray(json)) {
        mappings['type'] = 'NSArray *';
        mappings['property'] = "copy";
        mappings['internalClass'] = 'NSArray';
    } else {
        var className = key.toCamel().addPrefix(prefix);
        mappings['type'] = className + ' *';
        mappings['property'] = "strong";
        mappings['internalClass'] = className;
    }
    
    return mappings;
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
        text += "             [EFMapping mapping:^(EFMapping *m) {\n\
                 m.externalKey = @\"{externalKey}\";\n\
                 m.internalKey = @\"{internalKey}\";\n\
                 m.internalClass = [{internalClass} class];\n\
             }],\n".format({externalKey: mapping.externalKey, internalKey: mapping.internalKey, internalClass: mapping.internalClass});
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

