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
	static var discordInitialized:Bool = false;

	override function create()
	{
		#if windows
		NativeUtil.enableDarkMode();
		#end

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

		#if discord_rpc
		DiscordClient.initialize();
		if (!Application.current.window.onClose.has(DiscordClient.shutdown))
			Application.current.window.onClose.add(DiscordClient.shutdown);
		#end

		if (!FlxG.signals.preStateCreate.has(onStateCreate))
			FlxG.signals.preStateCreate.add(onStateCreate);

		super.create();

		FlxTransitionableState.skipNextTransOut = true;
		FlxG.switchState(new TitleState());

		FlxG.mouse.visible = false;
	}

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
