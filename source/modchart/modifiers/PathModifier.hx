package modchart.modifiers;

import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import modchart.core.util.ModchartUtil;
import openfl.geom.Vector3D;
import flixel.math.FlxMath;

typedef PathInfo = {
	var position:Vector3D;
	var dist:Float;
	var start:Float;
	var end:Float;
}
  
// stolen from troll engine
class PathModifier extends Modifier
{
	var moveSpeed:Float;
	var pathData:Array<Array<PathInfo>> = [];
	var totalDists:Array<Float> = [];
	
	public function getMoveSpeed() return 5000;
	public function getPathName() return '';
	
	public function getPath():Array<Array<Vector3D>>
		return [];

	public function new()
	{
		super(0);

		moveSpeed = getMoveSpeed();
		var path:Array<Array<Vector3D>> = getPath();
		var dir:Int = 0;
	
		while(dir < path.length)
		{
			var idx = 0;
			totalDists[dir] = 0;
			pathData[dir] = [];

		  	while(idx < path[dir].length)
			{
				var pos = path[dir][idx];
	
				if(idx!=0)
				{
			  		var last = pathData[dir][idx-1];
			  		totalDists[dir] += Math.abs(Vector3D.distance(last.position, pos));
			 		var totalDist = totalDists[dir];
			 		last.end = totalDist;
			  		last.dist = last.start - totalDist;
				}
	
				pathData[dir].push({
					position: pos.add(new Vector3D(-ARROW_SIZEDIV2, -ARROW_SIZEDIV2)),
					start: totalDists[dir],
					end: 0,
					dist: 0
				});
				idx++;
		  	}
		  	dir++;
		}
	}

	override public function render(pos:Vector3D, params:RenderParams)
	{
		var vDiff = -params.hDiff;
		var data = params.receptor;

		var progress  = (vDiff / -moveSpeed) * totalDists[data];
		var outPos = pos.clone();
		var daPath = pathData[data];

		// normally i dont use the field params cuz `Modifier` has a field property
		// and its set on the modifiergroup
		// but here does not work and im lazy for debugging
		var modPerc = getPercent(getPathName(), params.field);

		var outPos = pos;

		if (progress <= 0)
		{
			// for receptors
			outPos = ModchartUtil.lerpVector3D(outPos, daPath[0].position.add(ModchartUtil.getHalfPos()), modPerc);
		}
		else
		{
			// for regular arrows (holds too)
			var idx:Int = 0;
	
			while(idx<daPath.length)
			{
				var cData = daPath[idx];
				var nData = daPath[idx+1];
				  if(nData != null && cData != null){
					if(progress > cData.start && progress < cData.end){
						  var alpha = (cData.start - progress) / cData.dist;
						  var interpPos:Vector3D = ModchartUtil.lerpVector3D(cData.position, nData.position, alpha);
						  outPos = ModchartUtil.lerpVector3D(pos, interpPos.add(ModchartUtil.getHalfPos()), modPerc);
					}
				  }
				  idx++;
			}
		}

		return outPos;
	}

	override public function shouldRun():Bool
		return getPercent(getPathName()) != 0;
}