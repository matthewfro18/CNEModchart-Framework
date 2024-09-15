package modchart.modifiers;

import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import openfl.geom.Vector3D;
import modchart.core.util.ModchartUtil;

class OpponentSwap extends Modifier
{
    override public function render(curPos:Vector3D, params:RenderParams)
    {
		var distX = WIDTH / getKeycount();
		curPos.x -= distX * ModchartUtil.sign((params.field + 1) * 2 - 3) * params.perc;
        return curPos;
    }

}