package heaps.prefab.builders;

import h2d.Interactive;

class InteractiveBuilder extends PrefabBuilder<Interactive> {
    public override function createConstructor() : Void -> h2d.Interactive
        {
            return () -> {
                var item = new h2d.Interactive(128, 128);

				item.width = Std.int(config.width);
				item.height = Std.int(config.height);

				if (config.smooth != null) item.isEllipse = true;

                applyTransforms(item);
                attachChildren(item);
                
                return item;
            };
        }
}