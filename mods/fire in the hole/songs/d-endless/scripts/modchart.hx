import modchart.Manager;
import modchart.core.util.ModchartUtil;
import modchart.core.ModifierGroup;
import modchart.modifiers.Drunk;
import openfl.geom.Vector3D;

var newModchartAdditions = false;

function postCreate()
{
	modchart = new Manager(PlayState.instance);
	add(modchart);

	youneverstoleacat();
}
function youneverstoleacat()
{
    var kicks = [];
    var snares = [];

	// REVERSE ALWAYS ON THE TOP KIDS !!
	// seriusly, especially with mods that modify the y pos (they wont work!!!)
	modchart.addModifier('reverse');
	modchart.addModifier('invert');
	modchart.addModifier('transform');
	modchart.addModifier('drunk');
	modchart.addModifier('tipsy');
	modchart.addModifier('beat');
	modchart.addModifier('opponentSwap');

	// ROTATE ALWAYS ON THE BOTTOM KIDS !!
	// i recomend this but this but is not thaat necesary
	modchart.addModifier('rotate');
	modchart.addModifier('fieldRotate');

	modchart.addModifier('scale');
	modchart.addModifier('alpha');

	modchart.setPercent('alpha', 0);
	kicks = [
        16,
        80,
        90,
        96,
        106,
        112,
        120,
        128,
        132,
        136,
        140,
        140.5,
        141,
        141.5,
        142,
        142.5,
        143,
        143.5,
    ];

	var m = 1;

	modchart.set('opponentSwap', 0, 0.5);

	modchart.set('alpha', 4, 0.75, 0);
	modchart.set('alpha', 4, 1, 1);

	modchart.set('scaleX', 80 / 4, 1.6);
	modchart.ease('scaleX', 80 / 4, 1, 1, FlxEase.cubeOut);
	modchart.ease('opponentSwap', 80 / 4, 1, 0, FlxEase.quadOut);
	modchart.ease('alpha', 80 / 4, 1, 1, FlxEase.cubeOut, 0);

	for(i in 0...kicks.length)
	{
        m *= -1;
        var step = kicks[i];
        var beat = kicks[i] / 4;

        if(step >= 140){
            var wow = i % 2;
            if (wow==0) {
				modchart.ease('invert', beat, 0.125, 1, FlxEase.quadOut);
            }else if(wow == 1){
				modchart.ease('invert', beat, 0.125, 0, FlxEase.quadOut);
            }
		}
		else
		{
			modchart.set('x', beat, 50 * m);
			modchart.ease('x', beat, 2, 0, FlxEase.quartOut);
			modchart.set('tipsy', beat, m);
			modchart.ease('tipsy', beat, 2, 0, FlxEase.cubeOut);

			if (newModchartAdditions)
			{
				var scaleAxis = m == -1 ? 'scaleX' : 'scaleY';
				modchart.set(scaleAxis, beat, 0.5);
				modchart.ease(scaleAxis, beat, 2, 0, FlxEase.quartOut);
			}
		}
    }
	modchart.set('beat', 144 / 4, 0.75);
	modchart.ease('flip', 144 / 4, 0.5, 'flip', 0, FlxEase.quadOut);
	modchart.ease('invert', 144 / 4, 0.5, 'invert', 0, FlxEase.quadOut);

	kicks = [];
    snares = [];

	numericForInterval(144, 392, 8, function(i){
        kicks.push(i);
    });
    numericForInterval(408, 904, 8, function(i){
        kicks.push(i);
    });
	numericForInterval(144+4, 904+4, 8, function(i){
        snares.push(i);
    });
	for (i in 0...kicks.length)
	{
        var step = kicks[i] / 4;
		var dur = 1; // 4 / 4

		modchart.set('tipsy', step, 1.25);
		modchart.set('tipsyOffset', step, .25);
		modchart.set('x', step, -75);
		modchart.set('tiny', step, 0.25);

		modchart.ease('x', step, dur, 0, FlxEase.cubeOut);
		modchart.ease('tipsy', step, dur, 0, FlxEase.cubeOut);
		modchart.ease('tipsyOffset', step, dur, 0, FlxEase.cubeOut);
		modchart.ease('tiny', step, dur, 0, FlxEase.quadOut);
    }
	for (i in 0...snares.length)
	{
        var step = snares[i] / 4;
		var dur = 1; // 4 / 4
		modchart.set('x', step, -150);
		modchart.set('tiny', step, -0.25);
		
		modchart.ease('x', step, dur, 0, FlxEase.cubeOut);
		modchart.ease('tiny', step, dur, 0, FlxEase.quadOut);
    }

	modchart.ease('alpha', 264 / 4, 1, 0.25, FlxEase.cubeOut, 0);

	queueFunc(272, 400, function(event, cDS:Float){
        var pos = pos = (cDS - 272) / 4 + 1.5;

        for(pnT in 1...3){
            for(col in 0...4){
				var pn = pnT == 1 ? 2 : 1;
				
                var cPos = col * -112;
                if (pn == 2) cPos = cPos - 640;
                var c = (pn - 1) * 4 + col;
                var mn = pn == 2?0:1;
                var cSpacing = 112;

                var newPos = (((col * cSpacing + (pn - 1) * 640 + pos * cSpacing) % (1280))) - 176;
                modchart.setPercent("x" + col, cPos + newPos, 1 - mn);
            }
        }
    });

	for(i in 0...4)
        modchart.ease('x' + i, 400 / 4, 1, 0, FlxEase.quadOut);

	modchart.set('alpha', 404 / 4, 1, 0);

	// PENDING MODIFIERS, DO NOT FORGET IT THEO !!1!
	modchart.ease('opponentSwap', 400 / 4, 0.5, 0.5, FlxEase.quadOut, 1);
	modchart.ease('opponentSwap', 400 / 4, 0.5, -1.25, FlxEase.quadOut, 0);

	// elastic 1
	modchart.ease("reverse", 424 / 4, 1, -0.5, FlxEase.quartIn, 1);
	modchart.ease("reverse", 428 / 4, 2 / 4, 5, FlxEase.quadIn, 1);
	modchart.set("reverse", 430 / 4, -2.5, 1);
	modchart.ease("reverse", 430 / 4, 2 / 4, 0, FlxEase.backOut, 1);

	// elastic 2
	modchart.ease("rotateY", 456 / 4, 1, 85, FlxEase.quadIn, 1);
	modchart.ease("rotateY", 460 / 4, 10 / 4, -360 *3, FlxEase.elasticOut, 1);
	modchart.set("rotateY", 470 / 4, 0, 1);

    // elastic 3
	modchart.ease("rotateX", 488 / 4, (492 - 488) / 4, -25, FlxEase.quadIn, 1);
	modchart.ease("rotateX", 492 / 4, 8 / 4, 180, FlxEase.elasticOut, 1);
	modchart.set("rotateX", 500 / 4, 0, 1);
	// modchart.set("reverse", 500 / 4, 1, 1);

	// elastic 4
	modchart.ease("flip", 520 / 4, 1, 0.25, FlxEase.quadIn, 1);
	modchart.ease("opponentSwap", 520 / 4, 1, 1, FlxEase.quadIn, 1);
	modchart.ease("opponentSwap", 524 / 4, (532 - 524) / 4, -1.25, FlxEase.elasticOut, 1);

	modchart.ease("flip", 524 / 4, 2, 0, FlxEase.elasticOut, 1);
	// PENDING HERE
	modchart.ease("opponentSwap", 524 / 4, 0.5, 0.5, FlxEase.quadOut, 0);
	modchart.set("reverse", 528 / 4, 1, 1);
}
function queueFunc(step, end, func)
{
	queuedFuncs.push({
		step: step,
		end: end,
		callback: func
	});
}
var queuedFuncs = [];
function update()
{
	for (obj in queuedFuncs)
	{
		if (curStepFloat >= obj.step && curStepFloat < obj.end)
		{
			obj.callback(null, curStepFloat);
		} else if (curStepFloat > obj.end) {
			queuedFuncs.remove(obj);
		}
	}
}
function numericForInterval(start, end, interval, func){
    var index = start;
    while(index < end){
        func(index);
        index += interval;
    }
}