package;

import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.text.FlxText;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import openfl.display.FPS;
import openfl.Lib;



class QuickOptions extends FlxSubState //kinda based on the keybind menu from kade engine, just wanted something simple, also a substate, so we got mid song options, kade engine is doing that now lol
{
    var curSelected:Int = 0;
    var waitingForInput:Bool = false;

    var daLARGEText:FlxText; 
    var infoText:FlxText;
    var BG:FlxSprite;
    
    var categories:Array<Dynamic>; //main section

    var gameplay:Array<Dynamic>;
    var misc:Array<Dynamic>;
    var keybinds:Array<Dynamic>;
    var P2keybinds:Array<Dynamic>;
    var randomization:Array<Dynamic>;

    var inCat:Bool = false;
    var curCategory:Array<Dynamic>; //actual category
    var daCat:String = "";
	override function create()
    {	
        reloadOptions();

        curCategory = categories;

        BG = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
        add(BG);
        BG.alpha = 0.5;
        BG.scrollFactor.set();

        daLARGEText = new FlxText(-260, 0, 1000, "", 32);
		daLARGEText.scrollFactor.set(0, 0);
		daLARGEText.setFormat("VCR OSD Mono", 28, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
        add(daLARGEText);
        daLARGEText.scrollFactor.set();

        infoText = new FlxText(-10, 600, 1000, 32);
		infoText.scrollFactor.set(0, 0);
		infoText.setFormat("VCR OSD Mono", 28, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        infoText.screenCenter(X);
        add(infoText);
        infoText.scrollFactor.set();

        createText();

        trace(daLARGEText.x);

        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
    }

    override function update(elapsed:Float)
    {
        if(FlxG.keys.justPressed.ESCAPE)
        {
            if (waitingForInput)
            {
                waitingForInput = false;
            }
            else if (inCat)
            {
                reloadOptions();
                daCat = "";
                curCategory = categories;
                curSelected = 0;
                createText();
                inCat = false;
            }
            else
                exit();
        }
            

        if (!waitingForInput)
        {
            if (FlxG.keys.justPressed.UP)
                changeSelected(-1);
            if (FlxG.keys.justPressed.DOWN)
                changeSelected(1);
    
            if (FlxG.keys.justPressed.LEFT)
                changeOptionSetting(-1);
            if (FlxG.keys.justPressed.RIGHT)
                changeOptionSetting(1);   
    
            if (FlxG.keys.justPressed.ENTER)
            {
                if (curCategory[curSelected][2] == "toggle")
                {
                    curCategory[curSelected][1] = !curCategory[curSelected][1];
                    turnOptionsIntoSaveData();
                    SaveData.saveDataCheck();
                    reloadOptions();
                    createText();
                }
                else if (curCategory[curSelected][2] == "cat")
                {
                    //curCat 0 = catergory menu, might be a little confusing lol
                    
                    reloadOptions();
                    switch (curCategory[curSelected][0])
                    {
                        case "Gameplay": 
                            curCategory = gameplay;
                            daCat = "Gameplay";
                        case "Misc": 
                            curCategory = misc;
                            daCat = "Misc";
                        case "Keybinds": 
                            curCategory = keybinds;
                            daCat = "Keybinds";
                        case "P2 Keybinds": 
                            curCategory = P2keybinds;
                            daCat = "P2 Keybinds";
                        case "Randomization": 
                            curCategory = randomization;
                            daCat = "Randomization";
                        default: 
                            curCategory = categories; //backup
                            daCat = "";
                    }
                    curSelected = 0;
                    inCat = true;
                    createText();
                }
                else if (curCategory[curSelected][2] == "keybind")
                {
                    waitingForInput = true;
                    createText();
                }
            }   
        }
        else
        {
            if (FlxG.keys.justPressed.ANY)
            {
                var key:String = FlxG.keys.getIsDown()[0].ID.toString(); //dont wanna add keyboard events to make this substate larger, but should work for most keys, it might break numpad though idk
                if (key != "BACKSPACE" || key != "ESCAPE" || key != "ENTER")
                {
                    curCategory[curSelected][1] = key;
                    turnOptionsIntoSaveData();
                    SaveData.saveDataCheck();
                    reloadOptions();
                    createText();
                }
                waitingForInput = false;
            }
        }
        

        if (curCategory[curSelected][1] < 1 && curCategory[curSelected][0] == "Scroll Speed") //checks
            curCategory[curSelected][1] = 1;
        if (curCategory[curSelected][1] > 10 && curCategory[curSelected][0] == "Scroll Speed")
            curCategory[curSelected][1] = 10;
        if (curCategory[curSelected][1] < 60 && curCategory[curSelected][0] == "FPS Cap")
            curCategory[curSelected][1] = 60;
        if (curCategory[curSelected][1] > 300 && curCategory[curSelected][0] == "FPS Cap")
            curCategory[curSelected][1] = 300;
            


        super.update(elapsed);
    }

    function exit()
    {
        SaveData.saveTheData();
        close();
    }

    function changeOptionSetting(change:Float = 0)
    {
        switch(curCategory[curSelected][0])
        {
            case "Scroll Speed": 
                change = change / 10; //makes it 0.1
            case "FPS Cap": 
                change = change * 10; //makes it 10
        }
        if (curCategory[curSelected][2] == "slider")
            curCategory[curSelected][1]+= change;

        turnOptionsIntoSaveData();
        SaveData.saveDataCheck();
        reloadOptions();
        createText();
    }

    function changeSelected(change:Int = 0)
    {
        FlxG.sound.play(Paths.sound('scrollMenu'));
        curSelected += change;

        if (curSelected < 0)
			curSelected = curCategory.length - 1;
		if (curSelected >= curCategory.length)
			curSelected = 0;

        if (curCategory[curSelected][0] == "")
            curSelected += change; //skips empty shit

        createText();
    }

    function createText()
    {
        daLARGEText.text = "\n";
        for (i in 0...curCategory.length)
        {
            /////////////////////////////
            var isToggle = curCategory[i][2] == "toggle"; 
            var ToggleText:String = "On"; //idk why tf i called it this lol
            if (curCategory[i][1])
                ToggleText = "On";
            else
                ToggleText = "Off";

            if (!isToggle)
                ToggleText = curCategory[i][1];
            //////////////////////////
            var middleThing:String = " : ";
            var extraThing:String = ""; 
            if (curCategory[i][2] == "slider")
            {
                middleThing = " <";
                extraThing = ">";
            }
            if (curCategory[i][2] == "cat")
                middleThing = "";

            if (i == curSelected && waitingForInput)
                ToggleText = "?";
                

            var text = (curCategory[i][0] + middleThing + ToggleText + extraThing);
            var isSelected = "";
            if (i == curSelected)
                isSelected = "---> ";
            daLARGEText.text += isSelected + text + "\n";
        }
        infoText.text = curCategory[curSelected][3];
    }

    function reloadOptions()
    {
        //READ IF YOU WANNA ADD MORE OPTIONS
        //so first thing is get your save data set up in saveData.hx, make a public static var for the save data, then stick it in saveDataCheck/SaveTheData/ReadTheData functions
        //next you want to add another line in the arrays here, pick a category for it (or add a new one, make sure set it up at line ~101 as well)
        
        //so first thing in the line is the name of the options, which shows on the menu, and is how its referenced in this code.
        //second thing is the actual save data
        //third thing is the option type (toggle, for Booleans. slider, for numbers (you can set up limits in update).keybind, pretty self explainatory, and finally cat, which is just used for the categories menu)
        //final thing in the array is the text at the bottom of the screen.

        //after you done this, you have to add a case inside turnOptionsIntoSaveData(), just copy paste one or something idk

        //make sure you dont mess up your commas lol
        categories = [
            ["Gameplay", "", "cat"],
            ["Misc", "", "cat"],
            ["Keybinds", "", "cat"],
            ["P2 Keybinds", "", "cat"],
            ["Randomization", "", "cat"]
        ];
        //name, savedata, type of option, info
        gameplay = [ 
            ["Ghost Tapping", SaveData.ghost, "toggle", "Turning on this means you dont miss when misspressing a note"],
            ["P1 Downscroll", SaveData.downscroll, "toggle", "Flip Da Notes"],
            ["Scroll Speed", SaveData.ScrollSpeed, "slider", "Change the default scroll speed (does not include notes changed by the chart)"],
            ["Casual Mode", SaveData.casual, "toggle", "More Spammable Input, Heal from Sustains and no health loss from bad accuracy"],
            ["Multiplayer", SaveData.multiplayer, "toggle", "Turn on to play with a friend locally\n(or just play both side because you have no friends)"],
            ["P2 Downscroll", SaveData.P2downscroll, "toggle", "Flip Da Notes but for the second guy"]
            
        ];
    
        misc = [ 
            ["Note Splash", SaveData.noteSplash, "toggle", "Turn on the funni effect when hitting sicks"],
            ["FPS Cap", SaveData.fps, "slider", "Turn up for more frames"],
            ["Middlescroll", SaveData.middlescroll, "toggle", "Center your Notes"],
            ["Camera Movements on Note Hits", SaveData.noteMovements, "toggle", "the thing that every mod does now"]
        ];
    
        keybinds = [
            ["4K/5K Left", FlxG.save.data.leftBind, "keybind", ""],
            ["4K/5K Down", FlxG.save.data.downBind, "keybind", ""],
            ["4K/5K Up", FlxG.save.data.upBind, "keybind", ""],
            ["4K/5K Right", FlxG.save.data.rightBind, "keybind", ""],
            ["", "", "cat", ""],
            ["9K/8K Left 1", FlxG.save.data.N0Bind, "keybind", ""],
            ["9K/8K Down 1", FlxG.save.data.N1Bind, "keybind", ""],
            ["9K/8K Up 1", FlxG.save.data.N2Bind, "keybind", ""],
            ["9K/8K Right 1", FlxG.save.data.N3Bind, "keybind", ""],
            ["5K/7K/9K Middle", FlxG.save.data.N4Bind, "keybind", ""],
            ["9K/8K Left 2", FlxG.save.data.N5Bind, "keybind", ""],
            ["9K/8K Down 2", FlxG.save.data.N6Bind, "keybind", ""],
            ["9K/8K Up 2", FlxG.save.data.N7Bind, "keybind", ""],
            ["9K/8K Right 2", FlxG.save.data.N8Bind, "keybind", ""],
            ["", "", "cat", ""],
            ["6K/7K Left 1", FlxG.save.data.L1Bind, "keybind", ""],
            ["6K/7K Up", FlxG.save.data.U1Bind, "keybind", ""],
            ["6K/7K Right 1", FlxG.save.data.R1Bind, "keybind", ""],
            ["6K/7K Left 2", FlxG.save.data.L2Bind, "keybind", ""],
            ["6K/7K Down", FlxG.save.data.D1Bind, "keybind", ""],
            ["6K/7K Right 2", FlxG.save.data.R2Bind, "keybind", ""]
        ];
        P2keybinds = [
            ["P2 4K/5K Left", FlxG.save.data.P2leftBind, "keybind", ""],
            ["P2 4K/5K Down", FlxG.save.data.P2downBind, "keybind", ""],
            ["P2 4K/5K Up", FlxG.save.data.P2upBind, "keybind", ""],
            ["P2 4K/5K Right", FlxG.save.data.P2rightBind, "keybind", ""],
            ["", "", "cat", ""],
            ["P2 9K/8K Left 1", FlxG.save.data.P2N0Bind, "keybind", ""],
            ["P2 9K/8K Down 1", FlxG.save.data.P2N1Bind, "keybind", ""],
            ["P2 9K/8K Up 1", FlxG.save.data.P2N2Bind, "keybind", ""],
            ["P2 9K/8K Right 1", FlxG.save.data.P2N3Bind, "keybind", ""],
            ["P2 5K/7K/9K Middle", FlxG.save.data.P2N4Bind, "keybind", ""],
            ["P2 9K/8K Left 2", FlxG.save.data.P2N5Bind, "keybind", ""],
            ["P2 9K/8K Down 2", FlxG.save.data.P2N6Bind, "keybind", ""],
            ["P2 9K/8K Up 2", FlxG.save.data.P2N7Bind, "keybind", ""],
            ["P2 9K/8K Right 2", FlxG.save.data.P2N8Bind, "keybind", ""],
            ["", "", "cat", ""],
            ["P2 6K/7K Left 1", FlxG.save.data.P2L1Bind, "keybind", ""],
            ["P2 6K/7K Up", FlxG.save.data.P2U1Bind, "keybind", ""],
            ["P2 6K/7K Right 1", FlxG.save.data.P2R1Bind, "keybind", ""],
            ["P2 6K/7K Left 2", FlxG.save.data.P2L2Bind, "keybind", ""],
            ["P2 6K/7K Down", FlxG.save.data.P2D1Bind, "keybind", ""],
            ["P2 6K/7K Right 2", FlxG.save.data.P2R2Bind, "keybind", ""]
        ];
    
        randomization = [
            ["Randomize Notes", SaveData.randomNotes, "toggle", "what else do you think it does"],
            ["Randomization Mode", SaveData.randomSection, "toggle", "change the mode, please just use section based it makes good charts"],
            ["Randomize Note Speed", SaveData.randomNoteSpeed, "toggle", "yes pain"],
            ["Randomize Note Velocity", SaveData.randomNoteVelocity, "toggle", "now its even worse"],
            ["Hellchart", SaveData.Hellchart, "toggle", "oh fuck it gets worse"],
            ["Play As Oppenent", SaveData.flip, "toggle", "figure it out lol"]
        ];

        switch (daCat)
        {
            case "Gameplay": 
                curCategory = gameplay;
            case "Misc": 
                curCategory = misc;
            case "Keybinds": 
                curCategory = keybinds;
            case "P2 Keybinds": 
                curCategory = P2keybinds;
            case "Randomization": 
                curCategory = randomization;
            default: 
                curCategory = categories; //backup
        }
    }

    function turnOptionsIntoSaveData()
    {
        /*SaveData.ghost = options[0][1];
        SaveData.downscroll = options[1][1];
        SaveData.P2downscroll = options[2][1];
        SaveData.multiplayer = options[3][1];
        SaveData.middlescroll = options[4][1];
        SaveData.noteSplash = options[5][1];
        SaveData.ScrollSpeed = options[6][1];
        SaveData.fps = options[7][1];
        SaveData.casual = options[8][1];

        SaveData.randomNotes = options[10][1];
        SaveData.randomSection = options[11][1];
        SaveData.randomNoteSpeed = options[12][1];
        SaveData.randomNoteVelocity = options[13][1];
        SaveData.Hellchart = options[14][1];
        SaveData.flip = options[15][1];*/

        for (i in 0...curCategory.length) //this is the best i could come up with OK, just so it only saves the ones in your current category
        {
            switch (curCategory[i][0])
            {
//////////////////////////////////////////////////////////////////////////////////////////
                case "Ghost Tapping": 
                    SaveData.ghost = curCategory[i][1];
                case "P1 Downscroll": 
                    SaveData.downscroll = curCategory[i][1];
                case "Scroll Speed": 
                    SaveData.ScrollSpeed = curCategory[i][1];
                case "Casual Mode": 
                    SaveData.casual = curCategory[i][1];
                case "Multiplayer": 
                    SaveData.multiplayer = curCategory[i][1];
                case "P2 Downscroll": 
                    SaveData.P2downscroll = curCategory[i][1];
//////////////////////////////////////////////////////////////////////////////////////////
                case "Note Splash": 
                    SaveData.noteSplash = curCategory[i][1];
                case "FPS Cap": 
                    SaveData.fps = curCategory[i][1];
                case "Middlescroll": 
                    SaveData.middlescroll = curCategory[i][1];
//////////////////////////////////////////////////////////////////////////////////////////
                case "4K/5K Left": 
                    FlxG.save.data.leftBind = curCategory[i][1];
                case "4K/5K Down": 
                    FlxG.save.data.downBind = curCategory[i][1];
                case "4K/5K Up": 
                    FlxG.save.data.upBind = curCategory[i][1];
                case "4K/5K Right": 
                    FlxG.save.data.rightBind = curCategory[i][1];

                case "9K/8K Left 1": 
                    FlxG.save.data.N0Bind = curCategory[i][1];
                case "9K/8K Down 1": 
                    FlxG.save.data.N1Bind = curCategory[i][1];
                case "9K/8K Up 1": 
                    FlxG.save.data.N2Bind = curCategory[i][1];
                case "9K/8K Right 1": 
                    FlxG.save.data.N3Bind = curCategory[i][1];
                case "5K/7K/9K Middle": 
                    FlxG.save.data.N4Bind = curCategory[i][1];
                case "9K/8K Left 2": 
                    FlxG.save.data.N5Bind = curCategory[i][1];
                case "9K/8K Down 2": 
                    FlxG.save.data.N6Bind = curCategory[i][1];
                case "9K/8K Up 2": 
                    FlxG.save.data.N7Bind = curCategory[i][1];
                case "9K/8K Right 2": 
                    FlxG.save.data.N8Bind = curCategory[i][1];

                case "6K/7K Left 1": 
                    FlxG.save.data.L1Bind = curCategory[i][1];
                case "6K/7K Up": 
                    FlxG.save.data.U1Bind = curCategory[i][1];
                case "6K/7K Right 1": 
                    FlxG.save.data.R1Bind = curCategory[i][1];
                case "6K/7K Left 2": 
                    FlxG.save.data.L2Bind = curCategory[i][1];
                case "6K/7K Down": 
                    FlxG.save.data.D1Bind = curCategory[i][1];
                case "6K/7K Right 2": 
                    FlxG.save.data.R2Bind = curCategory[i][1];
//////////////////////////////////////////////////////////////////////////////////////////
                case "P2 4K/5K Left": 
                    FlxG.save.data.P2leftBind = curCategory[i][1];
                case "P2 4K/5K Down": 
                    FlxG.save.data.P2downBind = curCategory[i][1];
                case "P2 4K/5K Up": 
                    FlxG.save.data.P2upBind = curCategory[i][1];
                case "P2 4K/5K Right": 
                    FlxG.save.data.P2rightBind = curCategory[i][1];

                case "P2 9K/8K Left 1": 
                    FlxG.save.data.P2N0Bind = curCategory[i][1];
                case "P2 9K/8K Down 1": 
                    FlxG.save.data.P2N1Bind = curCategory[i][1];
                case "P2 9K/8K Up 1": 
                    FlxG.save.data.P2N2Bind = curCategory[i][1];
                case "P2 9K/8K Right 1": 
                    FlxG.save.data.P2N3Bind = curCategory[i][1];
                case "P2 5K/7K/9K Middle": 
                    FlxG.save.data.P2N4Bind = curCategory[i][1];
                case "P2 9K/8K Left 2": 
                    FlxG.save.data.P2N5Bind = curCategory[i][1];
                case "P2 9K/8K Down 2": 
                    FlxG.save.data.P2N6Bind = curCategory[i][1];
                case "P2 9K/8K Up 2": 
                    FlxG.save.data.P2N7Bind = curCategory[i][1];
                case "P2 9K/8K Right 2": 
                    FlxG.save.data.P2N8Bind = curCategory[i][1];

                case "P2 6K/7K Left 1": 
                    FlxG.save.data.P2L1Bind = curCategory[i][1];
                case "P2 6K/7K Up": 
                    FlxG.save.data.P2U1Bind = curCategory[i][1];
                case "P2 6K/7K Right 1": 
                    FlxG.save.data.P2R1Bind = curCategory[i][1];
                case "P2 6K/7K Left 2": 
                    FlxG.save.data.P2L2Bind = curCategory[i][1];
                case "P2 6K/7K Down": 
                    FlxG.save.data.P2D1Bind = curCategory[i][1];
                case "P2 6K/7K Right 2": 
                    FlxG.save.data.P2R2Bind = curCategory[i][1];
//////////////////////////////////////////////////////////////////////////////////////////
                case "Randomize Notes": 
                    SaveData.randomNotes = curCategory[i][1];
                case "Randomization Mode": 
                    SaveData.randomSection = curCategory[i][1];
                case "Randomize Note Speed": 
                    SaveData.randomNoteSpeed = curCategory[i][1];
                case "Randomize Note Velocity": 
                    SaveData.randomNoteVelocity = curCategory[i][1];
                case "Hellchart": 
                    SaveData.Hellchart = curCategory[i][1];
                case "Play As Oppenent": 
                    SaveData.flip = curCategory[i][1];
                case "Camera Movements on Note Hits": 
                    SaveData.noteMovements = curCategory[i][1];
////////////////////////////////////////////////////////////////////////////////////// stick ur custom options here
                case "your option": 
                    //stick da shit here
            }
        }

        (cast (Lib.current.getChildAt(0), Main)).changeFPS(SaveData.fps);
    }
}