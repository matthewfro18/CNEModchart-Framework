package modchart.modifiers;

import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import openfl.geom.Vector3D;
import flixel.tweens.FlxEase;
import flixel.math.FlxMath;
import modchart.core.util.ModchartUtil;

class Accelerate extends Modifier
{
    override public function render(curPos:Vector3D, params:RenderParams)
    {
		var off = params.hDiff * 1.5 / ((params.hDiff + (720 * getPercent('accelerateScale', 1)) / 1.2) / (720 * getPercent('accelerateScale', 1)));
		curPos.y += ModchartUtil.clamp(getPercent('accelerate') * (off - params.hDiff), -600, 600);

        return curPos;
    }

	override public function shouldRun():Bool
		return getPercent('accelerate') != 0;
}