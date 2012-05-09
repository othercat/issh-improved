
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

#import <Cocoa/Cocoa.h>
#import <AGProcess/AGProcess.h>
#import <EMKeychainProxy.h>
#import <EMKeychainItem.h>
#import "GrowlInformer.h"

#define ISSH_STATUS_CONNECTED       1
#define ISSH_STATUS_NOT_CONNECTED   0

@interface MSController : NSObject {
	IBOutlet NSWindow    *mainWindow;
	IBOutlet NSWindow    *preferencesWindow;
    IBOutlet NSTextField *localPort;
    IBOutlet NSTextField *portNumber;
	IBOutlet NSSecureTextField *passWord;
    IBOutlet NSTextField  *remoteAddress;
    IBOutlet NSTextField  *remotePort;
    IBOutlet NSTextField  *socksPort;
    IBOutlet NSButtonCell *portForward;
	IBOutlet NSButtonCell *portDynamic;
    IBOutlet NSTextField  *userName;
	IBOutlet NSMenu       *menu;
	IBOutlet NSMenuItem   *con;
	IBOutlet NSMenuItem   *disc;
	IBOutlet NSButton     *autoStart;
	IBOutlet NSButton     *useGrowl;
	IBOutlet NSButton     *start;
	IBOutlet NSButton     *recon;


	NSMenuItem   *conAndDis;
	NSStatusItem *stateItem;
	NSTask *task;
	bool running;
	NSTimer *timer;
	NSTimer *onlineTime;
	NSUserDefaults *defaults;

	AGProcess    *process;
	NSEnumerator *processEnumerator;

    GrowlInformer *growlInformer;
}

    - (IBAction)isshHelp:(id)sender;
    - (IBAction)openSetting:(id)sender;
    - (IBAction)startCon:(id)sender;
    - (IBAction)stopCon:(id)sender;
    - (IBAction)stopConQuit:(id)sender;
    - (BOOL)checkFields;
    - (int)checkStatus;
    - (void)activateStatusMenu;
    - (void)addAppAsLoginItem;
    - (void)checkIfOnline:(NSTimer*)Time;
    - (void)deleteAppFromLoginItem;
    - (void)errorCheck:(NSTimer*)timer;
    - (void)launch;
    - (void)loadSetting;
    - (void)saveSetting;
    - (void)startCheck;
    - (void)terminate;
    - (void)runAlertPanel:(NSString *) message title:(NSString *) title;
@end
