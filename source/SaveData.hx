import flixel.text.FlxText.FlxTextAlign;
import openfl.Lib;
import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;

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

    public static var hudPositions:Map<String, Dynamic> = [
        'song' => [0,0],
        'combo' => [0,0],
        'rating' => [0,0],
        'healthBar' => [0,0],
        'score' => [0,0],
        'scoreAlign' => FlxTextAlign.CENTER,
        'songAlign' => FlxTextAlign.LEFT,
        'songSize' => 24,
        'scoreSize' => 16,
        'healthBarAlign' => FlxTextAlign.CENTER,
        'verticalHealthBar' => false,
        'healthBarWidth' => 1,
    ];
    public static var hudTexts:Map<String, Dynamic> = [
        'score' => true,
        'rank' => true,
        'acc' => true,
        'misses' => true,
        'song' => true,
        'timer' => true,
        'sicks' => false,
        'goods' => false,
        'bads' => false,
        'shits' => false,
        'ghostMisses' => false,
        'combo' => false,
        'highestCombo' => false,
        'nps' => false,
        'highestNps' => false
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

    public static var listOfSaveData:Array<String> = [
        'ghost',
        'downscroll',
        'P2downscroll',
        'botplay',
        'noteSplash',
        'middlescroll',
        'multiplayer',
        'ScrollSpeed',
        'fps',
        'casual',
        'noteMovements',
        'speedScaling',
        'hudPositions',
        'hudTexts',
        'arrowLanes',
        'laneOpacity',
        'hudOpacity',
        'noteQuant',
        'offset',
        'noteColors',
        'binds',
        'P2binds',
        'GPbinds'
    ];


    public static function saveDataCheck()
    {
        if (FlxG.save.data.ScrollSpeed == null || FlxG.save.data.ScrollSpeed < 1)
			FlxG.save.data.ScrollSpeed = 1;
        else if (FlxG.save.data.ScrollSpeed > 10)
            FlxG.save.data.ScrollSpeed = 10;

        if (FlxG.save.data.fps == null || FlxG.save.data.fps < 60)
            FlxG.save.data.fps = 60;
        else if (FlxG.save.data.fps > 300)
            FlxG.save.data.fps = 300;



        for (i in 0...listOfSaveData.length)
        {
            if (Reflect.getProperty(FlxG.save.data, listOfSaveData[i]) != null)
            {
                switch(listOfSaveData[i])
                {
                    case 'hudPositions': //fucking maps
                        var temp:Map<String, Dynamic> = Reflect.getProperty(FlxG.save.data, listOfSaveData[i]);
                        for (shit => fuck in temp)
                            hudPositions.set(shit, fuck);
                    case 'hudTexts': 
                        var temp:Map<String, Dynamic> = Reflect.getProperty(FlxG.save.data, listOfSaveData[i]);
                        for (shit => fuck in temp)
                            hudTexts.set(shit, fuck);
                        
                    default: 
                        Reflect.setProperty(SaveData, listOfSaveData[i], Reflect.getProperty(FlxG.save.data, listOfSaveData[i]));
                }
            }
                
        }        
        keyBindCheck();

    }
    public static function saveTheData()
    {
        for (i in 0...listOfSaveData.length)
        {
            Reflect.setProperty(FlxG.save.data, listOfSaveData[i], Reflect.getProperty(SaveData, listOfSaveData[i]));            
        }        
        FlxG.save.flush();
        saveDataCheck();
    }

    public static function readTheData() //not sure if this is needed, kinda just a backup or somethin idk
    {
        saveDataCheck();
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
        saveTheData();

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

    public static function ResetHud():Void
    {
        hudPositions = [
            'song' => [0,0],
            'combo' => [0,0],
            'rating' => [0,0],
            'healthBar' => [0,0],
            'score' => [0,0],
            'scoreAlign' => FlxTextAlign.CENTER,
            'songAlign' => FlxTextAlign.LEFT,
            'songSize' => 24,
            'scoreSize' => 16,
            'healthBarAlign' => FlxTextAlign.CENTER,
            'verticalHealthBar' => false,
            'healthBarWidth' => 1,
        ];
        hudTexts = [
            'score' => true,
            'rank' => true,
            'acc' => true,
            'misses' => true,
            'song' => true,
            'timer' => true,
            'sicks' => false,
            'goods' => false,
            'bads' => false,
            'shits' => false,
            'ghostMisses' => false,
            'combo' => false,
            'highestCombo' => false,
            'nps' => false,
            'highestNps' => false
        ];
        arrowLanes = "Off";
        laneOpacity = 0.2;
        hudOpacity = 1;
        saveTheData();
    }

}