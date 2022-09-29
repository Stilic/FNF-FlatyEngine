package;

import ui.PreferencesMenu;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubstate extends MusicBeatSubstate
{
	public static var character:String = 'bf';
	public static var lossSound:String = 'fnf_loss_sfx';
	public static var startMusic:String = 'gameOver';
	public static var endMusic:String = 'gameOverEnd';

	var bf:Boyfriend;
	var camGame:FNFCamera;

	var randomGameover:String;
	var playingDeathSound:Bool = false;

	public static function resetVariables()
	{
		switch (PlayState.curStage)
		{
			case 'school' | 'schoolEvil':
				character = 'bf-pixel-dead';
				lossSound = 'fnf_loss_sfx-pixel';
				startMusic = 'gameOver-pixel';
				endMusic = 'gameOverEnd-pixel';
			default:
				character = 'bf';
				lossSound = 'fnf_loss_sfx';
				startMusic = 'gameOver';
				endMusic = 'gameOverEnd';
		}
		if (PlayState.SONG.song.toLowerCase() == 'stress')
			character = 'bf-holding-gf-dead';
	}

	public function new(x:Float, y:Float)
	{
		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, character);
		add(bf);

		camGame = cast FlxG.camera;
		camGame.camFollow.copyFrom(bf.getGraphicMidpoint());

		FlxG.sound.play(Paths.sound(lossSound));
		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		camGame.scroll.set();
		camGame.target.setPosition(camGame.scroll.x + (camGame.width / 2), camGame.scroll.y + (camGame.height / 2));
		camGame.target = null;
		camGame.lerp = 0.01;

		bf.playAnim('firstDeath');

		// CACHE RANDOM GAMEOVER SOUND
		var exclude:Array<Int> = [];
		if (PreferencesMenu.getPref('censor-naughty'))
			exclude = [1, 3, 8, 13, 17, 21];
		randomGameover = 'jeffGameover/jeffGameover-' + FlxG.random.int(1, 25, exclude);
		Paths.sound(randomGameover);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;

			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				MusicBeatState.switchState(new StoryMenuState());
			else
				MusicBeatState.switchState(new FreeplayState());
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			camGame.resetTarget();
		}

		if (PlayState.storyWeek == 7)
		{
			if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished && !playingDeathSound)
			{
				playingDeathSound = true;
				bf.startedDeath = true;
				coolStartDeath(0.2);
				FlxG.sound.play(Paths.sound(randomGameover), 1, false, null, true, function()
				{
					FlxG.sound.music.fadeIn(4, 0.2, 1);
				});
			}
		}
		else if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			bf.startedDeath = true;
			coolStartDeath();
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	function coolStartDeath(startVol:Float = 1)
	{
		FlxG.sound.playMusic(Paths.music(startMusic), startVol);
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(endMusic));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				camGame.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
