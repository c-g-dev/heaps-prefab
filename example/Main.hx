import heaps.prefab.dev.Prefab;

class Main
{
    public static function main()
    {
        var prefab = new Prefab("LogicObject");
        prefab.config.src = "LogicObjectImage.png";
        prefab.config.type = "heaps.prefabs.logicprefabtest.LogicObject";
        prefab.config.builderClass = "heaps.prefab.builders.BitmapBuilder";
        prefab.build();
    }
}