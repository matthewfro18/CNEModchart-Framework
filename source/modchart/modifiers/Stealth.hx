package modchart.modifiers;

import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import modchart.core.util.Constants.Visuals;
import openfl.geom.Vector3D;
import flixel.math.FlxMath;
import flixel.FlxG;
import modchart.core.util.ModchartUtil;
import funkin.backend.system.Conductor;

// this is literally copied and pasted from te
// im tired today so i will replace this for my own tomorrow
// - theodev
class Stealth extends Modifier
{
	public function new()
	{
		super();
	}
	public function getHiddenSudden(){
		return getPercent("hidden") * getPercent("sudden");
	}

	public function getHiddenEnd(){
		return (FlxG.height* 0.5) + fadeDistY * FlxMath.remapToRange(getHiddenSudden(),0,1,-1,-1.25) + (FlxG.height* 0.5) * getPercent("hiddenOffset");
	}

	public function getHiddenStart(){
		return (FlxG.height* 0.5) + fadeDistY * FlxMath.remapToRange(getHiddenSudden(),0,1,0,-0.25) + (FlxG.height* 0.5) * getPercent("hiddenOffset");
	}

	public function getSuddenEnd(){
		return (FlxG.height* 0.5) + fadeDistY * FlxMath.remapToRange(getHiddenSudden(),0,1,1,1.25) + (FlxG.height* 0.5) * getPercent("suddenOffset");
	}

	public function getSuddenStart(){
		return (FlxG.height* 0.5) + fadeDistY * FlxMath.remapToRange(getHiddenSudden(),0,1,0,0.25) + (FlxG.height* 0.5) * getPercent("suddenOffset");
	}

	function getVisibility(yPos:Float):Float
	{
		var distFromCenter = yPos - (HEIGHT * 0.5);
		var alpha:Float = 0;

		if(yPos<0 && getPercent("stealthPastReceptors")==0)
			return 1.0;

		var time = Conductor.songPosition/1000;

		if(getPercent("hidden")!=0){
			var hiddenAdjust = ModchartUtil.clamp(FlxMath.remapToRange(yPos,getHiddenStart(),getHiddenEnd(),0,-1),-1,0);
			alpha += getPercent("hidden")*hiddenAdjust;
		}

		if(getPercent("sudden")!=0){
			var suddenAdjust = ModchartUtil.clamp(FlxMath.remapToRange(yPos,getSuddenStart(),getSuddenEnd(),0,-1),-1,0);
			alpha += getPercent("sudden")*suddenAdjust;
		}

		if(getPercent('alpha')!=0)
			alpha -= getPercent('alpha');


		if(getPercent("blink")!=0){
			var f = quantizeAlpha(sin(time*10),0.3333);
			alpha += FlxMath.remapToRange(f,0,1,-1,0);
		}

		if(getPercent("vanish")!=0){
			var realFadeDist:Float = 120;
			alpha += FlxMath.remapToRange(Math.abs(distFromCenter),realFadeDist,2*realFadeDist,-1,0)*getPercent("vanish");
		}

		return ModchartUtil.clamp(alpha+1,0,1);
	}
	function getGlow(visible:Float){
		var glow = FlxMath.remapToRange(visible, 1, 0.5, 0, 1.8);
		return ModchartUtil.clamp(glow,0,1);
	}

	function getRealAlpha(visible:Float){
		var alpha = FlxMath.remapToRange(visible, 0.5, 0, 1, 0);
		return ModchartUtil.clamp(alpha,0,1);
	}
	inline public static function quantizeAlpha(f:Float, interval:Float){
		return Std.int((f+interval/2)/interval)*interval;
	}

	override public function visuals(data:Visuals, params:RenderParams)
	{
		var alpha:Float = data.alpha;

		if (params.arrow)
		{
			var yPos:Float = 50 + ARROW_SIZEDIV2 + params.hDiff * getScrollSpeed() * 0.45;

			var alphaMod = (1 - getPercent("alpha")) * (1 - getPercent('alpha${params.receptor}')) * (1 - getPercent("arrowAlpha"))* (1 - getPercent('noteAlpha${params.receptor}'));
			var vis = getVisibility(yPos);

			if (getPercent("hideStealthGlow") == 0)
			{
				alpha *= getRealAlpha(vis);
				data.glow -= getGlow(vis);
			}
			else
				alpha *= vis;

			alpha *= alphaMod;
		}
		else
		{
			alpha *= (1 - getPercent("alpha")) * (1 - getPercent('alpha${params.receptor}'));

			if (getPercent("dark") != 0 || getPercent('dark${params.receptor}') != 0)
			{
				var vis = (1 - getPercent("dark")) * (1 - getPercent('dark${params.receptor}'));
				if (getPercent("hideDarkGlow") == 0)
				{
					alpha *= getRealAlpha(vis);
					data.glow = getGlow(vis);
				}else
					alpha *= vis;
			}
		}
		
		data.alpha = alpha;
		return data;
	}
	public static var fadeDistY = 120;

	override public function shouldRun():Bool
		return true;
}