package heaps.prefab;

import heaps.localres.LocalRes;
import hxd.res.Resource;

class PrefabBuilder<T>
{
    var path : String;
    var config : PrefabConfig;

    public function new(path:String, config:PrefabConfig)
    {
        this.path = path;
        this.config = config;
    }

    public function createConstructor() : Void -> T
    {
        return () -> {
            if (config.link != null)
            {   
                var info = PrefabCache.get(config.link);
                if(info != null) {
                    var builder = PrefabBuilders.resolveBuilder(info.path, info.config);
                    return cast builder.createConstructor()();
                }
                
            }
            
            var obj = createObjectInstance();
            applyTransforms(cast obj);
            attachChildren(cast obj);
            return cast obj;
        
        };
    }

    public function createObjectInstance() : T
    {
        return Type.createInstance(Type.resolveClass(Utils.convertTypes(config.type)), []);
    }

    public function getResource(resName:String) : hxd.res.Any
    {
        var scopedRes = LocalRes.scoped(path);
        return hxd.res.Any.fromBytes("", scopedRes.res(resName).entry.getBytes());
    }

    public function applyTransforms(obj:h2d.Object)
    {
        if (config.x != null) obj.x = config.x;
        if (config.y != null) obj.y = config.y;
        if (config.scaleX != null) obj.scaleX = config.scaleX;
        if (config.scaleY != null) obj.scaleY = config.scaleY;
        if (config.rotation != null) obj.rotation = config.rotation;
        if (config.alpha != null) obj.alpha = config.alpha;
        if (config.visible != null) obj.visible = config.visible;
    }


    public function attachChildren(obj:h2d.Object)
    {
        if (config.children == null) return;
        for (eachChild in config.children)
        {
            var childPrefabBuilder = PrefabBuilders.resolveBuilder(path, eachChild);
            var child = childPrefabBuilder.createConstructor()();
            obj.addChild(child);
        }
    }
}