package heaps.prefab.builders;

import h2d.Bitmap;

class BitmapBuilder extends PrefabBuilder<h2d.Bitmap> {

    public override function createConstructor(): Void -> h2d.Bitmap {
        return () -> {
            var tile = getResource(config.src).toTile();
            var bitmap = new Bitmap(tile);
            applyTransforms(bitmap);

            if(config.width != null) bitmap.width = config.width;
            if(config.height != null) bitmap.height = config.height;
            if(config.blendMode != null) bitmap.blendMode = BlendMode.createByName(config.blendMode);

            attachChildren(bitmap);
            return bitmap;
        };
    }
}