package modchart.core.util;

import openfl.geom.Vector3D;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.tile.FlxDrawTrianglesItem.DrawData;
import funkin.game.Note;
import funkin.game.PlayState;
import funkin.backend.utils.CoolUtil;
import funkin.backend.system.Conductor;

class ModchartUtil
{
    public static function rotate(x:Float, y:Float, angle:Float)
    {
        final sin = FlxMath.fastSin(angle);
        final cos = FlxMath.fastCos(angle);

        return [x * cos - y * sin, x * sin + y * cos];
    };
	static final RAD = Math.PI / 180;
    public static function rotate3DVector(vec:Vector3D, angleX:Float, angleY:Float, angleZ:Float)
	{
		var rotateZ = rotate(vec.x, vec.y, angleZ * RAD);
		var offZ = new Vector3D(rotateZ[0], rotateZ[1], vec.z);

		var rotateY = rotate(offZ.x, offZ.z, angleY * RAD);
		var offY = new Vector3D(rotateY[0], offZ.y, rotateY[1]);

		var rotateX = rotate(offY.z, offY.y, angleX * RAD);
		var offX = new Vector3D(offY.x, rotateX[1], rotateX[0]);

		return offX;
	}

	static final __screenCenter = new Vector3D(FlxG.width / 2, FlxG.height / 2);
	static var fov = Math.PI / 2;
	static var near = 0;
	static var far = 1;
	static var range = near - far;

	// stolen & improved from schmovin (Camera3DTransforms)
	public static function perspective(pos:Vector3D)
	{
		var halfScreenOffset = new Vector3D(FlxG.width / 2, FlxG.height / 2);
		pos.decrementBy(halfScreenOffset);

		var worldZ = Math.min(pos.z - 1, 0); // bound to 1000 z

		var halfFovTan = 1 / fastTan(fov / 2);

		var projectionScale = (near + far) / range;
		var projectionOffset = 2 * near * far / range;
		var projectionZ = projectionScale * worldZ + projectionOffset;

		var projectedPos = new Vector3D(pos.x * halfFovTan, pos.y * halfFovTan, projectionZ * projectionZ);
		projectedPos.scaleBy(1 / projectionZ);
		projectedPos.incrementBy(halfScreenOffset);
		return projectedPos;
	}
	public static function fastTan(ang:Float)
		return FlxMath.fastSin(ang) / FlxMath.fastCos(ang);

	public static function getHoldVertex(upper:Array<Vector3D>, lower:Array<Vector3D>)
	{
		return [
			upper[0].x, upper[0].y,
			upper[1].x, upper[1].y,
			lower[0].x, lower[0].y,
			lower[1].x, lower[1].y
		];
	}
	public static function getHoldUVT(arrow:Note, subs:Int)
	{
		var uv = new DrawData<Float>(8 * subs, false, []);

		var frameUV = arrow.frame.uv;
		var frameHeight = frameUV.height - frameUV.y;

		var subDivited = 1.0 / subs;

		for (curSub in 0...subs)
		{
			var uvOffset = subDivited * curSub;
			var subIndex = curSub * 8;

			uv[subIndex] = uv[subIndex + 4] = frameUV.x;
			uv[subIndex + 2] = uv[subIndex + 6] = frameUV.width;
			uv[subIndex + 1] = uv[subIndex + 3] = frameUV.y + uvOffset * frameHeight;
			uv[subIndex + 5] = uv[subIndex + 7] = frameUV.y + (uvOffset + subDivited) * frameHeight;
		}

		return uv;
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
	public inline static function getScrollSpeed():Float
	{
		return PlayState?.instance?.scrollSpeed ?? 1;
	}
    public static var HOLD_SIZE:Float = 44 * 0.7;
	public static var ARROW_SIZE:Float = 160 * 0.7;
    public static var ARROW_SIZEDIV2:Float = (160 * 0.7) * 0.5;
    public static var PI:Float = Math.PI;

	public static function lerpVector3D(start:Vector3D, end:Vector3D, ratio:Float)
	{
		final diff = end.subtract(start);
		diff.scaleBy(ratio);

		return start.add(diff);
	}

	public static function applyVectorZoom(vec:Vector3D, zoom:Float)
	{
		if(zoom != 1){
			var centerX = FlxG.width * 0.5;
			var centerY = FlxG.height * 0.5;

			vec.x = (vec.x - centerX) * zoom + centerX;
			vec.y = (vec.y - centerY) * zoom + centerY;
		}

		return vec;
	}
}