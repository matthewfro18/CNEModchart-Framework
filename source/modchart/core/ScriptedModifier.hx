package modchart.core;

import flixel.FlxG;
import funkin.game.PlayState;
import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import openfl.geom.Vector3D;
import flixel.math.FlxMath;

class ScriptedModifier extends Modifier
{
	public var _render:(Vector3D, RenderParams) -> Vector3D = null;
	public var _getAliases:() -> Array<String> = null;

	override public function render(a, b)
	{
		if (_render != null) 
			_render(a, b);

		return a;
	}
	override public function getAliases()
	{
		if (_getAliases != null) 
			return _getAliases();

		return [];
	}
}