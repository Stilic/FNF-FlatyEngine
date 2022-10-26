package;

#if discord_rpc
import lime.app.Application;
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;

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
		FlxG.mouse.useSystemCursor = true;

		// WEEK UNLOCK PROGRESSION!!
		if (FlxG.save.data.weekUnlocked != null)
		{
			if (StoryMenuState.weekUnlocked.length < 4)
				StoryMenuState.weekUnlocked.insert(0, true);

			// QUICK PATCH OOPS!
			if (!StoryMenuState.weekUnlocked[0])
				StoryMenuState.weekUnlocked[0] = true;
		}

		// gets your volume setting
		if (FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;

		#if discord_rpc
		DiscordClient.initialize();
		if (!Application.current.onExit.has(onExit))
			Application.current.onExit.add(onExit);
		#end

		if (!FlxG.signals.preStateCreate.has(onStateCreate))
			FlxG.signals.preStateCreate.add(onStateCreate);

		super.create();

		FlxTransitionableState.skipNextTransOut = true;
		FlxG.switchState(new TitleState());
		// LoadingState.loadAndSwitchState(new editors.CharacterEditorState());

		FlxG.mouse.visible = false;
	}

	#if discord_rpc
	static function onExit(exitCode:Int)
	{
		DiscordClient.shutdown();
	}
	#end

	static function onStateCreate(state:FlxState)
	{
		if (!Std.isOfType(state, PlayState)
			&& !Std.isOfType(state, editors.ChartingState)
			&& !Std.isOfType(state, editors.CharacterEditorState))
		{
			Cache.clear();
		}
	}
}
