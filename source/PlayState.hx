package;

import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
#if desktop
import Discord.DiscordClient;
#end

import openfl.ui.KeyLocation;
import openfl.events.Event;
import haxe.EnumTools;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
//import openfl.events.JoystickEvent;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepadManager;
import haxe.Exception;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import lime.graphics.Image;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import flixel.system.FlxAssets;
import openfl.utils.Assets as OpenFlAssets;

import lime.app.Application;
import lime.media.AudioContext;
import lime.media.AudioManager;
import openfl.Lib;
import Section.SwagSection;
import Song.SwagSong;
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
//import flixel.util.FlxCollision;
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
#end
import flash.media.Sound;

using StringTools;

//for anyone looking though the code,
//sorry if i put capitals at the start of variables/functions, i can't be bothered to change it, 
//i would prefer to keep consistancy, its mainly with P2 variables though

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
	public static var storySuffix:String = "";
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var mania:Int = 0;
	public static var p1Mania:Int = 0;
	public static var p2Mania:Int = 0;
	public static var keyAmmo:Array<Int> = [4, 6, 9, 5, 7, 8, 1, 2, 3];
	public static var SongSpeed:Float;
	public var songLength:Float = 0;
	private var vocals:FlxSound;
	private var curSong:String = "";
	public static var instance:PlayState = null; //to access in other places
	public var elapsedTime:Float = 0; //used for arrow movements and shit i think
	public static var rewinding:Bool = false;
	public static var regeneratingNotes:Bool = false;
	static var rewindOnDeath = false;

	/// modifier shit
	public static var SongSpeedMultiplier:Float = 1;
	public static var RandomSpeedChange:Bool = false;

	//characters
	public static var dad:Boyfriend;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;
	var oppenentColors:Array<Array<Float>>; //oppenents arrow colors and assets
	private var gfSpeed:Int = 1;
	private var combinedHealth:Float = 1;

	//note stuff
	private var P1notes:FlxTypedGroup<Note>; //bf
	private var P2notes:FlxTypedGroup<Note>; //dad
	private var P3notes:FlxTypedGroup<Note>; //gf (events notes pretty much lol)
	private var unspawnNotes:Array<Note> = [];
	var noteSplashes:FlxTypedGroup<NoteSplash>;
	var P2noteSplashes:FlxTypedGroup<NoteSplash>;

	public static var poisonDrain:Float = 0.075;
	public static var drainNoteAmount:Float = 0.025;

	public static var curP1NoteMania:Int = 0; //so i tried using a mapping system, but it sometimes decided to fuck up the scales, so il try this system again
	public static var curP2NoteMania:Int = 0;
	public static var prevP1NoteMania:Int = 0; 
	public static var prevP2NoteMania:Int = 0;
	public static var lastP1mChange:Float = 0; 
	public static var lastP2mChange:Float = 0;

	//sing animation arrays
	public static var sDir:Array<Dynamic> = [
		['LEFT', 'DOWN', 'UP', 'RIGHT'],
		['LEFT', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'RIGHT'],
		['LEFT', 'DOWN', 'UP', 'RIGHT', 'UP', 'LEFT', 'DOWN', 'UP', 'RIGHT'],
		['LEFT', 'DOWN', 'UP', 'UP', 'RIGHT'],
		['LEFT', 'UP', 'RIGHT', 'UP', 'LEFT', 'DOWN', 'RIGHT'],
		['LEFT', 'DOWN', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'UP', 'RIGHT'],
		['UP'],
		['LEFT', 'RIGHT'],
		['LEFT', 'UP', 'RIGHT'],
	]; 
	//regular singing animations
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
	public var ranksList:Array<String> = ["Skill Issue", "E", "D", "C", "B", "A", "S"]; //for score text

	public var P1Stats = {
		songScore : 0,
		fc : true,
		sicks : 0,
		goods : 0,
		bads : 0,
		shits : 0,
		misses : 0,
		ghostmisses : 0,
		totalNotesHit : 0,
		accuracy : 0.0,
		curRank : "None",
		combo : 0,
		highestCombo : 0,
		nps : 0,
		highestNps : 0,
		health : 1.0,
		poisonHits : 0,
		scorelerp : 0,
		acclerp : 0.0,
		npsArray : []
	};
	public var P2Stats = {
		songScore : 0,
		fc : true,
		sicks : 0,
		goods : 0,
		bads : 0,
		shits : 0,
		misses : 0,
		ghostmisses : 0,
		totalNotesHit : 0,
		accuracy : 0.0,
		curRank : "None",
		combo : 0,
		highestCombo : 0,
		nps : 0,
		highestNps : 0,
		health : 1.0,
		poisonHits : 0,
		scorelerp : 0,
		acclerp : 0.0,
		npsArray : []
	};


	
	//song stuff
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	//hud shit
	public var iconP1:HealthIcon; 
	public var iconP2:HealthIcon;
	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	var scoreTxt:FlxText;
	var timeText:FlxText;
	var songtext:String; //for time text
	var modeText:String; //also for time text
	var botPlayTxt:FlxText;
	//private var P2healthBar:FlxBar; //fuck this it will take too long
	var hudThing:FlxTextAlign = LEFT;
	var songhudThing:FlxTextAlign = CENTER;

	//camera shit
	public var camHUD:FlxCamera;
	public var camP1Notes:FlxCamera;
	public var camP2Notes:FlxCamera;
	public var camOnTop:FlxCamera;
	private var camGame:FlxCamera;

	private var camZooming:Bool = false;
	private var camFollow:FlxObject;
	private static var prevCamFollow:FlxObject;
	var defaultCamZoom:Float = 1.05;

	public static var beatCamZoom:Float = 0.015;
	public static var beatCamHUD:Float = 0.03;
	public static var beatCamHowOften:Int = 4; //how many beats until next zoom

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
	public static var stageData:Array<Dynamic>;

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
		instance = this;
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

		resetStats();

		beatCamZoom = 0.015;
		beatCamHUD = 0.03;
		beatCamHowOften = 4; 
		rewinding = false;
		regeneratingNotes = false;

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camP1Notes = new FlxCamera();
		camP1Notes.bgColor.alpha = 0;
		camP2Notes = new FlxCamera();
		camP2Notes.bgColor.alpha = 0;
		camOnTop = new FlxCamera();
		camOnTop.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camP1Notes);
		FlxG.cameras.add(camP2Notes);
		FlxG.cameras.add(camOnTop);

		FlxCamera.defaultCameras = [camGame];

		PlayerSettings.player1.controls.loadKeyBinds();

		persistentUpdate = true;
		persistentDraw = true;

		if (SaveData.flip)
			flipped = true;
		else
			flipped = false;

		if (SaveData.multiplayer)
			multiplayer = true;
		else
			multiplayer = false;

		if (multiplayer)
			modeText = " - Multiplayer";
		else if (flipped)
			modeText = " - Flipped";
		else
			modeText = "";

		if (SaveData.downscroll) //im not sure if this is the smartest or the stupidest way of doing downscroll
			camP1Notes.flashSprite.scaleY *= -1;
		if (SaveData.P2downscroll) //well it works lol
			camP2Notes.flashSprite.scaleY *= -1;

		mania = SONG.mania; //setting the manias
		p1Mania = mania;
		p2Mania = mania;

		curP1NoteMania = mania;
		curP2NoteMania = mania;
		prevP1NoteMania = mania;
		prevP2NoteMania = mania;
		lastP1mChange = 0;
		lastP2mChange = 0;


		ModchartUtil.playerStrumsInfo = ["", "", ""];
		ModchartUtil.cpuStrumsInfo = ["", "", ""];

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);
		//Conductor.mapManiaChanges(SONG);


		if (SaveData.ScrollSpeed != 1)
			SongSpeed = FlxMath.roundDecimal(SaveData.ScrollSpeed, 2);
		else
			SongSpeed = FlxMath.roundDecimal(SONG.speed, 2);

		SongSpeedMultiplier = FlxMath.roundDecimal(SongSpeedMultiplier, 2);

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

		var stageCheck:String = "";

			
		trace(stageCheck); //fuck you stage check not working, i can see in the trace that its picking up the song.stage correctly but you dont fucking change aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
		trace(PlayState.SONG.stage);

		curStage = null;
		pieceArray = [];

		
		StagePiece.StageCheck(PlayState.SONG.stage);
		stageExpectionCheck(PlayState.SONG.stage);
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
				case 'tutorial' | 'bopeebo' | 'fresh' | 'dadbattle': 
					stageCheck = "stage";
			}
			trace("trying to make stage again");
			StagePiece.StageCheck(stageCheck);
			stageExpectionCheck(stageCheck);
		}

		if (stageData != null)
		{
			pieceArray = stageData[0];
			curStage = stageData[1];
			defaultCamZoom = stageData[2];
			stageOffsets = stageData[3];
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

		boyfriend.defaultPos = [boyfriend.x, boyfriend.y, boyfriend.angle];
		dad.defaultPos = [dad.x, dad.y, dad.angle];

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


		generateSong(SONG.song);


		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		var frameRateShit = 0.04 * (60 / (cast(Lib.current.getChildAt(0), Main)).getFPS());
		FlxG.camera.follow(camFollow, LOCKON, frameRateShit);
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

		switch(SaveData.hpBarPos)
		{
			case "Left" | "Right" | "Center": 
				centerHealthBar = true;
		}


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
			healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), P1Stats,
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



		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 540, healthBarBG.y + 30, 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, hudThing, OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();

		timeText = new FlxText(healthBarBG.x + healthBarBG.width - 540, healthBarBG.y - 60, 0, "", 20);
		timeText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		timeText.scrollFactor.set();

		if (centerHealthBar)
		{
			timeText.y = (FlxG.height * 0.1) - 60;
			if (SaveData.hudPos == "Vanilla")
				scoreTxt.y = (FlxG.height * 0.9) + 30;
		}

		switch (SaveData.hudPos)
		{
			case "Left": 
				scoreTxt.x = 20;
				scoreTxt.y = 250;
			case "Right": 
				scoreTxt.x = FlxG.width - 160;
				scoreTxt.y = 250;
				hudThing = RIGHT;
		}

		switch (SaveData.songhudPos)
		{
			case "Left": 
				timeText.x = 20;
				songhudThing = LEFT;
			case "Right": 
				timeText.x = FlxG.width - 400;
				songhudThing = RIGHT;
		}

		switch (SaveData.hpBarPos)
		{
			case "Left": 
				healthBarBG.x = -200;
				healthBar.x = healthBarBG.x + 4;
			case "Right": 
				healthBarBG.x = FlxG.width - 400;
				healthBar.x = healthBarBG.x + 4;
		}

		timeText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, songhudThing, OUTLINE, FlxColor.BLACK); //update it
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, hudThing, OUTLINE, FlxColor.BLACK);
			


		botPlayTxt = new FlxText(0, 400, 0, "BOTPLAY", 20);
		botPlayTxt.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		botPlayTxt.screenCenter(X);
		botPlayTxt.scrollFactor.set();
		add(botPlayTxt);
		

		iconP1 = new HealthIcon(bfcharacter, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(dadcharacter, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);
		add(scoreTxt);
		add(timeText);
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
		botPlayTxt.cameras = [camHUD];
		timeText.cameras = [camHUD];
		doof.cameras = [camHUD];

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


	
	function stageExpectionCheck(stage:String) //only did this so you can access stages in the stage debug menu, just week 4/6 will be weird, but idk tbh theyre vanilla stages
	{
		switch(stage)
		{
			case "limo": 
				limo = new StagePiece(0, 0, 'limo'); //for the shitty layering
				limo.x += limo.newx;
				limo.y += limo.newy;
			case "schoolEvil": 
				var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
				var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
		}
	}

	function resetStats():Void
	{
		P1Stats.songScore = 0;
		P1Stats.fc = true;
		P1Stats.sicks = 0;
		P1Stats.goods = 0;
		P1Stats.bads = 0;
		P1Stats.shits = 0;
		P1Stats.misses = 0;
		P1Stats.ghostmisses = 0;
		P1Stats.totalNotesHit = 0;
		P1Stats.accuracy = 0;
		P1Stats.curRank = "None";
		P1Stats.combo = 0;
		P1Stats.highestCombo = 0;
		P1Stats.nps = 0;
		P1Stats.highestNps = 0;
		P1Stats.health = 1;
		P1Stats.poisonHits = 0;
		P1Stats.npsArray = [];

		P2Stats.songScore = 0;
		P2Stats.fc = true;
		P2Stats.sicks = 0;
		P2Stats.goods = 0;
		P2Stats.bads = 0;
		P2Stats.shits = 0;
		P2Stats.misses = 0;
		P2Stats.ghostmisses = 0;
		P2Stats.totalNotesHit = 0;
		P2Stats.accuracy = 0;
		P2Stats.curRank = "None";
		P2Stats.combo = 0;
		P2Stats.highestCombo = 0;
		P2Stats.nps = 0;
		P2Stats.highestNps = 0;
		P2Stats.health = 1;
		P2Stats.poisonHits = 0;
		P2Stats.npsArray = [];

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

		if (unspawnNotes[0] != null)
			spawnNote();

		

		var P1binds:Array<String> = CoolUtil.bindCheck(mania);
		var P2binds:Array<String> = CoolUtil.P2bindCheck(mania);

		if (multiplayer)
		{
			createKeybindText(playerStrums, P1binds, SaveData.downscroll);
			createKeybindText(cpuStrums, P2binds, SaveData.P2downscroll);
		}
		else if (flipped)
		{
			createKeybindText(cpuStrums, P1binds, SaveData.P2downscroll);	
		}
		else
		{
			createKeybindText(playerStrums, P1binds, SaveData.downscroll);
		}

		createCountdown();
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

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
		
		binds = CoolUtil.bindCheck(mania);
		//data = CoolUtil.arrowKeyCheck(maniaToChange, evt.keyCode); //arrow keys are shit, just set them in keybinds, sorry to anyone who plays both wasd + arrow keys, might add alt keys at some point

		var P2binds:Array<String> = [null,null,null,null]; //null so you cant misspress while not in multi
		if (multiplayer) //so it only checks when in multi
			P2binds = CoolUtil.P2bindCheck(mania);

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
		binds = CoolUtil.bindCheck(mania); //finally got rid of that fucking huge case statement, its still inside coolutil, but theres only 1, not like 4 lol
		//data = CoolUtil.arrowKeyCheck(maniaToChange, evt.keyCode);

		var P2binds:Array<String> = [null,null,null,null]; //null so you cant misspress while not in multi
		if (multiplayer) //so it only checks when in multi
			P2binds = CoolUtil.P2bindCheck(mania);

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
		normalInputSystem(data, playernum);		
	}


	//////////////////////////////////////////////////////////////////////////////////




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

			if (hittableNotes.length > 1)
			{
				for (shitNote in hittableNotes)
				{
					if (shitNote.strumTime == daNote.strumTime)
						goodNoteHit(shitNote, playernum);
					else if ((!shitNote.isSustainNote && (shitNote.strumTime - daNote.strumTime) < 35))
						goodNoteHit(shitNote, playernum);

					if (hittableNotes.length > 2 && SaveData.casual) //literally all you need to allow you to spam though impossiblely hard jacks
						goodNoteHit(shitNote, playernum);
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
	function casualInputSystem(data:Int, playernum:Int) //casual input was originally gonna use a completely different input system, but one change to the regular input made it more spammable, which is what i wanted from this
	{
		var daClosest = [];
		var notesBeingHit = [];
		var hittableNotes = [];
		switch(playernum)
		{
			case 0: 
				daClosest = P2closestNotes;
			case 1: 
				daClosest = closestNotes;
		}
		if (daClosest.length > 0) //damn makin a new input system is hard
		{

				//time to redo this again and again and again
					/*if (nextNote.noteData != daNote.noteData)
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
					}*/
			var firstNote = daClosest[0];

			if (daClosest.length > 1)
				if (firstNote.strumTime == daClosest[1].strumTime)
				{
					for (daNote in daClosest)
					{
						notesBeingHit.push(daNote);
					}
				}
				

			for (shitNote in daClosest) //this is a fucking mess lol
			{					
				if (shitNote.noteData == data)
					hittableNotes.push(shitNote);	
			}
			for (daNote in hittableNotes)
			{
				for (stackedNote in hittableNotes)
				{
					if (!stackedNote.isSustainNote && ((stackedNote.strumTime - daNote.strumTime) < 25) && stackedNote.strumTime >= daNote.strumTime && daNote != stackedNote)
					{
						notesBeingHit.push(stackedNote);
						trace("pushed stacked note");
					}
				}
				if (hittableNotes.length > 5)
					notesBeingHit.push(daNote);
			}
			if (firstNote.noteData == data)
				notesBeingHit.push(firstNote);
			for (daNote in notesBeingHit)
				goodNoteHit(daNote, playernum);
					


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
		{
			#if sys
			var path:String = Paths.inst(PlayState.SONG.song); //not putting in paths because its being a pain in the ass
			var songInst:FlxSoundAsset = Sound.fromFile(path);
			FlxG.sound.playMusic(songInst, 1, false);
			#else
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
			#end
		}
			

		if (SaveData.noteSplash)
		{
			switch (mania)
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
		
		SaveData.fixColorArray(mania);

		//FlxG.sound.music.onComplete = endSong;
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

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);
		curSong = songData.song;

		if (SONG.needsVoices)
		{
			#if sys
			vocals = new FlxSound().loadEmbedded(Sound.fromFile(Paths.voices(PlayState.SONG.song)));
			#else
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
			#end
		}
			
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		P1notes = new FlxTypedGroup<Note>();
		add(P1notes);
		P2notes = new FlxTypedGroup<Note>();
		add(P2notes);
		P3notes = new FlxTypedGroup<Note>();
		add(P3notes);

		generateNotes();

		generatedMusic = true;

		if (unspawnNotes[0] != null)
			spawnNote();
	}



	private function generateStaticArrows(playernum:Int):Void
	{
		for (i in 0...keyAmmo[mania])
		{
			var style:String = "normal";

			var babyArrow:BabyArrow = new BabyArrow(strumLine.y, playernum, i, style, true);

			babyArrow.ID = i;
			babyArrow.curID = i;

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

			var frameRateShit = 0.04 * (60 / (cast(Lib.current.getChildAt(0), Main)).getFPS());
			FlxG.camera.follow(camFollow, LOCKON, frameRateShit); //fixes camera shit when changing fps

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
		if (P1Stats.health > 0 && !paused)
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
		if (P1Stats.health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		trace("synced vocals");
		vocals.pause();

		FlxG.sound.music.play();
		FlxG.sound.music.time = Conductor.songPosition;
		vocals.time = FlxG.sound.music.time;
		vocals.play();

		updateSongMulti();
	}

	function updateSongMulti():Void
	{
		#if cpp
		@:privateAccess
		{
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, SongSpeedMultiplier);
			//if (SONG.needsVoices)
			if (vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, SongSpeedMultiplier);
		}
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	function calculateStrumtime(daNote:Note, Strumtime:Float) //for note velocity shit, used andromeda engine as a guide for this https://github-dotcom.gateway.web.tr/nebulazorua/andromeda-engine
	{
		var ChangeTime:Float = (daNote.strumTime - daNote.velocityChangeTime);
		var StrumDiff = (Strumtime - ChangeTime);
		var Multi:Float = 1;
		if (Strumtime >= ChangeTime)
			Multi = daNote.speedMulti;

		var pos = ChangeTime * daNote.speed;
		pos += StrumDiff * (daNote.speed * Multi);
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

		var noteY:Float = 0; //i uncapitalized these because i knew it would annoy people lol
		var noteX:Float = 0;
		var noteAngle:Float = 0;
		var noteAlpha:Float = 1;
		var noteVisible:Bool = true;
		var strumNote:BabyArrow;

		var wasGoodHit:Bool = daNote.wasGoodHit; //so it doesnt have to check multiple times
		var isSustainNote:Bool = daNote.isSustainNote; //its running this shit every frame for every note
		var mustPress:Bool = daNote.mustPress;
		var canBeHit:Bool = daNote.canBeHit;
		var tooLate:Bool = daNote.tooLate;
		var noteData:Int = daNote.noteData;
		
		if (strums == 'player') //playerStrums
		{
			strumNote = playerStrums.members[Math.floor(Math.abs(daNote.noteData))];
			noteX = strumNote.x;
			noteY = strumNote.y;
			noteAngle = strumNote.angle;
			noteAlpha = strumNote.alpha;
			noteVisible = strumNote.visible;
		}
		else //cpuStrums
		{
			strumNote = cpuStrums.members[Math.floor(Math.abs(daNote.noteData))];
			noteX = strumNote.x;
			noteY = strumNote.y;
			noteAngle = strumNote.angle;
			noteAlpha = strumNote.alpha;
			noteVisible = strumNote.visible;
		}


		var middleOfNote:Float = noteY + Note.noteWidths[daNote.curMania] / 2;
		var calculatedStrumtime = calculateStrumtime(daNote, Conductor.songPosition);

		var angleX:Float = 1; //1 = none
		var angleY:Float = 1;

		if (daNote.followAngle) //credit to this epic engine for angle shit https://github.com/TheLostGhostS/Ghost-engine-source-code 
		{
			angleX = Math.sin(noteAngle * Math.PI / 180);
			angleY = Math.cos(noteAngle * Math.PI / 180);
		}

		var noteCurPos = daNote.startPos - calculatedStrumtime;

		var xCalc = noteX - 0.45 * noteCurPos * angleX;
		var yCalc = noteY + 0.45 * noteCurPos * angleY;

		if (noteAngle > 180)
		{
			xCalc = noteX + 0.45 * noteCurPos * angleX;
			yCalc = noteY - 0.45 * noteCurPos * angleY;
		}
		
		daNote.setPosition(xCalc, yCalc);
			
		if (flipped || (multiplayer && strums == "cpu"))
			mustPress = !mustPress; //this is just for detecting it, not actually a must press note lol
		

		//TODO: fix clipping

		if (isSustainNote) //im not sure if doing nested if statements is bad for performance, but at least it looks much nicer
			if (!mustPress || (wasGoodHit || (daNote.prevNote.wasGoodHit && !canBeHit) || SaveData.botplay))
				if (daNote.y + (daNote.offset.y) <= middleOfNote)
				{
					var fuckYouRect = new FlxRect(0, middleOfNote - daNote.y, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
					fuckYouRect.y /= daNote.scale.y;
					fuckYouRect.height -= fuckYouRect.y; 
					//fuckYouRect.y = daNote.frameHeight - fuckYouRect.height;
														//fuck you clipping
					daNote.clipRect = fuckYouRect;
				}

		daNote.visible = noteVisible;
		daNote.angle = noteAngle;
		
		if (isSustainNote)
		{
			daNote.alpha = noteAlpha * 0.6;
			daNote.x += daNote.sustainXOffset;
		}
		else
		{
			daNote.alpha = noteAlpha;
		}
		
		if (SaveData.downscroll)
		{
			daNote.y += daNote.downscrollYOffset; //y offset of notetypes  (only downscroll for some reason, weird shit with the graphic flip)
			//bruh i made a whole menu just to help fix and it doesnt even match up wtf
			//ok so i halfed what it said on the offset menu and it worked correctly, this games confuses me so much
		}
			

	}

	function NoteMissDetection(daNote:Note, strums:String, playernum:Int = 1)
	{
		var wasGoodHit:Bool = daNote.wasGoodHit; //so it doesnt have to check multiple times
		var isSustainNote:Bool = daNote.isSustainNote; //its running this shit every frame for every note
		var mustPress:Bool = daNote.mustPress;
		var canBeHit:Bool = daNote.canBeHit;
		var tooLate:Bool = daNote.tooLate;
		var noteData:Int = daNote.noteData;

		if (strums == "cpu")
			mustPress = !mustPress; //this is just for detecting it, not actually a must press note lol

		var statsToUse = getStats(playernum);

		if (isSustainNote && wasGoodHit && Conductor.songPosition >= daNote.strumTime)
			removeNote(daNote, strums);
		else if (SaveData.botplay && Conductor.songPosition >= daNote.strumTime && !daNote.badNoteType)
			goodNoteHit(daNote, playernum);
		else if (mustPress && (tooLate && !wasGoodHit))
		{
			if (daNote.normalNote)
			{
				if (isSustainNote && wasGoodHit) //to 100% make sure the sustain is gone
					{
						daNote.kill();
						removeNote(daNote, strums);
					}
					else
					{
						vocals.volume = 0;
						noteMiss(noteData, daNote, playernum);								
					}
				removeNote(daNote, strums);
			}
			else if (daNote.badNoteType)
			{
				removeNote(daNote, strums);
			}
			else if (daNote.warningNoteType)
			{
				statsToUse.misses++;
				badNoteHit();
				removeNote(daNote, strums);
				switch (daNote.noteType)
				{
					case 3: //regular warning note
					statsToUse.health -= 1;
						vocals.volume = 0;
					case 7: //glitch note
						HealthDrain(playernum);
				}
			}
			else
			{
				removeNote(daNote, strums);
			}
		}
	}

	function NoteCpuHit(daNote:Note, strums:String)
	{
		var wasGoodHit:Bool = daNote.wasGoodHit;
		var noteData:Int = daNote.noteData;

		if (wasGoodHit)
		{
			if (SONG.song != 'Tutorial')
				camZooming = false;

			var altAnim:String = "";

			if (currentSection != null)
			{
				if (currentSection.altAnim)
					altAnim = '-alt';
			}

			if (Note.noteTypeList[daNote.noteType] == "alt")
				altAnim = '-alt';

			if (!daNote.badNoteType)
				cpu.playAnim('sing' + sDir[mania][noteData] + altAnim, true);

			if (flipped)
			{
				playerStrums.forEach(function(spr:BabyArrow)
				{
					if (Math.abs(noteData) == spr.ID)
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
					if (Math.abs(noteData) == spr.ID)
					{
						if (!daNote.badNoteType)
							spr.playAnim('confirm', true, spr.ID);
					}
				});
			}

			if (Note.noteTypeList[daNote.noteType] == "drain")
			{
				if ((drainNoteAmount * 2) > P1Stats.health)
					P1Stats.health = drainNoteAmount * 2;
				else 
					P1Stats.health -= drainNoteAmount;
			}

			cpu.noteCamMovement = noteCamMovementShit(daNote.noteData, 0);

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
		var wasGoodHit:Bool = daNote.wasGoodHit;
		var noteData:Int = daNote.noteData;

		daNote.visible = false;

		if (wasGoodHit)
		{

			var altAnim:String = "";

			if (Note.noteTypeList[daNote.noteType] == "alt")
				altAnim = '-alt';

			trace("gf Note Hit");
			trace(daNote.eventData);

			if (daNote.eventName == "")
			{
				gf.playAnim('sing' + sDir[mania][noteData] + altAnim, true);
				gf.holdTimer = 0;
			}
			var eventName = daNote.eventData[0];
			var eventData = daNote.eventData[1];

			EventList.convertEventDataToEvent(eventName, eventData);


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
		super.update(elapsed);

		elapsedTime += elapsed;

		if (SaveData.botplay)
			botPlayTxt.visible = true;
		else
			botPlayTxt.visible = false;


		songLength = FlxG.sound.music.length;

		if (rewinding)
		{
			canPause = false;
			if (Conductor.songPosition <= 0)
			{
				SongSpeedMultiplier = 1;
				generateNotes();
				if (unspawnNotes[0] != null)
					spawnNote();

				rewinding = false;
				Conductor.songPosition = 0;
				Conductor.songPosition -= Conductor.crochet * 5;
				createCountdown(true);
			}
		}

		for (i in 0...P1Stats.npsArray.length) //TODO put this in function to set up for multi
		{
			var timeNoteWasHit = P1Stats.npsArray[i];

			if ((Conductor.songPosition - timeNoteWasHit) >= 1000)
			{
				P1Stats.npsArray.remove(P1Stats.npsArray[i]);
			}
		}
		P1Stats.nps = P1Stats.npsArray.length;
		if (P1Stats.nps > P1Stats.highestNps)
			P1Stats.highestNps = P1Stats.nps;
		

		updateTimer();
		updateHUD(1);

		if (generatedMusic)
		{
			if (songStarted && !endingSong)
				if (songLength - Conductor.songPosition <= 0) ///yooo it works pog
				{
					resyncVocals();

					endingSong = true;
					endSong();
				}
					
			else if (FlxG.sound.music.playing && canPause && !endingSong)
				updateSongMulti();
		}



		

		var currentBeat = (Conductor.songPosition / 1000)*(SONG.bpm/60);

		playerStrums.forEach(function(spr:BabyArrow) //uhhh make this better //TODO
		{
			ModchartUtil.CalculateArrowShit(spr, spr.curID, 1, "X", currentBeat);
			ModchartUtil.CalculateArrowShit(spr, spr.curID, 1, "Y", currentBeat);
			ModchartUtil.CalculateArrowShit(spr, spr.curID, 1, "Angle", currentBeat);
		});
		cpuStrums.forEach(function(spr:BabyArrow)
		{
			ModchartUtil.CalculateArrowShit(spr, spr.curID, 0, "X", currentBeat);
			ModchartUtil.CalculateArrowShit(spr, spr.curID, 0, "Y", currentBeat);
			ModchartUtil.CalculateArrowShit(spr, spr.curID, 0, "Angle", currentBeat);
		});

		/*var shit = defaultCamScaleX + 1 * Math.sin((currentBeat * 1) * Math.PI);
		camP1Notes.setScale(shit, camP1Notes.scaleY);*/ //just messing around




		if (controls.PAUSE && startedCountdown && canPause)
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

		P1Stats.health = poisonHealthCheck(1, elapsed);
		if (multiplayer)
			P2Stats.health = poisonHealthCheck(0, elapsed);

		if (P1Stats.health > 2)
			P1Stats.health = 2;

		if (P2Stats.health > 2)
			P2Stats.health = 2;

		combinedHealth = P1Stats.health - P2Stats.health;

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



		if (startingSong)
		{
			if (unspawnNotes[0] != null)
				spawnNote();
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += (FlxG.elapsed * 1000) * SongSpeedMultiplier;

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
				}
			}
		}

		if (generatedMusic && currentSection != null)
		{
			closestNotes = [];
			P2closestNotes = [];
			if (multiplayer)
			{
				closestNotes = collectNotes(P1notes, true);
				P2closestNotes = collectNotes(P2notes, false);
			}
			else if (flipped)
				closestNotes = collectNotes(P2notes, false);
			else
				closestNotes = collectNotes(P1notes, true);
			

			closestNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			P2closestNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));


			if (!currentSection.mustHitSection)
				moveCamera(getCameraPos(0));
			else if (currentSection.mustHitSection)
				moveCamera(getCameraPos(1));
		}
		cameraZooming();
		

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
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
			}
		}

		if (P1Stats.health <= 0 || P2Stats.health <= 0)
		{
			if (!rewindOnDeath)
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
			else 
			{
				rewindTime();
			}

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
			resetBabyArrowAnim(playerStrums);
		else if (!multiplayer)
			resetBabyArrowAnim(cpuStrums);


		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (!inCutscene)
		{
			if (gamepad != null)
				gamepadCheck(gamepad);
			keyShit();
		}
			

		/*#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end*/
	}

	function endSong():Void
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN,handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
		canPause = false;
		endingSong = true;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		FlxG.sound.music.pause();
		vocals.pause();
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, P1Stats.songScore, storyDifficulty);
			#end
		}

		if (isStoryMode)
		{
			campaignScore += P1Stats.songScore;

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

				#if sys
				var formmatedShit = CoolUtil.getSongFromJsons(PlayState.storyPlaylist[0].toLowerCase(), storyDifficulty);
				#else
				var formmatedShit = Highscore.formatSong(PlayState.storyPlaylist[0].toLowerCase(), storyDifficulty);
				#end

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
			MainMenuState.musicShit();
		}
	}

	var endingSong:Bool = false;

	function createCountdown(rewinded:Bool = false)
	{
		var swagCounter:Int = 0;

		if (rewinded)
		{
			vocals.volume = 0;
			FlxG.sound.music.volume = 0;
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
						if (rewinded)
						{
							vocals.volume = 1;
							FlxG.sound.music.volume = 1;
							canPause = true;
						}

							

				}
	
				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
	}

	private function popUpScore(note:Note = null, playernum:Int = 1):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var statsToUse = getStats(playernum);

		var daCombo:Int = statsToUse.combo;

		if (SaveData.botplay)
			statsToUse.songScore = 0;

		var placement:String = Std.string(daCombo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * 0.70)
		{
			daRating = 'shit';
			score = 50;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.55)
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

		statsToUse.totalNotesHit++;
		var healthChanges:Float = 0;

		if (!SaveData.botplay)
		{
			switch (daRating)
			{
				case "sick": 
					statsToUse.sicks++;
					healthChanges += 0.15;
				case "good": 
					statsToUse.goods++;
					healthChanges += 0.1;
				case "bad": 
					statsToUse.bads++;
					statsToUse.ghostmisses++;
					if (!SaveData.casual)
						healthChanges -= 0.07;
				case "shit":
					statsToUse.shits++;
					statsToUse.ghostmisses++;
					if (!SaveData.casual)
						healthChanges -= 0.12;
			}
	
			statsToUse.health += healthChanges;

	
			statsToUse.songScore += score;
		}


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
				sustainHoldCheck(keys, P1notes, true);
				sustainHoldCheck(P2keys, P2notes, false, 0);
			}
			else if (flipped && !multiplayer)
				sustainHoldCheck(keys, P2notes, false);
			else
				sustainHoldCheck(keys, P1notes, true);
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
			strumPressCheck(playerStrums, keys);
			strumPressCheck(cpuStrums, P2keys);
		}
		else if (flipped && !multiplayer)
			strumPressCheck(cpuStrums, keys);
		else
			strumPressCheck(playerStrums, keys);

	}

	private function gamepadCheck(gamepad:FlxGamepad):Void
	{
		var binds:Array<String> = CoolUtil.gamepadBindCheck(p1Mania);
		for (i in 0...binds.length) //im suprised this worked first try without any issues
		{
			var data = -1;
			var input = FlxGamepadInputID.fromString(binds[i]);
			if (gamepad.checkStatus(input, JUST_PRESSED))
			{
				data = i;
				if (data != -1)
					keys[data] = true;
				normalInputSystem(data, 1);
			}
			else if (gamepad.checkStatus(input, JUST_RELEASED))
			{
				data = i;
				if (data != -1)
					keys[data] = false;
			}


		}
		/*if (gamepad.anyJustReleased)
		{
			for (i in 0...binds.length)
			{
				var data = -1;
				var input = FlxGamepadInputID.fromString(binds[i]);
				if (gamepad.checkStatus(input, JUST_RELEASED))
				{
					data = i;
				}
				if (data != -1)
					keys[data] = false;
			}
		}
		if (gamepad.anyJustPressed)
		{

		}*/
	}

	function noteMiss(direction:Int = 1, daNote:Note, playernum:Int = 1):Void
	{
		var shit = player;
		var statsToUse = getStats(playernum);
		if (playernum != 1 && multiplayer)
		{
			shit = player2;
		}
			
		if (!shit.stunned)
		{
			if (daNote.isSustainNote)
				statsToUse.health -= 0.03;
			else
				statsToUse.health -= 0.15;

			if (statsToUse.combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			statsToUse.combo = 0;

			if (!daNote.isSustainNote)
				statsToUse.misses++; //so you dont get like 20 misses from a long note

			statsToUse.totalNotesHit++; //not actually missing, just for working out the accuracy

			CalculateAccuracy(playernum);

			statsToUse.songScore -= 10;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			if (daNote.mustPress)
				shit.playAnim('sing' + sDir[mania][direction] + 'miss', true);
			else
			{
				shit.color = 0x00303f97;
				shit.playAnim('sing' + sDir[mania][direction], true);
			}

			scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.RED, hudThing, OUTLINE, FlxColor.BLACK);

			player.stunned = true;


			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				shit.stunned = false;
				shit.color = 0x00FFFFFF;
			});

		}
		
	}
	function missPress(direction:Int = 1, playernum:Int = 1):Void
	{
		var shit = player;
		var statsToUse = getStats(playernum);
		if (playernum != 1 && multiplayer)
		{
			shit = player2;
		}
			
		if (!shit.stunned)
		{
			statsToUse.health -= 0.04;

			if (statsToUse.combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			statsToUse.ghostmisses++;

			statsToUse.totalNotesHit++; //not actually missing, just for working out the accuracy

			CalculateAccuracy(playernum);

			statsToUse.songScore -= 10;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			if (playernum == 1 && !flipped)
				shit.playAnim('sing' + sDir[mania][direction] + 'miss', true);
			else
			{
				shit.color = 0x00303f97;
				shit.playAnim('sing' + sDir[mania][direction], true);
			}

			scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.RED, hudThing, OUTLINE, FlxColor.BLACK);

			player.stunned = true;


			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				shit.stunned = false;
				shit.color = 0x00FFFFFF;
			});

		}
		
	}



	function goodNoteHit(note:Note, playernum:Int = 1):Void
	{
		if (!note.wasGoodHit)
		{
			var statsToUse = getStats(playernum);

			if (!note.isSustainNote)
			{
				popUpScore(note, playernum);
				statsToUse.combo += 1;
				if (statsToUse.combo > statsToUse.highestCombo)
					statsToUse.highestCombo = statsToUse.combo;
			}
			else
			{
				note.rating = "sick";
				statsToUse.sicks++;
				statsToUse.totalNotesHit++;
			}

			if ((!note.isSustainNote || SaveData.casual) && !note.badNoteType)
				note.healthChangesOnHit = 0.02;

			var altAnim:String = "";

			if (currentSection != null)
				{
					if (currentSection.altAnim)
						altAnim = '-alt';
				}	
			if (Note.noteTypeList[note.noteType] == "alt")
				altAnim = '-alt';

			if (playernum == 1)
			{
				player.playAnim('sing' + sDir[mania][note.noteData] + altAnim, true);
				player.holdTimer = 0;
				player.noteCamMovement = noteCamMovementShit(note.noteData, 1);
			}
			else
			{
				player2.playAnim('sing' + sDir[mania][note.noteData] + altAnim, true);
				player2.holdTimer = 0;
				player2.noteCamMovement = noteCamMovementShit(note.noteData, 0);
			}

			var timeWasHit:Float = Conductor.songPosition;
			if (!note.isSustainNote)
				statsToUse.npsArray.push(timeWasHit);

			note.noteTypeHit();

			CalculateAccuracy(playernum);

			statsToUse.health += note.healthChangesOnHit;

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

	public function HealthDrain(playernum:Int = 1):Void //code from vs bob
	{
		badNoteHit();
		var statsToUse = getStats(playernum);

		new FlxTimer().start(0.01, function(tmr:FlxTimer)
		{
			statsToUse.health -= 0.005; //TODO
		}, 300);
	}

	public function badNoteHit():Void
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

	function updateRank(playernum:Int = 1):Void
	{
		var statsToUse = getStats(playernum);

		var accuracyToRank:Array<Bool> = [
			statsToUse.accuracy <= 40,
			statsToUse.accuracy <= 50,
			statsToUse.accuracy <= 60,
			statsToUse.accuracy <= 70,
			statsToUse.accuracy <= 80,
			statsToUse.accuracy <= 90,
			statsToUse.accuracy <= 100,
		];



		
		for (i in 0...accuracyToRank.length)
		{
			if (accuracyToRank[i])
			{
				statsToUse.curRank = ranksList[i];
				if(statsToUse.misses == 0 && !SaveData.botplay)
					statsToUse.curRank += "(FC)";

				break;
			}
		}
	}
	
	function CalculateAccuracy(playernum:Int = 1):Void
	{
		var statsToUse = getStats(playernum);

		var notesAddedUp = statsToUse.sicks + (statsToUse.goods * 0.65) + (statsToUse.bads * 0.3) + (statsToUse.shits * 0.1);
		statsToUse.accuracy = FlxMath.roundDecimal((notesAddedUp / statsToUse.totalNotesHit) * 100, 2);

		updateRank(playernum);
	}

	function getStats(playernum:Int = 1)
	{
		var stats = P1Stats;

		if (playernum != 1 && multiplayer)
			stats = P2Stats;

		return stats;
	}

	function updateHUD(playernum:Int = 1):Void
	{
		var statsToUse = getStats(playernum);

		statsToUse.scorelerp = Math.floor(FlxMath.lerp(statsToUse.scorelerp, statsToUse.songScore, 0.4)); //funni lerp
		statsToUse.acclerp = FlxMath.roundDecimal(FlxMath.lerp(statsToUse.acclerp, statsToUse.accuracy, 0.4), 2);

		if (Math.abs(statsToUse.scorelerp - statsToUse.songScore) <= 10)
			statsToUse.scorelerp = statsToUse.songScore;

		if ((statsToUse.acclerp - statsToUse.accuracy) <= 0.05)
			statsToUse.acclerp = statsToUse.accuracy;

		var score = "Score:" + statsToUse.scorelerp;
		var rank = "Rank: " + statsToUse.curRank;
		var acc = "Accuracy: " + statsToUse.acclerp + "%";
		var miss = "Misses: " + statsToUse.misses;

		

		var sick = "Sicks: " + statsToUse.sicks;
		var good = "Goods: " + statsToUse.goods;
		var bad = "Bads: " + statsToUse.bads;
		var shit = "Shits: " + statsToUse.shits;
		var ghost = "Ghost Misses: " + statsToUse.ghostmisses;
		var comb = "Combo: " + statsToUse.combo;
		var highestcomb = "Highest Combo: " + statsToUse.highestCombo;
		var nps = "NPS: " + statsToUse.nps;
		var highestnps = "Highest NPS: " + statsToUse.highestNps;
		var hp = "Health: " + Math.round(healthBar.percent) + "%";

		var listOShit = [score, rank, acc, miss, "", "", sick, good, bad, shit, ghost, comb, highestcomb, nps, highestnps, hp];

		scoreTxt.text = "";
		for (i in 0...SaveData.enabledHudSections.length)
		{
			if (SaveData.enabledHudSections[i] == true)
			{
				if (i == 4 || i == 5) //timer/songname text
				{
					//moved to updateTimer()
				}
				else 
				{
					if ((i == 6 || i == 11) && SaveData.hudPos == "Vanilla")
						scoreTxt.text += "\n";

					if (SaveData.hudPos != "Vanilla")
						scoreTxt.text += "\n";
					else
						scoreTxt.text += "|";

					scoreTxt.text += listOShit[i];

					if (SaveData.hudPos == "Vanilla")
						scoreTxt.text += "|";

				}
			}
		}
	}

	function updateTimer():Void
	{
		var timeLeft = songLength - FlxG.sound.music.time;
		var time:Date = Date.fromTime(timeLeft);
		var mins = time.getMinutes();
		var secs = time.getSeconds();
		var multitext:String = "(x" + FlxMath.roundDecimal(SongSpeedMultiplier, 2) + ")";
		if (SongSpeedMultiplier == 1)
			multitext = "";
		var time = "";
		if (secs < 10) //so it looks right
			time = " - " + mins + ":" + "0" + secs; 
		else
			time = " - " + mins + ":" + secs; 

		timeText.text = "";
		for (i in 0...SaveData.enabledHudSections.length)
		{
			if (SaveData.enabledHudSections[i] == true)
			{
				if (i == 4 || i == 5) //timer/songname text
				{
					if (i == 4)
					{
						timeText.text += songtext + multitext;
						if (!SaveData.enabledHudSections[5])
							timeText.text += modeText; //add mode text if no timer
					}
					else if (i == 5)
					{
						timeText.text += time;
						if (SaveData.enabledHudSections[4])
							timeText.text += modeText; //add mode text after timer
					}
				}
			}
		}
	}

	/*public function easyLerp(daShit:Dynamic, time:Float):Void
	{
		FlxTween.num(camGame.scaleY, daShit, time, {onUpdate: function(tween:FlxTween){
			var ting = FlxMath.lerp(camGame.scaleY, daShit, tween.percent);
			if (ting != 0) //divide by 0 is a verry bad
				camGame.setScale(camGame.scaleX, ting); //why cant i just tween a variable
		}});
	}*/

	var justChangedMania:Bool = false;

	public function switchMania(newMania:Int, strumnum = 1):Void //TODO, now done lol
	{
		if (mania == 2) //so it doesnt break the fucking game
		{
			var strums:FlxTypedGroup<BabyArrow> = playerStrums;
		
			var scaleToCheck:Float = 1;
			var bindsToUse:Array<String> = [];
			var downscroll = SaveData.downscroll;
			var showKeyBindText = true;
			if (strumnum == 1)
			{
				p1Mania = newMania;
				Note.p1NoteScale = Note.noteScales[newMania];
				scaleToCheck = Note.p1NoteScale;
				strums = playerStrums;
				if (!flipped && !multiplayer)
					bindsToUse = CoolUtil.bindCheck(mania);
				else 
					showKeyBindText = false;
			}
			else
			{
				p2Mania = newMania;
				Note.p2NoteScale = Note.noteScales[newMania];
				scaleToCheck = Note.p2NoteScale;
				strums = cpuStrums;
				if (multiplayer)
					bindsToUse = CoolUtil.P2bindCheck(mania);
				else if (flipped)
					bindsToUse = CoolUtil.bindCheck(mania);
				else 
					showKeyBindText = false;
				downscroll = SaveData.P2downscroll;
			}
	
			strums.forEach(function(spr:BabyArrow)
			{
				spr.playAnim('static', true, spr.ID); //changes to static because it can break the scaling of the static arrows if they are doing the confirm animation
				if (spr.stylelol == "pixel")
					spr.setGraphicSize(Std.int(spr.defaultWidth * PlayState.daPixelZoom * Note.pixelnoteScale * spr.scaleMulti));
				else 
					spr.setGraphicSize(Std.int(spr.defaultWidth * scaleToCheck * spr.scaleMulti));

				//spr.centerOffsets();

				spr.moveKeyPositions(spr, newMania, strumnum);
			});	

			if (showKeyBindText)
				createManiaSwitchKeybindText(strums, bindsToUse, downscroll);

			/*regeneratingNotes = true;
			generateNotes();*/
		}
	}


	function moveCamera(pos:Array<Float>):Void
	{
		camFollow.setPosition(pos[0], pos[1]);
	}
	function getCameraPos(playernum:Int = 0)
	{
		var pos:Array<Float> = [0, 0];
		if (playernum == 0)
		{
			var camOffset = dad.posOffsets.get('cam'); //offset in character.hx
			if (dad.posOffsets.exists('cam'))
			{
				pos = [dad.getMidpoint().x + camOffset[0] + dad.noteCamMovement[0], 
				dad.getMidpoint().y + camOffset[1] + dad.noteCamMovement[1]];
			}
			else
				pos = [dad.getMidpoint().x + 150 + dad.noteCamMovement[0], dad.getMidpoint().y - 100 + dad.noteCamMovement[1]];

			if (dad.curCharacter == 'mom')
				vocals.volume = 1;

			if (SONG.song.toLowerCase() == 'tutorial')
				tweenCamIn();
		}
		else
		{
			var yoffset:Float = -100;
			var xoffset:Float = -100;
			switch (curStage)
			{
				case 'limo':
					xoffset = -300;
				case 'mall':
					yoffset = -200;
				case 'school' | 'schoolEvil':
					xoffset = -200;
					yoffset = -200;
			}

			pos = [boyfriend.getMidpoint().x + xoffset + boyfriend.noteCamMovement[0], 
			boyfriend.getMidpoint().y + yoffset + boyfriend.noteCamMovement[1]];

			if (SONG.song.toLowerCase() == 'tutorial')
				FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing"))
			boyfriend.noteCamMovement = [0, 0];
		if (!dad.animation.curAnim.name.startsWith("sing"))
			dad.noteCamMovement = [0, 0];

		return pos;
	}

	function cameraZooming():Void
	{
		camHUD.zoom = 0.7;
		camP1Notes.zoom = camHUD.zoom;
		camP2Notes.zoom = camHUD.zoom;
		camOnTop.zoom = camHUD.zoom;
		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(0.7, camHUD.zoom, 0.95);

			camP1Notes.zoom = camHUD.zoom;
			camP2Notes.zoom = camHUD.zoom;
			camOnTop.zoom = camHUD.zoom;
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
	}

	function noteCamMovementShit(data:Int, playernum:Int = 0) //literally everyone does this now, so imma do it anyway
	{
		
		var movement:Array<Float> = [0, 0];
		var thing:Array<Float> = [0, 0];
		if (playernum == 1)
			thing = player.noteCamMovement;
		else
		{
			if (multiplayer)
				thing = player2.noteCamMovement;
			else
				thing = cpu.noteCamMovement;
		}
		if (SaveData.noteMovements)
		{
			switch(sDir[mania][data])
			{
				case "LEFT": 
					if (thing[0] > -100)
						movement[0] += -25;
				case "UP": 
					if (thing[1] > -100)
						movement[1] += -25;
				case "RIGHT": 
					if (thing[0] < 100)
						movement[0] += 25;
				case "DOWN":
					if (thing[1] < 100)
						movement[1] += 25;
			}
		}
		return movement;
	}


	function createKeybindText(strums:FlxTypedGroup<BabyArrow>, binds:Array<String>, downscroll:Bool):Void
	{
		for (i in 0...binds.length)
		{
			var text:FlxText = new FlxText(strums.members[i].x, (strumLine.y + 200), 48, binds[i], 32, false);
			text.setFormat(Paths.font("vcr.ttf"), 48, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
			add(text);
			text.scrollFactor.set();
			if (downscroll)
				{
					text.y += 170;	
					text.x += 15;
				}
			else
				text.x += 40;
			text.cameras = [camHUD];
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
	function createManiaSwitchKeybindText(strums:FlxTypedGroup<BabyArrow>, binds:Array<String>, downscroll:Bool):Void
		{
			for (i in 0...binds.length)
			{
				var text:FlxText = new FlxText(strums.members[i].x, (strumLine.y + 200), 48, binds[i], 32, false);
				text.setFormat(Paths.font("vcr.ttf"), 48, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
				add(text);
				text.scrollFactor.set();
				if (downscroll)
					{
						text.y += 170;	
						text.x += 15;
					}
				else
					text.x += 40;
				text.cameras = [camHUD];
				new FlxTimer().start(2, function(tmr:FlxTimer)
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
	function collectNotes(shit:FlxTypedGroup<Note>, checkMustPresses:Bool) //lot of functions for code optimizations, and less copy pasted shit
	{
		var collectedNotes:Array<Note> = [];
		if (checkMustPresses)
		{
			shit.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
					collectedNotes.push(daNote);
			});
		}
		else
		{
			shit.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && !daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
					collectedNotes.push(daNote);
			});
		}

		return collectedNotes;
	}
	function resetBabyArrowAnim(strums:FlxTypedGroup<BabyArrow>):Void
	{
		strums.forEach(function(spr:BabyArrow)
		{
			if (spr.animation.finished)
			{
				spr.playAnim('static',false , spr.ID);
				spr.centerOffsets();
			}
		});
	}
	function sustainHoldCheck(daKeys:Array<Bool>, shit:FlxTypedGroup<Note>, checkMustPresses:Bool, playernum:Int = 1):Void
	{
		if (checkMustPresses)
		{
			shit.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && daKeys[daNote.noteData])
					goodNoteHit(daNote, playernum);
			});
		}
		else
		{
			shit.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && !daNote.mustPress && daKeys[daNote.noteData])
					goodNoteHit(daNote, playernum);
			});
		}
	}
	function strumPressCheck(strums:FlxTypedGroup<BabyArrow>, daKeys:Array<Bool>):Void
	{
		strums.forEach(function(spr:BabyArrow)
			{
				if (daKeys[spr.ID] && spr.animation.curAnim.name != 'confirm' && spr.animation.curAnim.name != 'pressed')
					spr.playAnim('pressed', false, spr.ID);
				if (!daKeys[spr.ID])
					spr.playAnim('static', false, spr.ID);
			});
	}

	function poisonHealthCheck(playernum:Int = 1, elapsed:Float)
	{
		var statsToUse = getStats(playernum);

		var healthToCheck:Float = statsToUse.health;
		var hits:Int = statsToUse.poisonHits;
			
		if (healthToCheck > 0.01) //code from vs retrospecter
		{
			if (poisonDrain * hits * elapsed > statsToUse.health)
				healthToCheck = 0.01;
			else
				healthToCheck -= poisonDrain * hits * elapsed;
		}
		return healthToCheck;
	}

	function spawnNote():Void
	{
		if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500)
		{
			var dunceNote:Note = unspawnNotes[0];

			if (dunceNote.strumTime - Conductor.songPosition <= 0)
				unspawnNotes.remove(dunceNote); //remove notes that would have already passed if regening notes
			else 
			{
				if (dunceNote.isGFNote)
					P3notes.add(dunceNote);
				else if (dunceNote.mustPress)
					P1notes.add(dunceNote);
				else if (!dunceNote.mustPress)
					P2notes.add(dunceNote);
			}

			
			var index:Int = unspawnNotes.indexOf(dunceNote);
			unspawnNotes.splice(index, 1);
		}
		if (unspawnNotes[0] != null)
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500)
				spawnNote(); //loop it lol
	}

	



	function lerpSongSpeed(num:Float, time:Float):Void
	{
		FlxTween.num(SongSpeedMultiplier, num, time, {onUpdate: function(tween:FlxTween){
			var ting = FlxMath.lerp(SongSpeedMultiplier,num, tween.percent);
			if (ting != 0) //divide by 0 is a verry bad
				SongSpeedMultiplier = ting; //why cant i just tween a variable
		}});
		var staticLinesNum = FlxG.random.int(3, 5);
		for (i in 0...staticLinesNum)
		{
			var startPos = FlxG.random.float(0, FlxG.height);
			var endPos = FlxG.random.float(0, FlxG.height);

			var line:FlxSprite = new FlxSprite().loadGraphic(Paths.image("staticline"));
			line.y = startPos;
			line.updateHitbox();
			line.cameras = [camHUD];
			line.alpha = 0.3;
	
			line.screenCenter(X);
			add(line);
			FlxTween.tween(line, {y: endPos}, time, {
				ease: FlxEase.circInOut,
				onComplete: function(twn:FlxTween)
				{
					line.destroy();
				}
			});
		}
	}

	public function rewindTime():Void
	{
		var timeLeft = songLength - FlxG.sound.music.time;
		var speed = (timeLeft - songLength) / 1000;

		var restart:FlxSprite = new FlxSprite().loadGraphic(Paths.image("restart"));
		restart.scrollFactor.set();
		restart.updateHitbox();

		restart.screenCenter();
		add(restart);
		FlxTween.tween(restart, {y: restart.y += 100, alpha: 0}, Conductor.crochet / 1000, {
			ease: FlxEase.cubeInOut,
			onComplete: function(twn:FlxTween)
			{
				restart.destroy();
			}
		});
		lerpSongSpeed(speed, 1);
		rewinding = true;
		p1Mania = mania;
		p2Mania = mania;
		curP1NoteMania = mania;
		curP2NoteMania = mania;
		prevP1NoteMania = mania;
		prevP2NoteMania = mania;
		lastP1mChange = 0;
		lastP2mChange = 0;

		ModchartUtil.playerStrumsInfo = ["x", "y", "defaultAngle"];
    	ModchartUtil.cpuStrumsInfo = ["x", "y", "defaultAngle"];


		if (mania == 2)
		{
			switchMania(2, 0);
			switchMania(2, 1);
		}
		resetStats();
	}

	function generateNotes():Void
	{
		unspawnNotes = [];
		P1notes.clear();
		P2notes.clear();
		P3notes.clear();

		var songData = SONG;
		var noteData:Array<SwagSection>;
		noteData = songData.notes;

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


					var daType = songNotes[3];
	
					var gottaHitNote:Bool = section.mustHitSection;


	
					if (songNotes[1] >= mn)
						gottaHitNote = !section.mustHitSection;

					var t = Std.int(songNotes[1] / 18); //compatibility with god mode final destination (or just shaggy x matt charts)
					switch(t)
					{
						case 1: 
							daType = 2;
							daNoteData = Std.int((songNotes[1] - 18) % mn); //did this to fix duets
							gottaHitNote = section.mustHitSection;
							if (songNotes[1] >= (mn + 18))
								gottaHitNote = !section.mustHitSection;
						case 2: 
							daType = 3;
							daNoteData = Std.int((songNotes[1] - 36) % mn);
							gottaHitNote = section.mustHitSection;
							if (songNotes[1] >= (mn + 36))
								gottaHitNote = !section.mustHitSection;
					}
	
					var oldNote:Note;
					if (unspawnNotes.length > 0)
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					else
						oldNote = null;
	
					
	
					var daSpeed = songNotes[4];
	
					var daVelocityData = songNotes[5];
	
					
					daType = CoolUtil.songCompatCheck(daType); //checks songs from mods that also use the notetype variable name, which is not many lol
	
					var swagNote:Note = new Note(daStrumTime, daNoteData, daType, false, daSpeed, daVelocityData, false, false, gottaHitNote, null, oldNote);
					swagNote.sustainLength = songNotes[2];
					swagNote.scrollFactor.set(0, 0);
					swagNote.startPos = calculateStrumtime(swagNote, daStrumTime);
	
					var susLength:Float = swagNote.sustainLength;
	
					susLength = susLength / Conductor.stepCrochet;
					unspawnNotes.push(swagNote);

					if (susLength != 0)
						susLength++; //increase length of all sustains, so they dont look off in game
	
	
	
					for (susNote in 0...Math.floor(susLength))
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
						var speedToUse = SongSpeed;
						if (daSpeed != null || daSpeed > 1)
							speedToUse = daSpeed;

						//var crocs = Conductor.stepCrochet * SongSpeedMultiplier; //crocs lol
	
						
						var susStrum = daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / speedToUse / SongSpeedMultiplier);
						if (rewinding)
							susStrum = daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / speedToUse);

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

					var eventData:Array<String> = songNotes[6];
					//trace(eventData);

					var swagNote:Note = new Note(daStrumTime, daNoteData, 0, false, 1, daVelocityData, false, true, false, eventData, oldNote);
					swagNote.startPos = calculateStrumtime(swagNote, daStrumTime);
					unspawnNotes.push(swagNote);

					/*if (swagNote.eventData[0] == "Change P1 Mania" && swagNote.eventData != null)
						Conductor.mapManiaChange(swagNote, 1);
					else if (swagNote.eventData[0] == "Change P2 Mania" && swagNote.eventData != null)
						Conductor.mapManiaChange(swagNote, 0);*/
					if (swagNote.eventData[0] == "Change P1 Mania" && swagNote.eventData != null)
					{
						prevP1NoteMania = curP1NoteMania;
						curP1NoteMania = Std.parseInt(eventData[1]); //im watching you, you better not steal this fucking code
						lastP1mChange = swagNote.strumTime;
					}
						
					else if (swagNote.eventData[0] == "Change P2 Mania" && swagNote.eventData != null)
					{
						prevP2NoteMania = curP2NoteMania;
						curP2NoteMania = Std.parseInt(eventData[1]);
						lastP2mChange = swagNote.strumTime;
					}
						
				}
				
			}
			daBeats += 1;
		}

		unspawnNotes.sort(sortByShit);
	}
		
	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}


	

	override function stepHit()
	{
		super.stepHit();

		var needToResync:Bool = (((FlxG.sound.music.time - vocals.time) >= 10) && vocals.playing);

		if (FlxG.sound.music.time > Conductor.songPosition + (20 * PlayState.SongSpeedMultiplier) || FlxG.sound.music.time < Conductor.songPosition - (20 * PlayState.SongSpeedMultiplier)
			|| needToResync)
			resyncVocals();

		/*P1notes.forEachAlive(function(daNote:Note)
		{
			daNote.checkNoteScale(Note.p1NoteScale, 1);
		});
		P2notes.forEachAlive(function(daNote:Note)
		{
			daNote.checkNoteScale(Note.p2NoteScale, 0);
		});*/
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

		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, hudThing, OUTLINE, FlxColor.BLACK);

		if (unspawnNotes[0] != null)
			spawnNote();

		/*P1notes.forEachAlive(function(daNote:Note)
		{
			daNote.checkNoteScale(Note.p1NoteScale, 1);
		});
		P2notes.forEachAlive(function(daNote:Note)
		{
			daNote.checkNoteScale(Note.p2NoteScale, 0);
		});*/

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

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % beatCamHowOften == 0)
		{
			FlxG.camera.zoom += beatCamZoom;
			camHUD.zoom += beatCamHUD;
		}

		if (curBeat % 32 == 0 && RandomSpeedChange && !rewinding)
		{
			var randomShit = FlxMath.roundDecimal(FlxG.random.float(0.8, 2), 2);
			lerpSongSpeed(randomShit, 1);
		}

		if (curBeat % 4 == 0 && !rewinding)
		{
			var flipscroll = FlxG.random.bool(50);
			playerStrums.forEach(function(spr:BabyArrow)
			{					
				var angle = FlxG.random.int(-50, 50);
				if (flipscroll)
					angle = FlxG.random.int(130, 220);

				FlxTween.tween(spr, {angle: angle}, (Conductor.stepCrochet / 1000));
					
			});

			cpuStrums.forEach(function(spr:BabyArrow)
			{					
				var angle = FlxG.random.int(-50, 50);
				if (flipscroll)
					angle = FlxG.random.int(130, 220);

				FlxTween.tween(spr, {angle: angle}, (Conductor.stepCrochet / 1000));
			});
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
