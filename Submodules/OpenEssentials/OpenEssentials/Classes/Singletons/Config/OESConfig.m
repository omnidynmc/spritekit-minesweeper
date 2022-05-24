//
//  OESConfig.m
//  OESShared
//
//  This abstract class is designed to make creating a config singleton easier
//  with some default variables and values that every app will need.
//
//  Created by Gregory Carter on 9/10/12.
//  Copyright (c) 2012 Gregory Carter. All rights reserved.
//

// Inheritence Tree
//
// NOTE: The use of the Abstract suffix is only for cases where
//       the class name is also going to be used as a real class,
//       but other classes subclass it.
//
// OESConfigObject
//   |- OESConfigMode
//   |- OESConfigFeature
//   |    `- OESConfigEndpoint
//   |- OESConfigVariable
//   `- OESConfigDatatype
//
// OESConfigParserAbstract
//   |- OESConfigVariableParser
//   |- OESConfigDatatypeParser
//   `- OESConfigParser
//
// OESConfig
//   `- OESConfig

#import "OESConfig.h"
#import "OESConfigVariableParser.h"
#import "OESConfigApp.h"
#import "OESConfigMode.h"
#import "OESConfigParser.h"
#import "OESConfigException.h"
#import "OESConfigDebug.h"

@interface OESConfig ()
- (void)loadConfigsOperation:(NSDictionary *)loadFiles;
@end

@implementation OESConfig

#pragma mark - Shared Instance Setup

OESSHARED_INSTANCE(id)

#pragma mark - Public
#pragma mark -- Load Configs

- (BOOL)loadConfigs:(NSDictionary *)loadFiles enqueue:(BOOL)enqueue error:(NSError **)error
{
    if (isEmpty(loadFiles)) {
        if (error != NULL)
            *error = [NSError OESConfigError:500 description:@"loadfiles dictionary is empty"];
        return NO;
    } // if


    NSArray *expect = @[ @"main", @"datatypes", @"variables" ];
    
    for(NSString *name in expect) {
        id url = [loadFiles objectForKey:name];
        if (!isUrl(url) && !isData(url)) {
            if (error != NULL)
                *error = [NSError OESConfigError:501 description:[NSString stringWithFormat:@"expected %@ to be defined for support configs", url]];
            return NO;
        } // if
    } // for

    // create a new parser, don't put it in place unless it succeeds
    self.incomingConfigParser = [self createNewConfigParser];
    self.incomingConfigParser.delegate = self;
    BOOL wasLoaded = false;
    
    if (!enqueue) {
        wasLoaded = [self.incomingConfigParser loadConfigs:loadFiles error:error];
        [self loadConfigsDidFinish:wasLoaded];
    } // if
    else {
        // eventually we could make the other conf files dependencies so they load first async
        NSOperationQueue *queue = [NSOperationQueue new];
 
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
        selector:@selector(loadConfigsOperation:)
        object:loadFiles];
 
        OESLogInfo(@"Dispatching loadConfigsOperation to queue");
        [queue addOperation:operation];
    } // else

    return wasLoaded;
}

- (void)loadConfigsOperation:(NSDictionary *)loadFiles
{
    NSError *error = nil;
    BOOL wasLoaded = [self.configParser loadConfigs:loadFiles error:&error];

    [self loadConfigsDidFinish:wasLoaded];
}

- (void)loadConfigsDidFinish:(BOOL)wasLoaded
{
    if (!wasLoaded) {
        self.incomingConfigParser = nil;
        return;
    } // if
    
    BOOL isNewVersion = isNil([self currentApp]) || [[self currentApp] isConfigNewer:[self.incomingConfigParser app]];
    if (!isNewVersion) {
        OESLogInfo(@"Incoming configuration serial '%@' was not newer than running configuration '%@', ignoring.", self.incomingConfigParser.app.serial, self.currentApp.serial);
        self.incomingConfigParser = nil;
        return;
    } // if
    
    self.configParser = self.incomingConfigParser;
    
    //dispatch_sync(dispatch_get_main_queue(), ^{
        [self updateInternalConfig];
    //});
    
    // don't store reference anymore, we handed it off
    self.incomingConfigParser = nil;
}

#pragma mark -- Abstract Methods

- (void)updateInternalConfig
{
    // This method is not guaranteed to be called on the main thread, you've
    // been warned!
    @throw [OESConfigException exceptionWithName:NSInternalInconsistencyException
                            reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                             userInfo:nil];
}

- (OESConfigVariableParser *)validators
{
    // WARNING: This method should only be used for parsing. It is not based
    // off of the running config but the incoming one.
    return self.incomingConfigParser.variables;
}

- (OESConfigParser *)createNewConfigParser
{
    return [OESConfigParser new];
}

#pragma mark -- ConfigApp Accessors

// Configuration Inqueries
- (NSNumber *)minimumVersion
{
    return [[self currentApp] minimumVersion];
}

- (NSNumber *)latestVersion
{
    return [[self currentApp] latestVersion];
}

- (BOOL)isAppMinimumVersion
{
    return [[self currentApp] isAppMinimumVersion];
}

- (BOOL)isAppLatestVersion
{
    return [[self currentApp] isAppLatestVersion];
}

#pragma mark -- ConfigParser Accessors

- (OESConfigMode *)currentMode
{
    return self.configParser.currentMode;
}

- (OESConfigApp *)currentApp
{
    return self.configParser.app;
}

- (NSString *)currentAppmode
{
    return self.configParser.appmode;
}

#pragma mark -- ConfigMode Accessors

- (OESConfigFeature *)fetchFeatureByName:(NSString *)name
{
    return [[self currentMode] fetchFeatureByName:name];
}

- (OESConfigEndpoint *)fetchEndpointByName:(NSString *)name
{
    return [[self currentMode] fetchEndpointByName:name];
}

- (NSString *)fetchEndpointUrlStringByName:(NSString *)name
{
    NSString *urlString = [[self currentMode] urlForEndpoint:name];
    
    if (isEmpty(urlString)) {
        OESLogWarn(@"Endpoint not found with name '%@'", name);
        return nil;
    } // if
    
    return urlString;
}

- (NSURL *)fetchEndpointUrlByName:(NSString *)name
{
    // auto performs default substitutions
    return [self fetchEndpointUrlByName:name substitutions:nil];
}

- (NSURL *)fetchEndpointUrlByName:(NSString *)name substitutions:(NSDictionary *)substitutions
{
    NSString *urlString = [self fetchEndpointUrlStringByName:name];

    if (isEmpty(urlString))
        return nil;

    return [self performSubstitutionsOnUrlString:urlString substitutions:substitutions];
}

- (NSURL *)performSubstitutionsOnUrlString:(NSString *)urlString substitutions:(NSDictionary *)substitutions
{
    if (isEmpty(urlString))
        return nil;

    NSDictionary *configSubstitutions = [[[OESConfig sharedInstance] configParser] substitutions];
    NSDictionary *supportedSubstitutions = [configSubstitutions objectForKey:@"variables"];
    NSMutableDictionary *defaultedSubstitutions = !isNil(substitutions) ? [[NSMutableDictionary alloc] initWithDictionary:substitutions] : [NSMutableDictionary new];

    // create our defaults list if it is available in config
    NSDictionary *defaults = [configSubstitutions objectForKey:@"defaults"];
    if (!isEmpty(defaults)) {
        for(NSString *key in defaults) {
            NSString *defaultValue = [defaults objectForKey:key];
            if (!isString(defaultValue))
                continue;

            if (isNil([defaultedSubstitutions objectForKey:key]))
                [defaultedSubstitutions setObject:defaultValue forKey:key];
        } // for
    } // if
    else {
        // if we have no defaults AND subsitutions is nil then we have nothing to do
        // and we should just return the urlString as an NSURL
        BOOL isThereAnythingToDo = !isNil(substitutions);

        if (!isThereAnythingToDo)
            return [NSURL URLWithString:urlString];
    } // else
    
    for(NSString *key in defaultedSubstitutions) {
        NSString *urlSubstitution = [supportedSubstitutions objectForKey:key];
        id object = [defaultedSubstitutions objectForKey:key];
        
        NSString *substitutionValue;
        if (isString(object))
            substitutionValue = (NSString *)object;
        else if (isNumber(object))
            substitutionValue = [(NSNumber *)object stringValue];
        else {
#ifdef DEBUG
            @throw [OESConfigException exceptionWithName:NSInternalInconsistencyException
                            reason:[NSString stringWithFormat:@"Substitution value for '%@' must be NSString or NSNumber", key]
                             userInfo:nil];
#else
            return nil;
#endif
        } // else
        
        if (isEmpty(urlSubstitution)) {
            NSString *substitutionFormated = [NSString stringWithFormat:@"{{%@}}", key];
            OESLogDebug(@"Substituion url for '%@' not found, mapping directly: %@", key, substitutionFormated);
            urlString = [urlString stringByReplacingOccurrencesOfString:substitutionFormated withString:substitutionValue];
            continue;
        } // if

        urlString = [urlString stringByReplacingOccurrencesOfString:urlSubstitution withString:substitutionValue];
    } // for

    NSURL *url = [NSURL URLWithString:urlString];
    
    if (isNil(url))
        OESLogError(@"Unable to build URL for '%@'; substitutions should be swapped out already.", urlString);

    return url;
}

#pragma mark -- Date

- (NSDate *)currentDate
{
    OESConfigDebug *configDebug = self.configParser.debug;
    
    BOOL shouldUseDebugDate = !isNil(configDebug) && !isNil(configDebug.deviceDate);
    if (shouldUseDebugDate)
        return configDebug.deviceDate;
    
    // add support for debug section date here if specified
    return [NSDate date];
}

#pragma mark - Accessors

- (OESConfigParser *)configParser
{
    return !isNil(_configParser) ? _configParser : (_configParser = [OESConfigParser new]);
}

- (NSArray *)forDevices
{
    return !isNil(_forDevices) ? _forDevices : (_forDevices = [NSArray new]);
}

#pragma mark - <OESConfigParserDelegate>

- (void)configParserDidFinishParsing:(BOOL)loaded error:(NSError *)error
{
    // do something awesome here
    OESLogInfo(@"Finished parsing config; parsed successfully? %@", boolAsString(loaded));
}

@end
