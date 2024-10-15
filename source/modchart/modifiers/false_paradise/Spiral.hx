package modchart.modifiers.false_paradise;

import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import openfl.geom.Vector3D;
import funkin.backend.system.Conductor;
import modchart.core.util.ModchartUtil;

class Spiral extends Modifier
{
    override public function render(curPos:Vector3D, params:RenderParams)
    {
		var centerX = WIDTH * .5;
		var centerY = HEIGHT * .5;
		var radiusOffset = -params.hDiff * .25;
		var radius = radiusOffset + getPercent('spiralDist') * params.receptor;
		var outX = centerX + cos(-params.hDiff / Conductor.crochet * PI + params.fBeat * (PI * .25)) * radius;
		var outY = centerY + sin(-params.hDiff / Conductor.crochet * PI - params.fBeat * (PI * .25)) * radius;

		return ModchartUtil.lerpVector3D(curPos, new Vector3D(outX, outY, radius / (centerY * 4) - 1, 0), getPercent('spiral'));
    }
	override public function shouldRun():Bool
		return getPercent('spiral') != 0;
}