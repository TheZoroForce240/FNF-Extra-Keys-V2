package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end
import PlayState;
import Shaders;

using StringTools;

class Note extends FlxSprite //so many vars ahhhhhhhhhhhhhhhhhh
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
	public var prevNote:Note;
	
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var isSustainEnd:Bool = false;

	public var noteColor:Int;
	public static var MaxNoteData:Int = 9; // :troll:

	var HSV:HSVEffect = new HSVEffect();

	////////////////////////////////////////////////////////////

	//note type shit
	public var noteType:Int = 0;

	public var regular:Bool = false; //just a regular note
	public var burning:Bool = false; //fire
	public var death:Bool = false; //halo/death
	public var warning:Bool = false; //warning
	public var angel:Bool = false; //angel
	public var alt:Bool = false; //alt animation note
	public var bob:Bool = false; //bob arrow
	public var glitch:Bool = false; //glitch
	public var poison:Bool = false; //poison notes
	public var drain:Bool = false; //health drain notes

	public var normalNote:Bool = true; //just to make checking easier i guess
	public var warningNoteType:Bool = false;
	public var badNoteType:Bool = false;

	////////////////////////////////////////////////////////////

	//extra shit idk where to put
	public var noteScore:Float = 1;
	public var rating:String = "shit";
	public var scaleMulti:Float = 1; //for middlescroll
	public var daShit:Int = 0; //this is just for note data and anim shit that was annoying me
	public var earlyHitTiming = 145;
	public var lateHitTiming = -145;

	////////////////////////////////////////////////////////////

	//mania shit
	public static var mania:Int = 0; 
	public static var swagWidth:Float = 160 * 0.7;
	public static var noteScale:Float;
	public static var newNoteScale:Float = 0;
	public static var prevNoteScale:Float = 0.5;
	public static var pixelnoteScale:Float;
	public static var scaleSwitch:Bool = true;
	public static var tooMuch:Float = 30;

	public static var noteScales:Array<Float> = [0.7, 0.6, 0.5, 0.65, 0.58, 0.55, 0.7, 0.7, 0.7];
	public static var pixelNoteScales:Array<Float> = [1, 0.83, 0.7, 0.9, 0.8, 0.74, 1, 1, 1];
	public static var noteWidths:Array<Float> = [112, 84, 66.5, 91, 77, 70, 140, 126, 119];
	public static var sustainXOffsets:Array<Float> = [97, 84, 70, 91, 77, 78, 97, 97, 97];

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
	var GFframeN:Array<String> = ['purple', 'blue', 'green', 'red']; //gf cant have more than 4k

	////////////////////////////////////////////////////////////

	//note asset shit
	var pathList:Array<String> = [
        'noteassets/NOTE_assets',
        'noteassets/PURPLE_NOTE_assets',
        'noteassets/BLUE_NOTE_assets',
        'noteassets/GREEN_NOTE_assets',
        'noteassets/RED_NOTE_assets'
    ];
	public var style:String = "";
	public var noteColors:Array<String> = ['purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'darkred', 'dark'];
	var colorShit:Array<Float>;
	var pathToUse:Int = 0;

	////////////////////////////////////////////////////////////

	public var speed:Float = 1; //note speed and velocity shit
	public var changedSpeed:Bool = false;
	public var velocityData:Array<Float>;
	public var speedMulti:Float = 1;
	public var velocityChangeTime:Float;
	public var startPos:Float = 0;
	var changedVelocityScale:Bool = false;

	////////////////////////////////////////////////////////////

	//event note shit (well it will go here when i add it)
	public var isGFNote:Bool = false;

	////////////////////////////////////////////////////////////

	public var rawNoteData:Int = 0; //for charter
	public var playedSound:Bool = true;
	public var canPlaySound:Bool = true;
	public var inCharter:Bool = false;
	var charterMulti:Int = 0; //wtf was this used for again???

	////////////////////////////////////////////////////////////

	public function new(strumTime:Float, _noteData:Int, ?noteType:Int = 0, ?sustainNote:Bool = false, ?_speed:Float = 1, ?_velocityData:Array<Float>, ?charter = false, ?_gfNote, ?_mustPress:Bool = false, ?prevNote:Note)
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

		if (SaveData.randomNoteSpeed)
			speed = FlxMath.roundDecimal(FlxG.random.float(2.2, 3.8), 2);

		if (SaveData.speedScaling)
			speed = FlxMath.roundDecimal((speed / 0.7) * (noteScale * scaleMulti), 2); //adjusts speed based on note size, i should make this an option at some point

		x += 50;
		if (PlayState.SONG.mania == 2)
		{
			x -= tooMuch; //moves notes a little to the left on 9k
		}


		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		if (Main.editor)
			this.strumTime = strumTime;
		else 
			this.strumTime = Math.round(strumTime);

		if (this.strumTime < 0 )
			this.strumTime = 0;


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
		daShit = noteData;

		//note types shit
		regular = noteType == 0;
		burning = noteType == 1;
		death = noteType == 2;
		warning = noteType == 3;
		angel = noteType == 4;
		alt = noteType == 5;
		bob = noteType == 6;
		glitch = noteType == 7;
		poison = noteType == 8;
		drain = noteType == 9;
		isGFNote = _gfNote;

		this.shader = HSV.shader;

		if (!regular && !alt)
			normalNote = false;

		if (warning || glitch || angel)
			warningNoteType = true;
		else if (burning || death || bob || poison)
			badNoteType = true;

		if (!_mustPress)
		{
			ColorPresets.fixColorArray(mania);
			colorShit = ColorPresets.ccolorArray[noteData];
		}
		else
		{
			SaveData.fixColorArray(mania);
			colorShit = SaveData.colorArray[noteData];
		}

		if (!isGFNote)
			pathToUse = Std.int(colorShit[3]);

		if (pathToUse == 5)
			style = 'pixel';

		if (SaveData.middlescroll && !_mustPress && !inCharter)
			scaleMulti = 0.55;


		switch (style)
		{
			case 'pixel':
				loadGraphic(Paths.image('noteassets/pixel/arrows-pixels'), true, 17, 17);
				if (isSustainNote && noteType == 0)
					loadGraphic(Paths.image('noteassets/pixel/arrowEnds'), true, 7, 6);

				for (i in 0...9)
				{
					animation.add(noteColors[i] + 'Scroll', [i + 9]); // Normal notes
					animation.add(noteColors[i] + 'hold', [i]); // Holds
					animation.add(noteColors[i] + 'holdend', [i + 9]); // Tails
				}
				if (burning)
					{
						loadGraphic(Paths.image('noteassets/pixel/firenotes/arrows-pixels'), true, 17, 17);
						if (isSustainNote && burning)
							loadGraphic(Paths.image('noteassets/pixel/firenotes/arrowEnds'), true, 7, 6);
						for (i in 0...9)
							{
								animation.add(noteColors[i] + 'Scroll', [i + 9]); // Normal notes
								animation.add(noteColors[i] + 'hold', [i]); // Holds
								animation.add(noteColors[i] + 'holdend', [i + 9]); // Tails
							}
					}
				else if (death)
					{
						loadGraphic(Paths.image('noteassets/pixel/halo/arrows-pixels'), true, 17, 17);
						if (isSustainNote && death)
							loadGraphic(Paths.image('noteassets/pixel/halo/arrowEnds'), true, 7, 6);
						for (i in 0...9)
							{
								animation.add(noteColors[i] + 'Scroll', [i + 9]); // Normal notes
								animation.add(noteColors[i] + 'hold', [i]); // Holds
								animation.add(noteColors[i] + 'holdend', [i + 9]); // Tails
							}
					}
				else if (warning)
					{
						loadGraphic(Paths.image('noteassets/pixel/warning/arrows-pixels'), true, 17, 17);
						if (isSustainNote && warning)
							loadGraphic(Paths.image('noteassets/pixel/warning/arrowEnds'), true, 7, 6);
						for (i in 0...9)
							{
								animation.add(noteColors[i] + 'Scroll', [i + 9]); // Normal notes
								animation.add(noteColors[i] + 'hold', [i]); // Holds
								animation.add(noteColors[i] + 'holdend', [i + 9]); // Tails
							}
					}
				else if (angel)
					{
						loadGraphic(Paths.image('noteassets/pixel/angel/arrows-pixels'), true, 17, 17);
						if (isSustainNote && angel)
							loadGraphic(Paths.image('noteassets/pixel/angel/arrowEnds'), true, 7, 6);
						for (i in 0...9)
							{
								animation.add(noteColors[i] + 'Scroll', [i + 9]); // Normal notes
								animation.add(noteColors[i] + 'hold', [i]); // Holds
								animation.add(noteColors[i] + 'holdend', [i + 9]); // Tails
							}
					}
				else if (bob)
					{
						loadGraphic(Paths.image('noteassets/pixel/bob/arrows-pixels'), true, 17, 17);
						if (isSustainNote && bob)
							loadGraphic(Paths.image('noteassets/pixel/bob/arrowEnds'), true, 7, 6);
						for (i in 0...9)
							{
								animation.add(noteColors[i] + 'Scroll', [i + 9]); // Normal notes
								animation.add(noteColors[i] + 'hold', [i]); // Holds
								animation.add(noteColors[i] + 'holdend', [i + 9]); // Tails
							}
					}
				else if (glitch)
					{
						loadGraphic(Paths.image('noteassets/pixel/glitch/arrows-pixels'), true, 17, 17);
						if (isSustainNote && glitch)
							loadGraphic(Paths.image('noteassets/pixel/glitch/arrowEnds'), true, 7, 6);
						for (i in 0...9)
							{
								animation.add(noteColors[i] + 'Scroll', [i + 9]); // Normal notes
								animation.add(noteColors[i] + 'hold', [i]); // Holds
								animation.add(noteColors[i] + 'holdend', [i + 9]); // Tails
							}
					}

				

				setGraphicSize(Std.int(width * PlayState.daPixelZoom * pixelnoteScale * scaleMulti));
				updateHitbox();
			default:
				frames = Paths.getSparrowAtlas(pathList[pathToUse]);
				for (i in 0...9)
					{
						animation.addByPrefix(noteColors[i] + 'Scroll', noteColors[i] + '0'); // Normal notes
						animation.addByPrefix(noteColors[i] + 'hold', noteColors[i] + ' hold piece'); // Hold
						animation.addByPrefix(noteColors[i] + 'holdend', noteColors[i] + ' hold end'); // Tails
					}
				if (!normalNote)
					{
						frames = Paths.getSparrowAtlas('noteassets/notetypes/NOTE_types');
						switch(noteType)
						{
							case 1: 
								for (i in 0...9)
									{
										animation.addByPrefix(noteColors[i] + 'Scroll', 'fire ' + noteColors[i] + '0'); // Normal notes
										animation.addByPrefix(noteColors[i] + 'hold', 'fire hold piece'); // Hold
										animation.addByPrefix(noteColors[i] + 'holdend', 'fire hold end'); // Tails
									}
							case 2: 
								for (i in 0...9)
									{
										animation.addByPrefix(noteColors[i] + 'Scroll', 'halo ' + noteColors[i] + '0'); // Normal notes
										animation.addByPrefix(noteColors[i] + 'hold', 'halo hold piece'); // Hold
										animation.addByPrefix(noteColors[i] + 'holdend', 'halo hold end'); // Tails
									}
							case 3: 
								for (i in 0...9)
									{
										animation.addByPrefix(noteColors[i] + 'Scroll', 'warning ' + noteColors[i] + '0'); // Normal notes
										animation.addByPrefix(noteColors[i] + 'hold', 'warning hold piece'); // Hold
										animation.addByPrefix(noteColors[i] + 'holdend', 'warning hold end'); // Tails
									}
							case 4: 
								for (i in 0...9)
									{
										animation.addByPrefix(noteColors[i] + 'Scroll', 'angel ' + noteColors[i] + '0'); // Normal notes
										animation.addByPrefix(noteColors[i] + 'hold', 'angel hold piece'); // Hold
										animation.addByPrefix(noteColors[i] + 'holdend', 'angel hold end'); // Tails
									}
							case 6: 
								for (i in 0...9)
									{
										animation.addByPrefix(noteColors[i] + 'Scroll', 'bob ' + noteColors[i] + '0'); // Normal notes
										animation.addByPrefix(noteColors[i] + 'hold', 'bob hold piece'); // Hold
										animation.addByPrefix(noteColors[i] + 'holdend', 'bob hold end'); // Tails
									}
							case 7:
								for (i in 0...9)
									{
										animation.addByPrefix(noteColors[i] + 'Scroll', 'glitch ' + noteColors[i] + '0'); // Normal notes
										animation.addByPrefix(noteColors[i] + 'hold', 'glitch hold piece'); // Hold
										animation.addByPrefix(noteColors[i] + 'holdend', 'glitch hold end'); // Tails
									}
							case 8:
								frames = Paths.getSparrowAtlas('noteassets/notetypes/poison');
								for (i in 0...9)
									{
										animation.addByPrefix(noteColors[i] + 'Scroll', 'poison ' + noteColors[i] + '0'); // Normal notes
										animation.addByPrefix(noteColors[i] + 'hold', 'poison hold piece'); // Hold
										animation.addByPrefix(noteColors[i] + 'holdend', 'poison hold end'); // Tails
									}
							case 9:
								frames = Paths.getSparrowAtlas('noteassets/notetypes/drain'); //i forgot to change xml for drain notes lol, thats why it says poison
								for (i in 0...9)
									{
										animation.addByPrefix(noteColors[i] + 'Scroll', 'poison ' + noteColors[i] + '0'); // Normal notes
										animation.addByPrefix(noteColors[i] + 'hold', 'poison hold piece'); // Hold
										animation.addByPrefix(noteColors[i] + 'holdend', 'poison hold end'); // Tails
									}
						}
					}


				setGraphicSize(Std.int(width * noteScale * scaleMulti));
				updateHitbox();
				antialiasing = true;
		}
		if (normalNote && !isGFNote)
		{
			HSV.hue = colorShit[0];
			HSV.saturation = colorShit[1];
			HSV.brightness = colorShit[2];
			HSV.update();
		}



		x += swagWidth * noteData;
		if (inCharter) //this shit took so long to figure out, most of it is in charting state
		{
			if (isGFNote)
				animation.play(GFframeN[daShit] + 'Scroll');
			else
			{
				animation.play(frameN[mania][daShit] + 'Scroll');
			}
		}
		/*if (isGFNote)
			animation.play(GFframeN[daShit + 4] + 'Scroll'); //just for chart editor
		else if (inCharter)
			animation.play(frameN[(daShit - 4) + PlayState.keyAmmo[mania] % 9] + 'Scroll'); //just for chart editor*/
		else
		{
			animation.play(frameN[mania][daShit] + 'Scroll');
		}	
			
		noteColor = noteData;

		if (isSustainNote && prevNote != null)
		{
			speed = prevNote.speed;
			speedMulti = prevNote.speedMulti;
			velocityChangeTime = prevNote.velocityChangeTime;
			noteScore * 0.2;
			alpha = 0.6;

			earlyHitTiming = 75;

			x += width / 2;

			//setGraphicSize(Std.int(width * 2));

			
			animation.play(frameN[mania][daShit] + 'holdend');

			updateHitbox();

			x -= width / 2;

			if (PlayState.curStage.startsWith('school'))
				x += 30;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(frameN[mania][prevNote.daShit] + 'hold');
				prevNote.updateHitbox();
				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * speed * (0.7 / (noteScale * scaleMulti));
				prevNote.updateHitbox();

				//prevNote.sustainOffset = Math.round(-prevNote.offset.y);
				//sustainOffset = Math.round(-offset.y);

			}

			//scale.y *= Conductor.stepCrochet / 100 * 1.5 * speed * speedMulti * (0.7 / (noteScale * scaleMulti));
			//updateHitbox(); //just testin stuff


		}

		if (((SaveData.downscroll && _mustPress && !isSustainNote) || 
			(SaveData.P2downscroll && !_mustPress && !isSustainNote)) && 
			!inCharter)
		{
			scale.y *= -1;
		}
			
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if ((animation.curAnim.name.endsWith('holdend') && prevNote.isSustainNote) && !isGFNote)
		{
			isSustainEnd = true;
		}
		else
		{
			isSustainEnd = false;
		}
		/*if (animation.curAnim.name != frameN[noteData] + "Scroll" && animation.curAnim.name.endsWith('Scroll')) //this fixes the note colors when they switch
			animation.play(frameN[noteData] + 'Scroll');
			
		if (animation.curAnim.name != frameN[noteData] + "hold" && animation.curAnim.name.endsWith('hold'))
			animation.play(frameN[noteData] + 'hold');

		if (animation.curAnim.name != frameN[noteData] + "holdend" && animation.curAnim.name.endsWith('holdend'))
			animation.play(frameN[noteData] + 'holdend');*/

		if (!scaleSwitch)
			{
				if (!isSustainNote && noteType == 0)
					setGraphicSize(Std.int((width / prevNoteScale) * newNoteScale)); //this fixes the note scale
				else if (!isSustainNote && noteType != 0)
				{
					//setGraphicSize(Std.int((width / prevNoteScale) * newNoteScale)); //they smal for some reason
					//updateHitbox();
				}
				


				switch(PlayState.maniaToChange)
				{
					case 10: 
						switch (noteColor)
						{
							case 0: 
								noteData = 0;
							case 1: 
								noteData = 1;
							case 2: 
								noteData = 2;
							case 3: 
								noteData = 3;
							case 4: 
								noteData = 2;
							case 5: 
								noteData = 0;
							case 6: 
								noteData = 1;
							case 7:
								noteData = 2;
							case 8:
								noteData = 3;
						}

					case 11: 
						switch (noteColor)
						{
							case 0: 
								noteData = 0;
							case 1: 
								noteData = 1;
							case 2: 
								noteData = 2;
							case 3: 
								noteData = 3;
							case 4: 
								noteData = 2;
							case 5: 
								noteData = 5;
							case 6: 
								noteData = 1;
							case 7:
								noteData = 2;
							case 8:
								noteData = 8;
						}

					case 12: 
						switch (noteColor)
						{
							case 0: 
								noteData = 0;
							case 1: 
								noteData = 1;
							case 2: 
								noteData = 2;
							case 3: 
								noteData = 3;
							case 4: 
								noteData = 4;
							case 5: 
								noteData = 5;
							case 6: 
								noteData = 6;
							case 7:
								noteData = 7;
							case 8:
								noteData = 8;
						}
					case 13: 
						switch (noteColor)
						{
							case 0: 
								noteData = 0;
							case 1: 
								noteData = 1;
							case 2: 
								noteData = 2;
							case 3: 
								noteData = 3;
							case 4: 
								noteData = 4;
							case 5: 
								noteData = 0;
							case 6: 
								noteData = 1;
							case 7:
								noteData = 2;
							case 8:
								noteData = 3;
						}


					case 14: 
						switch (noteColor)
						{
							case 0: 
								noteData = 0;
							case 1: 
								noteData = 1;
							case 2: 
								noteData = 2;
							case 3: 
								noteData = 3;
							case 4: 
								noteData = 4;
							case 5: 
								noteData = 5;
							case 6: 
								noteData = 1;
							case 7:
								noteData = 2;
							case 8:
								noteData = 8;
						}


					case 15: 
						switch (noteColor)
						{
							case 0: 
								noteData = 0;
							case 1: 
								noteData = 1;
							case 2: 
								noteData = 2;
							case 3: 
								noteData = 3;
							case 4: 
								noteData = 2;
							case 5: 
								noteData = 5;
							case 6: 
								noteData = 6;
							case 7:
								noteData = 7;
							case 8:
								noteData = 8;
						}


					case 16: 
						noteData = 4;
					case 17: 
						switch (noteColor)
						{
							case 0: 
								noteData = 0;
							case 1: 
								noteData = 0;
							case 2: 
								noteData = 3;
							case 3: 
								noteData = 3;
							case 4: 
								noteData = 0;
							case 5: 
								noteData = 0;
							case 6: 
								noteData = 0;
							case 7:
								noteData = 3;
							case 8:
								noteData = 3;
						}


					case 18: 
						switch (noteColor)
						{
							case 0: 
								noteData = 0;
							case 1: 
								noteData = 0;
							case 2: 
								noteData = 4;
							case 3: 
								noteData = 3;
							case 4: 
								noteData = 4;
							case 5: 
								noteData = 0;
							case 6: 
								noteData = 0;
							case 7:
								noteData = 4;
							case 8:
								noteData = 3;
						}


				}
				//scaleSwitch = true;
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
		}

		if (isGFNote)
			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		else if (badNoteType)
			if (strumTime - Conductor.songPosition < -300) //so note types go past the strumline before removed
				wasGoodHit = true;

		if (!changedVelocityScale)
			if (speedMulti != 0 || speedMulti != 1)
				if ((strumTime - velocityChangeTime) <= Conductor.songPosition)
						fixSustains();
				

		if (tooLate && !wasGoodHit)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}



	function fixSustains():Void
	{
		if (!changedVelocityScale)
		{
			changedVelocityScale = true;
			if (animation.curAnim.name.endsWith('hold') && isSustainNote)
				{
					scale.y *= speedMulti;
					updateHitbox();
				}
		}

	} 
}
