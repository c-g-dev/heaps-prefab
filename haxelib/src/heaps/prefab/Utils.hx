package heaps.prefab;

#if !macro
import hxd.res.Atlas;
import heaps.localres.LocalRes;
#end

class Utils {

    public static function convertTypes(value:String) : String
    {
        switch (value) {
            case "prefab": return "h2d.Object";
            case "bitmap": return "h2d.Bitmap";
            case "object": return "h2d.Object";
            case "scalegrid": return "h2d.ScaleGrid";
            case "mask": return "h2d.Mask";
            case "graphics": return "h2d.Graphics";
            case "anim": return "h2d.Anim";
            case "text": return "h2d.Text";
            case "interactive": return "h2d.Interactive";
            default : return value;
        }
    }
    
    #if !macro
    public static function getTile(config: PrefabConfig, localRes: LocalRes) : h2d.Tile {
        if (config.atlas != null) {
            if(!localRes.exists(config.atlas)) throw("Could not find atlas " + config.atlas + ".atlas");
            var atlas = localRes.res(config.atlas).to(Atlas);
            return atlas.get(config.src);
        }
        else {
            if(!localRes.exists(config.src)) throw("Could not find image " + config.src);
            return localRes.res(config.src).toTile();
        }
    }
    #end
}