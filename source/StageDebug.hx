package;



import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import StagePiece.StageOffset;
import haxe.Json;
import haxe.format.JsonParser;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
using StringTools;

class StageDebug extends MusicBeatState
{
    var _file:FileReference;

    var bf:Boyfriend;
    var dad:Character;
    var camFollow:FlxObject;
    var daStage:String = "stage";
    var StagePieces:FlxTypedGroup<StagePiece>;
    var defaultCamZoom = 1.05;

    var pieces:Array<String> = [];
    var zoom:Float = 1.05;
    var offsetMap:Map<String, Array<Dynamic>>;

    var stageOffsets:Array<StageOffset>;

    public function new(daStage:String = 'stage')
    {
        super();
        this.daStage = daStage;
    }

    override function create()
    {
        StagePieces = new FlxTypedGroup<StagePiece>();
		add(StagePieces);

        loadStage();



        camFollow = new FlxObject(0, 0, 2, 2);
		add(camFollow);

		FlxG.camera.follow(camFollow);

		super.create();
    }

    override function update(elapsed:Float)
    {
        if (FlxG.keys.justPressed.E)
            FlxG.camera.zoom += 0.25;
        if (FlxG.keys.justPressed.Q)
            FlxG.camera.zoom -= 0.25;

        if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L)
        {
            if (FlxG.keys.pressed.I)
                camFollow.velocity.y = -350;
            else if (FlxG.keys.pressed.K)
                camFollow.velocity.y = 350;
            else
                camFollow.velocity.y = 0;

            if (FlxG.keys.pressed.J)
                camFollow.velocity.x = -350;
            else if (FlxG.keys.pressed.L)
                camFollow.velocity.x = 350;
            else
                camFollow.velocity.x = 0;
        }
        else
        {
            camFollow.velocity.set();
        }

        if (FlxG.keys.justPressed.ESCAPE)
			FlxG.switchState(new DebugState());

        super.update(elapsed);
    }

    override function beatHit()
    {
        super.beatHit();

        StagePiece.daBeat = curBeat;
		for (piece in StagePieces.members)
        {
            if (piece.danceable)
                piece.dance();
        }
			
    }

    private function loadStage()
    {
        pieces = [];
        defaultCamZoom = 1.05;
        stageOffsets = [];

        StagePiece.StageCheck(daStage);
        pieces = PlayState.stageData[0];
        defaultCamZoom = PlayState.stageData[2];
        stageOffsets = PlayState.stageData[3];
    }
    private function loadPieces()
    {
        StagePieces.clear();
        for (i in 0...pieces.length)
        {
            var piece:StagePiece = new StagePiece(0, 0, pieces[i], true);

            if (pieces[i] == 'bgDancer')
                piece.x += (370 * (i - 2));
            
            piece.x += piece.newx;
            piece.y += piece.newy;
            StagePieces.add(piece);
        }
    }


    private function savePiece()
    {
        var json = {
            "position": [100, 100], 
            "scale": 1,
            "flip": false,
            "scrollFactor": [1, 1],
            "aa": true,
        
            "isAnimated": true,
            "anims": [
                {
                    "anim": "bop",
                    "xmlname": "santa idle in fear",
                    "frameRate": 24,
                    "loop": true
                }
            ],
            "animToPlay": "bop",
        
            "isDanceable": true,
            "animToPlayOnDance": "bop"
        };

        var data:String = Json.stringify(json, "\t");

        if ((data != null) && (data.length > 0))
        {
            _file = new FileReference();
            _file.addEventListener(Event.COMPLETE, onSaveComplete);
            _file.addEventListener(Event.CANCEL, onSaveCancel);
            _file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
            _file.save(data.trim(), "data.json");
        }
    }

    private function saveStage()
    {
        var json = {
            "name": daStage,
            "camZoom": defaultCamZoom,
            "pieceArray": pieces,
            "offsets": stageOffsets
        };

        var data:String = Json.stringify(json, "\t");

        if ((data != null) && (data.length > 0))
        {
            _file = new FileReference();
            _file.addEventListener(Event.COMPLETE, onSaveComplete);
            _file.addEventListener(Event.CANCEL, onSaveCancel);
            _file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
            _file.save(data.trim(), json.name.toLowerCase() + ".json");
        }
    }

    function onSaveComplete(_):Void
    {
        _file.removeEventListener(Event.COMPLETE, onSaveComplete);
        _file.removeEventListener(Event.CANCEL, onSaveCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _file = null;
        FlxG.log.notice("Successfully saved LEVEL DATA.");
    }

    /**
     * Called when the save file dialog is cancelled.
     */
    function onSaveCancel(_):Void
    {
        _file.removeEventListener(Event.COMPLETE, onSaveComplete);
        _file.removeEventListener(Event.CANCEL, onSaveCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _file = null;
    }

    /**
     * Called if there is an error while saving the gameplay recording.
     */
    function onSaveError(_):Void
    {
        _file.removeEventListener(Event.COMPLETE, onSaveComplete);
        _file.removeEventListener(Event.CANCEL, onSaveCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _file = null;
        FlxG.log.error("Problem saving Level data");
    }

}