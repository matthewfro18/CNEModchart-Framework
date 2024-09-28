package modchart.modifiers;

import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import openfl.geom.Vector3D;

class ScrollAngle extends Modifier
{
	/*
	public var _rotatedVector:Vector3D;

	public function getRotation():Vector3D
	{
		var angleX = getPercent('scrollAngleX');
		var angleY = getPercent('scrollAngleY');
		var angleZ = getPercent('scrollAngleZ');

		var curvedDistace = params.hDiff * 0.02 * getPercent('curvedScrollPeriod');

		_rotatedVector.setTo(
			angleX + getPercent('curvedScrollX') * curvedDistace,
			angleY + getPercent('curvedScrollY') * curvedDistace,
			angleZ + getPercent('curvedScrollZ') * curvedDistace
		);
	}
	override public function rotateScroll(curRot:Vector3D):Vector3D
	{
		return curRot.add(getRotation());
	}

	override public function shouldRun():Bool
		return true;*/
}