//
//  NSObject+PropertyTypes.m
//  OpenEssentials
//
//  Created by Gregory Carter on 10/19/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//
#import <objc/message.h>
#import "NSObject+PropertyTypes.h"

@implementation NSObject (PropertyTypes)

+ (NSString *)classFromPropertyAttributeString:(NSString *)attributeString
{
    NSScanner *typeScanner = [NSScanner scannerWithString:attributeString];
    [typeScanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"@"] intoString:nil];
    
    if ([typeScanner isAtEnd])
        return nil;
    
    [typeScanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"@"] intoString:nil];

    // this gets the actual object type
    NSString *type = [NSString string];
    [typeScanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\""] intoString:&type];
    
    return type;
}

- (NSDictionary *)typesForProperties
{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];

    Class currentClass = [self class];
    while(currentClass != nil) {
        unsigned int propertyCount;
        objc_property_t *propertyList = class_copyPropertyList(currentClass, &propertyCount);

        for(int i=0; i < propertyCount; ++i) {
            objc_property_t *property = propertyList + i;
            
            NSString *attributeString = [NSString stringWithCString:property_getAttributes(*property) encoding:NSUTF8StringEncoding];
            NSString *propertyName = [NSString stringWithCString:property_getName(*property) encoding:NSUTF8StringEncoding];
            
            const char *className = [[NSObject classFromPropertyAttributeString:attributeString] cStringUsingEncoding:NSUTF8StringEncoding];

            Class theClass = objc_getClass(className);
            
            if (isNil(theClass))
                continue;
            
            [dictionary setObject:theClass forKey:propertyName];
        } // for
        
        free(propertyList);
        
        currentClass = [currentClass superclass];
    } // while
    
    return dictionary;
}

@end
