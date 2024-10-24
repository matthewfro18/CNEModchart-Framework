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
		data.angle -= (params.fBeat * (getPercent('confusion', params.field) + getPercent('confusion' + Std.string(params.receptor)))) % 360;
		// offset
		data.angle += getPercent('confusionOffset', params.field) + getPercent('confusionOffset' + Std.string(params.receptor));
		// other
		data.angle += getPercent('dizzy', params.field) * (params.hDiff * 0.1 * (1 + getPercent('dizzySpeed', params.field)));

		return data;
	}

	override public function shouldRun(params:RenderParams):Bool
		return true;
}