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



class QuickOptions extends FlxSubState //kinda based on the keybind menu from kade engine, just wanted something simple
{
    var curSelected:Int = 0;

    var daLARGEText:FlxText; 
    var infoText:FlxText;

    var BG:FlxSprite;

    //name, savedata, true = on/off false = slider, info
    var options:Array<Dynamic> = [ 
        ["Ghost Tapping", SaveData.ghost, true, "Turning on this means you dont miss when misspressing a note"],
        ["P1 Downscroll", SaveData.downscroll, true, "Flip Da Notes"],
        ["P2 Downscroll", SaveData.P2downscroll, true, "Flip Da Notes but for the second guy"],
        ["Multiplayer", SaveData.multiplayer, true, "Turn on to play with a friend locally\n(or just play both side because you have no friends)"],
        ["Middlescroll", SaveData.middlescroll, true, "Center your Notes"],
        ["Note Splash", SaveData.noteSplash, true, "Turn on the funni effect when hitting sicks"],
        ["Scroll Speed", SaveData.ScrollSpeed, false, "Change the default scroll speed (does not include notes changed by the chart)"],
        ["FPS Cap", SaveData.fps, false, "Turn up for more frames"],
        ["Casual Mode", SaveData.casual, true, "More Spammable Input, Heal from Sustains and no health loss from bad accuracy"],
        ["", "", false, "how did you get here"],
        ["Randomize Notes (not added)", SaveData.randomNotes, true, "what else do you think it does"],
        ["Randomization Mode (not added)", SaveData.randomSection, true, "change the mode, please just use section based it makes good charts"],
        ["Randomize Note Speed", SaveData.randomNoteSpeed, true, "yes pain"],
        ["Randomize Note Velocity", SaveData.randomNoteVelocity, true, "now its even worse"],
        ["Hellchart (not added)", SaveData.Hellchart, true, "oh fuck it gets worse"],
        ["Play As Oppenent", SaveData.flip, true, "figure it out lol"]
    ];
	override function create()
    {	
        BG = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
        add(BG);
        BG.alpha = 0.5;
        BG.scrollFactor.set();

        daLARGEText = new FlxText(-10, 0, 1000, "", 32);
		daLARGEText.scrollFactor.set(0, 0);
		daLARGEText.setFormat("VCR OSD Mono", 28, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        daLARGEText.screenCenter(X);
        add(daLARGEText);
        daLARGEText.scrollFactor.set();

        infoText = new FlxText(-10, 600, 1000, 32);
		infoText.scrollFactor.set(0, 0);
		infoText.setFormat("VCR OSD Mono", 28, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        infoText.screenCenter(X);
        add(infoText);
        infoText.scrollFactor.set();

        createText();

        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
    }

    override function update(elapsed:Float)
    {
        if(FlxG.keys.justPressed.ESCAPE)
            exit();

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
            if (options[curSelected][2] == true)
            {
                options[curSelected][1] = !options[curSelected][1];
                turnOptionsIntoSaveData();
                SaveData.saveDataCheck();
                reloadOptions();
                createText();
            }
        }   

        if (options[6][1] < 1 || options[6][1] > 10) //scroll speed
            options[6][1] = 1;
        if (options[7][1] < 60 || options[7][1] > 300) //fps cap
            options[7][1] = 60;

            


        super.update(elapsed);
    }

    function exit()
    {
        SaveData.saveTheData();
        close();
    }

    function changeOptionSetting(change:Float = 0)
    {
        switch(options[curSelected][0])
        {
            case "Scroll Speed": 
                change = change / 10; //makes it 0.1
            case "FPS Cap": 
                change = change * 10; //makes it 10
        }
        if (options[curSelected][2] == false)
            options[curSelected][1]+= change;

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
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

        if (options[curSelected][0] == "")
            curSelected += change; //skips empty shit

        createText();
    }

    function createText()
    {
        daLARGEText.text = "\n";
        for (i in 0...options.length)
        {
            /////////////////////////////
            var isToggle = options[i][2];
            var ToggleText:String = "On";
            if (options[i][1])
                ToggleText = "On";
            else
                ToggleText = "Off";

            if (!isToggle)
                ToggleText = options[i][1];
            //////////////////////////

            var text = (options[i][0] + " : " + ToggleText);
            var isSelected = "";
            if (i == curSelected)
                isSelected = " <---";
            daLARGEText.text += text + isSelected + "\n";
        }
        infoText.text = options[curSelected][3];
    }

    function reloadOptions()
    {
        options = [
            ["Ghost Tapping", SaveData.ghost, true, "Turning on this means you dont miss when misspressing a note"],
            ["P1 Downscroll", SaveData.downscroll, true, "Flip Da Notes"],
            ["P2 Downscroll", SaveData.P2downscroll, true, "Flip Da Notes but for the second guy"],
            ["Multiplayer", SaveData.multiplayer, true, "Turn on to play with a friend locally\n(or just play both side because you have no friends)"],
            ["Middlescroll", SaveData.middlescroll, true, "Center your Notes"],
            ["Note Splash", SaveData.noteSplash, true, "Turn on the funni effect when hitting sicks"],
            ["Scroll Speed", SaveData.ScrollSpeed, false, "Change the default scroll speed (does not include notes changed by the chart)"],
            ["FPS Cap", SaveData.fps, false, "Turn up for more frames"],
            ["Casual Mode", SaveData.casual, true, "More Spammable Input, Heal from Sustains and no health loss from bad accuracy"],
            ["", "", false, "how did you get here"],
            ["Randomize Notes (not added)", SaveData.randomNotes, true, "what else do you think it does"],
            ["Randomization Mode (not added)", SaveData.randomSection, true, "change the mode, please just use section based it makes good charts"],
            ["Randomize Note Speed", SaveData.randomNoteSpeed, true, "yes pain"],
            ["Randomize Note Velocity", SaveData.randomNoteVelocity, true, "now its even worse"],
            ["Hellchart (not added)", SaveData.Hellchart, true, "oh fuck it gets worse"],
            ["Play As Oppenent", SaveData.flip, true, "figure it out lol"]
        ];
    }

    function turnOptionsIntoSaveData()
    {
        SaveData.ghost = options[0][1];
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
        SaveData.flip = options[15][1];

        (cast (Lib.current.getChildAt(0), Main)).changeFPS(SaveData.fps);
    }
}