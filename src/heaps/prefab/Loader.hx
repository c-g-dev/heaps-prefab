package heaps.prefab;

import zip.Zip;
import zip.ZipReader;
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class Loader {
    
    @:persistent static var timestamps:Map<String, Float> = new Map<String, Float>();
    @:persistent public static var CURRENT_PROJECT_NAME: String;

    
    public macro static function init(?projectName: String):Void {
        CURRENT_PROJECT_NAME = projectName;
        
        var resFolder = "./res";

        
        if (FileSystem.exists(resFolder) && FileSystem.isDirectory(resFolder)) {
            
            var files = FileSystem.readDirectory(resFolder);
            
            var currentFiles = new Map<String, Bool>();

            
            for (file in files) {
                var fullPath = resFolder + "/" + file;
                
                if (!FileSystem.isDirectory(fullPath) && StringTools.endsWith(file, ".prefab")) {
                    
                    var mtime = FileSystem.stat(fullPath).mtime.getTime();

                    
                    if (!timestamps.exists(fullPath) || timestamps[fullPath] != mtime) {
                        
                        Loader.processZip(fullPath);
                        
                        timestamps[fullPath] = mtime;
                    }
                    
                    currentFiles[fullPath] = true;
                }
            }

            
            var toRemove = [for (key in timestamps.keys()) if (!currentFiles.exists(key)) key];
            for (key in toRemove) {
                timestamps.remove(key);
            }
        }
    }

    #if macro
    static function processZip(file:String):Void {
        
        var fileName = file.substr(file.lastIndexOf("/") + 1);
        fileName = fileName.substr(0, fileName.length - 7); 

        
        var tempFolder = MacroTools.getPrefabDir() + fileName + "/";

        trace("Processing prefab: " + file + " into " + tempFolder);
        if (!FileSystem.exists(tempFolder)) {
            FileSystem.createDirectory(tempFolder);
        }

        
        var zipBytes = File.getBytes(file);
        var zip = new ZipReader(zipBytes);
        var entry: zip.ZipEntry;

        
        var hasSrcFolder = false;

        
        while ((entry = zip.getNextEntry()) != null) {
            var fileName = entry.fileName;
            var targetPath = tempFolder + fileName;

            
            if (fileName.startsWith("src/") || fileName == "src") {
                hasSrcFolder = true;
            }

            
            var dir = targetPath.substr(0, targetPath.lastIndexOf("/"));
            if (!FileSystem.exists(dir)) {
                FileSystem.createDirectory(dir);
            }

            
            if (!fileName.endsWith("/")) {
                var data = Zip.getBytes(entry);
                if (data != null) {
                    File.saveBytes(targetPath, data);
                }
            }
        }

        
        if (hasSrcFolder) {
            var srcPath = tempFolder + "src";
            Compiler.addClassPath(srcPath);
            trace("Added classpath: " + srcPath);
        }
    }
    #end
}