package heaps.prefab;

import haxe.io.Path;
import hxd.res.Resource;
import hxd.fs.LoadedBitmap;
import hxd.fs.FileEntry;
import haxe.macro.Context;
import haxe.io.Bytes;
#if macro
import sys.FileSystem;
#end

class LocalRes
{
    #if macro
    public static macro function here() : ExprOf<LocalRes>
    {
        trace(Path.directory(Context.getLocalModule().split(".").join("/") + ".hx"));
        var resPath = Context.resolvePath(Path.directory(Context.getLocalModule().split(".").join("/") + ".hx") + "/res");
        if (!FileSystem.isDirectory(resPath))
        {
            Context.error("res directory not found", Context.currentPos());
            return macro null;
        }
        return macro @:privateAccess new LocalRes(resPath);
    }
    #end

    #if !macro

    static var cachedResources : Map<String, hxd.res.Resource> = [];

    var prepend : String;

    function new(prepend:String)
    {
        this.prepend = prepend;
    }

    public static function scoped(path:String) : LocalRes
    {
        return new LocalRes(path + "/res");
    }

    function getResourceName(name:String) : String
    {
        return this.prepend + "/" + name;
    }

    public function tile(name:String) : h2d.Tile
    {
        return hxd.res.Any.fromBytes("", res(name).entry.getBytes()).toTile();
	}

    public function sound(name:String) : hxd.res.Sound
    {
        return hxd.res.Any.fromBytes("", res(name).entry.getBytes()).toSound();
	}

	public function res(name:String) : hxd.res.Resource
	{
        var qName = getResourceName(name);
        if (!cachedResources.exists(qName))
        {
            cachedResources[qName] = new Resource(new ComponentEmbeddedFileEntry(qName));
        }
		return cachedResources[qName];
	}
	#end
}

class ComponentEmbeddedFileEntry extends FileEntry
{
    var data : String;
    var bytes : haxe.io.Bytes;

    public function new(data)
    {
        this.name = data;
        this.data = data;
    }

    function init()
    {
        if (bytes == null) {
            bytes = haxe.Resource.getBytes(data);
            if (bytes == null) throw "Missing resource " + data;
        }
    }

    override function getBytes() : haxe.io.Bytes
    {
        if (bytes == null)
            init();
        return bytes;
    }

    override function readBytes(out:haxe.io.Bytes, outPos:Int, pos:Int, len:Int) : Int
    {
        if (bytes == null)
            init();
        if (pos + len > bytes.length)
            len = bytes.length - pos;
        if (len < 0) len = 0;
        out.blit(outPos, bytes, pos, len);
        return len;
    }

    override function load(?onReady:Void -> Void) : Void
    {
        #if js
        if (onReady != null) haxe.Timer.delay(onReady, 1);
        #end
    }

    override function loadBitmap(onLoaded:LoadedBitmap -> Void) : Void
    {
        #if js
        
        var rawData = null;
        for (res in @:privateAccess haxe.Resource.content)
            if (res.name == data)
            {
                rawData = res.data;
                break;
            }
        if (rawData == null) throw "Missing resource " + data;
        var image = new js.html.Image();
        image.onload = function(_)
        {
            onLoaded(new LoadedBitmap(image));
        };
        var extra = "";
        var bytes = (rawData.length * 6) >> 3;
        for (i in 0...(3-(bytes*4)%3)%3)
            extra += "=";
        image.src = "data:image/" + extension + ";base64," + rawData + extra;
        #else
        throw "TODO";
        #end
    }

    override function get_isDirectory()
    {
        return false;
    }

    override function exists(name:String)
    {
        return false;
    }

    override function get_size()
    {
        init();
        return bytes.length;
    }
}