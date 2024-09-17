package modchart.modifiers;

import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import openfl.geom.Vector3D;

class Square extends Modifier
{
    override public function render(curPos:Vector3D, params:RenderParams)
    {
		final square = (angle:Float) -> {
			var fAngle = angle % (PI * 2);

			return fAngle >= PI ? -1.0 : 1.0;
		};

		final offset = getSubmod("squareOffset");
		final period = getSubmod("squarePeriod");
		final amp = (PI * (params.hDiff + offset) / (ARROW_SIZE + (period * ARROW_SIZE)));

		curPos.x += percent * square(amp);

        return curPos;
    }
}