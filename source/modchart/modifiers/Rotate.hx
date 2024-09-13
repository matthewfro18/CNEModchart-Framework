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
		final origin:Vector3D = new Vector3D(50 + WIDTH / 2 * params.field + 2 * ARROW_SIZE, ((HEIGHT - ARROW_SIZE) * (HEIGHT / 720) * 0.5));
		final diff = curPos.subtract(origin);
		final out = ModchartUtil.rotate3DVector(diff, getSubmod('rotateX'), getSubmod('rotateY'), getSubmod('rotateZ'));
		curPos.copyFrom(origin.add(out));
		return curPos;
    }
	override public function getAliases():Array<String>
		return ['rotateX', 'rotateY', 'rotateZ'];
}