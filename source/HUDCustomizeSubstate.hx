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

    var inCat:Bool = false;
    var curCategory:Array<Dynamic>; //actual category
    var daCat:String = "";

    var rating:FlxSprite;
    var combo:FlxSprite;

    var hudSprites:Array<FlxSprite> = [];

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

        daLARGEText = new FlxText(0, 0, 1000, "", 32);
		daLARGEText.scrollFactor.set(0, 0);
		daLARGEText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        daLARGEText.screenCenter(X);
        add(daLARGEText);
        daLARGEText.scrollFactor.set();
        daLARGEText.alpha = 0.75;

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
            

        if (!waitingForInput)
        {
            if (upP)
                changeSelected(-1);
            if (downP)
                changeSelected(1);
    
            if (leftP)
                changeOptionSetting(-1);
            if (rightP)
                changeOptionSetting(1);   
    
            if (accepted && !justOpened)
            {
                switch (curCategory[curSelected][2]) //option type for pressing enter
                {
                    case "toggle": 
                        curCategory[curSelected][1] = !curCategory[curSelected][1];
                        turnOptionsIntoSaveData();
                        SaveData.saveTheData();
                        reloadOptions();
                        createHud();
                        createText();
                    case 'button': 
                        switch(curCategory[curSelected][0])
                        {
                            case 'Reset HUD': 
                                SaveData.ResetHud();
                        }
                }
            }  
        }


        daLARGEText.y = FlxMath.lerp(daLARGEText.y, (FlxG.height / 2) + (-32 * curSelected), 0.16);
    
        for (i in 0...curCategory.length)
        {
            switch (curCategory[i][0])
            {
                case "Hud Opacity" | 'Lane Opacity':
                    if (curCategory[i][1] < 0) //need to figure out a better way to do this, TODO
                        curCategory[i][1] = 0;
                    else if (curCategory[i][1] > 1)
                        curCategory[i][1] = 1;
                case "Score Hud Size" | 'Song Name/Time Hud Size':
                    if (curCategory[i][1] < 4) 
                        curCategory[i][1] = 4;
                    else if (curCategory[i][1] > 128)
                        curCategory[i][1] = 128;
                case "Health Bar Width":
                    if (curCategory[i][1] < 0.1) 
                        curCategory[i][1] = 0.1;
                    else if (curCategory[i][1] > 2.5)
                        curCategory[i][1] = 2.5;
            }
        }



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

        var statsToUse = P1Stats;

		var listOfShit:Map<String, String> = [ 
			'score' => "Score:" + statsToUse.songScore,
			'rank' => "Rank: " + statsToUse.curRank,
			'acc' => "Accuracy: " + statsToUse.accuracy + "%",
			'misses' => "Misses: " + statsToUse.misses,
			'sicks' => "Sicks: " + statsToUse.sicks,
			'goods' => "Goods: " + statsToUse.goods,
			'bads' => "Bads: " + statsToUse.bads,
			'shits' => "Shits: " + statsToUse.shits,
			'ghostMisses' => "Ghost Misses: " + statsToUse.ghostmisses,
			'combo' => "Combo: " + statsToUse.combo,
			'highestCombo' => "Highest Combo: " + statsToUse.highestCombo,
			'nps' => "NPS: " + statsToUse.nps,
			'highestNps' => "Highest NPS: " + statsToUse.highestNps
		];

        var orderOfShit = ['score', 'rank', 'acc', 'misses', 'sicks', 'goods', 'bads', 'shits', 'ghostMisses', 'combo', 'highestCombo', 'nps', 'highestNps'];

        scoreTxt.text = "";
        timeText.text = "";
		var addTime = 0;
		for (i in 0...orderOfShit.length)
        {
            if (SaveData.hudTexts.get(orderOfShit[i]))
            {
                switch(orderOfShit[i])
                {
                    case 'song' | 'timer': 
                        //do nothing cuz its done in updateTimer()
                    default: 
                        if ((addTime == 6 || addTime == 11) && SaveData.hudPositions.get('scoreAlign') == FlxTextAlign.CENTER)
                            scoreTxt.text += "\n";
    
                        if (SaveData.hudPositions.get('scoreAlign') != FlxTextAlign.CENTER)
                            scoreTxt.text += "\n";
                        else
                            scoreTxt.text += "|";
    
                        scoreTxt.text += listOfShit.get(orderOfShit[i]);
    
                        if (SaveData.hudPositions.get('scoreAlign') == FlxTextAlign.CENTER)
                            scoreTxt.text += "|";
                        addTime++;
                }
            }
        }
        for (shit => fuck in SaveData.hudTexts)
        {
            if (fuck)
            {
                if (shit == 'song')
                {
                    timeText.text += songtext + multitext;
                    if (!SaveData.hudTexts.get('timer'))
                        timeText.text += modeText; //add mode text if no timer
                }
                else if (shit == 'timer')
                {
                    timeText.text += time;
                    if (SaveData.hudTexts.get('song'))
                        timeText.text += modeText; //add mode text after timer
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
        if (FlxG.keys.pressed.SHIFT)
            change *= 10;
        if (curCategory[curSelected][2] == "mode")
        {
            var list = ["Off", "Colored", "Black"];
            var selected:Int = 0; //backup or something idk
            selected = list.indexOf(curCategory[curSelected][1]);
            if (selected == -1)
                selected = 1;
            selected += Std.int(change);
            if (selected < 0)
                selected = list.length - 1;
            if (selected >= list.length)
                selected = 0;

            curCategory[curSelected][1] = list[selected];
        }
        if (curCategory[curSelected][2] == "align")
        {
            var list:Array<Dynamic> = [FlxTextAlign.CENTER, FlxTextAlign.LEFT, FlxTextAlign.RIGHT];

            var selected:Int = 0; //backup or something idk
            selected = list.indexOf(curCategory[curSelected][1]);
            if (selected == -1)
                selected = 1;
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
                case "Lane Opacity" | "Hud Opacity" | "Health Bar Width":
                    change = change / 10; //makes it 0.1
            }

            curCategory[curSelected][1] += change;
        }

        turnOptionsIntoSaveData();
        SaveData.saveTheData();
        reloadOptions();
        createHud();
        createText();
    }

    function changeSelected(change:Int = 0)
    {
        FlxG.sound.play(Paths.sound('scrollMenu'));
        curSelected += change;

        justOpened = false;

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
            if (curCategory[i][2] == "slider" || curCategory[i][2] == "mode" || curCategory[i][2] == "align")
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
            ["Score Hud Position", SaveData.hudPositions.get('scoreAlign'), "align"],
            ["Score Hud Offset X", SaveData.hudPositions.get('score')[0], "slider"],
            ["Score Hud Offset Y", SaveData.hudPositions.get('score')[1], "slider"],
            ["Score Hud Size", SaveData.hudPositions.get('scoreSize'), "slider"],
            ["", "", ""],
            ["Song Name/Time Hud Position", SaveData.hudPositions.get('songAlign'), "align"],
            ["Song Name/Time Hud Offset X", SaveData.hudPositions.get('song')[0], "slider"],
            ["Song Name/Time Hud Offset Y", SaveData.hudPositions.get('song')[1], "slider"],
            ["Song Name/Time Hud Size", SaveData.hudPositions.get('songSize'), "slider"],
            ["", "", ""],
            ["Health Bar Position", SaveData.hudPositions.get('healthBarAlign'), "align", "Auto-Centers if P1 scroll is not the same as P2 scroll"],
            ["Health Bar Offset X", SaveData.hudPositions.get('healthBar')[0], "slider"],
            ["Health Bar Offset Y", SaveData.hudPositions.get('healthBar')[1], "slider"],
            ["Health Bar Width", SaveData.hudPositions.get('healthBarWidth'), "slider"],
            ["Vertical Health Bar", SaveData.hudPositions.get('verticalHealthBar'), "toggle"],
            ["", "", ""],
            ["Combo Offset X", SaveData.hudPositions.get('combo')[0], "slider"],
            ["Combo Offset Y", SaveData.hudPositions.get('combo')[1], "slider"],
            ["", "", ""],
            ["Rating Offset X", SaveData.hudPositions.get('rating')[0], "slider"],
            ["Rating Offset Y", SaveData.hudPositions.get('rating')[1], "slider"],
            ["", "", ""],
            ["Arrow Lanes/backing", SaveData.arrowLanes, "mode"],
            ["Lane Opacity", SaveData.laneOpacity, "slider"],
            ["Hud Opacity", SaveData.hudOpacity, "slider"],
            ["", "", ""],
            ["Score", SaveData.hudTexts.get('score'), "toggle"],
            ["Rank", SaveData.hudTexts.get('rank'), "toggle"],
            ["Accuracy", SaveData.hudTexts.get('acc'), "toggle"],
            ["Misses", SaveData.hudTexts.get('misses'), "toggle"],
            ["Song Name", SaveData.hudTexts.get('song'), "toggle"],
            ["Timer", SaveData.hudTexts.get('timer'), "toggle"],
            ["Sicks", SaveData.hudTexts.get('sicks'), "toggle"],
            ["Goods", SaveData.hudTexts.get('goods'), "toggle"],
            ["Bads", SaveData.hudTexts.get('bads'), "toggle"],
            ["Shits", SaveData.hudTexts.get('shits'), "toggle"],
            ["Ghost Misses",SaveData.hudTexts.get('ghostMisses'), "toggle"],
            ["Combo", SaveData.hudTexts.get('combo'), "toggle"],
            ["Highest Combo", SaveData.hudTexts.get('highestCombo'), "toggle"],
            ["NPS", SaveData.hudTexts.get('nps'), "toggle"],
            ["Highest NPS", SaveData.hudTexts.get('highestNps'), "toggle"],
            ["", "", ""],
            ["Reset HUD", '', "button"],
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
                case "Score Hud Position":
                    SaveData.hudPositions.set('scoreAlign', curCategory[i][1]);
                case "Song Name/Time Hud Position":
                    SaveData.hudPositions.set('songAlign', curCategory[i][1]); 
                case "Health Bar Position":
                    SaveData.hudPositions.set('healthBarAlign', curCategory[i][1]);
                case "Hud Opacity":
                    SaveData.hudOpacity = curCategory[i][1]; 
                case "Score":
                    SaveData.hudTexts.set('score', curCategory[i][1]);
                case "Rank":
                    SaveData.hudTexts.set('rank', curCategory[i][1]);
                case "Accuracy":
                    SaveData.hudTexts.set('acc', curCategory[i][1]); 
                case "Misses":
                    SaveData.hudTexts.set('misses', curCategory[i][1]);
                case "Song Name":
                    SaveData.hudTexts.set('song', curCategory[i][1]);
                case "Timer":
                    SaveData.hudTexts.set('timer', curCategory[i][1]); 
                case "Sicks":
                    SaveData.hudTexts.set('sicks', curCategory[i][1]);
                case "Goods":
                    SaveData.hudTexts.set('goods', curCategory[i][1]);
                case "Bads":
                    SaveData.hudTexts.set('bads', curCategory[i][1]);
                case "Shits":
                    SaveData.hudTexts.set('shits', curCategory[i][1]);
                case "Ghost Misses":
                    SaveData.hudTexts.set('ghostMisses', curCategory[i][1]); 
                case "Combo":
                    SaveData.hudTexts.set('combo', curCategory[i][1]); 
                case "Highest Combo":
                    SaveData.hudTexts.set('highestCombo', curCategory[i][1]);
                case "NPS":
                    SaveData.hudTexts.set('nps', curCategory[i][1]);
                case "Highest NPS":
                    SaveData.hudTexts.set('highestNps', curCategory[i][1]);
                case "Arrow Lanes/backing":
                    SaveData.arrowLanes = curCategory[i][1]; 
                case "Lane Opacity": 
                    SaveData.laneOpacity = curCategory[i][1]; 

                case "Score Hud Offset X":
                    SaveData.hudPositions.set('score', [curCategory[i][1], SaveData.hudPositions.get('score')[1]]);
                case "Score Hud Offset Y":
                    SaveData.hudPositions.set('score', [SaveData.hudPositions.get('score')[0], curCategory[i][1]]);

                case "Song Name/Time Hud Offset X":
                    SaveData.hudPositions.set('song', [curCategory[i][1], SaveData.hudPositions.get('song')[1]]);
                case "Song Name/Time Hud Offset Y":
                    SaveData.hudPositions.set('song', [SaveData.hudPositions.get('song')[0], curCategory[i][1]]);

                case "Health Bar Offset X":
                    SaveData.hudPositions.set('healthBar', [curCategory[i][1], SaveData.hudPositions.get('healthBar')[1]]);
                case "Health Bar Offset Y":
                    SaveData.hudPositions.set('healthBar', [SaveData.hudPositions.get('healthBar')[0], curCategory[i][1]]);

                case "Combo Offset X":
                    SaveData.hudPositions.set('combo', [curCategory[i][1], SaveData.hudPositions.get('combo')[1]]);
                case "Combo Offset Y":
                    SaveData.hudPositions.set('combo', [SaveData.hudPositions.get('combo')[0], curCategory[i][1]]);

                case "Rating Offset X":
                    SaveData.hudPositions.set('rating', [curCategory[i][1], SaveData.hudPositions.get('rating')[1]]);
                case "Rating Offset Y":
                    SaveData.hudPositions.set('rating', [SaveData.hudPositions.get('rating')[0], curCategory[i][1]]);


                case "Vertical Health Bar":
                    SaveData.hudPositions.set('verticalHealthBar', curCategory[i][1]);
                case "Health Bar Width":
                    SaveData.hudPositions.set('healthBarWidth', curCategory[i][1]);
                case "Song Name/Time Hud Size":
                    SaveData.hudPositions.set('songSize', curCategory[i][1]);
                case "Score Hud Size":
                    SaveData.hudPositions.set('scoreSize', curCategory[i][1]);
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
            for (i in 0...hudSprites.length)
                remove(hudSprites[i]);
        }
        



        healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));

		if (SaveData.hudPositions.get('verticalHealthBar'))
		{
			healthBarBG.screenCenter(Y); 
			healthBarBG.angle = 90;
		}


		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.scale.x = SaveData.hudPositions.get('healthBarWidth');
		healthBarBG.updateHitbox();
		add(healthBarBG);
		if (SaveData.downscroll && !SaveData.hudPositions.get('verticalHealthBar'))
			healthBarBG.y = FlxG.height * 0.1;

        healthBar = new FlxBar(healthBarBG.x + (4), healthBarBG.y + (4), RIGHT_TO_LEFT, 
        Std.int(healthBarBG.width - (8)), Std.int(healthBarBG.height - (8)), this,
        'health', 0, 2);

		healthBar.angle = healthBarBG.angle;
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		add(healthBar);	

		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 540, healthBarBG.y + 30, 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), SaveData.hudPositions.get('scoreSize'), FlxColor.WHITE, SaveData.hudPositions.get('scoreAlign'), OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();

		timeText = new FlxText(healthBarBG.x + healthBarBG.width - 540, healthBarBG.y - 60, 0, "", 20);
		timeText.setFormat(Paths.font("vcr.ttf"), SaveData.hudPositions.get('songSize'), FlxColor.WHITE, SaveData.hudPositions.get('songAlign'), OUTLINE, FlxColor.BLACK);
		timeText.scrollFactor.set();

		if (SaveData.hudPositions.get('verticalHealthBar'))
		{
			timeText.y = (FlxG.height * 0.1) - 60;
			if (SaveData.hudPositions.get('scoreAlign') == FlxTextAlign.CENTER)
				scoreTxt.y = (FlxG.height * 0.9) + 30;
		}


        switch (SaveData.hudPositions.get('scoreAlign'))
        {
            case FlxTextAlign.LEFT: 
                scoreTxt.x = 20;
                scoreTxt.y = 250;
            case FlxTextAlign.RIGHT: 
                scoreTxt.x = FlxG.width - 200;
                scoreTxt.y = 250;
        }
        switch (SaveData.hudPositions.get('healthBarAlign'))
        {
            case FlxTextAlign.LEFT: 
                healthBarBG.x = -200;
                healthBar.x = healthBarBG.x + 4;
            case FlxTextAlign.RIGHT: 
                healthBarBG.x = FlxG.width - 400;
                healthBar.x = healthBarBG.x + 4;
        }

		healthBarBG.x += SaveData.hudPositions.get('healthBar')[0];
		healthBarBG.y += SaveData.hudPositions.get('healthBar')[1];
		healthBar.x += SaveData.hudPositions.get('healthBar')[0];
		healthBar.y += SaveData.hudPositions.get('healthBar')[1];

		scoreTxt.x += SaveData.hudPositions.get('score')[0];
		scoreTxt.y += SaveData.hudPositions.get('score')[1];
		timeText.x += SaveData.hudPositions.get('song')[0];
		timeText.y += SaveData.hudPositions.get('song')[1];

		switch (SaveData.hudPositions.get('songAlign'))
		{
			case FlxTextAlign.LEFT: 
				timeText.x = 20;
			case FlxTextAlign.RIGHT: 
				timeText.x = FlxG.width - 400;
		}

		timeText.setFormat(Paths.font("vcr.ttf"), SaveData.hudPositions.get('songSize'), FlxColor.WHITE, SaveData.hudPositions.get('songAlign'), OUTLINE, FlxColor.BLACK); //update it
		scoreTxt.setFormat(Paths.font("vcr.ttf"), SaveData.hudPositions.get('scoreSize'), FlxColor.WHITE, SaveData.hudPositions.get('scoreAlign'), OUTLINE, FlxColor.BLACK);
        add(scoreTxt);
        add(timeText);


        var daCombo:Int = 1;

		var placement:String = Std.string(daCombo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
        var rating:FlxSprite = new FlxSprite();

        var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		rating.loadGraphic(Paths.image(pixelShitPart1 + "sick" + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;

		rating.x += SaveData.hudPositions.get('rating')[0];
		rating.y += SaveData.hudPositions.get('rating')[1];


		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;

		add(rating);
        hudSprites.push(rating);

		rating.setGraphicSize(Std.int(rating.width * 0.7));
		rating.antialiasing = true;
		comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
		comboSpr.antialiasing = true;

		comboSpr.updateHitbox();
		rating.updateHitbox();

        var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(daCombo / 100));
		seperatedScore.push(Math.floor((daCombo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(daCombo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			combo = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			combo.screenCenter();
			combo.x = coolText.x + (43 * daLoop) - 90;
			combo.y += 80;

			combo.antialiasing = true;
			combo.setGraphicSize(Std.int(combo.width * 0.5));

			combo.updateHitbox();

			combo.x += SaveData.hudPositions.get('combo')[0];
			combo.y += SaveData.hudPositions.get('combo')[1];

            hudSprites.push(combo);

			add(combo);

			daLoop++;
		}
    }
}