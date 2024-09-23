package modchart.modifiers;

import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import openfl.geom.Vector3D;

class Tipsy extends Modifier
{
    override public function render(curPos:Vector3D, params:RenderParams)
    {
		var perc = getSubmod('tipsy');
		var speed = getSubmod('tipsySpeed');
		var offset = getSubmod('tipsyOffset');

		var tipsy = (cos((params.sPos * 0.001 * ((speed * 1.2) + 1.2) + params.receptor * ((offset * 1.8) + 1.8))) * ARROW_SIZE * .4);

        curPos.x += tipsy * getSubmod('tipsyX');
        curPos.y += tipsy * (percent * getSubmod('tipsyY', 1));
        curPos.z += tipsy * getSubmod('tipsyZ');

        return curPos;
    }
    override public function getAliases()
    {
        return ['tipsyX', 'tipsyY', 'tipsyZ'];
    }
}