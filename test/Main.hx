import heaps.prefab.Prefabs;
import hxd.App;

class Main extends App
{
    override function init()
    {
        var z = Prefabs.alltypes();
        s2d.addChild(z);
    }

    static function main()
    {
        new Main();
    }
}