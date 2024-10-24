package modchart.core.util;

import flixel.util.FlxColor;

class Constants {}

@:structInit
class RenderParams
{
	public var perc:Float;
	public var sPos:Float;
	public var time:Float;
	public var fBeat:Float;
	public var hDiff:Float;
	public var receptor:Int;
	public var field:Int;
	public var arrow:Bool;
}

@:structInit
class NoteData
{
	public var time:Float;
	public var hDiff:Float;
	public var receptor:Int;
	public var field:Int;
	public var arrow:Bool;
}

@:structInit
class Visuals
{
	public var scaleX:Float;
	public var scaleY:Float;
	public var alpha:Float;
	public var angle:Float;
	public var zoom:Float;
	public var glow:Float;
	public var glowR:Float;
	public var glowG:Float;
	public var glowB:Float;
}