package openfl.text._internal;

import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

class TextParagraph
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
	// TODO: tabStops
	
	public var offsetX:Float;
	public var offsetY:Float; // or int?
	
	public var width:Float; // needed?
	public var height:Int;
	
	public var lines:Array<TextLine>;

	public function new(startIndex:Int, endIndex:Int)
	{
		this.startIndex = startIndex;
		this.endIndex = endIndex;
		
		offsetX = offsetY = 2; // GUTTER
		
		width = 4;
		height = 4;
		
		lines = [];
		
		align = LEFT;
		blockIndent = 0;
		bullet = false;
		indent = 0;
		leftMargin = 0;
		rightMargin = 0;
	}
	
	public function addLine(line:TextLine):Void
	{
		// inline
		// *** also consider paragraphs as helpers, and there's really just a single line array that everything gets added to ***
		// maybe even consider lines as helpers on top of a single layout group array, which would be most ideal
		// ugh linked list sounds really good there
		// you could even be tricky and begin iteration at the head or tail depending on where modifications occur, or even go by paragraph, but that's for the future
		lines.push(line);
	}
	
	public function addLayoutGroup(lg:TextLayoutGroup):TextLine
	{
		var line:TextLine = null;
		
		// maybe this check could be more robust? or less annoying
		if (lines.length == 0 || lg.lineIndex > lines[lines.length - 1].lineIndex)
		{
			if (lines.length == 0)
			{
				// paragraph-level metrics
				var format = lg.format;
				
				align = format.align != null ? format.align : align;
				blockIndent = format.blockIndent != null ? format.blockIndent : blockIndent;
				// TODO: bullet = format.bullet;
				indent = format.indent != null ? format.indent : indent;
				leftMargin = format.leftMargin != null ? format.leftMargin : leftMargin;
				rightMargin = format.rightMargin != null ? format.rightMargin : rightMargin;
				// TODO: tabStops
			}
			
			line = new TextLine();
			lines.push(line);
		}
		else
		{
			line = lines[lines.length - 1];
		}
		
		line.addLayoutGroup(lg);
		
		return line;
	}
	
	public function changeStartIndex(newStartIndex:Int):Void
	{
		// inline?
		if (lines.length <= 0 || newStartIndex == startIndex) return;
		
		for (line in lines) line.changeStartIndex(newStartIndex);
		startIndex = newStartIndex;
		endIndex = lines[lines.length - 1].endIndex;
	}
	
	public function finalize():Void
	{
		width = 0;
		height = 0;
		
		if (lines.length <= 0) return; // TODO: handle, prolly not correct to just return
		
		var line;
		for (i in 0...lines.length)
		{
			line = lines[i];
			line.finalize();
			line.shift(getBaseMargin(i), offsetY + height); // x shift different for RTL
			
			if (line.width > width) width = line.width;
			height += line.height;
		}
		
		endIndex = lines[lines.length - 1].endIndex;
	}
	
	public function getBaseMargin(relativeLineIndex:Int):Float
	{
		// inline?
		return Math.max(2, offsetX + leftMargin + blockIndent + (relativeLineIndex == 0 ? indent : 0)); // GUTTER
	}
		
	public function getAllMargin(lineIndex:Int):Float
	{
		// inline?
		var base = getBaseMargin(lines.length == 0 ? 0 : lineIndex - lines[0].lineIndex);
		return Math.max(4, base + 2 + rightMargin); // GUTTER
	}			
}