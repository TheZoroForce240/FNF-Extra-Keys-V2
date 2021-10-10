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
    public static var randomSection:Bool = true;
    public static var randomNoteSpeed:Bool = false;
    public static var randomNoteVelocity:Bool = false;
    public static var flip:Bool = false;
    public static var Hellchart:Bool = false;


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

        if (FlxG.save.data.multiplayer == null)
			FlxG.save.data.multiplayer = false;

        if (FlxG.save.data.ScrollSpeed == null || FlxG.save.data.ScrollSpeed < 1 || FlxG.save.data.ScrollSpeed > 10)
			FlxG.save.data.ScrollSpeed = 1;

        if (FlxG.save.data.fps == null || FlxG.save.data.fps < 60 || FlxG.save.data.fps > 300)
            FlxG.save.data.fps = 60;

        if (FlxG.save.data.casual == null)
			FlxG.save.data.casual = false;

        /////////////////////////////////////////////////////////////////

        if (FlxG.save.data.randomNotes == null)
			FlxG.save.data.randomNotes = false;

		if (FlxG.save.data.randomSection == null)
			FlxG.save.data.randomSection = true;

        if (FlxG.save.data.flip == null)
			FlxG.save.data.flip = false;

        if (FlxG.save.data.randomNoteSpeed == null)
			FlxG.save.data.randomNoteSpeed = false;

        if (FlxG.save.data.randomNoteVelocity == null)
			FlxG.save.data.randomNoteVelocity = false;

        if (FlxG.save.data.Hellchart == null)
			FlxG.save.data.Hellchart = false;

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
        FlxG.save.data.multiplayer = multiplayer;
        FlxG.save.data.ScrollSpeed = ScrollSpeed;
        FlxG.save.data.fps = fps;
        FlxG.save.data.casual = casual;

        FlxG.save.data.randomNotes = randomNotes;
        FlxG.save.data.randomSection = randomSection;
        FlxG.save.data.flip = flip;
        FlxG.save.data.randomNoteSpeed = randomNoteSpeed;
        FlxG.save.data.randomNoteVelocity = randomNoteVelocity;
        FlxG.save.data.Hellchart = Hellchart;

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
        multiplayer = FlxG.save.data.multiplayer;

        ScrollSpeed = FlxG.save.data.ScrollSpeed;
        fps = FlxG.save.data.fps;
        casual = FlxG.save.data.casual;

        randomNotes = FlxG.save.data.randomNotes;
        randomSection = FlxG.save.data.randomSection;
        flip = FlxG.save.data.flip;
        randomNoteSpeed = FlxG.save.data.randomNoteSpeed;
        randomNoteVelocity = FlxG.save.data.randomNoteVelocity;
        Hellchart = FlxG.save.data.Hellchart;

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
        FlxG.save.data.randomSection = true;
        FlxG.save.data.mania = 0;
        FlxG.save.data.randomMania = 0;
        FlxG.save.data.flip = false;
        FlxG.save.data.bothSide = false;
        FlxG.save.data.randomNoteTypes = 0;
        FlxG.save.data.multiplayer = false;
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

    public static function resetBinds():Void
    {

        FlxG.save.data.upBind = "W";
        FlxG.save.data.downBind = "S";
        FlxG.save.data.leftBind = "A";
        FlxG.save.data.rightBind = "D";

        FlxG.save.data.N0Bind = "A";
        FlxG.save.data.N1Bind = "S";
        FlxG.save.data.N2Bind = "D";
        FlxG.save.data.N3Bind = "F";
        FlxG.save.data.N4Bind = "SPACE";
        FlxG.save.data.N5Bind = "H";
        FlxG.save.data.N6Bind = "J";
        FlxG.save.data.N7Bind = "K";
        FlxG.save.data.N8Bind = "L";

        FlxG.save.data.L1Bind = "S";
        FlxG.save.data.U1Bind = "D";
        FlxG.save.data.R1Bind = "F";
        FlxG.save.data.L2Bind = "J";
        FlxG.save.data.D1Bind = "K";
        FlxG.save.data.R2Bind = "L";

        FlxG.save.data.P2upBind = "UP";
        FlxG.save.data.P2downBind = "DOWN";
        FlxG.save.data.P2leftBind = "LEFT";
        FlxG.save.data.P2rightBind = "RIGHT";

        FlxG.save.data.P2N0Bind = "Q";
        FlxG.save.data.P2N1Bind = "W";
        FlxG.save.data.P2N2Bind = "E";
        FlxG.save.data.P2N3Bind = "R";
        FlxG.save.data.P2N4Bind = "B";
        FlxG.save.data.P2N5Bind = "Y";
        FlxG.save.data.P2N6Bind = "U";
        FlxG.save.data.P2N7Bind = "I";
        FlxG.save.data.P2N8Bind = "O";

        FlxG.save.data.P2L1Bind = "W";
        FlxG.save.data.P2U1Bind = "E";
        FlxG.save.data.P2R1Bind = "R";
        FlxG.save.data.P2L2Bind = "U";
        FlxG.save.data.P2D1Bind = "I";
        FlxG.save.data.P2R2Bind = "O";

        PlayerSettings.player1.controls.loadKeyBinds();

        keyBindCheck();
	}
    public static function keyBindCheck():Void
        {
            if(FlxG.save.data.upBind == null)
                FlxG.save.data.upBind = "W";
            if(FlxG.save.data.downBind == null)
                FlxG.save.data.downBind = "S";
            if(FlxG.save.data.leftBind == null)
                FlxG.save.data.leftBind = "A";
            if(FlxG.save.data.rightBind == null)
                FlxG.save.data.rightBind = "D";
            
            if(FlxG.save.data.N0Bind == null)
                FlxG.save.data.N0Bind = "A";
            if(FlxG.save.data.N1Bind == null)
                FlxG.save.data.N1Bind = "S";
            if(FlxG.save.data.N2Bind == null)
                FlxG.save.data.N2Bind = "D";
            if(FlxG.save.data.N3Bind == null)
                FlxG.save.data.N3Bind = "F";
            if(FlxG.save.data.N4Bind == null)
                FlxG.save.data.N4Bind = "SPACE";
            if(FlxG.save.data.N5Bind == null)
                FlxG.save.data.N5Bind = "H";
            if(FlxG.save.data.N6Bind == null)
                FlxG.save.data.N6Bind = "J";
            if(FlxG.save.data.N7Bind == null)
                FlxG.save.data.N7Bind = "K";
            if(FlxG.save.data.N8Bind == null)
                FlxG.save.data.N8Bind = "L";
            
            if(FlxG.save.data.L1Bind == null)
                FlxG.save.data.L1Bind = "S";
            if(FlxG.save.data.U1Bind == null)
                FlxG.save.data.U1Bind = "D";
            if(FlxG.save.data.R1Bind == null)
                FlxG.save.data.R1Bind = "F";
            if(FlxG.save.data.L2Bind == null)
                FlxG.save.data.L2Bind = "J";
            if(FlxG.save.data.D1Bind == null)
                FlxG.save.data.D1Bind = "K";
            if(FlxG.save.data.R2Bind == null)
                FlxG.save.data.R2Bind = "L";

            ////////////////////////////////////////// player 2 shit

            if(FlxG.save.data.P2upBind == null)
                FlxG.save.data.P2upBind = "UP";
            if(FlxG.save.data.P2downBind == null)
                FlxG.save.data.P2downBind = "DOWN";
            if(FlxG.save.data.P2leftBind == null)
                FlxG.save.data.P2leftBind = "LEFT";
            if(FlxG.save.data.P2rightBind == null)
                FlxG.save.data.P2rightBind = "RIGHT";
            
            if(FlxG.save.data.P2N0Bind == null)
                FlxG.save.data.P2N0Bind = "Q";
            if(FlxG.save.data.P2N1Bind == null)
                FlxG.save.data.P2N1Bind = "W";
            if(FlxG.save.data.P2N2Bind == null)
                FlxG.save.data.P2N2Bind = "E";
            if(FlxG.save.data.P2N3Bind == null)
                FlxG.save.data.P2N3Bind = "R";
            if(FlxG.save.data.P2N4Bind == null)
                FlxG.save.data.P2N4Bind = "B";
            if(FlxG.save.data.P2N5Bind == null)
                FlxG.save.data.P2N5Bind = "Y";
            if(FlxG.save.data.P2N6Bind == null)
                FlxG.save.data.P2N6Bind = "U";
            if(FlxG.save.data.P2N7Bind == null)
                FlxG.save.data.P2N7Bind = "I";
            if(FlxG.save.data.P2N8Bind == null)
                FlxG.save.data.P2N8Bind = "O";
            
            if(FlxG.save.data.P2L1Bind == null)
                FlxG.save.data.P2L1Bind = "W";
            if(FlxG.save.data.P2U1Bind == null)
                FlxG.save.data.P2U1Bind = "E";
            if(FlxG.save.data.P2R1Bind == null)
                FlxG.save.data.P2R1Bind = "R";
            if(FlxG.save.data.P2L2Bind == null)
                FlxG.save.data.P2L2Bind = "U";
            if(FlxG.save.data.P2D1Bind == null)
                FlxG.save.data.P2D1Bind = "I";
            if(FlxG.save.data.P2R2Bind == null)
                FlxG.save.data.P2R2Bind = "O";
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