package modchart.core;

import openfl.geom.Vector3D;
import modchart.Modifier;
import modchart.core.util.Constants.Visuals;
import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import modchart.modifiers.*;
import modchart.modifiers.false_paradise.*;
import modchart.core.util.ModchartUtil;

import haxe.ds.StringMap;
import haxe.ds.IntMap;
import haxe.ds.Vector;

import funkin.backend.system.Conductor;
import funkin.backend.system.Logs;

// @:build(modchart.core.macros.Macro.buildModifiers())
@:allow(modchart.Modifier)
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
		'mini' => Mini,
        'rotate' => Rotate,
        'fieldrotate' => FieldRotate,
        'centerrotate' => CenterRotate,
		'confusion' => Confusion,
		'stealth' => Stealth,
		'scale' => Scale,
		// YOU NEVER STOOD A CHANCE
		'infinite' => Infinite,
        'schmovindrunk' => SchmovinDrunk,
        'schmovintipsy' => SchmovinTipsy,
        'wiggle' => Wiggle,
        'arrowshape' => ArrowShape,
        'eyeshape' => EyeShape,
        'spiral' => Spiral,
        'counterclockwise' => CounterClockWise,
        'vibrate' => Vibrate,
        'bounce' => Bounce,
        'radionic' => Radionic,
        'arrowpath' => ArrowPath
    ];
	private var MODIFIER_REGISTRERY:Map<String, Class<Modifier>> = GLOBAL_MODIFIERS;

	private var percents:StringMap<IntMap<Float>> = new StringMap();
    private var modifiers:StringMap<Modifier> = new StringMap();

	private var sortedMods:Array<String> = [];

	public function new() {}

	// just render mods with the perspective stuff included
	public function getPath(pos:Vector3D, data:NoteData, ?posDiff:Float = 0):Vector3D
	{
		pos = renderMods(pos, data, posDiff);
		// should i made a z scale mod ?
		pos.z *= 0.001;
		return ModchartUtil.perspective(pos);
	}
	public function getVisuals(data:NoteData):Visuals
	{
		var visuals:Visuals = {
			scaleX: 1.,
			scaleY: 1.,
			angle: 0.,
			alpha: 1.,
			zoom: 1.,
			glow: 0.,
			glowR: 0.,
			glowG: 0.,
			glowB: 0.
		};

		for (i in 0...sortedMods.length)
		{
			final mod = modifiers.get(sortedMods[i]);
			mod.field = data.field;

			final args:RenderParams = {
				// fuck u haxe
                perc: 0.0,
                sPos: Conductor.songPosition,
                fBeat: Conductor.curBeatFloat,
				time: data.time,
                hDiff: data.hDiff,
                receptor: data.receptor,
                field: data.field,
				arrow: data.arrow
            }
			if (!mod.shouldRun(args))
				continue;

			visuals = mod.visuals(visuals, args);
		}

		return visuals;
	}
	public function renderMods(pos:Vector3D, data:NoteData, ?posDiff:Float = 0):Vector3D
    {
		final iterator = sortedMods.iterator();

		for (i in 0...sortedMods.length)
		{
			final mod = modifiers.get(sortedMods[i]);
			mod.field = data.field;

			final args:RenderParams = {
				// fuck u haxe
                perc: 0.0,
                sPos: Conductor.songPosition,
                fBeat: Conductor.curBeatFloat,
				time: data.time + posDiff,
                hDiff: data.hDiff + posDiff,
                receptor: data.receptor,
                field: data.field,
				arrow: data.arrow
            }

			if (!mod.shouldRun(args))
				continue;

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
		final percs = percents.get(name.toLowerCase()) ?? getDefaultPerc();

		if (field == -1)
			for (k => _ in percs) percs.set(k, value);
		else
			percs.set(field, value);

		percents.set(name.toLowerCase(), percs);
	}
	public function getPercent(name:String, field:Int):Float
		return percents.get(name.toLowerCase())?.get(field) ?? 0;

	private function getDefaultPerc():IntMap<Float>
	{
		final percmap = new IntMap<Float>();
		percmap.set(0, 0.);
		percmap.set(1, 0.);
		return percmap;
	}
}