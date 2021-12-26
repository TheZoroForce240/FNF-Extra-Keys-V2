import openfl.Lib;
import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.util.FlxColor;

class SaveData
{
    public static var ghost:Bool = true;
    public static var downscroll:Bool = false;
    public static var P2downscroll:Bool = false;
    public static var botplay:Bool = false;
    public static var noteSplash:Bool = true;
    public static var middlescroll:Bool = false;
    public static var multiplayer:Bool = false;
    public static var ScrollSpeed:Float = 1;
    public static var fps:Float = 60;
    public static var casual:Bool = false;

    public static var randomNotes:Bool = false;
    //public static var randomSection:Bool = true;
    public static var randomNoteSpeed:Bool = false;
    public static var randomNoteVelocity:Bool = false;
    public static var flip:Bool = false;
    public static var Hellchart:Bool = false;
    public static var noteMovements:Bool = false;
    public static var speedScaling:Bool = false;
    public static var randomizationMode:String = "Normal";

    public static var hudPos:String = "Left";
    public static var songhudPos:String = "Left";
    public static var hpBarPos:String = "Left";
    public static var enabledHudSections:Array<Bool> = [
        true, //score
        true, //rank
        true, //acc
        true, //misses
        true, //song name
        true, //timer
        true, //sicks
        true, //goods
        true, //bads
        true, //shits
        true, //ghost misses
        true, //combo
        true, //highest combo
        true, //nps
        true, //highest nps
        true, //health percentage
    ];

    public static var arrowLanes:String = "Off";
    public static var laneOpacity:Float = 0.2;
    public static var hudOpacity:Float = 1;
    public static var noteQuant:Bool = false;

    public static var splitScroll:Bool = false; 
    public static var P2splitScroll:Bool = false;
    public static var offset:Int = 0;

    //hue, saturation, brightness, asset
    public static var noteColors:Array<Array<Float>> = [
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

    
    public static var binds:Array<Dynamic> = [
        ["A", "S", "W", "D"],
        ["S", "D", "F", "J", "K", "L"],
        ["A", "S", "D", "F", "SPACE", "H", "J", "K", "L"]
    ];

    public static var P2binds:Array<Dynamic> = [
        ["LEFT", "DOWN", "UP", "RIGHT"],
        ["W", "E", "R", "U", "I", "O"],
        ["Q", "W", "E", "R", "B", "Y", "U", "I", "O"]
    ];

    public static var GPbinds:Array<Dynamic> = [
        ["DPAD_LEFT", "DPAD_DOWN", "DPAD_UP", "DPAD_RIGHT"],
        ["DPAD_LEFT", "DPAD_DOWN", "DPAD_UP", "X", "A", "B"],
        ["DPAD_LEFT", "DPAD_DOWN", "DPAD_UP", "DPAD_RIGHT", "LEFT_TRIGGER", "X", "A", "Y", "B"]
    ];


    public static var noteScaleMulti:Float = 1;
    public static var noteWidthMulti:Float = 1;


    public static function saveDataCheck()
    {
        /////////////////////////////////////////////////////////
        if (FlxG.save.data.ghost == null)
			FlxG.save.data.ghost = true;

		if (FlxG.save.data.downscroll == null)
			FlxG.save.data.downscroll = false;

        if (FlxG.save.data.P2downscroll == null)
			FlxG.save.data.P2downscroll = false;

        if (FlxG.save.data.botplay == null)
			FlxG.save.data.botplay = false;

        if (FlxG.save.data.noteSplash == null)
			FlxG.save.data.noteSplash = true;

        if (FlxG.save.data.middlescroll == null)
			FlxG.save.data.middlescroll = false;


        if (FlxG.save.data.ScrollSpeed == null || FlxG.save.data.ScrollSpeed < 1 || FlxG.save.data.ScrollSpeed > 10)
			FlxG.save.data.ScrollSpeed = 1;

        if (FlxG.save.data.fps == null || FlxG.save.data.fps < 60 || FlxG.save.data.fps > 300)
            FlxG.save.data.fps = 60;

        if (FlxG.save.data.casual == null)
			FlxG.save.data.casual = false;

        if (FlxG.save.data.noteMovements == null)
			FlxG.save.data.noteMovements = false;

        if (FlxG.save.data.speedScaling == null)
			FlxG.save.data.speedScaling = false;

        if (FlxG.save.data.hudPos == null)
			FlxG.save.data.hudPos = "Default";

        if (FlxG.save.data.songhudPos == null)
			FlxG.save.data.songhudPos = "Default";
        
        if (FlxG.save.data.hpBarPos == null)
			FlxG.save.data.hpBarPos = "Default";

        if (FlxG.save.data.enabledHudSections == null)
			FlxG.save.data.enabledHudSections = [
                true, //score
                true, //rank
                true, //acc
                true, //misses
                true, //song name
                true, //timer
                true, //sicks
                true, //goods
                true, //bads
                true, //shits
                true, //ghost misses
                true, //combo
                true, //highest combo
                true, //nps
                true, //highest nps
                true, //health percentage
            ];

        if (FlxG.save.data.arrowLanes == null)
            FlxG.save.data.arrowLanes = "Off";

        if (FlxG.save.data.hudOpacity == null)
            FlxG.save.data.hudOpacity = 0.2;

        if (FlxG.save.data.hpBarOpacity == null)
            FlxG.save.data.hpBarOpacity = 0.2;

        if (FlxG.save.data.splitScroll == null)
			FlxG.save.data.splitScroll = false;

        if (FlxG.save.data.P2splitScroll == null)
			FlxG.save.data.P2splitScroll = false;

        if (FlxG.save.data.offset == null)
            FlxG.save.data.offset = 0;

        if (FlxG.save.data.noteQuant == null)
            FlxG.save.data.noteQuant = false;

        //////////////////////////////////////////////////////////////

        if (FlxG.save.data.noteColors == null)
            FlxG.save.data.noteColors = [
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

        keyBindCheck();

    }
    public static function saveTheData()
    {
        FlxG.save.data.downscroll = downscroll;
        FlxG.save.data.P2downscroll = P2downscroll;
        FlxG.save.data.ghost = ghost;
        FlxG.save.data.botplay = botplay;
        FlxG.save.data.noteSplash = noteSplash;
        FlxG.save.data.middlescroll = middlescroll;
        FlxG.save.data.ScrollSpeed = ScrollSpeed;
        FlxG.save.data.fps = fps;
        FlxG.save.data.casual = casual;
        FlxG.save.data.noteMovements = noteMovements;
        FlxG.save.data.speedScaling = speedScaling;

        FlxG.save.data.hudPos = hudPos;
        FlxG.save.data.songhudPos = songhudPos;
        FlxG.save.data.hpBarPos = hpBarPos;
        FlxG.save.data.enabledHudSections = enabledHudSections;
        FlxG.save.data.arrowLanes = arrowLanes;
        FlxG.save.data.laneOpacity = laneOpacity;
        FlxG.save.data.hudOpacity = hudOpacity;
        FlxG.save.data.splitScroll = splitScroll;
        FlxG.save.data.P2splitScroll = P2splitScroll;
        FlxG.save.data.offset = offset;
        FlxG.save.data.noteQuant = noteQuant;


        FlxG.save.data.noteColors = noteColors;

        FlxG.save.data.binds = binds;
        FlxG.save.data.P2binds = P2binds;
        FlxG.save.data.GPbinds = GPbinds;

        FlxG.save.flush();
    }

    public static function readTheData() //not sure if this is needed, kinda just a backup or somethin idk
    {
        saveDataCheck();

        downscroll = FlxG.save.data.downscroll;
        P2downscroll = FlxG.save.data.P2downscroll;
        ghost = FlxG.save.data.ghost;
        botplay = FlxG.save.data.botplay;
        noteSplash = FlxG.save.data.noteSplash;
        middlescroll = FlxG.save.data.middlescroll;
        noteMovements = FlxG.save.data.noteMovements;
        speedScaling = FlxG.save.data.speedScaling;

        ScrollSpeed = FlxG.save.data.ScrollSpeed;
        fps = FlxG.save.data.fps;
        casual = FlxG.save.data.casual;

        hudPos = FlxG.save.data.hudPos;
        songhudPos = FlxG.save.data.songhudPos;
        hpBarPos = FlxG.save.data.hpBarPos;
        enabledHudSections = FlxG.save.data.enabledHudSections;

        arrowLanes = FlxG.save.data.arrowLanes;
        laneOpacity = FlxG.save.data.laneOpacity;
        hudOpacity = FlxG.save.data.hudOpacity;
        splitScroll = FlxG.save.data.splitScroll;
        P2splitScroll = FlxG.save.data.P2splitScroll;
        offset = FlxG.save.data.offset;

        noteQuant = FlxG.save.data.noteQuant;

        binds = FlxG.save.data.binds;
        P2binds = FlxG.save.data.P2binds;
        GPbinds = FlxG.save.data.GPbinds;

        noteColors = FlxG.save.data.noteColors;
    }
    public static function ResetData()
    {
        FlxG.save.data.ghost = true;
        FlxG.save.data.downscroll = false;
        FlxG.save.data.P2downscroll = false;
        FlxG.save.data.botplay = false;
        FlxG.save.data.noteSplash = true;
        FlxG.save.data.middlescroll = false;
        FlxG.save.data.randomNotes = false;
        FlxG.save.data.mania = 0;
        FlxG.save.data.flip = false;
        FlxG.save.data.noteMovements = false;
        FlxG.save.data.speedScaling = false;

        readTheData();
        saveTheData();
    }

    public static function resetBinds():Void //todo uhhhh put in an array or somethin
    {
        FlxG.save.data.binds = [
            ["A", "S", "W", "D"],
            ["S", "D", "F", "J", "K", "L"],
            ["A", "S", "D", "F", "SPACE", "H", "J", "K", "L"]
        ];

        FlxG.save.data.P2binds = [
            ["LEFT", "DOWN", "UP", "RIGHT"],
            ["W", "E", "R", "U", "I", "O"],
            ["Q", "W", "E", "R", "B", "Y", "U", "I", "O"]
        ];

        FlxG.save.data.GPbinds = [
            ["DPAD_LEFT", "DPAD_DOWN", "DPAD_UP", "DPAD_RIGHT"],
            ["DPAD_LEFT", "DPAD_DOWN", "DPAD_UP", "X", "A", "B"],
            ["DPAD_LEFT", "DPAD_DOWN", "DPAD_UP", "DPAD_RIGHT", "LEFT_TRIGGER", "X", "A", "Y", "B"]
        ];

        PlayerSettings.player1.controls.loadKeyBinds();
        readTheData();
        keyBindCheck();
	}
    public static function keyBindCheck():Void 
        {
            if (FlxG.save.data.binds == null)
                FlxG.save.data.binds = [
                    ["A", "S", "W", "D"],
                    ["S", "D", "F", "J", "K", "L"],
                    ["A", "S", "D", "F", "SPACE", "H", "J", "K", "L"]
                ];

            if (FlxG.save.data.P2binds == null)
                FlxG.save.data.P2binds = [
                    ["LEFT", "DOWN", "UP", "RIGHT"],
                    ["W", "E", "R", "U", "I", "O"],
                    ["Q", "W", "E", "R", "B", "Y", "U", "I", "O"]
                ];

            if (FlxG.save.data.GPbinds == null)
                FlxG.save.data.GPbinds = [
                    ["DPAD_LEFT", "DPAD_DOWN", "DPAD_UP", "DPAD_RIGHT"],
                    ["DPAD_LEFT", "DPAD_DOWN", "DPAD_UP", "X", "A", "B"],
                    ["DPAD_LEFT", "DPAD_DOWN", "DPAD_UP", "DPAD_RIGHT", "LEFT_TRIGGER", "X", "A", "Y", "B"]
                ];
        }

    public static function ResetColors():Void //i think you can figure out what this does
    {
        FlxG.save.data.purple = [0, 0, 0, 0];
        FlxG.save.data.blue = [0, 0, 0, 0];
        FlxG.save.data.green = [0, 0, 0, 0];
        FlxG.save.data.red = [0, 0, 0, 0];
        FlxG.save.data.white = [0, 0, 0, 0];
        FlxG.save.data.yellow = [0, 0, 0, 0];
        FlxG.save.data.violet = [0, 0, 0, 0];
        FlxG.save.data.darkred = [0, 0, 0, 0];
        FlxG.save.data.dark = [0, 0, 0, 0];
        FlxG.save.data.noteColors = [
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
        
        readTheData();
        saveTheData();

    }

}