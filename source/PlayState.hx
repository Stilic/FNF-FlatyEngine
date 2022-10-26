package;

#if hxCodec
import vlc.MP4Handler;
#end
#if discord_rpc
import Discord.DiscordClient;
#end
import Conductor.Rating;
import Song.SwagSong;
import openfl.events.KeyboardEvent;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.effects.FlxTrail;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import Strumline.Receptor;
import shaders.BuildingShaders;
import ui.PreferencesMenu;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist(default, set):Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var deathCounter:Int = 0;
	public static var practiceMode:Bool = false;
	public static var seenCutscene:Bool = false;

	static var isFirstStorySong:Bool = true;

	private var vocals:FlxSound;
	private var vocalsFinished = false;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Character;

	private var unspawnNotes:Array<Note> = [];

	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	private var strumlines:Array<Strumline> = [];
	private var opponentStrumline:Strumline;
	private var playerStrumline:Strumline;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var health:Float = 1;
	private var combo:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;

	private var camGame:FNFCamera;
	private var camRating:FlxCamera;
	private var camHUD:FlxCamera;
	private var camOther:FlxCamera;
	private var bumpinCams:Array<FlxCamera> = [];

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var foregroundSprites:FlxTypedGroup<BGSprite>;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;
	var lightFadeShader:BuildingShaders;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;

	var tankWatchtower:BGSprite;
	var tankGround:BGSprite;
	var tankmanRun:FlxTypedGroup<TankmenBG>;

	// var gfCutsceneLayer:FlxTypedGroup<FlxAnimate>;
	// var bfTankCutsceneLayer:FlxTypedGroup<FlxAnimate>;
	var songScore:Int = 0;
	var songMisses:Int = 0;
	var scoreTxt:FlxText;

	var hitMap:Map<String, Int> = new Map<String, Int>();

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static final daPixelZoom:Float = 6;

	var inCutscene:Bool = false;

	#if discord_rpc
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var songLength:Float = 0;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	public static function set_storyPlaylist(playlist:Array<String>)
	{
		isFirstStorySong = true;
		storyPlaylist = playlist;
		return playlist;
	}

	override public function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		camGame = new FNFCamera(0.04);
		camRating = new FlxCamera();
		camRating.bgColor.alpha = 0;
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther = new FlxCamera();
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camRating, false);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);

		bumpinCams.push(camRating);
		bumpinCams.push(camHUD);

		persistentUpdate = persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		foregroundSprites = new FlxTypedGroup<BGSprite>();

		switch (SONG.song.toLowerCase())
		{
			// case 'tutorial':
			// 	dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			// case 'bopeebo':
			// 	dialogue = [
			// 		'HEY!',
			// 		"You think you can just sing\nwith my daughter like that?",
			// 		"If you want to date her...",
			// 		"You're going to have to go \nthrough ME first!"
			// 	];
			// case 'fresh':
			// 	dialogue = ["Not too shabby boy.", ""];
			// case 'dadbattle':
			// 	dialogue = [
			// 		"gah you think you're hot stuff?",
			// 		"If you can beat me here...",
			// 		"Only then I will even CONSIDER letting you\ndate my daughter!"
			// 	];
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
		}

		#if discord_rpc
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		#end

		switch (SONG.song.toLowerCase())
		{
			case 'spookeez' | 'monster' | 'south':
				{
					curStage = 'spooky';

					halloweenBG = new FlxSprite(-200, -100);
					halloweenBG.frames = Paths.getSparrowAtlas('halloween_bg');
					halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
					halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
					halloweenBG.animation.play('idle');
					halloweenBG.antialiasing = true;
					add(halloweenBG);

					isHalloween = true;
				}
			case 'pico' | 'blammed' | 'philly':
				{
					curStage = 'philly';

					var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky'));
					bg.scrollFactor.set(0.1, 0.1);
					add(bg);

					var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city'));
					city.scrollFactor.set(0.3, 0.3);
					city.setGraphicSize(Std.int(city.width * 0.85));
					city.updateHitbox();
					add(city);

					lightFadeShader = new BuildingShaders();
					phillyCityLights = new FlxTypedGroup<FlxSprite>();
					add(phillyCityLights);

					for (i in 0...5)
					{
						var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i));
						light.scrollFactor.set(0.3, 0.3);
						light.visible = false;
						light.setGraphicSize(Std.int(light.width * 0.85));
						light.updateHitbox();
						light.antialiasing = true;
						light.shader = lightFadeShader.shader;
						phillyCityLights.add(light);
					}

					var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain'));
					add(streetBehind);

					phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
					add(phillyTrain);

					trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
					FlxG.sound.list.add(trainSound);

					// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

					var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street'));
					add(street);
				}
			case 'milf' | 'satin-panties' | 'high':
				{
					curStage = 'limo';
					defaultCamZoom = 0.90;

					var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset'));
					skyBG.scrollFactor.set(0.1, 0.1);
					add(skyBG);

					var bgLimo:FlxSprite = new FlxSprite(-200, 480);
					bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo');
					bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
					bgLimo.animation.play('drive');
					bgLimo.scrollFactor.set(0.4, 0.4);
					add(bgLimo);

					grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);

					for (i in 0...5)
					{
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
						dancer.scrollFactor.set(0.4, 0.4);
						grpLimoDancers.add(dancer);
					}

					limo = new FlxSprite(-120, 550);
					limo.frames = Paths.getSparrowAtlas('limo/limoDrive');
					limo.animation.addByPrefix('drive', "Limo stage", 24);
					limo.animation.play('drive');
					limo.antialiasing = true;

					fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol'));
					// add(limo);
				}
			case 'cocoa' | 'eggnog':
				{
					curStage = 'mall';
					defaultCamZoom = 0.80;

					var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					add(bg);

					upperBoppers = new FlxSprite(-240, -90);
					upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop');
					upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
					upperBoppers.antialiasing = true;
					upperBoppers.scrollFactor.set(0.33, 0.33);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					add(upperBoppers);

					var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator'));
					bgEscalator.antialiasing = true;
					bgEscalator.scrollFactor.set(0.3, 0.3);
					bgEscalator.active = false;
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);

					var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree'));
					tree.antialiasing = true;
					tree.scrollFactor.set(0.40, 0.40);
					add(tree);

					bottomBoppers = new FlxSprite(-300, 140);
					bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop');
					bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
					bottomBoppers.antialiasing = true;
					bottomBoppers.scrollFactor.set(0.9, 0.9);
					bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
					bottomBoppers.updateHitbox();
					add(bottomBoppers);

					var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow'));
					fgSnow.active = false;
					fgSnow.antialiasing = true;
					add(fgSnow);

					santa = new FlxSprite(-840, 150);
					santa.frames = Paths.getSparrowAtlas('christmas/santa');
					santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
					santa.antialiasing = true;
					add(santa);
				}
			case 'winter-horrorland':
				{
					curStage = 'mallEvil';

					var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					add(bg);

					var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree'));
					evilTree.antialiasing = true;
					evilTree.scrollFactor.set(0.2, 0.2);
					add(evilTree);

					var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow"));
					evilSnow.antialiasing = true;
					add(evilSnow);
				}
			case 'senpai' | 'roses':
				{
					curStage = 'school';

					var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky'));
					bgSky.scrollFactor.set(0.1, 0.1);
					add(bgSky);

					var repositionShit = -200;

					var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool'));
					bgSchool.scrollFactor.set(0.6, 0.90);
					add(bgSchool);

					var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet'));
					bgStreet.scrollFactor.set(0.95, 0.95);
					add(bgStreet);

					var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack'));
					fgTrees.scrollFactor.set(0.9, 0.9);
					add(fgTrees);

					var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
					var treetex = Paths.getPackerAtlas('weeb/weebTrees');
					bgTrees.frames = treetex;
					bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
					bgTrees.animation.play('treeLoop');
					bgTrees.scrollFactor.set(0.85, 0.85);
					add(bgTrees);

					var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
					treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals');
					treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
					treeLeaves.animation.play('leaves');
					treeLeaves.scrollFactor.set(0.85, 0.85);
					add(treeLeaves);

					var widShit = Std.int(bgSky.width * 6);

					bgSky.setGraphicSize(widShit);
					bgSchool.setGraphicSize(widShit);
					bgStreet.setGraphicSize(widShit);
					bgTrees.setGraphicSize(Std.int(widShit * 1.4));
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					treeLeaves.setGraphicSize(widShit);

					fgTrees.updateHitbox();
					bgSky.updateHitbox();
					bgSchool.updateHitbox();
					bgStreet.updateHitbox();
					bgTrees.updateHitbox();
					treeLeaves.updateHitbox();

					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					if (SONG.song.toLowerCase() == 'roses')
					{
						bgGirls.getScared();
					}

					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();
					add(bgGirls);
				}
			case 'thorns':
				{
					curStage = 'schoolEvil';

					var bg:FlxSprite = new FlxSprite(400, 200);
					bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool');
					bg.animation.addByPrefix('idle', 'background 2', 24);
					bg.animation.play('idle');
					bg.scrollFactor.set(0.8, 0.9);
					bg.scale.set(6, 6);
					add(bg);
				}
			case 'guns' | 'stress' | 'ugh':
				{
					curStage = 'tank';
					defaultCamZoom = 0.9;

					add(new BGSprite('tankSky', -400, -400, 0, 0));

					var clouds:BGSprite = new BGSprite('tankClouds', FlxG.random.int(-700, -100), FlxG.random.int(-20, 20), 0.1, 0.1);
					clouds.active = true;
					clouds.velocity.x = FlxG.random.float(5, 15);
					add(clouds);

					var mountains:BGSprite = new BGSprite('tankMountains', -300, -20, 0.2, 0.2);
					mountains.setGraphicSize(Std.int(mountains.width * 1.2));
					mountains.updateHitbox();
					add(mountains);

					var buildings:BGSprite = new BGSprite('tankBuildings', -200, 0, 0.3, 0.3);
					buildings.setGraphicSize(Std.int(buildings.width * 1.1));
					buildings.updateHitbox();
					add(buildings);

					var ruins:BGSprite = new BGSprite('tankRuins', -200, 0, 0.35, 0.35);
					ruins.setGraphicSize(Std.int(ruins.width * 1.1));
					ruins.updateHitbox();
					add(ruins);

					add(new BGSprite('smokeLeft', -200, -100, 0.4, 0.4, ['SmokeBlurLeft'], true));
					add(new BGSprite('smokeRight', 1100, -100, 0.4, 0.4, ['SmokeRight'], true));

					tankWatchtower = new BGSprite('tankWatchtower', 100, 50, 0.5, 0.5, ['watchtower gradient color']);
					add(tankWatchtower);

					tankGround = new BGSprite('tankRolling', 300, 300, 0.5, 0.5, ['BG tank w lighting'], true);
					add(tankGround);

					tankmanRun = new FlxTypedGroup<TankmenBG>();
					add(tankmanRun);

					var ground:BGSprite = new BGSprite('tankGround', -420, -150);
					ground.setGraphicSize(Std.int(ground.width * 1.15));
					ground.updateHitbox();
					add(ground);
					moveTank();

					foregroundSprites.add(new BGSprite('tank0', -500, 650, 1.7, 1.5, ['fg']));
					foregroundSprites.add(new BGSprite('tank1', -300, 750, 2, 0.2, ['fg']));
					foregroundSprites.add(new BGSprite('tank2', 450, 940, 1.5, 1.5, ['foreground']));
					foregroundSprites.add(new BGSprite('tank4', 1300, 900, 1.5, 1.5, ['fg']));
					foregroundSprites.add(new BGSprite('tank5', 1620, 700, 1.5, 1.5, ['fg']));
					foregroundSprites.add(new BGSprite('tank3', 1300, 1200, 3.5, 2.5, ['fg']));
				}
			default:
				{
					curStage = 'stage';
					defaultCamZoom = 0.9;

					var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
					add(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = true;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					add(stageFront);

					var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					stageCurtains.antialiasing = true;
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;

					add(stageCurtains);
				}
		}

		GameOverSubstate.resetVariables();

		var gfVersion:String = SONG.gfVersion;
		if (gfVersion == null || gfVersion.length <= 0)
		{
			switch (curStage)
			{
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school':
					gfVersion = 'gf-pixel';
				case 'schoolEvil':
					gfVersion = 'gf-pixel';
				case 'tank':
					if (SONG.song.toLowerCase() == 'stress')
						gfVersion = 'pico-speaker';
					else
						gfVersion = 'gf-tankmen';
				default:
					gfVersion = 'gf';
			}
		}

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);
		if (gfVersion == 'pico-speaker')
		{
			gf.x -= 50;
			gf.y -= 200;
			var tankmen:TankmenBG = new TankmenBG(20, 500, true);
			tankmen.strumTime = 10;
			tankmen.resetShit(20, 600, true);
			tankmanRun.add(tankmen);
			for (i in 0...TankmenBG.animationNotes.length)
			{
				if (FlxG.random.bool(16))
				{
					var man:TankmenBG = tankmanRun.recycle(TankmenBG);
					man.strumTime = TankmenBG.animationNotes[i][0];
					man.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
					tankmanRun.add(man);
				}
			}
		}

		dad = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = dad.getGraphicMidpoint(FlxPoint.weak());

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				dad.danceSpeed = 2;
				gf.visible = false;
				if (isStoryMode)
					camPos.x += 600;

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case "tankman":
				dad.y += 180;
		}

		boyfriend = new Character(770, 450, SONG.player1, true);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				add(evilTrail);
				// evilTrail.scrollFactor.set(1.1, 1.1);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'tank':
				gf.y += 10;
				gf.x -= 30;
				boyfriend.x += 40;
				boyfriend.y += 0;
				dad.y += 60;
				dad.x -= 80;
				if (gfVersion != 'pico-speaker')
				{
					gf.x -= 170;
					gf.y -= 75;
				}
		}

		add(gf);

		// gfCutsceneLayer = new FlxTypedGroup<FlxAnimate>();
		// add(gfCutsceneLayer);

		// bfTankCutsceneLayer = new FlxTypedGroup<FlxAnimate>();
		// add(bfTankCutsceneLayer);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dad);
		add(boyfriend);

		add(foregroundSprites);

		var doof:DialogueBox = null;
		if (curStage.startsWith('school'))
		{
			doof = new DialogueBox(false, dialogue);
			// doof.x += 70;
			// doof.y = FlxG.height * 0.5;
			doof.scrollFactor.set();
			doof.finishCallback = startCountdown;
		}

		Conductor.songPosition = -5000;

		var baseXShit:Int = 15;
		var baseX:Float = FlxG.width / baseXShit;
		var baseY:Int = PreferencesMenu.getPref('downscroll') ? FlxG.height - 150 : 50;

		opponentStrumline = new Strumline(baseX, baseY, PreferencesMenu.getPref('downscroll'), true);
		opponentStrumline.onNoteBotHit.add(function(note:Note)
		{
			goodNoteHit(opponentStrumline, note);
		});
		opponentStrumline.characters = [dad];
		opponentStrumline.singingCharacters = [dad];

		playerStrumline = new Strumline(baseX * (baseXShit / 1.75), baseY, PreferencesMenu.getPref('downscroll'));
		playerStrumline.onNoteBotHit.add(function(note:Note)
		{
			goodNoteHit(playerStrumline, note);
		});
		playerStrumline.onNoteUpdate.add(function(note:Note)
		{
			if (!playerStrumline.botplay && (note.tooLate || !note.wasGoodHit) && Strumline.isOutsideScreen(note.strumTime))
				noteMiss(note.noteData, playerStrumline, note, false);
		});
		playerStrumline.characters = [boyfriend];
		playerStrumline.singingCharacters = [boyfriend];

		add(opponentStrumline);
		add(playerStrumline);

		strumlines.push(opponentStrumline);
		strumlines.push(playerStrumline);

		if (!isStoryMode || isFirstStorySong)
		{
			for (strumline in strumlines)
			{
				strumline.receptors.forEachAlive(function(receptor:Receptor)
				{
					receptor.alpha = 0;
				});
			}
		}

		generateSong();

		camGame.snapToPosition(camPos.x, camPos.y, true);
		camPos.put();
		if (prevCamFollow != null)
		{
			camGame.camFollow.copyFrom(prevCamFollow);
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camGame.target.setPosition(prevCamFollowPos.x, prevCamFollowPos.y);
			prevCamFollowPos = null;
		}

		camGame.zoom = defaultCamZoom;

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		cameraSection();

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);
		if (PreferencesMenu.getPref('downscroll'))
			healthBarBG.y = FlxG.height * 0.1;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);

		iconP1 = new HealthIcon(SONG.player1, true, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false, true);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		scoreTxt = new FlxText(0, healthBarBG.y + 30, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 17, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);

		for (strumline in strumlines)
			strumline.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		if (doof != null)
			doof.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// CACHE IMAGES AND SOUNDS
		Paths.image('alphabet', null, true);
		// Paths.image('characters/' + GameOverSubstate.character);

		Paths.music('breakfast', null, true);
		for (i in 1...3)
			Paths.sound('missnote' + i, null, true);

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode && !seenCutscene)
		{
			seenCutscene = true;
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camGame.snapToPosition(camGame.camFollow.x + 200, -2050);
						camGame.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(camGame, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				#if hxCodec
				case 'ugh':
					tankIntro('ughCutscene', true);
				case 'guns':
					tankIntro('gunsCutscene');
				case 'stress':
					tankIntro('stressCutscene');
				#end
				default:
					startCountdown();
			}
		}
		else
			startCountdown();

		recalculateRating();

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);

		for (dir in Controls.noteDirections)
			keysArray.push(controls.getInputsFor(dir, Keys));

		super.create();

		Cache.clearUnused();
	}

	function playCutscene(name:String, atEndOfSong:Bool = false, ?callback:Void->Void)
	{
		var endShit = function()
		{
			if (callback != null)
				callback();
			if (atEndOfSong)
				endSong();
			else
				startCountdown();
		};
		#if hxCodec
		inCutscene = true;

		var video = new MP4Handler();
		video.finishCallback = endShit;
		video.playVideo(Paths.video(name));
		#else
		endShit();
		#end
	}

	function tankIntro(video:String, zoom:Bool = false):Void
	{
		playCutscene(video, false, function()
		{
			FlxTween.tween(camGame, {zoom: defaultCamZoom}, (Conductor.stepCrochet / 1000) * 5, {ease: FlxEase.quadInOut});
			cameraMovement(true);
		});
		if (zoom)
		{
			camGame.zoom = defaultCamZoom * 1.2;
			camGame.camFollow.x += 100;
			camGame.camFollow.y += 100;
		}
	}

	function schoolIntro(dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * daPixelZoom));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += senpaiEvil.width / 5;

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									camGame.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									camGame.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;

	function startCountdown():Void
	{
		inCutscene = false;

		camHUD.visible = true;

		if (!isStoryMode || isFirstStorySong)
		{
			for (strumline in strumlines)
				strumline.tweenReceptors();
		}

		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		var pixelArray:Array<String> = ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel'];
		introAssets.set('default', ['ready', "set", "go"]);
		introAssets.set('school', pixelArray);
		introAssets.set('schoolEvil', pixelArray);

		var introAlts:Array<String> = introAssets.get('default');
		var altSuffix:String = "";

		for (value in introAssets.keys())
		{
			if (value == curStage)
			{
				introAlts = introAssets.get(value);
				altSuffix = '-pixel';
			}
		}

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			beatDance(swagCounter);

			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
			}

			swagCounter += 1;
		}, 4);
	}

	function startSong():Void
	{
		startingSong = false;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(SONG.song), 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		#if discord_rpc
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
		#end
	}

	private function generateSong():Void
	{
		curSong = SONG.song;
		Conductor.changeBPM(SONG.bpm);

		vocals = new FlxSound();
		if (SONG.needsVoices)
			vocals.loadEmbedded(Paths.voices(SONG.song));

		vocals.onComplete = function()
		{
			vocalsFinished = true;
		};
		FlxG.sound.list.add(vocals);

		for (section in SONG.notes)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var gottaHitNote:Bool = section.mustHitSection;
				if (songNotes[1] > 3)
					gottaHitNote = !section.mustHitSection;

				var oldNote:Note = null;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				if (swagNote.sustainLength > 0)
					swagNote.sustainLength = Math.round(swagNote.sustainLength / Conductor.stepCrochet) * Conductor.stepCrochet;
				swagNote.altNote = songNotes[3];
				swagNote.scrollFactor.set();
				unspawnNotes.push(swagNote);

				if (swagNote.sustainLength > 0)
				{
					var floorSus:Int = Math.round(swagNote.sustainLength / Conductor.stepCrochet);
					if (floorSus > 0)
					{
						if (floorSus == 1)
							floorSus++;
						for (susNote in 0...floorSus)
						{
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

							var sustainNote:Note = new Note(daStrumTime + Conductor.stepCrochet * (susNote + 1), daNoteData, oldNote, true);
							sustainNote.mustPress = gottaHitNote;
							sustainNote.altNote = swagNote.altNote;
							sustainNote.scrollFactor.set();
							unspawnNotes.push(sustainNote);
						}
					}
				}
			}
		}

		unspawnNotes.sort(sortByTime);

		generatedMusic = true;
	}

	function sortByTime(Obj1:Note, Obj2:Note)
	{
		return CoolUtil.sortNotes(FlxSort.ASCENDING, Obj1, Obj2);
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;

			camGame.target = null;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		persistentUpdate = persistentDraw = true;

		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
				resyncVocals();

			FlxTimer.globalManager.forEach(function(tmr:FlxTimer)
			{
				if (!tmr.finished)
					tmr.active = true;
			});
			FlxTween.globalManager.forEach(function(twn:FlxTween)
			{
				if (!twn.finished)
					twn.active = true;
			});

			camGame.resetTarget();

			paused = false;

			#if discord_rpc
			if (startTimer == null || startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
			#end
		}

		super.closeSubState();

		Cache.clearUnused();
	}

	#if discord_rpc
	override public function onFocus():Void
	{
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0)
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			else
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}
		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		if (health > 0 && !paused)
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		super.onFocusLost();
	}
	#end

	function resyncVocals():Void
	{
		if (!_exiting)
		{
			vocals.pause();

			FlxG.sound.music.play();
			Conductor.songPosition = FlxG.sound.music.time + Conductor.offset;
			if (!vocalsFinished)
			{
				vocals.time = Conductor.songPosition;
				vocals.play();
			}
		}
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float)
	{
		Conductor.songPosition += elapsed * 1000;
		if (startingSong && startedCountdown && Conductor.songPosition >= 0)
			startSong();

		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				lightFadeShader.update(1.5 * (Conductor.crochet / 1000) * elapsed);
			case 'tank':
				moveTank();
		}

		super.update(elapsed);

		if (controls.PAUSE && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
				Main.switchState(new GitarooPause());
			else
			{
				FlxTimer.globalManager.forEach(function(tmr:FlxTimer)
				{
					if (!tmr.finished)
						tmr.active = false;
				});
				FlxTween.globalManager.forEach(function(twn:FlxTween)
				{
					if (!twn.finished)
						twn.active = false;
				});

				var pauseMenu:PauseSubState = new PauseSubState();
				openSubState(pauseMenu);
				pauseMenu.camera = camOther;
			}

			#if discord_rpc
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			Main.switchState(new editors.ChartingState());

			#if discord_rpc
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		if (FlxG.keys.justPressed.EIGHT)
		{
			Main.switchState(new editors.CharacterEditorState());

			#if discord_rpc
			DiscordClient.changePresence("Character Editor", null, null, true);
			#end
		}

		// forever engine moment
		if (FlxG.keys.justPressed.SIX)
			playerStrumline.botplay = !playerStrumline.botplay;

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		var iconOffset:Int = 26;
		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		if (generatedMusic && !endingSong)
			cameraSection(Std.int(curStep / 16));

		if (camZooming)
		{
			var lerpVal:Float = 0.052;
			camGame.zoom = CoolUtil.coolLerp(defaultCamZoom, camGame.zoom, lerpVal, true);
			for (cam in bumpinCams)
				cam.zoom = CoolUtil.coolLerp(1, cam.zoom, lerpVal, true);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gf.danceSpeed = 2;
				case 48:
					gf.danceSpeed = 1;
				case 80:
					gf.danceSpeed = 2;
				case 112:
					gf.danceSpeed = 1;
					// case 163:
					// FlxG.sound.music.stop();
					// Main.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// Main.switchState(new PlayState());
			}
		}
		// better streaming of shit

		if (!inCutscene && !_exiting)
		{
			// RESET = Quick Game Over Screen
			if (controls.RESET)
			{
				health = 0;
				// trace("RESET = True");
			}

			// CHEAT = brandon's a pussy
			// if (controls.CHEAT)
			// {
			// 	health += 1;
			// 	trace("User is cheating!");
			// }

			if (health <= 0 && !practiceMode)
			{
				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				deathCounter += 1;

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				// Main.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if discord_rpc
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
				#end
			}
		}

		if (unspawnNotes[0] != null)
		{
			var time:Float = 2000;
			if (SONG.speed < 1)
				time /= SONG.speed;

			while (unspawnNotes[0] != null)
			{
				if (unspawnNotes[0].strumTime - Conductor.songPosition < time)
				{
					if (unspawnNotes[0].mustPress)
						playerStrumline.addNote(unspawnNotes[0]);
					else
						opponentStrumline.addNote(unspawnNotes[0]);
					unspawnNotes.shift();
				}
				else
					break;
			}
		}

		if (!inCutscene && startedCountdown)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	override public function destroy()
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		super.destroy();
	}

	function beatDance(?beat:Int)
	{
		if (beat == null)
			beat = curBeat;

		var ignoredChars:Array<Character> = [];
		for (strumline in strumlines)
		{
			var chars:Array<Character> = strumline.characters.copy();
			if (!ignoredChars.contains(gf) && !chars.contains(gf))
				chars.push(gf);
			for (char in chars)
			{
				if (!ignoredChars.contains(char))
				{
					if (beat % char.danceSpeed == 0 && !char.animation.curAnim.name.startsWith('sing'))
						char.dance();
					ignoredChars.push(char);
				}
			}
		}
	}

	var scoreSeparator:String = ' / ';
	var rankSeparator:String = ' • ';

	var rank:String = '?';
	var accuracy:Float = 0;

	var fcString:String; // Full Combo Rating string;
	var smallestRatingIndex:Int; // Last gotten rating index;

	function recalculateRating()
	{
		var floorAccuracy:Float = 0;

		accuracy = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
		floorAccuracy = CoolUtil.floorDecimal(accuracy * 100, 2);
		rank = Conductor.getRank(floorAccuracy);

		if (songMisses < 10)
			rank += fcString != null ? rankSeparator + fcString : '';
		else if (totalPlayed < 1)
			rank = '?';

		scoreTxt.text = 'Score: ' + songScore + scoreSeparator + 'Combo Breaks: ' + songMisses + scoreSeparator + 'Accuracy: '
			+ (rank != '?' ? '$floorAccuracy% [$rank]' : '?');
	}

	function endSong():Void
	{
		seenCutscene = false;
		deathCounter = 0;
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		FlxG.sound.music.stop();
		vocals.stop();
		#if !switch
		Highscore.saveScore(SONG.song, songScore, storyDifficulty);
		#end

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.shift();

			if (storyPlaylist.length <= 0)
			{
				Main.switchState(new StoryMenuState());

				CoolUtil.resetMusic();

				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				isFirstStorySong = false;

				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * camGame.zoom,
						-FlxG.height * camGame.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'), 1, false, null, true, function()
					{
						SONG = Song.loadFromJson(storyPlaylist[0].toLowerCase() + difficulty, storyPlaylist[0]);
						LoadingState.loadAndSwitchState(new PlayState());
					});
				}
				else
				{
					prevCamFollow = camGame.camFollow;
					prevCamFollowPos = camGame.target;

					SONG = Song.loadFromJson(storyPlaylist[0].toLowerCase() + difficulty, storyPlaylist[0]);
					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
		}
		else
		{
			Main.switchState(new FreeplayState());
			#if NO_PRELOAD_ALL
			CoolUtil.resetMusic();
			#end
		}
	}

	var endingSong:Bool = false;

	var totalPlayed:Int = 0;
	var totalNotesHit:Float = 0;

	private function popUpScore(note:Note, forceBestRating:Bool = false):Void
	{
		var daRating:Rating = Conductor.getRating(forceBestRating ? 0 : Math.abs(note.strumTime - Conductor.songPosition));
		totalNotesHit += daRating.mod;

		// gets your last rating, then sets the fc rating string accordingly, -gabi
		if (songMisses <= 0)
		{
			var leIndex:Int = Conductor.ratings.indexOf(daRating);
			if (leIndex > smallestRatingIndex)
				smallestRatingIndex = leIndex;
			fcString = null;
			var smallestRating:Rating = Conductor.ratings[smallestRatingIndex];
			if (smallestRating != null && smallestRating.fc != null)
				fcString = smallestRating.fc;
		}

		if (!practiceMode)
		{
			songScore += daRating.score;
			totalPlayed++;
			recalculateRating();
		}
		if (daRating.splash && PreferencesMenu.getPref('note-splashes'))
			playerStrumline.spawnSplash(note.noteData);

		hitMap.set(daRating.name, hitMap.exists(daRating.name) ? (hitMap.get(daRating.name) + 1) : 1);

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		var coolX:Float = FlxG.width * 0.35;

		var rating:FlxSprite = new FlxSprite(coolX - 40, 0).loadGraphic(Paths.image(pixelShitPart1 + daRating.name + pixelShitPart2));
		rating.screenCenter(Y);
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.cameras = [camRating];
		insert(members.indexOf(opponentStrumline), rating);

		// var comboSpr:FlxSprite = null;
		// if (combo >= 10)
		// {
		// 	comboSpr = new FlxSprite(coolX, 0).loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		// 	comboSpr.screenCenter(Y);
		// 	comboSpr.acceleration.y = 600;
		// 	comboSpr.velocity.y -= 150;
		// 	comboSpr.cameras = [camRating];
		// 	comboSpr.velocity.x += FlxG.random.int(1, 10);
		// 	insert(members.indexOf(opponentStrumline), comboSpr);
		// }

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			// if (comboSpr != null)
			// {
			// 	comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			// 	comboSpr.antialiasing = true;
			// }
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			// if (comboSpr != null)
			// 	comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		rating.updateHitbox();
		// if (comboSpr != null)
		// 	comboSpr.updateHitbox();

		if (combo >= 10)
		{
			var seperatedScore:Array<Int> = [];
			seperatedScore.push(Math.floor(combo / 100));
			seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
			seperatedScore.push(combo % 10);

			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite(coolX + 43 * daLoop - 90,
					0).loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
				numScore.screenCenter(Y);
				numScore.y += 80;

				if (!curStage.startsWith('school'))
				{
					numScore.antialiasing = true;
					numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				}
				else
					numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
				numScore.updateHitbox();

				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);
				numScore.cameras = [camRating];

				if (combo >= 10)
					insert(members.indexOf(opponentStrumline), numScore);

				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.kill();
						remove(numScore, true);
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.002
				});

				daLoop++;
			}
		}

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				rating.kill();
				remove(rating, true);
				rating.destroy();
				// if (comboSpr != null)
				// 	comboSpr.kill();
			},
			startDelay: Conductor.crochet * 0.001
		});

		// if (comboSpr != null)
		// 	FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
		// 		startDelay: Conductor.crochet * 0.001
		// 	});
	}

	var camZoomTween:FlxTween;

	private function cameraMovement(isDad:Bool, followChar:Bool = false):Void
	{
		var char:Character;
		if (isDad)
			char = dad;
		else
			char = boyfriend;

		var camPos:FlxPoint = char.getMidpoint(FlxPoint.weak());
		var tempY:Float = Math.NEGATIVE_INFINITY;

		if (isDad)
			switch (char.curCharacter)
			{
				case 'senpai' | 'senpai-angry':
					camPos.x -= 100;
					tempY = -430;
				default:
					if (char.curCharacter != 'mom')
						camPos.x += 150;
			}
		else
			switch (curStage)
			{
				case 'limo':
					camPos.x -= 300;
				case 'mall':
					tempY = -200;
				case 'school' | 'schoolEvil':
					tempY = -200;
					camPos.x += tempY;
				default:
					camPos.x -= 100;
			}
		if (tempY == Math.NEGATIVE_INFINITY)
			camPos.y -= 100;
		else
			camPos.y += tempY;

		if (followChar && char.cameraMove && char.cameraMoveArray != null)
			camPos.add(char.cameraMoveArray[0], char.cameraMoveArray[1]);

		camGame.camFollow.copyFrom(camPos);

		if (camZoomTween == null && SONG.song.toLowerCase() == 'tutorial')
		{
			camZoomTween = FlxTween.tween(camGame, {zoom: isDad ? 1.3 : 1}, (Conductor.stepCrochet * 4 / 1000), {
				ease: FlxEase.elasticInOut,
				onComplete: function(twn:FlxTween)
				{
					camZoomTween = null;
				}
			});
		}
	}

	private function cameraSection(section:Int = 0):Void
	{
		var leSection:SwagSection = SONG.notes[section];
		if (leSection != null)
			cameraMovement(!leSection.mustHitSection, true);
	}

	// for the keyboard
	var keysArray:Array<Array<Int>> = [];
	// for the gamepad
	var buttonsArray:Array<Array<Int>> = [];

	var holdingArray:Array<Bool> = [];

	private function getKeyFromCode(keyCode:Int):Int
	{
		if (keyCode != FlxKey.NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (bind in keysArray[i])
				{
					if (bind == keyCode)
						return i;
				}
			}
		}
		return FlxKey.NONE;
	}

	private function handleInput(key:Int, down:Bool)
	{
		holdingArray[key] = down;

		if (down && generatedMusic && !endingSong)
		{
			// accurate hit moment part one
			var lastTime:Float = Conductor.songPosition;
			Conductor.songPosition = FlxG.sound.music.time;

			var possibleNotes:Array<Note> = [];
			playerStrumline.notesGroup.forEachAlive(function(note:Note)
			{
				if (note.noteData == key && !note.isSustainNote && note.mustPress && !note.tooLate && !note.wasGoodHit && note.canBeHit)
					possibleNotes.push(note);
			});
			if (possibleNotes.length > 0)
			{
				if (possibleNotes.length == 1)
					goodNoteHit(playerStrumline, possibleNotes[0]);
				else
				{
					possibleNotes.sort(sortByTime);
					var pressedNotes:Array<Note> = [];
					for (note in possibleNotes)
					{
						var finishLoop:Bool = false;
						for (noteDouble in pressedNotes)
						{
							if (Math.abs(noteDouble.strumTime - note.strumTime) >= 0.1)
							{
								finishLoop = true;
								break;
							}
						}
						if (!finishLoop)
						{
							goodNoteHit(playerStrumline, note);
							pressedNotes.push(note);
						}
						else
							break;
					}
				}
			}
			else if (!PreferencesMenu.getPref('ghost-tapping'))
				noteMiss(key, playerStrumline);

			// accurate hit moment part two (the old times)
			Conductor.songPosition = lastTime;
		}

		var receptor = playerStrumline.receptors.members[key];
		if (receptor != null && (!down || receptor.animation.curAnim.name != 'confirm'))
			receptor.playAnim(down ? 'pressed' : 'static');
	}

	private function onKeyDown(evt:KeyboardEvent):Void
	{
		if (FlxG.keys.enabled
			&& (persistentUpdate || subState == null)
			&& !playerStrumline.botplay
			&& !inCutscene
			&& startedCountdown)
		{
			var key = getKeyFromCode(evt.keyCode);
			if (key != FlxKey.NONE && !holdingArray[key])
				handleInput(key, true);
		}
	}

	private function onKeyUp(evt:KeyboardEvent):Void
	{
		if (FlxG.keys.enabled
			&& (persistentUpdate || subState == null)
			&& !playerStrumline.botplay
			&& !inCutscene
			&& startedCountdown)
		{
			var key = getKeyFromCode(evt.keyCode);
			if (key != FlxKey.NONE)
				handleInput(key, false);
		}
	}

	private function keyShit():Void
	{
		if (!playerStrumline.botplay)
		{
			if (generatedMusic)
			{
				if (controls.gamepads.length > 0)
				{
					var gamepad:FlxGamepad = FlxG.gamepads.getByID(controls.gamepads[0]);
					var genArray:Bool = buttonsArray.length == 0;
					for (i in 0...Controls.noteDirections.length)
					{
						if (genArray)
							buttonsArray[i] = controls.getInputsFor(Controls.noteDirections[i], Gamepad(gamepad.id));
						if (gamepad.anyJustPressed(buttonsArray[i]))
							handleInput(i, true);
						if (gamepad.anyJustReleased(buttonsArray[i]))
							handleInput(i, false);
					}
				}

				playerStrumline.holdsGroup.forEachAlive(function(note:Note)
				{
					if (note.isSustainNote && note.mustPress && holdingArray[note.noteData] && note.canBeHit)
						goodNoteHit(playerStrumline, note);
				});

				for (char in playerStrumline.singingCharacters)
					char.noHoldDance = holdingArray.contains(true) || char.animation.curAnim.name.endsWith('miss');
			}
		}
		else
		{
			for (char in playerStrumline.singingCharacters)
				char.noHoldDance = false;
		}
	}

	function noteMiss(direction:Int, ?strumline:Strumline, ?note:Note, press:Bool = true):Void
	{
		vocals.volume = 0;

		if (press)
		{
			if (combo > 5 && gf.animation.exists('sad'))
				gf.playAnim('sad');
			health -= Note.defaultMissHealth - 0.0075;
		}
		else if (note != null)
			health -= note.missHealth;
		else
			health -= Note.defaultMissHealth;

		combo = 0;
		if (!practiceMode)
			songScore -= 10;
		songMisses++;

		totalPlayed++;
		fcString = (songMisses < 10 ? 'SDCB' : '');
		recalculateRating();

		if (strumline != null)
		{
			playMissSound();
			for (char in strumline.singingCharacters)
			{
				char.playAnim(Character.singAnimations[direction] + 'miss', true);
				char.holding = false;
			}
		}
	}

	function playMissSound()
	{
		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
	}

	function goodNoteHit(strumline:Strumline, note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			note.wasGoodHit = true;

			if (note.mustPress)
			{
				if (!note.isSustainNote)
				{
					popUpScore(note, strumline.botplay);
					combo += 1;
				}

				health += note.hitHealth;
			}
			else if (SONG.song != 'Tutorial')
				camZooming = true;

			var animSuffix:String = '';
			if (!note.mustPress)
			{
				var curSection:SwagSection = SONG.notes[Math.floor(curStep / 16)];
				if ((curSection != null && curSection.altAnim) || note.altNote)
					animSuffix = '-alt';
			}

			var canHold:Bool = true;
			if (!note.isSustainNote)
			{
				canHold = false;
				for (susNote in note.children)
				{
					if (susNote.wasGoodHit)
					{
						canHold = true;
						break;
					}
				}
			}
			else if (note.isSustainEnd)
				canHold = false;
			for (char in strumline.singingCharacters)
			{
				char.playAnim(Character.singAnimations[note.noteData] + animSuffix, true);
				char.holdTimer = 0;
				char.holding = canHold;
			}

			var receptor = strumline.receptors.members[note.noteData];
			if (receptor != null)
			{
				if (!strumline.botplay)
					receptor.playAnim('confirm', true);
				else
				{
					var time:Float = 0.15;
					if (note.isSustainNote && !note.isSustainEnd)
						time += 0.15;
					receptor.autoConfirm(time);
				}
			}

			if (vocals != null)
				vocals.volume = 1;

			if (!note.isSustainNote)
				strumline.removeNote(note);
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var tankResetShit:Bool = false;
	var tankMoving:Bool = false;
	var tankAngle:Float = FlxG.random.int(-90, 45);
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankX:Float = 400;

	function moveTank():Void
	{
		if (!inCutscene)
		{
			tankAngle += tankSpeed * FlxG.elapsed;
			tankGround.angle = (tankAngle - 90 + 15);
			tankGround.x = tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180));
			tankGround.y = 1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180));
		}
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;
	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	override function stepHit()
	{
		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
		{
			resyncVocals();
		}
	}

	function bumpCams()
	{
		if (camZooming && camGame.zoom < 1.35)
		{
			camGame.zoom += 0.015;
			for (cam in bumpinCams)
				cam.zoom += 0.03;
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		var section:SwagSection = SONG.notes[Math.floor(curStep / 16)];
		if (section != null && section.changeBPM)
		{
			Conductor.changeBPM(section.bpm);
			FlxG.log.add('CHANGED BPM!');
		}

		if (PreferencesMenu.getPref('camera-zoom'))
		{
			// HARDCODING FOR MILF ZOOMS!
			if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200)
				bumpCams();

			if (curBeat % 4 == 0)
				bumpCams();
		}

		iconP1.bounce();
		iconP2.bounce();

		beatDance();

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
			boyfriend.playAnim('hey', true);

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		foregroundSprites.forEachAlive(function(spr:BGSprite)
		{
			spr.dance();
		});

		switch (curStage)
		{
			case 'tank':
				tankWatchtower.dance();
			case 'school':
				bgGirls.dance();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEachAlive(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					lightFadeShader.reset();

					phillyCityLights.forEachAlive(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
					// phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
			lightningStrikeShit();
	}

	var curLight:Int = 0;
}
