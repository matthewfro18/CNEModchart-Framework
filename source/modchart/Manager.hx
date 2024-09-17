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

typedef RenderParams = {
    // Mod Percent
    perc:Float,
    // Song Position
    sPos:Float,
    // Beat Float
    fBeat:Float,
    // Hit Time Difference
    hDiff:Float,
    // Receptor ID
    receptor:Int,
    // Field ID
    field:Int
};
typedef NoteData = {
    // Hit Time Difference
    hDiff:Float,
    // Receptor ID
    receptor:Int,
    // Field ID
    field:Int
}
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
					var thisPos = new Vector3D(getReceptorX(arrow.strumID, arrow.strumLine.ID) + ARROW_SIZEDIV2 - HOLD_SIZEDIV2, getReceptorY(arrow.strumID, arrow.strumLine.ID) + ARROW_SIZEDIV2);
					var nextPos = new Vector3D(getReceptorX(arrow.strumID, arrow.strumLine.ID) + ARROW_SIZEDIV2 - HOLD_SIZEDIV2, getReceptorY(arrow.strumID, arrow.strumLine.ID) + ARROW_SIZEDIV2);
					thisPos = thisPos.add(getScrollPos((arrow.strumTime - Conductor.songPosition) * (0.45 * CoolUtil.quantize(arrow.strumLine.members[arrow.strumID].getScrollSpeed(arrow), 100)), arrow));
					nextPos = nextPos.add(getScrollPos(((arrow.strumTime + (Conductor.stepCrochet / Note.HOLD_SUBDIVS)) - Conductor.songPosition) * (0.45 * CoolUtil.quantize(arrow.strumLine.members[arrow.strumID].getScrollSpeed(arrow), 100)), arrow));

					for (vec in [thisPos, nextPos])
					{		
						renderMods(vec, {
							hDiff: (arrow.strumTime + (vec == nextPos ? (Conductor.stepCrochet / Note.HOLD_SUBDIVS) : 0)) - Conductor.songPosition,
							receptor: arrow.strumID,
							field: arrow.strumLine.ID
						});
						vec.z *= 0.001;
						vec = perspective(vec);
					}

					_vertices = ModchartUtil.getHoldVertex(thisPos, nextPos);
					_uvtData = ModchartUtil.getHoldIndices(arrow);

					arrow.updateFramePixels();
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

		super.draw();
	}
	public var DEFAULT_Z:Float = 1;
    public function updateReceptor(receptor:Strum)
    {
        final lane = receptor.extra.get('lane') ?? 0;
        final field = receptor.extra.get('field') ?? 0;

		receptor.scale.set(0.7, 0.7);
        receptor.setPosition(getReceptorX(lane, field), getReceptorY(lane, field));
        receptorPos.setTo(receptor.x, receptor.y, DEFAULT_Z);
        renderMods(receptorPos, {
            hDiff: 0,
            receptor: lane,
            field: field
        });

		receptorPos.z *= 0.001;
		receptorPos = perspective(receptorPos, cast receptor);

        receptor.setPosition(receptorPos.x, receptorPos.y);
    }
	var smoothSustains:Bool = false;

	public function getScrollPos(fuck, arrow)
	{
		var scrollPos = new Vector3D(
			0,
			fuck,
			DEFAULT_Z
		);
		var angleX = modifiers.getPercent('scrollAngleX', arrow.strumLine.ID);
		var angleY = modifiers.getPercent('scrollAngleY', arrow.strumLine.ID);
		var angleZ = modifiers.getPercent('scrollAngleZ', arrow.strumLine.ID);

		return ModchartUtil.rotate3DVector(scrollPos, angleX, angleY, angleZ);
	}
    public function updateArrow(arrow:Note)
    {		
		var shit = getScrollPos((arrow.strumTime - Conductor.songPosition) * (0.45 * CoolUtil.quantize(arrow.strumLine.members[arrow.strumID].getScrollSpeed(arrow), 100)), arrow);

        final diff = arrow.strumTime - Conductor.songPosition;
		arrow.scale.set(0.7, 0.7);
        arrow.x = getReceptorX(arrow.strumID, arrow.strumLine.ID) + shit.x;
        arrow.y = getReceptorY(arrow.strumID, arrow.strumLine.ID) + shit.y;
        arrow.angle = 0;
        arrow.strumRelativePos = false;
	
        arrowPos.setTo(arrow.x, arrow.y, shit.z);

		// arrowPos.add(getScrollPos(arrow));
        
        renderMods(arrowPos, {
            hDiff: diff,
            receptor: arrow.strumID,
            field: arrow.strumLine.ID
        });

		arrowPos.z *= 0.001;
		arrowPos = perspective(arrowPos, cast arrow);

        arrow.setPosition(arrowPos.x, arrowPos.y);

		// This dont work since im using camera.drawTriangles, fixing that later
		return;
		if (arrow.isSustainNote && arrow.wasGoodHit)
		{
			var len = 0.45 * CoolUtil.quantize(arrow.strumLine.members[arrow.strumID].getScrollSpeed(arrow), 100);
			var t = FlxMath.bound((Conductor.songPosition - arrow.strumTime) / (arrow.height) * len, 0, 1);
			var swagRect = arrow.clipRect == null ? new flixel.math.FlxRect() : arrow.clipRect;
			swagRect.x = 0;
			swagRect.y = t * arrow.frameHeight;
			swagRect.width = arrow.frameWidth;
			swagRect.height = arrow.frameHeight;
			arrow.clipRect = swagRect;
		}
    }
	function perspective(pos:Vector3D, ?obj:FlxSprite)
	{
		final tan:Float->Float = (num) -> FlxMath.fastSin(num) / FlxMath.fastCos(num);

		var outPos = pos;

		var halfScreenOffset = new Vector3D(FlxG.width / 2, FlxG.height / 2);
		outPos = outPos.subtract(halfScreenOffset);

		var fov = PI / 2;
		var screenRatio = 1;
		var near = 0;
		var far = 1;

		var perspectiveZ = outPos.z - 1;
		if (perspectiveZ > 0)
			perspectiveZ = 0; // To prevent coordinate overflow :/

		var x = outPos.x / tan(fov / 2);
		var y = outPos.y * screenRatio / tan(fov / 2);

		var a = (near + far) / (near - far);
		var b = 2 * near * far / (near - far);
		var z = a * perspectiveZ + b;

		var result = new Vector3D(x / z, y / z, z, outPos.w).add(halfScreenOffset);

		if (obj != null) {
			obj.scale.scale(1 / result.z);
		}

		return result;
	}
    private var receptorPos:Vector3D = new Vector3D();
    private var arrowPos:Vector3D = new Vector3D();
    private var sustainPos:Vector3D = new Vector3D();

    public function renderMods(pos:Vector3D, data:NoteData):Vector3D return modifiers.renderMods(pos, data);

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