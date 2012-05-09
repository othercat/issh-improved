
/*

 Copyright (c) 2008, Alex Jones
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that
 the following conditions are met:
 
 	1.	Redistributions of source code must retain the above copyright notice, this list of conditions and the
 		following disclaimer.
  
 	2.	Redistributions in binary form must reproduce the above copyright notice, this list of conditions and
 		the following disclaimer in the documentation and/or other materials provided with the distribution.
  
 	3.	Neither the name of MacServe nor the names of its contributors may be used to endorse
 		or promote products derived from this software without specific prior written permission.
  
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
 TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */

#import "MSController.h"

@implementation MSController

+ (void)initialize {
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
	[ defaultValues setObject:@"" forKey: @"remoteAddress" ];
	[ defaultValues setObject:@"" forKey: @"userName" ];
	[ defaultValues setObject:@"" forKey: @"portNumber" ];
	[ defaultValues setObject:@"5900" forKey: @"localPort" ];
	[ defaultValues setObject:@"5900" forKey: @"remotePort" ];
	[ defaultValues setObject:@"7070" forKey: @"socksPort" ];
	[ defaultValues setObject:@"d" forKey:@"port" ];

	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

- (void)awakeFromNib {
	[[mainWindow dockTile] setShowsApplicationBadge: NO];
	
	[self activateStatusMenu];

    growlInformer = [[GrowlInformer alloc] init];

    conAndDis = [[NSMenuItem alloc] 
        initWithTitle:NSLocalizedString(@"CON", @"Connect")
               action:@selector(startCon:)
        keyEquivalent:@""];

    [self loadSetting]; // Load storaged settings
    if([self checkStatus] == ISSH_STATUS_CONNECTED) {
        NSLog(@"ssh is connected");
        [conAndDis setAction:@selector(stopCon:)];
        [conAndDis setTitle:NSLocalizedString(@"DIS", @"Disconnect")];
        [stateItem setImage:[NSImage imageNamed:@"ok"]];
    } else {
        if ([autoStart state] == 1) {
            [self startCheck];
        }
    }

	[menu insertItem:conAndDis atIndex:0];
}


- (void)startCheck {
	NSLog(@"checking wether autostart");
	[self checkIfOnline:nil];
	onlineTime = [NSTimer scheduledTimerWithTimeInterval:10 
                                                  target:self 
                                                selector:@selector(checkIfOnline:) 
                                                userInfo:nil 
                                                 repeats:YES];

	[[NSRunLoop currentRunLoop] addTimer:onlineTime 
                                 forMode:NSDefaultRunLoopMode];	
}

- (void)checkIfOnline:(NSTimer*)Time {
	NSLog(@"checking if online");
    NSString *url = [NSString stringWithString:[remoteAddress stringValue]];
    NSTask *task2 = [[NSTask alloc] init];
    [task2 setLaunchPath:@"/sbin/ping"];
    NSArray *args = [NSArray arrayWithObjects:@"-c 1", url, nil];
    [task2 setArguments:args];
    
    NSPipe *outPipe = [[NSPipe alloc] init];
    [task2 setStandardOutput:outPipe];
    [outPipe release];
    
    [task2 launch];
    
    NSData *data = [[outPipe fileHandleForReading] readDataToEndOfFile];
    
    [task2 waitUntilExit];
    [task2 release];
    
    NSString *aString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSRange rang = [aString rangeOfString:@"1 packets transmitted, 1 packets received, 0.0% packet loss"];
    NSLog(@"locate in : %lu",rang.length);
    
    [aString release];
    
    if (rang.length == 0) {
        return;
    } else {
        [self launch];
        [Time invalidate];
    }
}

- (BOOL)windowShouldClose:(id)sender
{
	[self saveSetting];
	return YES;
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag {
	
	if(flag == NO){
		[ mainWindow makeKeyAndOrderFront:nil ];
		
	}
	else {
		if([ mainWindow isVisible ] == NO) {
			[ mainWindow makeKeyAndOrderFront:nil ];
		}
	}
	
	return NO;
}

- (void)loadSetting {
	NSLog(@"loadSetting");

	defaults = [ NSUserDefaults standardUserDefaults ];
	[ remoteAddress setStringValue: [ defaults objectForKey: @"remoteAddress" ]];
	[ userName setStringValue: [ defaults objectForKey: @"userName" ]];
	[ portNumber setStringValue: [ defaults objectForKey: @"portNumber" ]];
	[ localPort setStringValue: [ defaults objectForKey: @"localPort" ]];
	[ remotePort setStringValue: [ defaults objectForKey: @"remotePort" ]];
	[ socksPort setStringValue: [ defaults objectForKey: @"socksPort" ]];
	
	//NSLog(@"port value: %@",[defaults valueForKey:@"port"]);
	if ([[defaults valueForKey:@"port"] isEqualTo:@"f"]) {
		NSLog(@"f load");
		[portForward setState:1];
		[portDynamic setState:0];
	}
	else {
		NSLog(@"d load");
		[portForward setState:0];
		[portDynamic setState:1];
	}

	if ([[defaults valueForKey:@"auto"] isEqualTo:@"ture"]) {
		[autoStart setState:1];
	} else {
		[autoStart setState:0];
	}

	if ([[defaults valueForKey:@"useGrowl"] isEqualTo:@"ture"]) {
		[useGrowl setState:1];
	} else {
		[useGrowl setState:0];
	}

	if ([[defaults valueForKey:@"startup"] isEqualTo:@"ture"]) {
		[start setState:1];
	} else {
		[start setState:0];
	}
	
	if([[ EMKeychainProxy sharedProxy ] 
            genericKeychainItemForService: @"iSSH"
                             withUsername: @"MacServe" ] != nil) {
		[ passWord setStringValue: [[
            [ EMKeychainProxy sharedProxy ] 
    genericKeychainItemForService: @"iSSH"
                     withUsername: @"MacServe" ] password ]];
	}
}

- (void)saveSetting {
	NSLog(@"save");

	if(![ self checkFields ]) {
		return;
	}
	
    defaults = [ NSUserDefaults standardUserDefaults ];
	[ defaults setObject:[ remoteAddress stringValue ] forKey: @"remoteAddress" ];
	[ defaults setObject:[ userName stringValue ] forKey: @"userName" ];
	[ defaults setObject:[ portNumber stringValue ] forKey: @"portNumber" ];
	[ defaults setObject:[ localPort stringValue ] forKey: @"localPort" ];
	[ defaults setObject:[ remotePort stringValue ] forKey: @"remotePort" ];
	[ defaults setObject:[ socksPort stringValue ] forKey: @"socksPort" ];
	
	if ([portForward state]) {
		NSLog(@"f saved");
		[defaults setObject:@"f" forKey:@"port"];
	}
	else {
		NSLog(@"d saved");
		[defaults setObject:@"d" forKey:@"port"];
	}

	if ([autoStart state]) {
		[defaults setObject:@"ture" forKey:@"auto"];
	}
	else {
		[defaults setObject:@"false" forKey:@"auto"];
	}

    [defaults setObject: ([useGrowl state] ? @"ture" : @"false") forKey:@"useGrowl"];

	if ([start state]) {
		[defaults setObject:@"ture" forKey:@"startup"];
		[self addAppAsLoginItem];
	}
	else {
		[defaults setObject:@"false" forKey:@"startup"];
		[self deleteAppFromLoginItem];
	}

	
	if([[ EMKeychainProxy sharedProxy ] genericKeychainItemForService: @"iSSH" withUsername: @"MacServe" ] == nil) {
		[[ EMKeychainProxy sharedProxy ] addGenericKeychainItemForService: @"iSSH" withUsername: @"MacServe" password: [ passWord stringValue ]];		
	}
	else {
		[[[ EMKeychainProxy sharedProxy ] genericKeychainItemForService: @"iSSH" withUsername: @"MacServe" ] setPassword: [ passWord stringValue ]];
	}
	
}

- (IBAction)startCon:(id)sender {
	if ([onlineTime isValid] == YES) {
		[onlineTime invalidate];
	}
	
    [ self launch ];
}

- (IBAction)stopCon:(id)sender {
	[ self terminate ];
}

- (IBAction)stopConQuit:(id)sender {
	[ self terminate ];
    [ NSApp terminate: self ];
}

- (IBAction)isshHelp:(id)sender {
	[[ NSWorkspace sharedWorkspace ] openURL: [ NSURL URLWithString: @"http://code.google.com/p/issh-improved/"]];
}

- (void)launch {
	if(![self checkFields]) {
		return;
	}
	
	task = [[NSTask alloc] init];
	NSMutableDictionary *environment = [ NSMutableDictionary dictionaryWithDictionary: [[ NSProcessInfo processInfo ] environment ]];
    [ task setLaunchPath: @"/usr/bin/ssh"];
	
	[ environment removeObjectForKey:@"SSH_AGENT_PID" ];
	[ environment removeObjectForKey:@"SSH_AUTH_SOCK" ];
	[ environment setObject: [[ NSBundle mainBundle ] pathForResource: @"getPass" ofType: @"sh" ] forKey: @"SSH_ASKPASS" ];
	[ environment setObject: [ passWord stringValue ] forKey: @"PASS" ];
	[ environment setObject: @":0" forKey:@"DISPLAY" ];
	[ task setEnvironment: environment ];

    NSMutableArray *arguments = [ NSMutableArray array ];
	[ arguments addObject: @"-N" ];
	
	[ arguments addObject: [ NSString stringWithFormat: @"%@@%@", [ userName stringValue ], [ remoteAddress stringValue ] ] ];
	
	if([ portForward state ] == 1) {
	[ arguments addObject: @"-L" ];
	[ arguments addObject: [ NSString stringWithFormat: @"%@:localhost:%@", [ localPort stringValue ], [ remotePort stringValue ] ] ];
	NSLog(@"Forwarding port %@ on the local machine to port %@ on the remote machine", [ localPort stringValue ], [ remotePort stringValue ]);
	}
	else {
	[ arguments addObject: @"-D" ];
	[ arguments addObject: [ NSString stringWithFormat: @"localhost:%@", [ socksPort stringValue ] ] ];
	NSLog(@"SOCKS Proxy on port %@", [socksPort stringValue]);
	}
	
	[ arguments addObject: @"-p" ];
	if([[ portNumber stringValue ] isEqualToString:@"" ]) {
		[ arguments addObject: @"22" ];
		NSLog(@"Connecting on port 22");
	}
	else {
		
	[ arguments addObject: [ portNumber stringValue ] ];
	NSLog(@"Connecting on port %@", [ portNumber stringValue]);
	}
	
	[ arguments addObject: @"-F" ];
	[ arguments addObject: [[NSBundle mainBundle ] pathForResource: @"ssh_config" ofType: @"" ] ];
	
    [ task setArguments: arguments ];
	
    [ task launch ];
	NSLog(@"Started Connection");
    if ([useGrowl state] == 1) {
        [growlInformer growlAlert: NSLocalizedString(@"STATUS_CON", "Started Connection")
                            title: NSLocalizedString(@"CONN_NOTICE", "Connection Notice")];
    }
	
	[conAndDis setAction:@selector(stopCon:)];
	[conAndDis setTitle:NSLocalizedString(@"DIS", @"Disconnect")];
	
	[stateItem setImage:[NSImage imageNamed:@"ok"]];

	timer = [ NSTimer scheduledTimerWithTimeInterval:20 
                                              target:self 
                                            selector:@selector(errorCheck:)
                                            userInfo:nil
                                             repeats:YES];

	[[ NSRunLoop currentRunLoop ] addTimer:timer forMode:NSDefaultRunLoopMode ];

}


- (void)terminate {
	if([self checkStatus] == ISSH_STATUS_CONNECTED) {
		[conAndDis setAction:@selector(startCon:)];
		[conAndDis setTitle:NSLocalizedString(@"CON", @"Connect")];
		[stateItem setImage:[NSImage imageNamed:@"idle"]];

        [task terminate];
        [process terminate];

        if (true || [recon state] == 0) {
            [timer invalidate];
        }

        if ([useGrowl state] == 1) {
            [growlInformer growlAlert: NSLocalizedString(@"STATUS_NOT_CON", "Connection closed")
                                title: NSLocalizedString(@"CONN_NOTICE", "Connection Notice")];
        }

		NSLog(@"Connection closed");
	}
}


- (int)checkStatus {
	process = nil;
	processEnumerator = [[AGProcess allProcesses] objectEnumerator];
	while (process = [processEnumerator nextObject]) {
        if ([@"ssh" isEqualToString: [process command]]) {
			return ISSH_STATUS_CONNECTED;
		}
	}

	return ISSH_STATUS_NOT_CONNECTED;
}


- (void)errorCheck:(NSTimer*)timer {
	
	if([ self checkStatus ] == ISSH_STATUS_NOT_CONNECTED) {
		[conAndDis setAction:@selector(startCon:)];
		[conAndDis setTitle: NSLocalizedString(@"CON", @"Connect")];
		[stateItem setImage:[NSImage imageNamed:@"idle"]];

        NSString *message =[[NSString alloc] initWithString: NSLocalizedString(@"CHECK_SETTING", @"Check you have entered the settings correctly and that the remote computer is set up correctly")];
        NSString *title = [[NSString alloc] initWithString:NSLocalizedString(@"HAVE_ERROR", @"An error occurred")];
		
        if ([useGrowl state] == 1) {
            [growlInformer growlAlert:message title:title];
        } 
        /*else {
            NSAlert *alert = [[[NSAlert alloc] init] autorelease];
            [alert addButtonWithTitle: NSLocalizedString(@"OK", @"OK")];
            [alert setMessageText: title];
            [alert setInformativeText: message];
            [alert setAlertStyle: NSWarningAlertStyle];
            [alert runModal];
        }*/
		
		//[timer invalidate];
        [message release];
        [title release];
		
		if ([recon state] == 1) {
			[self startCheck];
		}
	}
}

- (void)runAlertPanel:(NSString *) message title:(NSString *) title {
                /*
        forceUseGrlow:(BOOL) forceUseGrlow
            needClick:(BOOL) needClick 
            */
    if ([useGrowl state] == 1) {
            [growlInformer growlAlert:message title:title];
        /*
        if (needClick) {
            [growlInformer growlAlertWithClickContext:message title:title];
        } else {
        }
        */
    } else {
		NSRunAlertPanel(title, message, NSLocalizedString(@"OK", @"OK"), nil, nil);
    }
}


- (BOOL)checkFields {
	if([[ remoteAddress stringValue ] isEqualToString:@"" ]) {
        [self runAlertPanel: [NSString stringWithFormat:@"You have not entered an Address"] 
                                                  title:@"Settings Incomplete"];
		return NO;
	}
	
	if([[ userName stringValue ] isEqualToString:@"" ]) {
        [self runAlertPanel: [NSString stringWithFormat:@"You have not entered a User Name"]
                                                  title:@"Settings Incomplete"];
		return NO;
	}
	
	if([[ passWord stringValue ] isEqualToString:@"" ]) {
        [self runAlertPanel: [NSString stringWithFormat:@"You have not entered a Password"]
                                                  title:@"Settings Incomplete"];
		return NO;
	}
	
	if([ portForward state ] == 1) {
		if([[ localPort stringValue ] isEqualToString:@"" ] || [[ remotePort stringValue ] isEqualToString:@"" ]) {
            [self runAlertPanel: [NSString stringWithFormat:@"You have not entered a Port for forwarding"] 
                                                      title:@"Settings Incomplete"];
			return NO;
		}
	}
	else {
		if([[ socksPort stringValue ] isEqualToString:@"" ]) {
        [self runAlertPanel: [NSString stringWithFormat:@"You have not entered a Port for the SOCKS Proxy"] 
                                                  title:@"Settings Incomplete"];
			return NO;
		}
	}
	
	return YES;
}


- (void)activateStatusMenu {
	NSStatusBar *bar = [NSStatusBar systemStatusBar];
	stateItem = [bar statusItemWithLength:NSVariableStatusItemLength]; 
	[stateItem retain];
	[stateItem setImage:[NSImage imageNamed:@"idle"]];
	[stateItem setHighlightMode:YES]; 
	[stateItem setMenu:menu];
}


- (IBAction)openSetting:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
	[ mainWindow makeKeyAndOrderFront:sender ];
}


-(void) addAppAsLoginItem {
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
	
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:appPath]; 
	
	// Create a reference to the shared file list.
	// We are adding it to the current user only.
	// If we want to add it all users, use
	// kLSSharedFileListGlobalLoginItems instead of
	//kLSSharedFileListSessionLoginItems
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
															kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) {
		//Insert an item to the list.
		LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
																	 kLSSharedFileListItemLast, NULL, NULL,
																	 url, NULL, NULL);
		if (item) {
			CFRelease(item);
		}
	}	
	if (loginItems)
        CFRelease(loginItems);
}

-(void) deleteAppFromLoginItem {
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
	
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:appPath]; 
	
	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
															kLSSharedFileListSessionLoginItems, NULL);
	
	if (loginItems) {
		UInt32 seedValue;
		//Retrieve the list of Login Items and cast them to
		// a NSArray so that it will be easier to iterate.
		NSArray  *loginItemsArray = (NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
	/*	int i = 0;
		for(i ; i< [loginItemsArray count]; i++){
			LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)[loginItemsArray
																		objectAtIndex:i];
			//Resolve the item with URL
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(NSURL*)url path];
				if ([urlPath compare:appPath] == NSOrderedSame){
					LSSharedFileListItemRemove(loginItems,itemRef);
				}
			}
		}
	 */
		for(id itemRef in loginItemsArray){
			if (LSSharedFileListItemResolve((LSSharedFileListItemRef)itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(NSURL*)url path];
				if ([urlPath compare:appPath] == NSOrderedSame){
					LSSharedFileListItemRemove(loginItems,(LSSharedFileListItemRef)itemRef);
				}
			}
			
		}
		[loginItemsArray release];
	}
}

- (void)dealloc {
	[task release];
	[process release];
	[timer release];
	[onlineTime release];
	[defaults release];
	[processEnumerator release];
	[growlInformer release];
	[super dealloc];
}

@end
