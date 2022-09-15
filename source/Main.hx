package;

#if CRASH_HANDLER
import haxe.CallStack;
import sys.io.File;
import sys.FileSystem;
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
import ui.PreferencesMenu;

using StringTools;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = StartState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 120; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

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
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if polymod
		ModHandler.init();
		#end

		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));

		FlxG.mouse.visible = false;

		#if !mobile
		fpsCounter = new CoolCounter(8, 3, 0xFFFFFF);
		addChild(fpsCounter);
		#end

		// we load the preferences here in order to make the counter stuff working
		PreferencesMenu.initPrefs();

		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end
	}

	#if CRASH_HANDLER
	static final crashHandlerDirectory:String = './crash';

	// crash handler made by sqirra-rng
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = '';

		for (stackItem in CallStack.exceptionStack(true))
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + ' (line ' + line + ')\n';
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += '\nUncaught Error: ' + e.error + '\nPlease report this error to the GitHub page: https://github.com/Stilic/FNF-SoftieEngine';

		if (!FileSystem.exists(crashHandlerDirectory))
			FileSystem.createDirectory(crashHandlerDirectory);
		File.saveContent(crashHandlerDirectory + '/' + Date.now().toString().replace(' ', '_').replace(':', "'") + '.txt', errMsg + '\n');

		Sys.println(errMsg);
		Application.current.window.alert(errMsg, 'Error!');

		DiscordClient.shutdown();
		Sys.exit(1);
	}
	#end
}
