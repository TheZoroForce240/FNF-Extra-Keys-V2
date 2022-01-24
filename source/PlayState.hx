package;


import HscriptShit.BeatScriptEvent;
import HscriptShit.StepScriptEvent;
import HscriptShit.StrumTimeScriptEvent;
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
import flixel.util.FlxSpriteUtil;
import flixel.math.FlxAngle;
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
import HscriptShit.ScriptEvent;
import HscriptShit.EventCallType;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
import lime.media.AudioBuffer;
import openfl.utils.ByteArray;
import haxe.io.Bytes;
import haxe.io.BytesData;


#if sys
import sys.io.File;
import sys.FileSystem;
#end
import flash.media.Sound;
import StagePiece.Stages;

using StringTools;

//for anyone looking though the code,
//sorry if i put capitals at the start of variables/functions, i can't be bothered to change it, 
//i would prefer to keep consistancy, its mainly with P2 variables though


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
	public var vocals:FlxSound;
	private var curSong:String = "";
	public static var instance:PlayState = null; //to access in other places
	public var elapsedTime:Float = 0; //used for arrow movements and shit i think
	public static var rewinding:Bool = false;
	public static var regeneratingNotes:Bool = false;
	static var rewindOnDeath = false;
	public static var allowSpeedChanges:Bool = true;
	public var legacyModcharts:Bool = false; //id prefer to use new modcharts rather than shitty event notes
	public static var characters:Bool = true;
	public static var backgrounds:Bool = true;
	public static var modcharts:Bool = true;

	public static var StrumLineStartY:Float = 50;
	public static var healthToDieOn:Float = 0;

	public static var shitTiming:Float = 0.7; //TODO make these use ms timing
	public static var badTiming:Float = 0.55;
	public static var goodTiming:Float = 0.3;
	public static var healthFromAnyHit:Float = 0.02;
	public static var healthFromRating:Array<Float> = [0.15, 0.1, -0.07, -0.12];
	public static var healthLossFromMiss:Float = 0.15;
	public static var healthLossFromSustainMiss:Float = 0.03;
	public static var healthLossFromMissPress:Float = 0.04;
	public static var graceTimerCooldown:Float = 0.15;


	/// modifier shit
	public static var SongSpeedMultiplier:Float = 1;
	public static var RandomSpeedChange:Bool = false;
	public static var allowNoteTypes:Bool = true;
	public static var randomNoteAngles:Bool = false;
	public static var rainbowNotes:Bool = false;
	public static var backwardSong:Bool = false;
	public static var randomModchartEffects:Bool = false;


	//characters
	public static var dad:Boyfriend;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;
	public static var bfDefaultPos:Array<Int> = [770, 450];
	public static var dadDefaultPos:Array<Int> = [100, 100];
	public static var gfDefaultPos:Array<Int> = [400, 130];
	public static var bfDefaultCamOffset:Array<Int> = [-100, -100];
	public static var dadDefaultCamOffset:Array<Int> = [150, 100];


	public var modchartStorage:Map<String, Dynamic>;

	public var extraCharactersList:Array<String> = [];
	public static var extraCharacters:FlxTypedGroup<Boyfriend>;


	var oppenentColors:Array<Array<Float>>; //oppenents arrow colors and assets
	public var gfSpeed:Int = 1;
	private var combinedHealth:Float = 1; //dont mess with this using modcharts
	private var missSounds:Array<FlxSound> = [];

	public var currentBeat:Float;
	public var overrideCam:Bool = false;
	public var alignCams:Bool = true;

	//note stuff
	public var unspawnNotes:Array<Note> = [];

	public static var poisonDrain:Float = 0.075;
	public static var drainNoteAmount:Float = 0.025;

	public static var fireNoteDamage:Float = 0.5;
	public static var deathNoteDamage:Float = 2.2;
	public static var warningNoteDamage:Float = 1;
	public static var angelNoteDamage:Array<Float> = [-2, -0.5, 0.5, 1];
	public static var poisonNoteDamage:Float = 0.3;
	public static var HealthDrainFromGlitchAndBob:Float = 0.005;

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
	public static var GFsDir:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT']; //for gf

	//some more song stuff
	public var strumLine:FlxSprite; //the strumline (just for static arrow placement)
	private var curSection:Int = 0; //current section
	private var currentSection:SwagSection; //the current section again lol, but its actually the section not just a number

	public static var p1:Player = null;
	public static var p2:Player = null;
	public static var p3:Player = null;
	public static var playerList:Array<Player> = [];
	//score and stats
	public static var campaignScore:Int = 0;
	public var ranksList:Array<String> = ["Skill Issue", "E", "D", "C", "B", "A", "S"]; //for score text
	public var fcList:Array<String> = ["[Nice FC]", "[Awful FC]", "[SFC]", "[GFC]", "[FC]", "[FC]", "[SDCB]", "[Pass]","youre just terrible"]; //fc shit
	
	//song stuff
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	//hud shit
	public var iconP1:HealthIcon; 
	public var iconP2:HealthIcon;
	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;
	public var scoreTxt:FlxText;
	public var P2scoreTxt:FlxText;
	public var timeText:FlxText;
	public var songtext:String; //for time text
	public var modeText:String; //also for time text
	public var botPlayTxt:FlxText;
	//private var P2healthBar:FlxBar; //fuck this it will take too long
	public var hudThing:FlxTextAlign = LEFT;
	public var songhudThing:FlxTextAlign = CENTER;

	//camera shit
	public var camHUD:FlxCamera;
	public var camOnTop:FlxCamera;
	private var camGame:FlxCamera;

	public var camZooming:Bool = false;
	public var camFollow:FlxObject;
	public static var prevCamFollow:FlxObject;
	public var camSpeed:Float = 0.04;
	public static var defaultCamZoom:Float = 1.05;

	public static var beatCamZoom:Float = 0.015;
	public static var beatCamHUD:Float = 0.03;
	public static var beatCamHowOften:Int = 4; //how many beats until next zoom

	//dialogue
	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var talking:Bool = true;
	var inCutscene:Bool = false;

	//stages
	public var StagePiecesBEHIND:FlxTypedGroup<Dynamic>; //changed to just dynamic so you can add anything to it
	public var StagePiecesGF:FlxTypedGroup<Dynamic>;
	public var StagePiecesDAD:FlxTypedGroup<Dynamic>;
	public var StagePiecesBF:FlxTypedGroup<Dynamic>;
	public var StagePiecesFRONT:FlxTypedGroup<Dynamic>;
	var stageException:Bool = false; //just used for week 6 stage, because of its weird set graphic size shit, oh wait i fixed it right
	var stageOffsets:Map<String, Array<Dynamic>>;
	var pieceArray = [];
	public static var stageData:Array<Dynamic>;

	//some extra random stuff i didnt know where to put
	
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
	public var player:Boyfriend;
	public var player2:Boyfriend;
	public var cpu:Boyfriend;
	var centerHealthBar:Bool = false;

	public var showStrumsOnStart:Bool = true;
	public var allowSongStart:Bool = true;


	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	public var modchartScript:HscriptShit;
	public function call(tfisthis:String, shitToGoIn:Array<Dynamic>)
	{
		if (modchartScript.enabled)
			modchartScript.call(tfisthis, shitToGoIn); //because
	}
	public var scriptEvents:Array<ScriptEvent> = [];

	public var amountOfNoteCams = 1; //for funni effects, make sure the change this in loadScript(), otherwise it wont work and will prob crash
	public var amountOfExtraPlayers = 0;

	override public function create()
	{
		instance = this;
		FlxG.mouse.visible = false;

		Main.updateGameData();

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		var songLowercase = PlayState.SONG.song.toLowerCase();
		modchartScript = new HscriptShit("assets/data/charts/" + songLowercase + "/script.hscript");
		trace ("file loaded = " + modchartScript.enabled);
		call("loadScript", []);

		var diffText = CoolUtil.CurSongDiffs[storyDifficulty];
		if (isStoryMode)
			diffText = StoryMenuState.StoryData.weeks[storyWeek].diffs[storyDifficulty];

		songtext = PlayState.SONG.song + " - " + diffText;

		#if sys
		cacheSong();
		#end

		playerList = [];

		p1 = new Player(1);
		p2 = new Player(0);
		p3 = new Player(2); //p3 is gf

		p1.mustHitNotes = true;

		playerList.push(p2);
		playerList.push(p1);
		playerList.push(p3);

		if (amountOfExtraPlayers > 0)
		{
			for (i in 0...amountOfExtraPlayers)
			{
				var extraP = new Player(i + 3); //+3 because p 1-3 are hardcoded
				playerList.push(extraP);
			}
		}

		for (p in playerList)
			p.generatedStrums = false;

		p1.resetStats();
		p2.resetStats();

		for (i in 0...3)
		{
			var missSound = new FlxSound().loadEmbedded(Paths.sound('missnote' + (i + 1)));
			FlxG.sound.list.add(missSound);
			missSounds.push(missSound);

			missSound.onComplete = function()
			{
				missSound.volume = 0;
				missSound.stop();
			}
		}


		beatCamZoom = 0.015;
		beatCamHUD = 0.03;
		beatCamHowOften = 4; 
		rewinding = false;
		regeneratingNotes = false;

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camHUD.alpha = SaveData.hudOpacity;
		p1.createCams();
		p2.createCams();
		camOnTop = new FlxCamera();
		camOnTop.bgColor.alpha = 0;

		//var splitClip = new FlxRect(0, 0, 600, 0);
		//camP1NotesSplit.screen.clipRect = splitClip;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		p1.addCams();
		p2.addCams();
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

		//p1.downscrollCheck(SaveData.downscroll, SaveData.splitScroll); //didnt wanna work
		//p2.downscrollCheck(SaveData.P2downscroll, SaveData.P2splitScroll);

		if (SaveData.downscroll) //im not sure if this is the smartest or the stupidest way of doing downscroll
		{
			for (i in 0...amountOfNoteCams)
			{
				p1.noteCams[i].flashSprite.scaleY *= -1;
				p1.noteCamsSus[i].flashSprite.scaleY *= -1;
			}
		}	
		if (SaveData.P2downscroll) //well it works lol
		{
			for (i in 0...amountOfNoteCams)
			{
				p2.noteCams[i].flashSprite.scaleY *= -1;
				p2.noteCamsSus[i].flashSprite.scaleY *= -1;
			}
		}
			

		if (SaveData.Hellchart)
			SONG.mania = 5; //make 8k

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
		ModchartUtil.P1CamShake = [0,0];
		ModchartUtil.P2CamShake = [0,0];

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
		Conductor.recalculateTimings(); //fix time scale so can hit notes easier

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

		var diffText = CoolUtil.CurSongDiffs[storyDifficulty];
		if (isStoryMode)
			diffText = StoryMenuState.StoryData.weeks[storyWeek].diffs[storyDifficulty];

		storyDifficultyText = diffText;

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

		StagePiecesBEHIND = new FlxTypedGroup<Dynamic>();
		add(StagePiecesBEHIND);

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


		var characterList:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));
		var gfcharacter:String = SONG.gfVersion;

		if (!characterList.contains(gfcharacter))
			gfcharacter = "gf";


		gf = new Character(gfDefaultPos[0], gfDefaultPos[1], gfcharacter);
		gf.scrollFactor.set(0.95, 0.95);

		extraCharacters = new FlxTypedGroup<Boyfriend>();
		add(extraCharacters);

		var dadcharacter:String = SONG.player2;
		var bfcharacter:String = SONG.player1;

		
		if (!characterList.contains(dadcharacter)) //stop the fucking game from crashing when theres a character that doesnt exist
			dadcharacter = "dad";
		if (!characterList.contains(bfcharacter))
			bfcharacter = "bf";

		p1.activeCharacters = [bfcharacter];
		p2.activeCharacters = [dadcharacter];
		p3.activeCharacters = [gfcharacter];

		if (characters)
		{
			for (i in 0...extraCharactersList.length)
				{
					var character:Boyfriend = new Boyfriend(dadDefaultPos[0], dadDefaultPos[1], extraCharactersList[i], false, true);
					var offset = character.posOffsets.get('pos');
					if (character.posOffsets.exists('pos'))
					{
						character.x += offset[0];
						character.y += offset[1];
					}
					call("characterMade", [character]);
					extraCharacters.add(character);

				}
		}


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



		dad = new Boyfriend(dadDefaultPos[0], dadDefaultPos[1], dadcharacter, isdadPlayer, false);
		boyfriend = new Boyfriend(bfDefaultPos[0], bfDefaultPos[1], bfcharacter, isbfPlayer, true);
		call("characterMade", [dad]);
		call("characterMade", [boyfriend]);
		call("characterMade", [gf]);

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
		
		var stupidArray:Array<String> = ['dad', 'bf', 'gf'];
		var stupidCharArray:Array<Dynamic> = [dad, boyfriend, gf];
		//stage offsets
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

		if (characters)
			add(gf);

		// Shitty layering but whatev it works LOL
		StagePiecesGF = new FlxTypedGroup<Dynamic>();
		add(StagePiecesGF);

		if (characters)
		{
			add(dad);
			StagePiecesDAD = new FlxTypedGroup<Dynamic>();
			add(StagePiecesDAD);
			add(boyfriend);
			StagePiecesBF = new FlxTypedGroup<Dynamic>();
			add(StagePiecesBF);
		}
		StagePiecesFRONT = new FlxTypedGroup<Dynamic>();
		add(StagePiecesFRONT);

		modchartStorage = new Map<String, Dynamic>();

		if (!stageException && backgrounds)
		{
			for (i in 0...pieceArray.length) //x and y are optional and set in StagePiece.hx, so for loop can be used
			{
				var piece:StagePiece = new StagePiece(0, 0, pieceArray[i]);
				
				if (pieceArray[i] == 'bgDancer')
					piece.x += (370 * (i - 2));
				
				piece.x += piece.newx;
				piece.y += piece.newy;
				switch (piece.pieceLayer)
				{
					case BEHIND:
						StagePiecesBEHIND.add(piece);
					case GF:
						StagePiecesGF.add(piece);
					case DAD:
						StagePiecesDAD.add(piece);
					case BF:
						StagePiecesBF.add(piece);
					case FRONT:
						StagePiecesFRONT.add(piece);
				}
				
			}
		}


		var doof:DialogueBox = new DialogueBox(false, dialogue);
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, StrumLineStartY).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		//strumLineNotes = new StrumLineGroup();
		//add(strumLineNotes);

		p1.createStrums();
		p2.createStrums();
		p3.createStrums();
		if (amountOfExtraPlayers > 0)
		{
			for (i in 0...amountOfExtraPlayers)
			{
				playerList[i + 3].createStrums();
			}
		}
		add(p1.strums.noteSplashes);
		add(p2.strums.noteSplashes);

		add(p1.strums);
		add(p2.strums);
		if (SONG.showGFStrums)
			add(p3.strums);

		if (amountOfExtraPlayers > 0)
		{
			for (i in 0...amountOfExtraPlayers)
			{
				add(playerList[i + 3].strums);
			}
		}


		generateSong(SONG.song);


		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		var frameRateShit = camSpeed * (60 / (cast(Lib.current.getChildAt(0), Main)).getFPS());
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
			healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), p1.Stats,
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

		P2scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 540, healthBarBG.y + 30, 0, "", 20);
		P2scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		P2scoreTxt.scrollFactor.set();

		timeText = new FlxText(healthBarBG.x + healthBarBG.width - 540, healthBarBG.y - 60, 0, "", 20);
		timeText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		timeText.scrollFactor.set();

		if (centerHealthBar)
		{
			timeText.y = (FlxG.height * 0.1) - 60;
			if (SaveData.hudPos == "Default")
				scoreTxt.y = (FlxG.height * 0.9) + 30;
		}

		if (!multiplayer)
		{
			switch (SaveData.hudPos)
			{
				case "Left": 
					scoreTxt.x = 20;
					scoreTxt.y = 250;
				case "Right": 
					scoreTxt.x = FlxG.width - 200;
					scoreTxt.y = 250;
					hudThing = RIGHT;
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
		}
		else 
		{
			scoreTxt.x = FlxG.width - 200;
			scoreTxt.y = 250;
			hudThing = RIGHT;

			P2scoreTxt.x = 20;
			P2scoreTxt.y = 250;
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
		if (multiplayer)
		{
			add(P2scoreTxt);
			P2scoreTxt.cameras = [camHUD];
		}
			
		p1.setNoteCams();
		p2.setNoteCams();
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
					if (allowSongStart)
						startCountdown();
					else 
						call("cutscene", []);
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					if (allowSongStart)
						startCountdown();
					else
						call("cutscene", []);
			}
		}

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN,handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);

		call("onPlayStateCreated", []);
		call("onStateCreated", []);

		super.create();
	}


	
	function stageExpectionCheck(stage:String) //only did this so you can access stages in the stage debug menu, just week 4/6 will be weird, but idk tbh theyre vanilla stages
	{
		switch(stage)
		{
			case "schoolEvil": 
				var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
				var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
		}
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
	var sustainsHeld = [false, false, false, false, false, false, false, false, false];
	var P2sustainsHeld = [false, false, false, false, false, false, false, false, false];

	public function startCountdown():Void
	{
		if (startedCountdown)
			return; //so you cant fuck with the game

		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);
		if (SONG.showGFStrums)
			generateStaticArrows(2);

		for (i in 0...amountOfExtraPlayers)
		{
			generateStaticArrows(i + 3);
		}

		//var splitRect:FlxRect = new FlxRect(50 + (FlxG.width / 2) + (Note.swagWidth * (keyAmmo[mania] / 2)),0, FlxG.width / 2, 0);


		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		if (unspawnNotes[0] != null)
			spawnNote();

		

		var P1binds:Array<String> = CoolUtil.bindCheck(mania, false, SaveData.binds, mania);
		var P2binds:Array<String> = CoolUtil.bindCheck(mania, false, SaveData.P2binds, mania);

		if (showStrumsOnStart)
		{
			if (multiplayer)
			{
				createKeybindText(p1.strums, P1binds, SaveData.downscroll);
				createKeybindText(p2.strums, P2binds, SaveData.P2downscroll);
			}
			else if (flipped)
			{
				createKeybindText(p2.strums, P1binds, SaveData.P2downscroll);	
			}
			else
			{
				createKeybindText(p1.strums, P1binds, SaveData.downscroll);
			}		
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

		var binds:Array<String> = SaveData.binds[0];
		var data = -1;
		var playernum:Int = 1;
		
		binds = CoolUtil.bindCheck(mania, false, SaveData.binds, p1Mania);
		//data = CoolUtil.arrowKeyCheck(maniaToChange, evt.keyCode); //arrow keys are shit, just set them in keybinds, sorry to anyone who plays both wasd + arrow keys, might add alt keys at some point

		var P2binds:Array<String> = [null,null,null,null]; //null so you cant misspress while not in multi
		if (multiplayer) //so it only checks when in multi
			P2binds = CoolUtil.bindCheck(mania, false, SaveData.P2binds, p2Mania);

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
				P2sustainsHeld[data] = false;
			case 1: 
				if (data == -1)
					{
						return;
					}
				keys[data] = false;
				sustainsHeld[data] = false;
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
		var binds:Array<String> = SaveData.binds[0];
		binds = CoolUtil.bindCheck(mania, false, SaveData.binds, p1Mania); //finally got rid of that fucking huge case statement, its still inside coolutil, but theres only 1, not like 4 lol
		//data = CoolUtil.arrowKeyCheck(maniaToChange, evt.keyCode);

		var P2binds:Array<String> = [null,null,null,null]; //null so you cant misspress while not in multi
		if (multiplayer) //so it only checks when in multi
			P2binds = CoolUtil.bindCheck(mania, false, SaveData.P2binds, p2Mania);

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
				P2sustainsHeld[data] = true;
			case 1: 
				if (keys[data] || data == -1)
					{
						return;
					}
				keys[data] = true;
				sustainsHeld[data] = true;
		}
		normalInputSystem(data, playernum);		
	}


	//////////////////////////////////////////////////////////////////////////////////




	public function normalInputSystem(data:Int, playernum:Int)
	{
		closestNotes = [];
		P2closestNotes = [];
		if (multiplayer)
		{
			closestNotes = collectNotes(p1.strums.notes, true);
			P2closestNotes = collectNotes(p2.strums.notes, false);
		}
		else if (flipped)
			closestNotes = collectNotes(p2.strums.notes, false);
		else
			closestNotes = collectNotes(p1.strums.notes, true);


		

		closestNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
		P2closestNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

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
					{
						var notesThatCanBeHit = hittableNotes.length;
						for (i in 0...Std.int(notesThatCanBeHit / 2)) //only hit half of them so its not tooooo easy for people, but its still possible to hit a lot of notes
						{
							goodNoteHit(hittableNotes[i], playernum);
						}
						
					}
						
				}

			}

			goodNoteHit(daNote, playernum);
		}
		else if (!SaveData.ghost && songStarted && !grace)
		{
			//trace("you mispressed you dumbass");
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
	function cacheSong():Void 
	{
		var inst = Paths.inst(PlayState.SONG.song);
		if (CacheShit.sounds[inst] == null)
		{
			var sound:FlxSoundAsset = Sound.fromFile(inst);
			CacheShit.sounds[inst] = sound;
		}
		var vocal = Paths.voices(PlayState.SONG.song);
		if (CacheShit.sounds[vocal] == null)
		{
			var sound:FlxSoundAsset = Sound.fromFile(vocal);
			CacheShit.sounds[vocal] = sound;
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
			/*var path:String = Paths.inst(PlayState.SONG.song);
			var byteshit = File.getBytes(path);
			var audioBuffer = AudioBuffer.fromBytes(byteshit);
			var byteshitagain = audioBuffer.data.toBytes();
			
			if (backwardSong) //uhh tryin to do backward song but reversing audio is kinda hard, apparently flipping the bits can do it??????? but idk im stupid
			{
				//do byte reverse shit here

				#if cpp //cpp cuz bytesdata is an actual array, so i can do reverse
				var bytedata:BytesData = byteshitagain.getData();
				//trace(bytedata[0]);
				bytedata.reverse(); //hehe
				//trace(bytedata[0]);
				byteshitagain = Bytes.ofData(bytedata);
				#end
				audioBuffer = AudioBuffer.fromBytes(byteshitagain);
			}
			


			var songInst:FlxSoundAsset = Sound.fromAudioBuffer(audioBuffer);*/

			

			FlxG.sound.playMusic(CacheShit.sounds[Paths.inst(PlayState.SONG.song)], 1, false);
			#else
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
			#end
			call("startSong", [PlayState.SONG.song]);
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
			vocals = new FlxSound().loadEmbedded(CacheShit.sounds[Paths.voices(PlayState.SONG.song)]);
			#else
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
			#end
		}
			
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		p1.addNotes();
		p2.addNotes();
		p3.addNotes();
		if (amountOfExtraPlayers > 0)
		{
			for (i in 0...amountOfExtraPlayers)
			{
				playerList[i + 3].addNotes();
			}
		}

		generateNotes();

		generatedMusic = true;

		if (unspawnNotes[0] != null)
			spawnNote();
	}



	private function generateStaticArrows(playernum:Int):Void
	{
		var amountOfArrows = keyAmmo[mania];
		if (playernum > 2)
			amountOfArrows = 4;

		var curPlayer = getPlayerFromID(playernum);

		for (i in 0...amountOfArrows)
		{
			var style:String = "normal";

			var babyArrow:BabyArrow = new BabyArrow(strumLine.y, playernum, i, style, true);

			switch (playernum)
			{
				case 0:
					p2.strums.add(babyArrow);
					p2.strums.curMania = mania;
					//if (PlayStateChangeables.bothSide)
						//babyArrow.x -= 500;
					p2.strums.forEach(function(spr:BabyArrow)
					{					
						spr.centerOffsets();
					});
				case 1:
					p1.strums.add(babyArrow);
					p1.strums.curMania = mania;
				case 2: 
					curPlayer.strums.add(babyArrow);
					if (SONG.showGFStrums)
					{
						p3.strums.forEach(function(spr:BabyArrow)
						{					
							spr.centerOffsets();
						});
					}
				default:
					curPlayer.strums.add(babyArrow);
					curPlayer.strums.forEach(function(spr:BabyArrow)
					{					
						spr.centerOffsets();
					});
			}
			//strumLineNotes.add(babyArrow); //no more fuck you
		}

		curPlayer.generatedStrums = true;
		
		switch (playernum)
		{
			case 0:
				call("onStrumsGenerated", [p2.strums]);
			case 1:
				call("onStrumsGenerated", [p1.strums]);
			case 2: 
				call("onStrumsGenerated", [p3.strums]);
		}
	}

	public function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.volume = 0;
				vocals.volume = 0;
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
				FlxG.sound.music.volume = 1;
				vocals.volume = 1;
				//resyncInst();
				resyncVocals();
			}

			var frameRateShit = camSpeed * (60 / (cast(Lib.current.getChildAt(0), Main)).getFPS());
			FlxG.camera.follow(camFollow, LOCKON, frameRateShit); //fixes camera shit when changing fps
			Conductor.recalculateTimings();

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
		if (p1.Stats.health > 0 && !paused)
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
		if (p1.Stats.health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}
		#end

		super.onFocusLost();

	}

	function resyncVocals():Void //(sync song position to music)
	{
		if (!endingSong && !rewinding)
		{
			trace("synced vocals");
			FlxG.sound.music.pause();
			vocals.pause();
			Conductor.songPosition = FlxG.sound.music.time;
			vocals.time = FlxG.sound.music.time;
			FlxG.sound.music.play();
			vocals.play();
	
			updateSongMulti();
		}
	}
	function resyncInst():Void //(sync music to song position)
	{
		if (!endingSong)
		{
			trace("synced Inst");
			FlxG.sound.music.pause();
			FlxG.sound.music.time = Conductor.songPosition;
			FlxG.sound.music.play();
			updateSongMulti();

			resyncVocals(); //sync vocals at same time
		}

	}

	function updateSongMulti():Void
	{
		if (allowSpeedChanges)
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

			
			/*#if cpp
			@:privateAccess
			{
				lime.media.openal.AL.speedOfSound(SongSpeedMultiplier);
			}
			#end*/			
		}
	}

	function rewindAudio():Void 
	{
		if (allowSpeedChanges)
		{
			#if cpp
			@:privateAccess
			{
				lime.media.openal.AL.sourceRewind(FlxG.sound.music._channel.__source.__backend.handle);
				//if (SONG.needsVoices)
				if (vocals.playing)
					lime.media.openal.AL.sourceRewind(vocals._channel.__source.__backend.handle);
			}
			#end	
		}
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	function calculateStrumtime(daNote:Note, Strumtime:Float) //for note velocity shit, used andromeda engine as a guide for this https://github-dotcom.gateway.web.tr/nebulazorua/andromeda-engine
	{
		var ChangeTime:Float = daNote.strumTime;
		if (daNote.velocityData != null)
		{
			ChangeTime = (daNote.strumTime - daNote.velocityData.ChangeTime);
			if (daNote.velocityData.UseSpecificStrumTime)
				ChangeTime = daNote.velocityData.ChangeTime;
		}	


		var StrumDiff = (Strumtime - ChangeTime);
		var Multi:Float = 1;
		if (daNote.velocityData != null)
		{
			if (Strumtime >= ChangeTime)
				Multi = daNote.velocityData.SpeedMulti;
		}


		var pos = ChangeTime * daNote.speed;
		pos += StrumDiff * (daNote.speed * Multi);
		return pos;
	}

	function NotePositionShit(daNote:Note, strums:String)
	{
		/*if (!daNote.isOnScreen(daNote.cameras[0]))
		{
			daNote.active = false;
			daNote.visible = false;
		}
		else
		{
			if (daNote.active == false)
			{
				switch (strums)
				{
					case "player": 
						call('P1NoteNowOnScreen', [daNote]); //TODO fix this shit it dont work
					case "gf": 
						call('P3NoteNowOnScreen', [daNote]);
					default: 
						call('P2NoteNowOnScreen', [daNote]);
				}
			}

		}*/
		daNote.visible = true;
		daNote.active = true;

		var noteY:Float = 0; //i uncapitalized these because i knew it would annoy people lol
		var noteX:Float = 0;
		var noteAngle:Float = 0;
		var noteAlpha:Float = 1;
		var noteVisible:Bool = true;

		

		var wasGoodHit:Bool = daNote.wasGoodHit; //so it doesnt have to check multiple times
		var isSustainNote:Bool = daNote.isSustainNote; //its running this shit every frame for every note
		
		var strumID:Int = daNote.strumID;
		var canBeHit:Bool = daNote.canBeHit;
		var tooLate:Bool = daNote.tooLate;
		var noteData:Int = daNote.noteData;

		var curPlayer:Player = getPlayerFromID(daNote.strumID);

		
		if (!curPlayer.generatedStrums)
			return;



		var StrumGroup:StrumLineGroup = curPlayer.strums;
		var playernum = strumID;
		var modif = curPlayer.modifiers;

		if (modif.scramble != 0)
			daNote.noteDataToFollow = Std.int(noteData + modif.scramble) % keyAmmo[mania];
		else
			daNote.noteDataToFollow = noteData;

		daNote.mustPress = curPlayer.mustHitNotes; //you could probably switch this mid song for a cool effect ig
		var mustPress:Bool = daNote.mustPress;

		//trace(strumID);
		//trace(daNote.noteDataToFollow);

		var datashit = Math.floor(Math.abs(daNote.noteDataToFollow % curPlayer.strums.length));
		var strumNote:BabyArrow = curPlayer.strums.members[datashit];

		daNote.scrollFactor.set(modif.strumScrollFactor[0], modif.strumScrollFactor[1]);



			

		var middleOfNote:FlxPoint = strumNote.centerOfArrow;
		
		noteX = strumNote.x;
		noteY = strumNote.y;
		noteAlpha = strumNote.alpha;
		noteVisible = strumNote.visible;
		noteAngle = strumNote.angle;

		var anglething = daNote.incomingAngle + (strumNote.strumLineAngle + 90);
		if (modif.incomingAngleIsStrumAngle)
			anglething = strumNote.angle - 90;

		if (modif.drugged != 0)
			anglething = anglething + 15 * Math.sin(currentBeat * modif.drugged);

		var calculatedStrumtime = calculateStrumtime(daNote, Conductor.songPosition);
		var notePos:FlxPoint;
		var noteCurPos = daNote.startPos - calculatedStrumtime;
		daNote.curPos = noteCurPos;
		notePos = FlxAngle.getCartesianCoords(0.45 * noteCurPos, anglething);		
		daNote.setPosition(noteX - notePos.x, noteY - notePos.y);
			
		if (flipped || (multiplayer && strums == "cpu"))
			mustPress = !mustPress; //this is just for detecting it, not actually a must press note lol
		
		daNote.visible = noteVisible;
		daNote.angle = daNote.incomingAngle + 90;
		if (Note.followAngle)
			daNote.angle = noteAngle;

		/*if (strumID > 2)
		{
			trace(daNote.scrollFactor.x);
			trace(daNote.cameras);
			trace(daNote.y);
		}*/
		

		var holdingSustain:Bool = sustainsHeld[noteData] || (multiplayer && strums == "cpu" && P2sustainsHeld[noteData]);
		if (isSustainNote)
			if (!mustPress || daNote.isGFNote || holdingSustain || SaveData.botplay && modif.strumsFollowNotes != 0)
				daNote.clipSustain(middleOfNote);

		
	
		if (isSustainNote)
		{
			daNote.x += daNote.sustainXOffset;
			daNote.angle = anglething + 90; //sustains always follow incoming angle to not look weird
		}
		daNote.alpha = modif.noteAlpha * daNote.curAlpha;
		ModchartUtil.noteModifierShit(daNote, playernum);
		
		if (daNote.beenFlipped)
		{
			daNote.y += daNote.downscrollYOffset; //y offset of notetypes  (only downscroll for some reason, weird shit with the graphic flip)
			//bruh i made a whole menu just to help fix and it doesnt even match up wtf
			//ok so i halfed what it said on the offset menu and it worked correctly, this games confuses me so much
		}


		call("NoteOffsets", [daNote]);
	}

	function NoteMissDetection(daNote:Note, strums:String, playernum:Int = 1)
	{
		var wasGoodHit:Bool = daNote.wasGoodHit; //so it doesnt have to check multiple times
		var mustPress:Bool = daNote.mustPress;
		var tooLate:Bool = daNote.tooLate;

		if (strums == "cpu")
			mustPress = !mustPress; //this is just for detecting it, not actually a must press note lol

		var statsToUse = getStats(playernum);

		if (SaveData.botplay && Conductor.songPosition >= daNote.strumTime && !daNote.badNoteType)
			goodNoteHit(daNote, playernum);
		else if (mustPress && (tooLate && !wasGoodHit))
		{
			daNote.noteTypeMiss(strums, playernum);
		}
	}

	function NoteCpuHit(daNote:Note, strums:String)
	{
		var wasGoodHit:Bool = daNote.wasGoodHit;
		var noteData:Int = daNote.noteData;

		var strumID:Int = daNote.strumID;
		var curPlayer:Player = getPlayerFromID(strumID);

		if (wasGoodHit && !daNote.sustainHit)
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
			{
				
				if (curPlayer.activeCharacters.contains(cpu.curCharacter))
					cpu.playAnim('sing' + sDir[mania][noteData] + altAnim, true, false, 0, noteData);
				for (character in extraCharacters)
				{
					if ((character.canSing && !character.player1Side && !flipped) || (flipped && character.canSing && character.player1Side))
					{
						if (curPlayer.activeCharacters.contains(character.curCharacter))
							character.playAnim('sing' + sDir[mania][noteData] + altAnim, true, false, 0, noteData);
						//character.holdTimer = 0;			
					}
				}
			}
				

			if (flipped)
			{
				if (ModchartUtil.P1CamShake[0] != 0)
					FlxG.camera.shake(ModchartUtil.P1CamShake[0], ModchartUtil.P1CamShake[1]);
			}
			else
			{
				if (ModchartUtil.P2CamShake[0] != 0)
					FlxG.camera.shake(ModchartUtil.P2CamShake[0], ModchartUtil.P2CamShake[1]);
			}

			curPlayer.strums.forEach(function(spr:BabyArrow)
			{
				if (Math.abs(noteData) == spr.ID)
				{
					if (!daNote.badNoteType)
						spr.playAnim('confirm', true, spr.ID, daNote.colorShit);
				}
			});

			if (Note.noteTypeList[daNote.noteType] == "drain")
			{
				if ((drainNoteAmount * 2) > p1.Stats.health)
					p1.Stats.health = drainNoteAmount * 2;
				else 
					p1.Stats.health -= drainNoteAmount;
			}

			cpu.noteCamMovement = noteCamMovementShit(daNote.noteData, 0);

			//if (!daNote.badNoteType)
				//cpu.holdTimer = 0;

			if (SONG.needsVoices)
				vocals.volume = 1;

			if (!daNote.isSustainNote)
			{
				daNote.active = false;
				removeNote(daNote);
			}
			else
				daNote.sustainHit = true;

		}
	}
	function GFNoteHit(daNote:Note)
	{
		var wasGoodHit:Bool = daNote.wasGoodHit;
		var noteData:Int = daNote.noteData;

		if (!SONG.showGFStrums)
			daNote.visible = false; //im a fucking dummass i spend over an hour tryin to make the notes appear and its becuase of this

		if (wasGoodHit)
		{
			var altAnim:String = "";

			if (Note.noteTypeList[daNote.noteType] == "alt")
				altAnim = '-alt';

			call('P3CpuNoteHit', [daNote]);

			if (!daNote.isSustainNote)
			{
				if (daNote.eventData != null)
				{
					var eventName = daNote.eventData[0];
					var eventData = daNote.eventData[1];
					EventList.convertEventDataToEvent(eventName, eventData, daNote);
				}
			}
			else
			{
				daNote.eventWasValid = false;
			}


			if (!daNote.eventWasValid)
			{
				gf.playAnim('sing' + sDir[mania][noteData] + altAnim, true);
				//gf.holdTimer = 0;
			}

			if (SONG.showGFStrums)
			{
				p3.strums.forEach(function(spr:BabyArrow)
				{
					if (Math.abs(noteData) == spr.ID)
					{
						if (!daNote.badNoteType)
							spr.playAnim('confirm', true, spr.ID, daNote.colorShit);
					}
				});
			}


			if (SONG.needsVoices)
				vocals.volume = 1;

			daNote.active = false;

			daNote.kill();
			p3.strums.notes.remove(daNote, true);
			daNote.destroy();
		}
	}

	function updateNPS(playernum:Int):Void
	{
		var statsToUse = getStats(playernum);

		for (i in 0...statsToUse.npsArray.length)
		{
			var timeNoteWasHit = statsToUse.npsArray[i];

			if ((Conductor.songPosition - timeNoteWasHit) >= 1000)
			{
				statsToUse.npsArray.remove(statsToUse.npsArray[i]);
			}
		}
		statsToUse.nps = statsToUse.npsArray.length;
		if (statsToUse.nps > statsToUse.highestNps)
			statsToUse.highestNps = statsToUse.nps;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		call("update", [elapsed]);

		elapsedTime += elapsed;
		
		if (!allowSpeedChanges)
			SongSpeedMultiplier = 1;

		if (SaveData.botplay)
			botPlayTxt.visible = true;
		else
			botPlayTxt.visible = false;

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
				resyncInst();
			}
		}
		
		updateNPS(1);
		if (multiplayer)
			updateNPS(0);
		updateTimer();
		updateHUD(1);
		if (multiplayer)
			updateHUD(0);

		if (generatedMusic && songStarted && !endingSong)
		{
			if (songLength - Conductor.songPosition <= 200) ///yooo it works pog
			{
				//resyncVocals();

				endingSong = true;
				endSong();
			}
			if (songLength - Conductor.songPosition <= 2000) //near the end, get ready for to end
			{
				if (!nearEndOfSong)
				{
					nearEndOfSong = true;
					new FlxTimer().start(2.5, function(tmr:FlxTimer) //forcefully end if it loops
					{
						endingSong = true;
						endSong();
					});
				}
			}		
					
			else if (FlxG.sound.music.playing && canPause && !endingSong)
			{
				updateSongMulti();
			}
				
		}	

		currentBeat = (Conductor.songPosition / 1000)*(SONG.bpm/60);

		if (legacyModcharts)
		{
			p1.strums.forEach(function(spr:BabyArrow) //these shitty
			{
				ModchartUtil.CalculateArrowShit(spr, spr.curID, 1, "X", currentBeat);
				ModchartUtil.CalculateArrowShit(spr, spr.curID, 1, "Y", currentBeat);
				ModchartUtil.CalculateArrowShit(spr, spr.curID, 1, "Angle", currentBeat);
			});
			p2.strums.forEach(function(spr:BabyArrow)
			{
				ModchartUtil.CalculateArrowShit(spr, spr.curID, 0, "X", currentBeat);
				ModchartUtil.CalculateArrowShit(spr, spr.curID, 0, "Y", currentBeat);
				ModchartUtil.CalculateArrowShit(spr, spr.curID, 0, "Angle", currentBeat);
			});
		}

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
			call('endScript', []);
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		p1.Stats.health = poisonHealthCheck(1, elapsed);
		if (multiplayer)
			p2.Stats.health = poisonHealthCheck(0, elapsed);

		if (p1.Stats.health > 2)
			p1.Stats.health = 2;

		if (p2.Stats.health > 2)
			p2.Stats.health = 2;

		combinedHealth = p1.Stats.health - p2.Stats.health;

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


		if (unspawnNotes[0] != null)
			spawnNote();

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
			Conductor.songPosition += (FlxG.elapsed * 1000) * SongSpeedMultiplier;
			/*if (!endingSong)
			{
				if (Conductor.songPosition - FlxG.sound.music.time > (20 * PlayState.SongSpeedMultiplier) || Conductor.songPosition - FlxG.sound.music.time < (-20 * PlayState.SongSpeedMultiplier))
					resyncInst();
			}*/


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

		if (generatedMusic && currentSection != null && characters) //crashes with no characters cuz graphic midpoint shit idk
		{
			if (!overrideCam)
			{
				if (!currentSection.mustHitSection)
					moveCamera(getCameraPos(0));
				else if (currentSection.mustHitSection)
					moveCamera(getCameraPos(1));
			}
		}
		if (alignCams)
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

		if (p1.Stats.health <= healthToDieOn || p2.Stats.health <= healthToDieOn)
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
			p1.strums.notes.forEachAlive(function(daNote:Note)
			{
				NotePositionShit(daNote, "player");
				if (flipped && !multiplayer)
					NoteCpuHit(daNote, "player");
				else
					NoteMissDetection(daNote, "player", 1);
					
			});
			p2.strums.notes.forEachAlive(function(daNote:Note)
			{
				NotePositionShit(daNote, "cpu");
				if (multiplayer)
					NoteMissDetection(daNote, "cpu", 0);
				else if (flipped && !multiplayer)
					NoteMissDetection(daNote, "cpu", 1);
				else
					NoteCpuHit(daNote, "cpu");
			});
			p3.strums.notes.forEachAlive(function(daNote:Note)
			{
				if (SONG.showGFStrums)
					NotePositionShit(daNote, "gf");

				GFNoteHit(daNote);
			});
			for (i in 0...amountOfExtraPlayers)
			{
				var curPlaye:Player = getPlayerFromID(i + 3);
				curPlaye.strums.notes.forEachAlive(function(daNote:Note)
				{
					NotePositionShit(daNote, curPlaye.mustHitNotes ? "player" : "cpu");
					NoteCpuHit(daNote, curPlaye.mustHitNotes ? "player" : "cpu");
				});
			}


		}
		if (flipped && !multiplayer)
			resetBabyArrowAnim(p1.strums);
		else if (!multiplayer)
			resetBabyArrowAnim(p2.strums);

		if (SONG.showGFStrums)
			resetBabyArrowAnim(p3.strums);

		for (i in 0...amountOfExtraPlayers)
		{
			var curPlaye:Player = getPlayerFromID(i + 3);
			resetBabyArrowAnim(curPlaye.strums);
		}


		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (!inCutscene)
		{
			if (gamepad != null)
				gamepadCheck(gamepad);
			keyShit();
		}

		PlayState.p1.updateCams();
		PlayState.p2.updateCams();
		PlayState.p3.updateCams();

		if (scriptEvents.length > 0)
			for (i in 0...scriptEvents.length)
				if (scriptEvents[i] is StrumTimeScriptEvent)
					scriptEvents[i].check(0);
		
			

		/*#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end*/
	}

	function endSong():Void
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN,handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
		call('endSong', []);
		call('endScript', []);
		canPause = false;
		endingSong = true;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, p1.Stats.songScore, storyDifficulty);
			#end
		}

		if (isStoryMode)
		{
			campaignScore += p1.Stats.songScore;

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
	var nearEndOfSong:Bool = false;

	public function createCountdown(rewinded:Bool = false)
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
							Conductor.recalculateTimings();
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

		if (noteDiff > Conductor.safeZoneOffset * shitTiming)
		{
			daRating = 'shit';
			score = 50;
		}
		else if (noteDiff > Conductor.safeZoneOffset * badTiming)
		{
			daRating = 'bad';
			score = 100;
		}
		else if (noteDiff > Conductor.safeZoneOffset * goodTiming)
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
					healthChanges += healthFromRating[0];
				case "good": 
					statsToUse.goods++;
					healthChanges += healthFromRating[1];
				case "bad": 
					statsToUse.bads++;
					statsToUse.ghostmisses++;
					if (!SaveData.casual)
						healthChanges += healthFromRating[2];
				case "shit":
					statsToUse.shits++;
					statsToUse.ghostmisses++;
					if (!SaveData.casual)
						healthChanges += healthFromRating[3];
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
		rating.acceleration.y = 550 * SongSpeedMultiplier;
		rating.velocity.y -= FlxG.random.int(140, 175) * SongSpeedMultiplier;
		rating.velocity.x -= FlxG.random.int(0, 10) * SongSpeedMultiplier;

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600 * SongSpeedMultiplier;
		comboSpr.velocity.y -= 150 * SongSpeedMultiplier;

		comboSpr.velocity.x += FlxG.random.int(1, 10) * SongSpeedMultiplier;
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

			numScore.acceleration.y = FlxG.random.int(200, 300) * SongSpeedMultiplier;
			numScore.velocity.y -= FlxG.random.int(140, 160) * SongSpeedMultiplier;
			numScore.velocity.x = FlxG.random.float(-5, 5) * SongSpeedMultiplier;

			if (daCombo >= 10 || daCombo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2 / SongSpeedMultiplier, {
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

		FlxTween.tween(rating, {alpha: 0}, 0.2 / SongSpeedMultiplier, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2 / SongSpeedMultiplier, {
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
		if ((sustainsHeld.contains(true) || P2sustainsHeld.contains(true))&& /*!boyfriend.stunned && */ generatedMusic)
		{
			if (multiplayer)
			{
				sustainHoldCheck(sustainsHeld, p1.strums.notes, true);
				sustainHoldCheck(P2sustainsHeld, p2.strums.notes, false, 0);
			}
			else if (flipped && !multiplayer)
				sustainHoldCheck(sustainsHeld, p2.strums.notes, false);
			else
				sustainHoldCheck(sustainsHeld, p1.strums.notes, true);
		}

		if (characters)
		{
			if (player.canSing)
			{
				if (player.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!keys.contains(true)))
					{
						if (player.animation.curAnim.name.startsWith('sing') && !player.animation.curAnim.name.endsWith('miss'))
							player.dance();
					}
			}
	
			for (character in extraCharacters)
			{
				if (character.player1Side)
				{
					if (character.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!keys.contains(true) || !character.canSing))
					{
						if (character.animation.curAnim.name.startsWith('sing') && !character.animation.curAnim.name.endsWith('miss'))
							character.dance();
					}
				}
	
				if (!character.player1Side && multiplayer)
				{
					if (character.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!P2keys.contains(true) || !character.canSing))
					{
						if (character.animation.curAnim.name.startsWith('sing') && !character.animation.curAnim.name.endsWith('miss'))
							character.dance();
					}
				}
			}
			if (multiplayer && player2.canSing)
			{
				if (player2.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!P2keys.contains(true)))
					{
						if (player2.animation.curAnim.name.startsWith('sing') && !player2.animation.curAnim.name.endsWith('miss'))
							player2.dance();
					}
			}
		}


		if (multiplayer)
		{
			strumPressCheck(p1.strums, keys);
			strumPressCheck(p2.strums, P2keys);
		}
		else if (flipped && !multiplayer)
			strumPressCheck(p2.strums, keys);
		else
			strumPressCheck(p1.strums, keys);

	}

	private function gamepadCheck(gamepad:FlxGamepad):Void
	{
		var binds:Array<String> = CoolUtil.bindCheck(mania, false, SaveData.GPbinds, p1Mania);
		for (i in 0...binds.length) //im suprised this worked first try without any issues
		{
			var data = -1;
			var input = FlxGamepadInputID.fromString(binds[i]);
			if (gamepad.checkStatus(input, JUST_PRESSED))
			{
				data = i;
				if (data != -1)
				{
					sustainsHeld[data] = true;
					keys[data] = true;
				}
					
				normalInputSystem(data, 1);
			}
			else if (gamepad.checkStatus(input, JUST_RELEASED))
			{
				data = i;
				if (data != -1)
				{
					sustainsHeld[data] = false;
					keys[data] = false;
				}
					
			}


		}
	}

	public function noteMiss(direction:Int = 1, daNote:Note, playernum:Int = 1):Void
	{
		var shit = player;
		var statsToUse = getStats(playernum);
		if (playernum != 1 && multiplayer)
		{
			shit = player2;
		}
			
		//trace("miss: " + playernum);
		if (!shit.stunned)
		{
			if (daNote.isSustainNote)
				statsToUse.health -= healthLossFromSustainMiss;
			else
				statsToUse.health -= healthLossFromMiss;

			//trace("miss: " + playernum);

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

			playMissSound(FlxG.random.int(0,2));

			var missAnim = 'sing' + sDir[mania][direction] + 'miss';

			if (daNote.mustPress)
			{
				call('P1NoteMiss', [daNote]);
				if (shit.animOffsets.exists(missAnim)) //assume an offset exists????
					shit.playAnim(missAnim, true, false, 0, direction);
				else 
				{
					shit.playAnim('sing' + sDir[mania][direction], true, false, 0, direction);
					if (shit.canSing)
						shit.color = 0x00303f97;
				}
				for (character in extraCharacters)
				{
					if (character.canSing && character.player1Side)
					{
						if (character.animOffsets.exists(missAnim))
							character.playAnim(missAnim, true, false, 0, direction);
						else 
						{
							character.playAnim('sing' + sDir[mania][direction], true, false, 0, direction);
							character.color = 0x00303f97;
						}
							
					}
				}
			}	
			else
			{
				call('P2NoteMiss', [daNote]);
				if (shit.animOffsets.exists(missAnim)) //assume an offset exists????
					shit.playAnim(missAnim, true, false, 0, direction);
				else 
				{
					shit.playAnim('sing' + sDir[mania][direction], true, false, 0, direction);
					if (shit.canSing)
						shit.color = 0x00303f97;
				}
				
				for (character in extraCharacters)
				{
					if (character.canSing && !character.player1Side)
					{
						if (character.animOffsets.exists(missAnim))
							character.playAnim(missAnim, true, false, 0, direction);
						else 
						{
							character.playAnim('sing' + sDir[mania][direction], true, false, 0, direction);
							character.color = 0x00303f97;
						}
							
					}
				}
			}

			if (playernum != 1 && multiplayer)
				P2scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.RED, LEFT, OUTLINE, FlxColor.BLACK);
			else
				scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.RED, hudThing, OUTLINE, FlxColor.BLACK);

			shit.stunned = true;


			// get stunned for 5 seconds
			new FlxTimer().start((5 / 60) / SongSpeedMultiplier, function(tmr:FlxTimer)
			{
				shit.stunned = false;
				shit.color = 0x00FFFFFF;
				for (character in extraCharacters)
				{
					character.color = 0x00FFFFFF;
				}
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
			statsToUse.health -= healthLossFromMissPress;

			if (statsToUse.combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			statsToUse.ghostmisses++;

			statsToUse.totalNotesHit++; //not actually missing, just for working out the accuracy

			CalculateAccuracy(playernum);

			statsToUse.songScore -= 10;

			playMissSound(FlxG.random.int(0,2));

			var missAnim = 'sing' + sDir[mania][direction] + 'miss';

			if (playernum == 1 && !flipped)
			{
				call('P1MissPress', [direction]);
				if (shit.animOffsets.exists(missAnim)) //assume an offset exists????
					shit.playAnim(missAnim, true, false, 0, direction);
				else 
				{
					shit.playAnim('sing' + sDir[mania][direction], true, false, 0, direction);
					if (shit.canSing)
						shit.color = 0x00303f97;
				}
				for (character in extraCharacters)
				{
					if (character.canSing && character.player1Side)
					{
						if (character.animOffsets.exists(missAnim))
							character.playAnim(missAnim, true, false, 0, direction);
						else 
						{
							character.playAnim('sing' + sDir[mania][direction], true, false, 0, direction);
							character.color = 0x00303f97;
						}
							
					}
				}
			}
			else
			{
				call('P2MissPress', [direction]);
				
				if (shit.animOffsets.exists(missAnim)) //assume an offset exists????
					shit.playAnim(missAnim, true, false, 0, direction);
				else 
				{
					shit.playAnim('sing' + sDir[mania][direction], true, false, 0, direction);
					if (shit.canSing)
						shit.color = 0x00303f97;
				}
				
				for (character in extraCharacters)
				{
					if (character.canSing && !character.player1Side)
					{
						if (character.animOffsets.exists(missAnim))
							character.playAnim(missAnim, true, false, 0, direction);
						else 
						{
							character.playAnim('sing' + sDir[mania][direction], true, false, 0, direction);
							character.color = 0x00303f97;
						}
							
					}
				}
			}

			if (playernum != 1 && multiplayer)
				P2scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.RED, LEFT, OUTLINE, FlxColor.BLACK);
			else
				scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.RED, hudThing, OUTLINE, FlxColor.BLACK);

			shit.stunned = true;


			// get stunned for 5 seconds
			new FlxTimer().start((5 / 60) / SongSpeedMultiplier, function(tmr:FlxTimer)
			{
				shit.stunned = false;
				shit.color = 0x00FFFFFF;
				for (character in extraCharacters)
				{
					character.color = 0x00FFFFFF;
				}
			});

		}
		
	}



	function goodNoteHit(note:Note, playernum:Int = 1):Void
	{
		if (!note.wasGoodHit)
		{
			var statsToUse = getStats(playernum);
			var modif = ModchartUtil.getModif(playernum);
			var modifvalues = ModchartUtil.getModifValues(playernum);
			if (modif.press != 0 && !note.isSustainNote)
				Reflect.setProperty(modifvalues, "pressOffset" + note.noteData, [FlxG.random.float(0,50), FlxG.random.float(0,50), FlxG.random.float(0,360)]);

			var strumID:Int = note.strumID;
			var curPlayer:Player = getPlayerFromID(strumID);

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
				
				statsToUse.sustainsHit++; //give acc from sustains
				statsToUse.totalNotesHit++;

			}
			if ((!note.isSustainNote || SaveData.casual) && !note.badNoteType)
				note.healthChangesOnHit = healthFromAnyHit;

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
				call('P1NoteHit', [note]);

				if (player.canSing)
				{
					if (curPlayer.activeCharacters.contains(player.curCharacter))
						player.playAnim('sing' + sDir[mania][note.noteData] + altAnim, true, false, 0, note.noteData);
					//player.holdTimer = 0;
				}
				for (character in extraCharacters)
				{
					if (character.canSing && (flipped ? !character.player1Side : character.player1Side))
					{
						if (curPlayer.activeCharacters.contains(character.curCharacter))
							character.playAnim('sing' + sDir[mania][note.noteData] + altAnim, true, false, 0, note.noteData);
						//character.holdTimer = 0;
					}
				}
				player.noteCamMovement = noteCamMovementShit(note.noteData, 1);
				if (!flipped)
				{
					if (ModchartUtil.P1CamShake[0] != 0)
						FlxG.camera.shake(ModchartUtil.P1CamShake[0], ModchartUtil.P1CamShake[1]);
				}
				else
				{
					if (ModchartUtil.P2CamShake[0] != 0)
						FlxG.camera.shake(ModchartUtil.P2CamShake[0], ModchartUtil.P2CamShake[1]);
				}
			}
			else
			{
				call('P2NoteHit', [note]);
				if (player2.canSing)
				{
					if (curPlayer.activeCharacters.contains(player2.curCharacter))
						player2.playAnim('sing' + sDir[mania][note.noteData] + altAnim, true, false, 0, note.noteData);
					//player2.holdTimer = 0;
				}
				for (character in extraCharacters)
				{
					if (character.canSing && !character.player1Side)
					{
						if (curPlayer.activeCharacters.contains(character.curCharacter))
							character.playAnim('sing' + sDir[mania][note.noteData] + altAnim, true, false, 0, note.noteData);
						//character.holdTimer = 0;
					}
				}
				player2.noteCamMovement = noteCamMovementShit(note.noteData, 0);
				if (ModchartUtil.P2CamShake[0] != 0)
					FlxG.camera.shake(ModchartUtil.P2CamShake[0], ModchartUtil.P2CamShake[1]);
			}

			var timeWasHit:Float = Conductor.songPosition;
			if (!note.isSustainNote)
				statsToUse.npsArray.push(timeWasHit);

			note.noteTypeHit();

			CalculateAccuracy(playernum);

			statsToUse.health += note.healthChangesOnHit;


			curPlayer.strums.forEach(function(spr:BabyArrow)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.playAnim('confirm', true, spr.ID, note.colorShit);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;
			var strums = "player";
			if (flipped)
				strums = "cpu";

			if (!note.isSustainNote)
			{
				if (note.rating == "sick" && SaveData.noteSplash)
					doNoteSplash(note.x, note.y, note.noteData, note.strumID, note.cameras, note.colorShit);
				removeNote(note);
			}

			grace = true;
			new FlxTimer().start(graceTimerCooldown / SongSpeedMultiplier, function(tmr:FlxTimer)
			{
				grace = false;
			});
		}
	}
	function doNoteSplash(noteX:Float, noteY:Float, nData:Int, playernum:Int = 1, cameraShit:Array<FlxCamera>, colorShit:Array<Float>)
		{
			if (playernum != 0 && playernum != 1)
				return;
			var playe = getPlayerFromID(playernum);

			var recycledNote = playe.strums.noteSplashes.recycle(NoteSplash);
			var xPos:Float = 0;
			var yPos:Float = 0;
			xPos = playe.strums.members[nData].x;
			yPos = playe.strums.members[nData].y;
			recycledNote.makeSplash(xPos, yPos, nData, playernum, cameraShit, colorShit);
			playe.strums.noteSplashes.add(recycledNote);

			
		}

	public function HealthDrain(playernum:Int = 1):Void //code from vs bob
	{
		badNoteHit();
		var statsToUse = getStats(playernum);

		new FlxTimer().start(0.01, function(tmr:FlxTimer)
		{
			statsToUse.health -= HealthDrainFromGlitchAndBob;
		}, 300);
	}

	public function badNoteHit():Void
	{
		player.playAnim('hit', true);
		FlxG.sound.play(Paths.soundRandom('badnoise', 1, 3), FlxG.random.float(0.7, 1));
	}

	public function removeNote(daNote:Note):Void
	{
		daNote.kill();
		var playershit = getPlayerFromID(daNote.strumID);
		playershit.strums.notes.remove(daNote, true);
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

		var fcShit:Array<Bool> = [
			statsToUse.misses == 0 && Math.floor(statsToUse.accuracy) == 69,
			statsToUse.misses == 0 && statsToUse.accuracy < 69,
			statsToUse.misses == 0 && statsToUse.goods == 0 && statsToUse.bads == 0 && statsToUse.shits == 0,
			statsToUse.misses == 0 && statsToUse.bads == 0 && statsToUse.shits == 0,
			statsToUse.misses == 0 && statsToUse.shits == 0,
			statsToUse.misses == 0,
			statsToUse.misses <= 10,
			statsToUse.misses > 10,
			statsToUse.misses > 1000,
			
		];



		
		for (i in 0...accuracyToRank.length)
		{
			if (accuracyToRank[i])
			{
				statsToUse.curRank = ranksList[i];
				var fcText = "";
				for (i in 0...fcShit.length)
				{
					if (fcShit[i])
					{
						fcText = fcList[i];
						break;
					}
				}
				statsToUse.curRank += " " + fcText;

				break;
			}
		}
	}
	
	function CalculateAccuracy(playernum:Int = 1):Void
	{
		var statsToUse = getStats(playernum);

		var notesAddedUp = statsToUse.sustainsHit + statsToUse.sicks + (statsToUse.goods * 0.75) + (statsToUse.bads * 0.3) + (statsToUse.shits * 0.1);
		statsToUse.accuracy = FlxMath.roundDecimal((notesAddedUp / statsToUse.totalNotesHit) * 100, 2);

		updateRank(playernum);
	}

	function getStats(playernum:Int = 1)
	{
		var stats = p1.Stats;

		if (playernum != 1 && multiplayer)
			stats = p2.Stats;

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
		var text = "";
		text = "";
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
					if ((i == 6 || i == 11) && SaveData.hudPos == "Default")
						text += "\n";

					if (SaveData.hudPos != "Default")
						text += "\n";
					else
						text += "|";

					text += listOShit[i];

					if (SaveData.hudPos == "Default")
						text += "|";

				}
			}
		}
		if (playernum == 1)
			scoreTxt.text = text;
		else
			P2scoreTxt.text = text;
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

	var justChangedMania:Bool = false;

	public function switchMania(newMania:Int, strumnum = 1):Void
	{
		if (mania == 2) //so it doesnt break the fucking game
		{
			var strums:StrumLineGroup = p1.strums;
		
			var scaleToCheck:Float = 1;
			var bindsToUse:Array<String> = [];
			var downscroll = SaveData.downscroll;
			var showKeyBindText = true;
			if (strumnum == 1)
			{
				p1Mania = newMania;
				Note.p1NoteScale = Note.noteScales[newMania];
				scaleToCheck = Note.p1NoteScale;
				strums = p1.strums;
				if (!flipped && !multiplayer)
					bindsToUse = CoolUtil.bindCheck(mania, false, SaveData.binds, p1Mania);
				else 
					showKeyBindText = false;

				p1.strums.curMania = newMania;
			}
			else
			{
				p2Mania = newMania;
				Note.p2NoteScale = Note.noteScales[newMania];
				scaleToCheck = Note.p2NoteScale;
				strums = p2.strums;
				if (multiplayer)
					bindsToUse = CoolUtil.bindCheck(mania, false, SaveData.P2binds, p2Mania);
				else if (flipped)
					bindsToUse = CoolUtil.bindCheck(mania, false, SaveData.binds, p1Mania);
				else 
					showKeyBindText = false;
				downscroll = SaveData.P2downscroll;
				p2.strums.curMania = newMania;
			}
	
			strums.forEach(function(spr:BabyArrow)
			{
				spr.playAnim('static', true, spr.ID, [0,0,0,0]); //changes to static because it can break the scaling of the static arrows if they are doing the confirm animation
				if (spr.stylelol == "pixel")
					spr.setGraphicSize(Std.int(spr.defaultWidth * PlayState.daPixelZoom * Note.pixelnoteScale * spr.scaleMulti));
				else 
					spr.setGraphicSize(Std.int(spr.defaultWidth * scaleToCheck * spr.scaleMulti));

				//spr.centerOffsets();

				spr.moveKeyPositions(spr, newMania, strumnum);
			});	

			if (showKeyBindText)
				createManiaSwitchKeybindText(strums, bindsToUse, downscroll);

			if (strumnum == 1 && !flipped || strumnum == 0 && flipped)
				keys = [false, false, false, false, false, false, false, false, false];
			else if (multiplayer)
				P2keys = [false, false, false, false, false, false, false, false, false];


			/*regeneratingNotes = true;
			generateNotes();*/

			call("onManiaChange", [mania]);
		}
	}


	public function moveCamera(pos:Array<Float>):Void
	{
		camFollow.setPosition(pos[0], pos[1]);
	}
	function getCameraPos(playernum:Int = 0)
	{
		var pos:Array<Float> = [0, 0];
		if (playernum == 0)
		{
			var characterToSnapTo = dad;
			for (character in extraCharacters)
			{
				if (character.canSing && !character.player1Side)
				{
					characterToSnapTo = character;
					break;
				}
			}


			var camOffset = characterToSnapTo.posOffsets.get('cam'); //offset in character.hx
			if (characterToSnapTo.posOffsets.exists('cam'))
			{
				pos = [characterToSnapTo.getMidpoint().x + camOffset[0] + dad.noteCamMovement[0], 
				characterToSnapTo.getMidpoint().y + camOffset[1] + dad.noteCamMovement[1]];
			}
			else
				pos = [characterToSnapTo.getMidpoint().x + dadDefaultCamOffset[0] + dad.noteCamMovement[0], characterToSnapTo.getMidpoint().y - dadDefaultCamOffset[1] + dad.noteCamMovement[1]];

			if (dad.curCharacter == 'mom')
				vocals.volume = 1;

			if (SONG.song.toLowerCase() == 'tutorial')
				tweenCamIn();
		}
		else
		{
			var characterToSnapTo = boyfriend;
			for (character in extraCharacters)
			{
				if (character.canSing && character.player1Side)
				{
					characterToSnapTo = character;
					break;
				}
			}

			var yoffset:Float = bfDefaultCamOffset[1];
			var xoffset:Float = bfDefaultCamOffset[0];
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
			var camOffset = characterToSnapTo.posOffsets.get('cam'); //offset in character.hx
			if (characterToSnapTo.posOffsets.exists('cam'))
			{
				xoffset += camOffset[0];
				yoffset += camOffset[1];
			}

			pos = [characterToSnapTo.getMidpoint().x + xoffset + boyfriend.noteCamMovement[0], 
			characterToSnapTo.getMidpoint().y + yoffset + boyfriend.noteCamMovement[1]];

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
		//camP1Notes.zoom = SaveData.noteZoom;
		//camP2Notes.zoom = SaveData.noteZoom;
		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);

			//camP1Notes.zoom = camHUD.zoom;
			//camP2Notes.zoom = camHUD.zoom;
			camOnTop.zoom = camHUD.zoom;
		}
		p1.snapCams(camHUD);
		p2.snapCams(camHUD);
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


	function createKeybindText(strums:StrumLineGroup, binds:Array<String>, downscroll:Bool):Void
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

			text.y -= 10;
			text.alpha = 0;
			FlxTween.tween(text, {y: text.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * ((i * 4) / PlayState.keyAmmo[mania]))});
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
	function createManiaSwitchKeybindText(strums:StrumLineGroup, binds:Array<String>, downscroll:Bool):Void
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
			var id = strums.members[i].curID;

			text.cameras = [camHUD];
			text.y -= 10;
			text.alpha = 0;
			FlxTween.tween(text, {y: text.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.05 + (0.1 * ((id * 4) / PlayState.keyAmmo[mania]))});
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
				if (daNote.canBeHit && daNote.strumID == 1 && !daNote.tooLate && !daNote.wasGoodHit)
					collectedNotes.push(daNote);
			});
			for (i in 0...amountOfExtraPlayers)
			{
				var playe = getPlayerFromID(i + 3);
				playe.strums.notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
						collectedNotes.push(daNote);
				});
			}
		}
		else
		{
			shit.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.strumID == 0 && !daNote.tooLate && !daNote.wasGoodHit)
					collectedNotes.push(daNote);
			});
			for (i in 0...amountOfExtraPlayers)
			{
				var playe = getPlayerFromID(i + 3);
				playe.strums.notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && !daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
						collectedNotes.push(daNote);
				});
			}
		}

		return collectedNotes;
	}
	function resetBabyArrowAnim(strums:StrumLineGroup):Void
	{
		strums.forEach(function(spr:BabyArrow)
		{
			if (spr.animation.finished)
			{
				spr.playAnim('static',false , spr.ID, [0,0,0,0]);
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
				if (daNote.isSustainNote && daNote.canBeHit && daNote.strumID == 1 && daKeys[daNote.noteData])
					goodNoteHit(daNote, playernum);
			});
		}
		else
		{
			shit.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && daNote.strumID == 0 && daKeys[daNote.noteData])
					goodNoteHit(daNote, playernum);
			});
		}
	}
	function strumPressCheck(strums:StrumLineGroup, daKeys:Array<Bool>):Void
	{
		strums.forEach(function(spr:BabyArrow)
			{
				if (daKeys[spr.ID] && spr.animation.curAnim.name != 'confirm' && spr.animation.curAnim.name != 'pressed')
					spr.playAnim('pressed', false, spr.ID, spr.colorShiz);
				if (!daKeys[spr.ID])
					spr.playAnim('static', false, spr.ID, [0,0,0,0]);
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
		var timetospawn = unspawnNotes[0].strumTime - Conductor.songPosition < 3500;

		if (timetospawn)
		{
			var dunceNote:Note = unspawnNotes[0];

			if (dunceNote.strumTime - Conductor.songPosition <= 0)
				unspawnNotes.remove(dunceNote); //remove notes that would have already passed if regening notes
			else 
			{
				if (dunceNote.isGFNote)
				{
					call('P3NoteSpawned', [dunceNote]);
					p3.strums.notes.add(dunceNote);
				}	
				else if (dunceNote.strumID == 1)
				{
					call('P1NoteSpawned', [dunceNote]);
					p1.strums.notes.add(dunceNote);
				}
				else if (dunceNote.strumID == 0)
				{
					call('P2NoteSpawned', [dunceNote]);
					p2.strums.notes.add(dunceNote);
				}
				else 
				{
					//do shit with extras strums here
					var curPlayer = getPlayerFromID(dunceNote.strumID);
					dunceNote.cameras = [camGame]; //fix camera shit
					if (dunceNote.beenFlipped)
					{
						dunceNote.scale.y *= -1; //stop downscroll flip on these so up and down isnt switched
						dunceNote.beenFlipped = false;	
					}
					curPlayer.strums.notes.add(dunceNote);
				}
					
			}

			
			var index:Int = unspawnNotes.indexOf(dunceNote);
			unspawnNotes.splice(index, 1);
		}

		if (unspawnNotes[0] != null)
		{
			var timetospawnshit = unspawnNotes[0].strumTime - Conductor.songPosition < 2000;

			if (timetospawnshit) //force loop if close
				spawnNote(); //loop it lol
		}

	}

	



	public function lerpSongSpeed(num:Float, time:Float):Void
	{
		FlxTween.num(SongSpeedMultiplier, num, time, {onUpdate: function(tween:FlxTween){
			var ting = FlxMath.lerp(SongSpeedMultiplier,num, tween.percent);
			if (ting != 0) //divide by 0 is a verry bad
				SongSpeedMultiplier = ting; //why cant i just tween a variable

			FlxG.sound.music.time = Conductor.songPosition;
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
					Conductor.recalculateTimings();
					resyncInst();
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
		ModchartUtil.P1CamShake = [0,0];
		ModchartUtil.P2CamShake = [0,0];

		p1.resetModifiers();
		p2.resetModifiers();
		p3.resetModifiers();


		if (mania == 2)
		{
			switchMania(2, 0);
			switchMania(2, 1);
		}
		p1.resetStats();
		p2.resetStats();
	}

	public function updateCharacters():Void
	{	
		if (extraCharacters.length != 0)
		{
			for (character in extraCharacters)
			{
				if (p1.activeCharacters.contains(character.curCharacter))
				{
					character.canSing = true;
					character.player1Side = true;
					character.isPlayer = true;
				}
				else if (p2.activeCharacters.contains(character.curCharacter))
				{
					character.canSing = true;
					character.player1Side = false;
					character.isPlayer = false;
				}	
				else if (p3.activeCharacters.contains(character.curCharacter))
				{
					character.canSing = true;
					character.player1Side = false;
					character.isPlayer = false;
				}	
				else
					character.canSing = false;

				if (amountOfExtraPlayers > 0)
				{
					for (i in 0...amountOfExtraPlayers)
					{
						var playe = getPlayerFromID(i + 3);
						if (playe.activeCharacters.contains(character.curCharacter))
						{
							character.canSing = true;
							if (playe.mustHitNotes)
							{
								character.player1Side = true;
								character.isPlayer = true;	
							}
							else
							{
								character.player1Side = false;
								character.isPlayer = false;
							}
						}
					}
				}
			}
		}
		if (!p1.activeCharacters.contains(boyfriend.curCharacter)) //bf and dad are not a part of the group
			boyfriend.canSing = false;
		else 
			boyfriend.canSing = true;

		if (!p2.activeCharacters.contains(dad.curCharacter))
			dad.canSing = false;
		else 
			dad.canSing = true;
	}
	
	
	public function setCharacterNoteDatas(char:String, enable:Bool = true, datas:Array<Int>):Void //makes it so a character can only sing certain directions, good for multiple characters
	{
		for (character in extraCharacters)
		{
			if (char == character.curCharacter)
			{
				character.singAllNoteDatas = enable;
				character.noteDatasToSingOn = datas;
				return;
			}
		}
		if (char == dad.curCharacter)
		{
			dad.singAllNoteDatas = enable;
			dad.noteDatasToSingOn = datas;
			return;
		}
		else if (char == boyfriend.curCharacter)
		{
			boyfriend.singAllNoteDatas = enable;
			boyfriend.noteDatasToSingOn = datas;
			return;
		}
	}
	public function resetCharacterNoteDatas():Void 
	{
		for (character in extraCharacters)
		{
			character.singAllNoteDatas = true;
		}
		boyfriend.singAllNoteDatas = true;
		dad.singAllNoteDatas = true;
	}

	function generateNotes():Void
	{
		unspawnNotes = [];
		for (p in playerList)
			p.strums.notes.clear();
		

		var songData = SONG;
		var noteData:Array<SwagSection>;
		noteData = songData.notes;

		var hellChartDataConvert = [0,2,4,6,1,3,5,7];
		var noteIDs = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var mn:Int = keyAmmo[mania];
			var coolSection:Int = Std.int(section.lengthInSteps / 4);
			section.sectionNotes.sort(function(a, b){
				if (a[0] < b[0]) //sort based on strumtime
					return -1;
				else if (a[0] > b[0])
					return 1;
				else
					return 0;
			});

			for (songNotes in section.sectionNotes)
			{
				if (songNotes[1] >= 0)
				{
					var daStrumTime:Float = songNotes[0];
					daStrumTime += SaveData.offset;
					if (daStrumTime < 0)
						daStrumTime = 0;
	
					var daNoteData:Int = Std.int(songNotes[1] % mn);


					var daType:Dynamic = songNotes[3];

					var possibleNoteTypes = ["hurt", "bullet", "warning", "death", "halo", "alt"]; //compat with psych custom note types, kinda just guessing half the names lol

					if (daType is String)
					{
						for (i in 0...possibleNoteTypes.length)
						{
							if (daType.toLowerCase().contains(possibleNoteTypes[i]))
							{
								switch(i) //it was just a random suggestion from someone
								{
									case 0: 
										daType = 1;
									case 3 | 4:
										daType = 2;
									case 1 | 2: 
										daType = 3;
									case 5: 
										daType = 5;
								}
							}
						}

					}
	
					var gottaHitNote:Bool = section.mustHitSection;

					if (songNotes[1] >= mn)
						gottaHitNote = !section.mustHitSection;


					var strumID:Int = 0;
					if (gottaHitNote)
						strumID = 1;

					if (songNotes[7] is Int) //up to 7 now damn
						if (songNotes[7] > 2 && songNotes[7] <= amountOfExtraPlayers + 3)
							strumID = Math.floor(Math.abs(songNotes[7])); //make sure its 100% an int
							
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

					if (SaveData.Hellchart)
					{
						if (!gottaHitNote)
							daNoteData += 4;

						daNoteData = daNoteData % 8;
						daNoteData = hellChartDataConvert[daNoteData]; //make them a little more enjoyable to play (it spreads the notes out)
						daNoteData = daNoteData % 8; //backup so no crashy
						gottaHitNote = true;
					}
						
	
					var oldNote:Note;
					if (unspawnNotes.length > 0)
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					else
						oldNote = null;

					var makeNote:Bool = true;

					if (!allowNoteTypes)
					{
						if (daType != 0 && daType != 5) //5 is alt anim, they are fine
						{
							switch (daType)
							{
								case 3 | 4 | 5 | 7 | 9: //make them regular notes
									daType = 0;
								default: 
									makeNote = false;
							}
						}
					}
					var daSpeed = songNotes[4];
	
					var daVelocityData = songNotes[5];
	
					
					daType = CoolUtil.songCompatCheck(daType); //checks songs from mods that also use the notetype variable name, which is not many lol
	
					if (makeNote)
					{
						var swagNote:Note = new Note(daStrumTime, daNoteData, daType, false, daSpeed, daVelocityData, false, false, gottaHitNote, null, oldNote);
						swagNote.sustainLength = songNotes[2];
						swagNote.scrollFactor.set(0, 0);
						swagNote.startPos = calculateStrumtime(swagNote, daStrumTime);
						swagNote.strumID = strumID;
		
						var susLength:Float = swagNote.sustainLength;
		
						susLength = susLength / Conductor.stepCrochet;
						unspawnNotes.push(swagNote);
	
						if (susLength != 0)
							susLength++; //increase length of all sustains, so they dont look off in game

						swagNote.ID = noteIDs;
						noteIDs++;
						//susLength *= 2;
		
						for (susNote in 0...Math.floor(susLength))
						{
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
							var speedToUse = SongSpeed;
							if (daSpeed != null || daSpeed > 1)
								speedToUse = daSpeed;
	
							var crocs = Conductor.stepCrochet; //crocs lol
		
							
							var susStrum = daStrumTime + (crocs * susNote) + (crocs / speedToUse / SongSpeedMultiplier);
							if (rewinding)
								susStrum = daStrumTime + (crocs * susNote) + (crocs / speedToUse);
	
							var sustainNote:Note = new Note(susStrum, daNoteData, daType, true, daSpeed, daVelocityData, false, false, gottaHitNote, oldNote, swagNote);
							sustainNote.scrollFactor.set();
							unspawnNotes.push(sustainNote);
							sustainNote.startPos = calculateStrumtime(sustainNote, susStrum);
							sustainNote.ID = noteIDs;
							sustainNote.strumID = strumID;
							noteIDs++;
						}
						
					}
					
				}
				else if (songNotes[1] >= -4 && songNotes[1] < 0) //for gf notes (also in case notedata is less than -3)
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

					var daSpeed = songNotes[4];

					var eventData:Array<String> = songNotes[6];
					//trace(eventData);
					var daType = songNotes[3];

					var swagNote:Note = new Note(daStrumTime, daNoteData, daType, false, daSpeed, daVelocityData, false, true, false, eventData, oldNote);
					swagNote.startPos = calculateStrumtime(swagNote, daStrumTime);
					swagNote.sustainLength = songNotes[2];
					var susLength:Float = swagNote.sustainLength;
					susLength = susLength / Conductor.stepCrochet;
					unspawnNotes.push(swagNote);
					swagNote.strumID = 2;
					swagNote.scrollFactor.set(gf.scrollFactor.x, gf.scrollFactor.y);
					
					//i guess i gotta add sustains now that gf notes can be visible

					if (susLength != 0)
						susLength++; //increase length of all sustains, so they dont look off in game

					for (susNote in 0...Math.floor(susLength))
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
						var speedToUse = SongSpeed;
						if (daSpeed != null || daSpeed > 1)
							speedToUse = daSpeed;

						var crocs = Conductor.stepCrochet; //crocs lol
	
						
						var susStrum = daStrumTime + (crocs * susNote) + (crocs / speedToUse / SongSpeedMultiplier);
						if (rewinding)
							susStrum = daStrumTime + (crocs * susNote) + (crocs / speedToUse);

						var sustainNote:Note = new Note(susStrum, daNoteData, daType, true, daSpeed, daVelocityData, false, true, false, oldNote);
						sustainNote.scrollFactor.set(gf.scrollFactor.x, gf.scrollFactor.y);
						unspawnNotes.push(sustainNote);
						sustainNote.startPos = calculateStrumtime(sustainNote, susStrum);
						sustainNote.strumID = 2;
					}
					if (eventData != null)
					{
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
				
			}
			daBeats += 1;
		}

		unspawnNotes.sort(sortByShit);

		p3.modifiers.strumScrollFactor = [gf.scrollFactor.x, gf.scrollFactor.y];
	}
		
	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}


	public static function getPlayerFromID(id:Int)
	{
		if (playerList[id] != null)
			return playerList[id];
		else
			return playerList[0]; //default to p2 (dad)
	}


	

	override function stepHit()
	{
		super.stepHit();
		call("stepHit", [curStep]);

		updateCharacters();

		var needToResync:Bool = (((FlxG.sound.music.time - vocals.time) >= 10) && vocals.playing);
		if (!allowSpeedChanges || SongSpeedMultiplier == 1)
			needToResync = false; //reduce lag from syncing

		if (vocals.active && vocals.playing)
		{
			if (FlxG.sound.music.time > vocals.time + (20 * PlayState.SongSpeedMultiplier) || vocals.time < Conductor.songPosition - (20 * PlayState.SongSpeedMultiplier)
				|| needToResync)
			{
				resyncVocals();
			}
		}

		if (songStarted && !endingSong && !rewinding)
			if (FlxG.sound.music.time > Conductor.songPosition + (20 * PlayState.SongSpeedMultiplier) || FlxG.sound.music.time < Conductor.songPosition - (20 * PlayState.SongSpeedMultiplier))
				resyncVocals();
		
		if (scriptEvents.length > 0)
			for (i in 0...scriptEvents.length)
				if (scriptEvents[i] is StepScriptEvent)
					scriptEvents[i].check(curStep);

			
	}

	override function beatHit()
	{
		super.beatHit();
		call("beatHit", [curBeat]);
		if (generatedMusic)
		{
			p1.strums.notes.sort(FlxSort.byY, FlxSort.DESCENDING);
			p2.strums.notes.sort(FlxSort.byY, FlxSort.DESCENDING);
			p3.strums.notes.sort(FlxSort.byY, FlxSort.DESCENDING);
			for (i in 0...amountOfExtraPlayers)
			{
				var curPlayer = getPlayerFromID(i + 3);
				curPlayer.strums.notes.sort(FlxSort.byY, FlxSort.DESCENDING);
			}
		}
		//trace(p1.strums.notes.length);

		StagePiece.daBeat = curBeat;
		for (piece in StagePiecesBEHIND.members)
			if (piece is StagePiece)
				piece.dance();	
		for (piece in StagePiecesGF.members)
			if (piece is StagePiece)
				piece.dance();
		for (piece in StagePiecesDAD.members)
			if (piece is StagePiece)
				piece.dance();
		for (piece in StagePiecesBF.members)
			if (piece is StagePiece)
				piece.dance();
		for (piece in StagePiecesFRONT.members)
			if (piece is StagePiece)
				piece.dance();

		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, hudThing, OUTLINE, FlxColor.BLACK); //resets colors
		if (multiplayer)
			P2scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);

		if (scriptEvents.length > 0)
			for (i in 0...scriptEvents.length)
				if (scriptEvents[i] is BeatScriptEvent)
					scriptEvents[i].check(curBeat);

		if (currentSection != null)
		{
			if (currentSection.changeBPM)
			{
				Conductor.changeBPM(currentSection.bpm);
				FlxG.log.add('CHANGED BPM!');
			}

			if (characters)
			{
				// Dad doesnt interupt his own notes
				if (currentSection.mustHitSection && !multiplayer)
				{
					cpu.dance();
					for (character in extraCharacters)
					{
						if (character.canSing && !character.isPlayer)
							character.dance();
					}
				}
					

				for (character in extraCharacters)
				{
					if (!character.canSing)
						character.dance();
				}
				if (!dad.canSing)
					dad.dance();
				if (!boyfriend.canSing)
					boyfriend.dance();
			}

		}
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


		if (curBeat % 8 == 0 && !rewinding && randomModchartEffects)
		{
			var randomnum = FlxG.random.int(0, ModchartUtil.modifierList.length - 1, [0,1]);
			var modifToChange = ModchartUtil.modifierList[randomnum];
			var modifValue:Dynamic = FlxG.random.float(0, 4);
			var playernum = FlxG.random.int(0,1);
			switch(modifToChange)
			{
				case "scrollAngle":
					modifValue = FlxG.random.int(0, 360);
				case "incomingAngleIsStrumAngle" | "StrumLinefollowAngle" | "boundStrums":
					modifValue = FlxG.random.bool(50);
				case "sinWaveX" | "sinWaveY" | "cosWaveX" | "cosWaveY" | "sinMoveX" | "sinMoveY" | "cosMoveX" | "cosMoveY": 
					modifValue = [FlxG.random.float(0, 100), FlxG.random.float(0.5, 2)];
				case "strumScrollFactor": 
					modifValue = [FlxG.random.float(0, 1), FlxG.random.float(0, 1)];
				case "strumAlpha" | "noteAlpha":
					modifValue = FlxG.random.float(0.3, 1);
				case "ghostNotes" | "inverseGhostNotes":
					modifValue = FlxG.random.float(5, 15);
				case "bop": 
					modifValue = FlxG.random.float(0, 4);
					var modifValues = ModchartUtil.getModifValues(playernum);
					modifValues.bopTo0 = [FlxG.random.float(-20, 20), FlxG.random.float(-20, 20), FlxG.random.float(-20, 20)];
					modifValues.bopTo1 = [FlxG.random.float(-20, 20), FlxG.random.float(-20, 20), FlxG.random.float(-20, 20)];
					modifValues.bopTo2 = [FlxG.random.float(-20, 20), FlxG.random.float(-20, 20), FlxG.random.float(-20, 20)];
					modifValues.bopTo3 = [FlxG.random.float(-20, 20), FlxG.random.float(-20, 20), FlxG.random.float(-20, 20)];
					modifValues.bopTo4 = [FlxG.random.float(-20, 20), FlxG.random.float(-20, 20), FlxG.random.float(-20, 20)];
					modifValues.bopTo5 = [FlxG.random.float(-20, 20), FlxG.random.float(-20, 20), FlxG.random.float(-20, 20)];
					modifValues.bopTo6 = [FlxG.random.float(-20, 20), FlxG.random.float(-20, 20), FlxG.random.float(-20, 20)];
					modifValues.bopTo7 = [FlxG.random.float(-20, 20), FlxG.random.float(-20, 20), FlxG.random.float(-20, 20)];
					modifValues.bopTo8 = [FlxG.random.float(-20, 20), FlxG.random.float(-20, 20), FlxG.random.float(-20, 20)];
			}
			
			
			if (modifValue is Float)
			{
				FlxTween.num(ModchartUtil.getModifierValue(modifToChange, playernum), modifValue, Conductor.crochet / 1000, {onUpdate: function(tween:FlxTween){
					var ting = FlxMath.lerp(ModchartUtil.getModifierValue(modifToChange, playernum),modifValue, tween.percent);
					ModchartUtil.changeModifier(modifToChange, ting, playernum);
				}, ease: FlxEase.cubeInOut, onComplete: function(tween:FlxTween) {
					ModchartUtil.changeModifier(modifToChange, modifValue, playernum);
				}});
			}
			else 
				ModchartUtil.changeModifier(modifToChange, modifValue, playernum);

		}
		if (curBeat % 32 == 0 && !rewinding && randomModchartEffects)
		{
			p1.resetModifiers();
			p2.resetModifiers();
			p3.resetModifiers();
		}


		if (p1.modifiers.bop != 0)
			bopNotes(1);
		if (p2.modifiers.bop != 0)
			bopNotes(0);
		if (p3.modifiers.bop != 0)
			bopNotes(2);
		

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();



		if (characters)
		{

			if (curBeat % gfSpeed == 0)
				gf.dance();

			if (!player.animation.curAnim.name.startsWith("sing"))
				player.dance();
	
			if (multiplayer)
				if (!player2.animation.curAnim.name.startsWith("sing"))
					player2.dance();
	
			for (character in extraCharacters)
			{
				if ((!character.animation.curAnim.name.startsWith("sing") && character.player1Side) || 
					((!character.animation.curAnim.name.startsWith("sing") && !character.player1Side && multiplayer)))
					character.dance();
			}

			if (curBeat % 8 == 7 && curSong == 'Bopeebo')
				boyfriend.playAnim('hey', true);
	
			if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
			{
				boyfriend.playAnim('hey', true);
				dad.playAnim('cheer', true);
			}
		}




		switch (curStage)
		{		
			case "philly":
				if (curBeat % 4 == 0)
					StagePiece.curLight = FlxG.random.int(0, 4);
		}
	}

	public function changeCharacter(character:Boyfriend, changeTo:String)
	{
		if (p1.activeCharacters.contains(character.curCharacter))
			p1.activeCharacters.push(changeTo); //so character can sing when changing, dont have to do it manually
		if (p2.activeCharacters.contains(character.curCharacter))
			p2.activeCharacters.push(changeTo);
		if (p3.activeCharacters.contains(character.curCharacter))
			p3.activeCharacters.push(changeTo);

		if (amountOfExtraPlayers > 0)
		{
			for (i in 0...amountOfExtraPlayers)
			{
				var playe = getPlayerFromID(i + 3);
				if (playe.activeCharacters.contains(character.curCharacter))
					playe.activeCharacters.push(changeTo);
			}
		}

		

		character.loadCharacter(changeTo);
		
	}

	public function bopNotes(playernum:Int)
	{
        var modif = ModchartUtil.getModif(playernum);
        var modifValues = ModchartUtil.getModifValues(playernum);

		for (i in 0...keyAmmo[mania])
		{
			var bopOffset = Reflect.getProperty(modifValues, "bopOffset" + i);
			var bopTo = Reflect.getProperty(modifValues, "bopTo" + i);
			bopOffset = [bopTo[0], bopTo[1], bopTo[2]];
			Reflect.setProperty(modifValues, "bopOffset" + i, bopOffset);

			FlxTween.num(bopOffset[0], 0, Conductor.crochet / 1000, {onUpdate: function(tween:FlxTween){ ///FUCK YOU
				var ting = FlxMath.lerp(bopOffset[0],0, tween.percent);
				var bopshit = Reflect.getProperty(modifValues, "bopOffset" + i);
				bopshit[0] = ting;
				Reflect.setProperty(modifValues, "bopOffset" + i, bopshit);
			}, ease: FlxEase.cubeInOut, onComplete: function(tween:FlxTween) {
				Reflect.setProperty(modifValues, "bopOffset" + i, [0,0,0]);
			}});

			FlxTween.num(bopOffset[1], 0, Conductor.crochet / 1000, {onUpdate: function(tween:FlxTween){
				var ting = FlxMath.lerp(bopOffset[1],0, tween.percent);
				var bopshit = Reflect.getProperty(modifValues, "bopOffset" + i);
				bopshit[1] = ting;
				Reflect.setProperty(modifValues, "bopOffset" + i, bopshit);
			}, ease: FlxEase.cubeInOut, onComplete: function(tween:FlxTween) {
				Reflect.setProperty(modifValues, "bopOffset" + i, [0,0,0]);
			}});

			FlxTween.num(bopOffset[2], 0, Conductor.crochet / 1000, {onUpdate: function(tween:FlxTween){
				var ting = FlxMath.lerp(bopOffset[2],0, tween.percent);
				var bopshit = Reflect.getProperty(modifValues, "bopOffset" + i);
				bopshit[2] = ting;
				Reflect.setProperty(modifValues, "bopOffset" + i, bopshit);
			}, ease: FlxEase.cubeInOut, onComplete: function(tween:FlxTween) {
				Reflect.setProperty(modifValues, "bopOffset" + i, [0,0,0]);
			}});

		}
	}

	public function tweenModifier(modifToChange:String, modifValue:Dynamic, playernum:Int, ease:String = "cubeInOut", ?time:Float)
	{
        if (time == null)
            time = Conductor.crochet / 1000;
        
        var easeToUse = ModchartUtil.getEase(ease);
    
        FlxTween.num(ModchartUtil.getModifierValue(modifToChange, playernum), modifValue, time, {onUpdate: function(tween:FlxTween){
            var ting = FlxMath.lerp(ModchartUtil.getModifierValue(modifToChange, playernum),modifValue, tween.percent);
            ModchartUtil.changeModifier(modifToChange, ting, playernum);
        }, ease: easeToUse, onComplete: function(tween:FlxTween) {
            ModchartUtil.changeModifier(modifToChange, modifValue, playernum);
        }});
	}

	private function playMissSound(n:Int)
	{
		trace("playing miss sound: " + n);
		trace(missSounds.length);
		missSounds[n].play();
		missSounds[n].volume = FlxG.random.float(0.1, 0.2);
	}



	

	
}
