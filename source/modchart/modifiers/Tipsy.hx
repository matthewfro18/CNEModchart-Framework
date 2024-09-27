package modchart.modifiers;

import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import openfl.geom.Vector3D;

class Tipsy extends Modifier
{
    override public function render(curPos:Vector3D, params:RenderParams)
    {
		var speed = getPercent('tipsySpeed');
		var offset = getPercent('tipsyOffset');

		var tipsy = (cos((params.sPos * 0.001 * ((speed * 1.2) + 1.2) + params.receptor * ((offset * 1.8) + 1.8))) * ARROW_SIZE * .4);

		var tipAddition = new Vector3D(
			getPercent('tipsyX'),
			getPercent('tipsyY') + getPercent('tipsy'),
			getPercent('tipsyZ')
		);
		tipAddition.scaleBy(tipsy);

        return curPos.add(tipAddition);
    }
    override public function getAliases()
    {
        return ['tipsyX', 'tipsyY', 'tipsyZ'];
    }
	override public function shouldRun():Bool
		return true;
}