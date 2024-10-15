package modchart.core.util;

import flixel.util.FlxColor;

class Constants {}

typedef RenderParams = {
    // Mod Percent
    perc:Float,
    // Song Position
    sPos:Float,
	// Hit Time
	time:Float,
    // Beat Float
    fBeat:Float,
    // Hit Time Difference
    hDiff:Float,
    // Receptor ID
    receptor:Int,
    // Field ID
    field:Int,
	// If it is an arrow of receptor,
	arrow:Bool
};
typedef NoteData = {
	// Hit Time
	time:Float,
    // Hit Time Difference
    hDiff:Float,
    // Receptor ID
    receptor:Int,
    // Field ID
    field:Int,
	// If it is an arrow of receptor,
	arrow:Bool
}
typedef Visuals = {
	scaleX:Float,
	scaleY:Float,
	alpha:Float,
	angle:Float,
	zoom:Float,
	glow:Float,
	glowR:Float,
	glowG:Float,
	glowB:Float
}