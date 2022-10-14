package;

import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxSignal.FlxTypedSignal;
import ui.PreferencesMenu;

using StringTools;

class Receptor extends FNFSprite
{
	public var noteData:Int;

	public var direction:Float = 90;
	public var downscroll:Bool = false;
	public var sustainReduce:Bool = true;

	var resetAnim:Float = 0;

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

					addOffset('confirm', -3, -1.5);
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
		offset.addPoint(leOffset);
		centerOrigin();
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

class Strumline extends FlxGroup
{
	public var receptors(default, null):FlxTypedGroup<Receptor>;

	public var allNotes(default, null):FlxTypedGroup<Note>;
	public var notesGroup(default, null):FlxTypedGroup<Note>;
	public var holdsGroup(default, null):FlxTypedGroup<Note>;

	public var splashesGroup(default, null):FlxTypedGroup<NoteSplash>;

	public var botplay:Bool = false;

	public var onNoteBotHit(default, null):FlxTypedSignal<Note->Void> = new FlxTypedSignal<Note->Void>();
	public var onNoteUpdate(default, null):FlxTypedSignal<Note->Void> = new FlxTypedSignal<Note->Void>();

	public var characters:Array<Character> = [];
	public var singingCharacters:Array<Character> = [];

	inline public static function isOutsideScreen(strumTime:Float)
	{
		return Conductor.songPosition > 350 / PlayState.SONG.speed + strumTime;
	}

	public function new(x:Float, y:Float, downscroll:Bool, botplay:Bool = false)
	{
		super();

		this.botplay = botplay;

		var smClipStyle:Bool = PreferencesMenu.getPref('sm-clip');

		if (smClipStyle)
		{
			holdsGroup = new FlxTypedGroup<Note>();
			add(holdsGroup);
		}

		receptors = new FlxTypedGroup<Receptor>();
		add(receptors);

		for (i in 0...4)
		{
			var babyArrow:Receptor = new Receptor(x, y, i, downscroll);
			receptors.add(babyArrow);
			babyArrow.postAddedToGroup();
		}

		allNotes = new FlxTypedGroup<Note>();

		if (!smClipStyle)
		{
			holdsGroup = new FlxTypedGroup<Note>();
			add(holdsGroup);
		}

		notesGroup = new FlxTypedGroup<Note>();
		add(notesGroup);

		splashesGroup = new FlxTypedGroup<NoteSplash>();
		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		splash.alpha = 0.00001;

		add(splashesGroup);
		splashesGroup.add(splash);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var roundedSpeed:Float = FlxMath.roundDecimal(PlayState.SONG.speed, 2);
		allNotes.forEachAlive(function(note:Note)
		{
			var shouldRemove:Bool = isOutsideScreen(note.strumTime);
			note.active = !shouldRemove;
			note.visible = !shouldRemove;

			var receptor:Receptor = receptors.members[note.noteData % receptors.length];
			var scrollMult:Int = receptor.downscroll ? 1 : -1;
			var distance:Float = (Conductor.songPosition - note.strumTime) * (0.45 * roundedSpeed) * scrollMult;
			var angleDir:Float = (receptor.direction * Math.PI) / 180;

			note.x = receptor.x + note.offsetX + Math.cos(angleDir) * distance;
			note.y = receptor.y + note.offsetY + Math.sin(angleDir) * distance;

			if (note.isSustainNote)
			{
				var yFix:Float = Note.swagWidth / 10;
				if (receptor.downscroll)
					yFix += note.height / 1.6;
				yFix /= roundedSpeed;
				note.y += yFix * scrollMult;

				if (receptor.downscroll && note.isSustainEnd && note.prevNote != null)
				{
					if (note.sustainEndOffset == Math.NEGATIVE_INFINITY)
					{
						note.sustainEndOffset = (note.prevNote.y - (note.y + note.height - 1));
						if (!note.prevNote.isSustainNote)
							note.sustainEndOffset += note.height / 1.25;
					}
					note.y += note.sustainEndOffset;
				}
			}

			if (note.copyAngle)
				note.angle = receptor.direction - 90 + receptor.angle + note.offsetAngle;

			// i am so fucking sorry for these if conditions
			if (note.isSustainNote)
			{
				if (receptor.sustainReduce && (botplay || note.wasGoodHit || (note.prevNote != null && note.prevNote.wasGoodHit)))
				{
					var center:Float = receptor.y + Note.swagWidth / 2;
					if (receptor.downscroll)
					{
						if (note.y - note.offset.y * note.scale.y + note.height >= center)
						{
							var swagRect:FlxRect = new FlxRect(0, 0, note.frameWidth, note.frameHeight);
							swagRect.height = (center - note.y) / note.scale.y;
							swagRect.y = note.frameHeight - swagRect.height;

							note.clipRect = swagRect;
						}
					}
					else if (note.y + note.offset.y * note.scale.y <= center)
					{
						var swagRect:FlxRect = new FlxRect(0, 0, note.width / note.scale.x, note.height / note.scale.y);
						swagRect.y = (center - note.y) / note.scale.y;
						swagRect.height -= swagRect.y;

						note.clipRect = swagRect;
					}
				}
			}

			if (botplay && ((!note.isSustainNote && note.strumTime <= Conductor.songPosition) || (note.isSustainNote && note.canBeHit)))
				onNoteBotHit.dispatch(note);
			onNoteUpdate.dispatch(note);

			if (shouldRemove)
				removeNote(note);
		});
	}

	public function addNote(note:Note)
	{
		allNotes.add(note);
		var leGroup:FlxTypedGroup<Note>;
		if (note.isSustainNote)
			leGroup = holdsGroup;
		else
			leGroup = notesGroup;
		leGroup.add(note);
		leGroup.sort(CoolUtil.sortNotes);
	}

	public function removeNote(note:Note)
	{
		if (note.alive)
		{
			note.kill();
			allNotes.remove(note, true);
			if (note.isSustainNote)
				holdsGroup.remove(note, true);
			else
				notesGroup.remove(note, true);
			note.destroy();
		}
	}

	public function tweenStrums()
	{
		receptors.forEachAlive(function(receptor:Receptor)
		{
			receptor.y -= 10;
			receptor.alpha = 0;
			FlxTween.tween(receptor, {y: receptor.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * receptor.noteData)});
		});
	}

	public function spawnSplash(noteData:Int)
	{
		var receptor:Receptor = receptors.members[noteData];
		var splash:NoteSplash = splashesGroup.recycle(NoteSplash);
		splash.setupNoteSplash(receptor.x, receptor.y, noteData);
		splashesGroup.add(splash);
	}
}
