package;

import flixel.FlxSprite;
import shaderslmfao.ColorSwap;

using StringTools;

class StrumNote extends FlxSprite
{
	public var noteData:Int;

	public var direction:Float = 90;
	public var sustainReduce:Bool = true;

	var resetAnim:Float = 0;

	var colorSwap:ColorSwap;

	public function new(x:Float, y:Float, noteData:Int)
	{
		super(x, y);

		this.noteData = noteData;

		if (PlayState.curStage.startsWith('school'))
		{
			loadGraphic(Paths.image('pixelUI/arrows-pixels'), true, 17, 17);

			setGraphicSize(Std.int(width * PlayState.daPixelZoom));
			updateHitbox();
			antialiasing = false;

			switch (noteData)
			{
				case 0:
					animation.add('static', [0]);
					animation.add('pressed', [4, 8], 12, false);
					animation.add('confirm', [12, 16], 24, false);
				case 1:
					animation.add('static', [1]);
					animation.add('pressed', [5, 9], 12, false);
					animation.add('confirm', [13, 17], 24, false);
				case 2:
					animation.add('static', [2]);
					animation.add('pressed', [6, 10], 12, false);
					animation.add('confirm', [14, 18], 12, false);
				case 3:
					animation.add('static', [3]);
					animation.add('pressed', [7, 11], 12, false);
					animation.add('confirm', [15, 19], 24, false);
			}
		}
		else
		{
			frames = Paths.getSparrowAtlas('NOTE_assets');

			antialiasing = true;
			setGraphicSize(Std.int(width * 0.7));

			switch (Math.abs(noteData) % 4)
			{
				case 0:
					animation.addByPrefix('static', 'arrowLEFT');
					animation.addByPrefix('pressed', 'left press', 24, false);
					animation.addByPrefix('confirm', 'left confirm', 24, false);
				case 1:
					animation.addByPrefix('static', 'arrowDOWN');
					animation.addByPrefix('pressed', 'down press', 24, false);
					animation.addByPrefix('confirm', 'down confirm', 24, false);
				case 2:
					animation.addByPrefix('static', 'arrowUP');
					animation.addByPrefix('pressed', 'up press', 24, false);
					animation.addByPrefix('confirm', 'up confirm', 24, false);
				case 3:
					animation.addByPrefix('static', 'arrowRIGHT');
					animation.addByPrefix('pressed', 'right press', 24, false);
					animation.addByPrefix('confirm', 'right confirm', 24, false);
			}
		}

		updateHitbox();

		colorSwap = new ColorSwap();
		shader = colorSwap.shader;
		updateColors();
	}

	function updateColors()
	{
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

		if (animation.curAnim.name == 'confirm' && !PlayState.curStage.startsWith('school'))
			centerOrigin();

		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false)
	{
		animation.play(anim, force);
		centerOffsets();
		centerOrigin();
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
		ID = noteData;
	}
}
