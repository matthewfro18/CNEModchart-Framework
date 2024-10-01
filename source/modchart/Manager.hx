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

		for (strumLine in game.strumLines)
		{
			strumLine.forEach(strum -> {
				strum.extra.set('field', strumLine.ID);
				// i guess ???
				strum.extra.set('lane', strumLine.members.indexOf(strum));
			});
		}
    }

	public function registerModifier(name:String, mod:Class<Modifier>)   return modifiers.registerModifier(name, mod);
    public function setPercent(name:String, value:Float, field:Int = -1) return modifiers.setPercent(name, value, field);
    public function getPercent(name:String, field:Int)    				 return modifiers.getPercent(name, field);
    public function addModifier(name:String)		 	 				 return modifiers.addModifier(name);

    public function set(name:String, beat:Float, value:Float, field:Int = -1):Void
    {
		if (field == -1)
		{
			for (curField in 0...2)
				set(name, beat, value, curField);
			return;
		}

        events.add(new SetEvent(name.toLowerCase(), beat, value, field, events));
    }
    public function ease(name:String, beat:Float, length:Float, value:Float = 1, easeFunc:EaseFunction, field:Int = -1):Void
    {	
		if (field == -1)
		{
			for (curField in 0...2)
				ease(name, beat, length, value, easeFunc, curField);
			return;
		}

        events.add(new EaseEvent(name, beat, length, value, easeFunc, field, events));
    }

    override function update(elapsed)
    {
        // Update Event Timeline
        events.update(Conductor.curBeatFloat);

        // Update Modifiers
        for (strumLine in game.strumLines)
        {
			strumLine.notes.forEachAlive(note -> {
                updateArrow(note);
            });
            strumLine.forEach(strum -> {
                updateReceptor(strum);
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
	public function getHoldQuad(basePos:Vector3D, params:NoteData, ?firstVec:Vector3D):Vector3D
	{
		var leftPoint:Vector3D = firstVec ?? modifiers.getPath(basePos.clone(), params);
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
					// TODO: clean this code AWWW my eyes
					var basePos = new Vector3D(getReceptorX(arrow.strumID, arrow.strumLine.ID), getReceptorY(arrow.strumID, arrow.strumLine.ID));
					
					if (ModchartUtil.getDownscroll())
						basePos.y = FlxG.height - basePos.y - HOLD_SIZE;

					var scrollOffset = getScrollPos(
						ModchartUtil.getArrowDistance(arrow, (ARROW_SIZE * ModchartUtil.getClippedRatio(arrow))),
						arrow
					);
					var nextScrollOffset = getScrollPos(
						ModchartUtil.getArrowDistance(arrow, Conductor.stepCrochet / Note.HOLD_SUBDIVS),
						arrow
					);

					var thisPos = basePos.add(scrollOffset);
					var nextPos = basePos.add(nextScrollOffset);
					
					// i hate wet coding but in idk why it not work on loops
					thisPos = modifiers.getPath(thisPos, {
						hDiff: arrow.strumTime - Conductor.songPosition,
						receptor: arrow.strumID,
						field: arrow.strumLine.ID,
						arrow: true
					});

					nextPos = modifiers.getPath(nextPos, {
						hDiff: (arrow.strumTime + Conductor.stepCrochet / Note.HOLD_SUBDIVS) - Conductor.songPosition,
						receptor: arrow.strumID,
						field: arrow.strumLine.ID,
						arrow: true
					});

					// i saved 2 calls to getPath
					var topQuad = getHoldQuad(basePos.clone().add(scrollOffset), {
						hDiff: arrow.strumTime - Conductor.songPosition,
						receptor: arrow.strumID,
						field: arrow.strumLine.ID,
						arrow: true
					}, thisPos);
					var bottomQuad = getHoldQuad(basePos.clone().add(nextScrollOffset), {
						hDiff: (arrow.strumTime + Conductor.stepCrochet / Note.HOLD_SUBDIVS) - Conductor.songPosition,
						receptor: arrow.strumID,
						field: arrow.strumLine.ID,
						arrow: true
					}, nextPos);

					final thisVisuals = modifiers.getVisuals({
						hDiff: arrow.strumTime - Conductor.songPosition,
						receptor: arrow.strumID,
						field: arrow.strumLine.ID,
						arrow: true
					});
					final nextVisuals = modifiers.getVisuals({
						hDiff: (arrow.strumTime + Conductor.stepCrochet / Note.HOLD_SUBDIVS) - Conductor.songPosition,
						receptor: arrow.strumID,
						field: arrow.strumLine.ID,
						arrow: true
					});
					arrow.alpha = thisVisuals.alpha * 0.6;

					// apply scale and zoom
					topQuad.x *= thisVisuals.scaleX * thisVisuals.zoom;
					topQuad.y *= thisVisuals.scaleY * thisVisuals.zoom;
					bottomQuad.x *= nextVisuals.scaleX * nextVisuals.zoom;
					bottomQuad.y *= nextVisuals.scaleY * nextVisuals.zoom;
					thisPos = ModchartUtil.applyVectorZoom(thisPos, thisVisuals.zoom);
					nextPos = ModchartUtil.applyVectorZoom(nextPos, nextVisuals.zoom);

					thisPos = ModchartUtil.applyHoldOffset(thisPos, topQuad);
					nextPos = ModchartUtil.applyHoldOffset(nextPos, bottomQuad);

					_vertices = ModchartUtil.getHoldVertex(thisPos, nextPos, [topQuad, bottomQuad]);
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

		final noteData = {
            hDiff: 0.,
            receptor: lane,
            field: field,
			arrow: false
        };
		final visuals = modifiers.getVisuals(noteData);
		
		receptor.scale.set(0.7, 0.7);
        receptor.setPosition(getReceptorX(lane, field), getReceptorY(lane, field));
        receptorPos.setTo(receptor.x, receptor.y, 0);
        receptorPos = modifiers.getPath(receptorPos, noteData);

		receptor.scale.scale(1 / receptorPos.z);
        receptor.setPosition(receptorPos.x, receptorPos.y);

		ModchartUtil.applyObjectZoom(receptor, visuals.zoom);
		receptor.scale.x *= visuals.scaleX;
		receptor.scale.y *= visuals.scaleY;
		receptor.alpha = visuals.alpha;
		receptor.angle = visuals.angle;
    }
	var smoothSustains:Bool = false;

    public function updateArrow(arrow:Note)
    {		
		if (arrow.isSustainNote) return;

		var scrollAddition = getScrollPos(ModchartUtil.getArrowDistance(arrow, 0, false), arrow);

        final diff = arrow.strumTime - Conductor.songPosition;
		final noteData = {
            hDiff: diff,
            receptor: arrow.strumID,
            field: arrow.strumLine.ID,
			arrow: false
        };
		final visuals = modifiers.getVisuals(noteData);

		arrow.scale.set(0.7, 0.7);
        arrow.x = getReceptorX(arrow.strumID, arrow.strumLine.ID);
        arrow.y = getReceptorY(arrow.strumID, arrow.strumLine.ID);
        arrow.angle = 0;
        arrow.strumRelativePos = false;
        arrowPos.setTo(arrow.x, arrow.y, 0);
		arrowPos.incrementBy(scrollAddition);

        arrowPos = modifiers.getPath(arrowPos, noteData);

		arrow.scale.scale(1 / arrowPos.z);
        arrow.setPosition(arrowPos.x, arrowPos.y);

		ModchartUtil.applyObjectZoom(arrow, visuals.zoom);
		arrow.scale.x *= visuals.scaleX;
		arrow.scale.y *= visuals.scaleY;
		arrow.alpha = visuals.alpha;
		arrow.angle = visuals.angle;
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