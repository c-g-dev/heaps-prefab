package heaps.prefab;

typedef PrefabCacheEntry =
{
    path: String,
    config: PrefabConfig
}

@:build(heaps.prefab.PrefabCacheMacro.build())
class PrefabCache
{
}