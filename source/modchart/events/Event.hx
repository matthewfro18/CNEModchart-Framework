package modchart.events;

import modchart.Manager;

class Event
{
    /**
     * The beat where the event will be executed
     */
    public var beat:Float;
    public var callback:Void->Void;

    public var fired:Bool = false;

    public function new(beat:Float, callback:Void->Void)
    {
        this.beat = beat;
        this.callback = callback;
    }
    public function update(curBeat:Float)
    {
        if (curBeat >= beat) {
            callback();

            fired = true;
        }
    }
	public function create() {}
	public function getPriority() return 0;
    public function setModPercent(name, value, field)
    {
        Manager.instance.setPercent(name.toLowerCase(), value, field);
    }
	public function getModPercent(name, field):Float
	{
		return Manager?.instance?.modifiers?.getPercent(name, field) ?? 0;
	}
}