import modchart.Manager;
import modchart.core.util.ModchartUtil;
import openfl.geom.Vector3D;
import funkin.game.Note;

var modchart:Manager;
var pattern = [0, 1, 1.5];
var pattern2 = [0, 1, 1.5, 2.33333, 3.33333];

var m = 1;
function postCreate()
{
	Note.HOLD_SUBDIVS = 4;
	modchart = new Manager(PlayState.instance);
	modchart.cameras = [camHUD];
	add(modchart);

	modchart.addSubmod('scrollAngleX');
	modchart.addSubmod('scrollAngleY');
	modchart.addSubmod('scrollAngleZ');
	modchart.addModifier('square', 1);

	testModchart();
	
}
function testModchart()
{
	modchart.addModifier('transform', 1);
	modchart.addSubmod('x');
	modchart.addSubmod('z');
	modchart.addModifier('tipsy');
	modchart.addModifier('drunk');
	modchart.addModifier('beat');
	modchart.addModifier('tornado');
	modchart.addModifier('accelerate');
	modchart.addModifier('opponentSwap');
	modchart.addModifier('rotate', 1);
	modchart.addSubmod('rotateY');
	modchart.addSubmod('rotateZ');

	modchart.addSubmod('scrollAngleX');
	modchart.addSubmod('scrollAngleY');
	modchart.addSubmod('scrollAngleZ');

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

		modchart.set('x', b, m * 50, 0);
		modchart.ease('x', b, 2, 0, e);
		
		modchart.set('tipsy', b, m);
		modchart.ease('tipsy', b, 2, 0, e);

		m *= -1;
	}

	modchart.ease('rotateY', 16 - 2, 3, 360 * 2, FlxEase.cubeOut);
	modchart.set('rotateY', 18, 0);

	modchart.ease('drunk', 32 - 8, 8, 1, FlxEase.cubeOut);
	modchart.set('beat', 32, 1);

	for (b in 64...64 + 36)
	{
		final e = FlxEase.cubeOut;

		modchart.set('x', b, m * 50, 0);
		modchart.ease('x', b, 2, 0, e);
		
		modchart.set('tipsy', b, m);
		modchart.ease('tipsy', b, 2, 0, e);

		m *= -1;
	}
	modchart.ease('rotateY', 60, 2.5, 360, FlxEase.quartOut);

	modchart.ease('opponentSwap', 62, 1, 1, FlxEase.quartOut);
	modchart.ease('opponentSwap', 64, 8, 0, FlxEase.cubeOut);

	modchart.ease('accelerate', 64 - 8, 8, 0.5, FlxEase.cubeOut);
	modchart.ease('tornado', 64 - 8 + 8, 8 + 8, 0.25, FlxEase.cubeOut);
}
function onStrumCreation(ev)
{
	ev.strum.extra.set('lane', ev.strumID);
	ev.strum.extra.set('field', ev.player);
}