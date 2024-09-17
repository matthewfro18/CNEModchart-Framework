package modchart.modifiers;

import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import openfl.geom.Vector3D;

class SawTooth extends Modifier
{
    override public function render(curPos:Vector3D, params:RenderParams)
    {
		final period = 1 + getSubmod("sawtoothPeriod");
		curPos.x += (percent * ARROW_SIZE) * ((0.5 / period * params.hDiff) / ARROW_SIZE - Math.floor((0.5 / period * params.hDiff) / ARROW_SIZE));

        return curPos;
    }
	override public function getAliases():Array<String>
		return [];
}