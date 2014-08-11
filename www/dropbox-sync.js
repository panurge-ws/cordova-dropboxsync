var argscheck = require('cordova/argscheck'),
    utils = require('cordova/utils'),
    exec = require('cordova/exec');

var DropboxSync = function() {};

var pluginName = "DropboxSync";
var initialized = false;

//exec(null, null, "Keyboard", "hideKeyboardAccessoryBar", [hide]);
DropboxSync.initializeWithKeyAndSecret = function(success, error, key, secret) {
    initialized = true;
    cordova.exec(
        success,
        error,
        pluginName, "initializeWithKeyAndSecret", [key, secret]);
}

DropboxSync.link = function(success, error) {
    if (!initialized){
        throw "You must call initializeWithKeyAndSecret before linking the app";
        return;
    }
    cordova.exec(
        success,
        error,
        pluginName, "link", [""]);
}

DropboxSync.checkLink = function(success, error) {
    if (!initialized){
        throw "You must call initializeWithKeyAndSecret before linking the app";
        return;
    }
    cordova.exec(
        success,
        error,
        pluginName, "checkLink", [""]);

}

DropboxSync.unlink = function(success, error) {

    cordova.exec(
        success,
        error,
        pluginName, "unlink", [""]);

}

DropboxSync.getDBFileSystem = function(success, error) {

    cordova.exec(
        success,
        error,
        pluginName, "getDBFileSystem", [""]);

}

DropboxSync.listFolder = function(success, error, path) {

    cordova.exec(
        success,
        error,
        pluginName, "listFolder", [path]);
}

DropboxSync.createFile = function(success, error, path) {

    cordova.exec(
        success,
        error,
        pluginName, "createFile", [path]);
}

DropboxSync.createFolder = function(success, error, path) {

    cordova.exec(
        success,
        error,
        pluginName, "createFolder", [path]);
}

DropboxSync.deletePath = function(success, error, path) {

    cordova.exec(
        success,
        error,
        pluginName, "deletePath", [path]);
}

DropboxSync.movePath = function(success, error, fromPath, toPath) {

    cordova.exec(
        success,
        error,
        pluginName, "deletePath", [path]);
}

DropboxSync.addObserver = function(success, error, path) {

    cordova.exec(
        success,
        error,
        pluginName, "addObserver", [path]);
}

DropboxSync.removeObserver = function(success, error) {

    cordova.exec(
        success,
        error,
        pluginName, "removeObserver", [""]);
}

DropboxSync.readData = function(success, error, fileName) {

    cordova.exec(
        success,
        error,
        pluginName, "readData", [fileName]);
}

DropboxSync.readString = function(success, error, fileName) {
    cordova.exec(
        success,
        error,
        pluginName, "readString", [fileName]);
}

DropboxSync.writeContentsOfFile = function(success, error, fileName, shouldSteal, create) {
    shouldSteal = typeof shouldSteal === 'undefined' ? false : shouldSteal;
    create = typeof create === 'undefined' ? true : create;

    cordova.exec(
        success,
        error,
        pluginName, "writeContentsOfFile", [fileName, shouldSteal, create]);
}

DropboxSync.writeString = function(success, error, path, string) {
    cordova.exec(
        success,
        error,
        pluginName, "touch", [path, string]);
}


DropboxSync.update = function(success, error, fileName) {
    cordova.exec(
        success,
        error,
        pluginName, "update", [fileName]);
}



DropboxSync.touch = function(success, error, path) {
    cordova.exec(
        success,
        error,
        pluginName, "touch", [path]);
}








module.exports = DropboxSync;
