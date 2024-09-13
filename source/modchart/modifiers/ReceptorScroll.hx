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
		var strumTime = params.hDiff - Conductor.songPosition;
		var time = -strumTime / Conductor.crochet / 4;
		var alt = Math.floor(time) % 2 == 0;
		var outTime = time % 1;
		if (alt)
			outTime = 1 - outTime;
		var upscrollY = ARROW_SIZEDIV2 + 50 + (HEIGHT - 50 - ARROW_SIZE) * outTime;
		curPos.y = FlxMath.lerp(curPos.y, upscrollY, percent);

		return curPos;
    }
}