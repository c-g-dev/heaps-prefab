package heaps.prefab;

import heaps.prefab.builders.InteractiveBuilder;
import h2d.Interactive;
import heaps.prefab.builders.TextBuilder;
import h2d.Text;
import heaps.prefab.builders.ScaleGridBuilder;
import h2d.ScaleGrid;
import heaps.prefab.builders.MaskBuilder;
import heaps.prefab.builders.GraphicsBuilder;
import h2d.Graphics;
import heaps.prefab.builders.AnimBuilder;
import heaps.prefab.builders.LazyBuilder;
import heaps.prefab.builders.BitmapBuilder;

class PrefabBuilders
{
    static var type2Builder : Map<String, String> = [];
    static var builderConstructors : Map<String, (path:String, config:PrefabConfig) -> PrefabBuilder<Dynamic>> = [];
    static var hasInitialized = false;

    static function init()
    {
        if (hasInitialized) return;
        hasInitialized = true;
        assignBuilder(h2d.Bitmap, BitmapBuilder);
        assignBuilder(h2d.Object, PrefabBuilder);
        assignBuilder(h2d.Anim, AnimBuilder);
        assignBuilder(h2d.Graphics, GraphicsBuilder);
        assignBuilder(h2d.Mask, MaskBuilder);
        assignBuilder(h2d.ScaleGrid, ScaleGridBuilder);
        assignBuilder(h2d.Text, TextBuilder);
        assignBuilder(h2d.Interactive, InteractiveBuilder);
    }

    public static function assignBuilder<T>(objType:Class<T>, builderType:Class<PrefabBuilder<T>>)
    {
        init();
        type2Builder[Type.getClassName(objType)] = Type.getClassName(builderType);
        builderConstructors[Type.getClassName(builderType)] = (path:String, config:PrefabConfig) -> { return Type.createInstance(builderType, [path, config]); }
    }

    static function constructBuilder(builderClass:String, path:String, config:PrefabConfig) : PrefabBuilder<Dynamic>
    {
        init();
        if (builderConstructors[builderClass] != null)
        {
            return builderConstructors[builderClass](path, config);
        }
        else
        {
            var bClazz = Type.resolveClass(builderClass);
            builderConstructors[builderClass] = (path, config) -> { return Type.createInstance(bClazz, [path, config]); }
            return builderConstructors[builderClass](path, config);
        }
    }

    public static function getBuilder<T>(type:Class<T>, path:String, config:PrefabConfig) : PrefabBuilder<T>
    {
        init();
        return cast new LazyBuilder(path, config);
    }
    
    public static function resolveBuilder(path:String, config:PrefabConfig) : PrefabBuilder<Dynamic>
    {
        init();
        if (config.builderClass != null)
        {
            return cast builderConstructors[config.builderClass](path, config);
        }
        else if (builderConstructors.exists(type2Builder[Utils.convertTypes(config.type)]))
        {
            return cast builderConstructors[type2Builder[Utils.convertTypes(config.type)]](path, config);
        }
        else
        {
            return cast builderConstructors[type2Builder["h2d.Object"]](path, config);
        }
    }
    
}