//
//  GrowlInformer.m
//  iSSH
//
//  Created by 明城 on 10-5-14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GrowlInformer.h"

@implementation GrowlInformer
    - (id) init { 
        if (self = [super init]) {
            [GrowlApplicationBridge setGrowlDelegate:self];
        }
        return self;
    }
     
    - (NSDictionary *) registrationDictionaryForGrowl {
        NSArray      *array = [NSArray arrayWithObjects:@"issh", @"error", nil];
        NSDictionary *dict  = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithInt: 1],
                                 @"TicketVersion",
                                 array,
                                 @"AllNotifications",
                                 array,
                                 @"DefaultNotifications",
                                 nil];
        return dict;
    }
     
    - (void) growlNotificationWasClicked:(id)clickContext {
        /*
        if (clickContext && [clickContext isEqualToString:@"exampleClickContext"])
            [self exampleClickContext];
            */
        return;
    }
     
    /* These methods are not required to be implemented, so we will skip them in this example 
    - (NSString *) applicationNameForGrowl;
    - (NSData *) applicationIconDataForGrowl;
    - (void) growlNotificationTimedOut:(id)clickContext;
    */ 
    /* There is no good reason not to rely on the what Growl provides for the next two methods, in otherwords, do not override these methods
    - (void) growlIsReady;
    - (void) growlIsInstalled;
    */
    /* End Methods from GrowlApplicationBridgeDelegate */
     
    /* Simple method to make an alert with growl that has no click context */
    -(void) growlAlert:(NSString *)message title:(NSString *)title {
        [GrowlApplicationBridge notifyWithTitle:title
                                description:message
                                notificationName:@"issh"
                                iconData:nil
                                priority:0
                                isSticky:NO
                                clickContext:nil];
    }
     
    /* Simple method to make an alert with growl that has a click context */
    -(void) growlAlertWithClickContext:(NSString *)message title:(NSString *)title {
        [GrowlApplicationBridge notifyWithTitle:title
                                    description:message
                               notificationName:@"issh"
                                       iconData:nil
                                       priority:0
                                       isSticky:NO];
    }
     
    - (void) dealloc { 
        [super dealloc]; 
    }
@end
