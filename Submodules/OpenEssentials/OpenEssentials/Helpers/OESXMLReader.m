//
//  OESXMLReader.m
//  OpenEssentials
//
//  Created by Gregory Carter on 11/9/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import "OESXMLReader.h"

static NSString *const OESXMLReaderTextKey = @"!text";
static NSString *const OESXMLReaderAttributesKey = @"!attributes";

@interface OESXMLReader () {
    NSError *__autoreleasing *_error;
}

@property (nonatomic, strong) NSMutableDictionary *root;
@property (nonatomic, strong) NSMutableArray *path;
@property (nonatomic, strong) NSMutableString *intraElementText;
- (id)initWithError:(NSError **)error;
- (NSDictionary *)objectWithData:(NSData *)data;
@end

@implementation OESXMLReader

#pragma mark - Factory Methods

+ (NSDictionary *)objectWithData:(NSData *)data error:(NSError **)error
{
    OESXMLReader *xmlReader = [[OESXMLReader alloc] initWithError:error];
    NSDictionary *rootDictionary = [xmlReader objectWithData:data];

    return rootDictionary;
}

#pragma mark - Initialization

- (id)initWithError:(NSError *__autoreleasing *)error
{
    if (self = [super init]) {
        _error = error;
    } // if

    return self;
}

#pragma mark - Private

- (NSString *)trimIgnoredCharacters:(NSString *)string
{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \n"]];
}

#pragma mark - Public

- (NSDictionary *)objectWithData:(NSData *)data
{
    self.intraElementText = [NSMutableString new];
    self.path = [NSMutableArray new];
    *_error = nil;
    
    // Parse the XML
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;

    BOOL wasParsed = [parser parse];
    
    if (!wasParsed)
        return nil;
    
    return self.root;
}

- (id)currentObject
{
    return self.path.count > 0 ? [self.path lastObject] : self.root;
}

#pragma mark - <NSXMLParserDelegate>

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributes
{
    id parentObject = [self currentObject];

    // find dictionary for path
    id currentObject = isMutableDictionary(parentObject) ? [parentObject objectForKey:elementName] : nil;

    // create our new dictionary
    NSMutableDictionary *newDictionary = [NSMutableDictionary new];
    [newDictionary setObject:attributes forKey:OESXMLReaderAttributesKey];

    // object already existed, treat as an array
    if (!isNil(currentObject)) {
        if (isMutableArray(currentObject)) {
            NSMutableArray *array = currentObject;
            [array addObject:newDictionary];
        } // if
        else {
            NSMutableArray *array = [NSMutableArray new];
            
            [array addObject:currentObject];
            [array addObject:newDictionary];
            
            if (isMutableDictionary(parentObject))
                [(NSMutableDictionary *)parentObject setObject:array forKey:elementName];
        } // else
    } // if
    else {
        [parentObject setObject:newDictionary forKey:elementName];
    } // else

    [self.path addObject:newDictionary];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
{
    if (self.intraElementText.length > 0) {
        id currentObject = self.currentObject;
        if (isMutableDictionary(currentObject))
            [currentObject setObject:[self trimIgnoredCharacters:self.intraElementText] forKey:OESXMLReaderTextKey];

        self.intraElementText = [NSMutableString new];
    } // if

    [self.path removeLastObject];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    // add spiffy text from inside the element
    [self.intraElementText appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)error
{
    // uhoh an error, save it for great justice
    *_error = error;
}

#pragma mark - [Accessor Overrides]

- (NSMutableDictionary *)root
{
    return !isNil(_root) ? _root : (_root = [NSMutableDictionary new]);
}

@end
