Dropbox Sync API Plugin for iOS
======

## Install
Install the Dropbox Sync API following this [link](https://www.dropbox.com/developers/sync/sdks/ios).

Then add the plugin to your cordova project

```javascript
cordova plugin add https://github.com/panurge-ws/cordova-dropboxsync
```

**Tested in Cordova 3.5.0, iOS 7.1.x**

## Usage
### Initialize and link
```javascript
cordova.plugins.DropboxSync.initializeWithKeyAndSecret(function(){
                console.log("DropboxSync-initializeWithKeyAndSecret-success")
            },function(){
                console.log("DropboxSync-initializeWithKeyAndSecret-error")
            },"YOUR_APP_KEY","YOUR_APP_SECRET");
            
cordova.plugins.DropboxSync.link(
                function(result) {
                    console.log("DropboxSync-link-success")
                },
                function(error) {
                    console.log("DropboxSync-link-error")
                });
```
### Get Dropbox Sync File system
```javascript
cordova.plugins.DropboxSync.getDBFileSystem(function(fs) {
                var theFileSystem = fs;
            })
```
### Retrieving files and folders
```javascript
cordova.plugins.DropboxSync.listFolder(
                function(files) {
                    var files = results;
                },
                function(error) {
                    console.log("DropboxSync-listFolder-error")
                },
                '/'); // the path of the folder you want to list the files and folders 
```
### Observe
```javascript
cordova.plugins.DropboxSync.addObserver(
                function(result) {
                    console.log("DropboxSync-addObserver-success")
                },
                function(error) {
                   console.log("DropboxSync-addObserver-error")
                },
                '/'); // the path of the folder you want to observe
```
This will call the function dropbox_fileChange in your javascript
```javascript
function dropbox_fileChange(){
	console.log('files changes!');
}
```
to notify you that somithing is changed at the path observed
### Read files

```javascript
cordova.plugins.DropboxSync.readData(
                function(fileData) {
                	var theFileData = fileData;
                    console.log("DropboxSync-readData-success")
                },
                function(error) {
                    console.log("DropboxSync-readData-error")
                },
                fileName); // the DropBox file path of the file you want to read
```

### Write files 

```javascript
cordova.plugins.DropboxSync.writeContentsOfFile(
                function(result) {
                    console.log("DropboxSync.writeContentsOfFile-success")
                },
                function(error) {
                    console.log("DropboxSync.writeContentsOfFile-error")
                }, 
                'filePath'); // the local path of the file you want to upload to DropBox; 
```

## All the methods 
_(For the doc, please refer to the [Dropbox Sync API](https://www.dropbox.com/developers/sync/docs/ios))_

**cordova.plugins.DropboxSync.initializeWithKeyAndSecret(success, error)**

**cordova.plugins.DropboxSync.link(success, error)**

**cordova.plugins.DropboxSync.checkLink(success, error)**

**cordova.plugins.DropboxSync.unlink(success, error)**

**cordova.plugins.DropboxSync.getDBFileSystem(success, error)**

**cordova.plugins.DropboxSync.listFolder(success, error, path)**

**cordova.plugins.DropboxSync.createFile(success, error, path)**

**cordova.plugins.DropboxSync.createFolder(success, error, path)**

**cordova.plugins.DropboxSync.deletePath(success, error, path)**

**cordova.plugins.DropboxSync.movePath(success, error, fromPath, toPath)**

**cordova.plugins.DropboxSync.addObserver(success, error, path)**

**cordova.plugins.DropboxSync.removeObserver(success, error)**

**cordova.plugins.DropboxSync.readData(success, error, path)**

**cordova.plugins.DropboxSync.readString(success, error, path)**

**cordova.plugins.DropboxSync.writeContentsOfFile(success, error, localPath, shouldSteal, createIfNotExixts)**

**cordova.plugins.DropboxSync.writeString(success, error, path, string, createIfNotExixts)**

**cordova.plugins.DropboxSync.update(success, error, path)**

_ An utility method to touch to the current date a file in the localPath_
**cordova.plugins.DropboxSync.touch(success, error, localPath)**



Supported Platforms
-------------------

- iOS
