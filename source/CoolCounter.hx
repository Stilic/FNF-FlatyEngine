package;

import openfl.Lib;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

class CoolCounter extends TextField
{
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

	public var showFPS:Bool = true;
	public var showMemory:Bool = true;
	public var showMemoryPeak:Bool = true;
	public var showObjectCount:Bool = false;

	public var memoryPeak(default, null):Float = 0;

	var currentTime:Float = 0;
	var times:Array<Float> = [];
	var cacheCount:Int = 0;

	public function new(x:Float = 7, y:Float = 3, color:Int = 0xFFFFFF)
	{
		super();

		this.x = x;
		this.y = y;

		selectable = false;
		mouseEnabled = false;

		defaultTextFormat = new TextFormat(Paths.fontName('vcr.ttf'), 13, color);
		autoSize = LEFT;
		multiline = true;

		alpha = 0.7;

		addEventListener(Event.ENTER_FRAME, function(_)
		{
			__enterFrame(Lib.getTimer() - currentTime);
		});
	}

	#if !flash override #end function __enterFrame(deltaTime:Float)
	{
		currentTime += deltaTime;

		times.push(currentTime);
		while (times[0] < currentTime - 1000)
			times.shift();

		if (cacheCount != times.length)
		{
			cacheCount = times.length;

			var leText:String = '';

			if (showFPS)
				leText += 'FPS: ${FlxMath.bound(Math.round(times.length + cacheCount), 0, FlxG.updateFramerate)}\n';

			#if cpp
			var mem:Float = cpp.vm.Gc.memInfo64(3);
			#else
			var mem:Int = openfl.system.System.totalMemory;
			#end
			if (mem > memoryPeak)
				memoryPeak = mem;

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

			var intendedColor:FlxColor;
			if (mem / 1000000 > 3000 || times.length <= FlxG.updateFramerate / 2)
				intendedColor = 0xFFFF0000;
			else
				intendedColor = 0xFFFFFFFF;
			textColor = FlxColor.interpolate(textColor, intendedColor, CoolUtil.camLerpShit(0.15));
		}
	}
}
