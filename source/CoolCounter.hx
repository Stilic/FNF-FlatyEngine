package;

import haxe.Timer;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.FlxG;

class CoolCounter extends TextField
{
	public var showFPS:Bool = true;
	public var showMemory:Bool = true;
	public var showMemoryPeak:Bool = true;
	public var showObjectCount:Bool = false;

	var times:Array<Float> = [];
	var memoryPeak:Float = 0;

	public function new(x:Float = 7, y:Float = 3, color:Int = 0xFFFFFF)
	{
		super();

		this.x = x;
		this.y = y;

		selectable = false;
		mouseEnabled = false;

		defaultTextFormat = new TextFormat('./' + Paths.font('vcr.ttf'), 13, color);
		autoSize = LEFT;
		multiline = true;

		addEventListener(Event.ENTER_FRAME, onEnter);
	}

	static final intervalArray:Array<String> = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB']; // tb support for the myth engine modders :)

	public static function getInterval(size:Float)
	{
		var data:Int = 0;
		while (size > 1024 && data < intervalArray.length - 1)
		{
			data++;
			size = size / 1024;
		}
		size = Math.round(size * 100) / 100;
		return '$size ${intervalArray[data]}';
	}

	@:noCompletion function onEnter(_)
	{
		var now:Float = Timer.stamp();
		times.push(now);

		while (times[0] < now - 1)
			times.shift();

		#if cpp
		var mem:Float = cpp.vm.Gc.memInfo64(3);
		#else
		var mem:Int = openfl.system.System.totalMemory;
		#end

		if (mem > memoryPeak)
			memoryPeak = mem;

		if (visible)
		{
			var leText:String = '';

			if (showFPS)
				leText += 'FPS: ${times.length}\n';

			if (showMemory)
			{
				var memText:String = getInterval(mem);
				leText += 'RAM: $memText';
				if (showMemoryPeak)
				{
					leText += ' / ';
					if (memoryPeak == mem)
						leText += memText;
					else
						leText += getInterval(memoryPeak);
					leText += '\n';
				}
				else
					leText += '\n';
			}

			if (showObjectCount)
				leText += 'Objects: ${FlxG.state != null ? FlxG.state.members.length : 0}';

			text = leText;
		}
	}
}
