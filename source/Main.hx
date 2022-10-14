package;

#if cpp
import cpp.NativeGc;
#end
#if CRASH_HANDLER
import haxe.CallStack;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
#end
#if discord_rpc
import Discord.DiscordClient;
#end
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import ui.PreferencesMenu;

using StringTools;

class Main extends Sprite
{
	static final gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	static final gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	static final initialState:Class<FlxState> = StartState; // The FlxState the game starts with.
	static final framerate:Int = 120; // How many frames per second the game should run at.
	static final skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	static final startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	#if !mobile
	public static var fpsCounter:CoolCounter;
	#end

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
			init();
		else
			addEventListener(Event.ADDED_TO_STAGE, init);
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);

		#if polymod
		ModHandler.init();
		#end

		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		var zoom:Float = Math.min(stageWidth / gameWidth, stageHeight / gameHeight);
		addChild(new FlxGame(Math.ceil(stageWidth / zoom), Math.ceil(stageHeight / zoom), initialState, zoom, framerate, framerate, skipSplash,
			startFullscreen));

		FlxG.mouse.visible = false;

		#if !mobile
		fpsCounter = new CoolCounter();
		addChild(fpsCounter);
		#end

		// we load the preferences here in order to make the counter stuff working
		PreferencesMenu.initPrefs();

		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end
	}

	public static function switchState(nextState:FlxState)
	{
		var callback = function()
		{
			if (nextState == FlxG.state)
				FlxG.resetState();
			else
				FlxG.switchState(nextState);
		};
		if (!FlxTransitionableState.skipNextTransIn)
		{
			var state = FlxG.state;
			while (state.subState != null)
				state = state.subState;
			state.openSubState(new FadeSubstate(0.5, false, callback));
			FlxTransitionableState.skipNextTransIn = false;
		}
		else
			callback();
	}

	inline public static function resetState()
	{
		switchState(FlxG.state);
	}

	#if CRASH_HANDLER
	static final crashHandlerDirectory:String = './crash';

	// crash handler made by sqirra-rng
	static function onCrash(e:UncaughtErrorEvent):Void
	{
		if (FlxG.sound != null)
			FlxG.sound.destroy(true);

		#if discord_rpc
		DiscordClient.shutdown();
		#end

		var errMsg:String = '';

		for (stackItem in CallStack.exceptionStack(true))
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += '$file:$line\n';
				default:
					CoolUtil.nativeTrace(stackItem);
			}
		}

		errMsg += '\nUncaught Error: ' + e.error + '\nPlease report this error to the GitHub issues page: https://github.com/Stilic/FNF-FlatyEngine/issues';

		#if sys
		if (!FileSystem.exists(crashHandlerDirectory))
			FileSystem.createDirectory(crashHandlerDirectory);
		File.saveContent(crashHandlerDirectory + '/' + Date.now().toString().replace(' ', '_').replace(':', "'") + '.txt', errMsg + '\n');
		#end

		CoolUtil.nativeTrace(errMsg);
		Application.current.window.alert(errMsg, 'Error!');

		#if sys
		Sys.exit(1);
		#else
		Application.current.window.close();
		#end
	}
	#end
}
