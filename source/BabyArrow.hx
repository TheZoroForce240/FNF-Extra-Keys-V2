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

    var whichPlayer:Int = 0;
    public var stylelol:String = "";
    var colorShiz:Array<Float>;
    var pathToUse:Int = 0;
    public var scaleMulti:Float = 1;

    public var defaultX:Float = 0;
    public var defaultY:Float = 0;
    public var defaultAngle:Float = 0;

    public var defaultWidth:Float;
    public var curID:Int;

    public function new(strumline:Float, player:Int, i:Int, style:String, ?isPlayState:Bool = true)
    {
        super();
        y = strumline;
        var maniaToUse:Int = PlayState.mania;
        if (!isPlayState)
            maniaToUse = CustomizationState.maniaToChange;

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



                var numstatic:Array<Int> = [0, 1, 2, 3, 4, 5, 6, 7, 8]; //this is most tedious shit ive ever done why the fuck is this so hard
                var startpress:Array<Int> = [9, 10, 11, 12, 13, 14, 15, 16, 17];
                var endpress:Array<Int> = [18, 19, 20, 21, 22, 23, 24, 25, 26];
                var startconf:Array<Int> = [27, 28, 29, 30, 31, 32, 33, 34, 35];
                var endconf:Array<Int> = [36, 37, 38, 39, 40, 41, 42, 43, 44];                    
                    switch (maniaToUse)
                    {
                        case 1:
                            numstatic = [0, 2, 3, 5, 1, 8];
                            startpress = [9, 11, 12, 14, 10, 17];
                            endpress = [18, 20, 21, 23, 19, 26];
                            startconf = [27, 29, 30, 32, 28, 35];
                            endconf = [36, 38, 39, 41, 37, 44];

                        case 2: 
                            x -= Note.tooMuch;
                        case 3: 
                            numstatic = [0, 1, 4, 2, 3];
                            startpress = [9, 10, 13, 11, 12];
                            endpress = [18, 19, 22, 20, 21];
                            startconf = [27, 28, 31, 29, 30];
                            endconf = [36, 37, 40, 38, 39];
                        case 4: 
                            numstatic = [0, 2, 3, 4, 5, 1, 8];
                            startpress = [9, 11, 12, 13, 14, 10, 17];
                            endpress = [18, 20, 21, 22, 23, 19, 26];
                            startconf = [27, 29, 30, 31, 32, 28, 35];
                            endconf = [36, 38, 39, 40, 41, 37, 44];
                        case 5: 
                            numstatic = [0, 1, 2, 3, 5, 6, 7, 8];
                            startpress = [9, 10, 11, 12, 14, 15, 16, 17];
                            endpress = [18, 19, 20, 21, 23, 24, 25, 26];
                            startconf = [27, 28, 29, 30, 32, 33, 34, 35];
                            endconf = [36, 37, 38, 39, 41, 42, 43, 44];
                        case 6: 
                            numstatic = [4];
                            startpress = [13];
                            endpress = [22];
                            startconf = [31];
                            endconf = [40];
                        case 7: 
                            numstatic = [0, 3];
                            startpress = [9, 12];
                            endpress = [18, 21];
                            startconf = [27, 30];
                            endconf = [36, 39];
                        case 8: 
                            numstatic = [0, 4, 3];
                            startpress = [9, 13, 12];
                            endpress = [18, 22, 21];
                            startconf = [27, 31, 30];
                            endconf = [36, 40, 39];
                    }
                defaultWidth = width;
                setGraphicSize(Std.int(width * PlayState.daPixelZoom * Note.pixelnoteScale * scaleMulti));
                x += Note.swagWidth * i * scaleMulti; 
                updateHitbox();
                antialiasing = false;
                animation.add('static', [numstatic[i]]);
                animation.add('pressed', [startpress[i], endpress[i]], 12, false);
                animation.add('confirm', [startconf[i], endconf[i]], 24, false);

            default:
                var nSuf:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
                var pPre:Array<String> = ['purple', 'blue', 'green', 'red'];
                    switch (maniaToUse)
                    {
                        case 1:
                            nSuf = ['LEFT', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'RIGHT'];
                            pPre = ['purple', 'green', 'red', 'yellow', 'blue', 'dark'];
    
                        case 2:
                            nSuf = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'SPACE', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
                            pPre = ['purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'darkred', 'dark'];
                            x -= Note.tooMuch;
                        case 3: 
                            nSuf = ['LEFT', 'DOWN', 'SPACE', 'UP', 'RIGHT'];
                            pPre = ['purple', 'blue', 'white', 'green', 'red'];
                        case 4: 
                            nSuf = ['LEFT', 'UP', 'RIGHT', 'SPACE', 'LEFT', 'DOWN', 'RIGHT'];
                            pPre = ['purple', 'green', 'red', 'white', 'yellow', 'blue', 'dark'];
                        case 5: 
                            nSuf = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
                            pPre = ['purple', 'blue', 'green', 'red', 'yellow', 'violet', 'darkred', 'dark'];
                        case 6: 
                            nSuf = ['SPACE'];
                            pPre = ['white'];
                        case 7: 
                            nSuf = ['LEFT', 'RIGHT'];
                            pPre = ['purple', 'red'];
                        case 8: 
                            nSuf = ['LEFT', 'SPACE', 'RIGHT'];
                            pPre = ['purple', 'white', 'red'];
                    }


                var color:String = pPre[i];
                frames = Paths.getSparrowAtlas(pathList[pathToUse]);
                animation.addByPrefix('green', 'arrowUP');
                animation.addByPrefix('blue', 'arrowDOWN');
                animation.addByPrefix('purple', 'arrowLEFT');
                animation.addByPrefix('red', 'arrowRIGHT');

                antialiasing = true;
                defaultWidth = width;
                setGraphicSize(Std.int(width * Note.noteScale * scaleMulti));
                x += Note.swagWidth * i * scaleMulti; 

                animation.addByPrefix('static', 'arrow' + nSuf[i]);
                animation.addByPrefix('pressed', pPre[i] + ' press', 24, false);
                animation.addByPrefix('confirm', pPre[i] + ' confirm', 24, false);
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
            /*updateHitbox();
            offset.x = frameWidth / 2;
            offset.y = frameHeight / 2;


    
            offset.x -= (offsetshit / 0.7) * (scaleToUse * scaleMulti);
            offset.y -= (offsetshit / 0.7) * (scaleToUse * scaleMulti);*/
        }

        if (animation.curAnim.name == 'confirm')
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


        }
        
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
        }            
        else
        {
            spr.x += Note.noteWidths[newMania] * maniaSwitchPositions[newMania][spr.ID];
            curID = maniaSwitchPositions[newMania][spr.ID];
        }

        if (newMania == 2)
            spr.x -= Note.tooMuch;
            
        spr.x += 50;
        if (SaveData.middlescroll && player == 1)
            spr.x += ((FlxG.width / 2) * 0.5) + (Note.noteWidths[newMania] / 2);
        else 
            spr.x += ((FlxG.width / 2) * player);

        defaultX = spr.x;
    }
        
}