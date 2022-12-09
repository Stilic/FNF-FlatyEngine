package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class OutdatedSubState extends MusicBeatState
{
	public static var leftState:Bool = false;

	override function create()
	{
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"HEY! You're running an outdated version of the game!\nCurrent version is v"
			+ FlxG.stage.application.meta.get('version')
			+ " while the most recent version is "
			+ "v0.2.8" // might use the GitHub API later to check the version based on NinjaMuffin99's latest tag since I tore out the NG API
			+ "! Press Space to go to itch.io, or ESCAPE to ignore this!!", 32);
		txt.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		txt.antialiasing = PreferencesMenu.getPref('antialiasing');
		add(txt);
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT)
		{
			CoolUtil.openURL("https://ninja-muffin24.itch.io/funkin");
		}
		if (controls.BACK)
		{
			leftState = true;
			Main.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}
}
