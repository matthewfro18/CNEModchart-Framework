package modchart.modifiers;

import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import modchart.core.util.Constants.Visuals;
import openfl.geom.Vector3D;

class Scale extends Modifier
{
	public function new()
	{
		super();

		setPercent('scale', 1, -1);
		setPercent('scaleX', 1, -1);
		setPercent('scaleY', 1, -1);
	}
	override public function visuals(data:Visuals, params:RenderParams)
	{
		final scaleForce = getPercent('scaleForce');

		if (scaleForce != 0)
		{
			data.scaleX = scaleForce;
			data.scaleY = scaleForce;
			return data;
		}

		// normal scale
		data.scaleX *= getPercent('scaleX');
		data.scaleY *= getPercent('scaleY');

		// tiny
		data.scaleX *= Math.pow(0.5, getPercent('tinyX')) * Math.pow(0.5, getPercent('tiny'));
		data.scaleY *= Math.pow(0.5, getPercent('tinyY')) * Math.pow(0.5, getPercent('tiny'));

		data.scaleX *= getPercent('scale');
		data.scaleY *= getPercent('scale');

		return data;
	}

	override public function shouldRun():Bool
		return true;
}