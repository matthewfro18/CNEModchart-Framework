package modchart.events.types;

import flixel.math.FlxMath;
import flixel.tweens.FlxEase.EaseFunction;
import modchart.events.Event;

typedef EaseData = {
    var startValue:Float;
    var targetValue:Float;

    var startBeat:Float;
    var endBeat:Float;
    
    var beatLength:Float;

    var ease:EaseFunction;
}
class EaseEvent extends Event
{
    public var mod:String;
    public var data:EaseData;

    public var field:Int;
	public var active:Bool = false;

    public function new(mod:String, beat:Float, len:Float, prev:Float, target:Float, ease:EaseFunction, field:Int = -1)
    {
        this.mod = mod.toLowerCase();
        this.field = field;

        this.data = {
            startValue: prev,
            targetValue: target,
            startBeat: beat,
            endBeat: beat + len,
            beatLength: len,
            ease: ease
        };

        super(beat, () -> {});
    }
	override function create()
	{
		// data.startValue = getModPercent(mod, field);
	}
	public function setStartValue(f)
	{
		data.startValue = f;
	}
    override function update(curBeat:Float)
    {
		if (curBeat > data.startBeat && curBeat < data.endBeat)
		{
            // this is easier than u think
			var progress = (curBeat - data.startBeat) / (data.endBeat - data.startBeat);
            var out = FlxMath.lerp(data.startValue, data.targetValue, data.ease(progress));
			setModPercent(mod, out, field);
			active = true;
			fired = false;
		}
		else if (curBeat >= data.endBeat)
		{
			fired = true;
			active = false;
			
			setModPercent(mod, data.targetValue, field);
		}
    }
	override public function getPriority()
		return -1;
}