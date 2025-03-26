package heaps.prefab.builders;

import hxd.res.Atlas;
import heaps.localres.LocalRes;


class AnimBuilder extends PrefabBuilder<h2d.Anim> {
    public override function createConstructor() : Void -> h2d.Anim
    {
        return () -> {
            var localRes = LocalRes.scoped(path);
            var tiles:Array<h2d.Tile> = [];

            var sheet = Utils.getTile(config, localRes);

            if (config.atlas != null) {
                if(!localRes.exists(config.atlas)) throw("Could not find atlas " + config.atlas + ".atlas");
                var atlas = localRes.res(config.atlas).to(Atlas);
                tiles = atlas.getAnim(config.src);
                for (t in tiles) t.setCenterRatio(0.5, 0.5);
            }
            else {
                var sheet = Utils.getTile(config, localRes);

                var row = Std.int(config.width);
                var col = Std.int(config.height);
                var w = Std.int(sheet.width / row);
                var h = Std.int(sheet.height / col);
        
                for (y in 0...col) {    
                    for (x in 0...row) {
                        tiles.push( sheet.sub(x * w, y * h, w, h, -(w / 2), -(h / 2)) );
                    }
                }
            }

            var item = new h2d.Anim(tiles, config.speed);
            item.pause = config.loop == 0 ? true : false;

            if (config.smooth != null) item.smooth = config.smooth == 1 ? true : false;

            applyTransforms(item);
            attachChildren(item);
            
            return item;
        };
    }
}