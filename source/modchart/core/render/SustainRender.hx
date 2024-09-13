package modchart.core.render;

import flixel.graphics.tile.FlxDrawTrianglesItem.DrawData;
import funkin.game.Note;
import openfl.Vector;
import openfl.geom.Vector3D;
import flixel.FlxStrip;
import flixel.math.FlxMath;

class SustainRender extends FlxStrip
{
    // Rendering UV Data
    public static final UV_DATA:Array<Float> = [
        0, 0,
        1, 0,
        0, 0.5,
        1, 0.5,
        0, 1,
        1, 1
    ];
    // Every 3 indices is a triangle
    public static final INDICES:Array<Int> = [
		0, 1, 2,
		1, 3, 2,
		2, 3, 4,
		3, 5, 4
    ];
    
    var self:Note;

    override public function new(self:Note)
    {
        this.self = self;

        super(0,0);
        loadGraphic(self.updateFramePixels());

        shader = self.shader;
        cameras = self.cameras;

        for (uv in UV_DATA)
        {
            uvtData.push(uv);
            vertices.push(0);
        }
        for (ind in INDICES)
            indices.push(ind);
    }
    public function updateVertices(self:Vector3D, next:Vector3D)
    {
        var verts:Array<Float> = [];

		// top left
		verts.push(self.x);
		verts.push(self.y);
		// top right
		verts.push(self.x + self.w);
		verts.push(self.y);

		// middle left
		verts.push(FlxMath.lerp(self.x, next.x, 0.5));
		verts.push(FlxMath.lerp(self.y, next.y, 0.5));
		// middle right
		verts.push(FlxMath.lerp(self.x + self.w, next.x + next.w, 0.5));
		verts.push(FlxMath.lerp(self.y, next.y, 0.5));

		// bottmo left
		verts.push(next.x);
		verts.push(next.y);
		// bottom right
		verts.push(next.x + next.w);
		verts.push(next.y);

        vertices = new DrawData(12, true, verts);
    }
}