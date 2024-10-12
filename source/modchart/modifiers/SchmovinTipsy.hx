package modchart.modifiers;

import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import openfl.geom.Vector3D;

class SchmovinTipsy extends Modifier
{
    override public function render(curPos:Vector3D, params:RenderParams)
    {
        curPos.y += sin(params.fBeat / 4 * PI + params.receptor) * ARROW_SIZEDIV2 * getPercent('schmovinTipsy');
        return curPos;
    }
	override public function shouldRun():Bool
		return getPercent('schmovinTipsy') != 0;
}