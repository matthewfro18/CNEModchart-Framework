package modchart.modifiers;

import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import modchart.core.util.ModchartUtil;
import openfl.geom.Vector3D;
import flixel.math.FlxMath;

class Infinite extends PathModifier
{
    override function getPathName()
		return 'infinite';

	override function getMoveSpeed()
	{
		return 1850;
	}

	override function getPath():Array<Array<Vector3D>>
	{
		var infPath:Array<Array<Vector3D>> = [[], [], [], []];

		var r = 0;
		while (r < 360)
		{
			for (data in 0...infPath.length)
			{
				var rad = r * Math.PI / 180;
				infPath[data].push(new Vector3D(WIDTH * .5 + (sin(rad)) * 600,
					HEIGHT * .5 + (sin(rad) * cos(rad)) * 600, 0));
			}
			r += 15;
		}
		return infPath;
	}

}