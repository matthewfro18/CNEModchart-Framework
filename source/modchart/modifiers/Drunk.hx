package modchart.modifiers;

import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import openfl.geom.Vector3D;

class Drunk extends Modifier
{
    override public function render(curPos:Vector3D, params:RenderParams)
    {
		var speed = getPercent('drunkSpeed');
		var period = getPercent('drunkPeriod');
		var offset = getPercent('drunkOffset');

        var shift = params.sPos * 0.001 * (1 + speed) + params.receptor * ((offset * 0.2) + 0.2) + params.hDiff * ((period * 10) + 10) / HEIGHT;
        var drunk = (cos(shift) * ARROW_SIZE * 0.5);

        curPos.x += drunk * (getPercent('drunk') + getPercent('drunkX'));
        curPos.y += drunk * getPercent('drunkY');
        curPos.z += drunk * getPercent('drunkZ');

        return curPos;
    }
	override public function shouldRun():Bool
		return true;
}