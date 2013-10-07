//
//  FPRequestSimpleModel.h
//  First Pass
//
//  Created by Thiago Ricieri on 06/10/13.
//  Copyright (c) 2013 First Pass. All rights reserved.
//

#import "definitions.h"
#import <Foundation/Foundation.h>

@interface FPRequestDefaultModel : NSObject

@property (nonatomic, strong) NSNumber *FPID;

- (id) initWithID: (NSNumber *) ID;
- (NSDictionary *) dictionaryRepresentation;

@end
