package modchart.modifiers;

import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import openfl.geom.Vector3D;

class Invert extends Modifier
{
    override public function render(curPos:Vector3D, params:RenderParams)
    {
        // Invert
		curPos.x += ARROW_SIZE * getPercent('invert') * -(params.receptor % 2 - 0.5) / 0.5;
        // Flip
		curPos.x -= ARROW_SIZE * (params.receptor - 1.5) * getPercent('flip') * 2;

        return curPos;
    }

	override public function shouldRun():Bool
		return true;
}