package heaps.prefab;

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
        return cast resolveBuilder(path, config);
    }

   /* public static function getBuilderRaw(type: String, path: String, config: PrefabConfig): PrefabBuilder<Dynamic> {
        init();
        return cast type2Builder[type](path, config);
    }*/
    
    public static function resolveBuilder(path:String, config:PrefabConfig) : PrefabBuilder<Dynamic>
    {
        init();
        if (config.builderClass != null)
        {
            return cast builderConstructors[config.builderClass](path, config);
        }
        else if (builderConstructors.exists(type2Builder[convertTypes(config.type)]))
        {
            return cast builderConstructors[type2Builder[convertTypes(config.type)]](path, config);
        }
        else
        {
            trace("type2Builder: " + type2Builder);
            return cast builderConstructors[type2Builder["h2d.Object"]](path, config);
        }
    }
    
    static function convertTypes(value:String) : String
    {
        switch (value) {
            case "prefab": return "h2d.Object";
            case "bitmap": return "h2d.Bitmap";
            case "object": return "h2d.Object";
            default : return value;
        }
    }
}