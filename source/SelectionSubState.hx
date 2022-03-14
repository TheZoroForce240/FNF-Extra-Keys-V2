package;

import flixel.addons.ui.FlxInputText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import Controls.Control;
import flixel.addons.ui.FlxUIInputText;

class SelectionSubState extends MusicBeatSubstate
{

    public static var output:String = "";
    public static var selectedItemID:Int = 0;
    var grpMenuShit:FlxTypedGroup<Alphabet>;
    var menuItems:Array<String>;
    var curSelected:Int = 0;
    var type:String = '';
    var inputText:FlxInputText;

    var finishCallBack:String->Void;
    var info:String;
    var infoText:FlxText;

    public function new (type:String, callback:String->Void, info:String, ?stuff:Array<String>)
    {
        super();

        this.type = type;
        this.info = info;
        switch(type)
        {
            case "list": 
                menuItems = stuff;
            case "inputText":
                //

        }
        finishCallBack = callback;
        
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);
        FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});

        infoText = new FlxText(0, FlxG.height * 0.1, 0, info, 32);
		infoText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        infoText.screenCenter(X);
        add(infoText);

        

        

        if (type == 'list')
        {
            grpMenuShit = new FlxTypedGroup<Alphabet>();
            add(grpMenuShit);
    
            for (i in 0...menuItems.length)
            {
                var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
                songText.isMenuItem = true;
                songText.targetY = i;
                grpMenuShit.add(songText);
            }
            changeSelection();
        }
        else if (type == "inputText")
        {
            FlxG.mouse.visible = true;
            inputText = new FlxUIInputText(0,0, Math.floor(FlxG.width * 0.8), '', 64);
            inputText.screenCenter();
            //inputText.hasFocus = true;
            add(inputText);
        }

        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
        //FlxG.camera.zoom = 1;

    }

    override function update(elapsed:Float)
    {    
        super.update(elapsed);

        var upP = controls.UP_P;
        var downP = controls.DOWN_P;
        var accepted = controls.ACCEPT;

        if (type == 'list')
        {
            if (upP)
            {
                changeSelection(-1);
            }
            if (downP)
            {
                changeSelection(1);
            }
        }
        else if (type == 'inputText')
        {
            if (!inputText.hasFocus)
                inputText.hasFocus = true;
        }


        if (FlxG.keys.justPressed.ENTER)
        {
            if (type == 'list')
            {
                output = menuItems[curSelected];
                selectedItemID = curSelected;
            }
            else if (type == 'inputText')
            {
                output = inputText.text;
            }



            close();
            finishCallBack(output);
        }
        if (FlxG.keys.justPressed.ESCAPE)
        {
            close();
        }
    }

    override function close()
    {
        super.close();
    }


    function changeSelection(change:Int = 0):Void
        {
            curSelected += change;
    
            if (curSelected < 0)
                curSelected = menuItems.length - 1;
            if (curSelected >= menuItems.length)
                curSelected = 0;
    
            var bullShit:Int = 0;
    
            for (item in grpMenuShit.members)
            {
                item.targetY = bullShit - curSelected;
                bullShit++;
    
                item.alpha = 0.6;
                // item.setGraphicSize(Std.int(item.width * 0.8));
    
                if (item.targetY == 0)
                {
                    item.alpha = 1;
                    // item.setGraphicSize(Std.int(item.width));
                }
            }
        }

}