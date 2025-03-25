package heaps.prefab.dev;

import zip.ZipWriter;
import sys.FileSystem;
import sys.io.File;

class Prefab
{
    public var config : PrefabConfig;
    
    public function new(name:String)
    {
        this.config = { name: name, type: "h2d.Object" };
    }

    public function setType(type:Class<Dynamic>)
    {
        this.config.type = Type.getClassName(type);
    }

    public function setBuilder(type:Class<Dynamic>)
    {
        this.config.builderClass = Type.getClassName(type);
    }

    public function build(?outputFolder:String)
    {
        if (outputFolder == null)
        {
            outputFolder = Sys.getCwd() + "bin/";
        }
        
        if (!StringTools.endsWith(outputFolder, "/") && !StringTools.endsWith(outputFolder, "\\")) {
            outputFolder += "/";
        }
        if (!FileSystem.exists(outputFolder))
        {
            FileSystem.createDirectory(outputFolder);
        }
        
        var zip = new ZipWriter();
        
        var jsonData = haxe.Json.stringify(config);
        zip.addString(jsonData, "prefab.json", true);
        
        if (FileSystem.exists("res")) {
            addDirectoryToZip(zip, "res", "res/");
        }
        
        if (FileSystem.exists("src")) {
            addDirectoryToZip(zip, "src", "src/");
        }
        
        var zipBytes = zip.finalize();
        File.saveBytes(outputFolder + config.name + ".prefab", zipBytes);
    }

    private function addDirectoryToZip(zip:ZipWriter, basePath:String, zipPath:String)
    {
        for (file in FileSystem.readDirectory(basePath)) {
            var fullPath = basePath + "/" + file;
            var zipEntryPath = zipPath + file;
            
            if (FileSystem.isDirectory(fullPath))
            {
                addDirectoryToZip(zip, fullPath, zipEntryPath + "/");
            }
            else
            {
                var content = File.getBytes(fullPath);
                zip.addBytes(content, zipEntryPath, true);
            }
        }
    }
}