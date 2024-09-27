package modchart.modifiers;

import modchart.core.util.ModchartUtil;
import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import openfl.geom.Vector3D;
import flixel.FlxG;
import flixel.math.FlxMath;
import funkin.backend.system.Conductor;

class ReceptorScroll extends Modifier
{
    override public function render(curPos:Vector3D, params:RenderParams)
    {
		final moveSpeed = Conductor.crochet * 3;

		var diff = -params.hDiff;
		var sPos = Conductor.songPosition;
		var vDiff = -(diff - sPos) / moveSpeed;
		var reversed = Math.floor(vDiff)%2 == 0;
	
		var startY = curPos.y;
		var revPerc = reversed ? 1-vDiff%1 : vDiff%1;
		// haha perc 30
		var upscrollOffset = 50;
		var downscrollOffset = HEIGHT - 150;
	
		var endY = upscrollOffset + ((downscrollOffset - ARROW_SIZEDIV2) * revPerc);
	
		curPos.y = FlxMath.lerp(startY, endY, getPercent('receptorScroll'));
		return curPos;
    }
	override public function shouldRun():Bool
		return getPercent('receptorScroll') != 0;
}