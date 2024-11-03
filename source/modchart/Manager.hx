package modchart;

import funkin.backend.system.Logs;
import funkin.game.Note;
import funkin.game.Strum;
import funkin.game.StrumLine;
import funkin.game.PlayState;
import funkin.backend.utils.CoolUtil;
import funkin.backend.system.Conductor;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.system.FlxAssets.FlxShader;
import flixel.tweens.FlxEase.EaseFunction;
import flixel.graphics.tile.FlxDrawTrianglesItem.DrawData;
import flixel.graphics.tile.FlxDrawTrianglesItem;

import openfl.Vector;

import openfl.geom.Matrix;
import openfl.geom.Vector3D;
import openfl.geom.ColorTransform;

import openfl.display.Shape;
import openfl.display.BitmapData;
import openfl.display.GraphicsPathCommand;

import modchart.modifiers.*;
import modchart.events.*;
import modchart.events.types.*;
import modchart.core.util.ModchartUtil;
import modchart.core.ModifierGroup;
import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.NoteData;
import modchart.core.util.Constants.Visuals;

// @:build(modchart.core.macros.Macro.buildModifiers())
@:allow(modchart.core.ModifierGroup)
class Manager extends FlxBasic
{
    public static var instance:Manager;

	public static var DEFAULT_HOLD_SUBDIVITIONS:Int = 1;

	public var HOLD_SUBDIVITIONS(default, set):Int;

	// turn on if u wanna arrow paths
	public var renderArrowPaths:Bool = false;
	
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

		// default mods
		addModifier('reverse');
		addModifier('stealth');
		addModifier('confusion');

		setPercent('arrowPathAlpha', 1, -1);
		setPercent('arrowPathThickness', 1, -1);
		setPercent('arrowPathDivitions', 1, -1);
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

    override function update(elapsed:Float):Void
    {
        // Update Event Timeline
        events.update(Conductor.curBeatFloat);
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

		var size = (new Vector3D(-HOLD_SIZEDIV2).subtract(new Vector3D(HOLD_SIZEDIV2)).length * .5) * visuals.scaleX * zScale * visuals.zoom;

		return [
			curPoint.add(new Vector3D(-unit.x * size, unit.y * size)),
			curPoint.add(new Vector3D(unit.x * size, -unit.y * size)),
			curPoint.add(new Vector3D(0, 0,  1 + (1 - zScale) * 0.001))
		];
	}
	override function draw():Void
	{
		if (renderArrowPaths)
			drawArrowPath(game.strumLines.members);

		super.draw();

		var drawCB = [];
        for (strumLine in game.strumLines)
		{
			strumLine.notes.visible = strumLine.visible = false;
			
			strumLine.forEach(receptor -> {
				@:privateAccess
				drawCB.push({
					callback: () -> {
						drawReceptor(receptor);
					},
					z: receptor.extra.get('z')
				});

				// draw the path for every receptor
			});
			strumLine.notes.forEach(arrow -> @:privateAccess {
				if (!arrow.isSustainNote) {
					drawCB.push({
						callback: () -> {
							drawTapArrow(arrow);
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
			return Math.round(b.z - a.z);
		});
		
		for (item in drawCB) item.callback();
	}
	/**
	 * TODO: Implement a custom renderer
	 * to rotate the arrow graphic.
	 */
	function drawReceptor(receptor:Strum) @:privateAccess {
        final lane = receptor.extra.get('lane') ?? 0;
        final field = receptor.extra.get('field') ?? 0;

		final noteData:NoteData = {
			time: 0.,
            hDiff: 0.,
            receptor: lane,
            field: field,
			arrow: false
        };
		final visuals:Visuals = modifiers.getVisuals(noteData);
		
		var lastScale = receptor.scale.clone();

		ARROW_SIZE = receptor.width;
		ARROW_SIZEDIV2 = receptor.width * .5;

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

		var cameras:Array<FlxCamera> = receptor._cameras ?? game.strumLines.members[field].cameras;
		for (camera in cameras)
			receptor.drawComplex(camera);

		receptor.scale.copyFrom(lastScale);

		lastScale.put();
	}
	function drawTapArrow(arrow:Note) @:privateAccess {
		final diff = arrow.strumTime - Conductor.songPosition;
		final noteData:NoteData = {
			time: arrow.strumTime,
            hDiff: diff,
            receptor: arrow.strumID,
            field: arrow.strumLine.ID,
			arrow: true
        };
		final visuals = modifiers.getVisuals(noteData);

		var lastScale = arrow.scale.clone();

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

		var cameras:Array<FlxCamera> = arrow._cameras ?? arrow.strumLine.cameras;
		for (camera in cameras)
			arrow.drawComplex(camera);

		arrow.scale.copyFrom(lastScale);

		lastScale.put();
	}

	/**
	 * TODO: Draw every hold once in the camera buffer (via the camara graphics).
	 * (instead of draw every single hold via flixel).
	 */
	function drawHoldArrow(arrow:Note) @:privateAccess {
		var basePos = new Vector3D(
			getReceptorX(arrow.strumID, arrow.strumLine.ID),
			getReceptorY(arrow.strumID, arrow.strumLine.ID)
		).add(ModchartUtil.getHalfPos());

		var vertTotal:Array<Float> = [];

		var lastVis:Visuals = null;
		var lastQuad:Array<Vector3D> = null;

		var arrowQuads:Array<Vector3D> = null;
		var arrowVisuals:Visuals = null;

		HOLD_SIZE = arrow.width;
		HOLD_SIZEDIV2 = arrow.width * .5;

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

		var colorTransf:ColorTransform = new ColorTransform();
		colorTransf.redMultiplier = 1 - arrowVisuals.glow;
		colorTransf.greenMultiplier = 1 - arrowVisuals.glow;
		colorTransf.blueMultiplier = 1 - arrowVisuals.glow;
		colorTransf.redOffset = arrowVisuals.glowR * arrowVisuals.glow * 255;
		colorTransf.greenOffset = arrowVisuals.glowG * arrowVisuals.glow * 255;
		colorTransf.blueOffset = arrowVisuals.glowB * arrowVisuals.glow * 255;
		colorTransf.alphaMultiplier = arrowVisuals.alpha * 0.6;

		arrow.extra.set('z', arrowQuads[2].z * 1000);

		_vertices = new DrawData(vertTotal.length, false, vertTotal);
		_uvtData = ModchartUtil.getHoldUVT(arrow, HOLD_SUBDIVITIONS);

		var cameras:Array<FlxCamera> = arrow._cameras ?? arrow.strumLine.cameras;
		for (camera in cameras)
		{
			var trianglesBatch:FlxDrawTrianglesItem;
			
			// create or recycle a new draw item
			trianglesBatch = camera.startTrianglesBatch(arrow.graphic, false, true, null, true);

			// add the actual draw data
			trianglesBatch.addTriangles(_vertices, _indices, _uvtData, _colors, null, null, colorTransf);
		}
	}
	// TODO: Optimize this
	/**
	 * Draws the Arrow trajectory
	 * 
	 * This has very path performance
	 * and i think it also has.....
	 * M E M O R Y   L E A K S
	 * 
	 * Edit: so um it seems like i fix the memory leaks
	 * but the mem count goes crazy anyways
	 * @param fields The strum lines paths will be drawed
	 */
	function drawArrowPath(fields:Array<StrumLine>)
	{
		var data = new openfl.Vector<Float>();
		var commands = new openfl.Vector<Int>();

		var defaultPos = new Vector3D();

		__pathPoints.splice(0, __pathPoints.length);
		__pathCommands.splice(0, __pathCommands.length);
		__pathShape.graphics.clear();

		// so we draw every path of every receptor once
		// cus if not, it crashs (cus stack overflow or something like that (i dont founded the error....))
		for (f in fields) {
			__pathSprite.cameras = f._cameras.copy();
			
			for (r in f) {
				final l = r.extra.get('lane');
				final fn = r.extra.get('field');

				final alpha = getPercent('arrowPathAlpha', fn);
				final thickness = Math.round(Math.max(1, getPercent('arrowPathThickness', fn)));

				if ((alpha + thickness) <= 0)
					continue;
				
				final divitions = Math.round(35 / Math.max(1, getPercent('arrowPathDivitions', fn)));
				final limit = 1500 * (1 + getPercent('arrowPathLength', fn));
				final invertal = limit / divitions;

				var moved = false;

				defaultPos.setTo(getReceptorX(l, fn), getReceptorY(l, fn), 0);
				defaultPos.incrementBy(ModchartUtil.getHalfPos());

				__pathShape.graphics.lineStyle(thickness, 0xFFFFFFFF, alpha);

				for (sub in 0...divitions)
				{
					var time = invertal * sub;
		
					var position = modifiers.getPath(defaultPos.clone(), {
						time: Conductor.songPosition + time,
						hDiff: time,
						receptor: l,
						field: fn,
						arrow: true
					});

					/**
					 * So it seems that if the lines are too far from the screen
					   causes HORRIBLE memory leaks (from 60mb to 3gb-5gb in 2 seconds WHAT THE FUCK)
					 */
					if ((position.x <= -25) || (position.x >= __pathSprite.pixels.rect.width + 25) ||
						(position.y <= -25) || (position.y >= __pathSprite.pixels.rect.height + 25))
						continue;
		
					__pathCommands.push(moved ? GraphicsPathCommand.LINE_TO : GraphicsPathCommand.MOVE_TO);
					__pathPoints.push(position.x);
					__pathPoints.push(position.y);
		
					moved = true;
				}
			}
		}

		__pathShape.graphics.drawPath(__pathCommands, __pathPoints);

		// then drawing the path pixels into the sprite pixels
		__pathSprite.pixels.fillRect(__pathSprite.pixels.rect, 0x00FFFFFF);
		__pathSprite.pixels.draw(__pathShape);
		// draw the sprite to the cam
		__pathSprite.draw();
	}
	var __pathSprite:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0x00FFFFFF);
	var __pathShape:Shape = new Shape();
	var __pathPoints:Vector<Float> = new Vector<Float>();
	var __pathCommands:Vector<Int> = new Vector<Int>();
	// var __pathBitmap:BitmapData = new BitmapData(FlxG.width, FlxG.height, true, 0x00FFFFFF);

	function getNoteData(arrow:Note, posOff:Float = 0):NoteData
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

	override function destroy():Void
	{
		super.destroy();

		arrowPos = null;
		receptorPos = null;

		__pathSprite.destroy();
		__pathPoints.splice(0, __pathPoints.length);
		__pathCommands.splice(0, __pathCommands.length);
		__pathShape.graphics.clear();
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
    public static var HOLD_SIZE:Float = 50 * 0.7;
    public static var HOLD_SIZEDIV2:Float = (50 * 0.7) * 0.5;
    public static var ARROW_SIZE:Float = 160 * 0.7;
    public static var ARROW_SIZEDIV2:Float = (160 * 0.7) * 0.5;
    public static var PI:Float = Math.PI;
}