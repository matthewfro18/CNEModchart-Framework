package modchart.core;

import openfl.geom.Vector3D;
import funkin.backend.system.Logs;
import modchart.Modifier;
import modchart.core.util.Constants.Visuals;
import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import modchart.modifiers.*;
import funkin.backend.system.Conductor;
import modchart.core.util.ModchartUtil;

class ModifierGroup
{
	public static var GLOBAL_MODIFIERS:Map<String, Class<Modifier>> = [
		'reverse' => Reverse,
        'transform' => Transform,
		'opponentswap' => OpponentSwap,
        'drunk' => Drunk,
        'bumpy' => Bumpy,
        'tipsy' => Tipsy,
        'tornado' => Tornado,
        'invert' => Invert,
        'square' => Square,
        'zigzag' => ZigZag,
        'beat' => Beat,
		'accelerate' => Accelerate,
        'receptorscroll' => ReceptorScroll,
		'sawtooth' => SawTooth,
		'braidy' => Braidy,
		'mini' => Mini,
        'rotate' => Rotate,
        'fieldrotate' => FieldRotate,
        'centerrotate' => CenterRotate,
		'confusion' => Confusion,
		'stealth' => Stealth,
		'scale' => Scale,
		// YOU NEVER STOOD A CHANCE
		'infinite' => Infinite
    ];
	private var MODIFIER_REGISTRERY:Map<String, Class<Modifier>> = GLOBAL_MODIFIERS;

	public var percents:Map<String, Map<Int, Float>> = [];
    public var modifiers:Map<String, Modifier> = [];

	// apparently the maps dont care in what order you declare the values, they order them as they want
	// i hate maps
	public var sortedMods:Array<String> = [];

	public function new() {}

	// just render mods with the perspective stuff included
	public function getPath(pos:Vector3D, data:NoteData):Vector3D
	{
		pos = renderMods(pos, data);
		pos.z *= 0.001;
		return ModchartUtil.perspective(pos);
	}
	public function getVisuals(data:NoteData):Visuals
	{
		var visuals = {
			scaleX: 1.,
			scaleY: 1.,
			angle: 0.,
			alpha: 1.,
			zoom: 1.
		};

		for (name in sortedMods)
		{
			var mod = modifiers.get(name);

			if (!mod.shouldRun())
				continue;

			var args = {
				// fuck u haxe
                perc: 0.0,
                sPos: Conductor.songPosition,
                fBeat: Conductor.curBeatFloat,
                hDiff: data.hDiff,
                receptor: data.receptor,
                field: data.field,
				arrow: data.arrow
            }

			mod.field = data.field;
			visuals = mod.visuals(visuals, args);
		}

		return visuals;
	}
	public function renderMods(pos:Vector3D, data:NoteData):Vector3D
    {
		// add the scroll
		var scroll = new Vector3D(0, data.hDiff * 0.45 * ModchartUtil.getScrollSpeed());
		scroll = ModchartUtil.rotate3DVector(
			scroll,
			getPercent('scrollAngleX', data.field),
			getPercent('scrollAngleY', data.field),
			getPercent('scrollAngleZ', data.field)
		);
		pos.add(scroll);
		
		for (name in sortedMods)
		{
			var mod = modifiers.get(name);

			if (!mod.shouldRun())
				continue;

			var args = {
				// fuck u haxe
                perc: 0.0,
                sPos: Conductor.songPosition,
                fBeat: Conductor.curBeatFloat,
                hDiff: data.hDiff,
                receptor: data.receptor,
                field: data.field,
				arrow: data.arrow
            }

			mod.field = data.field;
			pos = mod.render(pos, args);
		}

        return pos;
    }
	public function registerModifier(name:String, modifier:Class<Modifier>)
	{
		if (MODIFIER_REGISTRERY.get(name.toLowerCase()) != null)
		{
			Logs.trace('There\'s already a modifier with name "$name" registered !');
			return;
		}
		MODIFIER_REGISTRERY.set(name.toLowerCase(), modifier);
	}
	public function addModifier(name:String)
	{
		var modifierClass:Null<Class<Modifier>> = MODIFIER_REGISTRERY.get(name.toLowerCase());
		if (modifierClass == null) {
			Logs.trace('$name modifier was not found !', WARNING);

			return;
		}

		var newModifier = Type.createInstance(modifierClass, []);
		modifiers.set(name.toLowerCase(), newModifier);
		sortedMods.push(name.toLowerCase());
	}

	public function setPercent(name:String, value:Float, field:Int = -1)
	{
		final percs = percents.get(name.toLowerCase()) ?? [0 => 0, 1 => 0];

		if (field == -1)
			for (k => _ in percs) percs.set(k, value);
		else
			percs.set(field, value);

		percents.set(name.toLowerCase(), percs);
	}
	public function getPercent(name:String, field:Int):Float
		return percents.get(name.toLowerCase())?.get(field) ?? 0;
}