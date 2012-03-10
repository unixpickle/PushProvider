//
//  ANAppDelegate.h
//  TCBPushAdmin
//
//  Created by Alex Nichol on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h> 
#include <sys/types.h>
#include <stdlib.h>
#include <unistd.h>
#import "KBDecodeObjC.h"
#import "KBEncodeObjC.h"

#define kPushAdminHost "localhost"
#define kPushAdminPort 1337

@interface ANAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource> {
    NSThread * readThread;
    NSThread * writeThread;
    NSMutableArray * dictBuffer;
    NSArray * deviceIDs;
    int fileDesc;
    
    IBOutlet NSTableView * tableView;
    IBOutlet NSTextField * alertField;
    IBOutlet NSTextField * badgeField;
    IBOutlet NSTextField * soundField;
    IBOutlet NSButton * sendButton;
    IBOutlet NSButton * reloadButton;
    IBOutlet NSButton * reconnectButton;
}

@property (assign) IBOutlet NSWindow * window;

- (int)openConnection;
- (void)sendDictionary:(NSDictionary *)aDictionary;
- (void)handleDictionary:(NSDictionary *)aDictionary;
- (void)handleClosed;

- (IBAction)refreshDevices:(id)sender;
- (IBAction)sendNotification:(id)sender;
- (IBAction)reconnect:(id)sender;

@end
