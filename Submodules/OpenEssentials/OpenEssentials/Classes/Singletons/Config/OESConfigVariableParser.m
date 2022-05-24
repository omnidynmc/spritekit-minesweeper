//
//  OESConfigVariableParser.m
//  OESShared
//
//  Created by Gregory Carter on 8/31/12.
//  Copyright (c) 2012 Gregory Carter. All rights reserved.
//
#import "NSDictionary+OESAdditions.h"

#import "OESConfigVariableParser.h"
#import "OESConfigVariable.h"
#import "OESConfigDatatype.h"

@interface OESConfigVariableParser ()
@property (nonatomic, strong) NSMutableArray *path;

- (NSDictionary *)processDictionaryForSection:(NSDictionary *)dictionary section:(NSString *)section;
@end

@implementation OESConfigVariableParser

#pragma mark - Initialization

- (id)initWithDatatypes:(NSDictionary *)datatypes
{
    if (self = [super init]) {
        self.datatypeCollection = datatypes;
    } // if
    return self;
}

#pragma mark - OESConfigParser Overrides

- (BOOL)processDictionaryFromConfig:(NSDictionary *)dictionary
{    
    self.currentSection = self.sections;
    for(NSString *sectionKey in dictionary) {
        NSDictionary *section = [dictionary objectForKey:sectionKey];
        [self.path addObject:sectionKey];
        [self drillDownDictionaryFromConfig:section];
        [self.path removeLastObject];
    } // if
    
    self.currentSection = nil;
    self.previousSection = nil;
    
    return YES;
}

#pragma mark - Public
#pragma mark -- Locate Variables for Section

- (NSDictionary *)variablesForSection:(NSString *)section
{
    return [self.sections valueForDotPath:section];
}

#pragma mark - Private
#pragma mark -- Parsers

- (OESConfigVariable *)drillDownDictionaryFromConfig:(NSDictionary *)dictionary
{
    if (!isDictionary(dictionary))
        return nil;

    OESLogDebug(@"processing '%@'", [self.path componentsJoinedByString:@"."]);

    NSString *datatype = [dictionary objectForKey:@"datatype"];

    if (!isString(datatype)) {
        OESLogWarn(@"'%@' missing datatype skipping object", [self currentPath]);
        return nil;
    } // if
    
    if ([datatype isEqualToString:@"object"]) {
        [self processObjectFields:dictionary];
    } // if
    else if ([datatype isEqualToString:@"hash"]);
    else {
        // not a special type, treat as variable name
        NSError *error;
        OESConfigVariable *variable = [self createVariableFromDictionary:dictionary datatypeName:datatype error:&error];

        if (isNil(variable)) {
            OESLogWarn(@"'%@' could not parse variable for key %@: %@", [self currentPath], [self.path lastObject], error);
            return nil;
        } // if
        
       return variable;
    } // else
    
    return nil;
}

- (void)processObjectFields:(NSDictionary *)dictionary
{
    // loop through dictionary keys
    NSDictionary *fields = [dictionary objectForKey:@"fields"];
    
    // no fields to process
    if (!isDictionary(fields)) {
        OESLogWarn(@"'%@' no fields found", [self.path componentsJoinedByString:@"."]);
        return;
    } // if
    
    NSMutableDictionary *currentSection = [self enterSection:[self currentSectionName]];
    
    for(NSString *key in fields) {
        NSDictionary *field = [fields objectForKey:key];
        [self.path addObject:key];
        OESConfigVariable *variable = [self drillDownDictionaryFromConfig:field];
        
        if (!isEmpty(variable))
            [currentSection setObject:variable forKey:[self currentSectionName]];
        
        [self.path removeLastObject];
    } // for

    [self exitSection];
}

- (OESConfigVariable *)createVariableFromDictionary:(NSDictionary *)dictionary datatypeName:(NSString *)datatypeName error:(NSError **)error
{
    NSString *key = [self.path lastObject];
    OESConfigVariable *variable = [OESConfigVariable initWithDictionary:dictionary name:key error:error];

    if (isNil(variable))
        return nil;

    OESLogDebug(@"Result %@", variable);
        
    // assign validator to variable if we can find one
    OESConfigDatatype *datatype = [self.datatypeCollection objectForKey:variable.datatype];
    if (!isNil(datatype)) {
        variable.validator = datatype;
    } // if
    else
        OESLogWarn(@"Validator for variable '%@' and type '%@' was not found, check datatype config for errors.", variable.name, variable.datatype);
    
    return variable;
}

- (NSDictionary *)processDictionaryForSection:(NSDictionary *)dictionary section:(NSString *)section
{
    NSDictionary *localDictionary = [dictionary objectForKey:section];

    if (!isDictionary(localDictionary)) {
        OESLogWarn(@"Dictionary section not found for name %@", section);
        return nil;
    } // if
    
    NSMutableDictionary *returnDictionary = [NSMutableDictionary new];

    NSError *error;
    for(NSString *key in localDictionary) {
        NSDictionary *object = [localDictionary objectForKey:key];
        OESConfigVariable *variable = [OESConfigVariable initWithDictionary:object name:key error:&error];
        if (isNil(variable)) {
            OESLogError(@"Could not parse variable for key %@: %@", key, error);
            continue;
        } // if

        OESLogDebug(@"Result %@", variable);
        
        // assign validator to variable if we can find one
        OESConfigDatatype *datatype = [self.datatypeCollection objectForKey:variable.datatype];
        if (!isNil(datatype)) {
            variable.validator = datatype;
        } // if
        else
            OESLogWarn(@"Validator for variable '%@' and type '%@' was not found, check datatype config for errors.", variable.name, variable.datatype);

        [returnDictionary setObject:variable forKey:variable.name];
    } // for
    
    return returnDictionary;
}

#pragma mark -- Section Changers

- (NSMutableDictionary *)enterSection:(NSString *)section
{
    self.previousSection = self.currentSection;
    
    NSMutableDictionary *newSection = [NSMutableDictionary new];
    [self.currentSection setObject:newSection forKey:[self currentSectionName]];
    return self.currentSection = newSection;
}

- (NSMutableDictionary *)exitSection
{
    return self.currentSection = self.previousSection;
}

#pragma mark -- Current Section Helpers

- (NSString *)currentPath
{
    return [self.path componentsJoinedByString:@"."];
}

- (NSString *)currentSectionName
{
    return [self.path lastObject];
}

#pragma mark - Accessors

- (NSDictionary *)datatypeCollection
{
    // this gets assigned on init so I'm not sure we need to do this, perhaps if we shortcut parsing later
    return !isNil(_datatypeCollection) ? _datatypeCollection : (_datatypeCollection = [NSDictionary new]);
}

- (NSMutableDictionary *)sections
{
    return !isNil(_sections) ? _sections : (_sections = [NSMutableDictionary new]);
}

- (NSMutableDictionary *)lastSection
{
    return !isNil(_currentSection) ? _currentSection : (_currentSection = [NSMutableDictionary new]);
}

- (NSMutableArray *)path
{
    return !isNil(_path) ? _path : (_path = [NSMutableArray new]);
}

@end
