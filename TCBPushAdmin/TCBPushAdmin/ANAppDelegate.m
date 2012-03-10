//
//  ANAppDelegate.m
//  TCBPushAdmin
//
//  Created by Alex Nichol on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ANAppDelegate.h"

@interface ANAppDelegate (Private)

- (void)writeThread;
- (void)readThread;

@end

@implementation ANAppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    dictBuffer = [[NSMutableArray alloc] init];
    [self reconnect:nil];
}

- (int)openConnection {
    struct sockaddr_in serv_addr;
    struct hostent * server;
    int port = kPushAdminPort;
    fileDesc = socket(AF_INET, SOCK_STREAM, 0);
    if (fileDesc < 0) {
        return fileDesc;
    }
    
    NSLog(@"Connecting...");
    
    server = gethostbyname(kPushAdminHost);
    if (!server) {
        return -1;
    }
    
    /* Zero the $serv_addr, set its family, and 
     * update its address from $server. */
    bzero((char *)&serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    bcopy((char *)server->h_addr, 
          (char *)&serv_addr.sin_addr.s_addr,
          server->h_length);
    serv_addr.sin_port = htons(port);
    if (connect(fileDesc, (const struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0) {
        return -1;
    }
    NSLog(@"Connected.");
    return fileDesc;
}

#pragma mark - Actions -

- (IBAction)refreshDevices:(id)sender {
    [reloadButton setEnabled:NO];
    NSDictionary * dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"list", @"cmd", nil];
    [self sendDictionary:dictionary];
}

- (IBAction)sendNotification:(id)sender {
    NSInteger row = [tableView selectedRow];
    if (row < 0 || row > [deviceIDs count]) {
        NSBeep();
        return;
    }
    NSData * token = [deviceIDs objectAtIndex:row];
    
    NSString * alert = [alertField stringValue];
    NSString * sound = [soundField stringValue];
    NSString * badge = [badgeField stringValue];
    NSMutableDictionary * info = [[NSMutableDictionary alloc] initWithObjectsAndKeys:token, @"device", nil];
    if ([alert length] > 0) [info setObject:alert forKey:@"alert"];
    if ([sound length] > 0) [info setObject:sound forKey:@"sound"];
    if ([badge length] > 0) [info setObject:[NSNumber numberWithInt:[badge intValue]] forKey:@"badge"];
    
    NSDictionary * packet = [NSDictionary dictionaryWithObjectsAndKeys:
                             info, @"info", @"note", @"cmd", nil];
    [self sendDictionary:packet];
}

- (IBAction)reconnect:(id)sender {
    [readThread cancel];
    [writeThread cancel];
    readThread = nil;
    writeThread = nil;
    @synchronized (dictBuffer) {
        [dictBuffer removeAllObjects];
    }
    if (fileDesc > 0) {
        close(fileDesc);
        fileDesc = 0;
    }
    
    [reloadButton setEnabled:NO];
    [sendButton setEnabled:NO];
    
    if ([self openConnection] < 0) {
        NSRunAlertPanel(@"Connection failed.", @"Failed to connect to push host.", @"OK", nil, nil);
    } else {
        readThread = [[NSThread alloc] initWithTarget:self selector:@selector(readThread) object:nil];
        writeThread = [[NSThread alloc] initWithTarget:self selector:@selector(writeThread) object:nil];
        [readThread start];
        [writeThread start];
        NSDictionary * dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"admin", @"type", nil];
        [self sendDictionary:dictionary];
        [self refreshDevices:nil];
        [reconnectButton setEnabled:NO];
        [sendButton setEnabled:YES];
    }
}

#pragma mark - Table View -

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [deviceIDs count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSData * theData = [deviceIDs objectAtIndex:row];
    NSMutableString * devStr = [[NSMutableString alloc] init];
    const unsigned char * bytes = (const unsigned char *)[theData bytes];
    for (NSUInteger i = 0; i < [theData length]; i++) {
        [devStr appendFormat:@"%02x", bytes[i]];
    }
    return devStr;
}

#pragma mark - IO -

- (void)sendDictionary:(NSDictionary *)aDictionary {
    @synchronized (dictBuffer) {
        [dictBuffer addObject:aDictionary];
    }
}

- (void)handleDictionary:(NSDictionary *)aDictionary {
    if ([[aDictionary objectForKey:@"cmd"] isEqualToString:@"list"]) {
        [reloadButton setEnabled:YES];
        deviceIDs = [aDictionary objectForKey:@"devices"];
        [tableView reloadData];
    }
}

- (void)handleClosed {
    [writeThread cancel];
    [readThread cancel];
    writeThread = nil;
    readThread = nil;
    close(fileDesc);
    fileDesc = 0;
    [reconnectButton setEnabled:YES];
    [reloadButton setEnabled:NO];
    [sendButton setEnabled:NO];
}

#pragma mark Private

- (void)writeThread {
    @autoreleasepool {
        while (true) {
            if ([[NSThread currentThread] isCancelled]) break;
            NSDictionary * packet = nil;
            @synchronized (dictBuffer) {
                if ([dictBuffer count] > 0) {
                    packet = [dictBuffer objectAtIndex:0];
                    [dictBuffer removeObjectAtIndex:0];
                }
            }
            if (packet) kb_encode_full_fd(packet, fileDesc);
            [NSThread sleepForTimeInterval:0.1];
        }
    }
}

- (void)readThread {
    @autoreleasepool {
        while (true) {
            NSDictionary * dictionary = (NSDictionary *)kb_decode_full_fd(fileDesc);
            if (!dictionary) {
                if (![[NSThread currentThread] isCancelled]) {
                    [self performSelectorOnMainThread:@selector(handleClosed)
                                           withObject:nil
                                        waitUntilDone:NO];
                }
                break;
            }
            if ([[NSThread currentThread] isCancelled]) break;
            [self performSelectorOnMainThread:@selector(handleDictionary:)
                                   withObject:dictionary
                                waitUntilDone:NO];
        }
    }
}

@end
