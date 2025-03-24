package heaps.prefab;

class PrefabBuilder<T> {
    public function new(path: String, config: PrefabConfig) {
        
    }

    public function createConstructor(): Void -> T {
        return () -> {return cast new h2d.Object();};
    }
}