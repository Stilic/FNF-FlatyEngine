package;

import flixel.FlxSprite;
import flixel.util.FlxColor;

class WeekItem extends FlxSprite
{
	public var targetY:Float = 0;

	public function new(x:Float, y:Float, weekNum:Int = 0)
	{
		super(x, y);
		loadGraphic(Paths.image('storymenu/week' + weekNum));
		antialiasing = true;
	}

	private var isFlashing:Bool = false;
	private var flashingInt:Int = 0;

	public function startFlashing():Void
	{
		isFlashing = true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		y = CoolUtil.coolLerp(y, (targetY * 120) + 480, 0.17);

		if (isFlashing)
			flashingInt += 1;

		// if it runs at 60fps, fake framerate will be 6
		// if it runs at 144 fps, fake framerate will be like 14, and will update the graphic every 0.016666 * 3 seconds still???
		// so it runs basically every so many seconds, not dependant on framerate??
		// I'm still learning how math works thanks whoever is reading this lol
		var fakeFramerate:Int = Math.round((1 / elapsed) / 10);
		if (flashingInt % fakeFramerate >= Math.floor(fakeFramerate / 2))
			color = 0xFF33ffff;
		else
			color = FlxColor.WHITE;
	}
}
