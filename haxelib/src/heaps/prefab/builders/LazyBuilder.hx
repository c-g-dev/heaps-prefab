package heaps.prefab.builders;

class LazyBuilder<T=Dynamic> extends PrefabBuilder<T>{
    public override function createConstructor() : Void -> T {
        return () -> {
            var realBuilder = PrefabBuilders.resolveBuilder(path, config);
            return realBuilder.createConstructor()();
        };
    }
}