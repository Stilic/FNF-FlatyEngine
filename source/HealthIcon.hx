package;

using StringTools;

class HealthIcon extends AttachedSprite
{
	public var char:String;
	public var isPlayer:Bool = false;
	public var isOldIcon:Bool = false;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		this.isPlayer = isPlayer;
		offsetY = -30;
		changeIcon(char);
		antialiasing = true;
	}

	public function swapOldIcon()
	{
		isOldIcon = !isOldIcon;

		if (isOldIcon)
		{
			changeIcon('bf-old');
		}
		else
		{
			changeIcon('bf');
		}
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
}
