package modchart.core.util;

import openfl.geom.Vector3D;
import flixel.math.FlxMath;
import flixel.graphics.tile.FlxDrawTrianglesItem.DrawData;
import funkin.game.Note;

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
	public static function getHoldVertex(thisPos:Vector3D, nextPos:Vector3D)
	{
		var newVertices = [];

		final thisWidth = (HOLD_SIZE * (1 / thisPos.z * 0.001));
		final nextWidth = (HOLD_SIZE * (1 / nextPos.z * 0.001));

		// top left
		newVertices.push(thisPos.x);
		newVertices.push(thisPos.y);
		// top right
		newVertices.push(thisPos.x + thisWidth);
		newVertices.push(thisPos.y);
		// middle left
		newVertices.push(FlxMath.lerp(thisPos.x, nextPos.x, 0.5));
		newVertices.push(FlxMath.lerp(thisPos.y, nextPos.y, 0.5));
		// middle right
		newVertices.push(FlxMath.lerp(thisPos.x + thisWidth, nextPos.x + nextWidth, 0.5));
		newVertices.push(FlxMath.lerp(thisPos.y, nextPos.y, 0.5));

		// bottmo left
		newVertices.push(nextPos.x);
		newVertices.push(nextPos.y);
		// bottom right
		newVertices.push(nextPos.x + nextWidth);
		newVertices.push(nextPos.y);

		return new DrawData(12, true, newVertices);
	}
	public static function getHoldIndices(arrow:Note)
	{
		var frame = arrow.frame;
		var uv = frame.uv;
		var graphic = frame.parent;
		
		var newUV = [
			// Top left
			uv.x, uv.y,
			// top right
			uv.width, uv.y,
			// middle left
			uv.x, FlxMath.lerp(uv.y, uv.height, 0.5),
			// middle right
			uv.width, FlxMath.lerp(uv.y, uv.height, 0.5),
			// botton left
			uv.x, uv.height,
			// bottom right
			uv.width, uv.height
		];
		return new DrawData(12, true, newUV);
	}
	// gonna keep this shits inline cus are basic funcions
	public static inline function getHalfPos():Vector3D
	{
		return new Vector3D(ARROW_SIZEDIV2, ARROW_SIZEDIV2, 0, 0);
	}
	// dude wtf it works
	public inline static function sign(x:Int)
	{
		return (x >> 31) | ((x != 0) ? 1 : 0);
	}
	public inline static function clamp(n:Float, l:Float, h:Float)
	{
		return Math.min(Math.max(n, l), h);
	}
    public static var HOLD_SIZE:Float = 44 * 0.7;
	public static var ARROW_SIZE:Float = 160 * 0.7;
    public static var ARROW_SIZEDIV2:Float = (160 * 0.7) * 0.5;
    public static var PI:Float = Math.PI;
}