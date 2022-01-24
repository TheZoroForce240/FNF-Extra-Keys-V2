package;


import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.Lib;
import flixel.input.gamepad.FlxGamepad;
import flixel.util.FlxTimer;
import flixel.ui.FlxBar;
import flixel.math.FlxMath;

class HUDCustomizeSubstate extends MusicBeatSubstate
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

    private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
    var centerHealthBar:Bool = false;
	var scoreTxt:FlxText;
	var timeText:FlxText;
	var songtext:String; //for time text
	var modeText:String; //also for time text

	var hudThing:FlxTextAlign = LEFT;
	var songhudThing:FlxTextAlign = CENTER;

    var inCat:Bool = false;
    var curCategory:Array<Dynamic>; //actual category
    var daCat:String = "";

    var health:Float = 1;

    public var P1Stats = {
		songScore : 0,
		fc : true,
		sicks : 0,
		goods : 0,
		bads : 0,
		shits : 0,
		misses : 0,
		ghostmisses : 0,
		totalNotesHit : 0,
		accuracy : 0.0,
		curRank : "None",
		combo : 0,
		highestCombo : 0,
		nps : 0,
		highestNps : 0,
		health : 1.0,
		poisonHits : 0,
		scorelerp : 0,
		acclerp : 0.0
	};

	override function create()
    {	
        reloadOptions();

        curCategory = categories;

        BG = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
        add(BG);
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
        createHud();
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
                        createHud();
                        createText();
                }
            }  
            
            
        }

        if (curCategory[curSelected][1] <= 0.1 && curCategory[curSelected][0] == "Lane Opacity") //need to figure out a better way to do this, TODO
            curCategory[curSelected][1] = 0.1;
        else if (curCategory[curSelected][1] > 1 && curCategory[curSelected][0] == "Lane Opacity")
            curCategory[curSelected][1] = 1;
        if (curCategory[curSelected][1] <= 0.1 && curCategory[curSelected][0] == "Hud Opacity") //need to figure out a better way to do this, TODO
            curCategory[curSelected][1] = 0.1;
        else if (curCategory[curSelected][1] > 1 && curCategory[curSelected][0] == "Hud Opacity")
            curCategory[curSelected][1] = 1;

        P1Stats.scorelerp = Math.floor(FlxMath.lerp(P1Stats.scorelerp, P1Stats.songScore, 0.4)); //funni lerp
		P1Stats.acclerp = FlxMath.roundDecimal(FlxMath.lerp(P1Stats.acclerp, P1Stats.accuracy, 0.4), 2);

		if (Math.abs(P1Stats.scorelerp - P1Stats.songScore) <= 10)
			P1Stats.scorelerp = P1Stats.songScore;

		if ((P1Stats.acclerp - P1Stats.accuracy) <= 0.05)
			P1Stats.acclerp = P1Stats.accuracy;

		var score = "Score:" + P1Stats.scorelerp;
		var rank = "Rank: " + P1Stats.curRank;
		var acc = "Accuracy: " + P1Stats.acclerp + "%";
		var miss = "Misses: " + P1Stats.misses;

		var timeLeft = 10000 - 1000;
		var time:Date = Date.fromTime(timeLeft);
		var mins = time.getMinutes();
		var secs = time.getSeconds();
		var multitext:String = "(x" + FlxMath.roundDecimal(PlayState.SongSpeedMultiplier, 2) + ")";
		if (PlayState.SongSpeedMultiplier == 1)
			multitext = "";
		var time = "";
		if (secs < 10) //so it looks right
			time = " - " + mins + ":" + "0" + secs; 
		else
			time = " - " + mins + ":" + secs; 

		var sick = "Sicks: " + P1Stats.sicks;
		var good = "Goods: " + P1Stats.goods;
		var bad = "Bads: " + P1Stats.bads;
		var shit = "Shits: " + P1Stats.shits;
		var ghost = "Ghost Misses: " + P1Stats.ghostmisses;
		var comb = "Combo: " + P1Stats.combo;
		var highestcomb = "Highest Combo: " + P1Stats.highestCombo;
		var nps = "NPS: " + P1Stats.nps;
		var highestnps = "Highest NPS: " + P1Stats.highestNps;
		var hp = "Health: " + Math.round(healthBar.percent) + "%";




		var listOShit = [score, rank, acc, miss, "", "", sick, good, bad, shit, ghost, comb, highestcomb, nps, highestnps, hp];


        scoreTxt.text = "";
        timeText.text = "";
        for (i in 0...SaveData.enabledHudSections.length)
        {
            if (SaveData.enabledHudSections[i] == true)
            {
                if (i == 4 || i == 5) //timer/songname text
                {
                    if (i == 4)
                    {
                        timeText.text += songtext + multitext;
                        if (!SaveData.enabledHudSections[5])
                            timeText.text += modeText; //add mode text if no timer
                    }
                    else if (i == 5)
                    {
                        timeText.text += time;
                        if (SaveData.enabledHudSections[4])
                            timeText.text += modeText; //add mode text after timer
                    }
                }
                else 
                {
                    if ((i == 6 || i == 11) && SaveData.hudPos == "Default")
                        scoreTxt.text += "\n";

                    if (SaveData.hudPos != "Default")
                        scoreTxt.text += "\n";
                    else
                        scoreTxt.text += "|";

                    scoreTxt.text += listOShit[i];

                    if (SaveData.hudPos == "Default")
                        scoreTxt.text += "|";

                }
            }
        }
        
    }

    function exit()
    {
        SaveData.saveTheData();
        close();
    }

    function changeOptionSetting(change:Float = 0)
    {

        if (curCategory[curSelected][2] == "mode")
        {
            var list = ["Default", "Left", "Right"];
            switch (curCategory[curSelected][0])
            {
                case "Health Bar Position": 
                    list = ["Default", "Left", "Right", "Center"];
                case "Arrow Lanes/backing": 
                    list = ["Off", "Colored", "Black"];
            }
            var selected:Int = 0; //backup or something idk
            selected = list.indexOf(curCategory[curSelected][1]);
            selected += Std.int(change);
            if (selected < 0)
                selected = list.length - 1;
            if (selected >= list.length)
                selected = 0;

            curCategory[curSelected][1] = list[selected];
        }
        else if (curCategory[curSelected][2] == "slider")
        {
            switch(curCategory[curSelected][0])
            {
                case "Lane Opacity" | "Hud Opacity": 
                    change = change / 10; //makes it 0.1
            }

            curCategory[curSelected][1]+= change;
        }

        turnOptionsIntoSaveData();
        SaveData.saveDataCheck();
        reloadOptions();
        createHud();
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
        //haha copy pasted lol
        categories = [
            ["Score Hud Position", SaveData.hudPos, "mode"],
            ["Song Name/Time Hud Position", SaveData.songhudPos, "mode"],
            ["Score", SaveData.enabledHudSections[0], "toggle"],
            ["Rank", SaveData.enabledHudSections[1], "toggle"],
            ["Accuracy", SaveData.enabledHudSections[2], "toggle"],
            ["Misses", SaveData.enabledHudSections[3], "toggle"],
            ["Song Name", SaveData.enabledHudSections[4], "toggle"],
            ["Timer", SaveData.enabledHudSections[5], "toggle"],
            ["", "", "cat", ""],
            ["Sicks", SaveData.enabledHudSections[6], "toggle"],
            ["Goods", SaveData.enabledHudSections[7], "toggle"],
            ["Bads", SaveData.enabledHudSections[8], "toggle"],
            ["Shits", SaveData.enabledHudSections[9], "toggle"],
            ["Ghost Misses",SaveData.enabledHudSections[10], "toggle"],
            ["Combo", SaveData.enabledHudSections[11], "toggle"],
            ["Highest Combo", SaveData.enabledHudSections[12], "toggle"],
            ["NPS", SaveData.enabledHudSections[13], "toggle"],
            ["Highest NPS", SaveData.enabledHudSections[14], "toggle"],
            ["", "", ""],
            ["Arrow Lanes/backing", SaveData.arrowLanes, "mode"],
            ["Lane Opacity", SaveData.laneOpacity, "slider"],
            ["Health Bar Position", SaveData.hpBarPos, "mode", "Auto-Centers if P1 scroll is not the same as P2 scroll"],
            ["Hud Opacity", SaveData.hudOpacity, "slider"],
        ];
        //name, savedata, type of option, info
        
        curCategory = categories; //backup
    }

    function turnOptionsIntoSaveData()
    {

        for (i in 0...curCategory.length)
        {
            switch (curCategory[i][0])
            {
                case "Random Speed Change":
                    PlayState.RandomSpeedChange = curCategory[i][1]; 

                case "Score Hud Position":
                    SaveData.hudPos = curCategory[i][1]; 
                case "Song Name/Time Hud Position":
                    SaveData.songhudPos = curCategory[i][1]; 
                case "Health Bar Position":
                    SaveData.hpBarPos = curCategory[i][1]; 
                case "Hud Opacity":
                    SaveData.hudOpacity = curCategory[i][1]; 
                case "Score":
                    SaveData.enabledHudSections[0] = curCategory[i][1]; 
                case "Rank":
                    SaveData.enabledHudSections[1] = curCategory[i][1]; 
                case "Accuracy":
                    SaveData.enabledHudSections[2] = curCategory[i][1]; 
                case "Misses":
                    SaveData.enabledHudSections[3] = curCategory[i][1]; 
                case "Song Name":
                    SaveData.enabledHudSections[4] = curCategory[i][1]; 
                case "Timer":
                    SaveData.enabledHudSections[5] = curCategory[i][1]; 
                case "Sicks":
                    SaveData.enabledHudSections[6] = curCategory[i][1]; 
                case "Goods":
                    SaveData.enabledHudSections[7] = curCategory[i][1]; 
                case "Bads":
                    SaveData.enabledHudSections[8] = curCategory[i][1]; 
                case "Shits":
                    SaveData.enabledHudSections[9] = curCategory[i][1]; 
                case "Ghost Misses":
                    SaveData.enabledHudSections[10] = curCategory[i][1]; 
                case "Combo":
                    SaveData.enabledHudSections[11] = curCategory[i][1]; 
                case "Highest Combo":
                    SaveData.enabledHudSections[12] = curCategory[i][1]; 
                case "NPS":
                    SaveData.enabledHudSections[13] = curCategory[i][1]; 
                case "Highest NPS":
                    SaveData.enabledHudSections[14] = curCategory[i][1]; 
                case "Health Percentage":
                    SaveData.enabledHudSections[15] = curCategory[i][1]; 
                case "Arrow Lanes/backing":
                    SaveData.arrowLanes = curCategory[i][1]; 
                case "Lane Opacity": 
                    SaveData.laneOpacity = curCategory[i][1]; 
            }
        }
    }

    function createHud()
    {
        if (healthBarBG != null)
        {
            remove(healthBarBG);
            remove(healthBar);
            remove(scoreTxt);
            remove(timeText);
        }
        



        healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar', 'shared'));

		switch(SaveData.hpBarPos)
		{
			case "Left" | "Right" | "Center": 
				centerHealthBar = true;
            case "Default": 
                centerHealthBar = false;
		}


		if (centerHealthBar)
		{
			healthBarBG.screenCenter(Y); 
			healthBarBG.angle = 90;
		}


		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);
		if (SaveData.downscroll && !centerHealthBar)
			healthBarBG.y = FlxG.height * 0.1;



        healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
        'health', 0, 2);


		if (centerHealthBar)
			healthBar.angle = 90;

		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		add(healthBar);		



		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 540, healthBarBG.y + 30, 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, hudThing, OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();

		timeText = new FlxText(healthBarBG.x + healthBarBG.width - 540, healthBarBG.y - 60, 0, "", 20);
		timeText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		timeText.scrollFactor.set();

		if (centerHealthBar)
		{
			timeText.y = (FlxG.height * 0.1) - 60;
			if (SaveData.hudPos == "Default")
				scoreTxt.y = (FlxG.height * 0.9) + 30;
		}

		switch (SaveData.hudPos)
		{
			case "Left": 
				scoreTxt.x = 20;
				scoreTxt.y = 250;
			case "Right": 
				scoreTxt.x = FlxG.width - 160;
				scoreTxt.y = 250;
				hudThing = RIGHT;
		}

		switch (SaveData.songhudPos)
		{
			case "Left": 
				timeText.x = 20;
				songhudThing = LEFT;
			case "Right": 
				timeText.x = FlxG.width - 400;
				songhudThing = RIGHT;
		}

		switch (SaveData.hpBarPos)
		{
			case "Left": 
				healthBarBG.x = -200;
				healthBar.x = healthBarBG.x + 4;
			case "Right": 
				healthBarBG.x = FlxG.width - 400;
				healthBar.x = healthBarBG.x + 4;
		}

		timeText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, songhudThing, OUTLINE, FlxColor.BLACK); //update it
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, hudThing, OUTLINE, FlxColor.BLACK);

        add(scoreTxt);
        add(timeText);
    }
}