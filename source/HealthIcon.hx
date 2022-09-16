package;

using StringTools;

class HealthIcon extends AttachedSprite
{
	public var char:String;
	public var isPlayer:Bool = false;
	public var isOldIcon:Bool = false;
	public var canBounce:Bool = false;

	public function new(char:String = 'bf', isPlayer:Bool = false, canBounce:Bool = false)
	{
		super();
		this.isPlayer = isPlayer;
		this.canBounce = canBounce;
		offsetY = -30;
		changeIcon(char);
		antialiasing = true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (canBounce)
		{
			var mult:Float = CoolUtil.coolLerp(1, scale.x, 0.2, true);
			scale.set(mult, mult);
			updateHitbox();
		}
	}

	public function swapOldIcon()
	{
		isOldIcon = !isOldIcon;

		if (isOldIcon)
			changeIcon('bf-old');
		else
			changeIcon('bf');
	}

	public function changeIcon(char:String)
	{
		if (char != 'bf-pixel' && char != 'bf-old')
			char = char.split('-')[0].trim();

		if (char != this.char)
		{
			if (animation.getByName(char) == null)
			{
				loadGraphic(Paths.image('icons/icon-' + char), true, 150, 150);
				animation.add(char, [0, 1], 0, false, isPlayer);
			}
			animation.play(char);
			this.char = char;
		}
	}

	public function bounce()
	{
		if (canBounce)
			setGraphicSize(Std.int(width + 30));
	}
}
