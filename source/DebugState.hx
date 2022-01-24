package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flixel.addons.ui.FlxUIDropDownMenu;

#if sys
import sys.io.File;
import sys.FileSystem;
import flash.media.Sound;
#end
using StringTools;

class DebugState extends MusicBeatState
{
    private static var curSelected:Int = 0;
    private var grpTxt:FlxTypedGroup<Alphabet>;
    var menuList = ["Character Debug", "Stage Debug", "Chart Editor"];

    private static var curSong:String = "tutorial";
    private static var curDiff:String = "Normal";
    private static var curDiffNum:Int = 1;
    private static var curCharacter:String = "bf";
    private static var curStage:String = "stage";

    var diffDropDown:FlxUIDropDownMenu;
    var diffText:FlxText;

    var poop:String;

    override function create()
    {
        FlxG.mouse.visible = true;
        
        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);

        grpTxt = new FlxTypedGroup<Alphabet>();
		add(grpTxt);
        for (i in 0...menuList.length)
        {
            var txt:Alphabet = new Alphabet(0, (70 * i) + 30, menuList[i], true, false, FlxG.width / 4);
			txt.isMenuItem = true;
			txt.targetY = i;
			grpTxt.add(txt);
        }

        var characters:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));
		var stages:Array<String> = CoolUtil.coolTextFile(Paths.txt('stageList'));
        var freeplayList:Array<String> = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
        var songs:Array<String> = [];

        for (i in 0...freeplayList.length)
        {
            var data:Array<String> = freeplayList[i].split(':');
		    var song = data[0];
            songs.push(song);
        }

		var playerDropDown = new FlxUIDropDownMenu(10, 120, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			curCharacter = characters[Std.parseInt(character)];
		});
		playerDropDown.selectedLabel = curCharacter;
        

        var stageDropDown = new FlxUIDropDownMenu(10, 150, FlxUIDropDownMenu.makeStrIdLabelArray(stages, true), function(stage:String)
        {
            curStage = stages[Std.parseInt(stage)];
        });
        stageDropDown.selectedLabel = curStage;
        

        var songDropDown = new FlxUIDropDownMenu(10, 180, FlxUIDropDownMenu.makeStrIdLabelArray(songs, true), function(song:String)
        {
            curSong = songs[Std.parseInt(song)];
            curDiffNum = CoolUtil.CurSongDiffs.indexOf(curDiff);
            #if sys
            poop = CoolUtil.getSongFromJsons(curSong.toLowerCase(), curDiffNum);
            #end
        });
        songDropDown.selectedLabel = curSong;
        

        diffDropDown = new FlxUIDropDownMenu(10, 210, FlxUIDropDownMenu.makeStrIdLabelArray(CoolUtil.CurSongDiffs, true), function(diff:String)
        {
            diffDropDown.setData(FlxUIDropDownMenu.makeStrIdLabelArray(CoolUtil.CurSongDiffs, true));
            curDiff = CoolUtil.CurSongDiffs[Std.parseInt(diff)];
            curDiffNum = CoolUtil.CurSongDiffs.indexOf(curDiff);
            #if sys
            poop = CoolUtil.getSongFromJsons(curSong.toLowerCase(), curDiffNum);   
            #end 
        });
        diffDropDown.selectedLabel = curDiff;

        diffText = new FlxText(diffDropDown.x, 230, 0, "Selected Difficulty: " + CoolUtil.CurSongDiffs[curDiffNum], 24);
        diffText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.BLACK, RIGHT);
        add(diffText);
        add(diffDropDown);
        add(songDropDown);
        add(stageDropDown);
        add(playerDropDown);
        
        changeSelection();

    }
    override function update(elapsed:Float)
    {
        super.update(elapsed);


        diffText.text = "Selected Difficulty: " + CoolUtil.CurSongDiffs[curDiffNum];

        var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;
        if (FlxG.keys.justPressed.UP)
        {
            changeSelection(-1);
        }
        if (FlxG.keys.justPressed.DOWN)
        {
            changeSelection(1);
        }
        if (controls.BACK)
        {
            FlxG.switchState(new MainMenuState());
            FlxG.mouse.visible = false;
        }
        if (accepted)
        {
            switch (menuList[curSelected])
            {
                case "Character Debug": 
                    LoadingState.loadAndSwitchState(new AnimationDebug(curCharacter));
                case "Stage Debug": 
                    LoadingState.loadAndSwitchState(new StageDebug(curStage, curCharacter));
                case "Chart Editor": 
                    #if sys
                    Main.editor = true;
                    PlayState.SONG = Song.loadFromJson(poop, curSong.toLowerCase());
                    PlayState.isStoryMode = false;
                    PlayState.storyDifficulty = curDiffNum;
                    trace('CUR WEEK' + PlayState.storyWeek);
                    LoadingState.loadAndSwitchState(new ChartingState());
                    #end
                case "Note Type Debug": 
                    LoadingState.loadAndSwitchState(new NoteTypeOffsetState());
				    

            }
        }
    }
    function changeSelection(change:Int = 0)
    {
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

        curSelected += change;

        if (curSelected < 0)
            curSelected = menuList.length - 1;
        if (curSelected >= menuList.length)
            curSelected = 0;

        var bullShit:Int = 0;

        for (item in grpTxt.members)
        {
            item.targetY = bullShit - curSelected;
            bullShit++;

            item.alpha = 0.6;

            if (item.targetY == 0)
            {
                item.alpha = 1;
            }
        }
    }
}