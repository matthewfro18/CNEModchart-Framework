package modchart.modifiers;

import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import openfl.geom.Vector3D;

class Tipsy extends Modifier
{
    override public function render(curPos:Vector3D, params:RenderParams)
    {
        final speed = getSubmod('tipsySpeed', 1);
        final tipsy = sin((params.fBeat * speed) / 4 * PI + params.receptor) * ARROW_SIZE / 2;

        curPos.x += tipsy * getSubmod('tipsyX');
        curPos.y += tipsy * (percent * getSubmod('tipsyY', 1));
        curPos.z += tipsy * getSubmod('tipsyZ');

        return curPos;
    }
    override public function getAliases()
    {
        return ['tipsyX', 'tipsyY', 'tipsyZ'];
    }
}