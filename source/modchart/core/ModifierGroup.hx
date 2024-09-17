package modchart.core;

import openfl.geom.Vector3D;
import funkin.backend.system.Logs;
import modchart.Modifier;
import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import modchart.modifiers.*;
import funkin.backend.system.Conductor;

class ModifierGroup
{
	public static var GLOBAL_MODIFIERS:Map<String, Class<Modifier>> = [
		'reverse' => Reverse,
        'drunk' => Drunk,
        'tipsy' => Tipsy,
        'tornado' => Tornado,
        'invert' => Invert,
        'square' => Square,
        'zigzag' => ZigZag,
        'beat' => Beat,
		'accelerate' => Accelerate,
		'opponentswap' => OpponentSwap,
        'transform' => Transform,
        'fieldrotate' => FieldRotate,
        'rotate' => Rotate,
        'receptorscroll' => ReceptorScroll,
		'sawtooth' => SawTooth,
		'braidy' => Braidy
    ];
	private var MODIFIER_REGISTRERY:Map<String, Class<Modifier>> = GLOBAL_MODIFIERS;

	public var percents:Map<String, Map<Int, Float>> = [];
    public var modifiers:Map<String, Modifier> = [];

	public function new() {}

	public function renderMods(pos:Vector3D, data:NoteData):Vector3D
    {
        for (mod => percs in percents)
        {
            final perc = percs.get(data.field);

			if (perc == 0)
                continue;

            // Arrow Mod Updates
            renderMod(pos, mod, {
                perc: perc,
                sPos: Conductor.songPosition,
                fBeat: Conductor.curBeatFloat,
                hDiff: data.hDiff,
                receptor: data.receptor,
                field: data.field,
				arrow: data.arrow
            });
        }

        return pos;
    }
    public function renderMod(curPos:Vector3D, name:String, params:RenderParams)
    {
        var modifier = modifiers.get(name.toLowerCase());

		// Or is something weird... or is a subvalue
		if (modifier == null)
		{
			for (mod in modifiers)
			{
				final aliases = mod.getAliases();
				for (alias in aliases)
				{
					if (alias.toLowerCase() == name.toLowerCase())
					{
						//if (getPercent(alias, params.field) == 0)
							//return;
						modifier = mod;
						break;
					}
				}
			}
			return;
		}

        modifier.percent = params.perc;
        curPos = modifier.render(curPos, params);
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
	public function addModifier(name:String, defVal:Float = 0)
	{
		var modifierClass:Null<Class<Modifier>> = MODIFIER_REGISTRERY.get(name.toLowerCase());
		if (modifierClass == null) {
			Logs.trace('$name modifier was not found !', WARNING);

			return;
		}

		var newModifier = Type.createInstance(modifierClass, [0]);
		modifiers.set(name.toLowerCase(), newModifier);

		percents.set(name.toLowerCase(), [
			0=>defVal,
			1=>defVal
		]);
	}
	public function addSubmod(name:String, defVal:Float = 0)
	{
		percents.set(name.toLowerCase(), [
			0=>defVal,
			1=>defVal
		]);
	}

	public function setPercent(name:String, value:Float, field:Int = -1)
	{
		final percs = percents.get(name.toLowerCase());

		if (percs == null)
			return Logs.trace('$name modifier was not found !', WARNING);

		if (field == -1)
			for (k => v in percs) percs.set(k, value);
		else
			percs.set(field, value);
	}
	public function getPercent(name:String, field:Int):Float
	{
		final percs = percents.get(name.toLowerCase());

		if (percs == null) {
			Logs.trace('$name modifier was not found !', WARNING);
			return 0;
		}

		return percs.get(field);
	}
	
	public function getPercentsOf(name:String):Map<Int, Float>
	{
		final percs = percents.get(name.toLowerCase());

		if (percs == null) {
			Logs.trace('$name modifier was not found !', WARNING);
			return [0=>0, 1=>0];
		}

		return percs;
	}

	public function isModExisting(name:String)
	{
		return percents.get(name.toLowerCase()) != null;
	}
}