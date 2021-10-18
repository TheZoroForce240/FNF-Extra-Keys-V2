package;

#if desktop
import Discord.DiscordClient;
#end

import openfl.ui.KeyLocation;
import openfl.events.Event;
import haxe.EnumTools;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import flixel.input.keyboard.FlxKey;
import haxe.Exception;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import lime.graphics.Image;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import flixel.system.FlxAssets;

import lime.app.Application;
import lime.media.AudioContext;
import lime.media.AudioManager;
import openfl.Lib;
import Section.SwagSection;
import Song.SwagSong;
import SongEvent.EventsList;
import SongEvent.SwagEvent;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import Shaders;
import ModchartUtil;

#if sys
import sys.io.File;
import sys.FileSystem;
import flash.media.Sound;
#end

using StringTools;

typedef Stages = 
{
	var stageList:Array<StageFile>;
}
typedef StageFile = 
{
	var name:String;
	var camZoom:Float;
	var pieceArray:Array<String>;
	var offsets:Array<StageOffset>;
}
typedef StageOffset = 
{
	var type:String;
	var offsets:Array<Int>;
}

class PlayState extends MusicBeatState
{
	//song stuff
	public static var curStage:String;
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var mania:Int = 0;
	public static var maniaToChange:Int = 0;
	public static var keyAmmo:Array<Int> = [4, 6, 9, 5, 7, 8, 1, 2, 3];
	public static var EVENT:EventsList; //not added events yet
	public static var SongSpeed:Float;
	var songLength:Float = 0;
	private var vocals:FlxSound;
	private var curSong:String = "";

	//characters
	public static var dad:Boyfriend; //made dad a boyfriend class for flip mode and multiplayer, to fix anim stuff because it be like that
	public static var gf:Character;
	public static var boyfriend:Boyfriend;
	var oppenentColors:Array<Array<Float>>; //oppenents arrow colors and assets
	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var P2health:Float = 1;
	private var combinedHealth:Float = 1;

	//note stuff
	private var P1notes:FlxTypedGroup<Note>; //bf
	private var P2notes:FlxTypedGroup<Note>; //dad
	private var P3notes:FlxTypedGroup<Note>; //gf (events notes pretty much lol)
	private var unspawnNotes:Array<Note> = []; //notes that are not rendered yet
	var noteSplashes:FlxTypedGroup<NoteSplash>;
	var P2noteSplashes:FlxTypedGroup<NoteSplash>;

	//sing animation arrays
	private var sDir:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT']; //regular singing animations
	//private var bfsDir:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT']; //just for playing hey animation as bf
	private var GFsDir:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT']; //for gf

	//some more song stuff
	private var strumLine:FlxSprite; //the strumline (just for static arrow placement)
	private var curSection:Int = 0; //current section
	public var currentSection:SwagSection; //the current section again lol, but its actually the section not just a number

	//static arrows
	public static var strumLineNotes:FlxTypedGroup<BabyArrow> = null;
	public static var playerStrums:FlxTypedGroup<BabyArrow> = null;
	public static var cpuStrums:FlxTypedGroup<BabyArrow> = null;

	//score and stats
	public static var campaignScore:Int = 0;
	private var combo:Int = 0;
	private var P2combo:Int = 0;
	var fc:Bool = true;
	var songScore:Int = 0;
	var P2songScore:Int = 0;

	public var accuracy:Float = 0.00;
	public var ranksList:Array<String> = ["Skill Issue", "E", "D", "C", "B", "A", "S"]; //for score text
	public var curRank:String = "None"; //for score text
	public static var misses:Int = 0;
	public var P2misses:Int = 0;
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;
	public var totalNotesHit:Int = 0;

	var scoreTxt:FlxText;
	var TimeText:FlxText;
	var songtext:String; //for time text
	var modeText:String; //also for time text
	
	//song stuff
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	//hud shit
	public var iconP1:HealthIcon; 
	public var iconP2:HealthIcon;
	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	//private var P2healthBar:FlxBar; //fuck this it will take too long

	//camera shit
	public var camHUD:FlxCamera;
	public var camSustains:FlxCamera;
	public var camP1Notes:FlxCamera;
	public var camP2Notes:FlxCamera;
	public var camOnTop:FlxCamera;
	private var camGame:FlxCamera;

	private var camZooming:Bool = false;
	private var camFollow:FlxObject;
	private static var prevCamFollow:FlxObject;
	var defaultCamZoom:Float = 1.05;

	//dialogue
	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var talking:Bool = true;
	var inCutscene:Bool = false;

	//stages
	public var dancingStagePieces:FlxTypedGroup<StagePiece>; //for stage pieces that bop/dance/whatever every beat, no need for a variable/hx
	var stageException:Bool = false; //just used for week 6 stage, because of its weird set graphic size shit
	var stageOffsets:Map<String, Array<Dynamic>>;
	var limo:StagePiece; //for the shitty layering
	var pieceArray = [];

	//some extra random stuff i didnt know where to put
	var wiggleShit:WiggleEffect = new WiggleEffect();
	var grace:Bool = false;
	var maniaChanged:Bool = false;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	//for testing
	var NormalInput:Bool = true;
	var CustomInput:Bool = false;

	//for flip and multiplayer
	public static var flipped:Bool = false;
	public static var multiplayer:Bool = false;
	var player:Boyfriend;
	var player2:Boyfriend;
	var cpu:Boyfriend;
	var centerHealthBar:Bool = false;


	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end
	override public function create()
	{
		FlxG.mouse.visible = false;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		var songLowercase = PlayState.SONG.song.toLowerCase();

		songtext = PlayState.SONG.song + " - " + CoolUtil.CurSongDiffs[storyDifficulty];

		noteSplashes = new FlxTypedGroup<NoteSplash>(); //note splash spawning before the song
		var daSplash = new NoteSplash(100, 100, 0);
		daSplash.alpha = 0;
		noteSplashes.add(daSplash);

		P2noteSplashes = new FlxTypedGroup<NoteSplash>(); //note splash spawning before the song
		var P2daSplash = new NoteSplash(100, 100, 0);
		P2daSplash.alpha = 0;
		P2noteSplashes.add(P2daSplash);

		if (SaveData.multiplayer)
			multiplayer = true;
		else
			multiplayer = false;

		misses = 0; //reset that shit

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camSustains = new FlxCamera();
		camSustains.bgColor.alpha = 0;
		camP1Notes = new FlxCamera();
		camP1Notes.bgColor.alpha = 0;
		camP2Notes = new FlxCamera();
		camP2Notes.bgColor.alpha = 0;
		camOnTop = new FlxCamera();
		camOnTop.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camSustains);
		FlxG.cameras.add(camP1Notes);
		FlxG.cameras.add(camP2Notes);
		FlxG.cameras.add(camOnTop);
		

		FlxCamera.defaultCameras = [camGame];

		PlayerSettings.player1.controls.loadKeyBinds();

		if (FlxG.save.data.flip)
			flipped = true;
		else
			flipped = false;

		persistentUpdate = true;
		persistentDraw = true;

		if (SaveData.downscroll) //im not sure if this is the smartest or the stupidest way of doing downscroll
		{
			camP1Notes.flashSprite.scaleY *= -1;
		}
		if (SaveData.P2downscroll) //well it works lol
		{
			camP2Notes.flashSprite.scaleY *= -1;
		}

		mania = SONG.mania; //setting the manias

		//if (PlayStateChangeables.bothSide)
			//mania = 5;
		//else if (FlxG.save.data.mania != 0 && PlayStateChangeables.randomNotes)
			//mania = FlxG.save.data.mania;

		maniaToChange = mania;

		/*var shaggy7KSongs:Array<String> = ["thunderstorm", "dissasembler", "astral-calamity"]; 
		//for compatibilty :)
		//srPerez used mania 2 for 7k, i used mania 4, this should fix
		//but mania 2 is 9k on this ahhhhhhhhhhhhhhhhhhhhhh
		//just change in chart editor ffs
		if (maniaToChange == 2 && shaggy7KSongs.contains(PlayState.SONG.song.toLowerCase()))
			maniaToChange = 4;*/

		Note.scaleSwitch = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		if (SaveData.ScrollSpeed != 1)
			SongSpeed = FlxMath.roundDecimal(SaveData.ScrollSpeed, 2);
		else
			SongSpeed = FlxMath.roundDecimal(SONG.speed, 2);

		if (multiplayer)
			modeText = " - Multiplayer";
		else if (flipped)
			modeText = " - Flipped";
		else
			modeText = "";

		var EventFile:String = Paths.json(SONG.song.toLowerCase() + '/events');
		if (Assets.exists(EventFile))											//unfinished event code!
		{
			PlayState.EVENT = SongEvent.loadFromJson('events', SONG.song.toLowerCase());
			//eventsEnabled = true;
		}

		switch (SONG.song.toLowerCase()) //dialogue
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dadbattle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('charts/senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('charts/roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('charts/thorns/thornsDialogue'));
		}

		#if desktop
		// Making difficulty text for Discord Rich Presence.

		storyDifficultyText = CoolUtil.CurSongDiffs[storyDifficulty];

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

		dancingStagePieces = new FlxTypedGroup<StagePiece>();
		add(dancingStagePieces);

		stageOffsets = new Map<String, Array<Dynamic>>();

		var stageCheck:String = 'stage';

			
		trace(stageCheck); //fuck you stage check not working, i can see in the trace that its picking up the song.stage correctly but you dont fucking change aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
		trace(PlayState.SONG.stage);

		curStage = null;
		pieceArray = [];

		StageCheck(PlayState.SONG.stage);
		trace("trying to make stage");

		if (curStage == null || pieceArray == [] || curStage == "")
		{
			switch (PlayState.SONG.song.toLowerCase())
			{
				case 'spookeez' | 'monster' | 'south':
					stageCheck = "halloween";
				case 'pico' | 'blammed' | 'philly': 
					stageCheck = 'philly'; 
				case 'milf' | 'satin-panties' | 'high':
					stageCheck = 'limo';
				case 'cocoa' | 'eggnog':
					stageCheck = 'mall';
				case 'winter-horrorland':
					stageCheck = 'mallEvil';
				case 'senpai' | 'roses':
					stageCheck = 'school';
				case 'thorns':
					stageCheck = 'schoolEvil';
				default: 
					stageCheck = "stage";
			}
			trace("trying to make stage again");
			StageCheck(stageCheck);
		}

		if (!stageException)
		{
			for (i in 0...pieceArray.length) //x and y are optional and set in StagePiece.hx, so for loop can be used
			{
				var piece:StagePiece = new StagePiece(0, 0, pieceArray[i]);
				if (piece.danceable)
					dancingStagePieces.add(piece);


				if (pieceArray[i] == 'bgDancer')
					piece.x += (370 * (i - 2));
				
				piece.x += piece.newx;
				piece.y += piece.newy;
				add(piece);
			}
		}

		var gfVersion:String = ''; //apparently this caused the fucking stage issue wtffffffff
		var checkGF:String = 'gf';

		if (SONG.gfVersion == null) 
		{
			switch(storyWeek)
			{
				case 4: 
					checkGF = 'gf-car';
				case 5: 
					checkGF = 'gf-christmas';
				case 6: 
					checkGF = 'gf-pixel';
			}
		} 
		else
			checkGF = SONG.gfVersion;

		switch (checkGF)
		{
			case 'gf-car':
				gfVersion = 'gf-car';
			case 'gf-christmas':
				gfVersion = 'gf-christmas';
			case 'gf-pixel':
				gfVersion = 'gf-pixel';
			default:
				gfVersion = 'gf';
		}

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);
		var dadcharacter = SONG.player2;
		var bfcharacter = SONG.player1;

		var characterList:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));
		if (!characterList.contains(dadcharacter)) //stop the fucking game from crashing when theres a character that doesnt exist
			dadcharacter = "dad";
		if (!characterList.contains(bfcharacter))
			bfcharacter = "bf";

		var isbfPlayer = true;
		var isdadPlayer = false;

		if (multiplayer)
		{
			isbfPlayer = true;
			isdadPlayer = true;
		}
		else if (flipped)
		{
			isbfPlayer = !isbfPlayer;
			isdadPlayer = !isdadPlayer;
		}


		dad = new Boyfriend(100, 100, dadcharacter, isdadPlayer, false);
		boyfriend = new Boyfriend(770, 450, bfcharacter, isbfPlayer, true);

		if (multiplayer)
		{
			player = boyfriend;
			player2 = dad;
		}
		else if (flipped)
		{
			player = dad;
			cpu = boyfriend;
		}
		else
		{
			player = boyfriend;
			cpu = dad;
		}


		//general offsets are now inside character.hx, go there for some examples

		// general offset for dad character
		var dadOffset = dad.posOffsets.get('pos');
		if (dad.posOffsets.exists('pos'))
		{
			dad.x += dadOffset[0];
			dad.y += dadOffset[1];
		}
		//general offset for bf (none by default lol)
		var bfOffset = boyfriend.posOffsets.get('pos');
		if (boyfriend.posOffsets.exists('pos'))
		{
			boyfriend.x += bfOffset[0];
			boyfriend.y += bfOffset[1];
		}


		//stage offsets are above inside the case statement for stages

		var stupidArray:Array<String> = ['dad', 'bf', 'gf'];
		var stupidCharArray:Array<Dynamic> = [dad, boyfriend, gf];
		//stage offsets (uses a for loop)
		for (i in 0...stupidArray.length)
		{
			var offset = stageOffsets.get(stupidArray[i]);
			if (stageOffsets.exists(stupidArray[i]))
			{
				stupidCharArray[i].x += offset[0];
				stupidCharArray[i].y += offset[1];
			}
		}

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		var camOffset = dad.posOffsets.get('startCam'); //offset in character.hx
		if (dad.posOffsets.exists('startCam'))
		{
			camPos.set(dad.getGraphicMidpoint().x + camOffset[0], dad.getGraphicMidpoint().y + camOffset[1]);
		}

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}
		}
		
		ColorPresets.setColors(dad, mania);

		

		// REPOSITIONING PER STAGE (not anymore, now moved to maps!)
		switch (curStage)
		{
			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				add(evilTrail);
		}

		add(gf);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dad);
		add(boyfriend);

		
		

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();





		strumLineNotes = new FlxTypedGroup<BabyArrow>();
		//add(strumLineNotes);
		add(noteSplashes);
		add(P2noteSplashes);
		playerStrums = new FlxTypedGroup<BabyArrow>();
		cpuStrums = new FlxTypedGroup<BabyArrow>();
		add(playerStrums);
		add(cpuStrums);

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		if (SaveData.downscroll != SaveData.P2downscroll)
			centerHealthBar = true;
		else 
			centerHealthBar = false; //this means the side ways one

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (centerHealthBar)
		{
			healthBarBG.screenCenter(Y); 
			healthBarBG.angle = 90;
		}


		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);
		if (SaveData.downscroll && !centerHealthBar)
			healthBarBG.y = FlxG.height * 0.1;


		if (!multiplayer)
		{
			healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		}
		else
		{
			healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'combinedHealth', -2, 2);
		}

		if (centerHealthBar)
			healthBar.angle = 90;

		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		add(healthBar);



		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 640, healthBarBG.y + 30, 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();

		TimeText = new FlxText(healthBarBG.x + healthBarBG.width - 540, healthBarBG.y - 60, 0, "", 20);
		TimeText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		TimeText.scrollFactor.set();

		if (centerHealthBar)
		{
			TimeText.y = (FlxG.height * 0.1) - 60;
			scoreTxt.y = (FlxG.height * 0.9) + 30;
		}
		

		iconP1 = new HealthIcon(bfcharacter, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(dadcharacter, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);
		add(scoreTxt);
		add(TimeText);
		noteSplashes.cameras = [camP1Notes];
		P2noteSplashes.cameras = [camP2Notes];
		//strumLineNotes.cameras = [camP1Notes];
		playerStrums.cameras = [camP1Notes];
		cpuStrums.cameras = [camP2Notes];
		P1notes.cameras = [camP1Notes];
		P2notes.cameras = [camP2Notes];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		TimeText.cameras = [camHUD];
		doof.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode)
		{
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
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
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
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN,handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);

		super.create();
	}

	function StageCheck(stage:String)
		{
			switch (stage)
			{
				case 'halloween':
					curStage = 'spooky';
					pieceArray = ['halloweenBG'];
				////////////////////////////////////////////////////////////////////////
				case 'philly': 
					curStage = 'philly';
					pieceArray = ['phillyBG', "phillyCity", "phillyCityLight0", "phillyCityLight1", "phillyCityLight2", "phillyCityLight3", "phillyCityLight4", "phillySteetBehind", "phillyTrain", "phillyStreet"];
				////////////////////////////////////////////////////////////////////////
				case 'limo':
					curStage = 'limo';
					defaultCamZoom = 0.90;
					stageOffsets['bf'] = [260, -220];
					pieceArray = ['limoSkyBG', 'limoBG', 'bgDancer', 'bgDancer', 'bgDancer', 'bgDancer', 'bgDancer', 'fastCar'];
	
					limo = new StagePiece(0, 0, 'limo'); //for the shitty layering
					limo.x += limo.newx;
					limo.y += limo.newy;
				/////////////////////////////////////////////////////////////////////
				case 'mall':
					curStage = 'mall';
					defaultCamZoom = 0.80;
					stageOffsets['bf'] = [200, 0];
					pieceArray = ['mallBG', 'mallUpperBoppers', 'mallEscalator', 'mallTree', 'mallBottomBoppers', 'mallSnow', 'mallSanta'];
				///////////////////////////////////////////////////////////////////
				case 'mallEvil':
					curStage = 'mallEvil';
					stageOffsets['bf'] = [320, 0];
					stageOffsets['dad'] = [0, -80];
					pieceArray = ['mallEvilBG', 'mallEvilTree', 'mallEvilSnow'];
				/////////////////////////////////////////////////////////////////
				case 'school':
					curStage = 'school';
					stageException = true; //week 6 has some weird shit goin on with its stage
	
					var bgSky:StagePiece = new StagePiece(0, 0, 'school-bgSky');
					add(bgSky);
	
					stageOffsets['bf'] = [200, 220];
					stageOffsets['gf'] = [180, 300];
	
					var repositionShit = -200;
	
					pieceArray = ['school-bgSchool', 'school-bgStreet', 'school-fgTrees', 'school-bgTrees', 'school-treeLeaves', 'bgGirls'];
					for (i in 0...pieceArray.length)
					{
						var piece:StagePiece = new StagePiece(repositionShit, 0, pieceArray[i]);
						piece.x += piece.newx;
						piece.y += piece.newy;
						var modif:Float = 1;
						var widShit = Std.int(bgSky.width * 6);
						add(piece);
						if (piece.danceable)
							dancingStagePieces.add(piece);
	
						if (pieceArray[i] != 'bgGirls')
						{
							if (pieceArray[i] == 'school-bgTrees')
								piece.setGraphicSize(Std.int(widShit * 1.4));
							else if (pieceArray[i] == 'school-fgTrees')
								piece.setGraphicSize(Std.int(widShit * 0.8));
							else
								piece.setGraphicSize(widShit);
							
							piece.updateHitbox();
						}
					}
					bgSky.setGraphicSize(Std.int(bgSky.width * 6));
					bgSky.updateHitbox();
				//////////////////////////////////////////////////////////////////////
				case 'schoolEvil':
					curStage = 'schoolEvil';
					stageOffsets['bf'] = [200, 220];
					stageOffsets['gf'] = [180, 300];
					var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
					var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
					pieceArray = ['schoolEvilBG'];
				////////////////////////////////////////////////////////////////////	
				case "stage": 
					defaultCamZoom = 0.9;
					curStage = "stage";
					pieceArray = ['stageBG', 'stageFront', 'stageCurtains'];
				default: 
					var stageList:Array<String> = CoolUtil.coolTextFile(Paths.txt('stageList'));
					if (!stageList.contains(stage))
						return;

					curStage = stage;
					var rawJson = File.getContent("assets/data/customStages.json");
					var json:Stages = cast Json.parse(rawJson);

					if (json.stageList.length != 0)
						for (i in json.stageList)
							if (i.name == stage)
							{
								pieceArray = i.pieceArray;
								defaultCamZoom = i.camZoom;

								if (i.offsets.length != 0)
									for (ii in i.offsets)
									{
										var type:String = ii.type;
										var offsets:Array<Int> = ii.offsets; 
										addStageOffset(type, offsets[0], offsets[1]);
									}
								break;
							}

			}
			/////////////////////////////////////////////////////////////////////////////
		}
	public function addStageOffset(name:String, x:Float = 0, y:Float = 0)
		{
			stageOffsets[name] = [x, y];
		}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
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
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
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
	var perfectMode:Bool = false;


	var keys = [false, false, false, false, false, false, false, false, false];
	var P2keys = [false, false, false, false, false, false, false, false, false];

	function startCountdown():Void
	{
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		var P1binds:Array<String> = CoolUtil.bindCheck(maniaToChange);
		var P2binds:Array<String> = CoolUtil.P2bindCheck(maniaToChange);

		if (multiplayer)
		{
			for (i in 0...P1binds.length)
			{
				var text:FlxText = new FlxText(playerStrums.members[i].x, (strumLine.y + 200), 48, P1binds[i], 32, false);
				text.setFormat(Paths.font("vcr.ttf"), 48, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
				add(text);
				text.scrollFactor.set();
				if (SaveData.downscroll)
					{
						text.y += 170;	
						text.x += 15;
					}
				else
					text.x += 40;
				new FlxTimer().start(4, function(tmr:FlxTimer)
				{
					FlxTween.tween(text, {alpha: 0}, 1, {
						onComplete: function(twn:FlxTween)
						{
							remove(text);
							text.destroy();
						}
					});
				});	
			}
			for (i in 0...P2binds.length)
			{
				var text:FlxText = new FlxText(cpuStrums.members[i].x, (strumLine.y + 200), 48, P2binds[i], 32, false);
				text.setFormat(Paths.font("vcr.ttf"), 48, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
				add(text);
				text.scrollFactor.set();
				if (SaveData.P2downscroll)
					{
						text.y += 170;	
						text.x += 15;
					}
				else
					text.x += 40;	
				new FlxTimer().start(4, function(tmr:FlxTimer)
				{
					FlxTween.tween(text, {alpha: 0}, 1, {
						onComplete: function(twn:FlxTween)
						{
							remove(text);
							text.destroy();
						}
					});
				});	
			}
		}
		else if (flipped)
		{
			for (i in 0...P1binds.length)
			{
				var text:FlxText = new FlxText(cpuStrums.members[i].x, (strumLine.y + 200), 48, P1binds[i], 32, false);
				text.setFormat(Paths.font("vcr.ttf"), 48, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
				add(text);
				text.scrollFactor.set();
				if (SaveData.P2downscroll)
					{
						text.y += 170;	
						text.x += 15;
					}
				else
					text.x += 40;
				new FlxTimer().start(4, function(tmr:FlxTimer)
				{
					FlxTween.tween(text, {alpha: 0}, 1, {
						onComplete: function(twn:FlxTween)
						{
							remove(text);
							text.destroy();
						}
					});
				});	
			}
		}
		else
		{
			for (i in 0...P1binds.length)
			{
				var text:FlxText = new FlxText(playerStrums.members[i].x, (strumLine.y + 200), 48, P1binds[i], 32, false);
				text.setFormat(Paths.font("vcr.ttf"), 48, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
				add(text);
				text.scrollFactor.set();
				if (SaveData.downscroll)
					{
						text.y += 170;	
						text.x += 15;
					}
				else
					text.x += 40;
					
				new FlxTimer().start(4, function(tmr:FlxTimer)
				{
					FlxTween.tween(text, {alpha: 0}, 1, {
						onComplete: function(twn:FlxTween)
						{
							remove(text);
							text.destroy();
						}
					});
				});	
			}
		}

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.dance();

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

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

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
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
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
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
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
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
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	private function getKey(charCode:Int):String
		{
			for (key => value in FlxKey.fromStringMap)
			{
				if (charCode == value)
					return key;
			}
			return null;
		}

	public var closestNotes:Array<Note> = [];
	public var P2closestNotes:Array<Note> = [];

	/////////////////////////////////////////////////////////// input code - originally from kade engine, i modified it a bit
	private function releaseInput(evt:KeyboardEvent):Void
	{
		@:privateAccess
		var key = FlxKey.toStringMap.get(evt.keyCode);

		var binds:Array<String> = [FlxG.save.data.leftBind,FlxG.save.data.downBind, FlxG.save.data.upBind, FlxG.save.data.rightBind];
		var data = -1;
		var playernum:Int = 1;
		
		binds = CoolUtil.bindCheck(maniaToChange);
		//data = CoolUtil.arrowKeyCheck(maniaToChange, evt.keyCode); //arrow keys are shit, just set them in keybinds, sorry to anyone who plays both wasd + arrow keys, might add alt keys at some point

		var P2binds:Array<String> = [null,null,null,null]; //null so you cant misspress while not in multi
		if (multiplayer) //so it only checks when in multi
			P2binds = CoolUtil.P2bindCheck(maniaToChange);

		for (i in 0...binds.length)//convert binds to key to data
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
			{
				data = i;
				playernum = 1;
			}

		}
		for (i in 0...P2binds.length)
		{
			if (P2binds[i].toLowerCase() == key.toLowerCase())
			{
				data = i;
				playernum = 0;
			}
		}

		switch (playernum)
		{
		case 0: 
			if (data == -1)
				{
					return;
				}
			P2keys[data] = false;
		case 1: 
			if (data == -1)
				{
					return;
				}
			keys[data] = false;
		}
	}



	private function handleInput(evt:KeyboardEvent):Void 
	{
		if (paused)
			return;

		@:privateAccess
		var key = FlxKey.toStringMap.get(evt.keyCode);
		var data = -1;
		var playernum:Int = 1;
		var binds:Array<String> = [FlxG.save.data.leftBind,FlxG.save.data.downBind, FlxG.save.data.upBind, FlxG.save.data.rightBind];
		binds = CoolUtil.bindCheck(maniaToChange); //finally got rid of that fucking huge case statement, its still inside coolutil, but theres only 1, not like 4 lol
		//data = CoolUtil.arrowKeyCheck(maniaToChange, evt.keyCode);

		var P2binds:Array<String> = [null,null,null,null]; //null so you cant misspress while not in multi
		if (multiplayer) //so it only checks when in multi
			P2binds = CoolUtil.P2bindCheck(maniaToChange);

		for (i in 0...binds.length)//convert binds to key to data
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
			{
				data = i;
				playernum = 1;
			}

		}
		for (i in 0...P2binds.length)
		{
			if (P2binds[i].toLowerCase() == key.toLowerCase())
			{
				data = i;
				playernum = 0;
			}
		}

		switch (playernum)
		{
			case 0: 
				if (P2keys[data] || data == -1)
					{
						return;
					}
				P2keys[data] = true;
			case 1: 
				if (keys[data] || data == -1)
					{
						return;
					}
				keys[data] = true;
		}
		if (!SaveData.casual)
			normalInputSystem(data, playernum);
		else
			casualInputSystem(data, playernum);


		
				
		
	}
	/////////////////////////////////////////////////////////////////////////////////////////

	function normalInputSystem(data:Int, playernum:Int)
	{
		var hittableNotes = [];
		switch(playernum)
		{
			case 0: 
				for(i in P2closestNotes)
					if (i.noteData == data)
						hittableNotes.push(i);
			case 1: 
				for(i in closestNotes)
					if (i.noteData == data)
						hittableNotes.push(i);
		}

		if (hittableNotes.length != 0)
		{
			var daNote = null;

			for (i in hittableNotes)
				if (!i.isSustainNote)
				{
					daNote = i;
					break;
				}

			if (daNote == null)
				return;

			if (hittableNotes.length > 1) // gets rid of stacked notes
			{
				for (i in 0...hittableNotes.length)
				{
					if (i == 0)
						continue;
					var note = hittableNotes[i];
					if (!note.isSustainNote && (note.strumTime - daNote.strumTime) < 10)
					{
						removeNote(note);
					}
				}
			}

			goodNoteHit(daNote, playernum);
		}
		else if (!SaveData.ghost && songStarted && !grace)
		{
			trace("you mispressed you dumbass");
			missPress(data, playernum);
		}
	}
	function casualInputSystem(data:Int, playernum:Int)
	{
		if (closestNotes.length > 0) //basic ass input system, it doesnt need to be complicated
			{

				//time to redo this lol
				var daNote = closestNotes[0];

				if (daNote.noteData == data)
					goodNoteHit(daNote, playernum);

				if (closestNotes.length > 1)
				{
					var nextNote = closestNotes[1];

					if (nextNote.noteData != daNote.noteData)
					{
						for (shitNote in closestNotes)
						{
							if (shitNote.strumTime == daNote.strumTime)
							{
								if (shitNote.noteData == data)
									goodNoteHit(shitNote, playernum);
							}
							else if ((!shitNote.isSustainNote && (shitNote.strumTime - daNote.strumTime) < 35) && shitNote.noteData == daNote.noteData)
							{
								goodNoteHit(shitNote, playernum);
							}
							else
							{
								if (shitNote.noteData == data)
									goodNoteHit(shitNote, playernum);
							}
						}
	
					}
					else if (nextNote.noteData == daNote.noteData)
					{
						if (!nextNote.isSustainNote && ((nextNote.strumTime - daNote.strumTime) < 35))
						{
							goodNoteHit(nextNote, playernum);
						}
					}
					


				}
			}
			else if (!SaveData.ghost && songStarted && !grace)
			{
				trace("you mispressed you dumbass");
				missPress(data, playernum);
			}
	}
	var songStarted = false;
	function startSong():Void
	{
		startingSong = false;
		songStarted = true;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Sound.fromFile(Paths.inst(PlayState.SONG.song)), 1, false);

		if (SaveData.noteSplash)
			{
				switch (maniaToChange)
				{
					case 0: 
						NoteSplash.colors = ['purple', 'blue', 'green', 'red'];
					case 1: 
						NoteSplash.colors = ['purple', 'green', 'red', 'yellow', 'blue', 'darkblue'];	
					case 2: 
						NoteSplash.colors = ['purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'darkred', 'darkblue'];
					case 3: 
						NoteSplash.colors = ['purple', 'blue', 'white', 'green', 'red'];
					case 4: 
						NoteSplash.colors = ['purple', 'green', 'red', 'white', 'yellow', 'blue', 'darkblue'];
					case 5: 
						NoteSplash.colors = ['purple', 'blue', 'green', 'red', 'yellow', 'violet', 'darkred', 'darkblue'];
					case 6: 
						NoteSplash.colors = ['white'];
					case 7: 
						NoteSplash.colors = ['purple', 'red'];
					case 8: 
						NoteSplash.colors = ['purple', 'white', 'red'];
				}
			}
		
		SaveData.fixColorArray(maniaToChange);

		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		songLength = FlxG.sound.music.length;
		#if desktop
		// Song duration in a float, useful for the time left feature

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
		#end
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Sound.fromFile(Paths.voices(PlayState.SONG.song)));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		P1notes = new FlxTypedGroup<Note>();
		add(P1notes);

		P2notes = new FlxTypedGroup<Note>();
		add(P2notes);

		P3notes = new FlxTypedGroup<Note>();
		add(P3notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var mn:Int = keyAmmo[mania];
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				if (songNotes[1] >= 0)
				{
					var daStrumTime:Float = songNotes[0];
					if (daStrumTime < 0)
						daStrumTime = 0;
	
					var daNoteData:Int = Std.int(songNotes[1] % mn);
	
	
					var gottaHitNote:Bool = section.mustHitSection;
	
					if (songNotes[1] >= mn)
					{
						gottaHitNote = !section.mustHitSection;
					}
	
					var oldNote:Note;
					if (unspawnNotes.length > 0)
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					else
						oldNote = null;
	
					var daType = songNotes[3];
	
					var daSpeed = songNotes[4];
	
					var daVelocityData = songNotes[5];
	
					var t = Std.int(songNotes[1] / 18); //compatibility with god mode final destination
					switch(t)
					{
						case 1: 
							daType = 2;
							gottaHitNote = !gottaHitNote;
						case 2: 
							daType = 3;
							gottaHitNote = !gottaHitNote;
					}
	
					var swagNote:Note = new Note(daStrumTime, daNoteData, daType, false, daSpeed, daVelocityData, false, false, gottaHitNote, oldNote);
					swagNote.sustainLength = songNotes[2];
					swagNote.scrollFactor.set(0, 0);
					swagNote.startPos = calculateStrumtime(swagNote, daStrumTime);
	
					var susLength:Float = swagNote.sustainLength;
	
					susLength = susLength / Conductor.stepCrochet;
					unspawnNotes.push(swagNote);

					if (susLength <= 2 && susLength != 0)
						susLength++; //make small sussy bois longer so you can see them
	
	
	
					for (susNote in 0...Math.floor(susLength))
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
						var speedToUse = SongSpeed;
						if (daSpeed != null || daSpeed > 1)
							speedToUse = daSpeed;
						
						var susStrum = daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / speedToUse);
	
						var sustainNote:Note = new Note(susStrum, daNoteData, daType, true, daSpeed, daVelocityData, false, false, gottaHitNote, oldNote);
						sustainNote.scrollFactor.set();
						unspawnNotes.push(sustainNote);
						sustainNote.startPos = calculateStrumtime(sustainNote, susStrum);
	
						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
					}
	
					if (swagNote.mustPress)
					{
						swagNote.x += FlxG.width / 2; // general offset
					}
					else {}
				}
				else if (songNotes[1] >= -3) //for gf notes (also in case notedata is less than -3)
				{
					var daStrumTime:Float = songNotes[0];
					if (daStrumTime < 0)
						daStrumTime = 0;
	
					var daNoteData:Int = Std.int(songNotes[1] + 4);

					var daVelocityData = songNotes[5];

					var oldNote:Note;
					if (unspawnNotes.length > 0)
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					else
						oldNote = null;

					var swagNote:Note = new Note(daStrumTime, daNoteData, 0, false, 1, daVelocityData, false, true, false, oldNote);
					swagNote.startPos = calculateStrumtime(swagNote, daStrumTime);
					unspawnNotes.push(swagNote);
				}
				
			}
			daBeats += 1;
		}

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(playernum:Int):Void
	{
		for (i in 0...keyAmmo[maniaToChange])
		{
			var style:String = "normal";

			var babyArrow:BabyArrow = new BabyArrow(strumLine.y, playernum, i, style, true);

			babyArrow.ID = i;

			switch (playernum)
			{
				case 0:
					cpuStrums.add(babyArrow);
					//if (PlayStateChangeables.bothSide)
						//babyArrow.x -= 500;
				case 1:
					playerStrums.add(babyArrow);
			}

			cpuStrums.forEach(function(spr:BabyArrow)
				{					
					spr.centerOffsets();
				});
	
			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
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

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if desktop
			if (startTimer.finished)
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
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	function calculateStrumtime(daNote:Note, Strumtime:Float) //for note velocity shit, used andromeda engine as a guide for this https://github-dotcom.gateway.web.tr/nebulazorua/andromeda-engine
	{
		var ChangeTime:Float = daNote.strumTime - daNote.velocityChangeTime;
		var StrumDiff = Strumtime - ChangeTime;
		var Multi:Float = 1;
		if (Strumtime >= ChangeTime)
			Multi = daNote.speedMulti;

		var pos = ChangeTime * daNote.speed;
		pos += (StrumDiff * (daNote.speed * Multi));
		return pos;
	}

	function NotePositionShit(daNote:Note, strums:String)
	{
		if (daNote.y > FlxG.height)
		{
			daNote.active = false;
			daNote.visible = false;
		}
		else
		{
			daNote.visible = true;
			daNote.active = true;
		}

		var NoteY:Float = 0;
		var NoteX:Float = 0;
		var NoteAngle:Float = 0;
		var NoteAlpha:Float = 1;
		var NoteVisible:Bool = true;
		var StrumNote:BabyArrow;

		var WasGoodHit:Bool = daNote.wasGoodHit; //so it doesnt have to check multiple times
		var IsSustainNote:Bool = daNote.isSustainNote; //its running this shit every frame for every note
		var MustPress:Bool = daNote.mustPress;
		var CanBeHit:Bool = daNote.canBeHit;
		var TooLate:Bool = daNote.tooLate;
		var NoteData:Int = daNote.noteData;
		
		if (strums == 'player') //playerStrums
		{
			StrumNote = playerStrums.members[Math.floor(Math.abs(daNote.noteData))];
			NoteX = StrumNote.x;
			NoteY = StrumNote.y;
			NoteAngle = StrumNote.angle;
			NoteAlpha = StrumNote.alpha;
			NoteVisible = StrumNote.visible;
		}
		else //cpuStrums
		{
			StrumNote = cpuStrums.members[Math.floor(Math.abs(daNote.noteData))];
			NoteX = StrumNote.x;
			NoteY = StrumNote.y;
			NoteAngle = StrumNote.angle;
			NoteAlpha = StrumNote.alpha;
			NoteVisible = StrumNote.visible;
		}
		var MiddleOfNote:Float = NoteY + Note.swagWidth / 2;
		var calculatedStrumtime = calculateStrumtime(daNote, Conductor.songPosition);
		


		daNote.y = (NoteY + 0.45 * (daNote.startPos - calculatedStrumtime));
		/*if (IsSustainNote)
			daNote.y -= daNote.sustainOffset;
		if (daNote.isSustainEnd)
			daNote.y -= daNote.height - daNote.sustainOffset;*/ //found a better method, but it fucks with clipping
			
		if (flipped || (multiplayer && strums == "cpu"))
			MustPress = !MustPress; //this is just for detecting it, not actually a must press note lol
		

		//TODO: fix clipping, idk what tf im doing lol
		/*if (IsSustainNote
			&& daNote.y + daNote.offset.y * daNote.scale.y <= MiddleOfNote
			&& (!MustPress || (WasGoodHit || (daNote.prevNote.wasGoodHit && !CanBeHit))))
		{
			var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
			//swagRect.y = ;
			//swagRect.y = (MiddleOfNote - daNote.y) / daNote.scale.y / daNote.speed;
			swagRect.height -= (MiddleOfNote - daNote.y) / daNote.scale.y;
			swagRect.y = (daNote.width / daNote.scale.x) - swagRect.height;

			daNote.clipRect = swagRect;
		}*/

		if (IsSustainNote) //im not sure if doing multiple if statements is bad for performace, but at least it looks much nicer
			if (!MustPress || (WasGoodHit || (daNote.prevNote.wasGoodHit && !CanBeHit)))
				if (daNote.y + (daNote.offset.y) <= MiddleOfNote)
				{
					var fuckYouRect = new FlxRect(0, MiddleOfNote - daNote.y, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
					fuckYouRect.y /= daNote.scale.y;
					fuckYouRect.height -= fuckYouRect.y; ///finalllly it works!!!!!!!! ahhhhhhhhhhhhhhhhhhhh
														//fuck you clipping
					daNote.clipRect = fuckYouRect;
				}

		daNote.x = NoteX;
		daNote.visible = NoteVisible;
		if (IsSustainNote)
		{
			daNote.alpha = NoteAlpha * 0.6;

			daNote.x = StrumNote.x + (Note.sustainXOffsets[maniaToChange] * daNote.scaleMulti) - (StrumNote.width / 2);
			if (daNote.style == 'pixel')
				daNote.x -= 11;
		}
		else
		{
			daNote.alpha = NoteAlpha;
			daNote.angle = NoteAngle;
		}
		if (SaveData.downscroll && (daNote.burning || daNote.death || daNote.warning || daNote.angel || daNote.bob || daNote.glitch))
			daNote.y += 75; //y offset of notetypes  (only downscroll for some reason, weird shit with the graphic flip)

	}

	function NoteMissDetection(daNote:Note, strums:String, playernum:Int = 1)
	{
		var WasGoodHit:Bool = daNote.wasGoodHit; //so it doesnt have to check multiple times
		var IsSustainNote:Bool = daNote.isSustainNote; //its running this shit every frame for every note
		var MustPress:Bool = daNote.mustPress;
		var CanBeHit:Bool = daNote.canBeHit;
		var TooLate:Bool = daNote.tooLate;
		var NoteData:Int = daNote.noteData;

		if (strums == "cpu")
			MustPress = !MustPress; //this is just for detecting it, not actually a must press note lol

		if (IsSustainNote && WasGoodHit && Conductor.songPosition >= daNote.strumTime)
			removeNote(daNote, strums);
		else if (MustPress && (TooLate && !WasGoodHit))
		{
			if (daNote.normalNote)
			{
				if (IsSustainNote && WasGoodHit) //to 100% make sure the sustain is gone
					{
						daNote.kill();
						removeNote(daNote, strums);
					}
					else
					{
						vocals.volume = 0;
						noteMiss(NoteData, daNote, playernum);								
					}
				removeNote(daNote, strums);
			}
			else if (daNote.badNoteType)
			{
				removeNote(daNote, strums);
			}
			else if (daNote.warningNoteType)
			{
				misses++;
				badNoteHit();
				removeNote(daNote, strums);
				switch (daNote.noteType)
				{
					case 3: //regular warning note
						health -= 1;
						vocals.volume = 0;
					case 7: //glitch note
						HealthDrain();
				}
			}
		}
	}

	function NoteCpuHit(daNote:Note, strums:String)
	{
		var WasGoodHit:Bool = daNote.wasGoodHit;
		var NoteData:Int = daNote.noteData;

		if (WasGoodHit)
		{
			if (SONG.song != 'Tutorial')
				camZooming = true;

			var altAnim:String = "";

			if (currentSection != null)
			{
				if (currentSection.altAnim)
					altAnim = '-alt';
			}

			if (daNote.alt)
				altAnim = '-alt';

			if (!daNote.badNoteType)
				cpu.playAnim('sing' + sDir[NoteData] + altAnim, true);

			if (flipped)
			{
				playerStrums.forEach(function(spr:BabyArrow)
				{
					if (Math.abs(NoteData) == spr.ID)
					{
						if (!daNote.badNoteType)
							spr.playAnim('confirm', true, spr.ID);
					}
				});
			}
			else
			{
				cpuStrums.forEach(function(spr:BabyArrow)
				{
					if (Math.abs(NoteData) == spr.ID)
					{
						if (!daNote.badNoteType)
							spr.playAnim('confirm', true, spr.ID);
					}
				});
			}
			if (!daNote.badNoteType)
				cpu.holdTimer = 0;

			if (SONG.needsVoices)
				vocals.volume = 1;

			daNote.active = false;

			removeNote(daNote, strums);
		}
	}
	function GFNoteHit(daNote:Note)
	{
		var WasGoodHit:Bool = daNote.wasGoodHit;
		var NoteData:Int = daNote.noteData;

		daNote.visible = false;

		if (WasGoodHit)
		{
			if (SONG.song != 'Tutorial')
				camZooming = true;

			var altAnim:String = "";

			if (daNote.alt)
				altAnim = '-alt';

			gf.playAnim('sing' + sDir[NoteData] + altAnim, true);
			gf.holdTimer = 0;

			if (SONG.needsVoices)
				vocals.volume = 1;

			daNote.active = false;

			daNote.kill();
			P3notes.remove(daNote, true);
			daNote.destroy();
		}
	}

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		super.update(elapsed);

		
		if (multiplayer)
			scoreTxt.text = "P2 Misses:" + P2misses + "  P2 Combo: " + P2combo + "  P1 Misses: " + misses + "   P1 Combo: " + combo; 
		else
			scoreTxt.text = "Score:" + songScore + "  Rank: " + curRank + "  Accuracy: " + accuracy + "%   Misses: " + misses; 

		var timeLeft = songLength - FlxG.sound.music.time;
		var time:Date = Date.fromTime(timeLeft);
		var mins = time.getMinutes();
		var secs = time.getSeconds();
		if (secs < 10) //so it looks right
			TimeText.text = songtext + " - " + mins + ":" + "0" + secs + modeText; 
		else
			TimeText.text = songtext + " - " + mins + ":" + secs + modeText; 
		

		var currentBeat = (Conductor.songPosition / 1000)*(SONG.bpm/60);

		playerStrums.forEach(function(spr:BabyArrow)
		{
			if (ModchartUtil.pXEnabled)
			{
				ModchartUtil.ChangeArrowX(spr, ModchartUtil.CalculateArrowShit(
					spr,
					spr.ID,
					ModchartUtil.pXnum,
					0,
					currentBeat + ModchartUtil.pXbeatShit,
					ModchartUtil.pXExtra,
					ModchartUtil.pXPi,
					ModchartUtil.pXSin
				));
			}
			if (ModchartUtil.pYEnabled)
			{
				ModchartUtil.ChangeArrowY(spr, ModchartUtil.CalculateArrowShit(
					spr,
					spr.ID,
					ModchartUtil.pYnum,
					1,
					currentBeat + ModchartUtil.pYbeatShit,
					ModchartUtil.pYExtra,
					ModchartUtil.pYPi,
					ModchartUtil.pYSin
				));
			}
			if (ModchartUtil.pAngleEnabled)
			{
				ModchartUtil.ChangeArrowAngle(spr, ModchartUtil.CalculateArrowShit(
					spr,
					spr.ID,
					ModchartUtil.pAnglenum,
					2,
					currentBeat + ModchartUtil.pAnglebeatShit,
					ModchartUtil.pAngleExtra,
					ModchartUtil.pAnglePi,
					ModchartUtil.pAngleSin
				));
			}
		});
		cpuStrums.forEach(function(spr:BabyArrow)
		{
			if (ModchartUtil.cpuXEnabled)
			{
				ModchartUtil.ChangeArrowX(spr, ModchartUtil.CalculateArrowShit(
					spr,
					spr.ID,
					ModchartUtil.cpuXnum,
					0,
					currentBeat + ModchartUtil.cpuXbeatShit,
					ModchartUtil.cpuXExtra,
					ModchartUtil.cpuXPi,
					ModchartUtil.cpuXSin
				));
			}
			if (ModchartUtil.cpuYEnabled)
			{
				ModchartUtil.ChangeArrowX(spr, ModchartUtil.CalculateArrowShit(
					spr,
					spr.ID,
					ModchartUtil.cpuYnum,
					1,
					currentBeat + ModchartUtil.cpuYbeatShit,
					ModchartUtil.cpuYExtra,
					ModchartUtil.cpuYPi,
					ModchartUtil.cpuYSin
				));
			}
			if (ModchartUtil.cpuAngleEnabled)
			{
				ModchartUtil.ChangeArrowX(spr, ModchartUtil.CalculateArrowShit(
					spr,
					spr.ID,
					ModchartUtil.cpuAnglenum,
					2,
					currentBeat + ModchartUtil.cpuAnglebeatShit,
					ModchartUtil.cpuAngleExtra,
					ModchartUtil.cpuAnglePi,
					ModchartUtil.cpuAngleSin
				));
			}

		});




		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{

			persistentUpdate = false;
			persistentDraw = true;
			paused = true;



			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		
			#if desktop
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (FlxG.keys.justPressed.SEVEN && songStarted && FlxG.keys.pressed.SHIFT)
		{
			LoadingState.loadAndSwitchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor: " + SONG.song + " (" + storyDifficultyText + ")", null, null, true);
			#end
			Main.editor = true;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN,handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		if (health > 2)
			health = 2;

		if (P2health > 2)
			P2health = 2;

		combinedHealth = health - P2health;

		if (combinedHealth > 2)
			combinedHealth = 2;
		else if (combinedHealth < -2)
			combinedHealth = -2;



		if (centerHealthBar)
		{
			iconP1.y = healthBar.y + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (healthBar.width / 2) - iconP1.height / 2;
			iconP2.y = healthBar.y + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (healthBar.width / 2) - iconP2.height / 2;

			iconP1.x = healthBar.x + ((healthBar.width / 2) - iconOffset);
			iconP2.x = healthBar.x + ((healthBar.width / 2) - (iconP2.width - iconOffset));
		}
		else
		{
			iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
			iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
		}



		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new AnimationDebug(SONG.player2));
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			currentSection = SONG.notes[Std.int(curStep / 16)];

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && currentSection != null)
		{
			closestNotes = [];
			P2closestNotes = [];
			if (multiplayer)
			{
				P1notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
						closestNotes.push(daNote);
				}); // Collect notes that can be hit
				P2notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && !daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
						P2closestNotes.push(daNote);
				}); 
			}
			else if (flipped)
			{
				P2notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && !daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
						closestNotes.push(daNote);
				}); // Collect notes that can be hit
			}

			else
			{
				P1notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
						closestNotes.push(daNote);
				}); // Collect notes that can be hit
			}
			

			closestNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			if (camFollow.x != dad.getMidpoint().x + 150 && !currentSection.mustHitSection)
			{

				var camOffset = dad.posOffsets.get('cam'); //offset in character.hx
				if (dad.posOffsets.exists('cam'))
				{
					camFollow.setPosition(dad.getMidpoint().x + camOffset[0], dad.getMidpoint().y + camOffset[1]);
				}
				else
					camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);

				

				if (dad.curCharacter == 'mom')
					vocals.volume = 1;

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					tweenCamIn();
				}
			}

			if (currentSection.mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				var yoffset:Float = -100;
				var xoffset:Float = -100;
				switch (curStage) //offset is where stages are
				{
					case 'limo':
						xoffset = -300;
					case 'mall':
						yoffset = -200;
					case 'school' | 'schoolEvil':
						xoffset = -200;
						yoffset = -200;
				}

				camFollow.setPosition(boyfriend.getMidpoint().x + xoffset, boyfriend.getMidpoint().y + yoffset);

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);

			camP1Notes.zoom = camHUD.zoom;
			camP2Notes.zoom = camHUD.zoom;
			camSustains.zoom = camHUD.zoom;
		}
		camP1Notes.x = camHUD.x; //so they match up when it moves, pretty much will just be for modcharts and shit
		camP1Notes.y = camHUD.y;
		camP1Notes.angle = camHUD.angle;
		camP2Notes.x = camHUD.x;
		camP2Notes.y = camHUD.y;
		camP2Notes.angle = camHUD.angle;
		camOnTop.x = camHUD.x;
		camOnTop.y = camHUD.y;
		camOnTop.angle = camHUD.angle;

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}

		if (health <= 0 || P2health <= 0)
		{
			player.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			
			#if desktop
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500)
			{
				var dunceNote:Note = unspawnNotes[0];
				if (dunceNote.isGFNote)
					P3notes.add(dunceNote);
				else if (dunceNote.mustPress)
					P1notes.add(dunceNote);
				else if (!dunceNote.mustPress)
					P2notes.add(dunceNote);
				

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		switch(maniaToChange)
		{
			case 0: 
				sDir = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
			case 1: 
				sDir = ['LEFT', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'RIGHT'];
			case 2: 
				sDir = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'UP', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
			case 3: 
				sDir = ['LEFT', 'DOWN', 'UP', 'UP', 'RIGHT'];
			case 4: 
				sDir = ['LEFT', 'UP', 'RIGHT', 'UP', 'LEFT', 'DOWN', 'RIGHT'];
			case 5: 
				sDir = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
			case 6: 
				sDir = ['UP'];
			case 7: 
				sDir = ['LEFT', 'RIGHT'];
			case 8:
				sDir = ['LEFT', 'UP', 'RIGHT'];
		}


		if (generatedMusic)
		{
			P1notes.forEachAlive(function(daNote:Note)
			{
				NotePositionShit(daNote, "player");
				if (flipped && !multiplayer)
					NoteCpuHit(daNote, "player");
				else
					NoteMissDetection(daNote, "player", 1);
			});
			P2notes.forEachAlive(function(daNote:Note)
			{
				NotePositionShit(daNote, "cpu");
				if (multiplayer)
					NoteMissDetection(daNote, "cpu", 0);
				else if (flipped && !multiplayer)
					NoteMissDetection(daNote, "cpu", 1);
				else
					NoteCpuHit(daNote, "cpu");
			});
			P3notes.forEachAlive(function(daNote:Note)
			{
				GFNoteHit(daNote);
			});
		}
		if (flipped && !multiplayer)
		{
			playerStrums.forEach(function(spr:BabyArrow)
			{
				if (spr.animation.finished)
				{
					spr.playAnim('static',false , spr.ID);
					spr.centerOffsets();
				}
			});
		}
		else if (!multiplayer)
		{
			cpuStrums.forEach(function(spr:BabyArrow)
			{
				if (spr.animation.finished)
				{
					spr.playAnim('static',false , spr.ID);
					spr.centerOffsets();
				}
			});
		}


		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	function endSong():Void
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN,handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		FlxG.sound.music.pause();
		vocals.pause();
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
			#end
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				FlxG.switchState(new StoryMenuState());

				// if ()
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore)
				{
					NGio.unlockMedal(60961);
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				var formmatedShit = CoolUtil.getSongFromJsons(PlayState.storyPlaylist[0].toLowerCase(), storyDifficulty);

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(formmatedShit, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				LoadingState.loadAndSwitchState(new PlayState());
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(note:Note = null, playernum:Int = 1):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var daCombo:Int = combo;
		if (playernum != 1)
			daCombo = P2combo;

		var placement:String = Std.string(daCombo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * 0.85)
		{
			daRating = 'shit';
			score = 50;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.70)
		{
			daRating = 'bad';
			score = 100;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.3)
		{
			daRating = 'good';
			score = 200;
		}

		note.rating = daRating;

		totalNotesHit++;
		var healthChanges:Float = 0;

		switch (daRating)
		{
			case "sick": 
				sicks++;
				scoreTxt.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
				healthChanges += 0.15;
			case "good": 
				goods++;
				scoreTxt.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.GREEN, LEFT, OUTLINE, FlxColor.BLACK);
				healthChanges += 0.1;
			case "bad": 
				bads++;
				scoreTxt.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.RED, LEFT, OUTLINE, FlxColor.BLACK);
				if (!SaveData.casual)
					healthChanges -= 0.04;
			case "shit":
				shits++;
				scoreTxt.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.GRAY, LEFT, OUTLINE, FlxColor.BLACK);
				if (!SaveData.casual)
					healthChanges -= 0.1;
		}

		if (playernum == 1)
			health += healthChanges;
		else
			P2health += healthChanges;

		

		songScore += score;

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(daCombo / 100));
		seperatedScore.push(Math.floor((daCombo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(daCombo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!curStage.startsWith('school'))
			{
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (daCombo >= 10 || daCombo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	private function keyShit():Void
	{

		// HOLDS, check for sustain notes
		if ((keys.contains(true) || P2keys.contains(true))&& /*!boyfriend.stunned && */ generatedMusic)
		{
			if (multiplayer)
			{
				P1notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && keys[daNote.noteData])
						goodNoteHit(daNote);
				});
				P2notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.isSustainNote && daNote.canBeHit && !daNote.mustPress && P2keys[daNote.noteData])
						goodNoteHit(daNote, 0);
				});
			}
			else if (flipped && !multiplayer)
			{
				P2notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.isSustainNote && daNote.canBeHit && !daNote.mustPress && keys[daNote.noteData])
						goodNoteHit(daNote);
				});
			}
			else
			{
				P1notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && keys[daNote.noteData])
						goodNoteHit(daNote);
				});
			}
		}

		if (player.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!keys.contains(true)))
		{
			if (player.animation.curAnim.name.startsWith('sing') && !player.animation.curAnim.name.endsWith('miss'))
				player.dance();
		}
		if (multiplayer)
		{
			if (player2.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!P2keys.contains(true)))
				{
					if (player2.animation.curAnim.name.startsWith('sing') && !player2.animation.curAnim.name.endsWith('miss'))
						player2.dance();
				}
		}


		if (multiplayer)
		{
			playerStrums.forEach(function(spr:BabyArrow)
			{
				if (keys[spr.ID] && spr.animation.curAnim.name != 'confirm' && spr.animation.curAnim.name != 'pressed')
					spr.playAnim('pressed', false, spr.ID);
				if (!keys[spr.ID])
					spr.playAnim('static', false, spr.ID);
			});
			cpuStrums.forEach(function(spr:BabyArrow)
			{
				if (P2keys[spr.ID] && spr.animation.curAnim.name != 'confirm' && spr.animation.curAnim.name != 'pressed')
					spr.playAnim('pressed', false, spr.ID);
				if (!P2keys[spr.ID])
					spr.playAnim('static', false, spr.ID);
			});
		}
		else if (flipped && !multiplayer)
		{
			cpuStrums.forEach(function(spr:BabyArrow)
			{
				if (keys[spr.ID] && spr.animation.curAnim.name != 'confirm' && spr.animation.curAnim.name != 'pressed')
					spr.playAnim('pressed', false, spr.ID);
				if (!keys[spr.ID])
					spr.playAnim('static', false, spr.ID);
			});
		}
		else
		{
			playerStrums.forEach(function(spr:BabyArrow)
			{
				if (keys[spr.ID] && spr.animation.curAnim.name != 'confirm' && spr.animation.curAnim.name != 'pressed')
					spr.playAnim('pressed', false, spr.ID);
				if (!keys[spr.ID])
					spr.playAnim('static', false, spr.ID);
			});
		}

	}

	function noteMiss(direction:Int = 1, daNote:Note, playernum:Int = 1):Void
	{
		switch (playernum) //idk why am doing it like this but who cares, il fix it at some point
			{
				case 0: 
					if (!player2.stunned)
						{
							if (daNote.isSustainNote)
								P2health -= 0.03;
							else
								P2health -= 0.15;
				
							if (combo > 5 && gf.animOffsets.exists('sad'))
							{
								gf.playAnim('sad');
							}
							P2combo = 0;
				
							if (!daNote.isSustainNote)
								P2misses++; //so you dont get like 20 misses from a long note
				
							totalNotesHit++; //not actually missing, just for working out the accuracy
				
							CalculateAccuracy();
				
							songScore -= 10;
				
							FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
							// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
							// FlxG.log.add('played imss note');
							if (daNote.mustPress)
								player.playAnim('sing' + sDir[direction] + 'miss', true);
							else
							{
								if (multiplayer)
								{
									player2.color = 0x00303f97;
									player2.playAnim('sing' + sDir[direction], true);
								}
								else
								{
									player.color = 0x00303f97;
									player.playAnim('sing' + sDir[direction], true);
								}
							}
				
							scoreTxt.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.RED, LEFT, OUTLINE, FlxColor.BLACK);
				
							player2.stunned = true;
				
				
							// get stunned for 5 seconds
							new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
							{
								player2.stunned = false;
								if (multiplayer)
								{
									player2.color = 0x00FFFFFF;
								}
								else
								{
									player.color = 0x00FFFFFF;
								}
							});
				
						}
				case 1: 
					if (!player.stunned)
						{
							if (daNote.isSustainNote)
								health -= 0.03;
							else
								health -= 0.15;
				
							if (combo > 5 && gf.animOffsets.exists('sad'))
							{
								gf.playAnim('sad');
							}
							combo = 0;
				
							if (!daNote.isSustainNote)
								misses++; //so you dont get like 20 misses from a long note
				
							totalNotesHit++; //not actually missing, just for working out the accuracy
				
							CalculateAccuracy();
				
							songScore -= 10;
				
							FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
							// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
							// FlxG.log.add('played imss note');
							if (daNote.mustPress)
								player.playAnim('sing' + sDir[direction] + 'miss', true);
							else
							{
								if (multiplayer)
								{
									player2.color = 0x00303f97;
									player2.playAnim('sing' + sDir[direction], true);
								}
								else
								{
									player.color = 0x00303f97;
									player.playAnim('sing' + sDir[direction], true);
								}
							}
				
							scoreTxt.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.RED, LEFT, OUTLINE, FlxColor.BLACK);
				
							player.stunned = true;
				
				
							// get stunned for 5 seconds
							new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
							{
								player.stunned = false;
								if (multiplayer)
								{
									player2.color = 0x00FFFFFF;
								}
								else
								{
									player.color = 0x00FFFFFF;
								}
							});
				
						}
			}
		
	}
	function missPress(direction:Int = 1, playernum:Int = 1):Void //copied, just to stop game from crashing
		{
			switch (playernum) //idk why am doing it like this but who cares, il fix it at some point //TODO
			{
				case 0: 
					if (!player2.stunned)
					{
						P2health -= 0.04;
			
						if (combo > 5 && gf.animOffsets.exists('sad'))
						{
							gf.playAnim('sad');
						}
						P2combo = 0;
						
						P2misses++;
			
						totalNotesHit++; //not actually missing, just for working out the accuracy
			
						CalculateAccuracy();
			
						songScore -= 10;
			
						FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
						if (playernum == 1 && !flipped)
							player.playAnim('sing' + sDir[direction] + 'miss', true);
						else
						{
							if (multiplayer)
							{
								player2.color = 0x00303f97;
								player2.playAnim('sing' + sDir[direction], true);
							}
							else
							{
								player.color = 0x00303f97;
								player.playAnim('sing' + sDir[direction], true);	
							}
						}
						scoreTxt.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.RED, LEFT, OUTLINE, FlxColor.BLACK);
			
						player2.stunned = true;
						// get stunned for 5 seconds
						new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
						{
							player2.stunned = false;
							if (multiplayer)
							{
								player2.color = 0x00FFFFFF;
							}
							else
							{
								player.color = 0x00FFFFFF;
							}
						});
			
					}

				case 1: 
					if (!player.stunned)
						{
							health -= 0.04;
				
							if (combo > 5 && gf.animOffsets.exists('sad'))
							{
								gf.playAnim('sad');
							}
							combo = 0;
							
							misses++;
				
							totalNotesHit++; //not actually missing, just for working out the accuracy
				
							CalculateAccuracy();
				
							songScore -= 10;
				
							FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
							if (playernum == 1 && !flipped)
								player.playAnim('sing' + sDir[direction] + 'miss', true);
							else
							{
								if (multiplayer)
								{
									player2.color = 0x00303f97;
									player2.playAnim('sing' + sDir[direction], true);
								}
								else
								{
									player.color = 0x00303f97;
									player.playAnim('sing' + sDir[direction], true);	
								}
							}
							scoreTxt.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.RED, LEFT, OUTLINE, FlxColor.BLACK);
				
							player.stunned = true;
							// get stunned for 5 seconds
							new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
							{
								player.stunned = false;
								if (multiplayer)
								{
									player2.color = 0x00FFFFFF;
								}
								else
								{
									player.color = 0x00FFFFFF;
								}
							});
				
						}
			}
			
		}



	function goodNoteHit(note:Note, playernum:Int = 1):Void
	{
		if (!note.wasGoodHit)
		{
			var healthChanges:Float = 0;
			if (!note.isSustainNote)
			{
				popUpScore(note, playernum);
				if (playernum == 1)
					combo += 1;
				else
					P2combo += 1;
			}
			else
			{
				note.rating = "sick";
				sicks++;
				totalNotesHit++;
			}

			if (!note.isSustainNote || SaveData.casual)
				healthChanges += 0.02;

			var altAnim:String = "";

			if (currentSection != null)
				{
					if (currentSection.altAnim)
						altAnim = '-alt';
				}	
			if (note.alt)
				altAnim = '-alt';

			if (playernum == 1)
			{
				player.playAnim('sing' + sDir[note.noteData] + altAnim, true);
				player.holdTimer = 0;
			}
			else
			{
				player2.playAnim('sing' + sDir[note.noteData] + altAnim, true);
				player2.holdTimer = 0;
			}



			if (note.burning) //fire note
				{
					badNoteHit();
					healthChanges -= 0.45;
				}

			else if (note.death) //halo note
				{
					badNoteHit();
					healthChanges -= 2.2;
				}
			else if (note.angel) //angel note
				{
					switch(note.rating)
					{
						case "shit": 
							badNoteHit();
							healthChanges -= 2;
						case "bad": 
							badNoteHit();
							healthChanges -= 0.5;
						case "good": 
							healthChanges += 0.5;
						case "sick": 
							healthChanges += 1;

					}
				}
			else if (note.bob) //bob note
				{
					HealthDrain();
				}

			CalculateAccuracy();

			if (playernum == 1)
				health += healthChanges;
			else
				P2health += healthChanges;


			


			if (flipped && !multiplayer)
			{
				cpuStrums.forEach(function(spr:BabyArrow)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.playAnim('confirm', true, spr.ID);
					}
				});
			}
			else
			{
				switch (playernum)
				{
					case 0: 
						cpuStrums.forEach(function(spr:BabyArrow)
						{
							if (Math.abs(note.noteData) == spr.ID)
							{
								spr.playAnim('confirm', true, spr.ID);
							}
						});
					case 1: 
						playerStrums.forEach(function(spr:BabyArrow)
						{
							if (Math.abs(note.noteData) == spr.ID)
							{
								spr.playAnim('confirm', true, spr.ID);
							}
						});
				}

			}

			note.wasGoodHit = true;
			vocals.volume = 1;
			var strums = "player";
			if (flipped)
				strums = "cpu";

			if (!note.isSustainNote)
			{
				if (note.rating == "sick")
					doNoteSplash(note.x, note.y, note.noteData, playernum);
				removeNote(note, strums);
			}
			grace = true;
			new FlxTimer().start(0.15, function(tmr:FlxTimer)
			{
				grace = false;
			});
		}
	}
	function doNoteSplash(noteX:Float, noteY:Float, nData:Int, playernum:Int = 1)
		{
			
			var recycledNote = noteSplashes.recycle(NoteSplash);
			var xPos:Float = 0;
			var yPos:Float = 0;
			xPos = playerStrums.members[nData].x;
			yPos = playerStrums.members[nData].y;
			if (playernum == 0 || (flipped && !multiplayer))
			{
				recycledNote = P2noteSplashes.recycle(NoteSplash);
				xPos = cpuStrums.members[nData].x;
				yPos = cpuStrums.members[nData].y;
			}

			recycledNote.makeSplash(xPos, yPos, nData, playernum);
			if (playernum == 1)
				noteSplashes.add(recycledNote);
			else
				P2noteSplashes.add(recycledNote);
			
		}

	function HealthDrain():Void //code from vs bob
		{
			badNoteHit();
			new FlxTimer().start(0.01, function(tmr:FlxTimer)
			{
				health -= 0.005; //TODO
			}, 300);
		}

	function badNoteHit():Void
		{
			player.playAnim('hit', true);
			FlxG.sound.play(Paths.soundRandom('badnoise', 1, 3), FlxG.random.float(0.7, 1));
		}

	function removeNote(daNote:Note, strums:String = 'player'):Void
	{
		daNote.kill();
		if (strums == 'player')
			P1notes.remove(daNote, true);
		else
			P2notes.remove(daNote, true);
		daNote.destroy();
	}

	function updateRank():Void
	{
		var accuracyToRank:Array<Bool> = [
			accuracy <= 40,
			accuracy <= 50,
			accuracy <= 60,
			accuracy <= 70,
			accuracy <= 80,
			accuracy <= 90,
			accuracy <= 100,
		];

		if(misses == 0)
			curRank = "FC";
		else
		{
			for (i in 0...accuracyToRank.length)
			{
				if (accuracyToRank[i])
				{
					curRank = ranksList[i];
					break;
				}
			}
		}

	}
	
	function CalculateAccuracy():Void
	{
		var notesAddedUp = sicks + (goods * 0.75) + (bads * 0.5) + (shits * 0.25);
		accuracy = Math.floor((notesAddedUp / totalNotesHit) * 100);

		updateRank();
	}
	var justChangedMania:Bool = false;

	public function switchMania(newMania:Int) //TODO
	{
		if (mania == 2) //so it doesnt break the fucking game
		{
			maniaToChange = newMania;
			justChangedMania = true;
			new FlxTimer().start(10, function(tmr:FlxTimer)
				{
					justChangedMania = false; //cooldown timer
				});
			switch(newMania)
			{
				case 10: 
					Note.newNoteScale = 0.7; //fix the note scales pog
				case 11: 
					Note.newNoteScale = 0.6;
				case 12: 
					Note.newNoteScale = 0.5;
				case 13: 
					Note.newNoteScale = 0.65;
				case 14: 
					Note.newNoteScale = 0.58;
				case 15: 
					Note.newNoteScale = 0.55;
				case 16: 
					Note.newNoteScale = 0.7;
				case 17: 
					Note.newNoteScale = 0.7;
				case 18: 
					Note.newNoteScale = 0.7;
			}
	
			strumLineNotes.forEach(function(spr:FlxSprite)
			{
				spr.animation.play('static'); //changes to static because it can break the scaling of the static arrows if they are doing the confirm animation
				spr.setGraphicSize(Std.int((spr.width / Note.prevNoteScale) * Note.newNoteScale));
				spr.centerOffsets();
				Note.scaleSwitch = false;
			});
	
			cpuStrums.forEach(function(spr:BabyArrow)
			{
				spr.moveKeyPositions(spr, newMania, 0);
			});
			playerStrums.forEach(function(spr:BabyArrow)
			{
				spr.moveKeyPositions(spr, newMania, 1);
			});
	
		}
	}



	

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
			resyncVocals();
	}



	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			P1notes.sort(FlxSort.byY, FlxSort.DESCENDING);
			P2notes.sort(FlxSort.byY, FlxSort.DESCENDING);
			P3notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		StagePiece.daBeat = curBeat;
		for (piece in dancingStagePieces.members)
			piece.dance();

		if (currentSection != null)
		{
			if (currentSection.changeBPM)
			{
				Conductor.changeBPM(currentSection.bpm);
				FlxG.log.add('CHANGED BPM!');
			}

			// Dad doesnt interupt his own notes
			if (currentSection.mustHitSection && !multiplayer)
				cpu.dance();
		}
		wiggleShit.update(Conductor.crochet);

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
			gf.dance();

		if (!player.animation.curAnim.name.startsWith("sing"))
			player.dance();

		if (multiplayer)
			if (!player2.animation.curAnim.name.startsWith("sing"))
					player2.dance();


		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
			boyfriend.playAnim('hey', true);

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		switch (curStage)
		{		
			case "philly":
				if (curBeat % 4 == 0)
					StagePiece.curLight = FlxG.random.int(0, 4);
		}
	}
}
