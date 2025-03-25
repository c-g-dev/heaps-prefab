package heaps.prefabs.logicprefabtest;

import h2d.Bitmap;
import h2d.RenderContext;

class LogicObject extends Bitmap
{
    private var elapsedTime : Float = 0;
    
    public function new(?parent:h2d.Object)
    {
        super(parent);
        this.alpha = 1.0;
    }
    
    override function sync(ctx:RenderContext)
    {
        super.sync(ctx);
        
        elapsedTime += ctx.elapsedTime;
        
        if (elapsedTime >= 2.0)
        {
            this.alpha = (this.alpha > 0.5) ? 0.0 : 1.0;
            
            elapsedTime = 0;
        }
    }
}