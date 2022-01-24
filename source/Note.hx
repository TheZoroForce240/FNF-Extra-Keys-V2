package;

import openfl.display.Bitmap;
import openfl.geom.Rectangle;
import openfl.ui.Multitouch;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end
import PlayState;
import Shaders;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import openfl.geom.Rectangle;
import openfl.geom.Point;

using StringTools;

typedef VelChange = 
{
	var SpeedMulti:Float;
	var ChangeTime:Float;
	var UseSpecificStrumTime:Bool;
}

class Note extends FlxSprite
{
	////////////////////////////////////////////////////////////

	//important note shit
	public var strumTime:Float = 0;
	public var baseStrum:Float = 0;

	public var mustPress:Bool = false; 
	public var strumID:Int = 0; //support for multiple strums :)

	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var parentNote:Note;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var sustainHit:Bool = false;

	public static var MaxNoteData:Int = 9; // :troll:

	var HSV:HSVEffect = new HSVEffect();

	////////////////////////////////////////////////////////////

	//note type shit
	public var noteType:Int = 0;

	public static var noteTypeList = [
		"regular",
		"burning",
		"death",
		"warning",
		"angel",
		"alt",
		"bob",
		"glitch",
		"poison",
		"drain"
	];

	public var normalNote:Bool = true; //just to make checking easier i guess
	public var warningNoteType:Bool = false;
	public var badNoteType:Bool = false;
	public var downscrollYOffset:Float = 0;

	public var healthChangesOnHit:Float = 0; //0 for sustains, used as default
	public var healthChangesOnMiss:Float = 0.15;

	////////////////////////////////////////////////////////////

	//extra shit idk where to put
	public var noteScore:Float = 1;
	public var rating:String = "shit";
	public var scaleMulti:Float = 1; //for middlescroll
	public static var hitTiming = 145;
	public var earlyHitTiming = hitTiming;
	public var lateHitTiming = -hitTiming;
	public static var followAngle:Bool = false;
	public static var StrumLinefollowAngle:Bool = false;
	public var incomingAngle:Float = -90;

	////////////////////////////////////////////////////////////

	//mania shit
	public static var mania:Int = 0; 
	public static var swagWidth:Float = 160 * 0.7;
	public static var noteScale:Float;
	public static var p1NoteScale:Float = 0;
	public static var p2NoteScale:Float = 0;
	//public static var prevNoteScale:Float = 0.5;
	public static var pixelnoteScale:Float;
	public static var tooMuch:Float = 30;
	public var scaleToUse:Float = 1;
	public var curMania:Int = 0; 
	public var changesMania:Bool = false;

	public static var ammoToMania:Array<Int> = [0, 6, 7, 8, 0, 3, 1, 4, 5, 2];
	public static var noteScales:Array<Float> = [0.7, 0.6, 0.5, 0.65, 0.58, 0.55, 0.7, 0.7, 0.7];
	public static var pixelNoteScales:Array<Float> = [1, 0.83, 0.7, 0.9, 0.8, 0.74, 1, 1, 1];
	public static var noteWidths:Array<Float> = [112, 84, 66.5, 91, 77, 70, 140, 126, 119];
	public var sustainXOffset:Float = 1;

	////////////////////////////////////////////////////////////

	//note anim stuff
	public static var frameN:Array<Dynamic> = [ //changed so i dont have to have a ton of case statements
		['purple', 'blue', 'green', 'red'],
		['purple', 'green', 'red', 'yellow', 'blue', 'dark'],
		['purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'darkred', 'dark'],
		['purple', 'blue', 'white', 'green', 'red'],
		['purple', 'green', 'red', 'white', 'yellow', 'blue', 'dark'],
		['purple', 'blue', 'green', 'red', 'yellow', 'violet', 'darkred', 'dark'],
		['white'],
		['purple', 'red'],
		['purple', 'white', 'red']
	];
	public static var GFframeN:Array<String> = ['purple', 'blue', 'green', 'red']; //gf cant have more than 4k

	////////////////////////////////////////////////////////////

	//note asset shit
	public static var pathList:Array<String> = [ //main assets //TODO unhardcode this shit and add note skin support
        'noteassets/NOTE_assets',
        'noteassets/PURPLE_NOTE_assets',
        'noteassets/BLUE_NOTE_assets',
        'noteassets/GREEN_NOTE_assets',
        'noteassets/RED_NOTE_assets'
    ];
	public static var noteTypeAssetPaths:Array<String> = [ //for noteTypes, just cleaning code a bit
		'noteassets/NOTE_assets', //not exactly needed but who cares
		'noteassets/notetypes/NOTE_types', //most note types are in a big spritesheet, if youre wondering why tf i did this
		'noteassets/notetypes/NOTE_types',
		'noteassets/notetypes/NOTE_types',
		'noteassets/notetypes/NOTE_types',
		'noteassets/NOTE_assets', //alt anim notes
		'noteassets/notetypes/NOTE_types',
		'noteassets/notetypes/NOTE_types',
		'noteassets/notetypes/poison',
		'noteassets/notetypes/drain'
	];
	public static var noteTypePrefixes:Array<String> = [
		"",
		"fire",
		"halo",
		"warning",
		"angel",
		"",
		"bob",
		"glitch",
		"poison",
		"poison" //forgot to change xml when copy pasting drain notes, if youre wondering why theres 2 poison
	];
	public var style:String = "";
	public static var noteColors:Array<String> = ['purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'darkred', 'dark'];
	public var colorShit:Array<Float>;
	var pathToUse:Int = 0;

	public static var pixelAssetPaths:Array<Array<String>> = [ //for noteTypes, code cleanup
		['noteassets/pixel/arrows-pixels', 'noteassets/pixel/arrowEnds'],
		['noteassets/pixel/firenotes/arrows-pixels', 'noteassets/pixel/firenotes/arrowEnds'],
		['noteassets/pixel/halo/arrows-pixels', 'noteassets/pixel/halo/arrowEnds'],
		['noteassets/pixel/warning/arrows-pixels', 'noteassets/pixel/warning/arrowEnds'],
		['noteassets/pixel/angel/arrows-pixels', 'noteassets/pixel/angel/arrowEnds'],
		['noteassets/pixel/arrows-pixels', 'noteassets/pixel/arrowEnds'], //repeated for alt anim notes
		['noteassets/pixel/bob/arrows-pixels', 'noteassets/pixel/bob/arrowEnds'],
		['noteassets/pixel/glitch/arrows-pixels', 'noteassets/pixel/glitch/arrowEnds'], //TODO make pixel sprites for posion and drain notes
		['noteassets/pixel/firenotes/arrows-pixels', 'noteassets/pixel/firenotes/arrowEnds'], //temp assets for poison and drain
		['noteassets/pixel/arrows-pixels', 'noteassets/pixel/arrowEnds']
	];

	////////////////////////////////////////////////////////////

	public var speed:Float = 1; //note speed and velocity shit
	public var velocityData:VelChange;
	public var speedMulti:Float = 1;
	public var velocityChangeTime:Float;
	public var startPos:Float = 0;
	public var curAlpha:Float = 1;
	public var noteDataToFollow:Int = 0;

	////////////////////////////////////////////////////////////

	//event note shit
	public var isGFNote:Bool = false;
	public var eventData:Array<String>; //name + values from chart editor
	public var eventWasValid:Bool = true;

	////////////////////////////////////////////////////////////

	public var rawNoteData:Int = 0; //for charter
	public var playedSound:Bool = true;
	public var canPlaySound:Bool = true;
	public var inCharter:Bool = false;
	public var updated:Bool = true;
	public var beingGrabbed:Bool = false;
	public var highlighted:Bool = false;
	public var section:Int = 0;

	////////////////////////////////////////////////////////////

	//note quantization stuff
	public var noteColor:String = "purple";
	public static var usingQuant:Bool = SaveData.noteQuant;
	static var beats:Array<Int> = [4, 8, 12, 16, 24, 32, 48, 64, 96, 128, 192,256,384,512,768,1024,1536,2048,3072,6144];

	////////////////////////////////////////////////////////////

	//experimental stuff

	//public var noteCam:FlxCamera; //just because i want multiple shaders on a note
	//terrible idea, pc almost exploded playing bopeebo

	//var StrumGroup:StrumLineGroup; //i think this can cause lag
	public var beenFlipped:Bool = false;
	public var curPos:Float = 0;

	///////////////////////////////////////////////////////////

	public function new(strumTime:Float, _noteData:Int, ?noteType:Int = 0, ?sustainNote:Bool = false, ?_speed:Float = 1, ?_velocityData:Array<Dynamic>, ?charter = false, ?_gfNote, ?_mustPress:Bool = false, ?_eventData:Array<String>, ?prevNote:Note, ?parent:Note)
	{
		StrumLinefollowAngle = false;
		followAngle = false;

		usingQuant = SaveData.noteQuant;

		swagWidth = 160 * 0.7;
		noteScale = 0.7;
		pixelnoteScale = 1;
		mania = 0;
		if (PlayState.SONG.mania != 0)
		{
			mania = PlayState.SONG.mania;
			swagWidth = noteWidths[mania];
			noteScale = noteScales[mania];
			pixelnoteScale = pixelNoteScales[mania];
		}

		if (!PlayState.regeneratingNotes)
		{
			p1NoteScale = noteScale;
			p2NoteScale = noteScale;
		}

		if (_speed <= 1) //sets speed to song speed if the speed value of a note is 1 or less, just as a backup in case it becomes 0
			speed = PlayState.SongSpeed;
		else
			speed = _speed;

		super();

		if (prevNote == null)
			prevNote = this;
		this.noteType = noteType;
		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		
		if (isSustainNote)
			this.parentNote = parent;

		if (_velocityData != null)
		{
			if (_velocityData.length > 2)
			{
				velocityData = {
					SpeedMulti: _velocityData[0],
					ChangeTime: _velocityData[1],
					UseSpecificStrumTime: _velocityData[2]
				};
			}
			else //back compat
			{
				velocityData = {
					SpeedMulti: _velocityData[0],
					ChangeTime: _velocityData[1],
					UseSpecificStrumTime: false
				};
			}
		}

		mustPress = _mustPress;
		inCharter = charter;
		if (_eventData != null)
		{
			eventData = _eventData;
		}

		if (!inCharter)
		{
			if (SaveData.randomNoteSpeed)
				speed = FlxMath.roundDecimal(FlxG.random.float(2.2, 3.8), 2);
	
			if (SaveData.speedScaling)
				speed = FlxMath.roundDecimal((speed / 0.7) * (noteScale * scaleMulti), 2); //adjusts speed based on note size, i should make this an option at some point
	
	
			if (!PlayState.rewinding)
				speed = FlxMath.roundDecimal(speed / PlayState.SongSpeedMultiplier, 2);
			else
				speed = FlxMath.roundDecimal(speed, 2);

			if (PlayState.randomNoteAngles)
			{
				incomingAngle = FlxG.random.int(0, 360);
			}
		}


				
		if (Main.editor)
			this.strumTime = strumTime;
		else 
			this.strumTime = Math.round(strumTime);

		if (this.strumTime < 0 )
			this.strumTime = 0;

		if (SaveData.randomNoteVelocity)
		{
			speedMulti = FlxMath.roundDecimal(FlxG.random.float(0.5, 2.5), 2);
			velocityChangeTime = FlxMath.roundDecimal(FlxG.random.float(0, 800), 2);
		}

		this.noteData = _noteData % MaxNoteData;

		isGFNote = _gfNote;
		noteTypeCheck();

		if (!inCharter && SaveData.randomNotes)
			noteData = FlxG.random.int(0, PlayState.keyAmmo[mania] - 1);

		if (isSustainNote && prevNote != null)
			noteData = prevNote.noteData;

		noteDataToFollow = noteData;

		
		if (!_mustPress)
		{
			if (strumTime >= PlayState.lastP2mChange)
				curMania = PlayState.curP2NoteMania;
			else
				curMania = PlayState.prevP2NoteMania;
			colorShit = ColorPresets.noteColors[BabyArrow.colorFromData[mania][noteData]];
		}
		else
		{
			if (strumTime >= PlayState.lastP1mChange)
				curMania = PlayState.curP1NoteMania;
			else
				curMania = PlayState.prevP1NoteMania;
			colorShit = SaveData.noteColors[BabyArrow.colorFromData[mania][noteData]];
		}
		if (mania != 2) //mania changes only allowed on 9k
			curMania = mania;


		if (Note.usingQuant)
            colorShit = [0,0,0,4];

		if (isGFNote)
			curMania = 0;

		scaleToUse = noteScales[curMania];

		if (!isGFNote)
		{
			pathToUse = Std.int(colorShit[3]);
			if (Note.usingQuant)
				pathToUse = 4;
		}
			

		if (SaveData.middlescroll && !_mustPress && !inCharter && !isGFNote)
			scaleMulti = 0.55;

		if (inCharter)
		{
			style = "";
			pathToUse = 0;
		}
		else if (pathToUse == 5)
			style = 'pixel';


		if (!isGFNote)
		{
			if (mustPress && !inCharter)
			{
				this.cameras = PlayState.p1.getNoteCams();
				if (isSustainNote)
					this.cameras = PlayState.p1.getNoteCams(true);
			}
			else if (!mustPress && !inCharter)
			{
				this.cameras = PlayState.p2.getNoteCams();
				if (isSustainNote)
					this.cameras = PlayState.p2.getNoteCams(true);			
			}
		}

		if (curMania != mania)
		{
			changesMania = true;
		}

		quantCheck();
		loadNote();
		playNoteAnim();
		positionNote();
		
		if (isSustainNote && prevNote != null)
			createSustain();

		if (!isGFNote)
			downscrollCheck();
		this.shader = HSV.shader;

		if (normalNote)
		{
			HSV.hue = colorShit[0];
			HSV.saturation = colorShit[1];
			HSV.brightness = colorShit[2];
			HSV.update();
		}			
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (inCharter && highlighted)
			color = 0x016BC5;
		else if (inCharter)
			color = 0xFFFFFFFF;

		if (!inCharter)
		{
			if (PlayState.rainbowNotes)
			{
				HSV.hue += (0.1 * elapsed);
				HSV.update();
			}
			if ((mustPress && !PlayState.flipped) || (!mustPress && PlayState.flipped) || (PlayState.multiplayer))
			{
				if (badNoteType)
				{
					if (strumTime - Conductor.songPosition <= (100 * Conductor.timeScale)
						&& strumTime - Conductor.songPosition >= (-50 * Conductor.timeScale))
						canBeHit = true;
					else
						canBeHit = false;	
				}
				else
				{
					if (strumTime - Conductor.songPosition <= (earlyHitTiming * Conductor.timeScale)
						&& strumTime - Conductor.songPosition >= (lateHitTiming * Conductor.timeScale))
						canBeHit = true;
					else
						canBeHit = false;
				}
				if (strumTime - Conductor.songPosition < lateHitTiming && !wasGoodHit)
					tooLate = true;
				else 
					tooLate = false;
			}
			else
			{
				canBeHit = false;
	
				if (strumTime <= Conductor.songPosition && !badNoteType)
					wasGoodHit = true;
			}
			var timeToDelete = -450;
	
			if (strumTime - Conductor.songPosition < -450 && !inCharter) //forcefully remove all notes past this point, also how all sutains are removed to fix clipping
				deleteShit();
	
			if (isGFNote)
				if (strumTime <= Conductor.songPosition)
					wasGoodHit = true;
			else if (badNoteType)
				if (strumTime - Conductor.songPosition < -300) //so note types go past the strumline before removed
					wasGoodHit = true;
	
			/*if (!changedVelocityScale)
				if (speedMulti != 0 || speedMulti != 1)
					if ((strumTime - velocityChangeTime) <= Conductor.songPosition)
							fixSustains();*/
					
	
			if (tooLate && !wasGoodHit)
			{
				if (alpha > 0.3)
					alpha = 0.3;
			}
		}


	}

	function deleteShit():Void
	{
		PlayState.instance.removeNote(this);
	}

	function positionNote():Void //dont think this is needed but il do it anyway
	{
		y -= 2000;
		x += 50;
		if (curMania == 2)
		{
			x -= tooMuch; //moves notes a little to the left on 9k
		}
		x += noteWidths[curMania] * noteData;
	}


	function loadNote():Void
	{
		frames = null;
		animation.destroyAnimations();

		switch (style)
		{
			case 'pixel':

				var noteTypePath:Int = noteType;
				if (noteTypePath < 0 || noteTypePath > pixelAssetPaths.length)
					noteTypePath = 0;

				if (!isSustainNote)
					loadGraphic(Paths.image(pixelAssetPaths[noteTypePath][0]), true, 17, 17);
				else
					loadGraphic(Paths.image(pixelAssetPaths[noteTypePath][1]), true, 7, 6);

				for (i in 0...9) //pixel notes still do for loop due to it causing issues
				{
					if (!isSustainNote)
						animation.add(noteColors[i] + 'Scroll', [i + 9]); // Normal notes
					else
					{
						animation.add(noteColors[i] + 'hold', [i]); // Holds
						animation.add(noteColors[i] + 'holdend', [i + 9]); // Tails
					}
				}
				setGraphicSize(Std.int(width * PlayState.daPixelZoom * pixelnoteScale * scaleMulti));
				updateHitbox();
			default:
				var prefix:String = noteTypePrefixes[noteType];
				if (normalNote)
				{
					prefix = frameN[mania][noteData]; 
					frames = Paths.getSparrowAtlas(pathList[pathToUse]);
				}	
				else
				{
					if (!isSustainNote)
						prefix += " " + frameN[mania][noteData]; //sustains use same part of xml, so they dont need the color for the prefix
																//i literally i have fucking clue wtf im talking about here
					frames = Paths.getSparrowAtlas(noteTypeAssetPaths[noteType]);
				}
				if (isGFNote && inCharter)
					animation.addByPrefix(frameN[2][noteData] + 'Scroll', prefix + '0'); // fix issues with charter
				else if (!isSustainNote)
					animation.addByPrefix(frameN[mania][noteData] + 'Scroll', prefix + '0'); // Normal notes
				else 
				{
					animation.addByPrefix(frameN[mania][noteData] + 'hold', prefix + ' hold piece'); // Hold
					animation.addByPrefix(frameN[mania][noteData] + 'holdend', prefix + ' hold end'); // Tails
				}


				//finally got around to cleaning this shit up

				setGraphicSize(Std.int(width * scaleToUse * scaleMulti));
				updateHitbox();
				antialiasing = true;
		}
	}

	function playNoteAnim():Void
	{
		if (inCharter)
		{
			if (isGFNote)
				animation.play(frameN[2][noteData] + 'Scroll');
			else
			{
				animation.play(frameN[mania][noteData] + 'Scroll');
			}
		}
		else if (!isSustainNote)
		{
			animation.play(frameN[mania][noteData] + 'Scroll');
		}	
	}

	function createSustain():Void 
	{
		speed = prevNote.speed;
		scaleToUse = prevNote.scaleToUse;
		speedMulti = prevNote.speedMulti;
		velocityChangeTime = prevNote.velocityChangeTime;
		noteScore * 0.2;
		curAlpha = 0.6;
		incomingAngle = prevNote.incomingAngle;

		sustainXOffset = (((37 / 0.7) * scaleToUse) * scaleMulti);

		colorShit[0] = prevNote.colorShit[0];
		colorShit[1] = prevNote.colorShit[1];
		colorShit[2] = prevNote.colorShit[2];

		earlyHitTiming = 75;

		x += width / 2;

		//setGraphicSize(Std.int(width * 2));

		
		animation.play(frameN[mania][noteData] + 'holdend');

		updateHitbox();

		x -= width / 2;

		if (PlayState.curStage.startsWith('school'))
			x += 30;

		if (prevNote.isSustainNote)
		{
			prevNote.animation.play(frameN[mania][prevNote.noteData] + 'hold');
			prevNote.updateHitbox();
			prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * speed * (0.7 / (scaleToUse * scaleMulti));
			prevNote.updateHitbox();

			//prevNote.sustainOffset = Math.round(-prevNote.offset.y);
			//sustainOffset = Math.round(-offset.y);

		}

		//scale.y *= Conductor.stepCrochet / 100 * 1.5 * speed * speedMulti * (0.7 / (noteScale * scaleMulti));
		//updateHitbox(); //just testin stuff
	}

	function downscrollCheck():Void 
	{
		if (((SaveData.downscroll && mustPress && !isSustainNote) || 
			(SaveData.P2downscroll && !mustPress && !isSustainNote)) && 
			!inCharter)
		{
			scale.y *= -1;	
			beenFlipped = true;			
		}
	
	}

	function quantCheck():Void 
	{
		if (usingQuant && !isSustainNote)
			{
				pathToUse = 4; //use red notes

				var time = strumTime;

				if (Conductor.bpmChangeMap.length > 0)
				{
					for (bpmchange in Conductor.bpmChangeMap) //doesnt work il fix it later
					{
						if (strumTime >= bpmchange.songTime)
						{
							time -= bpmchange.songTime;
						}
					}
				}

			
				var beat = Math.round((time / (Conductor.stepCrochet * 4)) * 48);
				for (i in 0...beats.length)
				{
					if (beat % (192 / beats[i]) == 0)
					{
						beat = beats[i];
						break;
					}			
				}
				switch (beat)
				{
					case 4: //red
						colorShit[0] = 0;
						colorShit[1] = 0;
						colorShit[2] = 0;
					case 8: //blue
						colorShit[0] = -0.34;
						colorShit[1] = 0;
						colorShit[2] = 0;
					case 12: //purple
						colorShit[0] = 0.8;
						colorShit[1] = 0;
						colorShit[2] = 0;
					case 16: //yellow
						colorShit[0] = 0.16;
						colorShit[1] = 0;
						colorShit[2] = 0;
					case 24: //pink
						colorShit[0] = 0.91;
						colorShit[1] = 0;
						colorShit[2] = 0;
					case 32: //orange
						colorShit[0] = 0.06;
						colorShit[1] = 0;
						colorShit[2] = 0;
					case 48: //cyan
						colorShit[0] = -0.53;
						colorShit[1] = 0;
						colorShit[2] = 0;
					case 64: //green
						colorShit[0] = -0.7;
						colorShit[1] = 0;
						colorShit[2] = 0;
					case 96: //salmon lookin ass
						colorShit[0] = 0;
						colorShit[1] = -0.33;
						colorShit[2] = 0;
					case 128: //light purple shit
						colorShit[0] = -0.24;
						colorShit[1] = -0.33;
						colorShit[2] = 0;
					case 192: //turquioe i cant spell
						colorShit[0] = 0.44;
						colorShit[1] = 0.31;
						colorShit[2] = 0;
					case 256: //shit (the color of it)
						colorShit[0] = 0.03;
						colorShit[1] = 0;
						colorShit[2] = -0.63;
					case 384: //dark green ugly shit
						colorShit[0] = 0.29;
						colorShit[1] = 1;
						colorShit[2] = -0.89;
					case 512: //darj blue
						colorShit[0] = -0.33;
						colorShit[1] = 0.29;
						colorShit[2] = -0.7;
					case 768: //gray ok
						colorShit[0] = 0.04;
						colorShit[1] = -0.86;
						colorShit[2] = -0.23;
					case 1024: //turqyuarfhiouhifueaig but dark
						colorShit[0] = 0.46;
						colorShit[1] = 0;
						colorShit[2] = -0.46;
					case 1536: //pure death
						colorShit[0] = 0;
						colorShit[1] = 0;
						colorShit[2] = -1;
					case 2048: //piss and shit color
						colorShit[0] = 0.2;
						colorShit[1] = -0.36;
						colorShit[2] = -0.74;
					case 3072: //boring ass color
						colorShit[0] = 0.17;
						colorShit[1] = -0.57;
						colorShit[2] = -0.27;
					case 6144: //why did i do this? idk tbh, it just funni
						colorShit[0] = 0.23;
						colorShit[1] = 0.76;
						colorShit[2] = -0.83;
					default: // white/gray
						colorShit[0] = 0.04;
						colorShit[1] = -0.86;
						colorShit[2] = -0.23;
				}
			}
	}

	function noteTypeCheck():Void
	{
		switch (noteTypeList[noteType])
		{
			case "warning" | "glitch": 
				warningNoteType = true;
				normalNote = false;
				downscrollYOffset = 50;
			case "regular" | "alt": 
				normalNote = true;
			case "angel": 
				normalNote = false;
				downscrollYOffset = 50;
			case "drain": 
				normalNote = false;
				downscrollYOffset = 50;
			case "burning" | "death" | "bob" | "poison": 
				normalNote = false;
				badNoteType = true;
				downscrollYOffset = 50;
			default: 
				//add custom ntoe tyeps scucppotp 
		}
	}

	public function noteTypeHit():Void 
	{
		switch (noteTypeList[noteType])
		{
			case "warning" | "glitch": 
				//nothing
			case "regular" | "alt": 
				//nothing lol
			case "angel": 
				switch(rating)
				{
					case "shit": 
						PlayState.instance.badNoteHit();
						healthChangesOnHit = PlayState.angelNoteDamage[0];
					case "bad": 
						PlayState.instance.badNoteHit();
						healthChangesOnHit = PlayState.angelNoteDamage[1];
					case "good": 
						healthChangesOnHit = PlayState.angelNoteDamage[2];
					case "sick": 
						healthChangesOnHit = PlayState.angelNoteDamage[3];
				}

			case "burning": 
				PlayState.instance.badNoteHit();
				healthChangesOnHit -= PlayState.fireNoteDamage;
			case "death": 
				PlayState.instance.badNoteHit();
				healthChangesOnHit -= PlayState.deathNoteDamage;
			case "bob": 
				PlayState.instance.badNoteHit();
				if (PlayState.multiplayer && !mustPress)
					PlayState.instance.HealthDrain(0);
				else
					PlayState.instance.HealthDrain(1);
			case "poison": 
				PlayState.instance.badNoteHit();
				healthChangesOnHit -= PlayState.poisonNoteDamage;
				if (PlayState.multiplayer && !mustPress)
					PlayState.p2.Stats.poisonHits++;
				else
					PlayState.p1.Stats.poisonHits++;
			case "drain": 
				if (PlayState.multiplayer)
				{
					var statsToUse = PlayState.p1.Stats;
					if (!mustPress)
						statsToUse = PlayState.p2.Stats;

					if (PlayState.drainNoteAmount > statsToUse.health)
						statsToUse.health = PlayState.drainNoteAmount;
					else 
						statsToUse.health -= PlayState.drainNoteAmount;
				}
			default: 
				//add custom ntoe tyeps scucppotp 
		}
	}

	public function noteTypeMiss(strums:String, playernum:Int):Void 
	{
		switch (noteTypeList[noteType])
		{
			case "warning": 
				PlayState.instance.removeNote(this);
				var statsToUse = PlayState.p1.Stats;
				if (!mustPress && PlayState.multiplayer)
					statsToUse = PlayState.p2.Stats;
				PlayState.instance.badNoteHit();
				statsToUse.health -= PlayState.warningNoteDamage;
				statsToUse.misses++;
			case "glitch": 
				PlayState.instance.removeNote(this);
				var statsToUse = PlayState.p1.Stats;
				if (!mustPress && PlayState.multiplayer)
					statsToUse = PlayState.p2.Stats;
				PlayState.instance.HealthDrain(playernum);
				PlayState.instance.badNoteHit();
				statsToUse.misses++;
			case "angel": 
				//nothing, they literally do nothing if you miss
				PlayState.instance.removeNote(this);
			case "burning" | "death" | "bob" | "poison": 
				PlayState.instance.removeNote(this);
			case "regular" | "alt" | "drain": 
				if (isSustainNote && wasGoodHit) //to 100% make sure the sustain is gone
				{
					this.kill();
					PlayState.instance.removeNote(this);
				}
				else
				{
					PlayState.instance.vocals.volume = 0;
					PlayState.instance.noteMiss(this.noteData, this, playernum);								
				}
				PlayState.instance.removeNote(this);
			default: 
				//add custom ntoe tyeps scucppotp 
				PlayState.instance.removeNote(this); //temp
		}
	}

	public function clipSustain(clipTo:FlxPoint)
	{
		//var notepos = new FlxPoint(this.x, this.y);
		//var rad = clipTo.distanceTo(notepos);
		//var rectshit = FlxAngle.getPolarCoords((clipTo.x - this.x) / scale.x, (clipTo.y - this.y) / scale.y);
		//var rectPos = FlxAngle.getCartesianCoords(rectshit., angle + 90);
		//fuckYouRect.y = (clipTo.y - rectPos.y) / scale.y;

		var angleshit = ((incomingAngle % 360) + 360) % 360; //do mod twice to make negative numbers positive

		if (followAngle)
		{
			angleshit = (((angle - 90) % 360) + 360) % 360;
		}

		var up = (angleshit <= 315 && angleshit >= 225);
		var left = (angleshit <= 225 && angleshit >= 135);
		var right = (angleshit <= 45 && angleshit >= 315);
		var down = (angleshit <= 135 && angleshit >= 45);


		if (up) //regular clipping
		{
			var fuckYouRect = new FlxRect(0, 0, width / scale.x, height / scale.y);
			fuckYouRect.y = ((clipTo.y - y) / scale.y);
			fuckYouRect.height -= fuckYouRect.y;
			clipRect = fuckYouRect;
		}
		else 
		{
			if (strumTime + Conductor.stepCrochet <= Conductor.songPosition)
				visible = false; //dumb workaround while i figure out angled clipping
		}
	}
}

class CharterSustain extends FlxSprite //so i can do the grabbing thing
{
	public var note:Note;
	public var noteData:Int = 0;

	public function new (xpos:Float, ypos:Float, wid:Int, height:Int, mania:Int, _note:Note)
	{
		super();
		makeGraphic(wid, height);
		x = xpos;
		y = ypos;
		note = _note;
		noteData = note.noteData;
		var color = Note.frameN[mania][noteData];
		var flxcolorToUse:FlxColor = FlxColor.WHITE;
		switch (color)
		{
			case "purple": 
				flxcolorToUse = FlxColor.PURPLE;
			case "blue": 
				flxcolorToUse = FlxColor.CYAN;
			case "green": 
				flxcolorToUse = FlxColor.GREEN;
			case "red": 
				flxcolorToUse = FlxColor.RED;
			case "white": 
				flxcolorToUse = FlxColor.WHITE;
			case "yellow": 
				flxcolorToUse = FlxColor.YELLOW;
			case "violet": 
				flxcolorToUse = FlxColor.PURPLE;
			case "darkred": 
				flxcolorToUse = FlxColor.RED;
			case "dark": 
				flxcolorToUse = FlxColor.BLUE;
		}
		this.color = flxcolorToUse;
	}
}
