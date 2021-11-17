package;

import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import Shaders;

class BabyArrow extends FlxSprite
{
    var HSV:HSVEffect = new HSVEffect();

    public static var offsetshit:Float = 56;

    var pathList:Array<String> = [
        'noteassets/NOTE_assets',
        'noteassets/PURPLE_NOTE_assets',
        'noteassets/BLUE_NOTE_assets',
        'noteassets/GREEN_NOTE_assets',
        'noteassets/RED_NOTE_assets'
    ];

    public static var maniaSwitchPositions:Array<Dynamic> = [
        [0, 1, 2, 3, "alpha0", "alpha0", "alpha0", "alpha0", "alpha0"],
        [0, 4, 1, 2, "alpha0", 3, "alpha0", "alpha0", 5],
        [0, 1, 2, 3, 4, 5, 6, 7, 8],
        [0, 1, 3, 4, 2, "alpha0", "alpha0", "alpha0", "alpha0"],
        [0, 5, 1, 2, 3, 4, "alpha0", "alpha0", 6],
        [0, 1, 2, 3, "alpha0", 4, 5, 6, 7],
        ["alpha0", "alpha0", "alpha0", "alpha0", 0, "alpha0", "alpha0", "alpha0", "alpha0"],
        [0, "alpha0", "alpha0", 1, "alpha0", "alpha0", "alpha0", "alpha0", "alpha0"],
        [0, "alpha0", "alpha0", 2, 1, "alpha0", "alpha0", "alpha0", "alpha0"]
    ];


    public static var dirArray:Array<Dynamic> = [
        ['LEFT', 'DOWN', 'UP', 'RIGHT'],
        ['LEFT', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'RIGHT'],
        ['LEFT', 'DOWN', 'UP', 'RIGHT', 'SPACE', 'LEFT', 'DOWN', 'UP', 'RIGHT'],
        ['LEFT', 'DOWN', 'SPACE', 'UP', 'RIGHT'],
        ['LEFT', 'UP', 'RIGHT', 'SPACE', 'LEFT', 'DOWN', 'RIGHT'],
        ['LEFT', 'DOWN', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'UP', 'RIGHT'],
        ['SPACE'],
        ['LEFT', 'RIGHT'],
        ['LEFT', 'SPACE', 'RIGHT'],
    ];

    public static var colorFromData:Array<Array<Int>> = [
		[0,1,2,3],
		[0,2,3,5,1,8],
		[0,1,2,3,4,5,6,7,8],
		[0,1,4,2,3],
		[0,2,3,4,5,1,8],
		[0,1,2,3,5,6,7,8],
		[4],
		[0,3],
		[0,4,3]
	];

    public var lane:FlxSprite;
    var laneOffset:Array<Float> = [
        0,
        10,
        13,
        5,
        10,
        12,
        0,
        0,
        0,
    ];


    var whichPlayer:Int = 0;
    public var stylelol:String = "";
    var colorShiz:Array<Float>;
    var pathToUse:Int = 0;
    public var scaleMulti:Float = 1;
    public var curMania:Int = 0;

    public var defaultX:Float = 0;
    public var defaultY:Float = 0;
    public var defaultAngle:Float = 0;

    public var defaultWidth:Float;
    public var curID:Int;

    var flxcolorToUse:FlxColor = FlxColor.BLACK;

    public function new(strumline:Float, player:Int, i:Int, style:String, ?isPlayState:Bool = true)
    {
        super();
        y = strumline;
        var maniaToUse:Int = PlayState.mania;
        if (!isPlayState)
            maniaToUse = CustomizationState.maniaToChange;

        curMania = maniaToUse;

        whichPlayer = player;

		if (player == 0)
        {
            ColorPresets.fixColorArray(maniaToUse);
            colorShiz = ColorPresets.ccolorArray[i];
        }
        else
        {
            SaveData.fixColorArray(maniaToUse);
            colorShiz = SaveData.colorArray[i];
        }
        
        pathToUse = Std.int(colorShiz[3]);
		if (pathToUse == 5)
			style = 'pixel';

        stylelol = style;
        if (SaveData.middlescroll && player == 0)
            scaleMulti = 0.55;

        
        var color = Note.frameN[maniaToUse][i];
        if (SaveData.arrowLanes == "Colored")
        {
            switch (color)
            {
                case "purple": 
                    flxcolorToUse = FlxColor.PURPLE;
                case "blue": 
                    flxcolorToUse = FlxColor.CYAN;
                case "green": 
                    flxcolorToUse = FlxColor.GREEN;
                case "red": 
                    flxcolorToUse = FlxColor.RED;
                case "white": 
                    flxcolorToUse = FlxColor.WHITE;
                case "yellow": 
                    flxcolorToUse = FlxColor.YELLOW;
                case "violet": 
                    flxcolorToUse = FlxColor.PURPLE;
                case "darkred": 
                    flxcolorToUse = FlxColor.RED;
                case "dark": 
                    flxcolorToUse = FlxColor.BLUE;
            }
        }


        if (isPlayState && player == 1 && SaveData.arrowLanes != "Off")
        {
            lane = new FlxSprite(0, 0).makeGraphic(Std.int(Note.noteWidths[maniaToUse]), Std.int(FlxG.height * 2), flxcolorToUse);
            PlayState.instance.add(lane);
            lane.cameras = [PlayState.instance.camHUD];
            lane.alpha = 0.2;
        }
            

        

        switch (style)
        {
            case 'pixel':
                loadGraphic(Paths.image('noteassets/pixel/arrows-pixels'), true, 17, 17);
                animation.add('green', [11]);
                animation.add('red', [12]);
                animation.add('blue', [10]);
                animation.add('purplel', [9]);

                animation.add('white', [13]);
                animation.add('yellow', [14]);
                animation.add('violet', [15]);
                animation.add('black', [16]);
                animation.add('darkred', [16]);
                animation.add('orange', [16]);
                animation.add('dark', [17]);

                defaultWidth = width;
                setGraphicSize(Std.int(width * PlayState.daPixelZoom * Note.pixelnoteScale * scaleMulti));
                x += Note.swagWidth * i * scaleMulti; 
                updateHitbox();
                antialiasing = false;
                animation.add('static', [colorFromData[maniaToUse][i]]);
                animation.add('pressed', [colorFromData[maniaToUse][i] + 9, colorFromData[maniaToUse][i] + 18], 12, false);
                animation.add('confirm', [colorFromData[maniaToUse][i] + 27, colorFromData[maniaToUse][i] + 36], 24, false);

            default:
                switch (maniaToUse)
                {
                    case 2:
                        x -= Note.tooMuch;
                }
                var dir = dirArray[maniaToUse][i];
                


                frames = Paths.getSparrowAtlas(pathList[pathToUse]);
                animation.addByPrefix('green', 'arrowUP');
                animation.addByPrefix('blue', 'arrowDOWN');
                animation.addByPrefix('purple', 'arrowLEFT');
                animation.addByPrefix('red', 'arrowRIGHT');

                antialiasing = true;
                defaultWidth = width;
                setGraphicSize(Std.int(width * Note.noteScale * scaleMulti));
                x += Note.swagWidth * i * scaleMulti; 

                animation.addByPrefix('static', 'arrow' + dir);
                animation.addByPrefix('pressed', color + ' press', 24, false);
                animation.addByPrefix('confirm', color + ' confirm', 24, false);
			}

            this.shader = HSV.shader;

			updateHitbox();
			scrollFactor.set();

			if ((SaveData.downscroll && player == 1) || (SaveData.P2downscroll && player == 0))
            {
                scale.y *= -1;
            }

			animation.play('static');
			x += 50;
            if (SaveData.middlescroll && player == 1 && isPlayState)
			    x += ((FlxG.width / 2) * 0.5) + (Note.noteWidths[maniaToUse] / 2);
            else 
                x += ((FlxG.width / 2) * player);

            /*switch (i) //dumb center scroll i did for a video
            {
                case 0: 
                    angle -= 270;
                case 1: 
                    y += Note.swagWidth;
                case 2: 
                    x -= Note.swagWidth;
                    y -= Note.swagWidth;
                    angle -= 180;
                case 3: 
                    x -= Note.swagWidth;
                    angle -= 90;
                
            }
            y += Note.swagWidth * 2;
            x += 50;*/

            if (lane != null)
            {
                lane.x = this.x + laneOffset[maniaToUse];
                lane.y = this.y - 300;
            }
            y += 200;
            //lane.angle = this.angle;

            defaultX = this.x;
            defaultY = this.y;
            defaultAngle = this.angle;


    }
    public function playAnim(anim:String, ?force:Bool = false, id:Int)
    {
        animation.play(anim, force);
        centerOffsets();  
        if (animation.curAnim.name == 'static')
        {
            HSV.hue = 0;
            HSV.saturation = 0;
            HSV.brightness = 0;
            HSV.update();
        }
        else
        {
            if (whichPlayer == 1)
            {
                HSV.hue = colorShiz[0];
                HSV.saturation = colorShiz[1];
                HSV.brightness = colorShiz[2];
                HSV.update();
            }
            else 
            {
                HSV.hue = colorShiz[0];
                HSV.saturation = colorShiz[1];
                HSV.brightness = colorShiz[2];
                HSV.update(); 
            }
        }

        if (stylelol != 'pixel') //pixel note style doesnt need to be offset
        {
            //offset.x -= xoffset;
            //offset.y -= yoffset;
            var scaleToUse = Note.p1NoteScale;
            if (whichPlayer == 0)
                scaleToUse = Note.p2NoteScale;

            updateHitbox();
            offset.x = frameWidth / 2;
            offset.y = frameHeight / 2;


    
            offset.x -= (offsetshit / 0.7) * (scaleToUse * scaleMulti);
            offset.y -= (offsetshit / 0.7) * (scaleToUse * scaleMulti);
        }

        /*if (animation.curAnim.name == 'confirm')
        {
            var yoffset:Float = 13;
            var xoffset:Float = 13;
            var downscrollOffset:Float = 42; //downscroll needs another offset for some reason ??????            
                                            //idk why tf flipping the camera affects this
                                            
            var scaleToUse = Note.p1NoteScale;
            if (whichPlayer == 0)
                scaleToUse = Note.p2NoteScale;

            xoffset = (xoffset * 0.7) / (scaleToUse * scaleMulti); //calculates offset based on notescale 
            yoffset = (yoffset * 0.7) / (scaleToUse * scaleMulti);
    
            downscrollOffset = (downscrollOffset / 0.7) * (scaleToUse * scaleMulti);
            if ((SaveData.downscroll && whichPlayer == 1) || (SaveData.P2downscroll && whichPlayer == 0))
                yoffset += downscrollOffset;
    
            if (stylelol != 'pixel') //pixel note style doesnt need to be offset
            {
                offset.x -= xoffset;
                offset.y -= yoffset;
            }
        }*/
        
    }
    public function moveKeyPositions(spr:FlxSprite, newMania:Int, player:Int):Void 
    {
        spr.x = 0;
        spr.alpha = 1;

        if ((SaveData.downscroll && player == 1) || (SaveData.P2downscroll && player == 0))
        {
            scale.y *= -1;
        }
        
        if (maniaSwitchPositions[newMania][spr.ID] == "alpha0")
        {
            spr.alpha = 0;
            curID = 10;
            spr.x += 2000; //make it offscreen to not fuck with the arrow lanes
        }            
        else
        {
            spr.x += Note.noteWidths[newMania] * maniaSwitchPositions[newMania][spr.ID] * scaleMulti;
            curID = maniaSwitchPositions[newMania][spr.ID];
        }

        if (newMania == 2)
            spr.x -= Note.tooMuch;
            
        spr.x += 50;
        if (SaveData.middlescroll && player == 1)
            spr.x += ((FlxG.width / 2) * 0.5) + (Note.noteWidths[newMania] / 2);
        else 
            spr.x += ((FlxG.width / 2) * player);

        curMania = newMania;

        if (player == 1 && SaveData.arrowLanes != "Off")
        {
            PlayState.instance.remove(lane);
            lane = new FlxSprite(0, 0).makeGraphic(Std.int(Note.noteWidths[curMania]), Std.int(FlxG.height * 2), flxcolorToUse);
            PlayState.instance.add(lane);
            lane.cameras = [PlayState.instance.camHUD];
            lane.alpha = 0.2;
        }

        defaultX = spr.x;
    }
    override function update(elapsed:Float) 
    {
        super.update(elapsed);

        if (lane != null)
        {
            lane.x = this.x + laneOffset[curMania];
            lane.y = this.y - 300;
        }

    }
        
}