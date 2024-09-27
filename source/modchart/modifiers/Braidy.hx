package modchart.modifiers;

import modchart.core.util.ModchartUtil;
import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import openfl.geom.Vector3D;
import flixel.FlxG;
import funkin.backend.system.Conductor;

// i sawed this on a notitg modchart and i liked it some much, and i decided to recreate it
// calling this braider cus it look like a braid looool
// update: i just saw this is invert sine
class Braidy extends Modifier
{
    override public function render(curPos:Vector3D, params:RenderParams)
    {
		var shift = ARROW_SIZE * getPercent('braidy') * -(params.receptor % 2 - 0.5) / 0.5;

		curPos.x += sin(params.hDiff * PI / 222) * shift;
        return curPos;
    }
	override public function shouldRun():Bool
		return getPercent('braidy') != 0;
}