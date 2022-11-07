package;

import shaders.GridPlane;
import shaders.ColorSwap;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.Assets;

using StringTools;

class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	static var curWacky:Array<String>;

	var startedIntro:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var textGroup:FlxGroup;
	var engineLogo:FlxSprite;

	var wackyImage:FlxSprite;

	var lastBeat:Int = 0;

	var swagShader:ColorSwap;

	override public function create():Void
	{
		swagShader = new ColorSwap();

		if (curWacky == null)
			curWacky = FlxG.random.getObject(getIntroTextShit());

		super.create();

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;

	function startIntro()
	{
		if (!initialized)
			CoolUtil.resetMusic(true);

		startedIntro = true;

		Conductor.changeBPM(102);
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		// bg.antialiasing = true;
		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();
		#if !html5
		bg.shader = new GridPlane(30, FlxColor.BLUE).shader;
		#end
		add(bg);

		logoBl = new FlxSprite(-150, -100);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;
		logoBl.shader = swagShader.shader;

		gfDance = new FlxSprite(512, 40);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = true;
		add(gfDance);
		gfDance.shader = swagShader.shader;
		add(logoBl);

		titleText = new FlxSprite(100, 576);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		add(titleText);

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		engineLogo = new FlxSprite(0, 140).loadGraphic(Paths.image('engine_logo'));
		engineLogo.screenCenter(X);
		engineLogo.visible = false;
		engineLogo.antialiasing = true;
		add(engineLogo);

		FlxG.mouse.visible = false;

		if (initialized)
			skipIntro();
		else
			initialized = true;
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
			swagGoodArray.push(i.split('--'));

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	var isRainbow:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (FlxG.keys.justPressed.F)
			FlxG.fullscreen = !FlxG.fullscreen;

		var accept = controls.ACCEPT;

		if (accept && !transitioning && skippedIntro)
		{
			// #if !switch
			// // If it's Friday according to da clock
			// if (Date.now().getDay() == 5)
			// {
			// 	// Unlock Friday medal
			// }
			// #end

			if (titleText != null)
				titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			new FlxTimer().start(2, function(twn:FlxTimer)
			{
				Main.switchState(new MainMenuState());
			});

			// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
		}

		if (accept && !skippedIntro && initialized)
			skipIntro();

		if (controls.UI_LEFT)
			swagShader.update(elapsed * 0.1);
		if (controls.UI_RIGHT)
			swagShader.update(-elapsed * 0.1);

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, yAdd:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, (i * 60) + 200 + yAdd, textArray[i], true, false);
			money.screenCenter(X);
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String, yAdd:Float = 0)
	{
		var coolText:Alphabet = new Alphabet(0, (textGroup.length * 60) + 200 + yAdd, text, true, false);
		coolText.screenCenter(X);
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			var obj = textGroup.members[0];
			obj.kill();
			credGroup.remove(obj, true);
			textGroup.remove(obj, true);
			obj.destroy();
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if (logoBl != null)
			logoBl.animation.play('bump');
		danceLeft = !danceLeft;

		if (gfDance != null)
		{
			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');
		}

		FlxG.log.add(curBeat);

		if (curBeat > lastBeat)
		{
			if (startedIntro)
				for (i in lastBeat...curBeat)
				{
					switch (i + 1)
					{
						case 1:
							createCoolText(['ninjamuffin99', 'phantomarcade', 'kawaisprite', 'evilsk8r']);
						case 3:
							addMoreText('present');
						case 4:
							deleteCoolText();
						case 5:
							engineLogo.visible = true;
							createCoolText(['by stilic'], 180);
						case 7:
							addMoreText('and other people', 180);
						case 8:
							deleteCoolText();
							engineLogo.visible = false;
						case 9:
							createCoolText([curWacky[0]]);
						case 11:
							addMoreText(curWacky[1]);
						case 12:
							deleteCoolText();
						case 13:
							addMoreText('friday');
						case 14:
							addMoreText('night');
						case 15:
							addMoreText('funkin');
						case 16:
							skipIntro();
					}
				}
		}

		lastBeat = curBeat;
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(engineLogo);

			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;
		}
	}
}
