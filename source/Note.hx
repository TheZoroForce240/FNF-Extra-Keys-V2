package;

import openfl.ui.Multitouch;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

import flixel.math.FlxPoint;
import flixel.math.FlxRect;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end
import PlayState;
import Shaders;

using StringTools;

class Note extends FlxSprite
{
	////////////////////////////////////////////////////////////

	//important note shit
	public var strumTime:Float = 0;
	public var baseStrum:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var sustainHit:Bool = false;
	public var prevNote:Note;
	
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var isSustainEnd:Bool = false;

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
	public var daShit:Int = 0; //this is just for note data and anim shit that was annoying me
	public static var hitTiming = 145;
	public var earlyHitTiming = hitTiming;
	public var lateHitTiming = -hitTiming;
	public var followAngle:Bool = true;

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
	public var curMania:Int = 0; //im watching you, you better not steal this fucking code
	public var changesMania:Bool = false;

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
	var colorShit:Array<Float>;
	var pathToUse:Int = 0;

	public static var pixelAssetPaths:Array<Array<String>> = [ //for noteTypes, epic code cleanup
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
	public var changedSpeed:Bool = false;
	public var velocityData:Array<Float>;
	public var speedMulti:Float = 1;
	public var velocityChangeTime:Float;
	public var startPos:Float = 0;
	var changedVelocityScale:Bool = false;
	public var curAlpha:Float = 1;
	public var split:Bool = false; //split scroll fixing graphic flip shit
	public static var splitFlip:Array<Array<Bool>> = [
		[false, false, true, true, false, false, false, false, false],
		[false, true, false, false, false, true, false, false, true],
		[false, false, false, false, false, true, true, true, true],
		[false, false, true, true, false, false, false, false, false],
		[false, true, false, false, false, true, false, false, true],
		[false, false, false, false, false, true, true, true, true],
		[false, false, false, true, false, false, false, false, false],
		[false, false, false, true, false, false, false, false, false],
		[false, false, false, true, false, false, false, false, false],
	];
	public var beenFlipped:Bool = false;

	////////////////////////////////////////////////////////////

	//event note shit
	public var isGFNote:Bool = false;
	public var eventData:Array<String>; //name + values from chart editor
	public var eventName:String = "";
	public var eventValues:Array<Dynamic>;

	////////////////////////////////////////////////////////////

	public var rawNoteData:Int = 0; //for charter
	public var playedSound:Bool = true;
	public var canPlaySound:Bool = true;
	public var inCharter:Bool = false;
	var charterMulti:Int = 0; //wtf was this used for again???
	public var updated:Bool = true;


	////////////////////////////////////////////////////////////

	//wip note quantization stuff
	public var noteColor:String = "purple";
	public static var usingQuant:Bool = false;
	static var beats:Array<Int> = [4, 8, 12, 16, 24, 32, 48, 64];

	////////////////////////////////////////////////////////////

	public function new(strumTime:Float, _noteData:Int, ?noteType:Int = 0, ?sustainNote:Bool = false, ?_speed:Float = 1, ?_velocityData:Array<Float>, ?charter = false, ?_gfNote, ?_mustPress:Bool = false, ?_eventData:Array<String>, ?prevNote:Note)
	{
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

		velocityData = _velocityData;
		mustPress = _mustPress;
		inCharter = charter;
		if (_eventData != null)
		{
			eventData = _eventData;
		}	


		if (SaveData.randomNoteSpeed)
			speed = FlxMath.roundDecimal(FlxG.random.float(2.2, 3.8), 2);

		if (SaveData.speedScaling)
			speed = FlxMath.roundDecimal((speed / 0.7) * (noteScale * scaleMulti), 2); //adjusts speed based on note size, i should make this an option at some point


		if (!PlayState.rewinding)
			speed = FlxMath.roundDecimal(speed / PlayState.SongSpeedMultiplier, 2);
		else
			speed = FlxMath.roundDecimal(speed, 2);
				
		if (Main.editor)
			this.strumTime = strumTime;
		else 
			this.strumTime = Math.round(strumTime);

		if (this.strumTime < 0 )
			this.strumTime = 0;

		baseStrum = this.strumTime;


		if (velocityData != null)
		{
			speedMulti = _velocityData[0];
			velocityChangeTime = _velocityData[1];
		}
		if (SaveData.randomNoteVelocity)
		{
			speedMulti = FlxMath.roundDecimal(FlxG.random.float(0.5, 2.5), 2);
			velocityChangeTime = FlxMath.roundDecimal(FlxG.random.float(0, 800), 2);
		}

		this.noteData = _noteData % MaxNoteData;



		//note types shit //TODO fix this shit
		isGFNote = _gfNote;

		this.shader = HSV.shader;

		noteTypeCheck();

		//curMania = mania;
		//getCurMania();

		if (!inCharter && SaveData.randomNotes)
			noteData = FlxG.random.int(0, PlayState.keyAmmo[mania] - 1);

		if (isSustainNote && prevNote != null)
			noteData = prevNote.noteData;

		if (!_mustPress)
		{
			if (strumTime >= PlayState.lastP2mChange)
				curMania = PlayState.curP2NoteMania;
			else
				curMania = PlayState.prevP2NoteMania;
			ColorPresets.fixColorArray(mania);
			colorShit = ColorPresets.ccolorArray[noteData];
		}
		else
		{
			if (strumTime >= PlayState.lastP1mChange)
				curMania = PlayState.curP1NoteMania;
			else
				curMania = PlayState.prevP1NoteMania;
			SaveData.fixColorArray(mania);
			colorShit = SaveData.colorArray[noteData];
		}

		scaleToUse = noteScales[curMania];

		if (!isGFNote)
			pathToUse = Std.int(colorShit[3]);

		if (SaveData.middlescroll && !_mustPress && !inCharter)
			scaleMulti = 0.55;

		if (inCharter)
		{
			style = "";
			pathToUse = 0;
		}
		else if (pathToUse == 5)
			style = 'pixel';



		if (mustPress && !inCharter)
		{
			if (((splitFlip[curMania][this.noteData] && mania == 2) || (this.noteData >= (PlayState.keyAmmo[curMania] / 2) && mania != 2))
				&& !inCharter && SaveData.splitScroll)
			{
				this.cameras = [PlayState.instance.camP1NotesSplit];
				split = true;
			}	
			else
				this.cameras = [PlayState.instance.camP1Notes];
		}
		else if (!mustPress && !inCharter)
		{
			if (((splitFlip[curMania][this.noteData] && mania == 2) || (this.noteData >= (PlayState.keyAmmo[curMania] / 2) && mania != 2))
				&& !inCharter && SaveData.P2splitScroll)
			{
				this.cameras = [PlayState.instance.camP2NotesSplit];
				split = true;
			}
			else
				this.cameras = [PlayState.instance.camP2Notes];
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

		downscrollCheck();

		if (normalNote && !isGFNote)
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

		if ((animation.curAnim.name.endsWith('holdend') && prevNote.isSustainNote) && !inCharter)
		{
			isSustainEnd = true;
		}
		else
		{
			isSustainEnd = false;
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
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition && !badNoteType)
				wasGoodHit = true;

			if (sustainHit && strumTime - Conductor.songPosition < -300)
				deleteShit();
		}

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

	function deleteShit():Void
	{
		var strums = "cpu";
		if (PlayState.flipped && !PlayState.multiplayer)
			strums = "player";

		PlayState.instance.removeNote(this, strums);
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
			if (!split)
			{
				beenFlipped = true;
				scale.y *= -1;
			}
				
		}
		else if (split && !isSustainNote)
		{
			scale.y *= -1;
			beenFlipped = true;
		}
			
		
	}

	function quantCheck():Void 
	{
		if (!inCharter && usingQuant && !isSustainNote) //TODO finish this lol
			{
				pathToUse = 4; //use red notes
			
				var beat = Math.round((strumTime % (Conductor.crochet) * 48));
				
				for (i in 0...beats.length)
				{
					if (beat % (192 / beats[i]) == 0)
					{
						beat = beats[i];
						break;
					}			
				}
				trace("beat: " + beat);
				//trace(Conductor.crochet);
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
				healthChangesOnHit = PlayState.fireNoteDamage;
			case "death": 
				PlayState.instance.badNoteHit();
				healthChangesOnHit = PlayState.deathNoteDamage;
			case "bob": 
				PlayState.instance.badNoteHit();
				if (PlayState.multiplayer && !mustPress)
					PlayState.instance.HealthDrain(0);
				else
					PlayState.instance.HealthDrain(1);
			case "poison": 
				PlayState.instance.badNoteHit();
				healthChangesOnHit = PlayState.poisonNoteDamage;
				if (PlayState.multiplayer && !mustPress)
					PlayState.instance.P2Stats.poisonHits++;
				else
					PlayState.instance.P1Stats.poisonHits++;
			case "drain": 
				if (PlayState.multiplayer)
				{
					var statsToUse = PlayState.instance.P1Stats;
					if (!mustPress)
						statsToUse = PlayState.instance.P2Stats;

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
				PlayState.instance.removeNote(this, strums);
				var statsToUse = PlayState.instance.P1Stats;
				if (!mustPress && PlayState.multiplayer)
					statsToUse = PlayState.instance.P2Stats;
				PlayState.instance.badNoteHit();
				statsToUse.health -= PlayState.warningNoteDamage;
				statsToUse.misses++;
			case "glitch": 
				PlayState.instance.removeNote(this, strums);
				var statsToUse = PlayState.instance.P1Stats;
				if (!mustPress && PlayState.multiplayer)
					statsToUse = PlayState.instance.P2Stats;
				PlayState.instance.HealthDrain(playernum);
				PlayState.instance.badNoteHit();
				statsToUse.misses++;
			case "angel": 
				//nothing, they literally do nothing if you miss
			case "burning" | "death" | "bob" | "poison": 
				PlayState.instance.removeNote(this, strums);
			case "regular" | "alt" | "drain": 
				if (isSustainNote && wasGoodHit) //to 100% make sure the sustain is gone
				{
					this.kill();
					PlayState.instance.removeNote(this, strums);
				}
				else
				{
					PlayState.instance.vocals.volume = 0;
					PlayState.instance.noteMiss(this.noteData, this, playernum);								
				}
				PlayState.instance.removeNote(this, strums);
			default: 
				//add custom ntoe tyeps scucppotp 
				PlayState.instance.removeNote(this, strums); //temp
		}
	}

	public function clipSustain(clipTo:FlxPoint)
	{
		var fuckYouRect = new FlxRect(0, 0, width / scale.x, height / scale.y);
		fuckYouRect.y = ((clipTo.y - y) / scale.y);
		fuckYouRect.height -= fuckYouRect.y;
		clipRect = fuckYouRect;

		//clipTo - (y + offset.y * scale.y)
	}
}
