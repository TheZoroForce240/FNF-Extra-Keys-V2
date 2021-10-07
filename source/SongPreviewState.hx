package;


import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import flixel.input.keyboard.FlxKey;
import openfl.Lib;
import flixel.FlxBasic;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.addons.display.FlxGridOverlay;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxSlider;
import flixel.addons.ui.FlxUI;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import Shaders;
import openfl.filters.ShaderFilter;
import flixel.system.FlxSound;
import haxe.Json;
import lime.utils.Assets;
import flixel.util.FlxSort;


using StringTools;


class SongPreviewState extends MusicBeatState 
{                                               
    var bf:Boyfriend;
    var dad:Character;

    private var vocals:FlxSound;
    public static var SONG:SwagSong;

    public static var SongSpeed:Float;

    var strumLine:FlxSprite;
	public static var strumLineNotes:FlxTypedGroup<BabyArrow> = null;
	public static var playerStrums:FlxTypedGroup<BabyArrow> = null;
	public static var cpuStrums:FlxTypedGroup<BabyArrow> = null;
    private var unspawnNotes:Array<Note> = [];
    private var camHUD:FlxCamera;
    private var camNotes:FlxCamera;
    private var camOnTop:FlxCamera;
    private var camGame:FlxCamera;

    var songLength:Float = 0;

    private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;
    var startTimer:FlxTimer;

    public var currentSection:SwagSection;

    var pathList:Array<String> = [
        'noteassets/NOTE_assets',
        'noteassets/PURPLE_NOTE_assets',
        'noteassets/BLUE_NOTE_assets',
        'noteassets/GREEN_NOTE_assets',
        'noteassets/RED_NOTE_assets'
    ];

    var colorText:FlxText;
    var infoText:FlxText;

    var mania:Int = 0;
	private var curSong:String = "";



    public static var maniaToChange = 0;

    private var paused:Bool = false;
	var startedCountdown:Bool = false;

    var frameN:Array<String> = ['purple', 'blue', 'green', 'red'];

    var keyAmmo:Array<Int> = [4, 6, 9, 5, 7, 8, 1, 2, 3];
    private var notes:FlxTypedGroup<Note>;


    var assetList:Array<String> = ["default", "purple", 'blue', 'green', 'red', 'pixel'];



    public override function create()
    {

        if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

        camGame = new FlxCamera();
        camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camNotes = new FlxCamera();
		camNotes.bgColor.alpha = 0;
		camOnTop = new FlxCamera();
		camOnTop.bgColor.alpha = 0;

        FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camNotes);
		FlxG.cameras.add(camOnTop);

        FlxCamera.defaultCameras = [camGame];

        Note.songPreview = true;

		if (SaveData.downscroll) 
		{
			camNotes.flashSprite.scaleY *= -1;
		}

        maniaToChange = 0;
        //Note.noteScale = Note.noteScales[0];
        //Note.swagWidth = Note.noteWidths[0];
        //Note.pixelnoteScale = Note.pixelNoteScales[0];

        FlxG.mouse.visible = true;

        mania = SONG.mania;

        maniaToChange = mania;

		Note.scaleSwitch = true;

        if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

        SongSpeed = FlxMath.roundDecimal(SONG.speed, 2);

        strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

        var pieceArray = ['stageBG', 'stageFront', 'stageCurtains'];
        for (i in 0...pieceArray.length) //x and y are optional and set in StagePiece.hx, so epic for loop can be used
        {
            var piece:StagePiece = new StagePiece(0, 0, pieceArray[i]);
            piece.x += piece.newx;
            piece.y += piece.newy;
            add(piece);
        }

        var camFollow = new FlxObject(0, 0, 1, 1);
        dad = new Character(100, 100, 'dad');
        add(dad);

        bf = new Boyfriend(770, 450, 'bf');
        add(bf);

        generateSong(SONG.song);

        var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x + 400, dad.getGraphicMidpoint().y);

		camFollow.setPosition(camPos.x, camPos.y);

        FlxG.camera.follow(camFollow, LOCKON, 0.01);
		FlxG.camera.zoom = 0.9;
		FlxG.camera.focusOn(camFollow.getPosition());

        strumLineNotes = new FlxTypedGroup<BabyArrow>();
		add(strumLineNotes);
		playerStrums = new FlxTypedGroup<BabyArrow>();
        cpuStrums = new FlxTypedGroup<BabyArrow>();

		strumLineNotes.cameras = [camNotes];
		notes.cameras = [camNotes];

        
        startingSong = true;

        startCountdown();

        trace('created');

        super.create();
    }
	function sortByShit(Obj1:Note, Obj2:Note):Int
        {
            return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
        }

    function startCountdown():Void
    {

        generateStaticArrows(0);
        generateStaticArrows(1);
        trace('created static bois');

       
        trace('starting countdown');
        startedCountdown = true;
        Conductor.songPosition = 0;
        Conductor.songPosition -= Conductor.crochet * 5;

        var swagCounter:Int = 0;

        startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
        {

            var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
            introAssets.set('default', ['ready', "set", "go"]);
            introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
            introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

            var introAlts:Array<String> = introAssets.get('default');
            var altSuffix:String = "";

            switch (swagCounter)

            {
                case 0:
                    FlxG.sound.play(Paths.sound('intro3'), 0.6);
                case 1:
                    var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
                    ready.scrollFactor.set();
                    ready.updateHitbox();


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
        }, 5);
    }

    var previousFrameTime:Int = 0;
    var lastReportedPlayheadPosition:Int = 0;
    var songTime:Float = 0;
    var songStarted = false;
    function startSong():Void
        {
            trace('starting song');
            startingSong = false;
            songStarted = true;
    
            previousFrameTime = FlxG.game.ticks;
            lastReportedPlayheadPosition = 0;
    
            if (!paused)
                FlxG.sound.playMusic(Paths.inst(SongPreviewState.SONG.song), 1, false);
    
            //FlxG.sound.music.onComplete = endSong;
            vocals.play();
        }
        private function generateSong(dataPath:String):Void
            {
                // FlxG.log.add(ChartParser.parse());
        
                var songData = SONG;
                Conductor.changeBPM(songData.bpm);
        
                curSong = songData.song;
        
                if (SONG.needsVoices)
                    vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
                else
                    vocals = new FlxSound();
        
                FlxG.sound.list.add(vocals);
        
                notes = new FlxTypedGroup<Note>();
                add(notes);
        
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
        
                        var swagNote:Note = new Note(daStrumTime, daNoteData, daType, false, daSpeed, daVelocityData, gottaHitNote, oldNote);
                        swagNote.sustainLength = songNotes[2];
                        swagNote.scrollFactor.set(0, 0);
                        swagNote.startPos = calculateStrumtime(swagNote, daStrumTime);
        
                        var susLength:Float = swagNote.sustainLength;
        
                        susLength = susLength / Conductor.stepCrochet;
                        unspawnNotes.push(swagNote);
        
                        if (susLength > 0)
                            swagNote.isParent = true;
        
                        var type = 0;
        
                        for (susNote in 0...Math.floor(susLength))
                        {
                            oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
                            var susStrum = daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet;
        
                            var sustainNote:Note = new Note(susStrum, daNoteData, daType, true, daSpeed, daVelocityData, gottaHitNote, oldNote);
                            sustainNote.scrollFactor.set();
                            unspawnNotes.push(sustainNote);
                            sustainNote.startPos = calculateStrumtime(sustainNote, susStrum);
        
                            sustainNote.mustPress = gottaHitNote;
        
                            if (sustainNote.mustPress)
                            {
                                sustainNote.x += FlxG.width / 2; // general offset
                            }
                            sustainNote.parent = swagNote;
                            swagNote.children.push(sustainNote);
                            sustainNote.spotInLine = type;
                            type++;
                        }
        
                        swagNote.mustPress = gottaHitNote;
        
                        if (swagNote.mustPress)
                        {
                            swagNote.x += FlxG.width / 2; // general offset
                        }
                        else {}
                    }
                    daBeats += 1;
                }
        
                unspawnNotes.sort(sortByShit);
        
                generatedMusic = true;
            }

    private function generateStaticArrows(player:Int):Void
        {
            for (i in 0...keyAmmo[mania])
            {
                var style:String = "normal";
    
                var babyArrow:BabyArrow = new BabyArrow(strumLine.y, player, i, style, true);
    
                babyArrow.ID = i;
    
                switch (player)
                {
                    case 0:
                        //if (PlayStateChangeables.bothSide)
                            //babyArrow.x -= 500;
                    case 1:
                        playerStrums.add(babyArrow);
                }

        
                strumLineNotes.add(babyArrow);
            }
        }

    function resyncVocals():Void
        {
            vocals.pause();
    
            FlxG.sound.music.play();
            Conductor.songPosition = FlxG.sound.music.time;
            vocals.time = Conductor.songPosition;
            vocals.play();
            generatedMusic = true;
        }

    function calculateStrumtime(daNote:Note, Strumtime:Float)
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

    override function update(elapsed:Float)
        {
            super.update(elapsed);

            if (FlxG.keys.justPressed.BACKSPACE || FlxG.keys.justPressed.ESCAPE)
            {
                FlxG.sound.play(Paths.sound('cancelMenu'));
                FlxG.switchState(new MainMenuState());
                FlxG.mouse.visible = false;
            }

            if (paused)
                {
                    if (FlxG.sound.music != null)
                    {
                        FlxG.sound.music.pause();
                        vocals.pause();
                        generatedMusic = false;
                    }
                }
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
            if (unspawnNotes[0] != null)
                {
                    if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500)
                    {
                        var dunceNote:Note = unspawnNotes[0];
                        notes.add(dunceNote);
        
                        var index:Int = unspawnNotes.indexOf(dunceNote);
                        unspawnNotes.splice(index, 1);
                    }
                }

            if (generatedMusic)
            {
                notes.forEachAlive(function(daNote:Note)
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
        
                        var WasGoodHit:Bool = daNote.wasGoodHit; //so it doesnt have to check multiple times
                        var IsSustainNote:Bool = daNote.isSustainNote; //its running this shit every frame for every note
                        var MustPress:Bool = daNote.mustPress;
                        var CanBeHit:Bool = daNote.canBeHit;
                        var TooLate:Bool = daNote.tooLate;
                        var NoteData:Int = daNote.noteData;
                        
                        if (daNote.mustPress) //playerStrums
                        {
                            NoteX = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
                            NoteY = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y;
                            NoteAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
                            NoteAlpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
                            NoteVisible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
                        }
                        else //cpuStrums
                        {
                            NoteX = cpuStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
                            NoteY = cpuStrums.members[Math.floor(Math.abs(daNote.noteData))].y;
                            NoteAngle = cpuStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
                            NoteAlpha = cpuStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
                            NoteVisible = cpuStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
                        }
                        var MiddleOfNote:Float = NoteY + Note.swagWidth / 2;
                        var NoteStrumTime:Float = Conductor.songPosition - daNote.strumTime;

                        var OverallSpeed:Float = FlxMath.roundDecimal(daNote.speed, 2);
                        var calculatedStrumtime = calculateStrumtime(daNote, Conductor.songPosition);
                                
                        daNote.y = (NoteY + 0.45 * (daNote.startPos - calculatedStrumtime)) + daNote.sustainOffset + daNote.sustainEndOffset;
                        if (IsSustainNote)
                            daNote.y -= daNote.height;
                        if (daNote.isSustainEnd)
                            daNote.y -= daNote.height;
                            
                        // i am so fucking sorry for this if condition
                        if (IsSustainNote
                            && daNote.y + daNote.offset.y <= MiddleOfNote
                            && (!MustPress || (WasGoodHit || (daNote.prevNote.wasGoodHit && !CanBeHit))))
                        {
                            var swagRect = new FlxRect(0, MiddleOfNote - daNote.y, daNote.width * 2, daNote.height * 2);
                            swagRect.y /= daNote.scale.y;
                            swagRect.height -= swagRect.y;
        
                            daNote.clipRect = swagRect;
                        }
        
                        daNote.x = NoteX;
                        daNote.visible = NoteVisible;
                        if (IsSustainNote)
                        {
                            daNote.alpha = NoteAlpha * 0.6;
        
                            daNote.x += daNote.width / 2 + 20;
                            if (daNote.style == 'pixel')
                                daNote.x -= 11;
                        }
                        else
                        {
                            daNote.alpha = NoteAlpha;
                            daNote.angle = NoteAngle;
                        }
                        if (SaveData.downscroll && (daNote.burning || daNote.death || daNote.warning || daNote.angel || daNote.bob || daNote.glitch))
                            daNote.y += 75; //y offset of notetypes  (only downscroll for some reason)
        
                        // WIP interpolation shit? Need to fix the pause issue
                        // daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));
                    });
            }
                
            



        }
    override function beatHit()
        {
            super.beatHit();
    
            if (generatedMusic)
            {
                notes.sort(FlxSort.byY, FlxSort.DESCENDING);
            }
            if (currentSection != null)
                {
                    if (currentSection.changeBPM)
                    {
                        Conductor.changeBPM(currentSection.bpm);
                        FlxG.log.add('CHANGED BPM!');
                    }
                }
        }
}