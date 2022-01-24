package;

import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

#if sys
import sys.io.File;
import sys.FileSystem;
#end
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import haxe.Json;
import haxe.format.JsonParser;
import openfl.utils.Assets as OpenFlAssets;
import lime.utils.Assets;


using StringTools;

typedef OffsetFile =
{
	var anims:Array<AnimOffsetShit>;
	var otherOffsets:Array<OtherOffsetShit>;
	var flip:Bool;
	var scale:Float;
	var scrollFactor:Array<Float>;
	var aa:Bool;
	var arrowColorShit:ArrowColors;
	var healthBar:RGB;
	var useExtraSpritesheets:Bool;
	var otherSheetAnims:Array<AnimsOnOtherSheets>;
}
typedef OtherOffsetShit = 
{
	var type:String;
	var offsets:Array<Int>;
}

typedef AnimsOnOtherSheets = 
{
	var animName:String;
	var charNameForSpritesheet:String;
}

typedef AnimOffsetShit = 
{
	var anim:String; 
	var xmlname:String;
	var offsets:Array<Int>;
	var frameRate:Int;
	var loop:Bool;
	
}

typedef ArrowColors = 
{
    var purple:Array<Float>;
    var blue:Array<Float>;
    var green:Array<Float>;
    var red:Array<Float>;
    var white:Array<Float>;
    var yellow:Array<Float>;
    var violet:Array<Float>;
    var darkred:Array<Float>;
    var dark:Array<Float>;
}

typedef RGB = 
{
	var red:Int;
	var green:Int;
	var blue:Int;
}


class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	public var curGraphic:String = 'bf'; //for extra spritesheets????? auto switch character based on animation???

	public var holdTimer:Float = 0;

	public var posOffsets:Map<String, Array<Dynamic>>;

	public var flip:Bool = false;

	public var noteColors:Array<Array<Float>> = [
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0]
    ];

	public var healthColors:Array<Int> = [255, 0, 0]; //rgb, so default is set to red

	public var animTime:Float = 4;
	public var noteCamMovement:Array<Float> = [0, 0];
	public var defaultPos:Array<Float>;

	public var canSing:Bool = true;
	public var singAllNoteDatas:Bool = true;
	public var noteDatasToSingOn:Array<Int> = [0,1,2,3,4,5,6,7,8];
	public var player1Side:Bool = false;
	var tex:FlxAtlasFrames;

	public var useExtraSpritesheets:Bool = false;
	public var otherSheetAnims:Array<Dynamic> = [];

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false, ?flip:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		posOffsets = new Map<String, Array<Dynamic>>();
		
		this.isPlayer = isPlayer;
		this.flip = flip;

		antialiasing = true;
		if (PlayState.characters)
			loadCharacter(character);
		else 
		{
			curCharacter = character;
			curGraphic = character;
			makeGraphic(1,1); //bf become cube
			visible = false;
			animation.add("idle", [0]);
			animation.add("singLEFT", [0]);
			animation.add("singRIGHT", [0]);
			animation.add("singDOWN", [0]);
			animation.add("singUP", [0]);
			dance();
		}
	}

	override function update(elapsed:Float)
	{
		if (!isPlayer)
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed * PlayState.SongSpeedMultiplier;
			}

			if (holdTimer >= Conductor.stepCrochet * animTime * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}
		switch (curCharacter)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!PlayState.characters)
			return;

		if (!debugMode)
		{
			switch (curCharacter)
			{
				case 'gf':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'gf-christmas':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'gf-car':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}
				case 'gf-pixel':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'spooky':
					danced = !danced;

					if (danced)
						playAnim('danceRight');
					else
						playAnim('danceLeft');
				default:
					playAnim('idle');
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0, noteData:Int = 0):Void
	{
		if (AnimName == "singNONE")
			return;

		if (AnimName.startsWith("sing"))
		{
			if (!canSing)
				return;
			else if (!singAllNoteDatas && !noteDatasToSingOn.contains(noteData))
				return;
			else 
				holdTimer = 0;
		}

		if (!PlayState.characters)
			return;

		if (animation.getByName(AnimName) == null)
			checkAnimation(AnimName);

		animation.play(AnimName, Force, Reversed, Frame);
		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
			animation.curAnim.frameRate = Std.int(daOffset[2] * PlayState.SongSpeedMultiplier);
		}
		else
			offset.set(0, 0);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		var defaultFrameRate:Float = 24;
		if (animation.getByName(name) != null)
			defaultFrameRate = animation.getByName(name).frameRate;

		var fuck:Array<Dynamic> = [x, y, defaultFrameRate, curGraphic];
		animOffsets[name] = fuck;
	}

	public function addPosOffset(name:String, x:Float = 0, y:Float = 0)
	{
		posOffsets[name] = [x, y];
	}


	public function checkAnimation(AnimName:String)
	{
		//trace(otherSheetAnims);
		var foundSheet:Bool = false;
		for (i in 0...otherSheetAnims.length)
		{
			if (otherSheetAnims[i][0] == AnimName) //haha funni switch character
			{
				trace("found anim name");
				if (otherSheetAnims[i][1] != curGraphic)
					loadCharacter(otherSheetAnims[i][1], false);
				foundSheet = true;
				break;
			}
		}
	}

	public function loadCharacter(char:String, reset:Bool = true)
	{

		if (!PlayState.characters)
			return;

		if (reset)
		{
			curCharacter = char;
			animOffsets.clear();
			posOffsets.clear();
			flipX = false;
			
		}
		animation.destroyAnimations();
		tex = null;
		frames = null;
		curGraphic = char;

		trace("loading character: " + curGraphic);

		switch (curGraphic)
		{
			case 'gf':
				// GIRLFRIEND CODE
				tex = Paths.getSparrowAtlas('GF_assets');
				frames = tex;
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				addOffset('cheer');
				addOffset('sad', -2, -2);
				addOffset('danceLeft', 0, -9);
				addOffset('danceRight', 0, -9);

				addOffset("singUP", 0, 4);
				addOffset("singRIGHT", 0, -20);
				addOffset("singLEFT", 0, -19);
				addOffset("singDOWN", 0, -20);
				addOffset('hairBlow', 45, -8);
				addOffset('hairFall', 0, -9);

				addOffset('scared', -2, -17);

				playAnim('danceRight');

			case 'gf-christmas':
				tex = Paths.getSparrowAtlas('christmas/gfChristmas', 'week5');
				frames = tex;
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				addOffset('cheer');
				addOffset('sad', -2, -2);
				addOffset('danceLeft', 0, -9);
				addOffset('danceRight', 0, -9);

				addOffset("singUP", 0, 4);
				addOffset("singRIGHT", 0, -20);
				addOffset("singLEFT", 0, -19);
				addOffset("singDOWN", 0, -20);
				addOffset('hairBlow', 45, -8);
				addOffset('hairFall', 0, -9);

				addOffset('scared', -2, -17);

				playAnim('danceRight');

			case 'gf-car':
				tex = Paths.getSparrowAtlas('gfCar', 'week4');
				frames = tex;
				animation.addByIndices('singUP', 'GF Dancing Beat Hair blowing CAR', [0], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat Hair blowing CAR', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat Hair blowing CAR', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24,
					false);

				addOffset('danceLeft', 0);
				addOffset('danceRight', 0);

				playAnim('danceRight');

			case 'gf-pixel':
				tex = Paths.getSparrowAtlas('weeb/gfPixel', 'week6');
				frames = tex;
				animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
				animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				addOffset('danceLeft', 0);
				addOffset('danceRight', 0);

				playAnim('danceRight');

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
				antialiasing = false;

			case 'dad':
				// DAD ANIMATION LOADING CODE
				tex = Paths.getSparrowAtlas('DADDY_DEAREST');
				frames = tex;
				animation.addByPrefix('idle', 'Dad idle dance', 24);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24);

				addOffset('idle');
				addOffset("singUP", -6, 50);
				addOffset("singRIGHT", 0, 27);
				addOffset("singLEFT", -10, 10);
				addOffset("singDOWN", 0, -30);

				playAnim('idle');

				addPosOffset('startCam', 400, 0);

				animTime = 6.1;
			case 'spooky':
				tex = Paths.getSparrowAtlas('spooky_kids_assets', 'week2');
				frames = tex;
				animation.addByPrefix('singUP', 'spooky UP NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'spooky DOWN note', 24, false);
				animation.addByPrefix('singLEFT', 'note sing left', 24, false);
				animation.addByPrefix('singRIGHT', 'spooky sing right', 24, false);
				animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
				animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);

				addOffset('danceLeft', 0, 0);
				addOffset('danceRight', 0, 0);

				addOffset("singUP", -20, 26);
				addOffset("singRIGHT", -130, -14);
				addOffset("singLEFT", 130, -10);
				addOffset("singDOWN", -50, -130);

				playAnim('danceRight');

				addPosOffset('pos', 0, 200);
			case 'mom':
				tex = Paths.getSparrowAtlas('Mom_Assets', 'week4');
				frames = tex;

				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

				addOffset('idle');
				addOffset("singUP", 14, 71);
				addOffset("singRIGHT", 10, -60);
				addOffset("singLEFT", 250, -23);
				addOffset("singDOWN", 20, -160);

				playAnim('idle');

				addPosOffset('cam', 0, 100);

			case 'mom-car':
				tex = Paths.getSparrowAtlas('momCar', 'week4');
				frames = tex;

				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

				addOffset('idle');
				addOffset("singUP", 14, 71);
				addOffset("singRIGHT", 10, -60);
				addOffset("singLEFT", 250, -23);
				addOffset("singDOWN", 20, -160);

				playAnim('idle');
			case 'monster':
				tex = Paths.getSparrowAtlas('Monster_Assets', 'week2');
				frames = tex;
				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

				addOffset('idle');
				addOffset("singUP", -20, 50);
				addOffset("singRIGHT", -51);
				addOffset("singLEFT", -30);
				addOffset("singDOWN", -30, -40);
				playAnim('idle');

				addPosOffset('pos', 0, 100);
			case 'monster-christmas':
				tex = Paths.getSparrowAtlas('christmas/monsterChristmas', 'week5');
				frames = tex;
				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

				addOffset('idle');
				addOffset("singUP", -20, 50);
				addOffset("singRIGHT", -51);
				addOffset("singLEFT", -30);
				addOffset("singDOWN", -40, -94);
				playAnim('idle');

				addPosOffset('pos', 0, 130);
			case 'pico':
				tex = Paths.getSparrowAtlas('Pico_FNF_assetss', 'week3');
				frames = tex;
				animation.addByPrefix('idle', "Pico Idle Dance", 24);
				animation.addByPrefix('singUP', 'pico Up note0', 24, false);
				animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);
				if (isPlayer)
				{
					animation.addByPrefix('singLEFT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico Note Right Miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico NOTE LEFT miss', 24, false);
				}
				else
				{
					// Need to be flipped! REDO THIS LATER!
					animation.addByPrefix('singLEFT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico NOTE LEFT miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico Note Right Miss', 24, false);
				}

				animation.addByPrefix('singUPmiss', 'pico Up note miss', 24);
				animation.addByPrefix('singDOWNmiss', 'Pico Down Note MISS', 24);

				addOffset('idle');
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -68, -7);
				addOffset("singLEFT", 65, 9);
				addOffset("singDOWN", 200, -70);
				addOffset("singUPmiss", -19, 67);
				addOffset("singRIGHTmiss", -60, 41);
				addOffset("singLEFTmiss", 62, 64);
				addOffset("singDOWNmiss", 210, -28);

				playAnim('idle');

				flipX = true;


				addPosOffset('pos', 0, 300);
				addPosOffset('startCam', 600, 0);

			case 'bf':
				tex = Paths.getSparrowAtlas('BOYFRIEND');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				addOffset("hey", 7, 4);
				addOffset('firstDeath', 37, 11);
				addOffset('deathLoop', 37, 5);
				addOffset('deathConfirm', 37, 69);
				addOffset('scared', -4);

				playAnim('idle');

				flipX = true;

			case 'bf-christmas':
				tex = Paths.getSparrowAtlas('christmas/bfChristmas', 'week5');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				addOffset("hey", 7, 4);

				playAnim('idle');

				flipX = true;
			case 'bf-car':
				tex = Paths.getSparrowAtlas('bfCar', 'week4');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				playAnim('idle');

				flipX = true;
			case 'bf-pixel':
				frames = Paths.getSparrowAtlas('weeb/bfPixel', 'week6');
				animation.addByPrefix('idle', 'BF IDLE', 24, false);
				animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
				animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);

				addOffset('idle');
				addOffset("singUP");
				addOffset("singRIGHT");
				addOffset("singLEFT");
				addOffset("singDOWN");
				addOffset("singUPmiss");
				addOffset("singRIGHTmiss");
				addOffset("singLEFTmiss");
				addOffset("singDOWNmiss");

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				width -= 100;
				height -= 100;

				antialiasing = false;

				flipX = true;
			case 'bf-pixel-dead':
				frames = Paths.getSparrowAtlas('weeb/bfPixelsDEAD', 'week6');
				animation.addByPrefix('singUP', "BF Dies pixel", 24, false);
				animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
				animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
				animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);
				animation.play('firstDeath');

				addOffset('firstDeath');
				addOffset('deathLoop', -37);
				addOffset('deathConfirm', -37);
				playAnim('firstDeath');
				// pixel bullshit
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;
				flipX = true;

			case 'senpai':
				frames = Paths.getSparrowAtlas('weeb/senpai', 'week6');
				animation.addByPrefix('idle', 'Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'SENPAI UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'SENPAI LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'SENPAI RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'SENPAI DOWN NOTE', 24, false);

				addOffset('idle');
				addOffset("singUP", 5, 37);
				addOffset("singRIGHT");
				addOffset("singLEFT", 40);
				addOffset("singDOWN", 14);

				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;

				addPosOffset('pos', 150, 360);
				addPosOffset('startCam', 300, 0);
				addPosOffset('cam', -100, -430);


			case 'senpai-angry':
				frames = Paths.getSparrowAtlas('weeb/senpai', 'week6');
				animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'Angry Senpai UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'Angry Senpai LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'Angry Senpai RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'Angry Senpai DOWN NOTE', 24, false);

				addOffset('idle');
				addOffset("singUP", 5, 37);
				addOffset("singRIGHT");
				addOffset("singLEFT", 40);
				addOffset("singDOWN", 14);
				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;

				addPosOffset('pos', 150, 360);
				addPosOffset('startCam', 300, 0);
				addPosOffset('cam', -100, -430);


			case 'spirit':
				frames = Paths.getPackerAtlas('weeb/spirit', 'week6');
				animation.addByPrefix('idle', "idle spirit_", 24, false);
				animation.addByPrefix('singUP', "up_", 24, false);
				animation.addByPrefix('singRIGHT', "right_", 24, false);
				animation.addByPrefix('singLEFT', "left_", 24, false);
				animation.addByPrefix('singDOWN', "spirit down_", 24, false);

				addOffset('idle', -220, -280);
				addOffset('singUP', -220, -240);
				addOffset("singRIGHT", -220, -280);
				addOffset("singLEFT", -200, -280);
				addOffset("singDOWN", 170, 110);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				addPosOffset('pos', -150, 100);
				addPosOffset('startCam', 300, 0);


			case 'parents-christmas':
				frames = Paths.getSparrowAtlas('christmas/mom_dad_christmas_assets', 'week5');
				animation.addByPrefix('idle', 'Parent Christmas Idle', 24, false);
				animation.addByPrefix('singUP', 'Parent Up Note Dad', 24, false);
				animation.addByPrefix('singDOWN', 'Parent Down Note Dad', 24, false);
				animation.addByPrefix('singLEFT', 'Parent Left Note Dad', 24, false);
				animation.addByPrefix('singRIGHT', 'Parent Right Note Dad', 24, false);

				animation.addByPrefix('singUP-alt', 'Parent Up Note Mom', 24, false);

				animation.addByPrefix('singDOWN-alt', 'Parent Down Note Mom', 24, false);
				animation.addByPrefix('singLEFT-alt', 'Parent Left Note Mom', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'Parent Right Note Mom', 24, false);

				addOffset('idle');
				addOffset("singUP", -47, 24);
				addOffset("singRIGHT", -1, -23);
				addOffset("singLEFT", -30, 16);
				addOffset("singDOWN", -31, -29);
				addOffset("singUP-alt", -47, 24);
				addOffset("singRIGHT-alt", -1, -24);
				addOffset("singLEFT-alt", -30, 15);
				addOffset("singDOWN-alt", -30, -27);

				playAnim('idle');
				addPosOffset('pos', -500, 0);

			default:  	///custom character shit
				var imagePath = "assets/images/characters/" + curGraphic + "/image.png";
				var imageGraphic:FlxGraphic;

				if (CacheShit.images[imagePath] == null)
				{
					var image:FlxGraphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(imagePath));
					image.persist = true;
					CacheShit.images[imagePath] = image;
				}
				imageGraphic = CacheShit.images[imagePath];

				var xmlPath = "assets/images/characters/" + curGraphic + "/image.xml";
				var xml:String;

				if (CacheShit.xmls[xmlPath] != null) //check if xml is stored in cache
					xml = CacheShit.xmls[xmlPath];
				else
				{
					#if sys
					xml = File.getContent(xmlPath);
					#else
					xml = Assets.getText(xmlPath);
					#end
					CacheShit.SaveXml(xmlPath, xml);
				}
					

				tex = FlxAtlasFrames.fromSparrow(imageGraphic, xml); //todo set up the packer things with txts i think idk why tf youd use one just use an xml
				frames = tex;

				#if sys
				var rawJson = File.getContent(Paths.imageJson("characters/" + curGraphic + "/offsets"));
				#else
				var rawJson = Assets.getText(Paths.imageJson("characters/" + curGraphic + "/offsets"));
				#end
				var json:OffsetFile = cast Json.parse(rawJson);

				if (json.otherOffsets.length != 0 && frames != null)
				{
					trace("doing other offsets");
					for (i in json.otherOffsets)
					{
						var type:String = i.type;
						var offsets:Array<Int> = i.offsets; 
						addPosOffset(type, offsets[0], offsets[1]);
					}
				}
				if (json.anims.length != 0 && frames != null)
				{
					for (i in json.anims)
					{
						var animname:String = i.anim;
						var xmlname:String = i.xmlname;
						var fps:Int = i.frameRate;
						var loop:Bool = i.loop;
						var offsets:Array<Int> = i.offsets;

						animation.addByPrefix(animname, xmlname, fps, loop);
						addOffset(animname, offsets[0], offsets[1]);
						if (reset)
							otherSheetAnims.push([animname, curCharacter]);
					}
				}
				if (reset)
				{
					if (json.useExtraSpritesheets)
					{
						useExtraSpritesheets = json.useExtraSpritesheets;
						if (json.otherSheetAnims != null && json.otherSheetAnims.length != 0)
						{
							for (i in json.otherSheetAnims)
							{
								var animName:String = i.animName;
								var charName:String = i.charNameForSpritesheet;
								trace("adding extra sheet anim");
								otherSheetAnims.push([animName, charName]);
							}
						}
					}
				}

				flip = json.flip;
				setGraphicSize(Std.int(this.width * json.scale));
				scrollFactor.set(json.scrollFactor[0], json.scrollFactor[1]);
				antialiasing = json.aa;

				var colors = json.arrowColorShit;


				noteColors = [
					colors.purple,
					colors.blue,
					colors.green,
					colors.red,
					colors.white,
					colors.yellow,
					colors.violet,
					colors.darkred,
					colors.dark
				];

				var color = json.healthBar;
				healthColors = [color.red, color.green, color.blue];
				
					

		}

		if (reset)
			dance();

		if (flip)
		{
			flipX = !flipX;
		}
	}



	function autoGenerateAnims():Void //auto animation shit, no auto offsets though obviously
	{
		if (animation.getByName('idle') != null)
		{
			var animName = findAnimName('idle');
			if (animName != "")
				animation.addByPrefix('idle', animName, 24, false);
		}
		if (animation.getByName('singLEFT') != null)
		{
			var animName = findAnimName('left');
			if (animName != "")
				animation.addByPrefix('singLEFT', animName, 24, false);
		}
		if (animation.getByName('singUP') != null)
		{
			var animName = findAnimName('up');
			if (animName != "")
				animation.addByPrefix('singUP', animName, 24, false);
		}
		if (animation.getByName('singDOWN') != null)
		{
			var animName = findAnimName('down');
			if (animName != "")
				animation.addByPrefix('singDOWN', animName, 24, false);
		}
		if (animation.getByName('singRIGHT') != null)
		{
			var animName = findAnimName('right');
			if (animName != "")
				animation.addByPrefix('singRIGHT', animName, 24, false);
		}
		
	}

	function findAnimName(name:String)
	{
		for (frame in this.frames.frames)
		{
			if (frame.name != null)
			{
				var fname = frame.name.toLowerCase();
				if (fname.contains(name.toLowerCase()))
					return frame.name;
			}
		}
		return "";
	}
}
