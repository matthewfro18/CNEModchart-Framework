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
import modchart.core.util.Constants.Visuals;

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
		_indices = new DrawData<Int>(6, true, [
			0, 1, 3,
			0, 2, 3
		]);
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
	var _indices = null;
	var _uvtData = null;
	var _vertices = null;

	/**
	 * Returns the points along the hold path at specific time
	 * @param basePos The hold position per default
	 */
	public function getHoldQuads(basePos:Vector3D, params:NoteData, visuals:Visuals):Array<Vector3D>
	{
		var quad = [new Vector3D((-HOLD_SIZEDIV2)), new Vector3D((HOLD_SIZEDIV2))];

		var curPoint =  modifiers.getPath(basePos.clone(), params);
		var scale:Float = curPoint.z != 0 ? (1 / curPoint.z) : 1;

		params.hDiff += 1;
		var nextPoint =  modifiers.getPath(basePos.clone(), params);
		params.hDiff -= 1;

		curPoint.z = nextPoint.z = 0;
		
		// normalized points difference (from 0-1)
		var unit = nextPoint.subtract(curPoint);
		unit.normalize();
		// im dumb
		unit.setTo(unit.y, unit.x, 0);

		var size = (quad[0].subtract(quad[1]).length / 2) * visuals.scaleX * visuals.zoom;

		var quadOffsets = [
			new Vector3D(-unit.x * size, unit.y * size),
			new Vector3D(unit.x * size, -unit.y * size)
		];

		return [
			curPoint.add(quadOffsets[0]),
			curPoint.add(quadOffsets[1]),
			curPoint
		];
	}
	var _point:FlxPoint = FlxPoint.get();
	override function draw()
	{
		var drawCB = [];
        for (strumLine in game.strumLines)
		{
			strumLine.notes.visible = strumLine.visible = false;

			strumLine.forEach(receptor -> {
				@:privateAccess
				drawCB.push({
					callback: () -> {
						receptor.drawComplex(game.camHUD);
					},
					z: receptor.extra.get('z') - 1
				});
			});
			
			strumLine.notes.forEachAlive(arrow -> @:privateAccess {
				if (!arrow.isSustainNote) {
					drawCB.push({
						callback: () -> {
							arrow.drawComplex(game.camHUD);
						},
						z: arrow.extra.get('z') + 1
					});
				} else {
					drawCB.push({
						callback: () -> {
							drawHoldArrow(arrow);
						},
						z: arrow.extra.get('z')
					});
				}
			});
		}
		drawCB.sort((a, b) -> {
			return Math.ceil(a.z - b.z);
		});
		for (item in drawCB) item.callback();
	}
	// for tap arrows or receptors
	function drawTapArrow(arrow:FlxSprite)
	{
	}
	function drawHoldArrow(arrow:Note)
	{
		var basePos = new Vector3D(
			getReceptorX(arrow.strumID, arrow.strumLine.ID),
			getReceptorY(arrow.strumID, arrow.strumLine.ID)
		).add(ModchartUtil.getHalfPos());

		var curData = getNoteData(arrow);
		var nextData = getNoteData(arrow, Conductor.stepCrochet / Note.HOLD_SUBDIVS);

		var topVisuals = modifiers.getVisuals(curData);
		var bottomVisuals = modifiers.getVisuals(nextData);

		var topQuads = getHoldQuads(basePos, curData, topVisuals);
		var bottomQuads = getHoldQuads(basePos, nextData, bottomVisuals);
		arrow.alpha = topVisuals.alpha * 0.6;

		_vertices = ModchartUtil.getHoldVertex(topQuads, bottomQuads);
		_uvtData = ModchartUtil.getHoldUVT(arrow);
		
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
	function getNoteData(arrow:Note, posOff:Float = 0)
	{
		var pos = (arrow.strumTime - Conductor.songPosition) + posOff;

		if (arrow.wasGoodHit && pos < 0)
			pos = 0;
		return {
			hDiff: pos,
			receptor: arrow.strumID,
			field: arrow.strumLine.ID,
			arrow: true
		};
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
        receptor.setPosition(getReceptorX(lane, field) + ARROW_SIZEDIV2, getReceptorY(lane, field) + ARROW_SIZEDIV2);
        receptorPos.setTo(receptor.x, receptor.y, 0);
        receptorPos = modifiers.getPath(receptorPos, noteData);
		receptorPos.decrementBy(ModchartUtil.getHalfPos());

		receptor.scale.scale(1 / receptorPos.z);
        receptor.setPosition(receptorPos.x, receptorPos.y);

		ModchartUtil.applyObjectZoom(receptor, visuals.zoom);
		receptor.scale.x *= visuals.scaleX;
		receptor.scale.y *= visuals.scaleY;
		receptor.alpha = visuals.alpha;
		receptor.angle = visuals.angle;

		receptor.extra.set('z', receptorPos.z * 1000);
    }

    public function updateArrow(arrow:Note)
    {		
		if (arrow.isSustainNote) return;

        final diff = arrow.strumTime - Conductor.songPosition;
		final noteData = {
            hDiff: diff,
            receptor: arrow.strumID,
            field: arrow.strumLine.ID,
			arrow: false
        };
		final visuals = modifiers.getVisuals(noteData);

		arrow.scale.set(0.7, 0.7);
        arrow.x = getReceptorX(arrow.strumID, arrow.strumLine.ID) + ARROW_SIZEDIV2;
        arrow.y = getReceptorY(arrow.strumID, arrow.strumLine.ID) + ARROW_SIZEDIV2;
        arrow.angle = 0;
        arrow.strumRelativePos = false;
        arrowPos.setTo(arrow.x, arrow.y, 0);

        arrowPos = modifiers.getPath(arrowPos, noteData);
		arrowPos.decrementBy(ModchartUtil.getHalfPos());

		arrow.scale.scale(1 / arrowPos.z);
        arrow.setPosition(arrowPos.x, arrowPos.y);

		ModchartUtil.applyObjectZoom(arrow, visuals.zoom);
		arrow.scale.x *= visuals.scaleX;
		arrow.scale.y *= visuals.scaleY;
		arrow.alpha = visuals.alpha;
		arrow.angle = visuals.angle;

		arrow.extra.set('z', arrowPos.z * 1000);
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
		
	// for some reazon is 50 instead of 44 in cne
    private var HOLD_SIZE:Float = 50 * 0.7;
    private var HOLD_SIZEDIV2:Float = (50 * 0.7) * 0.5;
    private var ARROW_SIZE:Float = 160 * 0.7;
    private var ARROW_SIZEDIV2:Float = (160 * 0.7) * 0.5;
    private var PI:Float = Math.PI;
}