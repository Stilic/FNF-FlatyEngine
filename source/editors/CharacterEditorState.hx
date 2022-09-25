package editors;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using StringTools;

class CharacterEditorState extends MusicBeatState
{
	var char:Character;
	var curAnim:Int = 0;
	var curCharacter:String;
	var camFollow:FlxObject;

	var textAnim:FlxText;

	override function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		var gridBG:FlxSprite = FlxGridOverlay.create(10, 10);
		gridBG.scrollFactor.set(0.5, 0.5);
		add(gridBG);

		textAnim = new FlxText(5, 10, 0, "", 14);
		textAnim.scrollFactor.set();
		textAnim.setFormat("VCR OSD Mono", 18, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		loadChar();

		add(textAnim);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow);

		super.create();
	}

	function loadChar(?daAnim:String)
	{
		if (daAnim == null)
		{
			// if (PlayState.SONG != null)
			// 	daAnim = PlayState.SONG.player2;
			// else
			daAnim = 'bf';
		}
		curCharacter = daAnim;

		var index:Int = -1;
		if (char != null)
		{
			index = members.indexOf(char);
			remove(char);
		}
		char = new Character(0, 0, daAnim, daAnim.startsWith('bf'));
		char.screenCenter();
		char.debugMode = true;
		if (index > -1)
			add(char);
		else
			insert(index, char);

		var animList:String = '';
		for (i in 0...char.data.animations.length)
		{
			var anim = char.data.animations[i];

			animList += anim.name + ' [';

			var anim = char.data.animations[i];
			for (j in 0...2)
			{
				animList += anim.offset[j];
				if (j == 0)
					animList += ', ';
			}
			animList += ']';

			if (i < char.data.animations.length)
				animList += '\n';
		}
		textAnim.text = animList;
	}
}
