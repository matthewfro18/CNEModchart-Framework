package modchart.modifiers;

import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import openfl.geom.Vector3D;

class Rendering extends Modifier
{
    override public function render(curPos:Vector3D, params:RenderParams)
    {
        final arrowSpeed = getSubmod('drunkArrowSpeed', 1);
        final speed = getSubmod('drunkSpeed', 1);
        final amp = getSubmod('drunkAmplitude', 1);
        final shift = (params.receptor * 0.5 + (params.hDiff * arrowSpeed * speed) / 222 * PI) * amp;
        final drunk = sin((params.fBeat * speed) / 4 * PI + shift) * ARROW_SIZEDIV2 / 2;

        curPos.x += drunk * (percent * getSubmod('drunkX', 1));
        curPos.y += drunk * getSubmod('drunkY');
        curPos.z += drunk * getSubmod('drunkZ');

        return curPos;
    }
	override public function getAliases():Array<String>
		return ['drunkX', 'drunkY', 'drunkZ'];
}