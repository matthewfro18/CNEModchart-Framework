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
		var outPos = pos;

		var halfScreenOffset = new Vector3D(FlxG.width / 2, FlxG.height / 2);
		outPos = outPos.subtract(halfScreenOffset);

		var fov = PI / 2;
		var screenRatio = 1;
		var near = 0;
		var far = 1;

		var perspectiveZ = outPos.z - 1;
		if (perspectiveZ > 0)
			perspectiveZ = 0; // To prevent coordinate overflow :/

		var x = outPos.x / fastTan(fov / 2);
		var y = outPos.y * screenRatio / fastTan(fov / 2);

		var a = (near + far) / (near - far);
		var b = 2 * near * far / (near - far);
		var z = a * perspectiveZ + b;

		var result = new Vector3D(x / z, y / z, z, outPos.w).add(halfScreenOffset);

		return result;
	}
	public static function fastTan(ang:Float)
		return FlxMath.fastSin(ang) / FlxMath.fastCos(ang);
	public static function getHoldVertex(top:Array<Vector3D>, bot:Array<Vector3D>)
	{
		var vertices = [
			top[0].x, top[0].y,
			top[1].x, top[1].y,
			bot[0].x, bot[0].y,
			bot[1].x, bot[1].y
		];
		var vectorizedVerts = new DrawData(12, true, vertices);

		return vectorizedVerts;
	}
	public static function getHoldUVT(arrow:Note)
	{
		var frameUV = arrow.frame.uv;
		var frameHeight = frameUV.height - frameUV.y;

		var uvSub = 1.0 / 1;
		var uvOffset = uvSub * 0;

		var upperV = frameUV.y + (uvSub + uvOffset) * frameHeight;
		var lowerV = frameUV.y + uvOffset * frameHeight;
		var uv = new DrawData(12, false, [
			frameUV.x, 		lowerV,
			frameUV.width,  lowerV,
			frameUV.x,		upperV,
			frameUV.width,	upperV
		]);
		return uv;
	}
	public static function getHoldIndices(arrow:Note)
	{

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
	public static function applyObjectZoom(obj:FlxSprite, zoom:Float)
	{
		if(zoom != 1){
			var centerX = FlxG.width * 0.5;
			var centerY = FlxG.height * 0.5;

			obj.scale.scale(zoom);
			obj.x = (obj.x - centerX) * zoom + centerX;
			obj.y = (obj.y - centerY) * zoom + centerY;
		}

		return obj;
	}
}