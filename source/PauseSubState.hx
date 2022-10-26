package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class PauseSubState extends MusicBeatSubstate
{
	// do not make this static
	final pauseOG:Array<String> = ['Resume', 'Restart Song', 'Exit to menu'];

	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var difficultyChoices:Array<String> = [];

	var menuItems:Array<String> = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	var practiceText:FlxText;

	public function new()
	{
		super();

		menuItems = pauseOG;

		// make sure that you aren't cheating
		if (!PlayState.isStoryMode)
		{
			for (i in CoolUtil.difficultyArray)
				difficultyChoices.push(i);

			if (difficultyChoices.length > 1) // no need to show the button if there's only a single difficulty;
			{
				menuItems.insert(2, 'Change Difficulty');
				difficultyChoices.push('BACK');
			}

			menuItems.insert(3, 'Toggle Practice Mode');
		}

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, PlayState.SONG.song, 32);
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, CoolUtil.difficultyString(), 32);
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var deathCounter:FlxText = new FlxText(20, 15 + 64, 0, 'Blue balled: ' + PlayState.deathCounter, 32);
		deathCounter.scrollFactor.set();
		deathCounter.setFormat(Paths.font('vcr.ttf'), 32);
		deathCounter.updateHitbox();
		add(deathCounter);

		practiceText = new FlxText(20, 15 + 96, 0, "PRACTICE MODE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('vcr.ttf'), 32);
		practiceText.updateHitbox();
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.visible = PlayState.practiceMode;
		add(practiceText);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;
		deathCounter.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		deathCounter.x = FlxG.width - (deathCounter.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(deathCounter, {alpha: 1, y: deathCounter.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		regenMenu();
	}

	private function regenMenu()
	{
		// kill and destroy all the existing items inside the item group;
		grpMenuShit.forEachAlive(function(item:Alphabet)
		{
			item.kill();
			grpMenuShit.remove(item, true);
			item.destroy();
		});

		// generate the new menu items;
		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		curSelected = 0;
		changeSelection();
	}

	var cantUnpause:Float = 0.1;

	override function update(elapsed:Float)
	{
		cantUnpause -= elapsed;

		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		if (controls.UI_UP_P)
			changeSelection(-1);
		if (controls.UI_DOWN_P)
			changeSelection(1);

		if (controls.ACCEPT && cantUnpause <= 0)
		{
			var daSelected:String = menuItems[curSelected];

			if (menuItems == difficultyChoices && daSelected != 'BACK' && difficultyChoices.contains(daSelected))
			{
				try
				{
					PlayState.SONG = Song.loadFromJson(PlayState.SONG.song.toLowerCase(),
						Highscore.formatSong(PlayState.SONG.song.toLowerCase(), curSelected));
					PlayState.storyDifficulty = curSelected;
					Main.switchState(new PlayState());
				}
				catch (_)
				{
					menuItems = pauseOG;
					regenMenu();
				}
			}
			else
			{
				switch (daSelected)
				{
					case "Resume":
						close();
					case "Restart Song":
						Main.resetState();
					case "Change Difficulty":
						menuItems = difficultyChoices;
						regenMenu();
					case "Toggle Practice Mode":
						PlayState.practiceMode = !PlayState.practiceMode;
						practiceText.visible = PlayState.practiceMode;
					case "Exit to menu":
						PlayState.seenCutscene = false;
						PlayState.deathCounter = 0;
						if (PlayState.isStoryMode)
							Main.switchState(new StoryMenuState());
						else
							Main.switchState(new FreeplayState());
						#if NO_PRELOAD_ALL
						CoolUtil.resetMusic();
						#end

					case "BACK":
						menuItems = pauseOG;
						regenMenu();
				}
			}
		}
	}

	override function destroy()
	{
		pauseMusic.kill();
		FlxG.sound.list.remove(pauseMusic, true);
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
