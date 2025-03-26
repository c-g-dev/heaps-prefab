package heaps.prefab.builders;

import heaps.localres.LocalRes;
import h2d.Mask;

class MaskBuilder extends PrefabBuilder<Mask> {
    public override function createConstructor() : Void -> h2d.Mask
    {
        return () -> {
            var item = new h2d.Mask(Std.int(config.width), Std.int(config.height));

            applyTransforms(item);
            attachChildren(item);
            
            return item;
        };
    }
}