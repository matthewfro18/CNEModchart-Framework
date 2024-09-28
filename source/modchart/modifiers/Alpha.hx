package modchart.modifiers;

import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import modchart.core.util.Constants.Visuals;
import openfl.geom.Vector3D;

class Alpha extends Modifier
{
	public function new()
	{
		super();

		setPercent('alpha', 1, -1);
	}
	override public function visuals(data:Visuals, params:RenderParams)
	{
		final alphaForce = getPercent('alphaForce');

		if (alphaForce != 0)
		{
			data.alpha = alphaForce;
			return data;
		}

		data.alpha *= getPercent('alpha');
		data.alpha += getPercent('alphaOffset');

		return data;
	}

	override public function shouldRun():Bool
		return true;
}