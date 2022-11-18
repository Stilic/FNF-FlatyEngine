package;

import haxe.Json;
import ui.PreferencesMenu;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxColor;
import openfl.utils.Assets;

using StringTools;

typedef CharacterAnimation =
{
	var name:String;
	var prefix:String;
	var ?fps:Int;
	var ?loop:Bool;
	var ?flipX:Bool;
	var ?flipY:Bool;
	var ?indices:Array<Int>;
	var ?offset:Array<Float>;
}

typedef CharacterData =
{
	var imagePath:String;
	var ?scale:Float;
	var ?antialiasing:Bool;
	var ?flipX:Bool;
	var ?flipY:Bool;
	var ?singDuration:Int;
	var ?iconPath:String;
	var ?iconColor:Array<Int>;
	var animations:Array<CharacterAnimation>;
}

class Character extends FNFSprite
{
	public static final singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var data(default, null):CharacterData;

	public var debugMode:Bool = false;

	public var isPlayer(default, null):Bool;
	public var curCharacter(default, null):String;

	public var singDuration:Float = 4;
	public var danceSpeed:Int;

	public var holdTimer:Float = 0;
	public var noHoldDance:Bool = false;
	public var holding:Bool = false;

	public var simpleIdle(get, never):Bool;

	public function get_simpleIdle()
		return !animation.exists('danceLeft') && !animation.exists('danceRight');

	var animationNotes:Array<Dynamic> = [];

	public var cameraMove:Bool;
	public var cameraMoveAdd:Float = 15;
	public var cameraMoveArray:Array<Float>;

	public var startedDeath:Bool = false;

	public var blockDance:Bool = false;

	public function new(x:Float, y:Float, character:String = "bf", isPlayer:Bool = false)
	{
		super(x, y);

		curCharacter = character;
		this.isPlayer = isPlayer;

		cameraMove = PreferencesMenu.getPref('camera-follow-char');

		var tex:FlxAtlasFrames;
		antialiasing = true;

		switch (curCharacter)
		{
			case 'gf':
				// GIRLFRIEND CODE
				tex = Paths.getSparrowAtlas('characters/GF_assets');
				frames = tex;
				quickAnimAdd('cheer', 'GF Cheer');
				quickAnimAdd('singLEFT', 'GF left note');
				quickAnimAdd('singRIGHT', 'GF Right Note');
				quickAnimAdd('singUP', 'GF Up Note');
				quickAnimAdd('singDOWN', 'GF Down Note');
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, true);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24, true);

				loadOffsetFile(curCharacter);

				playAnim('danceRight');

			case 'gf-christmas':
				tex = Paths.getSparrowAtlas('characters/gfChristmas');
				frames = tex;
				quickAnimAdd('cheer', 'GF Cheer');
				quickAnimAdd('singLEFT', 'GF left note');
				quickAnimAdd('singRIGHT', 'GF Right Note');
				quickAnimAdd('singUP', 'GF Up Note');
				quickAnimAdd('singDOWN', 'GF Down Note');
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24, true);

				loadOffsetFile(curCharacter);

				playAnim('danceRight');

			case 'gf-car':
				tex = Paths.getSparrowAtlas('characters/gfCar');
				frames = tex;
				animation.addByIndices('singUP', 'GF Dancing Beat Hair blowing CAR', [0], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat Hair blowing CAR', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat Hair blowing CAR', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24,
					false);
				animation.addByIndices('idleHair', 'GF Dancing Beat Hair blowing CAR', [10, 11, 12, 25, 26, 27], "", 24, true);

				loadOffsetFile(curCharacter);

				playAnim('danceRight');

			case 'gf-pixel':
				tex = Paths.getSparrowAtlas('characters/gfPixel');
				frames = tex;
				animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
				animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				loadOffsetFile(curCharacter);

				playAnim('danceRight');

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
				antialiasing = false;

			case 'gf-tankmen':
				frames = Paths.getSparrowAtlas('characters/gfTankmen');
				animation.addByIndices('sad', 'GF Crying at Gunpoint', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, true);
				animation.addByIndices('danceLeft', 'GF Dancing at Gunpoint', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing at Gunpoint', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				loadOffsetFile('gf');

				playAnim('danceRight');

			case 'dad':
				// DAD ANIMATION LOADING CODE
				tex = Paths.getSparrowAtlas('characters/DADDY_DEAREST');
				frames = tex;
				quickAnimAdd('idle', 'Dad idle dance');
				quickAnimAdd('singUP', 'Dad Sing Note UP');
				quickAnimAdd('singRIGHT', 'Dad Sing Note RIGHT');
				quickAnimAdd('singDOWN', 'Dad Sing Note DOWN');
				quickAnimAdd('singLEFT', 'Dad Sing Note LEFT');

				singDuration = 6.1;

				loadOffsetFile(curCharacter);

				playAnim('idle');
			case 'spooky':
				tex = Paths.getSparrowAtlas('characters/spooky_kids_assets');
				frames = tex;
				quickAnimAdd('singUP', 'spooky UP NOTE');
				quickAnimAdd('singDOWN', 'spooky DOWN note');
				quickAnimAdd('singLEFT', 'note sing left');
				quickAnimAdd('singRIGHT', 'spooky sing right');
				animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
				animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);

				loadOffsetFile(curCharacter);

				playAnim('danceRight');
			case 'mom':
				tex = Paths.getSparrowAtlas('characters/Mom_Assets');
				frames = tex;

				quickAnimAdd('idle', "Mom Idle");
				quickAnimAdd('singUP', "Mom Up Pose");
				quickAnimAdd('singDOWN', "MOM DOWN POSE");
				quickAnimAdd('singLEFT', 'Mom Left Pose');
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				quickAnimAdd('singRIGHT', 'Mom Pose Left');

				loadOffsetFile(curCharacter);

				playAnim('idle');

			case 'mom-car':
				tex = Paths.getSparrowAtlas('characters/momCar');
				frames = tex;

				quickAnimAdd('idle', "Mom Idle");
				quickAnimAdd('singUP', "Mom Up Pose");
				quickAnimAdd('singDOWN', "MOM DOWN POSE");
				quickAnimAdd('singLEFT', 'Mom Left Pose');
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				quickAnimAdd('singRIGHT', 'Mom Pose Left');
				animation.addByIndices('idleHair', 'Mom Idle', [10, 11, 12, 13], '', 24, true);

				loadOffsetFile(curCharacter);

				playAnim('idle');
			case 'monster':
				tex = Paths.getSparrowAtlas('characters/Monster_Assets');
				frames = tex;
				quickAnimAdd('idle', 'monster idle');
				quickAnimAdd('singUP', 'monster up note');
				quickAnimAdd('singDOWN', 'monster down');
				quickAnimAdd('singLEFT', 'Monster left note');
				quickAnimAdd('singRIGHT', 'Monster Right note');

				loadOffsetFile(curCharacter);
				playAnim('idle');
			case 'monster-christmas':
				tex = Paths.getSparrowAtlas('characters/monsterChristmas');
				frames = tex;
				quickAnimAdd('idle', 'monster idle');
				quickAnimAdd('singUP', 'monster up note');
				quickAnimAdd('singDOWN', 'monster down');
				quickAnimAdd('singLEFT', 'Monster left note');
				quickAnimAdd('singRIGHT', 'Monster Right note');

				loadOffsetFile(curCharacter);
				playAnim('idle');
			case 'pico':
				tex = Paths.getSparrowAtlas('characters/Pico_FNF_assetss');
				frames = tex;
				quickAnimAdd('idle', "Pico Idle Dance");
				quickAnimAdd('singUP', 'pico Up note0');
				quickAnimAdd('singDOWN', 'Pico Down Note0');
				if (isPlayer)
				{
					quickAnimAdd('singLEFT', 'Pico NOTE LEFT0');
					quickAnimAdd('singRIGHT', 'Pico Note Right0');
					quickAnimAdd('singRIGHTmiss', 'Pico Note Right Miss');
					quickAnimAdd('singLEFTmiss', 'Pico NOTE LEFT miss');
				}
				else
				{
					// Need to be flipped! REDO THIS LATER!
					quickAnimAdd('singLEFT', 'Pico Note Right0');
					quickAnimAdd('singRIGHT', 'Pico NOTE LEFT0');
					quickAnimAdd('singRIGHTmiss', 'Pico NOTE LEFT miss');
					quickAnimAdd('singLEFTmiss', 'Pico Note Right Miss');
				}

				quickAnimAdd('singUPmiss', 'pico Up note miss');
				quickAnimAdd('singDOWNmiss', 'Pico Down Note MISS');

				loadOffsetFile(curCharacter);

				playAnim('idle');

				flipX = true;

			case 'pico-speaker':
				frames = Paths.getSparrowAtlas('characters/picoSpeaker');
				quickAnimAdd('shoot1', 'Pico shoot 1');
				quickAnimAdd('shoot2', 'Pico shoot 2');
				quickAnimAdd('shoot3', 'Pico shoot 3');
				quickAnimAdd('shoot4', 'Pico shoot 4');

				loadOffsetFile(curCharacter);

				playAnim('shoot1');

				loadMappedAnims();

			// case 'bf':
			// 	tex = Paths.getSparrowAtlas('characters/BOYFRIEND');
			// 	frames = tex;
			// 	quickAnimAdd('idle', 'BF idle dance');
			// 	quickAnimAdd('singUP', 'BF NOTE UP0');
			// 	quickAnimAdd('singLEFT', 'BF NOTE LEFT0');
			// 	quickAnimAdd('singRIGHT', 'BF NOTE RIGHT0');
			// 	quickAnimAdd('singDOWN', 'BF NOTE DOWN0');
			// 	quickAnimAdd('singUPmiss', 'BF NOTE UP MISS');
			// 	quickAnimAdd('singLEFTmiss', 'BF NOTE LEFT MISS');
			// 	quickAnimAdd('singRIGHTmiss', 'BF NOTE RIGHT MISS');
			// 	quickAnimAdd('singDOWNmiss', 'BF NOTE DOWN MISS');
			// 	quickAnimAdd('hey', 'BF HEY');

			// 	quickAnimAdd('firstDeath', "BF dies");
			// 	animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
			// 	quickAnimAdd('deathConfirm', "BF Dead confirm");

			// 	animation.addByPrefix('scared', 'BF idle shaking', 24, true);

			// 	loadOffsetFile(curCharacter);

			// 	playAnim('idle');

			// 	flipX = true;

			// 	loadOffsetFile(curCharacter);

			case 'bf-christmas':
				tex = Paths.getSparrowAtlas('characters/bfChristmas');
				frames = tex;
				quickAnimAdd('idle', 'BF idle dance');
				quickAnimAdd('singUP', 'BF NOTE UP0');
				quickAnimAdd('singLEFT', 'BF NOTE LEFT0');
				quickAnimAdd('singRIGHT', 'BF NOTE RIGHT0');
				quickAnimAdd('singDOWN', 'BF NOTE DOWN0');
				quickAnimAdd('singUPmiss', 'BF NOTE UP MISS');
				quickAnimAdd('singLEFTmiss', 'BF NOTE LEFT MISS');
				quickAnimAdd('singRIGHTmiss', 'BF NOTE RIGHT MISS');
				quickAnimAdd('singDOWNmiss', 'BF NOTE DOWN MISS');
				quickAnimAdd('hey', 'BF HEY');

				loadOffsetFile(curCharacter);

				playAnim('idle');

				flipX = true;
			case 'bf-car':
				tex = Paths.getSparrowAtlas('characters/bfCar');
				frames = tex;
				quickAnimAdd('idle', 'BF idle dance');
				quickAnimAdd('singUP', 'BF NOTE UP0');
				quickAnimAdd('singLEFT', 'BF NOTE LEFT0');
				quickAnimAdd('singRIGHT', 'BF NOTE RIGHT0');
				quickAnimAdd('singDOWN', 'BF NOTE DOWN0');
				quickAnimAdd('singUPmiss', 'BF NOTE UP MISS');
				quickAnimAdd('singLEFTmiss', 'BF NOTE LEFT MISS');
				quickAnimAdd('singRIGHTmiss', 'BF NOTE RIGHT MISS');
				quickAnimAdd('singDOWNmiss', 'BF NOTE DOWN MISS');

				animation.addByIndices('idleHair', 'BF idle dance', [10, 11, 12, 13], '', 24, true);

				loadOffsetFile(curCharacter);

				playAnim('idle');

				flipX = true;
			case 'bf-pixel':
				frames = Paths.getSparrowAtlas('characters/bfPixel');
				quickAnimAdd('idle', 'BF IDLE');
				quickAnimAdd('singUP', 'BF UP NOTE');
				quickAnimAdd('singLEFT', 'BF LEFT NOTE');
				quickAnimAdd('singRIGHT', 'BF RIGHT NOTE');
				quickAnimAdd('singDOWN', 'BF DOWN NOTE');
				quickAnimAdd('singUPmiss', 'BF UP MISS');
				quickAnimAdd('singLEFTmiss', 'BF LEFT MISS');
				quickAnimAdd('singRIGHTmiss', 'BF RIGHT MISS');
				quickAnimAdd('singDOWNmiss', 'BF DOWN MISS');

				loadOffsetFile(curCharacter);

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();

				playAnim('idle');

				width -= 100;
				height -= 100;

				antialiasing = false;

				flipX = true;
			case 'bf-pixel-dead':
				frames = Paths.getSparrowAtlas('characters/bfPixelsDEAD');
				quickAnimAdd('singUP', "BF Dies pixel");
				quickAnimAdd('firstDeath', "BF Dies pixel");
				animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
				quickAnimAdd('deathConfirm', "RETRY CONFIRM");
				animation.play('firstDeath');

				loadOffsetFile(curCharacter);
				playAnim('firstDeath');
				// pixel bullshit
				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
				antialiasing = false;
				flipX = true;
			case 'bf-holding-gf':
				frames = Paths.getSparrowAtlas('characters/bfAndGF');
				quickAnimAdd('idle', 'BF idle dance');
				quickAnimAdd('singDOWN', 'BF NOTE DOWN0');
				quickAnimAdd('singLEFT', 'BF NOTE LEFT0');
				quickAnimAdd('singRIGHT', 'BF NOTE RIGHT0');
				quickAnimAdd('singUP', 'BF NOTE UP0');
				quickAnimAdd('singDOWNmiss', 'BF NOTE DOWN MISS');
				quickAnimAdd('singLEFTmiss', 'BF NOTE LEFT MISS');
				quickAnimAdd('singRIGHTmiss', 'BF NOTE RIGHT MISS');
				quickAnimAdd('singUPmiss', 'BF NOTE UP MISS');

				quickAnimAdd('bfCatch', 'BF catches GF');

				loadOffsetFile(curCharacter);

				playAnim('idle');

				flipX = true;
			case 'bf-holding-gf-dead':
				frames = Paths.getSparrowAtlas('characters/bfHoldingGF-DEAD');
				quickAnimAdd('singUP', 'BF Dead with GF Loop');
				quickAnimAdd('firstDeath', 'BF Dies with GF');
				animation.addByPrefix('deathLoop', 'BF Dead with GF Loop', 24, true);
				quickAnimAdd('deathConfirm', 'RETRY confirm holding gf');

				loadOffsetFile(curCharacter);

				playAnim('firstDeath');

				flipX = true;

			case 'senpai':
				frames = Paths.getSparrowAtlas('characters/senpai');
				quickAnimAdd('idle', 'Senpai Idle');
				quickAnimAdd('singUP', 'SENPAI UP NOTE');
				quickAnimAdd('singLEFT', 'SENPAI LEFT NOTE');
				quickAnimAdd('singRIGHT', 'SENPAI RIGHT NOTE');
				quickAnimAdd('singDOWN', 'SENPAI DOWN NOTE');

				loadOffsetFile(curCharacter);

				playAnim('idle');

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();

				antialiasing = false;
			case 'senpai-angry':
				frames = Paths.getSparrowAtlas('characters/senpai');
				quickAnimAdd('idle', 'Angry Senpai Idle');
				quickAnimAdd('singUP', 'Angry Senpai UP NOTE');
				quickAnimAdd('singLEFT', 'Angry Senpai LEFT NOTE');
				quickAnimAdd('singRIGHT', 'Angry Senpai RIGHT NOTE');
				quickAnimAdd('singDOWN', 'Angry Senpai DOWN NOTE');

				loadOffsetFile(curCharacter);
				playAnim('idle');

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();

				antialiasing = false;

			case 'spirit':
				frames = Paths.getPackerAtlas('characters/spirit');
				quickAnimAdd('idle', "idle spirit_");
				quickAnimAdd('singUP', "up_");
				quickAnimAdd('singRIGHT', "right_");
				quickAnimAdd('singLEFT', "left_");
				quickAnimAdd('singDOWN', "spirit down_");

				loadOffsetFile(curCharacter);

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

			case 'parents-christmas':
				frames = Paths.getSparrowAtlas('characters/mom_dad_christmas_assets');
				quickAnimAdd('idle', 'Parent Christmas Idle');
				quickAnimAdd('singUP', 'Parent Up Note Dad');
				quickAnimAdd('singDOWN', 'Parent Down Note Dad');
				quickAnimAdd('singLEFT', 'Parent Left Note Dad');
				quickAnimAdd('singRIGHT', 'Parent Right Note Dad');

				quickAnimAdd('singUP-alt', 'Parent Up Note Mom');

				quickAnimAdd('singDOWN-alt', 'Parent Down Note Mom');
				quickAnimAdd('singLEFT-alt', 'Parent Left Note Mom');
				quickAnimAdd('singRIGHT-alt', 'Parent Right Note Mom');

				loadOffsetFile(curCharacter);

				playAnim('idle');

			case 'tankman':
				frames = Paths.getSparrowAtlas('characters/tankmanCaptain');
				quickAnimAdd('idle', 'Tankman Idle Dance');
				if (isPlayer)
				{
					quickAnimAdd('singLEFT', 'Tankman Note Left ');
					quickAnimAdd('singRIGHT', 'Tankman Right Note ');
					quickAnimAdd('singLEFTmiss', 'Tankman Note Left MISS');
					quickAnimAdd('singRIGHTmiss', 'Tankman Right Note MISS');
				}
				else
				{
					quickAnimAdd('singLEFT', 'Tankman Right Note ');
					quickAnimAdd('singRIGHT', 'Tankman Note Left ');
					quickAnimAdd('singLEFTmiss', 'Tankman Right Note MISS');
					quickAnimAdd('singRIGHTmiss', 'Tankman Note Left MISS');
				}
				quickAnimAdd('singUP', 'Tankman UP note ');
				quickAnimAdd('singDOWN', 'Tankman DOWN note ');
				quickAnimAdd('singUPmiss', 'Tankman UP note MISS');
				quickAnimAdd('singDOWNmiss', 'Tankman DOWN note MISS');

				quickAnimAdd('singDOWN-alt', 'PRETTY GOOD');
				quickAnimAdd('singUP-alt', 'TANKMAN UGH');

				loadOffsetFile(curCharacter);

				playAnim('idle');

				flipX = true;

			default:
				var path:String = Paths.getPath('characters/$curCharacter.json', TEXT);
				if (Assets.exists(path, TEXT))
					data = cast Json.parse(Assets.getText(path));

				if (data != null)
				{
					if (data.antialiasing != null)
						antialiasing = data.antialiasing;

					if (data.flipX != null)
						flipX = data.flipX;
					if (data.flipY != null)
						flipY = data.flipY;

					if (data.singDuration != null)
						singDuration = data.singDuration;

					if (data.iconPath == null)
						data.iconPath = 'face';
					if (data.iconColor == null)
						data.iconColor = [161, 161, 161];

					if (Assets.exists(Paths.getPath('images/${data.imagePath}.xml', TEXT)))
						frames = Paths.getSparrowAtlas(data.imagePath);
					else if (Assets.exists(Paths.getPath('images/${data.imagePath}.txt', TEXT)))
						frames = Paths.getPackerAtlas(data.imagePath);

					if (frames != null)
					{
						for (anim in data.animations)
						{
							var fps:Int = 24;
							if (anim.fps != null)
								fps = anim.fps;

							var loop:Bool = false;
							if (anim.loop != null)
								loop = anim.loop;

							var shitX:Bool = false;
							if (anim.flipX != null)
								shitX = anim.flipX;
							var shitY:Bool = false;
							if (anim.flipY != null)
								shitY = anim.flipY;

							if (anim.indices == null)
								animation.addByPrefix(anim.name, anim.prefix, fps, loop, shitX, shitY);
							else
								animation.addByIndices(anim.name, anim.prefix, anim.indices, '', fps, loop, shitX, shitY);

							if (anim.offset != null)
								addOffset(anim.name, anim.offset[0], anim.offset[1]);
						}
					}
				}
		}

		danceSpeed = simpleIdle ? 2 : 1;

		dance();
		animation.finish();

		if (isPlayer)
			flipX = !flipX;
	}

	function loadMappedAnims()
	{
		var sections:Array<SwagSection> = Song.loadFromJson('picospeaker', 'stress').notes;
		for (section in sections)
		{
			for (note in section.sectionNotes)
			{
				animationNotes.push(note);
			}
		}
		TankmenBG.animationNotes = animationNotes;
		// trace(animationNotes);
		animationNotes.sort(sortAnims);
	}

	function sortAnims(x, y)
	{
		return x[0] < y[0] ? -1 : x[0] > y[0] ? 1 : 0;
	}

	function quickAnimAdd(Name:String, Prefix:String)
	{
		animation.addByPrefix(Name, Prefix, 24, false);
	}

	function loadOffsetFile(char:String)
	{
		var offsets:Array<String> = CoolUtil.coolTextFile(Paths.getPath('images/characters/' + char + 'Offsets.txt', TEXT));
		for (i in offsets)
		{
			var split = i.split(' ');
			addOffset(split[0], Std.parseInt(split[1]), Std.parseInt(split[2]));
		}
	}

	override function update(elapsed:Float)
	{
		if (!debugMode)
		{
			if (isPlayer && animation.curAnim.finished)
			{
				if (animation.curAnim.name.endsWith('miss'))
					playAnim('idle', true, false, 10);
				if (animation.curAnim.name == 'firstDeath')
					playAnim('deathLoop');
			}

			if (animation.curAnim.name.startsWith('sing'))
				holdTimer += elapsed;

			if (!noHoldDance && holdTimer >= Conductor.stepCrochet * singDuration * 0.0011)
			{
				dance();
				holdTimer = 0;
			}

			if (curCharacter.endsWith('-car') && !animation.curAnim.name.startsWith('sing') && animation.curAnim.finished)
				playAnim('idleHair');

			switch (curCharacter)
			{
				case 'gf':
					if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
						playAnim('danceRight');
				case 'pico-speaker':
					if (animationNotes.length > 0 && Conductor.songPosition > animationNotes[0][0])
					{
						// trace("played shoot anim" + animationNotes[0][1]);
						var shotDirection:Int = 1;
						if (animationNotes[0][1] >= 2)
							shotDirection = 3;
						shotDirection += FlxG.random.int(0, 1);

						playAnim('shoot' + shotDirection, true);
						animationNotes.shift();
					}
					if (animation.curAnim.finished)
						playAnim(animation.curAnim.name, false, false, animation.curAnim.frames.length - 3);
			}
		}

		super.update(elapsed);

		// make sure everything is updated before doing the hold thingy
		if (!debugMode
			&& holding
			&& animation.curAnim != null
			&& animation.curAnim.frames.length > 2
			&& animation.curAnim.curFrame > 1)
			animation.curAnim.curFrame = 0;
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode)
		{
			holding = false;

			// TODO: unharcode this
			switch (curCharacter)
			{
				case 'pico-speaker':
				// do nothing LOL
				default:
					if ((!curCharacter.startsWith('gf') || !animation.curAnim.name.startsWith('hair'))
						|| (curCharacter != 'tankman' || !animation.curAnim.name.endsWith('DOWN-alt')))
					{
						if (simpleIdle)
							playAnim('idle');
						else if (!blockDance)
						{
							danced = !danced;

							if (danced)
								playAnim('danceRight');
							else
								playAnim('danceLeft');
						}
					}
			}
		}
	}

	override function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0)
	{
		super.playAnim(AnimName, Force, Reversed, Frame);

		if (curCharacter == 'gf')
		{
			if (AnimName == singAnimations[0])
				danced = true;
			else if (AnimName == singAnimations[3])
				danced = false;

			if (AnimName == singAnimations[1] || AnimName == singAnimations[2])
				danced = !danced;
		}

		if (cameraMove)
		{
			if (AnimName.startsWith(singAnimations[0]))
				cameraMoveArray = [-cameraMoveAdd, 0];
			else if (AnimName.startsWith(singAnimations[1]))
				cameraMoveArray = [0, cameraMoveAdd];
			else if (AnimName.startsWith(singAnimations[2]))
				cameraMoveArray = [0, -cameraMoveAdd];
			else if (AnimName.startsWith(singAnimations[3]))
				cameraMoveArray = [cameraMoveAdd, 0];
			else
				cameraMoveArray = null;
		}
		else
			cameraMoveArray = null;
	}
}
