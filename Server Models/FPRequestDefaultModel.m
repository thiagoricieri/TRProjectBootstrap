//
//  FPRequestSimpleModel.m
//  First Pass
//
//  Created by Thiago Ricieri on 06/10/13.
//  Copyright (c) 2013 First Pass. All rights reserved.
//

#import "TRBootstrap.h"
#import "FPRequestDefaultModel.h"

@implementation FPRequestDefaultModel

@synthesize FPID;

#pragma mark -
#pragma mark Inicialização
- (id) initWithID:(NSNumber *)ID {
	self = [super init];
	if (self) {
		// Initialization
		self.FPID = ID;
	}
	return self;
}

#pragma mark -
#pragma mark Representations
- (NSDictionary *) dictionaryRepresentation {
	return @{@"id": self.FPID};
}

@end