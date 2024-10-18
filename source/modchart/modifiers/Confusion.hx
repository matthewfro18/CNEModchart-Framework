package modchart.modifiers;

import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import modchart.core.util.Constants.Visuals;
import openfl.geom.Vector3D;

class Confusion extends Modifier
{
	override public function visuals(data:Visuals, params:RenderParams)
	{
		// real confusion
		data.angle -= (params.fBeat * (getPercent('confusion') + getPercent('confusion' + Std.string(params.receptor)))) % 360;
		// offset
		data.angle += getPercent('confusionOffset') + getPercent('confusionOffset' + Std.string(params.receptor));
		// other
		data.angle += getPercent('dizzy') * (params.hDiff * 0.1 * (1 + getPercent('dizzySpeed')));

		return data;
	}

	override public function shouldRun():Bool
		return true;
}