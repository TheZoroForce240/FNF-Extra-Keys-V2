package;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.FlxObject;

class NoteTypeOffsetState extends MusicBeatState
{


    private var camGame:FlxCamera;
    private var upscroll:FlxCamera;
    private var downscroll:FlxCamera;

    var curNoteType:Int = 0;
    var curOffset:Int = 0;

    var shitWidth:Float = 160 * 0.7;
    var shitScale:Float = 0.7;
    private var notes:FlxTypedGroup<FlxSprite>; //daNotes
    private var noteTypes:FlxTypedGroup<FlxSprite>; //daNotes

    var useDownscroll:Bool = true;

    var shitText:FlxText;

    var frameN = ['purple', 'blue', 'green', 'red', 'white', 'purple', 'blue', 'green', 'red', 'white'];
    public var noteColors:Array<String> = ['purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'darkred', 'dark'];

    public override function create()
    {
        camGame = new FlxCamera();
        FlxCamera.defaultCameras = [camGame];
        upscroll = new FlxCamera();
		upscroll.bgColor.alpha = 0;
		downscroll = new FlxCamera();
		downscroll.bgColor.alpha = 0;

        FlxCamera.defaultCameras = [camGame];

        FlxG.cameras.reset(camGame);
		FlxG.cameras.add(upscroll);
		FlxG.cameras.add(downscroll);

        var camFollow = new FlxObject(0, 0, 1, 1); //just some more shit from playstate

		camFollow.setPosition(0, 0);

        FlxG.camera.follow(camFollow, LOCKON, 0.01);
		FlxG.camera.zoom = 0.9;
		FlxG.camera.focusOn(camFollow.getPosition());

        
        notes = new FlxTypedGroup<FlxSprite>();
		add(notes);
        
        noteTypes = new FlxTypedGroup<FlxSprite>();
		add(noteTypes);

        shitText = new FlxText(50, 230, 0, "Current Note Type: " + curNoteType, 24);
        shitText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, RIGHT);
        add(shitText);


        downscroll.flashSprite.scaleY *= -1;

        createDownscrollNotes();

        super.create();
    }




    function createDownscrollNotes()
    {
        notes.clear();
        noteTypes.clear();
        notes.cameras = [downscroll];
        noteTypes.cameras = [downscroll];
        for (i in 0...9)
        {
            var daType = 0;
            if (i > 3)
                daType = curNoteType;

            var daNote:FlxSprite = new FlxSprite(50 + (shitWidth * i), 400);
            animationShit(daNote, daType, i);

            daNote.scale.y *= -1;
            if (i > 3)
                noteTypes.add(daNote);
            else
                notes.add(daNote);
        }
    }
    function createUpscrollNotes()
    {
        notes.clear();
        noteTypes.clear();
        notes.cameras = [upscroll];
        noteTypes.cameras = [upscroll];
        for (i in 0...9)
        {
            var daType = 0;
            if (i > 3)
                daType = curNoteType;

            var daNote:FlxSprite = new FlxSprite(50 + (shitWidth * i), 400);
            animationShit(daNote, daType, i);
            if (i > 3)
                noteTypes.add(daNote);
            else
                notes.add(daNote);
        }
    }

    function animationShit(spr:FlxSprite, noteType:Int = 0, i:Int)
    {
        spr.frames = Paths.getSparrowAtlas('noteassets/NOTE_assets');
        for (i in 0...9)
            {
                spr.animation.addByPrefix(noteColors[i] + 'Scroll', noteColors[i] + '0'); // Normal notes
                spr.animation.addByPrefix(noteColors[i] + 'hold', noteColors[i] + ' hold piece'); // Hold
                spr.animation.addByPrefix(noteColors[i] + 'holdend', noteColors[i] + ' hold end'); // Tails
            }
        if (noteType != 0 && noteType != 5)
            {
                spr.frames = Paths.getSparrowAtlas('noteassets/notetypes/NOTE_types');
                switch(noteType)
                {
                    case 1: 
                        for (i in 0...9)
                            {
                                spr.animation.addByPrefix(noteColors[i] + 'Scroll', 'fire ' + noteColors[i] + '0'); // Normal notes
                                spr.animation.addByPrefix(noteColors[i] + 'hold', 'fire hold piece'); // Hold
                                spr.animation.addByPrefix(noteColors[i] + 'holdend', 'fire hold end'); // Tails
                            }
                    case 2: 
                        for (i in 0...9)
                            {
                                spr.animation.addByPrefix(noteColors[i] + 'Scroll', 'halo ' + noteColors[i] + '0'); // Normal notes
                                spr.animation.addByPrefix(noteColors[i] + 'hold', 'halo hold piece'); // Hold
                                spr.animation.addByPrefix(noteColors[i] + 'holdend', 'halo hold end'); // Tails
                            }
                    case 3: 
                        for (i in 0...9)
                            {
                                spr.animation.addByPrefix(noteColors[i] + 'Scroll', 'warning ' + noteColors[i] + '0'); // Normal notes
                                spr.animation.addByPrefix(noteColors[i] + 'hold', 'warning hold piece'); // Hold
                                spr.animation.addByPrefix(noteColors[i] + 'holdend', 'warning hold end'); // Tails
                            }
                    case 4: 
                        for (i in 0...9)
                            {
                                spr.animation.addByPrefix(noteColors[i] + 'Scroll', 'angel ' + noteColors[i] + '0'); // Normal notes
                                spr.animation.addByPrefix(noteColors[i] + 'hold', 'angel hold piece'); // Hold
                                spr.animation.addByPrefix(noteColors[i] + 'holdend', 'angel hold end'); // Tails
                            }
                    case 6: 
                        for (i in 0...9)
                            {
                                spr.animation.addByPrefix(noteColors[i] + 'Scroll', 'bob ' + noteColors[i] + '0'); // Normal notes
                                spr.animation.addByPrefix(noteColors[i] + 'hold', 'bob hold piece'); // Hold
                                spr.animation.addByPrefix(noteColors[i] + 'holdend', 'bob hold end'); // Tails
                            }
                    case 7:
                        for (i in 0...9)
                            {
                                spr.animation.addByPrefix(noteColors[i] + 'Scroll', 'glitch ' + noteColors[i] + '0'); // Normal notes
                                spr.animation.addByPrefix(noteColors[i] + 'hold', 'glitch hold piece'); // Hold
                                spr.animation.addByPrefix(noteColors[i] + 'holdend', 'glitch hold end'); // Tails
                            }
                }
            }
        spr.animation.play(frameN[i] + 'Scroll');
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        shitText.text = "current note type: " + curNoteType + "\npress left and right to change note type\ncurrent Y offset: " + curOffset + "\npress up and down to change offset (this wont save, just to be used as a guide)";

        if (FlxG.keys.justPressed.ESCAPE)
        {
            FlxG.switchState(new DebugState());
        }
            

        if (FlxG.keys.justPressed.SPACE)
        {
            if (useDownscroll)
            {
                createDownscrollNotes();
                useDownscroll = false;
            }
            else
            {
                createUpscrollNotes();
                useDownscroll = true;
            }
        }


        if (FlxG.keys.justPressed.LEFT)
            curNoteType--;
        if (FlxG.keys.justPressed.RIGHT)
            curNoteType++;

        if (FlxG.keys.justPressed.UP)
            curOffset--;
        if (FlxG.keys.justPressed.DOWN)
            curOffset++;


        noteTypes.forEach(function(spr:FlxSprite)
        {
            spr.y = 400 + curOffset;
        });
    }
}