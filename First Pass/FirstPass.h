//
//  FirstPass.h
//  First Pass
//
//  Created by Thiago Ricieri on 06/10/13.
//  Copyright (c) 2013 First Pass. All rights reserved.
//

#import "definitions.h"
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ASIHTTPRequestDelegate.h"

@class FPResponseDefaultModel;
@class FPRequestDefaultModel;
@class ASIFormDataRequest;

@interface FirstPass : NSObject <CLLocationManagerDelegate, ASIHTTPRequestDelegate>

// User atual
@property (nonatomic, strong) NSDictionary *currentUser;
// Location Manager
@property (nonatomic, strong) CLLocationManager *locationManager;
// Flags
@property (nonatomic) BOOL canCheckTimedServices;
@property (nonatomic) BOOL canUpdateLocation;
@property (nonatomic) BOOL isGlobalServicesRunning;
@property (nonatomic) BOOL autoLocationServicesUpdate;

// Singleton
+ (FirstPass *) singleton;

// Processos de temporização de atualizações e controle de sessão
+ (void) AStartServices;
+ (void) AStopServices;
+ (void) AStartTimedServices;
+ (void) AStopTimedServices;
+ (BOOL) ACheckAndStoreLoggedUserInfo;
+ (void) AStoreLoggedUserInfoWith: (NSDictionary *) loggedUserInfo;
+ (void) APerformLogout;
- (void) ATimerFired;

// Iniciar um HTTPRequest com parâmetros padrão
+ (ASIFormDataRequest *) BInitDefaultFormRequest: (NSString *) url andJSON: (NSDictionary *) json andDelegate: (id<ASIHTTPRequestDelegate>) delegate;

// Processos de recebimento de dados
//+ (void) BPostSaveUserChanges: (WBUserLocatedModel *) model withDelegate: (id<ASIHTTPRequestDelegate>) delegate;

// Processos de localização
+ (void) CStartLocationServices;
+ (void) CStopLocationServices;

// Processos de log de erros
+ (void) ELogConnectionError;
+ (void) EDisplayErrorMessage: (NSString *) errorMessage;

// Push Notifications
+ (void) PRequestPermissionPushNotifications;

@end