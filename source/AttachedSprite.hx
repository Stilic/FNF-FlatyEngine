package;

import flixel.FlxSprite;

class AttachedSprite extends FlxSprite
{
	public var sprTracker:FlxSprite;

	public var offsetX:Float = 10;
	public var offsetY:Float = 0;

	public function new(?sprTracker:FlxSprite)
	{
		super();
		this.sprTracker = sprTracker;
		scrollFactor.set();

		antialiasing = false;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + offsetX, sprTracker.y + offsetY);
	}
}
