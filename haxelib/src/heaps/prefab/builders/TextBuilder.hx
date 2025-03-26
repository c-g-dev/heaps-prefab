package heaps.prefab.builders;

import heaps.localres.LocalRes;

class TextBuilder extends PrefabBuilder<h2d.Text> {
    public override function createConstructor() : Void -> h2d.Text
    {
        return () -> {
            var localRes = LocalRes.scoped(path);
            var font = hxd.res.DefaultFont.get();
            if (config.font != null) {
                if (!localRes.exists(config.src)) throw("Could not find Font file " + config.src);
                font = localRes.res(config.src).to(hxd.res.BitmapFont).toFont();
            }

            var item = new h2d.Text(font);
            item.smooth = true;

            if (config.color != null) item.textColor = config.color;
            if (config.width != null) item.letterSpacing = config.width;
            if (config.height != null) item.lineSpacing = config.height;
            if (config.range != null) item.maxWidth = config.range;

            if (config.align != null) {
                switch (config.align) {
                    case 1 : item.textAlign = Center;
                    case 2 : item.textAlign = Right;
                    default : item.textAlign = Left;
                }
            }

            item.text = config.text ?? "";

            applyTransforms(item);
            attachChildren(item);
            
            return item;
        };
    }
}