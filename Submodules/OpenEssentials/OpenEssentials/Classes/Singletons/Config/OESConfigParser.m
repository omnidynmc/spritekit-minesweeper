//
//  OESConfigParser.m
//  OESShared
//
//  Created by Gregory Carter on 9/4/12.
//  Copyright (c) 2012 Gregory Carter. All rights reserved.
//

#import "OESStopwatch.h"
#import "NSDictionary+OESAdditions.h"

#import "OESConfigException.h"
#import "OESConfigParser.h"
#import "OESConfigDatatypeParser.h"
#import "OESConfigVariableParser.h"
#import "OESConfigApp.h"
#import "OESConfigVariable.h"
#import "OESConfigDatatype.h"
#import "OESConfigMode.h"
#import "OESConfigDebug.h"

typedef enum {
    OESConfigParserValidateInvalid = 0,
    OESConfigParserValidateOk = 1,
    OESConfigParserValidateNotFound = 2,
} OESConfigParserValidateType;

@interface OESConfigParser ()
@property (nonatomic, strong) OESStopwatch *stopwatch;
// Private
- (OESConfigApp *)extractAppFromDictionary:(NSDictionary *)dictionary error:(NSError **)error;
- (OESConfigMode *)extractModeFromDictionary:(NSDictionary *)dictionary mode:(NSString *)mode error:(NSError **)error;
- (OESConfigParserValidateType)validateSectionInDictionary:(NSDictionary *)dictionary validator:(NSString *)validator;
- (void)storeUserInfoFromDictionary:(NSDictionary *)dictionary;
@end

@implementation OESConfigParser

#pragma mark - Public

- (BOOL)loadConfigs:(NSDictionary *)loadFiles error:(NSError **)error
{
    // config class will validate loadFiles for us
    OESConfigDatatypeParser *parser = [OESConfigDatatypeParser new];
    
    id datatypes = [loadFiles objectForKey:@"datatypes"];
    if (isUrl(datatypes)) {
        NSURL *url = datatypes;
        [parser loadConfigFromURL:url section:@"datatypes" error:nil];
    } // if
    else if (isData(datatypes)) {
        NSData *data = datatypes;
        [parser loadConfigFromData:data section:@"datatypes" error:nil];
    } // else if
    else {
#ifdef DEBUG
        @throw [OESConfigException exceptionWithName:@"InvalidDataTypesConfigInput"
                                             reason:@"The datatypes config loadFiles input is not a NSURL or NSData type."
                                               userInfo: nil];
#else
        return NO;
#endif
    } // else
    
    self.variables = [[OESConfigVariableParser alloc] initWithDatatypes:[parser objects]];

    id variables = [loadFiles objectForKey:@"variables"];
    if (isUrl(variables)) {
        NSURL *url = variables;
        [self.variables loadConfigFromURL:url section:@"variables" error:nil];
    } // if
    else if (isData(variables)) {
        NSData *data = datatypes;
        [self.variables loadConfigFromData:data section:@"variables" error:nil];
    } // else if
    else {
#ifdef DEBUG
        @throw [OESConfigException exceptionWithName:@"InvalidVariablesConfigInput"
                                             reason:@"The variables config loadFiles input is not a NSURL or NSData type."
                                               userInfo: nil];
#else
        return NO;
#endif
    } // else
    
    // this one is handled by this class and will be processed specially
    BOOL wasLoaded = false;

    self.stopwatch = [OESStopwatch new];
    [self.stopwatch start];

    id main = [loadFiles objectForKey:@"main"];
    if (isUrl(main)) {
        NSURL *url = main;
        wasLoaded = [self loadConfigFromURL:url error:error];
    } // if
    else if (isData(main)) {
        NSData *data = main;
        wasLoaded = [self loadConfigFromData:data section:nil error:error];
    } // else if
    else {
#ifdef DEBUG
        @throw [OESConfigException exceptionWithName:@"InvalidMainConfigInput"
                                             reason:@"The main config loadFiles input is not a NSURL or NSData type."
                                               userInfo: nil];
#else
        return NO;
#endif
    } // else
    
    OESLogInfo(@"Configs parsed in %@, successful: %@", [self.stopwatch msAsString], boolAsString(wasLoaded));
    
    return wasLoaded;
}

// This is the start of all processing. Here we process the config and look
// for the required app section along with attempting to derive what mode the app
// is in.
- (BOOL)processDictionaryFromConfig:(NSDictionary *)dictionary
{

    NSArray *requiredSections = @[ @"app" ];
    for(NSString *section in requiredSections) {
        OESConfigParserValidateType isValid = [self validateSectionInDictionary:[dictionary objectForKey:section] validator:section];
        if (isValid != OESConfigParserValidateOk) {
            OESLogError(@"Failed to find required section named: %@", section);
            return NO;
        } // if
    } // if

    // at this point app.mode must exist (unless someone messed up the variables/Datatypes files)
    NSError *error;
    self.app =  [self extractAppFromDictionary:dictionary error:&error];
    
    if (isNil(self.app)) {
        OESLogError(@"Could not process 'app' section: %@", error);
        return NO;
    } // if

    OESLogInfo(@"Found 'app' section: %@", self.app);

    // set current app version
    self.app.appVersion = [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];

    self.appmode = self.app.mode;
    if (isNil(self.appmode)) {
        OESLogError(@"Mode variable in app section does not exist, verify variable and datatype files are correct.");
        return NO;
    } // if

    if ([self.appmode isEqualToString:@"auto"]) {
        // derive appmode automagically
        self.currentMode = [self deriveAppmodeFromDictionary:dictionary error:&error];

        if (isEmpty(self.currentMode))
            OESLogError(@"Failed to load appmode automatically '%@': %@", self.appmode, error);
    } // if
    else {
        // try and find app mode requested
        self.currentMode = [self extractModeFromDictionary:dictionary mode:self.appmode error:&error];

        if (isEmpty(self.currentMode))
            OESLogError(@"Failed to load appmode by name '%@': %@", self.appmode, error);
    } // else

    self.debug = [self extractDebugFromDictionary:dictionary error:&error];
    if (self.debug == nil) {
        if (!isDerefNil(&error))
            OESLogWarn(@"Could not load debug section: %@", error);
    } // if

    // something went wrong, try and use default mode
    if (isEmpty(self.currentMode)) {
        self.appmode = @"default";
        self.currentMode = [self extractModeFromDictionary:dictionary mode:self.appmode error:&error];
        
        if (isEmpty(self.currentMode))
            OESLogError(@"Failed to load appmode automatically '%@': %@", self.appmode, error);
    } // if

    if (isEmpty(self.currentMode)) {
        OESLogError(@"Could not find and load an appropriate mode BAILING!");
        return NO;
    } // if

    // attempt to load default in order to perform overrides
    if (![self.appmode isEqualToString:@"default"]) {
        OESConfigMode *configMode = [self extractModeFromDictionary:dictionary mode:@"default" error:&error];

        if (isEmpty(configMode)) {
            OESLogError(@"Unable to load default config to perform inheritence.");
        } // if
        else {
            [self.currentMode inheritFromConfigMode:configMode];
        } // else
    } // if

    OESLogNotice(@"Loaded appmode %@", self.appmode);

    [self storeSubstitutionsFromDictionary:dictionary];
    [self storeUserInfoFromDictionary:dictionary];

    return YES;
}

#pragma mark - Private

- (OESConfigApp *)extractAppFromDictionary:(NSDictionary *)dictionary error:(NSError **)error
{
    NSDictionary *app = [dictionary objectForKey:@"app"];
    
    BOOL foundApp = isDictionary(app);
    if (!foundApp) {
        if (error != NULL)
            *error = [NSError OESConfigError:500 description:@"could not find app section"];
        return nil;
    } // if

    return [OESConfigApp initWithDictionary:app name:@"app" error:error];
}

- (OESConfigMode *)deriveAppmodeFromDictionary:(NSDictionary *)dictionary error:(NSError **)error
{
    NSDictionary *modes = [dictionary objectForKey:@"modes"];

    BOOL foundModes = !isEmpty(modes) && [modes isKindOfClass:[NSDictionary class]];
    if (!foundModes) {
        if (error != NULL)
            *error = [NSError OESConfigError:500 description:@"could not find modes section"];
        return nil;
    } // if

    for(NSString *modeKey in modes) {
        // don't try default mode it's special
        if ([modeKey isEqualToString:@"default"])
            continue;
        
        NSDictionary *mode = [modes objectForKey:modeKey];
        
        if (!isDictionary(mode))
            continue;
            
        OESConfigMode *configMode = [self extractModeFromDictionary:dictionary mode:modeKey error:error];
        if (isEmpty(configMode))
            continue;
            
        if (![configMode isEnabled])
            continue;

        self.appmode = modeKey;
        return configMode;
    } // for

    // we could not find a suitable mode, try default mode
    OESConfigMode *configMode = [self extractModeFromDictionary:dictionary mode:@"default" error:error];

    BOOL isModeAcceptable = !isEmpty(configMode) && [configMode isEnabled];
    if (isModeAcceptable) {
        self.appmode = @"default";
        return configMode;
    } // if

    return nil;
}

#pragma mark -- Mode

- (OESConfigMode *)extractModeFromDictionary:(NSDictionary *)dictionary mode:(NSString *)mode error:(NSError **)error
{
    NSDictionary *currentMode = [dictionary valueForDotPath:[NSString stringWithFormat:@"modes.%@", mode]];
    if (isEmpty(currentMode)) {
        if (error != NULL)
            *error = [NSError OESConfigError:500 description:[NSString stringWithFormat:@"requested mode '%@' not found", mode]];
        return nil;
    } // if

    // attempt to validate mode variables
    OESConfigParserValidateType isValid = [self validateSectionInDictionary:currentMode validator:@"modes"];
    if (isValid != OESConfigParserValidateOk) {
        if (error != NULL)
            *error = [NSError OESConfigError:501 description:[NSString stringWithFormat:@"failed to validate mode: %@", mode]];
        return nil;
    } // if

    // mode is validated in it's initWithDictionary factory method
    OESConfigMode *configMode = [self createNewMode:currentMode mode:mode error:error];

    OESLogInfo(@"EXTRACTED MODE: %@", configMode);
    
    return configMode;
}

- (OESConfigMode *)createNewMode:(NSDictionary *)dictionary mode:(NSString *)mode error:(NSError **)error
{
    return [OESConfigMode initWithDictionary:dictionary name:mode error:error];
}

#pragma mark -- Debug

- (OESConfigDebug *)extractDebugFromDictionary:(NSDictionary *)dictionary error:(NSError **)error
{
    NSDictionary *debugSection = [dictionary objectForKey:@"debug"];
    if (isEmpty(debugSection)) {
        if (error != NULL)
            *error = [NSError OESConfigError:500 description:@"debug section not found"];
        return nil;
    } // if

    // attempt to validate mode variables
    OESConfigParserValidateType isValid = [self validateSectionInDictionary:debugSection validator:@"debug"];
    if (isValid != OESConfigParserValidateOk) {
        if (error != NULL)
            *error = [NSError OESConfigError:501 description:@"failed to validate debug section"];
        return nil;
    } // if

    // mode is validated in it's initWithDictionary factory method
    OESConfigDebug *configDebug = [self createNewDebug:debugSection name:@"debug" error:error];

    OESLogInfo(@"EXTRACTED DEBUG: %@", configDebug);
    
    return configDebug;
}

- (OESConfigDebug *)createNewDebug:(NSDictionary *)dictionary name:(NSString *)name error:(NSError **)error
{
    return [OESConfigDebug initWithDictionary:dictionary name:name error:error];
}

#pragma mark -- Validate

- (OESConfigParserValidateType)validateSectionInDictionary:(NSDictionary *)dictionary validator:(NSString *)validator
{ 
    if (!isDictionary(dictionary)) {
        OESLogWarn(@"No '%@' validator found.", validator);
        return OESConfigParserValidateNotFound;
    } // if

    // loop through main variables and validate
    NSDictionary *sectionDictionary = [self.variables variablesForSection:validator];
    
    OESLogDebug(@"validating section '%@': %@", validator, sectionDictionary);

    if (!isDictionary(sectionDictionary)) {
        OESLogWarn(@"No '%@' section validation variable.", validator);
        return OESConfigParserValidateNotFound;
    } // if

    for(NSString *key in sectionDictionary) {
        OESConfigVariable *variable = [sectionDictionary objectForKey:key];

        if (![variable isKindOfClass:[OESConfigVariable class]])
            continue;
            
        id object = [dictionary objectForKey:key];

        BOOL isMissingAndRequied = variable.required && isNil(object);
        if (isMissingAndRequied) {
            OESLogError(@"Missing required variable in '%@' section: %@ ", validator, key);
            return OESConfigParserValidateInvalid;
        } // if
        
        NSError *error;
        BOOL isValid = [variable isValidField:object error:&error];
        if (!isValid) {
            OESLogError(@"Detected invalid value for key '%@' with value '%@': %@", key, object, error);
            return OESConfigParserValidateInvalid;
        } // if
    } // for
    
    return OESConfigParserValidateOk;
}

- (void)storeSubstitutionsFromDictionary:(NSDictionary *)dictionary
{
    NSDictionary *substitutions = [dictionary objectForKey:@"substitutions"];
    if (isEmpty(substitutions) || !isDictionary(substitutions))
        return;

    self.substitutions = substitutions;
}

- (void)storeUserInfoFromDictionary:(NSDictionary *)dictionary
{
    NSArray *parseableObjects = @[ @"app", @"debug", @"modes", @"substitutions" ];
    for(NSString *key in dictionary) {
        if ([parseableObjects containsObject:key])
            continue;
            
        id object = [dictionary objectForKey:key];

        if (isEmpty(object))
            continue;

        [self.userInfo setObject:object forKey:key];
    } // for
}

#pragma mark - Accessor Overrides

- (NSMutableDictionary *)userInfo
{
    return _userInfo != nil ? _userInfo : (_userInfo = [NSMutableDictionary new]);
}

@end
