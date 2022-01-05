package;


import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import flixel.input.keyboard.FlxKey;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.addons.display.FlxGridOverlay;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxSlider;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import Shaders;
import openfl.filters.ShaderFilter;


using StringTools;


class CustomizationState extends MusicBeatState //i literally copied like half of playstate lol
{                                               //this is probably the messiest piece of code i've ever written, even though i improved most of it, its still a mess
    var bf:Boyfriend;
    var dad:Character;

    var strumLine:FlxSprite;
    var strumLineNotes:FlxTypedGroup<BabyArrow>;
    var playerStrums:FlxTypedGroup<BabyArrow>;
    private var camHUD:FlxCamera;
    private var camNotes:FlxCamera;
    private var camOnTop:FlxCamera;
    private var camGame:FlxCamera;

    var HSV:HSVEffect; //hsv shader pog

    var UI_box:FlxUITabMenu; //didnt even use this lol

    var inMain:Bool = true;

    var curSelected:Int = 0;
    var curSelectedNote:Int = 0;
    var curMenu:String = "main";
    var waitingForInput:Bool = false;

    var selectedNoteColor:String = 'purple';

    var alpha:Float = 0; //used to use FlxColor but its shit
    var red:Float = 255;
    var green:Float = 255;
    var blue:Float = 255;

    var hue:Float = 0; //using chad hsv now
    var saturation:Float = 0;
    var brightness:Float = 0;

    var colorText:FlxText;
    var infoText:FlxText;

    var hueSlider:FlxSlider; //slider shit
    var saturationSlider:FlxSlider;
    var brightnessSlider:FlxSlider;

    var sliderThing:FlxSprite; //sliders are weird as fuck

    public static var maniaToChange = 0; //the mania

    var keys = [false, false, false, false, false, false, false, false, false]; //tracks inputs
    //var frameN:Array<String> = ['purple', 'blue', 'green', 'red']; //used for note anims

    var keyAmmo:Array<Int> = PlayState.keyAmmo; //turns mania value into amount of keys, thats why its called key Ammo(unt), duh

    var sDir:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'UP', 'LEFT', 'DOWN', 'UP', 'RIGHT']; //bf anims from note data, or input data in this state

    var menuList:Array<String> = ['Keybinds', 'Notes', 'Gameplay', 'Hud'];                           //used for creating menus
    //var KeybindList:Array<String> = FlxG.save.data.binds[0];
    var selectedPlayer:Int = 1;
    var NotesList:Array<String> = ['Color', '', '', '', '', 'Assets','Note Scale', 'Color Presets', 'Reset Colors'];

    var settings:Array<String> = ['Use Downscroll', 'Use Ghost Tapping', 'Use Note Splash', "Use Botplay", "Middlescroll"];
	var settingsData:Array<Bool> = [SaveData.downscroll, SaveData.ghost, SaveData.noteSplash, SaveData.botplay, SaveData.middlescroll];

	private var grpSettings:FlxTypedGroup<Alphabet>; //groups for menus
    private var grpNotes:FlxTypedGroup<Alphabet>;
    private var grpKeybinds:FlxTypedGroup<FlxText>;
    private var grpMenuList:FlxTypedGroup<Alphabet>; //idk why they all private lol i just copied from playstate

	private var checkArray:FlxTypedGroup<HealthIcon>; //just for gameplay section

    private var notes:FlxTypedGroup<FlxSprite>; //daNotes

    public static var assetList:Array<String> = ["default", "purple", 'blue', 'green', 'red', 'pixel']; //list of note asset names for the text
    var baseAsset:Int = 0; //note asset value

    var assetsOption:FlxText;
    var assetOptTracker:FlxSprite; //for moving the text next to the alphabet text


    var selectedNote:FlxSprite; //the note on the side
    var selectedColor:String; //is this even used??? why tf is this here
    var noteTracker:FlxSprite; //for moving the note next to the alphabet text
    var waitingForSettings:Bool = false;

    public override function create()
    {
        camGame = new FlxCamera(); //camera shit that probably isnt needed
        camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camNotes = new FlxCamera();
		camNotes.bgColor.alpha = 0;
		camOnTop = new FlxCamera();
		camOnTop.bgColor.alpha = 0;

        FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camNotes);
		FlxG.cameras.add(camOnTop);

        FlxCamera.defaultCameras = [camGame];

        QuickOptions.midSong = false;

		if (SaveData.downscroll) 
		{
			camNotes.flashSprite.scaleY *= -1; //easy downscroll lol
		}

        maniaToChange = 0;                  //makes sure its all set to 4k when entering the menu

        FlxG.mouse.visible = true; //well you kinda need the mouse to use the menu

        strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10); //for placing the static arrows over
		strumLine.scrollFactor.set();

        // my epic stage system
        var pieceArray = ['stageBG', 'stageFront', 'stageCurtains'];
        for (i in 0...pieceArray.length) //x and y are optional and set in StagePiece.hx, so epic for loop can be used
        {
            var piece:StagePiece = new StagePiece(0, 0, pieceArray[i]);
            piece.x += piece.newx;
            piece.y += piece.newy;
            add(piece);
        }

        var camFollow = new FlxObject(0, 0, 1, 1); //just some more shit from playstate
        dad = new Character(100, 100, 'dad');
        add(dad);

        bf = new Boyfriend(770, 450, 'bf', true, true);
        add(bf);

        var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x + 400, dad.getGraphicMidpoint().y);

		camFollow.setPosition(camPos.x, camPos.y);

        FlxG.camera.follow(camFollow, LOCKON, 0.01);
		FlxG.camera.zoom = 0.9;
		FlxG.camera.focusOn(camFollow.getPosition());

        strumLineNotes = new FlxTypedGroup<BabyArrow>();
		add(strumLineNotes);
		playerStrums = new FlxTypedGroup<BabyArrow>();



        generateStaticArrows(1); //just creating bf notes

        HSV = new HSVEffect(); //hsv shader pog


        grpMenuList = new FlxTypedGroup<Alphabet>(); //makin da groups
		add(grpMenuList);

		grpSettings = new FlxTypedGroup<Alphabet>();
		add(grpSettings);

        grpNotes = new FlxTypedGroup<Alphabet>();
		add(grpNotes);

        grpKeybinds = new FlxTypedGroup<FlxText>();
		add(grpKeybinds);

		checkArray = new FlxTypedGroup<HealthIcon>();
		add(checkArray);

        notes = new FlxTypedGroup<FlxSprite>();
		add(notes);

        infoText = new FlxText(FlxG.width * 0.4, 550, 1000, "", 32); //text shit
        if (SaveData.downscroll)
            infoText.y = 100;
        infoText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        infoText.text = "--Options--\nClick an option to enter that menu.\nFeel Free to test keybinds.\nPress ESC to go Back.\nPress 1-9 to Change amount of keys.";
        add(infoText);

        strumLineNotes.cameras = [camNotes];
        //notes.cameras = [camHUD];
        //regular notes arent on a camera because the mouse hitbox gets fucked idk why

        

        createMain(); //made a lot of funtcion to simplify/reuse the creating of the menus to refresh them
        createKeybinds();
        createNotes();
        createSettings();
        createSliders();
        createActualNotes();
        createSelectedNote();
        changeSelectedNote();
        

        FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN,handleInput); //keyboard event shit for input
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);

        super.create(); //acutally making it
    }

    override function update(elapsed:Float)
        {
            super.update(elapsed);

            hue = FlxMath.roundDecimal(sliderThing.x, 2);           //converts shit sprite transfer system for sliders into the hsv values
            saturation = FlxMath.roundDecimal(sliderThing.y, 2);
            brightness = FlxMath.roundDecimal(sliderThing.angle, 2);
            updateColors(); //is this even used anymore lol

            SaveData.noteColors[BabyArrow.colorFromData[maniaToChange][curSelectedNote]][0] = hue;
            SaveData.noteColors[BabyArrow.colorFromData[maniaToChange][curSelectedNote]][1] = saturation;
            SaveData.noteColors[BabyArrow.colorFromData[maniaToChange][curSelectedNote]][2] = brightness;


            if (bf.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!keys.contains(true))) //holding bfs anims, copied from playstate
                {
                    if (bf.animation.curAnim.name.startsWith('sing') && !bf.animation.curAnim.name.endsWith('miss'))
                        bf.dance();
                }

            if (noteTracker != null) //tracker shit, so it all moves together
            {
                selectedNote.setPosition(noteTracker.x + noteTracker.width + 10, noteTracker.y - 30);
                colorText.setPosition(noteTracker.x, noteTracker.y + 70);
                hueSlider.setPosition(noteTracker.x + noteTracker.width + 70, noteTracker.y - 55);
                saturationSlider.setPosition(noteTracker.x + noteTracker.width + 70, noteTracker.y - 7);
                brightnessSlider.setPosition(noteTracker.x + noteTracker.width + 70, noteTracker.y + 41);
            }
            if (assetOptTracker != null)
                assetsOption.setPosition(assetOptTracker.x + assetOptTracker.width + 10, assetOptTracker.y);


            colorText.text = "Hue: " + (hue * 180) + " \nSaturation: " + (saturation * 180) + " \nBrightness: " + (brightness * 180); //updating the hsv text


            playerStrums.forEach(function(spr:BabyArrow) //playing arrow anims
            {
                if (keys[spr.ID])
                    spr.playAnim('confirm', true, spr.ID, spr.colorShiz);
                if (!keys[spr.ID])
                    spr.playAnim('static', false, spr.ID, [0,0,0,0]);
            });

            for (i in 0...menuList.length) //menu selction shit
            {
                if (FlxG.mouse.overlaps(grpMenuList.members[i]) && curSelected != i) //hover
                    changeSelection(i, 0); //just for changing alpha/playing sound
                if (FlxG.mouse.overlaps(grpMenuList.members[i]) && FlxG.mouse.justPressed) //press
                {
                    inMain = false;
                    switch(i)
                    {
                        case 0: 
                            curMenu = 'keybinds';
                            infoText.text = "--Keybinds--\nClick a Note to edit its Keybind.\nFeel Free to test keybinds.\nPress BACKSPACE to Reset Keybinds.\nPress TAB to Change Selected Player\nSelected Player: P" + selectedPlayer + "\nPress ESC to go Back.\nPress 1-9 to Change amount of keys.";
                        case 1: 
                            for (ii in grpNotes.members)
                                FlxTween.tween(ii, {x: 150}, 1, {ease: FlxEase.cubeInOut});
                            curMenu = 'notes';
                            infoText.text = "--Note Customization--\nClick a Note to Select it.\nUse the Sliders to Change colors, \nand other options to change extra attributes.\nPress ESC to go Back.\nPress 1-9 to Change amount of keys.";
                        case 2: 
                            openSubState(new QuickOptions());
                            inMain = true;
                            waitingForSettings = true;
                        case 3: 
                            openSubState(new HUDCustomizeSubstate());
                            inMain = true;
                            waitingForSettings = true;  
                            
                    }
                    if (i != 2)
                        for (ii in grpMenuList.members)
                            FlxTween.tween(ii, {x: 2000}, 1, {ease: FlxEase.cubeInOut});  //moves the menu text to the side
                }
            }
            for (i in 0...NotesList.length)
                {
                    if (FlxG.mouse.overlaps(grpNotes.members[i]) && curSelected != i)//hover
                        changeSelection(i, 2);//just for changing alpha/playing sound
                    if (FlxG.mouse.overlaps(grpNotes.members[i]) && FlxG.mouse.justPressed)//press
                    {
                        switch(i)
                        {
                            case 5: //changing the note asset
                                baseAsset += 1;
                                if (baseAsset > assetList.length - 1)
                                    baseAsset = 0;

                                SaveData.noteColors[BabyArrow.colorFromData[maniaToChange][curSelectedNote]][3] = baseAsset;
                                changeSelectedNote(curSelectedNote); //still doesnt fucking swithc to pixel fuck you game
                                createSelectedNote(); //i think i fixed am stupid
                                changeMania(maniaToChange);
                                assetsOption.text = assetList[baseAsset];
                            case 8: 
                                SaveData.ResetColors();
                                sliderThing.x = 0;
                                sliderThing.y = 0;
                                sliderThing.angle = 0;
    
                                
                        }
                    }
                }
            for (i in 0...settings.length)
                {
                    if (FlxG.mouse.overlaps(grpSettings.members[i]) && curSelected != i)//hover
                        changeSelection(i, 3); //just for changing alpha/playing sound
                    if (FlxG.mouse.overlaps(grpSettings.members[i]) && FlxG.mouse.justPressed)//press
                    {
                        switch(i) //changes settings, may do a category system at some point
                        {
                            case 0: 
                                SaveData.downscroll = !SaveData.downscroll;
                            case 1:
                                SaveData.ghost = !SaveData.ghost;
                            case 2:
                                SaveData.noteSplash = !SaveData.noteSplash;
                            case 3: 
                                //not added botplay yet :(
                            case 4: 
                                SaveData.middlescroll = !SaveData.middlescroll;
                        }
                        createSettings(true); //remakes the settings to update the checkmarks
                    }
                }

            for (i in 0...notes.length)
                {
                    if (FlxG.mouse.overlaps(notes.members[i]) && FlxG.mouse.justPressed) //selecting daNote
                    {
                        createSelectedNote();
                        changeSelectedNote(i);

                    }
                        
                }
            if ((FlxG.keys.justPressed.BACKSPACE || FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.ENTER) && waitingForInput) //so you cant accidentally quit while changing a keybind
                waitingForInput = false;
            else if (FlxG.keys.justPressed.BACKSPACE || FlxG.keys.justPressed.ESCAPE)
            {
                FlxG.sound.play(Paths.sound('cancelMenu'));
                if (waitingForSettings)
                    FlxG.resetState();
                if (inMain) //exitint
                {
                    FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN,handleInput);
                    FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
                    SaveData.saveTheData(); //save the shit
                    FlxG.switchState(new MainMenuState());
                    FlxG.mouse.visible = false;
                }
                else
                {
                    inMain = true;
                    changeSelection(0);
                    curMenu = 'main';
                    infoText.text = "--Options--\nClick an option to enter that menu.\nFeel Free to test keybinds.\nPress ESC to go Back.\nPress 1-9 to Change amount of keys.";
                    waitingForInput = false;
                    for (i in grpMenuList.members)
                        FlxTween.tween(i, {x: 150}, 1, {ease: FlxEase.cubeInOut});  //tweeeeeeeeeeeeeeeeeeeeens
                    for (i in grpNotes.members)
                        FlxTween.tween(i, {x: 2000}, 1, {ease: FlxEase.cubeInOut});  
                    for (i in grpSettings.members)
                        FlxTween.tween(i, {x: 2000}, 1, {ease: FlxEase.cubeInOut});  
                }
            }
            if (FlxG.mouse.overlaps(notes.members[curSelectedNote]) && FlxG.mouse.justPressed && curMenu == 'keybinds')
                {
                    waitingForInput = true; //keybind changing shit, go into the keyboard events for the rest of the code
                    updateKeybinds();
                }
            if (!waitingForInput)
            {
                /*if (FlxG.keys.justPressed.ONE) //switching the mania
                    changeMania(6);
                if (FlxG.keys.justPressed.TWO)
                    changeMania(7);
                if (FlxG.keys.justPressed.THREE)
                    changeMania(8); *///temp disable due to crash
                if (FlxG.keys.justPressed.FOUR)
                    changeMania(0);
                if (FlxG.keys.justPressed.FIVE)
                    changeMania(3);
                if (FlxG.keys.justPressed.SIX)
                    changeMania(1);
                if (FlxG.keys.justPressed.SEVEN)
                    changeMania(4);
                if (FlxG.keys.justPressed.EIGHT)
                    changeMania(5);
                if (FlxG.keys.justPressed.NINE)
                    changeMania(2);
                if (FlxG.keys.justPressed.BACKSPACE && curMenu == 'keybinds')
                    SaveData.resetBinds();
                if (FlxG.keys.justPressed.TAB && curMenu == 'keybinds')
                {
                    if (selectedPlayer == 1)
                        selectedPlayer = 0;
                    else
                        selectedPlayer = 1;
                    infoText.text = "--Keybinds--\nClick a Note to edit its Keybind.\nFeel Free to test keybinds.\nPress BACKSPACE to Reset Keybinds.\nPress TAB to Change Selected Player\nSelected Player: P" + selectedPlayer + "\nPress ESC to go Back.\nPress 1-9 to Change amount of keys.";
                    updateKeybinds();
                }

                if (FlxG.keys.justPressed.C)
                {
                    
                }
            }

        }

    function changeSelection(change:Int = 0, menu:Int = 0) //just changes alpha and does sound effect lol
        {
            FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
    
            curSelected = change;
            switch (menu)
            {
                case 1: 
                    //listToUse = [KeybindList, gprMenuList];
                case 2: 
                    if (curSelected < 0)
                        curSelected = NotesList.length - 1;
                    if (curSelected >= NotesList.length)
                        curSelected = 0;
            
                    for (item in grpNotes.members)
                    {
                        item.alpha = 0.6;
                    }
                    grpNotes.members[curSelected].alpha = 1;
                case 3: 
                    if (curSelected < 0)
                        curSelected = settings.length - 1;
                    if (curSelected >= settings.length)
                        curSelected = 0;
            
                    for (item in grpSettings.members)
                    {
                        item.alpha = 0.6;
                    }
                    grpSettings.members[curSelected].alpha = 1;
                default:
                    if (curSelected < 0)
                        curSelected = menuList.length - 1;
                    if (curSelected >= menuList.length)
                        curSelected = 0;
            
                    for (item in grpMenuList.members)
                    {
                        item.alpha = 0.6;
                    }
                    grpMenuList.members[curSelected].alpha = 1;
            }

            
        }

    function changeSelectedNote(change:Int = 0)
    {
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
        
        curSelectedNote = change;
        if (curSelectedNote < 0)
            curSelectedNote = notes.length - 1;
        if (curSelectedNote >= notes.length)
            curSelectedNote = 0;
        
        for (item in notes.members)
        {
            item.y = 350;
        }
        updateColors();
        FlxTween.tween(notes.members[curSelectedNote], {y: 320}, 0.2, {ease: FlxEase.cubeInOut});
        selectedNote.animation.play(Note.frameN[maniaToChange][curSelectedNote] + 'Scroll');

        hue = SaveData.noteColors[BabyArrow.colorFromData[maniaToChange][curSelectedNote]][0];
        saturation = SaveData.noteColors[BabyArrow.colorFromData[maniaToChange][curSelectedNote]][1];
        brightness = SaveData.noteColors[BabyArrow.colorFromData[maniaToChange][curSelectedNote]][2];
        baseAsset = Std.int(SaveData.noteColors[BabyArrow.colorFromData[maniaToChange][curSelectedNote]][3]);

        sliderThing.x = hue;
        sliderThing.y = saturation;
        sliderThing.angle = brightness;
        updateColors();
    }
    function updateColors():Void //i hate all this code, oh wait i improved it pog, no longer a shitty case statment
    {
        var daColor:FlxColor = 0x00FFFFFF; //not even used lol
        
        HSV.hue = SaveData.noteColors[BabyArrow.colorFromData[maniaToChange][curSelectedNote]][0];
        HSV.saturation = SaveData.noteColors[BabyArrow.colorFromData[maniaToChange][curSelectedNote]][1];
        HSV.brightness = SaveData.noteColors[BabyArrow.colorFromData[maniaToChange][curSelectedNote]][2];

        HSV.update();
    }

    function changeColors(thing:Int, change:Int)
    {
        
    }

    
    function createMain():Void //these functions below make all the menu shit, there is literally way too much in this for me to explain it all
    {
        grpMenuList.clear();
        for (i in 0...menuList.length)
            {
                var text:Alphabet = new Alphabet(0, (70 * i) + 400, menuList[i], true, false);
                grpMenuList.add(text);
                text.x += 150;
            }
    }
    function createKeybinds():Void
        {
            var KeybindList:Array<String> = CoolUtil.bindCheck(maniaToChange, true, SaveData.binds, maniaToChange);
            if (selectedPlayer != 1)
                KeybindList = CoolUtil.bindCheck(maniaToChange, true, SaveData.P2binds, maniaToChange);

            grpKeybinds.clear();
            for (i in 0...KeybindList.length)
            {
                var text:FlxText = new FlxText(strumLineNotes.members[i].x + 100, (strumLine.y + 200), 48, KeybindList[i], 32, false);
                text.setFormat(Paths.font("vcr.ttf"), 48, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
                grpKeybinds.add(text);
                if (SaveData.downscroll)
                    text.y += 320;
            }
        }

    function createSelectedNote():Void
    {
        remove(selectedNote);
        selectedNote = new FlxSprite(2000, 200);
        var color:String = Note.frameN[maniaToChange][curSelectedNote];
        var pathToUse:Int = 0;
        pathToUse = Std.int(SaveData.noteColors[BabyArrow.colorFromData[maniaToChange][curSelectedNote]][3]);

        var noteColors:Array<String> = ['purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'darkred', 'dark'];
        if (pathToUse == 5)
        {
            selectedNote.loadGraphic(Paths.image('noteassets/pixel/arrows-pixels'), true, 17, 17);
            for (ii in 0...9)
                {
                    selectedNote.animation.add(noteColors[ii] + 'Scroll', [ii + 9]); // Normal notes
                    selectedNote.animation.add(noteColors[ii] + 'hold', [ii]); // Holds
                    selectedNote.animation.add(noteColors[ii] + 'holdend', [ii + 9]); // Tails
                }
            selectedNote.setGraphicSize(Std.int(selectedNote.width * PlayState.daPixelZoom * Note.pixelNoteScales[maniaToChange]));
            selectedNote.updateHitbox();
            selectedNote.antialiasing = false;
        }
        else
        {
            selectedNote.frames = Paths.getSparrowAtlas(Note.pathList[pathToUse]);
            for (ii in 0...9)
                {
                    selectedNote.animation.addByPrefix(noteColors[ii] + 'Scroll', noteColors[ii] + '0'); // Normal notes
                    selectedNote.animation.addByPrefix(noteColors[ii] + 'hold', noteColors[ii] + ' hold piece'); // Hold
                    selectedNote.animation.addByPrefix(noteColors[ii] + 'holdend', noteColors[ii] + ' hold end'); // Tails
                }
            selectedNote.setGraphicSize(Std.int(selectedNote.width * Note.noteScales[maniaToChange]));
            selectedNote.updateHitbox();
            selectedNote.antialiasing = true;
        }
        selectedNote.animation.play(Note.frameN[maniaToChange][curSelectedNote] + 'Scroll');
        selectedNote.shader = HSV.shader;
        add(selectedNote);
    }
    function createNotes():Void
        {
            remove(colorText);
            remove(assetsOption);
            
            grpNotes.clear();
            for (i in 0...NotesList.length)
                {
                    var text:Alphabet = new Alphabet(0, (70 * i) + 200, NotesList[i], true, false);
                    grpNotes.add(text);
                    text.x += 2000;
                    if (i == 0)
                        noteTracker = text;

                    if (i == 5)
                        assetOptTracker = text;

                }
            colorText = new FlxText(0,2000, 500, "", 48);
            colorText.setFormat(Paths.font("vcr.ttf"), 48, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
            colorText.text = "Hue: " + (hue * 180) + " \nSaturation: " + (saturation * 180) + " \nBrightness: " + (brightness * 180);
            add(colorText);

            
            assetsOption = new FlxText(0, 2000, 500, assetList[baseAsset], 48);
            assetsOption.setFormat(Paths.font("vcr.ttf"), 48, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
            add(assetsOption);
        }
    

    function createSliders()
    {
        sliderThing = new FlxSprite(0, 0); //sliders are shit
        add(sliderThing);
        hueSlider = new FlxSlider(sliderThing, "x", 250, 2000, -1, 1, 150, 40, 10);
        hueSlider.decimals = 2;
        
        saturationSlider = new FlxSlider(sliderThing, "y", 250, 2000, -1, 1, 150, 40, 10);
        saturationSlider.decimals = 2;

        brightnessSlider = new FlxSlider(sliderThing, "angle", 250, 2000, -1, 1, 150, 40, 10);
        brightnessSlider.decimals = 2;

        add(hueSlider);
        add(saturationSlider);
        add(brightnessSlider);
        hueSlider.cameras = [camHUD];
        saturationSlider.cameras = [camHUD];
        brightnessSlider.cameras = [camHUD];
    }

    function createSettings(inMenu:Bool = false):Void
        {
            grpSettings.clear();
            checkArray.clear();
            settingsData = [SaveData.downscroll, SaveData.ghost, SaveData.noteSplash, SaveData.botplay, SaveData.middlescroll];
            for (i in 0...settings.length)
                {
                    var text:Alphabet = new Alphabet(0, (70 * i) + 200, settings[i], true, false);
                    grpSettings.add(text);
                    if (!inMenu)
                        text.x += 2000;
                    else
                        text.x += 150;

                    var check:HealthIcon;
	
                    check = new HealthIcon('check');

                    check.sprTrackerOptions = text;
        
                    if (settingsData[i] == true)
                    {
                        check.animation.play("check");
                    }
                    else
                    {
                        check.animation.play("noCheck");
                    }
            
                    checkArray.add(check);
                }
        }

    function updateKeybinds():Void
    {
        var KeybindList:Array<String> = CoolUtil.bindCheck(maniaToChange, true, SaveData.binds, maniaToChange);
        if (selectedPlayer != 1)
            KeybindList = CoolUtil.bindCheck(maniaToChange, true, SaveData.P2binds, maniaToChange);

        grpKeybinds.clear();

        if (KeybindList.length != 0)
        {
            for (i in 0...KeybindList.length)
                {
                    var text:FlxText = new FlxText(strumLineNotes.members[i].x + 100, (strumLine.y + 200), 32, KeybindList[i], 32, false);
                    text.setFormat(Paths.font("vcr.ttf"), 48, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
                    grpKeybinds.add(text);
                    if (SaveData.downscroll)
                        text.y += 350;
                    if (i == curSelectedNote && waitingForInput)
                        text.text = "?";
                }
        }

    }
    function createActualNotes():Void
    {
        notes.clear();
        for (i in 0...keyAmmo[maniaToChange])
            {
                var note:FlxSprite = new FlxSprite(0, 350);
                var color:String = Note.frameN[maniaToChange][i];
                var pathToUse:Int = 0;
                pathToUse = Std.int(SaveData.noteColors[BabyArrow.colorFromData[maniaToChange][i]][3]);
                var noteColors:Array<String> = ['purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'darkred', 'dark'];
                if (pathToUse == 5)
                {
                    note.loadGraphic(Paths.image('noteassets/pixel/arrows-pixels'), true, 17, 17);
                    for (ii in 0...9)
                        {
                            note.animation.add(noteColors[ii] + 'Scroll', [ii + 9]); // Normal notes
                            note.animation.add(noteColors[ii] + 'hold', [ii]); // Holds
                            note.animation.add(noteColors[ii] + 'holdend', [ii + 9]); // Tails
                        }
                    note.setGraphicSize(Std.int(note.width * PlayState.daPixelZoom * Note.pixelNoteScales[maniaToChange]));
                    note.updateHitbox();
                    note.antialiasing = false;
                }
                else
                {
                    note.frames = Paths.getSparrowAtlas(Note.pathList[pathToUse]);
                    for (ii in 0...9)
                        {
                            note.animation.addByPrefix(noteColors[ii] + 'Scroll', noteColors[ii] + '0'); // Normal notes
                            note.animation.addByPrefix(noteColors[ii] + 'hold', noteColors[ii] + ' hold piece'); // Hold
                            note.animation.addByPrefix(noteColors[ii] + 'holdend', noteColors[ii] + ' hold end'); // Tails
                        }
                    note.setGraphicSize(Std.int(note.width * Note.noteScales[maniaToChange]));
                    note.updateHitbox();
                    note.antialiasing = true;
                }
                	
                var noteHSV:HSVEffect = new HSVEffect();
                note.shader = noteHSV.shader;

                noteHSV.hue = SaveData.noteColors[BabyArrow.colorFromData[maniaToChange][i]][0];
                noteHSV.saturation = SaveData.noteColors[BabyArrow.colorFromData[maniaToChange][i]][1];
                noteHSV.brightness = SaveData.noteColors[BabyArrow.colorFromData[maniaToChange][i]][2];

                noteHSV.update();
                note.animation.play(Note.frameN[maniaToChange][i] + 'Scroll');
                note.x = strumLineNotes.members[Math.floor(Math.abs(i))].x + 50;
                notes.add(note);
            }   
    }
    private function getKey(charCode:Int):String //input code shit
        {
            for (key => value in FlxKey.fromStringMap)
            {
                if (charCode == value)
                    return key;
            }
            return null;
        }
    private function releaseInput(evt:KeyboardEvent):Void
    {
        @:privateAccess
        var key = FlxKey.toStringMap.get(evt.keyCode);

        var binds:Array<String> = SaveData.binds[0];
        var data = -1;
		binds = CoolUtil.bindCheck(maniaToChange, true, SaveData.binds, maniaToChange);
        if (selectedPlayer != 1)
			binds = CoolUtil.bindCheck(maniaToChange, true, SaveData.P2binds, maniaToChange);

        for (i in 0...binds.length) // binds
        {
            if (binds[i].toLowerCase() == key.toLowerCase())
                data = i;
        }

        if (data == -1)
            return;

        keys[data] = false;
    }

    private function handleInput(evt:KeyboardEvent):Void 
    {
        @:privateAccess
        var key = FlxKey.toStringMap.get(evt.keyCode);
        var data = -1;
        var binds:Array<String> = SaveData.binds[0]; 
		binds = CoolUtil.bindCheck(maniaToChange, true, SaveData.binds, maniaToChange);
        if (selectedPlayer != 1)
			binds = CoolUtil.bindCheck(maniaToChange, true, SaveData.P2binds, maniaToChange);

        for (i in 0...binds.length) // binds
            {
                if (binds[i].toLowerCase() == key.toLowerCase())
                    data = i;
            }
            if (waitingForInput) //keybind saving shit that is awful
            {
                waitingForInput = false;
                if (key.toLowerCase() != "escape" && key.toLowerCase() != "enter" && key.toLowerCase() != "backspace")
                {
                    CoolUtil.complexAssKeybindSaving(maniaToChange, key, curSelectedNote, selectedPlayer);
                    FlxG.save.flush();
                    PlayerSettings.player1.controls.loadKeyBinds();
                }
                updateKeybinds();
    
            }   
            if (data == -1)
            {
                return;
            }
            if (keys[data])
            {
                return;
            }
        
        keys[data] = true;

        switch (selectedPlayer)
        {
            case 0: 
                dad.playAnim('sing' + sDir[data], true);
            case 1: 
                bf.playAnim('sing' + sDir[data], true);
        }
        
                     
    }

    private function generateStaticArrows(player:Int):Void
        {
            var style:String = "normal";
    
            for (i in 0...keyAmmo[maniaToChange])
            {
                var colorShit:Array<Float>;


                var babyArrow:BabyArrow = new BabyArrow(strumLine.y, player, i, style, false);
    
                babyArrow.ID = i;
    
                switch (player)
                {
                    case 1:
                        playerStrums.add(babyArrow);
                }
    
        
                strumLineNotes.add(babyArrow);
            }
        }

    private function changeMania(mania:Int):Void
    {
        
        playerStrums.clear();
        strumLineNotes.clear();
        maniaToChange = mania;
        generateStaticArrows(1);
        updateKeybinds();
        createActualNotes();
        changeSelectedNote(curSelectedNote);

    }
}