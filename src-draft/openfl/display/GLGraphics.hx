package openfl.display;

import openfl._internal.renderer.context3D.Context3DRenderer;
import openfl._internal.renderer.opengl.utils.DrawPath;
import openfl._internal.renderer.opengl.utils.GLStack;
import openfl._internal.renderer.opengl.utils.GraphicsRenderer;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

@:access(openfl.geom.Matrix)
@:access(openfl.geom.Rectangle)
class GLGraphics extends Shape
{
	private var __bounds:Rectangle = new Rectangle(0, 0, 0, 0);

	@:noCompletion private var __drawPaths:Array<DrawPath>;
	@:noCompletion private var __glStack:Array<GLStack> = [];

	public function new()
	{
		super();

		__type = GL_GRAPHICS;
		__blendMode = NORMAL;
	}

	@:noCompletion @:dox(hide) public static function render(graphics:GLGraphics, renderer:Context3DRenderer):Void
	{
		GraphicsRenderer.render(graphics, renderer);
	}

	@:noCompletion private function __addPointToBounds(x:Float, y:Float):Void
	{
		if (x < __bounds.x)
		{
			__bounds.width += __bounds.x - x;
			__bounds.x = x;
		}

		if (y < __bounds.y)
		{
			__bounds.height += __bounds.y - y;
			__bounds.y = y;
		}

		if (x > __bounds.x + __bounds.width)
		{
			__bounds.width = x - __bounds.x;
		}

		if (y > __bounds.y + __bounds.height)
		{
			__bounds.height = y - __bounds.y;
		}
	}

	@:noCompletion private override function __getBounds(rect:Rectangle, matrix:Matrix):Void
	{
		var bounds = Rectangle.__pool.get();
		__bounds.__transform(bounds, matrix);
		rect.__expand(bounds.x, bounds.y, bounds.width, bounds.height);
		Rectangle.__pool.release(bounds);
	}
}
