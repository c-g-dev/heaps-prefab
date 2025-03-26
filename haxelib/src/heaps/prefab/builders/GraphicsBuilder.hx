package heaps.prefab.builders;

import h2d.Graphics;

class GraphicsBuilder extends PrefabBuilder<Graphics> {
    public override function createConstructor() : Void -> h2d.Graphics
        {
            return () -> {
                var item = new h2d.Graphics();

				var c = config.color ?? 0xFFFFFF;
				var w = config.width ?? 128;
				var h = config.height ?? 128;

				item.beginFill(c);
				item.drawRect(0, 0, w, h);
				item.endFill();
    
                applyTransforms(item);
                attachChildren(item);
                
                return item;
            };
        }
}