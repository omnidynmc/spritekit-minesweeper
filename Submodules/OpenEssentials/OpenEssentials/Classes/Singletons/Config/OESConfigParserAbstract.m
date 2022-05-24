//
//  OESConfigParser.m
//  OESShared
//
//  Created by Gregory Carter on 8/31/12.
//  Copyright (c) 2012 Gregory Carter. All rights reserved.
//

#import "OESConfigParserAbstract.h"
#import "OESConfigException.h"

@interface OESConfigParserAbstract ()
@end

@implementation OESConfigParserAbstract

- (BOOL)loadConfigFromURL:(NSURL *)url error:(NSError **)error
{
    return [self loadConfigFromURL:url section:nil error:error];
}

- (BOOL)loadConfigFromURL:(NSURL *)url section:(NSString *)section error:(NSError **)error
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];

    // forward on to our subclass for processing
    BOOL wasParsed = [self loadConfigFromData:response section:section error:error];
    
    // causes dups from loadConfigFromData
    //[self postFinishedParsing:wasParsed error:(!isDerefNil(error) ? *error : nil)];
    
    return wasParsed;
}

- (BOOL)loadConfigFromData:(NSData *)data error:(NSError **)error
{
    return [self loadConfigFromData:data section:nil error:error];
}

- (BOOL)loadConfigFromData:(NSData *)data section:(NSString *)section error:(NSError **)error
{
    // Get JSON as a NSString from NSData response
    //NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:error];
    
    if (!isDerefNil(error)) {
        OESLogError(@"could not parse config: %@", *error);
        return NO;
    } // if
    
    if (!isDictionary(jsonObject)) {
        OESLogError(@"parsed config was not a dictionary");
        return NO;
    }

    NSDictionary *jsonDictionary = jsonObject;
    
    NSDictionary *dictionary = section != nil ? [jsonDictionary objectForKey:section] : jsonDictionary;

    if (isNil(dictionary)) {
        OESLogError(@"could not parse config for section %@: not found", section);
        return NO;
    } // if

    // forward on to our subclass for processing
    BOOL wasParsed = [self processDictionaryFromConfig:dictionary];
    
    [self postFinishedParsing:wasParsed error:(!isDerefNil(error) ? *error : nil)];
    
    return wasParsed;
}

- (void)postFinishedParsing:(BOOL)loaded error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate configParserDidFinishParsing:loaded error:error];
    });
}

#pragma mark - Abstract Methods

- (BOOL)processDictionaryFromConfig:(NSDictionary *)dictionary
{
    // abstract method, if you're not overriding this method, YOU'RE DOING IT WRONG!
    @throw [OESConfigException exceptionWithName:NSInternalInconsistencyException
                               reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                             userInfo:nil];
}

#pragma mark - Accessor

- (NSMutableDictionary *)objects
{
    return _objects != nil ? _objects : (_objects = [NSMutableDictionary new]);
}

@end
