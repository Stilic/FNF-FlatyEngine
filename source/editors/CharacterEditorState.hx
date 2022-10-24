package editors;

import haxe.Json;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUIDropDownMenu;

using StringTools;

class CharacterEditorState extends MusicBeatState
{
	var camGame:FlxCamera;
	var camHUD:FlxCamera;

	var char:Character;
	var camFollow:FlxObject;

	var dumbText:FlxText;
	var textAnim:FlxText;
	var curAnim:Int = 0;

	var UI_box:FlxUITabMenu;

	override function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camGame.bgColor.alpha = 0;
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		FlxG.mouse.visible = true;

		var gridBG:FlxSprite = FlxGridOverlay.create(10, 10, -1, -1, true, FlxColor.fromRGB(48, 48, 48), FlxColor.fromRGB(78, 78, 78));
		gridBG.scrollFactor.set();
		add(gridBG);

		dumbText = new FlxText(5, 10, 0, "", 14);
		dumbText.scrollFactor.set();
		dumbText.setFormat(Paths.font('vcr.ttf'), 18, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		textAnim = new FlxText(300, 16);
		textAnim.scrollFactor.set();
		textAnim.setFormat(Paths.font('vcr.ttf'), 18, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		textAnim.borderSize = 1;
		textAnim.size = 30;

		loadChar();

		dumbText.cameras = [camHUD];
		textAnim.cameras = [camHUD];

		add(dumbText);
		add(textAnim);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.screenCenter();
		add(camFollow);
		FlxG.camera.follow(camFollow);

		UI_box = new FlxUITabMenu(null, null, CoolUtil.makeUITabs(['Character', 'Animations']), null, true);
		UI_box.resize(300, 400);
		UI_box.x = FlxG.width / 1.35;
		UI_box.y = 20;
		UI_box.scrollFactor.set();
		add(UI_box);

		addCharacterUI();
		addAnimationsUI();

		super.create();
	}

	function addCharacterUI()
	{
		var charDropDown = new FlxUIDropDownMenu(10, 10, FlxUIDropDownMenu.makeStrIdLabelArray(CoolUtil.coolTextFile(Paths.txt('characterList')), true),
			loadChar);
		charDropDown.selectedLabel = char.curCharacter;

		var tab_group_character = new FlxUI(null, UI_box);
		tab_group_character.name = 'Character';
		tab_group_character.add(charDropDown);

		UI_box.addGroup(tab_group_character);
	}

	function addAnimationsUI()
	{
	}

	function loadChar(?name:String)
	{
		if (name == null)
		{
			// if (PlayState.SONG != null)
			// 	daAnim = PlayState.SONG.player2;
			// else
			name = 'bf';
		}

		var index:Int = -1;
		if (char != null)
		{
			index = members.indexOf(char);
			char.kill();
			remove(char, true);
			char.destroy();
		}
		char = new Character(0, 0, name, name.startsWith('bf'));
		char.screenCenter();
		char.debugMode = true;
		if (index < 0)
			add(char);
		else
			insert(index, char);

		curAnim = 0;

		regenList();
		playCurAnim();
	}

	function regenList()
	{
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
		dumbText.text = animList;
	}

	function playCurAnim(updateTextAnim:Bool = true)
	{
		var name = char.data.animations[curAnim].name;

		char.playAnim(name, true);

		if (updateTextAnim)
		{
			var anim = char.animation.getByName(name);
			if (anim == null || anim.frames.length < 1)
				name += ' (ERROR!)';
			textAnim.text = name;
		}
	}

	override function update(elapsed:Float)
	{
		var holdShift = FlxG.keys.pressed.SHIFT;

		if (FlxG.keys.justPressed.R)
			FlxG.camera.zoom = 1;

		if (FlxG.keys.pressed.E && FlxG.camera.zoom < 3)
		{
			FlxG.camera.zoom += elapsed * FlxG.camera.zoom;
			if (FlxG.camera.zoom > 3)
				FlxG.camera.zoom = 3;
		}
		if (FlxG.keys.pressed.Q && FlxG.camera.zoom > 0.1)
		{
			FlxG.camera.zoom -= elapsed * FlxG.camera.zoom;
			if (FlxG.camera.zoom < 0.1)
				FlxG.camera.zoom = 0.1;
		}

		if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L)
		{
			var addToCam:Float = 500 * elapsed;
			if (holdShift)
				addToCam *= 4;

			if (FlxG.keys.pressed.I)
				camFollow.y -= addToCam;
			else if (FlxG.keys.pressed.K)
				camFollow.y += addToCam;

			if (FlxG.keys.pressed.J)
				camFollow.x -= addToCam;
			else if (FlxG.keys.pressed.L)
				camFollow.x += addToCam;
		}

		if (char.data.animations.length > 0)
		{
			if (FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.W || FlxG.keys.justPressed.S)
			{
				if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S)
				{
					if (FlxG.keys.justPressed.W)
						curAnim--;
					if (FlxG.keys.justPressed.S)
						curAnim++;

					if (curAnim < 0)
						curAnim = char.data.animations.length - 1;
					if (curAnim >= char.data.animations.length)
						curAnim = 0;
				}

				playCurAnim(!FlxG.keys.justPressed.SPACE);
			}

			var controlArray:Array<Bool> = [
				FlxG.keys.justPressed.LEFT,
				FlxG.keys.justPressed.RIGHT,
				FlxG.keys.justPressed.UP,
				FlxG.keys.justPressed.DOWN
			];
			for (i in 0...controlArray.length)
			{
				if (controlArray[i])
				{
					char.data.animations[curAnim].offset[i > 1 ? 1 : 0] += (i % 2 == 1 ? -1 : 1) * (holdShift ? 10 : 1);

					var anim = char.data.animations[curAnim];
					char.addOffset(anim.name, anim.offset[0], anim.offset[1]);
					char.playAnim(anim.name);
				}
			}
			if (controlArray.contains(true))
				regenList();
		}

		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S)
			save();

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.mouse.visible = false;
			Main.switchState(new PlayState());
		}

		super.update(elapsed);
	}

	function save()
	{
		CoolUtil.openSavePrompt(Json.stringify(char.data, '\t'), char.curCharacter + ".json");
	}
}
