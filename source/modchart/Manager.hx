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
import openfl.geom.ColorTransform;

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

	public static var DEFAULT_HOLD_SUBDIVITIONS:Int = 1;

	public var HOLD_SUBDIVITIONS(default, set):Int;
	
	function set_HOLD_SUBDIVITIONS(divs:Int)
	{
		HOLD_SUBDIVITIONS = Std.int(Math.max(1, divs));

		updateIndices();

		return HOLD_SUBDIVITIONS;
	}

	public function updateIndices()
	{
		_indices.length = (HOLD_SUBDIVITIONS * 6);
		for (sub in 0...HOLD_SUBDIVITIONS)
		{
			var vert = sub * 4;
			var count = sub * 6;

			_indices[count] = _indices[count + 3] = vert;
			_indices[count + 2] = _indices[count + 5] = vert + 3;
			_indices[count + 1] = vert + 1;
			_indices[count + 4] = vert + 2;
		}
	}

    public var game:PlayState;
    public var events:EventManager;
	public var modifiers:ModifierGroup;

	private var _crochet:Float;

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
		// 1 as defualt
		_indices = new DrawData<Int>(1, false, []);

		HOLD_SUBDIVITIONS = DEFAULT_HOLD_SUBDIVITIONS;

		// no bpm changes
		_crochet = Conductor.stepCrochet;

		// default
		addModifier('reverse');
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

		var dw = PlayState.instance.downscroll;

		PlayState.instance.downscroll = false;
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
		PlayState.instance.downscroll = dw;
    }
    // Every 3 indices is a triangle
	var _indices:Null<DrawData<Int>> = null;
	var _uvtData:Null<DrawData<Float>> = null;
	var _vertices:Null<DrawData<Float>> = null;
	var _colors:Null<DrawData<Int>> = new DrawData<Int>();

	/**
	 * Returns the points along the hold path at specific time
	 * @param basePos The hold position per default
	 */
	public function getHoldQuads(basePos:Vector3D, params:NoteData, visuals:Visuals):Array<Vector3D>
	{
		var curPoint = ModchartUtil.applyVectorZoom(modifiers.getPath(basePos.clone(), params), visuals.zoom);
		var nextPoint = ModchartUtil.applyVectorZoom(modifiers.getPath(basePos.clone(), params, 1), visuals.zoom);

		var zScale:Float = curPoint.z != 0 ? (1 / curPoint.z) : 1;
		curPoint.z = nextPoint.z = 0;
		
		// normalized points difference (from 0-1)
		var unit = nextPoint.subtract(curPoint);
		unit.normalize();
		unit.setTo(unit.y, unit.x, 0);

		var size = (new Vector3D(-HOLD_SIZEDIV2).subtract(new Vector3D(HOLD_SIZEDIV2)).length / 2) * visuals.scaleX * zScale * visuals.zoom;

		return [
			curPoint.add(new Vector3D(-unit.x * size, unit.y * size)),
			curPoint.add(new Vector3D(unit.x * size, -unit.y * size)),
			curPoint.add(new Vector3D(0, 0,  1 + (1 - zScale) * 0.001))
		];
	}
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
					z: receptor.extra.get('z')
				});
			});
			strumLine.notes.forEachAlive(arrow -> @:privateAccess {
				if (!arrow.isSustainNote) {
					drawCB.push({
						callback: () -> {
							arrow.drawComplex(game.camHUD);
						},
						z: arrow.extra.get('z') - 2
					});
				} else {
					drawCB.push({
						callback: () -> {
							drawHoldArrow(arrow);
						},
						z: arrow.extra.get('z') - 1
					});
				}
			});
		}
		drawCB.sort((a, b) -> {
			return Math.floor(b.z - a.z);
		});
		
		for (item in drawCB) item.callback();
	}
	// for tap arrows or receptors
	function drawTapArrow(arrow:FlxSprite)
	{
		// TODO: Custom tap arrows/receptor drawing (vert modifiers)
	}
	function drawHoldArrow(arrow:Note)
	{
		var basePos = new Vector3D(
			getReceptorX(arrow.strumID, arrow.strumLine.ID),
			getReceptorY(arrow.strumID, arrow.strumLine.ID)
		).add(ModchartUtil.getHalfPos());

		var vertTotal:Array<Float> = [];

		var lastVis:Visuals = null;
		var lastQuad:Array<Vector3D> = null;

		var arrowQuads:Array<Vector3D> = null;
		var arrowVisuals:Visuals = null;

		for (sub in 0...HOLD_SUBDIVITIONS)
		{
			var subCr = _crochet / HOLD_SUBDIVITIONS;
			var subOff = subCr * sub;

			var thisData = getNoteData(arrow, subOff);
			var nextData = getNoteData(arrow, subOff + subCr);
	
			var topVisuals = lastVis ?? modifiers.getVisuals(thisData);
			var bottomVisuals = modifiers.getVisuals(nextData);

			var topQuads = lastQuad ?? getHoldQuads(basePos, thisData, topVisuals);
			var bottomQuads = getHoldQuads(basePos, nextData, bottomVisuals);

			vertTotal = vertTotal.concat(ModchartUtil.getHoldVertex(topQuads, bottomQuads));

			lastVis = bottomVisuals;
			lastQuad = bottomQuads;

			if (arrowQuads == null) {
				arrowQuads = topQuads;
				arrowVisuals = topVisuals;
			}
		}

		var colorTransf:ColorTransform = arrow.colorTransform ?? new ColorTransform();
		colorTransf.redMultiplier = 1 - arrowVisuals.glow;
		colorTransf.greenMultiplier = 1 - arrowVisuals.glow;
		colorTransf.blueMultiplier = 1 - arrowVisuals.glow;
		colorTransf.redOffset = arrowVisuals.glowR * arrowVisuals.glow * 255;
		colorTransf.greenOffset = arrowVisuals.glowG * arrowVisuals.glow * 255;
		colorTransf.blueOffset = arrowVisuals.glowB * arrowVisuals.glow * 255;
		colorTransf.alphaMultiplier = arrowVisuals.alpha * 0.6;

		Reflect.setProperty(arrow, 'colorTransform', colorTransf);

		arrow.extra.set('z', arrowQuads[2].z * 1000);

		_vertices = new DrawData(vertTotal.length, false, vertTotal);
		_uvtData = ModchartUtil.getHoldUVT(arrow, HOLD_SUBDIVITIONS);
		
		game.camHUD.drawTriangles(
			arrow.graphic,
			_vertices,
			_indices,
			_uvtData,
			_colors,
			null,
			null,
			false,
			arrow.antialiasing,
			colorTransf
		);
	}
	function getNoteData(arrow:Note, posOff:Float = 0)
	{
		var pos = (arrow.strumTime - Conductor.songPosition) + posOff;

		// clip rect
		if (arrow.wasGoodHit && pos < 0)
			pos = 0;
		return {
			time: arrow.strumTime + posOff,
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
			time: 0.,
            hDiff: 0.,
            receptor: lane,
            field: field,
			arrow: false
        };
		final visuals = modifiers.getVisuals(noteData);
		
		receptor.scale.set(0.7, 0.7);
        receptor.setPosition(getReceptorX(lane, field) + ARROW_SIZEDIV2, getReceptorY(lane, field) + ARROW_SIZEDIV2);
        receptorPos.setTo(receptor.x, receptor.y, 0);
        receptorPos = ModchartUtil.applyVectorZoom(modifiers.getPath(receptorPos, noteData), visuals.zoom);
		receptorPos.decrementBy(ModchartUtil.getHalfPos());

		receptor.scale.scale(1 / receptorPos.z);
        receptor.setPosition(receptorPos.x, receptorPos.y);

		var colorTransf:ColorTransform = receptor.colorTransform ?? new ColorTransform();
		colorTransf.redMultiplier = 1 - visuals.glow;
		colorTransf.greenMultiplier = 1 - visuals.glow;
		colorTransf.blueMultiplier = 1 - visuals.glow;
		colorTransf.redOffset = visuals.glowR * visuals.glow * 255;
		colorTransf.greenOffset = visuals.glowG * visuals.glow * 255;
		colorTransf.blueOffset = visuals.glowB * visuals.glow * 255;
		colorTransf.alphaMultiplier = visuals.alpha;
		Reflect.setProperty(receptor, 'colorTransform', colorTransf);

		receptor.scale.x *= visuals.scaleX * visuals.zoom;
		receptor.scale.y *= visuals.scaleY * visuals.zoom;
		receptor.angle = visuals.angle;

		receptor.extra.set('z', Math.floor(receptorPos.z * 1000));
    }

    public function updateArrow(arrow:Note)
    {		
        final diff = arrow.strumTime - Conductor.songPosition;
		final noteData = {
			time: arrow.strumTime,
            hDiff: diff,
            receptor: arrow.strumID,
            field: arrow.strumLine.ID,
			arrow: true
        };
		final visuals = modifiers.getVisuals(noteData);

		arrow.scale.set(0.7, 0.7);
        arrow.x = getReceptorX(arrow.strumID, arrow.strumLine.ID) + ARROW_SIZEDIV2;
        arrow.y = getReceptorY(arrow.strumID, arrow.strumLine.ID) + ARROW_SIZEDIV2;
        arrow.angle = 0;
        arrow.strumRelativePos = false;
        arrowPos.setTo(arrow.x, arrow.y, 0);

        arrowPos = ModchartUtil.applyVectorZoom(modifiers.getPath(arrowPos, noteData), visuals.zoom);
		arrowPos.decrementBy(ModchartUtil.getHalfPos());

		arrow.scale.scale(1 / arrowPos.z);
        arrow.setPosition(arrowPos.x, arrowPos.y);

		var colorTransf:ColorTransform = arrow.colorTransform ?? new ColorTransform();
		colorTransf.redMultiplier = 1 - visuals.glow;
		colorTransf.greenMultiplier = 1 - visuals.glow;
		colorTransf.blueMultiplier = 1 - visuals.glow;
		colorTransf.redOffset = visuals.glowR * visuals.glow * 255;
		colorTransf.greenOffset = visuals.glowG * visuals.glow * 255;
		colorTransf.blueOffset = visuals.glowB * visuals.glow * 255;
		colorTransf.alphaMultiplier = visuals.alpha;
		Reflect.setProperty(arrow, 'colorTransform', colorTransf);
		
		arrow.scale.x *= visuals.scaleX * visuals.zoom;
		arrow.scale.y *= visuals.scaleY * visuals.zoom;
		arrow.alpha = visuals.alpha;
		arrow.angle = visuals.angle;

		arrow.extra.set('z', Math.floor(arrowPos.z * 1000));
    }

    private var receptorPos:Vector3D = new Vector3D();
    private var arrowPos:Vector3D = new Vector3D();

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