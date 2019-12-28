package openfl._internal.text;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@SuppressWarnings(["checkstyle:FieldDocComment", "checkstyle:Dynamic"])
class Line
{
	public var startIndex:Int;
	public var endIndex:Int;
	
	public var ascent:Float;
	public var descent:Float;
	public var height:Int;
	public var leading:Int;
	public var width:Float; // or int?

	public function new(startIndex:Int, endIndex:Int)
	{
		this.startIndex = startIndex;
		this.endIndex = endIndex;
		
		ascent = 0;
		descent = 0;
		height = 0;
		leading = 0;
		width = 0;
		
		// TODO: where to calc ascent descent?
	}
	
	public function addHeightValues(ascent:Float, descent:Float, leading:Float):Void
	{
		if (ascent > this.ascent) this.ascent = ascent;
		if (descent > this.descent) this.descent = descent;
		if (leading > this.leading) this.leading = leading;
		
		var height = Math.ceil(ascent + descent + leading);
		if (height > this.height) this.height = height;
		// TODO: is this true, or does it default to true if ascent is true?
	}
}
