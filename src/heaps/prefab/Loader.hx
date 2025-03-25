package heaps.prefab;

import haxe.io.Path;
import zip.Zip;
import zip.ZipReader;
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class Loader
{
    @:persistent static var timestamps = new Map<String, Float>();
    @:persistent public static var CURRENT_PROJECT_NAME : String;
    
    public macro static function init(?projectName:String) : Void
    {
        CURRENT_PROJECT_NAME = projectName;
        
        var resFolder = "./res";
        
        if (FileSystem.exists(resFolder) && FileSystem.isDirectory(resFolder))
        {
            var files = FileSystem.readDirectory(resFolder);
            
            var currentFiles = new Map<String, Bool>();
            
            for (file in files)
            {
                var fullPath = resFolder + "/" + file;
                
                if (!FileSystem.isDirectory(fullPath) && StringTools.endsWith(file, ".prefab")) {
                    var mtime = FileSystem.stat(fullPath).mtime.getTime();
                    
                    if (!timestamps.exists(fullPath) || timestamps[fullPath] != mtime)
                    {
                        Loader.processZip(fullPath);
                        
                        timestamps[fullPath] = mtime;
                    }
                    
                    currentFiles[fullPath] = true;
                }
            }
            
            var toRemove = [for (key in timestamps.keys()) if (!currentFiles.exists(key)) key];
            for (key in toRemove)
            {
                timestamps.remove(key);
            }
        }
    }

    #if macro
    static function processZip(file:String) : Void
    {
        var fileName = file.substr(file.lastIndexOf("/") + 1);
        fileName = fileName.substr(0, fileName.length - 7);
        
        var tempFolder = MacroTools.getPrefabDir() + fileName + "/";

        trace("Processing prefab: " + file + " into " + tempFolder);
        if (!FileSystem.exists(tempFolder))
        {
            FileSystem.createDirectory(tempFolder);
        }
        
        var zipBytes = File.getBytes(file);
        var zip = new ZipReader(zipBytes);
        var entry : zip.ZipEntry;
        
        var hasSrcFolder = false;
        var hasResFolder = false;
        
        while ((entry=zip.getNextEntry()) != null)
        {
            var fileName = entry.fileName;
            var targetPath = tempFolder + fileName;
            
            if (fileName.startsWith("src/") || fileName == "src") {
                hasSrcFolder = true;
            }
            
            if (fileName.startsWith("res/") || fileName == "res") {
                hasResFolder = true;
            }

            if (fileName == "prefab.json") {
                var jsonStr = Zip.getString(entry);
                try
                {
                    var json = haxe.Json.parse(jsonStr);
                    
                    if (Reflect.hasField(json, "builderClass")) {
                        var builderClass : String = Reflect.field(json, "builderClass");
                        
                        if (Std.is(builderClass, String))
                        {
                            var parts = builderClass.split(".");
                            
                            if (parts.length > 1)
                            {
                                var packageName = parts.slice(0, -1).join(".");
                                Compiler.include(packageName);
                                trace("Including package: " + packageName + " for builderClass: " + builderClass + " from zip: " + file);
                            }
                            else
                            {
                                trace("Builder class is top-level: " + builderClass + " from zip: " + file);
                            }
                        }
                        else
                        {
                            trace("builderClass is not a string in prefab.json from zip: " + file);
                        }
                    }
                }
                catch (e:Dynamic)
                {
                    trace("Error parsing prefab.json from zip: " + file + " - " + e);
                }
            }

            var dir = targetPath.substr(0, targetPath.lastIndexOf("/"));
            if (!FileSystem.exists(dir))
            {
                FileSystem.createDirectory(dir);
            }
            
            if (!fileName.endsWith("/")) {
                var data = Zip.getBytes(entry);
                if (data != null)
                {
                    File.saveBytes(targetPath, data);
                }
            }
        }
        
        if (hasSrcFolder)
        {
            var srcPath = tempFolder + "src";
            Compiler.addClassPath(srcPath);
            trace("Added classpath: " + srcPath);
        }

        trace("hasResFolder: " + hasResFolder);
        if (hasResFolder)
        {
            var resPath = tempFolder + "res";
            var files = FileSystem.readDirectory(resPath);
            for (file in files)
            {
                if (Path.extension(file) == "prefab"){
                    trace("extracting nested prefab: " + file);
                    processZip(resPath + "/" + file);
                }
                else
                {
                    var fullPath = resPath + "/" + file;
                    var name = "res/" + file;
                    trace("Adding resource: " + fullPath);
                    Context.addResource(fullPath, File.getBytes(fullPath));
                }
            }
            trace("Added resource: " + resPath);
        }
    }
    #end
}