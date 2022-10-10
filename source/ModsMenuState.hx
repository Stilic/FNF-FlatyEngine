package;

#if discord_rpc
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.display.BitmapData;

using StringTools;

class ModsMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var changedSomethin:Bool = false;

	var bg:FlxSprite;
	var scoreBG:FlxSprite;
	var scoreText:FlxText;

	private var grpText:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];

	override function create()
	{
		#if discord_rpc
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (FlxG.sound.music == null || !FlxG.sound.music.playing)
			CoolUtil.resetMusic();

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);

		grpText = new FlxTypedGroup<Alphabet>();
		add(grpText);

		ModHandler.reloadModList();

		if (ModHandler.modList.length > 0)
		{
			for (i in 0...ModHandler.modList.length)
			{
				var text:Alphabet = new Alphabet(0, (70 * i) + 30, ModHandler.modList[i].metadata.title, true, false);
				text.isMenuItem = true;
				text.targetY = i;
				grpText.add(text);

				if (ModHandler.modList[i].metadata.icon != null)
				{
					var icon:AttachedSprite = new AttachedSprite(text);
					icon.loadGraphic(BitmapData.fromBytes(ModHandler.modList[i].metadata.icon));

					// using a FlxGroup is too much fuss!
					iconArray.push(icon);
					add(icon);
				}
			}

			scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
			// scoreText.autoSize = false;
			scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
			// scoreText.alignment = RIGHT;

			scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
			scoreBG.antialiasing = false;
			scoreBG.alpha = 0.6;
			add(scoreBG);

			add(scoreText);

			changeSelection();
		}

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (ModHandler.modList.length > 0)
		{
			scoreText.text = ModHandler.modList[curSelected].enabled ? "ENABLED" : "DISABLED";
			positionHighscore();

			if (controls.UI_UP_P)
				changeSelection(-1);
			if (controls.UI_DOWN_P)
				changeSelection(1);

			if (controls.ACCEPT)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				ModHandler.modList[curSelected].enabled = !ModHandler.modList[curSelected].enabled;
				ModHandler.saveModList();
			}
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound("cancelMenu"));
			Main.switchState(new MainMenuState());
		}
	}

	override function destroy()
	{
		ModHandler.reloadPolymod();
		super.destroy();
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = ModHandler.modList.length - 1;
		if (curSelected >= ModHandler.modList.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		if (iconArray[curSelected] != null)
			iconArray[curSelected].alpha = 1;

		for (item in grpText.members)
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

	function positionHighscore()
	{
		scoreText.x = FlxG.width - scoreText.width - 6;
		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - scoreBG.scale.x / 2;
	}
}
