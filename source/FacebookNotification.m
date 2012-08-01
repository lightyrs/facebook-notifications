//
//  FacebookNotification.m
//  Facebook
//
//  Created by Adrien Friggeri on 31/07/12.
//  Copyright (c) 2012 Adrien Friggeri. All rights reserved.
//

#import "FacebookNotification.h"

@implementation FacebookNotification
@synthesize uid;
@synthesize message;
@synthesize date;
@synthesize url;

+ (id)fromDict:(NSDictionary*)dict
{
  return [[FacebookNotification alloc] initWithDict:dict];
}
+ (id)fromNotification:(NSUserNotification*)notification
{
  return [[FacebookNotification alloc] initWithNotification:notification];
}
- (id)initWithDict:(NSDictionary *)dict
{
  self = [super init];
  if(self){
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    self.message = dict[@"title"];
    self.date = [dateFormatter dateFromString:dict[@"updated_time"]];
    self.uid = dict[@"id"];
    self.url = dict[@"link"];
  }
  return self;
}

- (id)initWithNotification:(NSUserNotification*)notification
{
  self = [super init];
  if (self){
    self.message = notification.informativeText;
    self.date    = notification.deliveryDate;
    self.uid     = notification.userInfo[@"id"];
    self.url     = notification.userInfo[@"url"];
  }
  return self;
}

- (BOOL)wasPresentIn:(NSUserNotificationCenter*)center
{
  for (NSUserNotification *notification in center.deliveredNotifications) {
    FacebookNotification *other = [[FacebookNotification alloc] initWithNotification:notification];
    if ([self isEqualTo:other]) return YES;
  }
  return NO;
}
- (void)deliverTo:(NSUserNotificationCenter*)center{
  if ([self wasPresentIn:center]) return;
  
  NSUserNotification *notification = [NSUserNotification new];
  notification.informativeText = self.message;
  notification.deliveryDate    = self.date;
  notification.title           = @"Facebook";
  notification.userInfo        = @{@"id" : self.uid,@"url": self.url};
  [center deliverNotification:notification];
}

- (BOOL)isEqualTo:(FacebookNotification*)other
{
  return [self.uid isEqualTo:other.uid] && [self.date isEqualTo:other.date];
}

- (NSComparisonResult)compare:(FacebookNotification*)other {
  return [other.date compare:self.date];
}

@end
