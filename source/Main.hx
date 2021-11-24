package;

import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.display.BlendMode;
import openfl.text.TextFormat;
import openfl.display.Application;
import flixel.util.FlxColor;
import flixel.FlxG;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import haxe.Json;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

typedef GameData = //time for mass unhardcoding
{
	var notesData:NotesData;
	var PlayStateData:PlayStateData;
	var FreeplayData:FreeplayData;
	var PauseMenuData:PauseMenuData;
	var StoryMenuShit:StoryMenuShit;
	var MainMenuData:MainMenuData;
	var ChartingStateData:ChartingStateData;
}

typedef NotesData = 
{
	var keyAmmo:Array<Int>; //wait fuck you can add more manias without coding
	var frameN:Array<Array<String>>; //oh wait you cant add more keybinds :troll:
	var GFframeN:Array<String>;
	var noteTypeList:Array<String>; //list of note types
	var noteAssetList:Array<String>; //path to assets
	var assetList:Array<String>; //display names in customization menu
	var noteTypeAssetPaths:Array<String>; //path to note type assets
	var noteTypePrefixes:Array<String>;
	var noteColors:Array<String>;
	var pixelAssetPaths:Array<Array<String>>;

	var poisonDrain:Float;
	var drainNoteAmount:Float;
	var fireNoteDamage:Float;
	var deathNoteDamage:Float;
	var warningNoteDamage:Float;
	var angelNoteDamage:Array<Float>;
	var poisonNoteDamage:Float;
	var HealthDrainFromGlitchAndBob:Float;

	var maniaSwitchPositions:Array<Dynamic>;
	var dirArray:Array<Array<String>>;
	var colorFromData:Array<Array<Int>>;
	var laneOffset:Array<Float>;

	var MaxNoteData:Int;
	var noteScales:Array<Float>;
	var pixelNoteScales:Array<Float>;
	var noteWidths:Array<Float>;
}

typedef PlayStateData = 
{
	var sDir:Array<Array<String>>;
	var GFsDir:Array<String>;
	var bfDefaultPos:Array<Int>;
	var dadDefaultPos:Array<Int>;
	var gfDefaultPos:Array<Int>;
	var bfDefaultCamOffset:Array<Int>;
	var dadDefaultCamOffset:Array<Int>;
	var defaultCamZoom:Float;
	var daPixelZoom:Float;
	var strumLineStartY:Float;
	var healthToDieOn:Float;

	var shitTiming:Float;
	var badTiming:Float;
	var goodTiming:Float;
	var healthFromAnyHit:Float;
	var healthFromRating:Array<Float>;
	var healthLossFromMiss:Float;
	var healthLossFromSustainMiss:Float;
	var healthLossFromMissPress:Float;
	var graceTimerCooldown:Float;
}

typedef FreeplayData =  //will add more to these eventually, like offseting each sprite and shit and changing if text is centered etc
{
	var useAutoDiffSystem:Bool;
}

typedef PauseMenuData =
{
	var menuItems:Array<String>;
} 

typedef StoryMenuShit = 
{
	var weekUnlocked:Array<Bool>;
}

typedef MainMenuData = 
{
	var optionList:Array<String>;
}

typedef ChartingStateData =
{
	var GRID_SIZE:Int;
	var S_GRID_SIZE:Int;
	var GF_GRID:Int;
	var noteTypes:Array<String>;
}

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
	public static var editor:Bool = false;
	public static var gameData:GameData; //unhardcode almost everything lol
	public static var enabledMod:String = "";
	public static var curCustomPath = "assets/";

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if !debug
		initialState = TitleState;
		#end

		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));

		#if !mobile
		fpsCounter = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsCounter);
		#end
	}
	var fpsCounter:FPS;
	
	public function changeFPS(cap:Float)
	{
		openfl.Lib.current.stage.frameRate = cap;
	}
	public function getFPS():Float
	{
		return fpsCounter.currentFPS;
	}

	public static function loadGameDataFile():Void
	{
		var filePath = "assets/data/gameData.json"; 
		if (enabledMod != "")
			filePath = "mods/" + enabledMod + "/data/gameData"; //next update hopefully :)
		#if sys
		var rawJson = File.getContent(filePath);
		#else
		var rawJson = Assets.getText(filePath);
		#end
		gameData = cast Json.parse(rawJson);
	}
	public static function updateGameData():Void
	{
		loadGameDataFile();

		var note = gameData.notesData;
		var play = gameData.PlayStateData;
		var free = gameData.FreeplayData;
		var pause = gameData.PauseMenuData;
		var story = gameData.StoryMenuShit;
		var mainmenu = gameData.MainMenuData;
		var chart = gameData.ChartingStateData;

		PlayState.keyAmmo = note.keyAmmo;
		Note.frameN = note.frameN;
		Note.GFframeN = note.GFframeN;
		Note.noteTypeList = note.noteTypeList;
		CustomizationState.assetList = note.assetList;
		Note.pathList = note.noteAssetList;
		Note.noteTypeAssetPaths = note.noteTypeAssetPaths;
		Note.noteTypePrefixes = note.noteTypePrefixes;
		Note.noteColors = note.noteColors;
		Note.pixelAssetPaths = note.pixelAssetPaths;


		PlayState.poisonDrain = note.poisonDrain;
		PlayState.drainNoteAmount = note.drainNoteAmount;
		PlayState.fireNoteDamage = note.fireNoteDamage;
		PlayState.deathNoteDamage = note.deathNoteDamage;
		PlayState.warningNoteDamage = note.warningNoteDamage;
		PlayState.angelNoteDamage = note.angelNoteDamage;
		PlayState.poisonNoteDamage = note.poisonNoteDamage;
		PlayState.HealthDrainFromGlitchAndBob = note.HealthDrainFromGlitchAndBob;

		BabyArrow.maniaSwitchPositions = note.maniaSwitchPositions;
		BabyArrow.dirArray = note.dirArray;
		BabyArrow.colorFromData = note.colorFromData;
		BabyArrow.laneOffset = note.laneOffset;

		Note.MaxNoteData = note.MaxNoteData;
		Note.noteScales = note.noteScales;
		Note.pixelNoteScales = note.pixelNoteScales;
		Note.noteWidths = note.noteWidths;


		PlayState.sDir = play.sDir;
		PlayState.GFsDir = play.GFsDir;
		PlayState.bfDefaultPos = play.bfDefaultPos;
		PlayState.dadDefaultPos = play.dadDefaultPos;
		PlayState.gfDefaultPos = play.gfDefaultPos;
		PlayState.bfDefaultCamOffset = play.bfDefaultCamOffset;
		PlayState.dadDefaultCamOffset = play.dadDefaultCamOffset;
		PlayState.defaultCamZoom = play.defaultCamZoom;
		PlayState.daPixelZoom = play.daPixelZoom;
		PlayState.StrumLineStartY = play.strumLineStartY;
		PlayState.healthToDieOn = play.healthToDieOn;

		PlayState.shitTiming = play.shitTiming;
		PlayState.badTiming = play.badTiming;
		PlayState.goodTiming = play.goodTiming;
		PlayState.healthFromAnyHit = play.healthFromAnyHit;
		PlayState.healthFromRating = play.healthFromRating;
		PlayState.healthLossFromMiss = play.healthLossFromMiss;
		PlayState.healthLossFromSustainMiss = play.healthLossFromSustainMiss;
		PlayState.healthLossFromMissPress = play.healthLossFromMissPress;
		PlayState.graceTimerCooldown = play.graceTimerCooldown;

		FreeplayState.useAutoDiffSystem = free.useAutoDiffSystem;
		PauseSubState.menuItems = pause.menuItems;
		//StoryMenuState.weekUnlocked = story.weekUnlocked; //crashes for some reason?????
		MainMenuState.optionShit = mainmenu.optionList;

		ChartingState.GRID_SIZE = chart.GRID_SIZE;
		ChartingState.S_GRID_SIZE = chart.S_GRID_SIZE;
		ChartingState.GF_GRID = chart.GF_GRID;
		ChartingState.noteTypes = chart.noteTypes;
	}
}
