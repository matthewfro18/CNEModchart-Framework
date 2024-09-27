package modchart.modifiers;

import modchart.core.util.ModchartUtil;
import modchart.Manager;
import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import openfl.geom.Vector3D;
import flixel.FlxG;
import flixel.math.FlxMath;

class Reverse extends Modifier
{
	public function getReverseValue(dir:Int, player:Int)
	{
        var kNum = getKeycount();
        var val:Float = 0;
        if(dir>=kNum * 0.5)
            val += getPercent("split");

        if((dir%2)==1)
            val += getPercent("alternate");

        var first = kNum * 0.25;
        var last = kNum-1-first;

        if(dir>=first && dir<=last)
            val += getPercent("cross");

        val += getPercent('reverse') + getPercent("reverse" + Std.string(dir));

        if(getPercent("unboundedReverse")==0){
            val %=2;
            if(val>1)val=2-val;
        }

        return val;
    }
    override public function render(curPos:Vector3D, params:RenderParams)
    {
		var initialY = Manager.instance.getReceptorY(params.receptor, params.field);
		var reversePerc = getReverseValue(params.receptor, params.field);
		var shift = FlxMath.lerp(initialY, HEIGHT - initialY - ARROW_SIZE, reversePerc);
		
		var centerPercent = getPercent('centered');		
		shift = FlxMath.lerp(shift, (HEIGHT * 0.5) - ARROW_SIZEDIV2, centerPercent);
		curPos.y = shift + FlxMath.lerp(params.hDiff, -params.hDiff, reversePerc);

		return curPos;
    }
	override public function getAliases()
		return ["cross", "split", "alternate", "centered", "unboundedReverse"];
	override public function shouldRun():Bool
		return true;
}