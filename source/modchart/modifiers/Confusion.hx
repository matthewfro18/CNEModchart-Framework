package modchart.modifiers;

import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import modchart.core.util.Constants.Visuals;
import openfl.geom.Vector3D;

class Confusion extends Modifier
{
	override public function visuals(data:Visuals, params:RenderParams)
	{
		data.angle += 
			getPercent('confusion') + 
			getPercent('confusion' + Std.string(params.receptor)) +
			getPercent('dizzy') * (params.hDiff * 0.1 * (1 + getPercent('dizzySpeed')));

		return data;
	}

	override public function shouldRun():Bool
		return true;
}