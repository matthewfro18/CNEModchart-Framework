package modchart.modifiers;

import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import openfl.geom.Vector3D;

class ZigZag extends Modifier
{
    override public function render(curPos:Vector3D, params:RenderParams)
    {
		var theta = -params.hDiff / ARROW_SIZE * PI;
		var outRelative = Math.acos(cos(theta + PI / 2)) / PI * 2 - 1;

        curPos.x += outRelative * ARROW_SIZEDIV2 * getPercent('zigZag');

        return curPos;
    }
	override public function shouldRun():Bool
		return getPercent('zigZag') != 0;
	override public function getAliases():Array<String>
		return ["triangle", "trianglePath", "zigZagPath"];
}