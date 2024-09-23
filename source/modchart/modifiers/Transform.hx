package modchart.modifiers;

import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import openfl.geom.Vector3D;

class Transform extends Modifier
{
    override public function render(curPos:Vector3D, params:RenderParams)
    {
        curPos.x += getSubmod('x') + getSubmod('x' + Std.string(params.receptor));
        curPos.y += getSubmod('y') + getSubmod('y' + Std.string(params.receptor));
        curPos.z += getSubmod('z') + getSubmod('z' + Std.string(params.receptor));

        return curPos;
    }
	override public function getAliases():Array<String>
		return ['x', 'y', 'z'];
}