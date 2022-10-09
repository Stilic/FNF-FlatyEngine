package;

#if discord_rpc
import lime.app.Application;
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxState;

class StartState extends FlxState
{
	override function create()
	{
		#if windows
		NativeUtil.enableDarkMode();
		#end

		FlxG.save.bind('funkin', 'ninjamuffin99');

		PlayerSettings.init();
		Highscore.load();

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = [ZERO];
		FlxG.keys.preventDefaultKeys = [TAB];

		// WEEK UNLOCK PROGRESSION!!
		if (FlxG.save.data.weekUnlocked != null)
		{
			if (StoryMenuState.weekUnlocked.length < 4)
				StoryMenuState.weekUnlocked.insert(0, true);

			// QUICK PATCH OOPS!
			if (!StoryMenuState.weekUnlocked[0])
				StoryMenuState.weekUnlocked[0] = true;
		}

		// saves your volume setting
		if (FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;

		#if discord_rpc
		DiscordClient.initialize();
		Application.current.onExit.add(function(exitCode)
		{
			DiscordClient.shutdown();
		});
		#end

		FlxG.signals.preStateCreate.add(function(state:FlxState)
		{
			if (!Std.isOfType(state, PlayState)
				&& !Std.isOfType(state, editors.ChartingState)
				&& !Std.isOfType(state, editors.CharacterEditorState))
			{
				Cache.clear();
			}
		});

		super.create();

		FlxG.switchState(new TitleState());
	}
}
