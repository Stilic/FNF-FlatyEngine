package;

import flixel.math.FlxPoint;
import shaders.ColorSwap;

using StringTools;

class StrumNote extends FNFSprite
{
	public var noteData:Int;

	public var direction:Float = 90;
	public var downscroll:Bool = false;
	public var sustainReduce:Bool = true;

	var resetAnim:Float = 0;

	var colorSwap:ColorSwap;

	override public function new(x:Float, y:Float, noteData:Int, downscroll:Bool)
	{
		super(x, y);

		this.noteData = noteData;
		this.downscroll = downscroll;

		if (PlayState.curStage.startsWith('school'))
		{
			loadGraphic(Paths.image('pixelUI/arrows-pixels'), true, 17, 17);

			antialiasing = false;
			setGraphicSize(Std.int(width * PlayState.daPixelZoom));

			switch (noteData)
			{
				case 0:
					animation.add('static', [0], 12);
					animation.add('pressed', [4, 8], 12, false);
					animation.add('confirm', [12, 16], 12, false);
				case 1:
					animation.add('static', [1], 12);
					animation.add('pressed', [5, 9], 12, false);
					animation.add('confirm', [13, 17], 12, false);
				case 2:
					animation.add('static', [2], 12);
					animation.add('pressed', [6, 10], 12, false);
					animation.add('confirm', [14, 18], 12, false);
				case 3:
					animation.add('static', [3], 12);
					animation.add('pressed', [7, 11], 12, false);
					animation.add('confirm', [15, 19], 12, false);
			}
		}
		else
		{
			frames = Paths.getSparrowAtlas('NOTE_assets');

			antialiasing = true;
			setGraphicSize(Std.int(width * 0.7));

			switch (noteData)
			{
				case 0:
					animation.addByPrefix('static', 'arrowLEFT', 24);
					animation.addByPrefix('pressed', 'left press', 24, false);
					animation.addByPrefix('confirm', 'left confirm', 24, false);

					addOffset('confirm', -1, -4);
				case 1:
					animation.addByPrefix('static', 'arrowDOWN', 24);
					animation.addByPrefix('pressed', 'down press', 24, false);
					animation.addByPrefix('confirm', 'down confirm', 24, false);

					addOffset('confirm', -3, -1);
				case 2:
					animation.addByPrefix('static', 'arrowUP', 24);
					animation.addByPrefix('pressed', 'up press', 24, false);
					animation.addByPrefix('confirm', 'up confirm', 24, false);

					addOffset('confirm', -1.5, -1);
				case 3:
					animation.addByPrefix('static', 'arrowRIGHT', 24);
					animation.addByPrefix('pressed', 'right press', 24, false);
					animation.addByPrefix('confirm', 'right confirm', 24, false);

					addOffset('confirm', -3, 0);
			}
		}

		updateHitbox();

		colorSwap = new ColorSwap();
		shader = colorSwap.shader;
		colorSwap.update(Note.arrowColors[noteData]);
	}

	override function update(elapsed:Float)
	{
		if (resetAnim > 0)
		{
			resetAnim -= elapsed;
			if (resetAnim <= 0)
			{
				playAnim('static');
				resetAnim = 0;
			}
		}

		super.update(elapsed);
	}

	override function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0)
	{
		super.playAnim(AnimName, Force, Reversed, Frame);

		var leOffset:FlxPoint = offset.copyTo();

		centerOffsets();
		centerOrigin();

		offset.addPoint(leOffset);
		origin.addPoint(leOffset);
	}

	public function autoConfirm(time:Float)
	{
		playAnim('confirm', true);
		resetAnim = time;
	}

	public function postAddedToGroup()
	{
		scrollFactor.set();
		playAnim('static');
		x += Note.swagWidth * noteData;
	}
}
