package modchart.modifiers;

import modchart.core.util.ModchartUtil;
import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import openfl.geom.Vector3D;
import flixel.FlxG;

class Rotate extends Modifier
{
    override public function render(curPos:Vector3D, params:RenderParams)
    {
		var angleX = getPercent('rotateX');
		var angleY = getPercent('rotateY');
		var angleZ = getPercent('rotateZ');

		if ((angleX + angleY + angleZ) == 0)
			return curPos;
		
		final origin:Vector3D = new Vector3D(50 + WIDTH / 2 * params.field + 2 * ARROW_SIZE, ((HEIGHT - ARROW_SIZE) * (HEIGHT / 720) * 0.5));
		final diff = curPos.subtract(origin);
		final out = ModchartUtil.rotate3DVector(diff, angleX, angleY, angleZ);
		curPos.copyFrom(origin.add(out));
		return curPos;
    }
	override public function getAliases():Array<String>
		return ['rotateX', 'rotateY', 'rotateZ'];
	override public function shouldRun():Bool
		return true;
}