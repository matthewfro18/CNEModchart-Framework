package modchart.modifiers;

import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import openfl.geom.Vector3D;

class OpponentSwap extends Modifier
{
    override public function render(curPos:Vector3D, params:RenderParams)
    {
		var distX = WIDTH / getKeycount();
		curPos.x -= distX * sign((params.field + 1) * 2 - 3) * params.perc;
        return curPos;
    }
	inline function sign(x:Int)
		return x == 0 ? 0 : (x <= -1 ? -1 : 1);
}