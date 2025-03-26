package heaps.prefab.builders;

import heaps.localres.LocalRes;

class ScaleGridBuilder extends PrefabBuilder<h2d.ScaleGrid> {
    public override function createConstructor() : Void -> h2d.ScaleGrid
        {
            return () -> {
                var res = LocalRes.scoped(path);

				var tile:h2d.Tile = Utils.getTile(config, res);

				var size = config.range ?? 10;
				var item = new h2d.ScaleGrid(tile, size, size);

				item.width = config.width;
				item.height = config.height;

				if (config.smooth != null) item.smooth = config.smooth == 1 ? true : false;

                applyTransforms(item);
                attachChildren(item);
                
                return item;
            };
        }
}