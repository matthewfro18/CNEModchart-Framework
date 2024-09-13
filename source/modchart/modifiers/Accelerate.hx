package modchart.modifiers;

import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import openfl.geom.Vector3D;
import flixel.tweens.FlxEase;

class Accelerate extends Modifier
{
    override public function render(curPos:Vector3D, params:RenderParams)
    {
		var off = params.hDiff * 1.5 / ((params.hDiff + (720 * getSubmod('accelerateScale', 1)) / 1.2) / (720 * getSubmod('accelerateScale', 1)));
		curPos.y += clamp(percent * (off - params.hDiff), -600, 600);

        return curPos;
    }
	inline public static function scale(x:Float, l1:Float, h1:Float, l2:Float, h2:Float):Float
		return ((x - l1) * (h2 - l2) / (h1 - l1) + l2);
	inline public static function clamp(n:Float, l:Float, h:Float)
	{
		if (n > h)
			n = h;
		if (n < l)
			n = l;

		return n;
	}
}