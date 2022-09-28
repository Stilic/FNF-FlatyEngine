package;

import haxe.Timer;
import openfl.Lib;
import openfl.system.System;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.FlxG;
import flixel.math.FlxMath;

class CoolCounter extends TextField
{
	public var showFPS:Bool = true;
	public var showMemory:Bool = true;
	public var showMemoryPeak:Bool = true;
	public var showObjectCount:Bool = false;

	var times:Array<Float> = [];
	var memoryPeak:Float = 0;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		width = Lib.current.stage.width;

		selectable = false;
		mouseEnabled = false;

		defaultTextFormat = new TextFormat('_sans', 13, color);
		multiline = true;
		text = 'FPS: ';

		addEventListener(Event.ENTER_FRAME, onEnter);
	}

	@:noCompletion function onEnter(_)
	{
		var now:Float = Timer.stamp();
		times.push(now);

		while (times[0] < now - 1)
			times.shift();

		var mem:Float = FlxMath.roundDecimal(System.totalMemory / 1000000, 1);
		if (mem > memoryPeak)
			memoryPeak = mem;

		if (visible)
		{
			var leText:String = '';

			if (showFPS)
				leText += 'FPS: ${times.length}\n';

			if (showMemory)
			{
				leText += 'RAM: ${mem}mb';
				if (showMemoryPeak)
					leText += ' / ${memoryPeak}mb\n';
				else
					leText += '\n';
			}

			if (showObjectCount)
				leText += 'Objects: ${FlxG.state != null ? FlxG.state.members.length : 0}';

			text = leText;
		}
	}
}
