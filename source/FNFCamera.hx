package;

import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.math.FlxPoint;

class FNFCamera extends FlxCamera
{
	public var camFollow(default, null):FlxPoint = FlxPoint.get();

	var camFollowPos:FlxObject = new FlxObject(0, 0, 1, 1);

	public var lerp:Float;

	override public function new(Lerp:Float = 0, Width:Int = 0, Height:Int = 0, Zoom:Float = 0)
	{
		super(0, 0, Width, Height, Zoom);

		lerp = Lerp;

		resetTarget();
	}

	override public function update(elapsed:Float)
	{
		if (camFollow != null && target != null)
			target.setPosition(CoolUtil.coolLerp(target.x, camFollow.x, lerp), CoolUtil.coolLerp(target.y, camFollow.y, lerp));

		super.update(elapsed);
	}

	public function resetTarget()
	{
		follow(camFollowPos, null, 1);
	}

	public function snapToPosition(?x:Float, ?y:Float, focus:Bool = false)
	{
		if (x == null)
			x = camFollow.x;
		if (y == null)
			y = camFollow.y;

		camFollow.set(x, y);
		target.setPosition(x, y);

		if (focus)
			focusOn(camFollow);
	}
}
