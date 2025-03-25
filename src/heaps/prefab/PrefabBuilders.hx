package heaps.prefab;

import heaps.prefab.builders.BitmapBuilder;

class PrefabBuilders {
    static var type2Builder: Map<String, (path: String, config: PrefabConfig) -> PrefabBuilder<Dynamic>> = [];
    static var hasInitialized: Bool = false;

    static function init() {
        if (hasInitialized) return;
        hasInitialized = true;
        registerBuilder(h2d.Bitmap, (path: String, config: PrefabConfig) -> {return new BitmapBuilder(path, config); });
        registerBuilder(h2d.Object, (path: String, config: PrefabConfig) -> {return new PrefabBuilder(path, config); });
    }

    public static function registerBuilder<T>(type: Class<T>, builder: (path: String, config: PrefabConfig) -> PrefabBuilder<T>) {
        init();
        type2Builder[Type.getClassName(type)] = builder;
    }

    public static function getBuilder<T>(type: Class<T>, path: String, config: PrefabConfig): PrefabBuilder<T> {
        init();
        return cast type2Builder[Type.getClassName(type)](path, config);
    }

    public static function getBuilderRaw(type: String, path: String, config: PrefabConfig): PrefabBuilder<Dynamic> {
        init();
        return cast type2Builder[type](path, config);
    }
}