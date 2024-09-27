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
		final angleX = getPercent('fieldRotateX');
		final angleY = getPercent('fieldRotateY');
		final angleZ = getPercent('fieldRotateZ');

		if ((angleX + angleY + angleZ) == 0)
			return curPos;

		var x:Float = (WIDTH * 0.5) - ARROW_SIZE - 54 + ARROW_SIZE * 1.5;
        switch (params.field)
        {
            case 0:
                x -= WIDTH * 0.5 - ARROW_SIZE * 2 - 100;
            case 1:
                x += WIDTH * 0.5 - ARROW_SIZE * 2 - 100;
        }
		x -= 56;

		var origin:Vector3D = new Vector3D(x, ((HEIGHT - ARROW_SIZE) * (HEIGHT / 720) * 0.5));
        var diff = curPos.subtract(origin);
		var out = ModchartUtil.rotate3DVector(diff, angleX, angleY, angleZ);
		curPos.copyFrom(origin.add(out));
        return curPos;
    }
	override public function getAliases()
		return ['fieldRotateX', 'fieldRotateY', 'fieldRotateZ'];

	override public function shouldRun():Bool
		return true;
}