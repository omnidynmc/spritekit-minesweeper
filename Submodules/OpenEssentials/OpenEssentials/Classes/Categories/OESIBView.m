//
//  IBView.m
//  OpenEssentials
//
//  Created by Gregory Carter on 11/12/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import "OESIBView.h"

@implementation OESIBView

-(void) loadViewsFromBundle {
	NSString *class_name = NSStringFromClass([self class]);
	//NSLog(@"Loading bundle: %@", class_name);
	UIView *mainSubView = [[[NSBundle mainBundle] loadNibNamed:class_name owner:self options:nil] lastObject];

    // make sure we adjust our new template subview size to the size of the view we're set instantiated from
    // do not be adjusting the origin or undesired results will happen
    CGRect frame = mainSubView.frame;
    frame.size = self.frame.size;
    frame.origin = CGPointMake(0.0f, 0.0f);
    mainSubView.frame = frame;
    
	[self addSubview:mainSubView];
}

-(id) initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if(self) {
		[self loadViewsFromBundle];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self loadViewsFromBundle];
        // Initialization code.
    }
    return self;
}

@end
