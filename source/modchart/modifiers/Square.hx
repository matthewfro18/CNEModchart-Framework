package modchart.modifiers;

import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import openfl.geom.Vector3D;

class Square extends Modifier
{
    override public function render(curPos:Vector3D, params:RenderParams)
    {
		final period = 200;
		final time = -params.hDiff / period + 1;
		final phaseShift = -0.001;
		final result = (Math.floor(time + phaseShift)) % 2 - 0.5;

        curPos.x += result * ARROW_SIZE * percent;

        return curPos;
    }
}