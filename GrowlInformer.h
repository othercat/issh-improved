//
//  GrowlInformer.h
//  iSSH
//
//  Created by 明城 on 10-5-14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Growl/Growl.h>

@interface GrowlInformer : NSObject <GrowlApplicationBridgeDelegate> {

}
-(void) growlAlert:(NSString *)message title:(NSString *)title;
-(void) growlAlertWithClickContext:(NSString *)message title:(NSString *)title;
@end
