//
//  AFAppDelegate.m
//  FB Notify
//
//  Created by Adrien Friggeri on 30/07/12.
//  Copyright (c) 2012 Adrien Friggeri. All rights reserved.
//

#import <PhFacebook/PhFacebook.h>
#import "AFAppDelegate.h"
#import "FacebookNotification.h"

@implementation AFAppDelegate

@synthesize timer;
@synthesize fb;
@synthesize center;
@synthesize statusMenu;
@synthesize statusMenuUserInfo;
@synthesize connectMenuItem;
@synthesize statusItem;

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
  NSUserNotification *userNotification = notification.userInfo[NSApplicationLaunchUserNotificationKey];
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  
  self.center = [NSUserNotificationCenter defaultUserNotificationCenter];
  self.center.delegate = self;
  
  self.fb = [[PhFacebook alloc] initWithApplicationID: @"399093420154849" delegate: self];
  
  if ([userDefaults boolForKey:@"shouldAutoConnect"]){
    [self connectToFacebook];
  }
  
  if (userNotification) {
    [self userActivatedNotification:userNotification];
  }
  
}

- (void)awakeFromNib {
  self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
  self.statusItem.highlightMode = YES;
  self.statusItem.menu = self.statusMenu;
  self.statusItem.image = [NSImage imageNamed:@"fb_offline"];
  self.connectMenuItem.title = @"Connect…";
  [self.statusMenuUserInfo setHidden:YES];
}

#pragma mark Menu Items

- (void) setConnected:(BOOL)connected
{
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  if (connected){
    self.statusItem.image = [NSImage imageNamed:@"fb_connected"];
    self.connectMenuItem.title = @"Logout…";
    [userDefaults setBool:YES forKey:@"shouldAutoConnect"];
  } else {
    self.statusItem.image = [NSImage imageNamed:@"fb_offline"];
    self.connectMenuItem.title = @"Connect…";
    [self.statusMenuUserInfo setHidden:YES];
    [userDefaults setBool:NO forKey:@"shouldAutoConnect"];
  }
  [userDefaults synchronize];
}

- (IBAction)connectToFacebookFromMenu:(id)sender {
  if (self.fb.accessToken){
    [self.fb invalidateCachedToken];
    [self setConnected:NO];
  } else {
    [self connectToFacebook];
  }
}

- (void)dispatchNotifications:(NSArray*)notifications {
  for (NSUserNotification *notification in center.deliveredNotifications) {
    BOOL shouldRemoveNotification = YES;
    FacebookNotification *other = [FacebookNotification fromNotification:notification];
    for (FacebookNotification *received in notifications) {
      if ([received isEqualTo:other]){
        shouldRemoveNotification = NO;
      }
    }
    if (shouldRemoveNotification){
      [self.center removeDeliveredNotification:notification];
    }
  }
  [notifications makeObjectsPerformSelector:@selector(deliverTo:) withObject:self.center];
}

#pragma mark Notification handling

- (void)userNotificationCenter:(NSUserNotificationCenter *)notificationCenter didActivateNotification:(NSUserNotification *)notification
{
  [self userActivatedNotification:notification];
}

- (void)userActivatedNotification:(NSUserNotification*)userNotification
{
  NSWorkspace * ws = [NSWorkspace sharedWorkspace];
  FacebookNotification *notification = [FacebookNotification fromNotification:userNotification];
  [self.center removeDeliveredNotification:userNotification];
  [self.fb sendRequest:[NSString stringWithFormat:@"%@?unread=0", notification.uid]
                params:@{}
        usePostRequest:YES];
  [ws openURL: [NSURL URLWithString:notification.url]];
}

#pragma mark Facebook
- (void) connectToFacebook{
  [self.fb getAccessTokenForPermissions: @[ @"manage_notifications" ] cached: NO];
}

- (void) didConnectToFacebook
{
  [self setConnected:YES];
  [self.fb sendRequest:@"me"];
  self.timer = [NSTimer scheduledTimerWithTimeInterval:300.0
                                                target:self
                                              selector:@selector(checkNotifications:)
                                              userInfo:nil
                                               repeats:YES];
  [self.timer fire];
  self.connectMenuItem.title = @"Logout…";
}

- (void) checkNotifications:(id)sender
{
  [self.fb sendRequest:@"me/notifications" params:@{/*@"include_read":@"1"*/} usePostRequest:NO];
}

- (void) setNameInMenu:(NSString*)userName
{
  self.statusMenuUserInfo.title = [NSString stringWithFormat:@"Connected as %@", userName];
  [self.statusMenuUserInfo setHidden:NO];
}

#pragma mark PhFacebookDelegate methods

- (void)tokenResult:(NSDictionary *)result
{
  if ([[result valueForKey: @"valid"] boolValue]){
    [self didConnectToFacebook];
  }
  else {
    
  }
  
}

- (NSDictionary*) parseJSON:(NSString*)json
{
  NSError* error;
  NSData* data = [json dataUsingEncoding:NSUTF8StringEncoding];
  return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
}

- (void)requestResult:(NSDictionary *)result
{
  NSDictionary *jsonResult = [self parseJSON:result[@"result"]];
  if ([result[@"request"] isEqualTo:@"me"]){
    [self setNameInMenu:jsonResult[@"name"]];
  } else if ([result[@"request"] isEqualTo:@"me/notifications"]){
    NSArray *jsonNotifications = jsonResult[@"data"];
    NSMutableArray *notifications = [NSMutableArray arrayWithCapacity:[jsonNotifications count]];
    NSArray *sortedNotification;
    
    for (NSDictionary* dict in jsonNotifications) {
      [notifications addObject:[FacebookNotification fromDict:dict]];
    }
    
    sortedNotification = [notifications sortedArrayUsingSelector:@selector(compare:)];
    [self dispatchNotifications:sortedNotification];
  }
}

- (void)willShowUINotification:(PhFacebook *)sender
{
  
}

- (void)didDismissUI:(PhFacebook *)sender
{
  
}

@end
