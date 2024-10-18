package modchart.modifiers;

import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import modchart.core.util.Constants.Visuals;
import openfl.geom.Vector3D;
import flixel.math.FlxMath;
import flixel.FlxG;
import modchart.core.util.ModchartUtil;
import funkin.backend.system.Conductor;

class Stealth extends Modifier
{
	public static var fadeDistY = 65;

	public function getSuddenEnd(){
		return (FlxG.height* 0.5) + fadeDistY * FlxMath.remapToRange(getPercent('sudden'),0,1,1,1.25) + (FlxG.height* 0.5) * getPercent("suddenOffset");
	}

	public function getSuddenStart(){
		return (FlxG.height* 0.5) + fadeDistY * FlxMath.remapToRange(getPercent('sudden'),0,1,0,0.25) + (FlxG.height* 0.5) * getPercent("suddenOffset");
	}
	public function new()
	{
		super();

		setPercent('alpha', 1, -1);
	}
	override public function visuals(data:Visuals, params:RenderParams)
	{
		var suddenAlpha = ModchartUtil.clamp(FlxMath.remapToRange(params.hDiff, getSuddenStart(), getSuddenEnd(), 0, -1), -1, 0);
		
		data.alpha = getPercent('alpha') + getPercent('alphaOffset');

		// sudden
		var sudden = getPercent('sudden');
		data.alpha += suddenAlpha * sudden;
		data.glow -= getPercent('flash') + (-suddenAlpha * 2) * sudden;

		return data;
	}

	override public function shouldRun():Bool
		return true;
}