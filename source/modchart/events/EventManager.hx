package modchart.events;

import modchart.events.types.*;

class EventManager
{
	var table:Map<String, Array<Array<Event>>> = [];

    public function new() {};

    public function add(event:Event)
    {
		if (table[event.name] == null)
			table[event.name] = [[], []];

		table[event.name][event.field].push(event);

		sortEvents();
    }
    public function update(curBeat:Float)
    {
		for (mod => fieldEvents in table)
		{
			for (events in fieldEvents)
			{
				for (ev in events)
				{
					ev.active = false;

					if (ev.beat >= curBeat)
						continue;
					else
						ev.active = true;

					ev.update(curBeat);
	
					if (ev.fired)
						events.remove(ev);
				}
			}
		}
    }
	public function getLastEvent<T>(name:String, field:Int, evClass:T)
	{
		var list = table[name][field];
		var idx = list.length;

		while (idx >= 0)
		{
			final ev = list[idx];
			
			if (Std.isOfType(ev, evClass) && ev.field == field && ev.active)
				return ev;

			idx--;
		}

		return null;
	}
    private function sortEvents()
    {
		for (mod => modTab in table)
		{
			for (events in modTab)
			{
				events.sort((a, b) -> {
					if (a.beat < b.beat)
						return -1;
					else if (a.beat > b.beat)
						return 1;
					return 0;
				});
			}
		}
    }
}