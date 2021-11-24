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


    public static var splitScroll:Bool = false; 
    public static var P2splitScroll:Bool = false;
    public static var offset:Int = 0;

    //hue, saturation, brightness, asset
    public static var purple:Array<Float> = [0, 0, 0, 0];
    public static var blue:Array<Float> = [0, 0, 0, 0];
    public static var green:Array<Float> = [0, 0, 0, 0];
    public static var red:Array<Float> = [0, 0, 0, 0];
    public static var white:Array<Float> = [0, 0, 0, 0];
    public static var yellow:Array<Float> = [0, 0, 0, 0];
    public static var violet:Array<Float> = [0, 0, 0, 0];
    public static var darkred:Array<Float> = [0, 0, 0, 0];
    public static var dark:Array<Float> = [0, 0, 0, 0];
    public static var colorArray:Array<Array<Float>> = [purple,blue,green,red,white,yellow,violet,darkred,dark];


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

        if (FlxG.save.data.laneOpacity == null)
            FlxG.save.data.laneOpacity = 0.2;

        if (FlxG.save.data.splitScroll == null)
			FlxG.save.data.splitScroll = false;

        if (FlxG.save.data.P2splitScroll == null)
			FlxG.save.data.P2splitScroll = false;

        if (FlxG.save.data.offset == null)
            FlxG.save.data.offset = 0;


        

        //////////////////////////////////////////////////////////////

        if (FlxG.save.data.purple == null)
            FlxG.save.data.purple = [0, 0, 0, 0];
        if (FlxG.save.data.blue == null)
            FlxG.save.data.blue = [0, 0, 0, 0];
        if (FlxG.save.data.green == null)
            FlxG.save.data.green = [0, 0, 0, 0];
        if (FlxG.save.data.red == null)
            FlxG.save.data.red = [0, 0, 0, 0];
        if (FlxG.save.data.white == null)
            FlxG.save.data.white = [0, 0, 0, 0];
        if (FlxG.save.data.yellow == null)
            FlxG.save.data.yellow = [0, 0, 0, 0];
        if (FlxG.save.data.violet == null)
            FlxG.save.data.violet = [0, 0, 0, 0];
        if (FlxG.save.data.darkred == null)
            FlxG.save.data.darkred = [0, 0, 0, 0];
        if (FlxG.save.data.dark == null)
            FlxG.save.data.dark = [0, 0, 0, 0];

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
        FlxG.save.data.splitScroll = splitScroll;
        FlxG.save.data.P2splitScroll = P2splitScroll;
        FlxG.save.data.offset = offset;


        FlxG.save.data.purple = purple;
        FlxG.save.data.blue = blue;
        FlxG.save.data.green = green;
        FlxG.save.data.red = red;
        FlxG.save.data.white = white;
        FlxG.save.data.yellow = yellow;
        FlxG.save.data.violet = violet;
        FlxG.save.data.darkred = darkred;
        FlxG.save.data.dark = dark;

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
        splitScroll = FlxG.save.data.splitScroll;
        P2splitScroll = FlxG.save.data.P2splitScroll;
        offset = FlxG.save.data.offset;

        purple = FlxG.save.data.purple;
        blue = FlxG.save.data.blue;
        green = FlxG.save.data.green;
        red = FlxG.save.data.red;
        white = FlxG.save.data.white;
        yellow = FlxG.save.data.yellow;
        violet = FlxG.save.data.violet;
        darkred = FlxG.save.data.darkred;
        dark = FlxG.save.data.dark;
        colorArray = [purple,blue,green,red,white,yellow,violet,darkred,dark];
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
        FlxG.save.data.purple = [0, 0, 0, 0];
        FlxG.save.data.blue = [0, 0, 0, 0];
        FlxG.save.data.green = [0, 0, 0, 0];
        FlxG.save.data.red = [0, 0, 0, 0];
        FlxG.save.data.white = [0, 0, 0, 0];
        FlxG.save.data.yellow = [0, 0, 0, 0];
        FlxG.save.data.violet = [0, 0, 0, 0];
        FlxG.save.data.darkred = [0, 0, 0, 0];
        FlxG.save.data.dark = [0, 0, 0, 0];
        

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
    public static function updateColorArray(mania:Int):Void //its better than having shit loads of case statements for every single thing
    {
        switch (mania)
        {
            case 0: 
                purple = colorArray[0];
                blue = colorArray[1];
                green = colorArray[2];
                red = colorArray[3];
            case 1: 
                purple = colorArray[0];
                green = colorArray[1];
                red = colorArray[2];
                yellow = colorArray[3];
                blue = colorArray[4];
                dark = colorArray[5];
            case 2: 
                purple = colorArray[0];
                blue = colorArray[1];
                green = colorArray[2];
                red = colorArray[3];
                white = colorArray[4];
                yellow = colorArray[5];
                violet = colorArray[6];
                darkred = colorArray[7];
                dark = colorArray[8];
            case 3: 
                purple = colorArray[0];
                blue = colorArray[1];
                white = colorArray[2];
                green = colorArray[3];
                red = colorArray[4];
            case 4: 
                purple = colorArray[0];
                green = colorArray[1];
                red = colorArray[2];
                white = colorArray[3];
                yellow = colorArray[4];
                blue = colorArray[5];
                dark = colorArray[6];
            case 5: 
                purple = colorArray[0];
                blue = colorArray[1];
                green = colorArray[2];
                red = colorArray[3];
                yellow = colorArray[4];
                violet = colorArray[5];
                darkred = colorArray[6];
                dark = colorArray[7];
            case 6: 
                white = colorArray[0];
            case 7: 
                purple = colorArray[0];
                red = colorArray[1];
            case 8: 
                purple = colorArray[0];
                white = colorArray[1];
                red = colorArray[2];

        }
        fixColorArray(mania);
            
    }
    public static function fixColorArray(mania:Int):Void //adjust color order based on amount of keys
    {
        switch (mania)
        {
            case 1: 
                colorArray = [purple, green, red, yellow, blue, dark];
            case 2: 
                colorArray = [purple, blue, green, red, white, yellow, violet, darkred, dark];
            case 3: 
                colorArray = [purple, blue, white, green, red];
            case 4: 
                colorArray = [purple, green, red, white, yellow, blue, dark];
            case 5: 
                colorArray = [purple, blue, green, red, yellow, violet, darkred, dark];
            case 6: 
                colorArray = [white];
            case 7: 
                colorArray = [purple, red];
            case 8: 
                colorArray = [purple, white, red];
        }
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
        
        readTheData();
        saveTheData();

    }

}