//
//  FirstPass.m
//  First Pass
//
//  Created by Thiago Ricieri on 06/10/13.
//  Copyright (c) 2013 First Pass. All rights reserved.
//

#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "TRBootstrap.h"
#import "SBJsonWriter.h"
#import "FPRequestDefaultModel.h"
#import "FPResponseDefaultModel.h"
#import "FirstPass.h"

@implementation FirstPass

@synthesize currentUser;
@synthesize locationManager;
// Flags
@synthesize canCheckTimedServices;
@synthesize canUpdateLocation;
@synthesize autoLocationServicesUpdate;
@synthesize isGlobalServicesRunning;

#pragma mark -
#pragma mark Shared Singleton
+ (FirstPass *) singleton {
    static FirstPass *singleton;
    @synchronized(self) {
        if (!singleton){
            singleton = [[FirstPass alloc] init];
            // Iniciando flags
            singleton.canUpdateLocation = YES;
            singleton.canCheckTimedServices = YES;
            singleton.autoLocationServicesUpdate = YES;
            singleton.isGlobalServicesRunning = NO;
        }
        return singleton;
    }
}

#pragma mark -
#pragma mark A: Temporização e Controle de sessão
// Inicia todos os serviços
+ (void) AStartServices {
    if(![FirstPass singleton].isGlobalServicesRunning){
        // Levantando flags
        [FirstPass singleton].canCheckTimedServices = YES;
        [FirstPass singleton].autoLocationServicesUpdate = YES;
        [FirstPass singleton].canUpdateLocation = YES;
        [FirstPass singleton].isGlobalServicesRunning = YES;
        // Chamando
        [FirstPass AStartTimedServices];
        [FirstPass CStartLocationServices];
    }
    else {
        NSLog(@"Aviso: não iniciará novos serviços porque os serviço globais estão rodando ainda");
    }
}
+ (void) AStopServices {
    if([FirstPass singleton].isGlobalServicesRunning){
        // Levantando flags
        [FirstPass singleton].canCheckTimedServices = NO;
        [FirstPass singleton].autoLocationServicesUpdate = YES;
        [FirstPass singleton].canUpdateLocation = NO;
        [FirstPass singleton].isGlobalServicesRunning = NO;
        // Chamando
        [FirstPass AStopTimedServices];
        [FirstPass CStopLocationServices];
    }
    else {
        NSLog(@"Aviso: não parará novos serviços porque não há nada rodando");
    }
}
+ (void) AStartTimedServices {
    [[FirstPass singleton] ATimerFired];
}
+ (void) AStopTimedServices {
    [FirstPass singleton].canCheckTimedServices = NO;
}
- (void) ATimerFired {
	// 1. Timed service: verificar atualizações
	//WBListRequestModel *model = [[WBListRequestModel alloc] initWithWBID:[FirstPass singleton].userModel.WBID pagina:1];
	//[FirstPass BGetNotifications:model withDelegate:self];
	// Disparação do tempo de atualização
    static int i = 0;
    if([FirstPass singleton].canCheckTimedServices){
        [NSTimer scheduledTimerWithTimeInterval:FP_SECONDS_UPDATE target:self selector:@selector(ATimerFired) userInfo:nil repeats:NO];
        NSLog(@"Timer interation... %d", i++);
    }
}
+ (BOOL) ACheckAndStoreLoggedUserInfo {
    NSLog(@"Processo A: Verificando cache de usuário...");
    if ([TRBootstrap fileExists:FP_USERFILE]) {
        NSLog(@"Processo A: Usuário encontrado, lendo arquivo...");
        NSDictionary *package = [TRBootstrap fileRead:FP_USERFILE];
		// Carregando
        NSLog(@"Processo A: Arquivo carregado: %@", package);
        [FirstPass singleton].currentUser = package;
        return true;
    }
    NSLog(@"Processo A: Não há usuário em cache, pede login.");
    return false;
}
+ (void) AStoreLoggedUserInfoWith: (NSDictionary *) loggedUserInfo {
    NSLog(@"Processo A: Gravando info de usuário após login ou cadastro...");
    [TRBootstrap fileWrite:loggedUserInfo andFileName:FP_USERFILE];
    NSLog(@"Processo A: Arquivo gravado %@", loggedUserInfo);
    [FirstPass ACheckAndStoreLoggedUserInfo];
}
+ (void) APerformLogout {
    NSLog(@"Processo A: Fazendo logout, tchau tchau :)");
    [TRBootstrap fileDelete:FP_USERFILE];
}

#pragma mark -
#pragma mark B: Recebimento de dados
+ (ASIFormDataRequest *) BInitDefaultFormRequest: (NSString *) url andJSON: (NSDictionary *) json andDelegate: (id<ASIHTTPRequestDelegate>) delegate {
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    ASIFormDataRequest* req = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    [req setPostValue:[jsonWriter stringWithObject:json] forKey:@"json"];
	[req setRequestMethod:@"POST"];
    [req setUseKeychainPersistence:YES];
    [req setDelegate:delegate];
    return req;
}
// Serviço: Salvar algumas alterações do usuário
/*+ (void) BPostSaveUserChanges: (WBUserLocatedModel *) model withDelegate: (id<ASIHTTPRequestDelegate>) delegate {
	ASIFormDataRequest* req = [FirstPass BInitDefaultFormRequest:FP_API_USER_SAVE andJSON:[model dictionaryRepresentation] andDelegate:delegate];
    [req startAsynchronous];
}*/

#pragma mark -
#pragma mark C: Location Manager Delegate
+ (void) CStartLocationServices {
	// Por enquanto não deixa atualizar a localização
    [FirstPass singleton].canUpdateLocation = YES;
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = [FirstPass singleton];
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    [FirstPass singleton].locationManager = locationManager;
}
+ (void) CStopLocationServices {
    [FirstPass singleton].canUpdateLocation = NO;
    if([FirstPass singleton].locationManager != nil){
        [[FirstPass singleton].locationManager stopUpdatingLocation];
        [FirstPass singleton].locationManager = nil;
    }
}
+ (BOOL) CNewLocationChangedTooMuch: (CLLocationCoordinate2D) newLocationCoordinate comparingTo: (CLLocationCoordinate2D) oldLocationCoordinate {
    int difflat = abs(newLocationCoordinate.latitude * FP_LOCATION_RADIOS_MULTIPLY -
                      oldLocationCoordinate.latitude * FP_LOCATION_RADIOS_MULTIPLY);
    int difflng = abs(newLocationCoordinate.longitude*FP_LOCATION_RADIOS_MULTIPLY - oldLocationCoordinate.longitude*FP_LOCATION_RADIOS_MULTIPLY);
    return difflat > FP_LOCATION_RADIOS_TO_CHANGE || difflng > FP_LOCATION_RADIOS_TO_CHANGE;
}
+ (NSString *) CLocationFormatForServer: (CLLocationCoordinate2D) coordinate {
    int lat = coordinate.latitude * FP_LOCATION_RADIOS_MULTIPLY;
    int lng = coordinate.longitude * FP_LOCATION_RADIOS_MULTIPLY;
    return [NSString stringWithFormat:@"%d,%d", lat, lng];
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if([FirstPass CNewLocationChangedTooMuch:newLocation.coordinate comparingTo:oldLocation.coordinate]) {
        NSLog(@"---- ATUALIZA LOCALIZACAO:");
        NSLog(@"New (%f, %f) Old (%f, %f)", newLocation.coordinate.latitude, newLocation.coordinate.longitude, oldLocation.coordinate.latitude, oldLocation.coordinate.longitude);
    }
    /*if([FirstPass singleton].canUpdateLocation && ([FirstPass CNewLocationChangedTooMuch:newLocation.coordinate comparingTo:oldLocation.coordinate] || ![userLocationStr isEqualToString:[FirstPass CLocationFormatForServer:newLocation.coordinate]])){
        // Atualiza coordenadas
		
    }*/
    if(!self.autoLocationServicesUpdate){
        [FirstPass CStopLocationServices];
    }
}

#pragma mark -
#pragma mark E: Log de Erros
+ (void) ELogConnectionError {
    
}
+ (void) EDisplayErrorMessage: (NSString *) errorMessage {
	UIAlertView *alerta = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alerta show];
}

#pragma mark -
#pragma mark P: Request Push Notifications
+ (void) PRequestPermissionPushNotifications {
	// Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
}

#pragma mark -
#pragma mark ASI HTTP Request
- (void) requestFailed:(ASIHTTPRequest *)request {
    // Log erro
	NSLog(@"------> Não conseguiu informações da URL: %@", [request.url absoluteString]);
}

- (void) requestFinished:(ASIHTTPRequest *)request {
    if([FirstPass singleton].canCheckTimedServices){
        NSDictionary *json = [TRBootstrap JSONWithRawData:[request responseData]];
		// Identifica o retorno por causa da URL
		// Retorno de atualização de posição geográfica
		if([[request.url absoluteString] isEqualToString:@""]){
			
		}
		// Atualizando o device token
		else if([[request.url absoluteString] isEqualToString:@"token"]){
			NSLog(@"Retorno Device Token %@", json);
		}
    }
}

@end