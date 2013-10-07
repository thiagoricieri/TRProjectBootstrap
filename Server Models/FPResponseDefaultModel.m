//
//  FPResponseDefaultModel.m
//  First Pass
//
//  Created by Thiago Ricieri on 06/10/13.
//  Copyright (c) 2013 First Pass. All rights reserved.
//

#import "FPResponseDefaultModel.h"

@implementation FPResponseDefaultModel

@synthesize success;
@synthesize errorMessage;
@synthesize responseString;
@synthesize responseDictionary;

#pragma mark -
#pragma mark Inicialização

- (id) initWithResponse: (NSDictionary *) response {
    self = [super init];
    if (self) {
		// Init
        self.success = [[response valueForKey:@"sucesso"] intValue] == 1;
        self.errorMessage = [response valueForKey:@"erro"];
    }
    return self;
}

@end
