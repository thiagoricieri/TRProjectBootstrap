//
//  FPAppDelegate.m
//  First Pass
//
//  Created by Thiago Ricieri on 06/10/13.
//  Copyright (c) 2013 First Pass. All rights reserved.
//


#import "FirstPass.h"
#import "TRBootstrap.h"
#import "FPAppDelegate.h"

@implementation FPAppDelegate

#pragma mark -
#pragma mark Application Start
- (void) buildApplication {
    // Settings
    // Analisa se há sessões abertas
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
	if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	}
	// Teste da aplicação
    if([FirstPass ACheckAndStoreLoggedUserInfo]) [self startFromHome];
    // Nova sessão precisa ser iniciada
    else [self startFromLogin];
}

- (void) startFromLogin {
    //WBSignInViewController *signIn = [[WBSignInViewController alloc] initWithNibName:nil bundle:nil];
    //self.window.rootViewController = signIn;
}

- (void) startFromHome {
    //NSLog(@"Bem-vindo de volta, %@.", [FirstPass sharedSingleton].userModel.name);
    // Primeira tela
    //WBGoBeerOptionsViewController *homeView = [[WBGoBeerOptionsViewController alloc] initWithNibName:nil bundle:nil];
    //UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:homeView];
    //nc.navigationBarHidden = YES;
    //self.window.rootViewController = nc;
    // Inicia serviços
    [FirstPass AStartServices];
	[FirstPass PRequestPermissionPushNotifications];
}
- (void) restartApplication {
    [FirstPass AStopServices];
    [FirstPass APerformLogout];
	if([FBSession.activeSession isOpen]) [FBSession.activeSession closeAndClearTokenInformation];
    NSLog(@"Terminando serviços porque pediram para o AppDelegate fazer logout.");
    [self startFromLogin];
}

#pragma mark -
#pragma mark Push Notificiations
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    NSString *dString = [[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
	//WBPushNotificationModel *pushModel = [[WBPushNotificationModel alloc] initWithWBID:[FirstPass sharedSingleton].userModel.WBID deviceToken:dString];
	//[FirstPass BPostPushNotification:pushModel withDelegate:[FirstPass sharedSingleton]];
	NSLog(@"My token is (string) %@", dString);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
	NSLog(@"Failed to get token, error: %@", error);
}

#pragma mark -
#pragma mark Facebook Stack
- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	return [FBSession.activeSession handleOpenURL:url];
}

#pragma mark -
#pragma mark Application Resume and Stuff

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = FP_BLUE;
    [self buildApplication];
    [self.window makeKeyAndVisible];
	// Foursquare credentials
	//[Foursquare2 setupFoursquareWithKey:FP_FOURSQUARE_CLIENTID secret:FP_FOURSQUARE_CLIENTSECRET callbackURL:FP_FOURSQUARE_REDIRECTURL];
	// returning
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	// We need to properly handle activation of the application with regards to Facebook Login
	// (e.g., returning from iOS 6.0 Login Dialog or from fast app switching).
	[FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
