//
//  DropboxSync.h
//  DropboxSync Cordova plugin
//
//  Created by Panurge
//  Credits Christophe Coenraets
//
//

#import <Cordova/CDV.h>
#import "DropboxSync.h"


@interface DropboxSync : CDVPlugin

- (void) initializeWithKeyAndSecret:(CDVInvokedUrlCommand*)command;

- (void) link:(CDVInvokedUrlCommand*)command;

- (void) checkLink:(CDVInvokedUrlCommand*)command;

- (void) unlink:(CDVInvokedUrlCommand*)command;

- (void) getDBFileSystem:(CDVInvokedUrlCommand*)command;

- (void) listFolder:(CDVInvokedUrlCommand*)command;

- (void) createFile:(CDVInvokedUrlCommand*)command;

- (void) createFolder:(CDVInvokedUrlCommand*)command;

- (void) deletePath:(CDVInvokedUrlCommand*)command;

- (void) movePath:(CDVInvokedUrlCommand*)command;

- (void) addObserver:(CDVInvokedUrlCommand*)command;

- (void) removeObserver:(CDVInvokedUrlCommand*)command;

- (void) readData:(CDVInvokedUrlCommand*)command;

- (void) readString:(CDVInvokedUrlCommand*)command;

- (void) writeContentsOfFile:(CDVInvokedUrlCommand*)command;

- (void) writeString:(CDVInvokedUrlCommand*)command;

- (void) update:(CDVInvokedUrlCommand*)command;

- (void) touch:(CDVInvokedUrlCommand*)command;

@property (nonatomic, retain) CDVInvokedUrlCommand *linkCommand;

@end

