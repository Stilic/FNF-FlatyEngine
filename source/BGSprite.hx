package;

import flixel.FlxSprite;

class BGSprite extends FlxSprite
{
	public var idleAnim:String;

	override public function new(image:String, x:Float = 0, y:Float = 0, scrollX:Float = 1, scrollY:Float = 1, ?animations:Array<String>,
			loopAnims:Bool = false)
	{
		super(x, y);

		if (animations != null)
		{
			frames = Paths.getSparrowAtlas(image);
			for (anim in animations)
			{
				animation.addByPrefix(anim, anim, 24, loopAnims);
				if (idleAnim == null)
					idleAnim = anim;
			}
			dance();
			animation.finish();
		}
		else
		{
			loadGraphic(Paths.image(image));
			active = false;
		}
		scrollFactor.set(scrollX, scrollY);
		antialiasing = PreferencesMenu.getPref('antialiasing');
	}

	public function dance()
	{
		if (idleAnim != null)
			animation.play(idleAnim);
	}
}
