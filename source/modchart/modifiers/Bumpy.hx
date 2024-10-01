package modchart.modifiers;

import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import openfl.geom.Vector3D;

class Bumpy extends Modifier
{
    override public function render(curPos:Vector3D, params:RenderParams)
    {
		var period = getPercent('bumpyPeriod');
		var offset = getPercent('bumpyOffset');
		var bumpy = (40 * sin((params.hDiff + (100.0 * offset)) / ((period * 24.0) + 24.0)));

		curPos.x += bumpy * getPercent('bumpyX'); 
        curPos.y += bumpy * getPercent('bumpyY');
        curPos.z += bumpy * (getPercent('bumpy') + getPercent('bumpyZ'));

        return curPos;
    }
	override public function shouldRun():Bool
		return true;
}