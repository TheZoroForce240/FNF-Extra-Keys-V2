package;


import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.Lib;
import flixel.input.gamepad.FlxGamepad;
import flixel.util.FlxTimer;

class QuickOptions extends MusicBeatSubstate //kinda based on the keybind menu from kade engine, just wanted something simple, also a substate, so we got mid song options, kade engine is doing that now lol
{
    var curSelected:Int = 0;
    var waitingForInput:Bool = false;
    var gamepadInput = false;
    var justOpened = true; // for some reason it would open the first category when opening the menu, so i did this

    var daLARGEText:FlxText; 
    var infoText:FlxText;
    var BG:FlxSprite;
    
    var categories:Array<Dynamic>; //main section

    var gameplay:Array<Dynamic>;
    var misc:Array<Dynamic>;
    var keybinds:Array<Dynamic>;
    var P2keybinds:Array<Dynamic>;
    var gamepad:Array<Dynamic>;
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

        new FlxTimer().start(0.1, function(tmr:FlxTimer)
        {
            justOpened = false;
        });
    }

    override function update(elapsed:Float)
    {

        super.update(elapsed);

        var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;
        var back = controls.BACK;
        var leftP = controls.LEFT_P;
        var rightP = controls.RIGHT_P;

        if(back)
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
            

        if (!waitingForInput && !justOpened)
        {
            if (upP)
                changeSelected(-1);
            if (downP)
                changeSelected(1);
    
            if (leftP)
                changeOptionSetting(-1);
            if (rightP)
                changeOptionSetting(1);   
    
            if (accepted)
            {
                switch (curCategory[curSelected][2]) //option type for pressing enter
                {
                    case "toggle": 
                        curCategory[curSelected][1] = !curCategory[curSelected][1];
                        turnOptionsIntoSaveData();
                        SaveData.saveDataCheck();
                        reloadOptions();
                        createText();
                    case "cat": 
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
                            case "Gamepad Binds": 
                                curCategory = gamepad;
                                daCat = "Gamepad Binds";
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
                    case "keybind" | "gamepad": 
                        waitingForInput = true;
                        if (curCategory[curSelected][2] == "gamepad")
                            gamepadInput = true;
                        createText();
                    case "button": 
                        switch (curCategory[curSelected][0])
                        {
                            case "Quick DFJK": 
                                FlxG.save.data.binds = ["D", "F", "J", "K"];
                            case "Quick WASD": 
                                FlxG.save.data.binds = ["A", "S", "W", "D"];
                            case "Quick Arrow Keys": 
                                FlxG.save.data.binds = ["LEFT", "DOWN", "UP", "RIGHT"];
                            case "Quick AS^>": 
                                FlxG.save.data.binds = ["A", "S", "UP", "RIGHT"];
                            case "Reset All Keybinds": 
                                SaveData.resetBinds();
                            case "Customize HUD": 
                                openSubState(new HUDCustomizeSubstate());
                            
                        }
                        //turnOptionsIntoSaveData();
                        SaveData.saveDataCheck();
                        reloadOptions();
                        createText();
                }
            }   
        }
        else if (waitingForInput)
        {
            var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

            if (gamepadInput && gamepad != null)
            {
                if (gamepad.justPressed.ANY)
                    {
                        var key:String = "F"; //press f to pay respects
                        if (!gamepadInput)
                            key = FlxG.keys.getIsDown()[0].ID.toString(); //dont wanna add keyboard events to make this substate larger, but should work for most keys, it might break numpad though idk
                        else
                        {    
                            if (gamepad != null)
                                key = gamepad.firstJustPressedID().toString();
                        }
                            
                        if (key != "BACKSPACE" || key != "ESCAPE" || key != "ENTER")
                        {
                            curCategory[curSelected][1] = key;
                            turnOptionsIntoSaveData();
                            SaveData.saveDataCheck();
                            reloadOptions();
                            createText();
                        }
                        waitingForInput = false;
                        gamepadInput = false;
                        turnOptionsIntoSaveData();
                        SaveData.saveDataCheck();
                        reloadOptions();
                        createText();
                    }
            }
            else
            {
                if (FlxG.keys.justPressed.ANY)
                    {
                        var key:String = "F"; //press f to pay respects
                        if (!gamepadInput)
                            key = FlxG.keys.getIsDown()[0].ID.toString(); //dont wanna add keyboard events to make this substate larger, but should work for most keys, it might break numpad though idk
                        else
                        {    
                            if (gamepad != null)
                                key = gamepad.firstJustPressedID().toString();
                        }
                            
                        if (key != "BACKSPACE" || key != "ESCAPE" || key != "ENTER")
                        {
                            curCategory[curSelected][1] = key;
                            turnOptionsIntoSaveData();
                            SaveData.saveDataCheck();
                            reloadOptions();
                            createText();
                        }
                        waitingForInput = false;
                        gamepadInput = false;
                        turnOptionsIntoSaveData();
                        SaveData.saveDataCheck();
                        reloadOptions();
                        createText();
                    }
            }
            
        }
        

        if (curCategory[curSelected][1] < 1 && curCategory[curSelected][0] == "Scroll Speed") //checks
            curCategory[curSelected][1] = 1;
        else if (curCategory[curSelected][1] > 10 && curCategory[curSelected][0] == "Scroll Speed")
            curCategory[curSelected][1] = 10;
        else if (curCategory[curSelected][1] < 60 && curCategory[curSelected][0] == "FPS Cap")
            curCategory[curSelected][1] = 60;
        else if (curCategory[curSelected][1] > 300 && curCategory[curSelected][0] == "FPS Cap")
            curCategory[curSelected][1] = 300;
        else if (curCategory[curSelected][1] <= 0.1 && curCategory[curSelected][0] == "Song Speed Multi") //need to figure out a better way to do this, TODO
            curCategory[curSelected][1] = 0.1;
        else if (curCategory[curSelected][1] > 10 && curCategory[curSelected][0] == "Song Speed Multi")
            curCategory[curSelected][1] = 10;
            


        
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
            case "Scroll Speed" | "Song Speed Multi": 
                change = change / 10; //makes it 0.1
            case "FPS Cap": 
                change = change * 10; //makes it 10
        }
        if (curCategory[curSelected][2] == "slider")
            curCategory[curSelected][1]+= change;
        else if (curCategory[curSelected][2] == "mode")
        {
            if (curCategory[curSelected][0] == "Randomization Mode")
            {
                if (curCategory[curSelected][1] == "Normal")
                    curCategory[curSelected][1] = "Section Based";
                else
                    curCategory[curSelected][1] = "Normal";
            }
        }

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
            if (curCategory[i][2] == "slider" || curCategory[i][2] == "mode")
            {
                middleThing = " <";
                extraThing = ">";
            }
            if (curCategory[i][2] == "cat" || curCategory[i][2] == "button")
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
        //third thing is the option type (toggle, for Booleans. slider, for numbers (you can set up limits in update).keybind, pretty self explainatory, etc)
        //final thing in the array is the text at the bottom of the screen.

        //after you done this, you have to add a case inside turnOptionsIntoSaveData(), just copy paste one or something idk

        //make sure you dont mess up your commas lol
        categories = [
            ["Gameplay", "", "cat"],
            ["Misc", "", "cat"],
            ["Keybinds", "", "cat"],
            ["P2 Keybinds", "", "cat"],
            ["Gamepad Binds", "", "cat"],
            ["Randomization", "", "cat"],
            ["Customize HUD", "", "button"]
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
            ["Camera Movements on Note Hits", SaveData.noteMovements, "toggle", "the thing that every mod does now"],
            ["Scale Speed with Mania", SaveData.speedScaling, "toggle", "Scales down the speed based on note scale \n(so the same scroll speed should feel mostly the same for every mania)"]
        ];
    
        keybinds = [
            ["Quick DFJK","", "button", ""],
            ["Quick AS^>","", "button", ""],
            ["Quick WASD","", "button", ""],
            ["Quick Arrow Keys","", "button", ""],
            ["4K/5K Left", FlxG.save.data.binds[0][0], "keybind", ""],
            ["4K/5K Down", FlxG.save.data.binds[0][1], "keybind", ""],
            ["4K/5K Up", FlxG.save.data.binds[0][2], "keybind", ""],
            ["4K/5K Right", FlxG.save.data.binds[0][3], "keybind", ""],
            ["", "", "cat", ""],
            ["9K/8K Left 1", FlxG.save.data.binds[2][0], "keybind", ""],
            ["9K/8K Down 1", FlxG.save.data.binds[2][1], "keybind", ""],
            ["9K/8K Up 1", FlxG.save.data.binds[2][2], "keybind", ""],
            ["9K/8K Right 1", FlxG.save.data.binds[2][3], "keybind", ""],
            ["5K/7K/9K Middle", FlxG.save.data.binds[2][4], "keybind", ""],
            ["9K/8K Left 2", FlxG.save.data.binds[2][5], "keybind", ""],
            ["9K/8K Down 2", FlxG.save.data.binds[2][6], "keybind", ""],
            ["9K/8K Up 2", FlxG.save.data.binds[2][7], "keybind", ""],
            ["9K/8K Right 2", FlxG.save.data.binds[2][8], "keybind", ""],
            ["", "", "cat", ""],
            ["6K/7K Left 1", FlxG.save.data.binds[1][0], "keybind", ""],
            ["6K/7K Up", FlxG.save.data.binds[1][1], "keybind", ""],
            ["6K/7K Right 1", FlxG.save.data.binds[1][2], "keybind", ""],
            ["6K/7K Left 2", FlxG.save.data.binds[1][3], "keybind", ""],
            ["6K/7K Down", FlxG.save.data.binds[1][4], "keybind", ""],
            ["6K/7K Right 2", FlxG.save.data.binds[1][5], "keybind", ""],
            ["Reset All Keybinds","", "button", "includes P2 and gamepad!"]
        ];
        P2keybinds = [
            ["P2 4K/5K Left", FlxG.save.data.P2binds[0][0], "keybind", ""],
            ["P2 4K/5K Down", FlxG.save.data.P2binds[0][1], "keybind", ""],
            ["P2 4K/5K Up", FlxG.save.data.P2binds[0][2], "keybind", ""],
            ["P2 4K/5K Right", FlxG.save.data.P2binds[0][3], "keybind", ""],
            ["", "", "cat", ""],
            ["P2 9K/8K Left 1", FlxG.save.data.P2binds[2][0], "keybind", ""],
            ["P2 9K/8K Down 1", FlxG.save.data.P2binds[2][1], "keybind", ""],
            ["P2 9K/8K Up 1", FlxG.save.data.P2binds[2][2], "keybind", ""],
            ["P2 9K/8K Right 1", FlxG.save.data.P2binds[2][3], "keybind", ""],
            ["P2 5K/7K/9K Middle", FlxG.save.data.P2binds[2][4], "keybind", ""],
            ["P2 9K/8K Left 2", FlxG.save.data.P2binds[2][5], "keybind", ""],
            ["P2 9K/8K Down 2", FlxG.save.data.P2binds[2][6], "keybind", ""],
            ["P2 9K/8K Up 2", FlxG.save.data.P2binds[2][7], "keybind", ""],
            ["P2 9K/8K Right 2", FlxG.save.data.P2binds[2][8], "keybind", ""],
            ["", "", "cat", ""],
            ["P2 6K/7K Left 1", FlxG.save.data.P2binds[1][0], "keybind", ""],
            ["P2 6K/7K Up", FlxG.save.data.P2binds[1][1], "keybind", ""],
            ["P2 6K/7K Right 1", FlxG.save.data.P2binds[1][2], "keybind", ""],
            ["P2 6K/7K Left 2", FlxG.save.data.P2binds[1][3], "keybind", ""],
            ["P2 6K/7K Down", FlxG.save.data.P2binds[1][4], "keybind", ""],
            ["P2 6K/7K Right 2", FlxG.save.data.P2binds[1][5], "keybind", ""],
            ["Reset All Keybinds","", "button", "includes P1 and gamepad!"]
        ];

        gamepad = [
            ["Gamepad 4K/5K Left", FlxG.save.data.GPbinds[0][0], "gamepad", ""],
            ["Gamepad 4K/5K Down", FlxG.save.data.GPbinds[0][1], "gamepad", ""],
            ["Gamepad 4K/5K Up", FlxG.save.data.GPbinds[0][2], "gamepad", ""],
            ["Gamepad 4K/5K Right", FlxG.save.data.GPbinds[0][3], "gamepad", ""],
            ["", "", "cat", ""],
            ["Gamepad 9K/8K Left 1", FlxG.save.data.GPbinds[2][0], "gamepad", ""],
            ["Gamepad 9K/8K Down 1", FlxG.save.data.GPbinds[2][1], "gamepad", ""],
            ["Gamepad 9K/8K Up 1", FlxG.save.data.GPbinds[2][2], "gamepad", ""],
            ["Gamepad 9K/8K Right 1", FlxG.save.data.GPbinds[2][3], "gamepad", ""],
            ["Gamepad 5K/7K/9K Middle", FlxG.save.data.GPbinds[2][4], "gamepad", ""],
            ["Gamepad 9K/8K Left 2", FlxG.save.data.GPbinds[2][5], "gamepad", ""],
            ["Gamepad 9K/8K Down 2", FlxG.save.data.GPbinds[2][6], "gamepad", ""],
            ["Gamepad 9K/8K Up 2", FlxG.save.data.GPbinds[2][7], "gamepad", ""],
            ["Gamepad 9K/8K Right 2", FlxG.save.data.GPbinds[2][8], "gamepad", ""],
            ["", "", "cat", ""],
            ["Gamepad 6K/7K Left 1", FlxG.save.data.GPbinds[1][0], "gamepad", ""],
            ["Gamepad 6K/7K Up", FlxG.save.data.GPbinds[1][1], "gamepad", ""],
            ["Gamepad 6K/7K Right 1", FlxG.save.data.GPbinds[1][2], "gamepad", ""],
            ["Gamepad 6K/7K Left 2", FlxG.save.data.GPbinds[1][3], "gamepad", ""],
            ["Gamepad 6K/7K Down", FlxG.save.data.GPbinds[1][4], "gamepad", ""],
            ["Gamepad 6K/7K Right 2", FlxG.save.data.GPbinds[1][5], "gamepad", ""],
            ["Reset All Keybinds","", "button", "includes keyboard Keybinds!"]
        ];
    
        randomization = [
            ["Randomize Notes", SaveData.randomNotes, "toggle", "what else do you think it does"],
            ["Randomization Mode", SaveData.randomizationMode, "mode", "change the mode, please just use section based it makes good charts"],
            ["Randomize Note Speed", SaveData.randomNoteSpeed, "toggle", "yes pain"],
            ["Randomize Note Velocity", SaveData.randomNoteVelocity, "toggle", "now its even worse"],
            ["Hellchart", SaveData.Hellchart, "toggle", "oh fuck it gets worse"],
            ["Play As Oppenent", SaveData.flip, "toggle", "figure it out lol"],
            ["Song Speed Multi", PlayState.SongSpeedMultiplier, "slider", "change the song speed"],
            ["Random Speed Change", PlayState.RandomSpeedChange, "toggle", "randomly change the speed"]
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
            case "Gamepad Binds": 
                curCategory = gamepad;
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
        if (daCat == "Keybinds")
        {
            
        }
        switch (daCat) //reminder to change this if new stuff is added to keybind options category
        {
            case "Keybinds": 
                FlxG.save.data.binds = [
                    [curCategory[4][1], curCategory[5][1], curCategory[6][1], curCategory[7][1]],
                    [curCategory[19][1], curCategory[20][1], curCategory[21][1], curCategory[22][1], curCategory[23][1], curCategory[24][1]],
                    [curCategory[9][1], curCategory[10][1], curCategory[11][1], curCategory[12][1], curCategory[13][1], curCategory[14][1], curCategory[15][1], curCategory[16][1], curCategory[17][1]]
                ];
            case "P2 Keybinds": 
                FlxG.save.data.P2binds = [
                    [curCategory[0][1], curCategory[1][1], curCategory[2][1], curCategory[3][1]],
                    [curCategory[15][1], curCategory[16][1], curCategory[17][1], curCategory[18][1], curCategory[19][1], curCategory[20][1]],
                    [curCategory[5][1], curCategory[6][1], curCategory[7][1], curCategory[8][1], curCategory[9][1], curCategory[10][1], curCategory[11][1], curCategory[12][1], curCategory[13][1]]
                ]; 
            case "Gamepad Binds": 
                FlxG.save.data.GPbinds = [
                    [curCategory[0][1], curCategory[1][1], curCategory[2][1], curCategory[3][1]],
                    [curCategory[15][1], curCategory[16][1], curCategory[17][1], curCategory[18][1], curCategory[19][1], curCategory[20][1]],
                    [curCategory[5][1], curCategory[6][1], curCategory[7][1], curCategory[8][1], curCategory[9][1], curCategory[10][1], curCategory[11][1], curCategory[12][1], curCategory[13][1]]
                ]; 
        }

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
/////////////////////////////////////////////////////////////////////////////////////////
                case "Randomize Notes": 
                    SaveData.randomNotes = curCategory[i][1];
                case "Randomization Mode": 
                    SaveData.randomizationMode = curCategory[i][1];
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
                case "Scale Speed with Mania":
                    SaveData.speedScaling = curCategory[i][1];
                case "Song Speed Multi":
                    PlayState.SongSpeedMultiplier = curCategory[i][1]; 
                case "Random Speed Change":
                    PlayState.RandomSpeedChange = curCategory[i][1]; 
////////////////////////////////////////////////////////////////////////////////////// stick ur custom options here
                case "your option": 
                    //stick da shit here
            }
        }

        (cast (Lib.current.getChildAt(0), Main)).changeFPS(SaveData.fps);
    }
}