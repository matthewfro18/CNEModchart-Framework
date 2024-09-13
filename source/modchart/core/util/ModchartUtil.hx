package modchart.core.util;

import openfl.geom.Vector3D;
import flixel.math.FlxMath;

// Some functions was stolen from schmovin lol
class ModchartUtil
{
    public static function rotate(x:Float, y:Float, angle:Float)
    {
        final sin = FlxMath.fastSin(angle);
        final cos = FlxMath.fastCos(angle);

        return [
            x * cos - y * sin,
            x * sin + y * cos
        ];
    };
    public static function rotate3DVector(vec:Vector3D, angleX:Float, angleY:Float, angleZ:Float)
	{
		var rad = Math.PI / 180;

		var rotateZ = rotate(vec.x, vec.y, angleZ * rad);
		var offZ = new Vector3D(rotateZ[0], rotateZ[1], vec.z);

		var rotateY = rotate(offZ.x, offZ.z, angleY * rad);
		var offY = new Vector3D(rotateY[0], offZ.y, rotateY[1]);

		var rotateX = rotate(offY.z, offY.y, angleX * rad);
		var offX = new Vector3D(offY.x, rotateX[1], rotateX[0]);

		return offX;
	}
	public static inline function getHalfPos():Vector3D
	{
		return new Vector3D(ARROW_SIZEDIV2, ARROW_SIZEDIV2, 0, 0);
	}
	public static var ARROW_SIZE:Float = 160 * 0.7;
    public static var ARROW_SIZEDIV2:Float = (160 * 0.7) * 0.5;
    public static var PI:Float = Math.PI;
}