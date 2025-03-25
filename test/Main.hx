import heaps.prefab.Prefabs;
import hxd.App;
import h2d.Text;

class Main extends App {
    override function init() {
        // Create a text object
        var p = Prefabs.testing();
        var x = Prefabs.composite();
       // s2d.addChild(p);
       // p.x += 100;
        s2d.addChild(x);
    }

    static function main() {
        new Main();
    }
}