package modchart.modifiers;

import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import openfl.geom.Vector3D;

class Transform extends Modifier
{
    override public function render(curPos:Vector3D, params:RenderParams)
    {
        curPos.x += getSubmod('x');
        curPos.y += getSubmod('y');
        curPos.z += getSubmod('z');

        return curPos;
    }
	override public function getAliases():Array<String>
		return ['x', 'y', 'z'];
}