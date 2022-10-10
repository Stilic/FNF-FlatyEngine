package;

import flixel.math.FlxRect;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxSignal.FlxTypedSignal;
import ui.PreferencesMenu;
import modchart.ModManager;

class Strumline extends FlxGroup
{
	public var modManager(default, null):ModManager;

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

		modManager = new ModManager();

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

		allNotes.forEachAlive(function(daNote:Note)
		{
			var shouldRemove:Bool = isOutsideScreen(daNote.strumTime);
			daNote.active = !shouldRemove;
			daNote.visible = !shouldRemove;

			var receptor:Receptor = receptors.members[daNote.noteData % receptors.length];

			modManager.setPos(daNote, receptor.x, receptor.y, receptor.direction, receptor.downscroll, PlayState.SONG != null ? PlayState.SONG.speed : 1);

			// i am so fucking sorry for these if conditions
			if (daNote.isSustainNote)
			{
				if (receptor.sustainReduce && (botplay || daNote.wasGoodHit || (daNote.prevNote != null && daNote.prevNote.wasGoodHit)))
				{
					var center:Float = receptor.y + Note.swagWidth / 2;
					if (receptor.downscroll)
					{
						if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
						{
							var swagRect:FlxRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
					else if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
					{
						var swagRect:FlxRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
						swagRect.y = (center - daNote.y) / daNote.scale.y;
						swagRect.height -= swagRect.y;

						daNote.clipRect = swagRect;
					}
				}
			}

			modManager.updateNote(daNote);

			if (onNoteBotHit != null && botplay && daNote.strumTime <= Conductor.songPosition)
				onNoteBotHit.dispatch(daNote);
			if (onNoteUpdate != null)
				onNoteUpdate.dispatch(daNote);

			if (shouldRemove)
				removeNote(daNote);
		});

		receptors.forEachAlive(modManager.updateReceptor);
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
		leGroup.sort(CoolUtil.sortNotes);
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
