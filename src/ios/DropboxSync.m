//
//  DropboxSync.m
//  DropboxSync Cordova plugin
//
//  Created by Panurge
//  Credits Christophe Coenraets
//
//

#import "DropboxSync.h"

#import "AppDelegate.h"

#import <Dropbox/Dropbox.h>

@implementation DropboxSync

@synthesize linkCommand;


// Overrides
/* NOTE: calls into JavaScript must not call or trigger any blocking UI, like alerts */
- (void)handleOpenURL:(NSNotification*)notification
{
    // override to handle urls sent to your app
    // register your url schemes in your App-Info.plist
    
    NSURL* url = [notification object];
    
    if ([url isKindOfClass:[NSURL class]]) {
        
        DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
        if (account) {
            NSLog(@"App is linked now");
            DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
            [DBFilesystem setSharedFilesystem:filesystem];
            
            CDVPluginResult* pluginResult = nil;
            
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:linkCommand.callbackId];
        }
    }
}

- (void) initializeWithKeyAndSecret:(CDVInvokedUrlCommand *)command
{
    NSLog(@"Executing initializeWithKeyAndSecret()");
    
    CDVPluginResult* pluginResult = nil;
    
    NSString* key = [command.arguments objectAtIndex:0];
    NSString* secret = [command.arguments objectAtIndex:1];
    
    DBAccountManager *accountManager = [[DBAccountManager alloc] initWithAppKey:key secret:secret];
    [DBAccountManager setSharedManager:accountManager];
    
    DBAccount *account = [accountManager.linkedAccounts objectAtIndex:0];
    if (account) {
        DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
        [DBFilesystem setSharedFilesystem:filesystem];
        NSLog(@"App linked successfully.");
    }
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


- (void) link:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Executing link()");

    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    UIViewController *topView = appDelegate.viewController;

    [[DBAccountManager sharedManager] linkFromController:topView];
    
    // used in handleOpenURL
    linkCommand = command;

}

- (void) checkLink:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Executing checklink()");

    CDVPluginResult* pluginResult = nil;
    
    DBAccount* account = [[DBAccountManager sharedManager] linkedAccount];
    
    pluginResult = [CDVPluginResult resultWithStatus:account ? CDVCommandStatus_OK : CDVCommandStatus_ERROR];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


- (void) unlink:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Executing unlink()");

    CDVPluginResult* pluginResult = nil;

    [[[DBAccountManager sharedManager] linkedAccount] unlink];
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) getDBFileSystem:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Executing getDBFileSystem()");
    
    [self.commandDelegate runInBackground:^{
    
    CDVPluginResult* pluginResult = nil;
    
    DBFilesystem * fs = [DBFilesystem sharedFilesystem];
    
    NSMutableDictionary *dictionaryStatus = [[NSMutableDictionary alloc] init];
    [dictionaryStatus setValue:[NSNumber numberWithBool:fs.status.active] forKey:@"active"];
    [dictionaryStatus setValue:[NSNumber numberWithBool:fs.status.metadata.inProgress] forKey:@"metadataInProgress"];
    [dictionaryStatus setValue:[NSNumber numberWithBool:fs.status.download.inProgress] forKey:@"downloadInProgress"];
    [dictionaryStatus setValue:[NSNumber numberWithBool:fs.status.upload.inProgress] forKey:@"uploadInProgress"];
    // TODO errors
    [dictionaryStatus setValue:[NSNumber numberWithBool:fs.status.anyInProgress] forKey:@"anyInProgress"];
    [dictionaryStatus setObject:@(fs.status.anyError.error.code) forKey:@"anyErrorErrorCode"];
    //[dictionaryStatus setObject:fs.status.anyError.error.description forKey:@"anyErrorErrorDescription"];
    
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[NSNumber numberWithBool:fs.completedFirstSync] forKey:@"completedFirstSync"];
    [dictionary setValue:[NSNumber numberWithBool:fs.shutDown] forKey:@"shutDown"];
    [dictionary setObject:dictionaryStatus forKey:@"status"];
    [dictionary setObject:@(fs.fileCacheSize) forKey:@"fileCacheSize"];
    [dictionary setObject:@(fs.maxFileCacheSize) forKey:@"maxFileCacheSize"];
    
    if (fs.account != nil && fs.account.userId != nil){
        [dictionary setObject:fs.account.userId forKey:@"accountUserId"];
    }
    if (fs.account.info != nil){
        if (fs.account.info.displayName != nil){
            [dictionary setObject:fs.account.info.displayName forKey:@"accountDisplayName"];
        }
        if (fs.account.info.userName != nil){
            [dictionary setObject:fs.account.info.userName forKey:@"accountUserName"];
        }
        if (fs.account.info.orgName != nil){
            [dictionary setObject:fs.account.info.orgName forKey:@"accountOrgName"];
        }
    }
    
    
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dictionary];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    }];
}

- (void)listFolder:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Executing listFolder()");

    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = nil;
        NSString* path = [command.arguments objectAtIndex:0];
    
        DBPath *newPath = [[DBPath root] childPath:path];
        NSArray *files = [[DBFilesystem sharedFilesystem] listFolder:newPath error:nil];
    
        NSMutableArray *items = [NSMutableArray array];
    
        for (DBFileInfo *file in files) {
            //NSLog(@"\t%@", file.path.stringValue);
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            [dictionary setObject:file.path.stringValue forKey:@"path"];
            [dictionary setObject:[NSNumber numberWithLongLong:[file.modifiedTime timeIntervalSince1970]*1000] forKey:@"modifiedTime"];
            [dictionary setObject:@(file.size) forKey:@"size"];
            [dictionary setValue:[NSNumber numberWithBool:file.isFolder] forKey:@"isFolder"];
            [items addObject:dictionary];
        }
    
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray: items];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)createFile:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Executing createFile()");
    CDVPluginResult* pluginResult = nil;
    NSString* path = [command.arguments objectAtIndex:0];
    
    DBPath *filePath = [[DBPath root] childPath:path];
    
    [[DBFilesystem sharedFilesystem] createFile:filePath error:nil];
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void)createFolder:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Executing createFile()");
    CDVPluginResult* pluginResult = nil;
    NSString* path = [command.arguments objectAtIndex:0];
    
    DBPath *folderPath = [[DBPath root] childPath:path];
    
    [[DBFilesystem sharedFilesystem] createFolder:folderPath error:nil];
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void)deletePath:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Executing deletePath()");
    CDVPluginResult* pluginResult = nil;
    NSString* path = [command.arguments objectAtIndex:0];
    
    DBPath * deletePath = [[DBPath root] childPath:path];
    
    [[DBFilesystem sharedFilesystem] deletePath:deletePath error:nil];
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void)movePath:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Executing createFile()");
    CDVPluginResult* pluginResult = nil;
    NSString* fromPath = [command.arguments objectAtIndex:0];
    NSString* toPath = [command.arguments objectAtIndex:0];
    
    DBPath *DBfromPath = [[DBPath root] childPath:fromPath];
    DBPath *DBtoPath = [[DBPath root] childPath:toPath];
    
    [[DBFilesystem sharedFilesystem] movePath:DBfromPath toPath:DBtoPath error:nil];
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}


- (void)addObserver:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Executing addObserver()");
    NSString* path = [command.arguments objectAtIndex:0];
    DBPath *newPath = [[DBPath root] childPath:path];
    
    [[DBFilesystem sharedFilesystem] addObserver:self forPathAndDescendants:newPath block:^() {
        NSLog(@"File change!");
        [self writeJavascript:@"dropbox_fileChange()"];
    }];
}

- (void)removeObserver:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Executing removeObserver()");
    
    [[DBFilesystem sharedFilesystem] removeObserver:self];
    
}


- (void)readData:(CDVInvokedUrlCommand*)command
{
    //NSLog(@"Executing readData()");

    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = nil;
        NSString* path = [command.arguments objectAtIndex:0];
    
        DBPath *newPath = [[DBPath root] childPath:path];
        DBFile *file = [[DBFilesystem sharedFilesystem] openFile:newPath error:nil];
        
        NSLog(@"Executing readData() status1 %@", file.newerStatus);
        
        if (file.newerStatus != nil && !file.newerStatus.cached){
            // wait until the file is cached
            // TODO make param
            while (!file.newerStatus.cached) { [NSThread sleepForTimeInterval:0.75f]; }
            [file update:nil];
        }
        
        NSError *error;
        NSData *data = [file readData:&error];
        
        NSLog(@"Executing readData() status2 %@", file.newerStatus);
        
        if (data != nil){
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArrayBuffer: data];
        }
        else{
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
    
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
    
}


- (void)readString:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Executing readString()");

    [self.commandDelegate runInBackground:^{
        
        CDVPluginResult* pluginResult = nil;
        NSString* path = [command.arguments objectAtIndex:0];
        
        DBPath *newPath = [[DBPath root] childPath:path];
        DBFile *file = [[DBFilesystem sharedFilesystem] openFile:newPath error:nil];
        
        NSError *error;
        NSString *data = [file readString:&error];
        
        if (data != nil){
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: data];
        }
        else{
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: data];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
    
    
}

- (void)writeContentsOfFile:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Executing writeContentsOfFile()");
    
    [self.commandDelegate runInBackground:^{
        
        CDVPluginResult* pluginResult = nil;
        NSString* path = [command.arguments objectAtIndex:0];
        BOOL shouldSteal = [[command.arguments objectAtIndex:1] boolValue];
        BOOL create = [[command.arguments objectAtIndex:2] boolValue];
        
        DBPath *newPath = [[DBPath root] childPath:path];
        DBFile *file = [[DBFilesystem sharedFilesystem] openFile:newPath error:nil];
        
        if (file == nil && create){ // create if not exists
            NSLog(@"Executing createFile()");
            file = [[DBFilesystem sharedFilesystem] createFile:newPath error:nil];
        }
        
        NSString *docs = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
        NSString *localPath = [NSString stringWithFormat:@"%@/%@", docs, path];
        
        if ([file writeContentsOfFile:localPath shouldSteal:shouldSteal error:nil])
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        else{
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    }];
    
}

- (void)writeString:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Executing writeString()");
    
    [self.commandDelegate runInBackground:^{
        
        CDVPluginResult* pluginResult = nil;
        NSString* path = [command.arguments objectAtIndex:0];
        NSString* string = [command.arguments objectAtIndex:1];
        BOOL create = [[command.arguments objectAtIndex:2] boolValue];
        
        DBPath *newPath = [[DBPath root] childPath:path];
        DBFile *file = [[DBFilesystem sharedFilesystem] openFile:newPath error:nil];
        
        if (file == nil && create){ // create if not exists
            NSLog(@"Executing createFile()");
            file = [[DBFilesystem sharedFilesystem] createFile:newPath error:nil];
        }
        
        if ([file writeString:string error:nil])
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        else{
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    }];
    
}


- (void) update:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Executing update()");
    [self.commandDelegate runInBackground:^{
        
        CDVPluginResult* pluginResult = nil;
        NSString* localPath = [command.arguments objectAtIndex:0];
        
        DBPath *newPath = [[DBPath root] childPath:localPath];
        DBFile *file = [[DBFilesystem sharedFilesystem] openFile:newPath error:nil];
        
        BOOL result = [file update:nil];
        
        if (result){
            NSLog(@"Executing update()->result");
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        else{
            NSLog(@"Executing update()->result-NO");
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
        
    }];
}

- (void) touch:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* path = [command.arguments objectAtIndex:0];
    
    NSString *docs = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    NSString *localPath = [NSString stringWithFormat:@"%@/%@", docs, path];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDate *now = [NSDate date];
    NSDictionary *modificationDateAttr = [NSDictionary dictionaryWithObjectsAndKeys: now, NSFileModificationDate, nil];
    [fileManager setAttributes:modificationDateAttr ofItemAtPath:localPath error:nil];
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:[now timeIntervalSince1970]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


@end
