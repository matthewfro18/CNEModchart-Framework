package modchart.modifiers.false_paradise;

import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import openfl.geom.Vector3D;

class Wiggle extends Modifier
{
    override public function render(curPos:Vector3D, params:RenderParams)
    {
		curPos.x += sin(params.fBeat) * getPercent('wiggle') * 20;
		curPos.y += sin(params.fBeat + 1) * getPercent('wiggle') * 20;

		setPercent('rotateZ', (sin(params.fBeat) * 0.2 * getPercent('wiggle')) * 180 / Math.PI);

		return curPos;
    }
	override public function shouldRun():Bool
		return getPercent('wiggle') != 0;
}