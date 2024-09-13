package modchart.events.types;

import modchart.events.Event;

class SetEvent extends Event
{
    public var target:Float;
    public var mod:String;
	public var field:Int;

    public function new(mod:String, beat:Float, target:Float, field:Int = -1)
    {
        this.mod = mod.toLowerCase();
        this.target = target;
		this.field = field;

        super(beat, () -> setModPercent(mod, target, field));
    }
	override public function getPriority()
		return 1;
}