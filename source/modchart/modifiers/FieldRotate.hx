package modchart.modifiers;

import modchart.core.util.ModchartUtil;
import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import openfl.geom.Vector3D;
import flixel.FlxG;

class FieldRotate extends Modifier
{
    override public function render(curPos:Vector3D, params:RenderParams)
    {
        var x:Float = getReceptorX(params.receptor, params.field);
		var origin:Vector3D = new Vector3D(x, ((HEIGHT - ARROW_SIZE) * (HEIGHT / 720) * 0.5));
		var out = ModchartUtil.rotate3DVector(curPos.subtract(origin), getSubmod('fieldRotateX'), getSubmod('fieldRotateY'), getSubmod('fieldRotateZ'));
		curPos.copyFrom(origin.add(out));
		return curPos;
    }
	override public function getAliases()
		return ['fieldRotateX', 'fieldRotateY', 'fieldRotateZ'];
}