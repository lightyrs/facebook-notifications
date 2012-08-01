//
//  FacebookNotification.h
//  Facebook
//
//  Created by Adrien Friggeri on 31/07/12.
//  Copyright (c) 2012 Adrien Friggeri. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FacebookNotification : NSObject
@property NSString* message;
@property NSString* url;
@property NSDate* date;
@property NSString* uid;

+ (id)fromDict:(NSDictionary*)dict;
+ (id)fromNotification:(NSUserNotification*)notification;
- (id)initWithDict:(NSDictionary *)dict;
- (id)initWithNotification:(NSUserNotification*)notification;
- (void)deliverTo:(NSUserNotificationCenter*)center;
- (NSComparisonResult)compare:(FacebookNotification*)other;
@end
