package openfl.text._internal;

class TextLine
{
	public var startIndex:Int;
	public var endIndex:Int;
	public var lineIndex:Int;
	
	public var ascent:Float;
	public var descent:Float;
	public var height:Int;
	public var leading:Int;
	public var width:Float; // without trailing spaces
	public var trailingSpaceWidth:Float;
	
	public var layoutGroups:Vector<TextLayoutGroup>;

	public function new()
	{
		startIndex = 0;
		endIndex = 0;
		lineIndex = 0;
		
		// line-level metrics
		ascent = 0;
		descent = 0;
		height = 0;
		leading = 0;
		width = 0;
		trailingSpaceWidth = 0;
		
		layoutGroups = new Vector();
	}
	
	public function addLayoutGroup(lg:TextLayoutGroup):Void
	{
		if (layoutGroups.length == 0)
		{
			lineIndex = lg.lineIndex;
			layoutGroups.push(lg);
		}
		
		else
		{
			var lastLG = layoutGroups[layoutGroups.length - 1];
			
			if (lastLG.endIndex != lg.startIndex) {
				throw "uh oh";
			}
			
			if (lastLG.lineIndex == lg.lineIndex && lastLG.format == lg.format)
			{
				lastLG.positions = lastLG.positions.concat(lg.positions);
				lastLG.endIndex = lg.endIndex;
				lastLG.width += lg.width;
			}
			
			else layoutGroups.push(lg);
		}
	}
	
	public function shift(deltaX:Float, deltaY:Float):Void
	{
		for (lg in layoutGroups) {
			lg.offsetX += deltaX;
			lg.offsetY += deltaY;
		}
	}
	
	public function changeStartIndex(newStartIndex:Int):Void {
		
		if (layoutGroups.length <= 0 || newStartIndex == startIndex) return;
		
		var delta = newStartIndex - startIndex;
		
		if (delta != 0)
		{
			for (lg in layoutGroups)
			{
				lg.startIndex += delta;
				lg.endIndex += delta;
			}
			
			startIndex = newStartIndex;
			endIndex += delta;
		}
	}
	
	public function finalize():Void
	{
		width = 0;
		height = 0;
		
		if (layoutGroups.length <= 0) return; // TODO: handle appropriately
		
		leading = layoutGroups[0].format.leading == null ? 0 : layoutGroups[0].format.leading;
		
		for (lg in layoutGroups) {
			
			width += lg.width;
			
			// TODO: can two LGs have the same height but different ascents?
			if (lg.ascent + lg.descent + leading > height)
			{
				ascent = lg.ascent;
				descent = lg.descent;
				height = Math.ceil(ascent + descent + leading);
			}
		}
		
		var offX = 0.0;
		for (lg in layoutGroups)
		{
			// aligns the baselines of everything in the line
			lg.ascent = ascent;
			lg.descent = descent;
			lg.height = height;
			lg.leading = leading;
			
			lg.offsetX = offX;
			offX += lg.width; // aligns groups in x
			lg.offsetY = 0; // paragraph handles y offsets
		}
		
		// cull trailing spaces from width, so alignment happens correctly
		width -= trailingSpaceWidth;
		
		startIndex = layoutGroups[0].startIndex;
		endIndex = layoutGroups[layoutGroups.length - 1].endIndex;
	}
}