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
	public static function getDownscrollRatio()
	{
		return (ModchartUtil.getDownscroll() ? -1 : 1);
	}
	public static function getDownscroll()
	{
		return PlayState?.instance?.camHUD?.downscroll ?? false;
	}
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

	// from schmovin
	public static function perspective(pos:Vector3D)
	{
		final tan:Float->Float = (num) -> FlxMath.fastSin(num) / FlxMath.fastCos(num);

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

		var x = outPos.x / tan(fov / 2);
		var y = outPos.y * screenRatio / tan(fov / 2);

		var a = (near + far) / (near - far);
		var b = 2 * near * far / (near - far);
		var z = a * perspectiveZ + b;

		var result = new Vector3D(x / z, y / z, z, outPos.w).add(halfScreenOffset);

		return result;
	}
	public static function getHoldVertex(thisPos:Vector3D, nextPos:Vector3D, quads:Array<Vector3D>)
	{
		final thisQuad = quads[0];
		final nextQuad = quads[1];

		return new DrawData(12, true, [
			// top left
			thisPos.x, thisPos.y,
			// top right
			thisPos.x + thisQuad.x, thisPos.y + thisQuad.y,
			// middle left
			FlxMath.lerp(thisPos.x, nextPos.x, 0.5), FlxMath.lerp(thisPos.y, nextPos.y, 0.5),
			// middle right
			FlxMath.lerp(thisPos.x + thisQuad.x, nextPos.x + nextQuad.x, 0.5), FlxMath.lerp(thisPos.y + thisQuad.y, nextPos.y + nextQuad.y, 0.5),
			// bottom left
			nextPos.x, nextPos.y,
			// bottom right
			nextPos.x + nextQuad.x, nextPos.y + nextQuad.y
		]);
	}
	public static function getHoldIndices(arrow:Note)
	{
		var uv = arrow.frame.uv;
		return new DrawData(12, true, [
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
		]);
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
	public inline static function getArrowDistance(arrow:Note, offsetMS:Float = 0, downscrollAffects:Bool = true)
	{
		return (downscrollAffects ? ModchartUtil.getDownscrollRatio() : 1) * (((arrow.strumTime + offsetMS) - Conductor.songPosition) * (0.45 * CoolUtil.quantize(arrow.strumLine.members[arrow.strumID].getScrollSpeed(arrow), 100)));
	}
    public static var HOLD_SIZE:Float = 44 * 0.7;
	public static var ARROW_SIZE:Float = 160 * 0.7;
    public static var ARROW_SIZEDIV2:Float = (160 * 0.7) * 0.5;
    public static var PI:Float = Math.PI;

	public static function applyHoldOffset(curPos:Vector3D, quad:Vector3D)
	{
		var outOffset = ModchartUtil.getHalfPos();

		var quadOffset = quad.clone();
		quadOffset.scaleBy(.5);

		outOffset.decrementBy(quadOffset);
		outOffset.scaleBy(1 / curPos.z);

		curPos.incrementBy(outOffset);

		return curPos;
	}
	public static function getClippedRatio(arrow:Note)
	{
		return arrow.wasGoodHit ? (FlxMath.bound(
			(Conductor.songPosition - arrow.strumTime) / (ARROW_SIZE) *
			(0.45 * CoolUtil.quantize(arrow.strumLine.members[arrow.strumID].getScrollSpeed(arrow), 100)),
		0, 1)) : 0;
	}
	public static function lerpVector3D(start:Vector3D, end:Vector3D, ratio:Float)
	{
		final diff = end.subtract(start);
		diff.scaleBy(ratio);

		return start.add(diff);
	}
}