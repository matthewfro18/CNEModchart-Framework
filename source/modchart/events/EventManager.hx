package modchart.events;

import modchart.events.types.*;

class EventManager
{
    var sets:Array<SetEvent> = [];
    var eases:Array<EaseEvent> = [];
	var dynamics:Array<Event> = [];

    public function new()
    {

    }

    public function add(event:Event)
    {
        if (event is SetEvent)
			sets.push(cast event);
		else if (event is EaseEvent)
			eases.push(cast event);
		else
			dynamics.push(cast event);
    }
    public function update(curBeat:Float)
    {
		var newVals:Map<String, Map<Int, Float>> = [];

		for (event in sets)
		{
			event.update(curBeat);

			if (event.fired)
			{
				if (newVals.get(event.mod) == null) newVals.set(event.mod, []);
				newVals.get(event.mod).set(event.field, event.target);

				sets.remove(event);
				event = null;
			}
		}
		
		for (event in eases)
		{
			var newVal = newVals.get(event.mod)?.get(event.field) ?? null;
			if (newVal != null) {
				event.setStartValue(newVal);
			}

			event.update(curBeat);

			// Si el evento ha terminado, lo removemos
			if (event.fired) {
				eases.remove(event);
			}
		}

		eases.sort((a, b) -> {
            if (a.beat < b.beat)
                return -1;
            else if (a.beat > b.beat)
                return 1;
            return 0;
        });
    }
    private function sortEvents(events)
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