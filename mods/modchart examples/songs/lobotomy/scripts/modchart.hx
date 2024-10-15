import modchart.Manager;
import modchart.core.util.ModchartUtil;
import modchart.core.ScriptedModifier;
import modchart.modifiers.SawTooth;
import modchart.core.ModifierGroup;
import openfl.geom.Vector3D;
import openfl.Vector;
import funkin.game.Note;

var modchart:Manager;
var pattern = [0, 1, 1.5];
var pattern2 = [0, 1, 1.5, 2.33333, 3.33333];

var m = 1;
function postCreate()
{
	modchart = new Manager(PlayState.instance);
	modchart.HOLD_SUBDIVITIONS = 5;
	add(modchart);

	player.cpu = true;

	scriptedModTest2();
}
function scriptedModTest2()
{
	var crochetRatio = 1 / Conductor.crochet;
	var rotateSine = new ScriptedModifier();
	rotateSine._render = (pos, params) -> {
		if (params.receptor == 0 || params.receptor == 3)
			return pos;

		var ang = (((params.hDiff) * crochetRatio)) * 250;

		var origin = new Vector3D(50 + 112 / 2 + FlxG.width / 2 * params.field + 2 * 112, FlxG.height * 0.5);
		var diff = pos.subtract(origin);
		var out = ModchartUtil.rotate3DVector(diff, 0, ang, 0);
		pos.copyFrom(origin.add(out));
		return pos;
	};

	modchart.modifiers.modifiers.set('rotatesine', rotateSine);
	modchart.modifiers.sortedMods.push('rotatesine');

	modchart.addModifier('transform');
	modchart.setPercent('z', -500);
}
function scriptedModTest1()
{
	var crochetRatio = 1 / Conductor.crochet;

	var circlePath = new ScriptedModifier();
	circlePath._render = (pos, params) -> {
		var perc = modchart.getPercent('circlepath', params.field);

		if (perc == 0)
			return pos;

		var time = ((params.sPos + params.hDiff) * crochetRatio) * .5;
		var sin = FlxMath.fastSin(time * Math.PI);
		var cos = FlxMath.fastCos(time * Math.PI);
		var ratioX = 420;
		var ratioY = 280;

		pos.x = FlxMath.lerp(pos.x, FlxG.width * .5 + cos * ratioX, perc);
		pos.y = FlxMath.lerp(pos.y, FlxG.height * .5 + sin * ratioY, perc);

		return pos;
	};

	modchart.modifiers.modifiers.set('circlepath', circlePath);
	modchart.modifiers.sortedMods.push('circlepath');

	modchart.addModifier('centerRotate');
	modchart.ease('circlepath', 0, 8, 1);
	modchart.ease('centerRotateX', 0, 128 * 3, 360 * 16);
	modchart.ease('centerRotateY', 0, 128 * 3, 380 * 16);
	modchart.ease('centerRotatez', 0, 128 * 3, 400 * 16);
}
function testModchart()
{
	modchart.addModifier('transform');
	modchart.addModifier('drunk');
	modchart.addModifier('tipsy');
	modchart.addModifier('beat');
	modchart.addModifier('tornado');
	modchart.addModifier('accelerate');
	modchart.addModifier('opponentSwap');
	modchart.addModifier('rotate');

	var newPatt = [];

	for (i in 0...16)
	{
		if (i >= 8) {
			for (b in pattern2)
				newPatt.push(b + i * 4);
			continue;
		}
		for (b in pattern)
			newPatt.push(b + i * 4);
	}

	for (b in newPatt)
	{
		final e = FlxEase.cubeOut;

		modchart.set('x', b, m * 40);
		modchart.ease('x', b, 2, 0, e);
		
		modchart.set('tipsy', b, m);
		modchart.ease('tipsy', b, 2, 0, e);

		m *= -1;
	}

	modchart.ease('rotateY', 16 - 2, 3, 360 * 2, FlxEase.cubeOut);
	modchart.set('rotateY', 18, 0);

	modchart.ease('drunk', 32 - 8, 8, 0.8, FlxEase.cubeOut);
	modchart.set('beat', 32, 1);

	for (b in 64...64 + 36)
	{
		final e = FlxEase.cubeOut;

		modchart.set('x', b, m * 50);
		modchart.ease('x', b, 2, 0, e);
		
		modchart.set('tipsy', b, m);
		modchart.ease('tipsy', b, 2, 0, e);

		m *= -1;
	}
	modchart.ease('rotateY', 60, 2.5, 360, FlxEase.quartOut);

	modchart.ease('opponentSwap', 62, 1, 1, FlxEase.quartOut);
	modchart.ease('opponentSwap', 64, 8, 0, FlxEase.cubeOut);

	// modchart.ease('accelerate', 64 - 8, 8, 0.5, FlxEase.cubeOut);
	modchart.ease('tornado', 64 - 8 + 8, 8 + 8, 0.25, FlxEase.cubeOut);
}
function onStrumCreation(ev)
{
	ev.strum.extra.set('lane', ev.strumID);
	ev.strum.extra.set('field', ev.player);
}