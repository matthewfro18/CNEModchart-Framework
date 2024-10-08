package modchart;

import flixel.FlxG;
import funkin.game.PlayState;
import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import modchart.core.util.Constants.Visuals;
import openfl.geom.Vector3D;
import flixel.math.FlxMath;

using StringTools;

class Modifier
{
    public var percent:Float = 0;

	// arguments are bad
	public var field:Int = 0;

    public function new(?percent:Null<Float>)
    {
        this.percent = percent ?? 0;
    }
    
    public function render(curPos:Vector3D, params:RenderParams)
    {
        return curPos;
    }
	public function visuals(data:Visuals, params:RenderParams)
	{
		return data;
	}
	public function rotateScroll(curScroll:Vector3D):Vector3D
	{
		return curScroll;
	}
    public function getAliases():Array<String>
        return [];
	public function shouldRun():Bool
		return false;

    public function setPercent(name:String, value:Float, ?cField:Int)
    {
        Manager?.instance?.modifiers?.setPercent(name, value, cField ?? field);
    }
	public function getPercent(name:String, ?cField:Int):Float
    {
        return Manager?.instance?.modifiers?.getPercent(name, cField ?? field);
    }
    

	private function getKeycount():Int
	{
		return (PlayState?.instance?.strumLines?.members[0]?.length) ?? 4;
	}
	private function getPlayercount():Int
	{
		return (PlayState?.instance?.strumLines?.length) ?? 2;
	}
    // Helpers Functions
    private function getScrollSpeed():Float
        return PlayState?.instance?.scrollSpeed ?? 1;
    public function getReceptorY(lane:Int, field:Int)
        @:privateAccess return PlayState?.instance?.strumLines.members[field]?.startingPos?.y;
    public function getReceptorX(lane:Int, field:Int)
        @:privateAccess return PlayState?.instance?.strumLines.members[field]?.startingPos?.x + ((ARROW_SIZE) * lane);

    private var WIDTH:Float = FlxG.width;
    private var HEIGHT:Float = FlxG.height;
    private var ARROW_SIZE:Float = 160 * 0.7;
    private var ARROW_SIZEDIV2:Float = (160 * 0.7) * 0.5;
    private var PI:Float = Math.PI;
    private function sin(num:Float, pr:Bool = false)
        return pr ? Math.sin(num) : FlxMath.fastSin(num);
    private function cos(num:Float, pr:Bool = false)
        return pr ? Math.cos(num) : FlxMath.fastCos(num);
    private function tan(num:Float, pr:Bool = false)
        return pr ? Math.tan(num) : sin(num) / cos(num);

    public function toString():String {
        var classn:String = Type.getClassName(Type.getClass(this));
        classn = classn.substring(classn.lastIndexOf('.') + 1);
        return classn + '{ percent: $percent }';
    }
}