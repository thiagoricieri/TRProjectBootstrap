//
//  FPResponseDefaultModel.h
//  First Pass
//
//  Created by Thiago Ricieri on 06/10/13.
//  Copyright (c) 2013 First Pass. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FPResponseDefaultModel : NSObject

@property (nonatomic) BOOL success;
@property (nonatomic, strong) NSString *errorMessage;
@property (nonatomic, strong) NSString *responseString;
@property (nonatomic, strong) NSDictionary *responseDictionary;

- (id) initWithResponse: (NSDictionary *) response;

@end
