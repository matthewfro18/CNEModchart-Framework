package modchart.modifiers;

import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import modchart.core.util.Constants.Visuals;
import openfl.geom.Vector3D;
import flixel.math.FlxMath;
import modchart.core.util.ModchartUtil;

class Stealth extends Modifier
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

		// sudden
		var yPos = 50 + params.hDiff;
		data.alpha += getPercent("sudden") * ModchartUtil.clamp(FlxMath.remapToRange(yPos, getSuddenStart(),getSuddenEnd(),0,-1),-1,0);
		
		data.alpha *= getPercent('alpha');
		data.alpha += getPercent('alphaOffset');

		return data;
	}

	public function getSuddenEnd()
	{
    	return (HEIGHT * 0.5) + (120 * (1 + getPercent('suddenPeriod'))) * FlxMath.remapToRange(getPercent('sudden'), 0,1,1,1.25) + (HEIGHT * 0.5) * getPercent('suddenOffset');
	}
	public function getSuddenStart()
	{
		return (HEIGHT * 0.5) + (120 * (1 + getPercent('suddenPeriod'))) * FlxMath.remapToRange(getPercent('sudden'), 0,1,0,0.25) + (HEIGHT * 0.5) * getPercent('suddenOffset');
	}
	override public function shouldRun():Bool
		return true;
}