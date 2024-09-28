package modchart.modifiers;

import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import modchart.core.util.ModchartUtil;
import openfl.geom.Vector3D;
import flixel.math.FlxMath;

/**
 * Stolen from schmovin
 */
class PathSegment extends Vector3D
{
	public var startDist = 0.0;
	public var endDist = 0.0;
	public var next:PathSegment;
}

class PathModifier extends Modifier
{
	var _path:List<PathSegment>;
	var _pathDistance:Float = 0;

	public var pathName:String = '';
	public var pathScale:Int = 1;
	public var pathBegin:Float = 1500;
	
	public function new(name:String, path:Array<Vector3D>)
	{
		super(0);

		this.pathName = name;

		// loading the path
		for (curSeg in path)
		{
			var segment = cast curSeg.clone();
			segment.scaleBy(pathScale);
			_path.add(segment);
		}
		
		// calculating the path distances
		var iterator = _path.iterator();
		var last = iterator.next();
		last.startDist = 0;
		var dist = 0.0;
		while (iterator.hasNext())
		{
			var current = iterator.next();
			var differential = current.subtract(last);
			dist += differential.length;
			current.startDist = dist;
			last.next = current;
			last.endDist = current.startDist;
			last = current;
		}
		_pathDistance = dist;
	}
	
	public function getPosAlongDistance(distance:Float):Null<Vector3D>
	{
		for (vec in _path)
		{
			if (FlxMath.inBounds(distance, vec.startDist, vec.endDist) && vec.next != null)
			{
				var ratio = (distance - vec.startDist) / vec.next.subtract(vec).length;
				return ModchartUtil.lerpVector3D(vec, vec.next, ratio);
			}
		}
		return _path.first();
	}

	override public function render(pos:Vector3D, params:RenderParams)
	{
		return ModchartUtil.lerpVector3D(
			pos,
			getPosAlongDistance(params.hDiff / -pathBegin * _pathDistance),
			getPercent(pathName)
		);
	}

	override public function shouldRun():Bool
		return getPercent(pathName) != 0;
}