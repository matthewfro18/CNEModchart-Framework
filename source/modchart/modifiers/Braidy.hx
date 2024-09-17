package modchart.modifiers;

import modchart.core.util.ModchartUtil;
import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import openfl.geom.Vector3D;
import flixel.FlxG;
import funkin.backend.system.Conductor;

// i sawed this on a notitg modchart and i liked it some much, and i decided to recreate it
// calling this braider cus it look like a braid looool
class Braidy extends Modifier
{
    override public function render(curPos:Vector3D, params:RenderParams)
    {
		if (!params.arrow)
			return curPos;

		var amp:Float = Math.min(params.receptor % 3, 1);
		amp = params.receptor == 2 ? -amp : amp;

		curPos.x += ARROW_SIZE * sin(params.hDiff * amp * getSubmod('braidySpeed', 1) / 222);
        return curPos;
    }
}