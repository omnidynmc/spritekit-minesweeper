//
//  OESConfigVariableParser.h
//  OESShared
//
//  Created by Gregory Carter on 8/31/12.
//  Copyright (c) 2012 Gregory Carter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OESConfigParserAbstract.h"

@interface OESConfigVariableParser : OESConfigParserAbstract
@property (nonatomic, strong) NSDictionary *datatypeCollection;
@property (nonatomic, strong) NSMutableDictionary *sections;
@property (nonatomic, strong) NSMutableDictionary *currentSection;
@property (nonatomic, strong) NSMutableDictionary *previousSection;

// Initialization
- (id)initWithDatatypes:(NSDictionary *)datatypes;

// Public
- (NSDictionary *)variablesForSection:(NSString *)section;
@end
