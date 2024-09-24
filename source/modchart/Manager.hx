package modchart;

import funkin.backend.system.Logs;
import funkin.game.Note;
import funkin.game.Strum;
import funkin.game.PlayState;
import funkin.backend.utils.CoolUtil;
import funkin.backend.system.Conductor;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxEase.EaseFunction;
import flixel.graphics.tile.FlxDrawTrianglesItem.DrawData;

import openfl.geom.Vector3D;

import modchart.modifiers.*;
import modchart.events.*;
import modchart.events.types.*;
import modchart.core.util.ModchartUtil;
import modchart.core.ModifierGroup;
import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;

// @:build(modchart.core.macros.Macro.buildModifiers())
class Manager extends FlxBasic
{
    public static var instance:Manager;

    public var game:PlayState;
    public var events:EventManager;

	public var modifiers:ModifierGroup;

    public function new(game:PlayState)
    {
        super();
        
        instance = this;

        this.game = game;
		this.cameras = [game.camHUD];
        this.events = new EventManager();
		this.modifiers = new ModifierGroup();

		addSubmod('scrollAngleX');
		addSubmod('scrollAngleY');
		addSubmod('scrollAngleZ');
    }

	public function registerModifier(name:String, mod:Class<Modifier>)   return modifiers.registerModifier(name, mod);
	public function addSubmod(name:String, defVal:Float = 0) 			 return modifiers.addSubmod(name, defVal);
    public function setPercent(name:String, value:Float, field:Int = -1) return modifiers.setPercent(name, value, field);
    public function getPercent(name:String, field:Int)    				 return modifiers.getPercent(name, field);
    public function addModifier(name:String, defVal:Float = 0)		 	 return modifiers.addModifier(name, defVal);

    public function set(name:String, beat:Float, value:Float, field:Int = -1):Void
    {
        final percs = modifiers.getPercentsOf(name);

        if (percs == null)
            return Logs.trace('$name modifier was not found !', WARNING);

		if (field == -1)
		{
			for (curField => _ in percs)
				set(name, beat, value, curField);
			return;
		}

        events.add(new SetEvent(name.toLowerCase(), beat, value, field));
    }
    public function ease(name:String, beat:Float, length:Float, value:Float = 1, easeFunc:EaseFunction, field:Int = -1):Void
    {
        final percs = modifiers.getPercentsOf(name);

		if (percs == null)
            return Logs.trace('$name modifier was not found !', WARNING);

		if (field == -1)
		{
			for (curField => _ in percs)
				ease(name, beat, length, value, easeFunc, curField);
			return;
		}

        events.add(new EaseEvent(name, beat, length, percs.get(field) ?? 0, value, easeFunc, field));
    }

    override function update(elapsed)
    {
        // Update Event Timeline
        events.update(Conductor.curBeatFloat);

        // Update Modifiers
        for (strumLine in game.strumLines)
        {
            strumLine.forEach(strum -> {
                updateReceptor(strum);
            });
            strumLine.notes.forEachAlive(note -> {
                updateArrow(note);
            });
        }
    }
    // Every 3 indices is a triangle
    public static final INDICES:Array<Int> = [
		0, 1, 2,
		1, 3, 2,
		2, 3, 4,
		3, 5, 4
    ];
	var _indices = new DrawData<Int>(INDICES.length, true, INDICES);
	var _uvtData = null;
	var _vertices = null;

	/**
	 * Returns the points along the hold path in a specific time
	 * @param basePos The hold position per default
	 */
	public function getHoldQuad(basePos:Vector3D, params:NoteData):Vector3D
	{
		var leftPoint:Vector3D = modifiers.getPath(basePos.clone(), params);
		var rightPoint:Vector3D = modifiers.getPath(basePos.clone().add(new Vector3D(HOLD_SIZE)), params);

		return rightPoint.subtract(leftPoint);
	}
	override function draw()
	{
        for (strumLine in game.strumLines)
		{
			strumLine.notes.visible = strumLine.visible = false;

			strumLine.forEach(receptor -> {
				@:privateAccess
				receptor.drawComplex(game.camHUD);
			});
			
			strumLine.notes.forEachAlive(arrow -> @:privateAccess {
				if (!arrow.isSustainNote)
					arrow.drawComplex(game.camHUD);
				else {
					// TODO: Properly downscroll support
					var basePos = new Vector3D(
						getReceptorX(arrow.strumID, arrow.strumLine.ID),
						getReceptorY(arrow.strumID, arrow.strumLine.ID)
					);
					if (ModchartUtil.getDownscroll())
					{
						basePos.y = FlxG.height - basePos.y - HOLD_SIZE;
					}

					var baseOffset = new Vector3D(ARROW_SIZEDIV2 - HOLD_SIZEDIV2, ARROW_SIZEDIV2);
					var thisPos = basePos.clone();
					var nextPos = basePos.clone();

					// this will be our "clip rect"
					var clipRatio = arrow.wasGoodHit ? (FlxMath.bound(
						(Conductor.songPosition - arrow.strumTime) / (ARROW_SIZE) *
						(0.45 * CoolUtil.quantize(arrow.strumLine.members[arrow.strumID].getScrollSpeed(arrow), 100)),
					0, 1)) : 0;
					
					var scrollOffset = getScrollPos(ModchartUtil.getArrowDistance(arrow, (ARROW_SIZE * clipRatio)), arrow);
					var nextScrollOffset = getScrollPos(ModchartUtil.getArrowDistance(arrow, Conductor.stepCrochet / Note.HOLD_SUBDIVS), arrow);
					thisPos.incrementBy(scrollOffset);
					nextPos.incrementBy(nextScrollOffset);
					
					// im not in "dry"
					thisPos = modifiers.getPath(thisPos, {
						hDiff: arrow.strumTime - Conductor.songPosition,
						receptor: arrow.strumID,
						field: arrow.strumLine.ID,
						arrow: true
					});

					var thisOffset = baseOffset.clone();
					thisOffset.scaleBy(1 / thisPos.z);
					thisPos.incrementBy(thisOffset);

					nextPos = modifiers.getPath(nextPos, {
						hDiff: (arrow.strumTime + Conductor.stepCrochet / Note.HOLD_SUBDIVS) - Conductor.songPosition,
						receptor: arrow.strumID,
						field: arrow.strumLine.ID,
						arrow: true
					});

					var nextOffset = baseOffset.clone();
					nextOffset.scaleBy(1 / nextPos.z);
					nextPos.incrementBy(nextOffset);

					var topPoints = getHoldQuad(basePos.clone().add(scrollOffset), {
						hDiff: arrow.strumTime - Conductor.songPosition,
						receptor: arrow.strumID,
						field: arrow.strumLine.ID,
						arrow: true
					});
					var bottomPoints = getHoldQuad(basePos.clone().add(nextScrollOffset), {
						hDiff: (arrow.strumTime + Conductor.stepCrochet / Note.HOLD_SUBDIVS) - Conductor.songPosition,
						receptor: arrow.strumID,
						field: arrow.strumLine.ID,
						arrow: true
					});

					_vertices = ModchartUtil.getHoldVertex(thisPos, nextPos, [topPoints, bottomPoints]);
					_uvtData = ModchartUtil.getHoldIndices(arrow);

					game.camHUD.drawTriangles(
						arrow.graphic,
						_vertices,
						_indices,
						_uvtData,
						null,
						null,
						null,
						false,
						arrow.antialiasing,
						arrow.colorTransform
					);
				}
			});
		}
	}
    public function updateReceptor(receptor:Strum)
    {
        final lane = receptor.extra.get('lane') ?? 0;
        final field = receptor.extra.get('field') ?? 0;

		receptor.scale.set(0.7, 0.7);
        receptor.setPosition(getReceptorX(lane, field), getReceptorY(lane, field));
        receptorPos.setTo(receptor.x, receptor.y, 0);
        receptorPos = modifiers.getPath(receptorPos, {
            hDiff: 0,
            receptor: lane,
            field: field,
			arrow: false
        });

        receptor.setPosition(receptorPos.x, receptorPos.y);
    }
	var smoothSustains:Bool = false;

    public function updateArrow(arrow:Note)
    {		
		if (arrow.isSustainNote) return;

		var scrollAddition = getScrollPos(ModchartUtil.getArrowDistance(arrow, 0, false), arrow);

        final diff = arrow.strumTime - Conductor.songPosition;
		arrow.scale.set(0.7, 0.7);
        arrow.x = getReceptorX(arrow.strumID, arrow.strumLine.ID);
        arrow.y = getReceptorY(arrow.strumID, arrow.strumLine.ID);
        arrow.angle = 0;
        arrow.strumRelativePos = false;
        arrowPos.setTo(arrow.x, arrow.y, 0);
		arrowPos.incrementBy(scrollAddition);

        arrowPos = modifiers.getPath(arrowPos, {
            hDiff: diff,
            receptor: arrow.strumID,
            field: arrow.strumLine.ID,
			arrow: true
        });

        arrow.setPosition(arrowPos.x, arrowPos.y);
    }

	public function getScrollPos(distance:Float, arrow:Note)
	{
		var scrollPos = new Vector3D(0, distance);
		var angleX = modifiers.getPercent('scrollAngleX', arrow.strumLine.ID);
		var angleY = modifiers.getPercent('scrollAngleY', arrow.strumLine.ID);
		var angleZ = modifiers.getPercent('scrollAngleZ', arrow.strumLine.ID);

		return ModchartUtil.rotate3DVector(scrollPos, angleX, angleY, angleZ);
	}
    private var receptorPos:Vector3D = new Vector3D();
    private var arrowPos:Vector3D = new Vector3D();
    private var sustainPos:Vector3D = new Vector3D();

    // HELPERS
    private function getScrollSpeed():Float return game.scrollSpeed;
    public function getReceptorY(lane:Float, field:Int)
        @:privateAccess
        return game.strumLines.members[field].startingPos.y;
    public function getReceptorX(lane:Float, field:Int)
        @:privateAccess
        return game.strumLines.members[field].startingPos.x + ((ARROW_SIZE) * lane);
    private var HOLD_SIZE:Float = 44 * 0.7;
    private var HOLD_SIZEDIV2:Float = (44 * 0.7) * 0.5;
    private var ARROW_SIZE:Float = 160 * 0.7;
    private var ARROW_SIZEDIV2:Float = (160 * 0.7) * 0.5;
    private var PI:Float = Math.PI;
}