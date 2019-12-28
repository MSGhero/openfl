package openfl._internal.text;

import openfl.text.TextFormatAlign;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@SuppressWarnings(["checkstyle:FieldDocComment", "checkstyle:Dynamic"])
class Paragraph
{
	// paragraphs begin the character after a line break or at textIndex == 0
	public var startIndex:Int;
	public var endIndex:Int;

	public var align:TextFormatAlign;
	public var blockIndent:Int;
	public var bullet:Bool;
	public var indent:Int;
	public var leftMargin:Int;
	public var rightMargin:Int;
	
	public var offsetX:Float;
	public var offsetY:Float; // or int?
	public var height:Int;
	
	public var lines:Array<Line>;

	public function new(startIndex:Int, endIndex:Int, textEngine:TextEngine)
	{
		this.startIndex = startIndex;
		this.endIndex = endIndex;
		
		var formatRanges = textEngine.textFormatRanges;
		var i = 0;
		while (i < formatRanges.length && formatRanges[i].end < startIndex)
		{
			i++;
		}
		
		var format = formatRanges[i].format;
		
		// paragraph-level metrics
		align = format.align != null ? format.align : LEFT;
		blockIndent = format.blockIndent != null ? format.blockIndent : 0;
		// TODO: bullet = format.bullet;
		indent = format.indent != null ? format.indent : 0;
		leftMargin = format.leftMargin != null ? format.leftMargin : 0;
		rightMargin = format.rightMargin != null ? format.rightMargin : 0;
		
		offsetX = offsetY = 2;
		// TODO: GUTTER
		height = 0;
		
		lines = [new Line(startIndex, endIndex)];
		
		// force indent to 0 due to ___ (called in abl) and don't worry about conditionals/lineIndex
	}
	
	public function insertLine(index:Int):Void
	{
		var lastLine = lines[lines.length - 1];
		lastLine.endIndex = index;
		lines.push(new Line(index, endIndex));
	}
	
	public function alignBaselines(textEngine:TextEngine)
	{
		// this logic should prolly migrate back to textengine
		// just let paragraph and line be holders of info
		// wonder where textdirection comes into play...
		// text direction is the property of a run of text, not a line or paragraph... so really it's a text format thing
		// HB returns positions and stuff already "reversed" so concat order is different
		
		var lineOffset = -1, prevIndex = -1, line:Line = null;
		for (lg in textEngine.layoutGroups)
		{
			if (lg.endIndex < startIndex) continue;
			else if (lineOffset < 0) lineOffset = lg.lineIndex; // lines are easier than indices
			else if (lg.lineIndex - lineOffset >= lines.length) break; // just consider lines within this para
			else if (lg.lineIndex > prevIndex) height += line.height;
			// kinda need prev and currLG, so when line index++, I know to go back
			// maybe keep track of which lg indices are in a line (lgIndexInLine = ...), reiterate from there
			// or have two loops, which is much cleaner
			
			line = lines[lg.lineIndex - lineOffset];
			line.addHeightValues(lg.ascent, lg.descent, lg.leading);
			prevIndex = lg.lineIndex;
			
			lg.offsetY = offsetY + height;
		}
		
		height += line.height;
	}
	
	public inline function getBaseX():Float
	{
		return leftMargin + blockIndent + indent;
	}
	
	public inline function getParaWidth():Float
	{
		return rightMargin + getBaseX();
	}
}
