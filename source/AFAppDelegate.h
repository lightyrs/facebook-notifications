//
//  AFAppDelegate.h
//  FB Notify
//
//  Created by Adrien Friggeri on 30/07/12.
//  Copyright (c) 2012 Adrien Friggeri. All rights reserved.
//

#import <PhFacebook/PhFacebook.h>

@interface AFAppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate, PhFacebookDelegate>

@property IBOutlet NSWindow *window;
@property PhFacebook *fb;
@property NSTimer *timer;
@property NSUserNotificationCenter *center;
@property NSStatusItem* statusItem;
@property IBOutlet NSMenu *statusMenu;
@property IBOutlet NSMenuItem *statusMenuUserInfo;
@property IBOutlet NSMenuItem *connectMenuItem;

- (void)tokenResult:(NSDictionary *)result;
- (void)requestResult:(NSDictionary *)result;
- (void)willShowUINotification:(PhFacebook *)sender;
- (void)didDismissUI:(PhFacebook *)sender;
- (IBAction)connectToFacebookFromMenu:(id)sender;

@end
