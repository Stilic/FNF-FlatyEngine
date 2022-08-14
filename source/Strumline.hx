package;

import ui.PreferencesMenu;
import flixel.math.FlxMath;
import flixel.util.FlxSort;
import flixel.math.FlxRect;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

using StringTools;

class Strumline extends FlxGroup
{
	public var strumsGroup:FlxTypedGroup<StrumNote>;

	public var allNotes:FlxTypedGroup<Note>;
	public var notesGroup:FlxTypedGroup<Note>;
	public var holdsGroup:FlxTypedGroup<Note>;

	public var splashesGroup:FlxTypedGroup<NoteSplash>;

	public var downscroll:Bool;

	public var onNoteUpdate:Note->Void;

	inline public static function isOutsideScreen(strumTime:Float)
	{
		return Conductor.songPosition > 350 * FlxMath.roundDecimal(PlayState.SONG.speed, 2) + strumTime;
	}

	public function new(x:Float, y:Float, downscroll:Bool, splashes:Bool = false, keyCount:Int = 4)
	{
		super();

		this.downscroll = downscroll;

		var smClipStyle:Bool = PreferencesMenu.getPref('sm-clip');

		if (smClipStyle)
		{
			holdsGroup = new FlxTypedGroup<Note>();
			add(holdsGroup);
		}

		strumsGroup = new FlxTypedGroup<StrumNote>();
		add(strumsGroup);

		for (i in 0...keyCount)
		{
			var babyArrow:StrumNote = new StrumNote(x, y, i);
			strumsGroup.add(babyArrow);
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

		var scrollMult:Int = downscroll ? -1 : 1;
		allNotes.forEachAlive(function(daNote:Note)
		{
			var isOutsideScreen:Bool = isOutsideScreen(daNote.strumTime);
			daNote.active = !isOutsideScreen;
			daNote.visible = !isOutsideScreen;

			var strum:StrumNote = strumsGroup.members[Std.int(Math.abs(daNote.noteData))];
			var angleDir:Float = (strum.direction * Math.PI) / 180;

			daNote.distance = (-0.45 * scrollMult) * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayState.SONG.speed, 2);

			if (daNote.copyX)
				daNote.x = (strum.x + daNote.offsetX) + Math.cos(angleDir) * daNote.distance;
			if (daNote.copyY)
				daNote.y = (strum.y + daNote.offsetY) + Math.sin(angleDir) * daNote.distance;
			if (daNote.copyAngle)
				daNote.angle = strum.direction - 90 + strum.angle + daNote.offsetAngle;
			if (daNote.copyAlpha)
				daNote.alpha = strum.alpha * daNote.multAlpha;

			// i am so fucking sorry for these if conditions
			if (daNote.isSustainNote)
			{
				if (daNote.copyY)
				{
					daNote.y -= (daNote.height / 2) * scrollMult;
					if (daNote.animation.curAnim.name.endsWith('holdend') && daNote.prevNote != null)
					{
						daNote.y -= (daNote.prevNote.height / 2) * scrollMult;
						if (downscroll)
						{
							daNote.y += daNote.height * 2;
							if (daNote.endHoldOffset == Math.NEGATIVE_INFINITY)
								daNote.endHoldOffset = daNote.prevNote.y - (daNote.y + daNote.height) + 2;
							else
								daNote.y += daNote.endHoldOffset;
						}
						else
							daNote.y += (daNote.height / 2) * scrollMult;
						if (!daNote.prevNote.isSustainNote)
						{
							var offset:Float = 3.25;
							if (downscroll)
								daNote.y += daNote.height / offset;
							else
								daNote.y += daNote.height * (offset / 2);
						}
					}
				}

				if (strum.sustainReduce)
				{
					var center:Float = strum.y + (Note.swagWidth / 2);
					if (downscroll)
					{
						if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
							&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
					else
					{
						if (daNote.isSustainNote
							&& daNote.y + daNote.offset.y * daNote.scale.y <= center
							&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
						{
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = (center - daNote.y) / daNote.scale.y;
							swagRect.height -= swagRect.y;

							daNote.clipRect = swagRect;
						}
					}
				}
			}

			if (onNoteUpdate != null)
				onNoteUpdate(daNote);

			if (isOutsideScreen)
				removeNote(daNote);
		});
	}

	public function addNote(daNote:Note)
	{
		allNotes.add(daNote);
		var leGroup:FlxTypedGroup<Note>;
		if (daNote.isSustainNote)
			leGroup = holdsGroup;
		else
			leGroup = notesGroup;
		leGroup.add(daNote);
		leGroup.sort(FlxSort.byY, downscroll ? FlxSort.DESCENDING : FlxSort.ASCENDING);
	}

	public function removeNote(daNote:Note)
	{
		daNote.kill();
		allNotes.remove(daNote, true);
		if (daNote.isSustainNote)
			holdsGroup.remove(daNote, true);
		else
			notesGroup.remove(daNote, true);
		daNote.destroy();
	}

	public function tweenStrums()
	{
		strumsGroup.forEachAlive(function(strum:StrumNote)
		{
			strum.y -= 10;
			strum.alpha = 0;
			FlxTween.tween(strum, {y: strum.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * strum.noteData)});
		});
	}

	public function spawnSplash(noteData:Int)
	{
		var strum:StrumNote = strumsGroup.members[noteData];
		var splash:NoteSplash = splashesGroup.recycle(NoteSplash);
		splash.setupNoteSplash(strum.x, strum.y, noteData);
		splashesGroup.add(splash);
	}
}
