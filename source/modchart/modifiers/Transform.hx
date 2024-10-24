package modchart.modifiers;

import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import openfl.geom.Vector3D;

class Transform extends Modifier
{
    override public function render(curPos:Vector3D, params:RenderParams)
    {
        curPos.x += getPercent('x', params.field) + getPercent('xoffset', params.field) + getPercent('x' + Std.string(params.receptor));
        curPos.y += getPercent('y', params.field) + getPercent('yoffset', params.field) + getPercent('y' + Std.string(params.receptor));
        curPos.z += getPercent('z', params.field) + getPercent('zoffset', params.field) + getPercent('z' + Std.string(params.receptor));

        return curPos;
    }
	override public function getAliases():Array<String>
		return ['x', 'y', 'z'];
	override public function shouldRun(params:RenderParams):Bool
		return true;
}