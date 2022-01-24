package;

import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import Shaders;
import flixel.math.FlxPoint;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;

class BabyArrow extends FlxSprite
{
    var HSV:HSVEffect = new HSVEffect();

    public static var offsetshit:Float = 56;

    var pathList:Array<String> = Note.pathList;

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
    public static var laneOffset:Array<Float> = [
        0,
        10,
        13,
        5,
        10,
        12,
        0,
        0,
        0
    ];


    public var whichPlayer:Int = 0;
    public var stylelol:String = "";
    public var colorShiz:Array<Float>;
    var pathToUse:Int = 0;
    public var scaleMulti:Float = 1;
    public var widthMulti:Float = 1;
    public var curMania:Int = 0;

    public var defaultX:Float = 0;
    public var defaultY:Float = 0;
    public var defaultAngle:Float = 0;

    public var defaultWidth:Float;
    public var curID:Int;

    //public var strumLineAngle:Float = 0;
    //public var strumLineCenter:FlxPoint;

    public var centerOfArrow:FlxPoint;

    var flxcolorToUse:FlxColor = FlxColor.BLACK;
    var inPlayState:Bool = true;

    public var strumLineAngle:Float = -90;

    public function new(strumline:Float, player:Int, i:Int, style:String, ?isPlayState:Bool = true)
    {
        super();
        y = strumline;
        var maniaToUse:Int = PlayState.mania;
        if (!isPlayState)
            maniaToUse = CustomizationState.maniaToChange;

        inPlayState = isPlayState;

        this.ID = i;
        this.curID = i;

        if (player >= 2)
            maniaToUse = 0;

        curMania = maniaToUse;

        whichPlayer = player;

		if (player == 0)
        {
            colorShiz = ColorPresets.noteColors[BabyArrow.colorFromData[maniaToUse][i]];
        }
        else if (player == 1)
        {
            colorShiz = SaveData.noteColors[BabyArrow.colorFromData[maniaToUse][i]];
        }

        if (Note.usingQuant)
            colorShiz = [0,0,0,4];
        
        if (player < 2)
        {
            pathToUse = Std.int(colorShiz[3]);
            if (pathToUse == 5)
                style = 'pixel';
        }


        stylelol = style;


        widthMulti = SaveData.noteWidthMulti;
        scaleMulti = SaveData.noteScaleMulti;

        if (SaveData.middlescroll && player == 0)
            scaleMulti *= 0.55;

        createLane();
        loadStrum(pathList[pathToUse]);

        this.shader = HSV.shader;
        

        setupStrum();
        positionStrum();





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


            //y += 200;
            //lane.angle = this.angle;



            


    }
    public function positionStrum():Void 
    {
        this.x = 50;
        x += Note.noteWidths[curMania] * curID * scaleMulti * widthMulti; 
        switch (curMania)
        {
            case 2:
                x -= Note.tooMuch;
        }
        if (SaveData.middlescroll && whichPlayer == 1)
            x += ((FlxG.width / 2) * 0.5) + ((Note.noteWidths[curMania] * widthMulti) / 2);
        else 
            x += ((FlxG.width / 2) * whichPlayer);

        if (whichPlayer == 2)
        {
            y = PlayState.gf.y - 300;
            x = (PlayState.gf.x + (PlayState.gf.width / 2)) - (Note.noteWidths[0] * 2) + Note.noteWidths[0] * curID;
        }

        defaultX = this.x;
        defaultY = this.y;
        defaultAngle = this.angle;

        if (lane != null)
        {
            lane.x = this.x + laneOffset[curMania];
            lane.y = this.y - 300;
        }

        centerOfArrow = new FlxPoint(this.getGraphicMidpoint().x, this.getGraphicMidpoint().y);
    }

    private function setupStrum():Void 
    {
        if (whichPlayer < 2)
            scrollFactor.set();
        else if (whichPlayer == 2)
            scrollFactor.set(PlayState.gf.scrollFactor.x, PlayState.gf.scrollFactor.y); //gf notes same scroll as gf
        else 
            scrollFactor.set(1,1);

        if ((SaveData.downscroll && whichPlayer == 1) || (SaveData.P2downscroll && whichPlayer == 0))
        {
            scale.y *= -1;
        }

        

        if (!PlayState.isStoryMode && inPlayState)
        {
            if (PlayState.instance.showStrumsOnStart)
            {
                y -= 10;
                alpha = 0;
                FlxTween.tween(this, {y: y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * ((curID * 4) / PlayState.keyAmmo[curMania]))});
                if (lane != null)
                {
                    lane.alpha = 0;
                    FlxTween.tween(lane, {alpha: SaveData.laneOpacity}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * ((curID * 4) / PlayState.keyAmmo[curMania]))});
                } 
            }
        }
        if (inPlayState)
            if (!PlayState.instance.showStrumsOnStart)
                alpha = 0;

        if (SaveData.splitScroll && whichPlayer == 1)
        {
            this.cameras = PlayState.p1.getNoteCams();
        }
        else if (SaveData.P2splitScroll && whichPlayer == 0)
        {
            this.cameras = PlayState.p2.getNoteCams();
        }
    }

    function createLane():Void 
    {
        var color = Note.frameN[curMania][curID];
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


        if (inPlayState && (whichPlayer == 1 || (whichPlayer == 0 && PlayState.multiplayer || PlayState.flipped)) && SaveData.arrowLanes != "Off")
        {
            lane = new FlxSprite(0, 0).makeGraphic(Std.int(Note.noteWidths[curMania] * widthMulti), Std.int(FlxG.height * 2), flxcolorToUse);
            PlayState.instance.add(lane);
            lane.cameras = [PlayState.instance.camHUD];
            lane.alpha = SaveData.laneOpacity;
        }
    }

    public function loadStrum(path:String) //so you can change sprite mid song
    {
        frames = null;
        animation.destroyAnimations();

        var color = Note.frameN[curMania][this.ID];

        switch (stylelol)
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
                setGraphicSize(Std.int(width * PlayState.daPixelZoom * Note.pixelNoteScales[curMania] * scaleMulti));
                updateHitbox();
                antialiasing = false;
                animation.add('static', [colorFromData[curMania][ID]]);
                animation.add('pressed', [colorFromData[curMania][ID] + 9, colorFromData[curMania][ID] + 18], 12, false);
                animation.add('confirm', [colorFromData[curMania][ID] + 27, colorFromData[curMania][ID] + 36], 24, false);

            default:
                var dir = dirArray[curMania][ID];
                frames = Paths.getSparrowAtlas(path);
                animation.addByPrefix('green', 'arrowUP');
                animation.addByPrefix('blue', 'arrowDOWN');
                animation.addByPrefix('purple', 'arrowLEFT');
                animation.addByPrefix('red', 'arrowRIGHT');

                antialiasing = true;
                defaultWidth = width;
                setGraphicSize(Std.int(width * Note.noteScales[curMania] * scaleMulti));

                animation.addByPrefix('static', 'arrow' + dir);
                animation.addByPrefix('pressed', color + ' press', 24, false);
                animation.addByPrefix('confirm', color + ' confirm', 24, false);
                updateHitbox();
		}
        animation.play('static');
    }


    public function showStrum()
    {
        y -= 10;
        alpha = 0;
        FlxTween.tween(this, {y: y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * ((curID * 4) / PlayState.keyAmmo[curMania]))});
        if (lane != null)
        {
            lane.alpha = 0;
            FlxTween.tween(lane, {alpha: SaveData.laneOpacity}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * ((curID * 4) / PlayState.keyAmmo[curMania]))});
        } 
    }
    public function playAnim(anim:String, ?force:Bool = false, id:Int, colorShit:Array<Float>)
    {
        animation.play(anim, force);
        animation.curAnim.frameRate = Std.int(24 * PlayState.SongSpeedMultiplier);
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
            HSV.hue = colorShit[0];
            HSV.saturation = colorShit[1];
            HSV.brightness = colorShit[2];
            HSV.update();
        }

        if (stylelol != "pixel")
        {
            //offset.x -= xoffset;
            //offset.y -= yoffset;
            var scaleToUse = Note.p1NoteScale;
            if (whichPlayer == 0)
                scaleToUse = Note.p2NoteScale;
            if (whichPlayer == 2)
                scaleToUse = Note.noteScales[0];

            centerOrigin();
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
        spr.visible = true;

        if ((SaveData.downscroll && player == 1) || (SaveData.P2downscroll && player == 0))
        {
            scale.y *= -1;
        }
        
        if (maniaSwitchPositions[newMania][spr.ID] == "alpha0")
        {
            spr.visible = false; //changed it visible rather than alpha so it doesnt interfere with modifiers
            curID = 10;
            spr.x += 2000; //make it offscreen to not fuck with the arrow lanes
        }            
        else
        {
            spr.x += Note.noteWidths[newMania] * maniaSwitchPositions[newMania][spr.ID] * scaleMulti * widthMulti;
            curID = maniaSwitchPositions[newMania][spr.ID];
        }

        if (newMania == 2)
            spr.x -= Note.tooMuch;
            
        spr.x += 50;
        if (SaveData.middlescroll && player == 1)
            spr.x += ((FlxG.width / 2) * 0.5) + ((Note.noteWidths[newMania] * widthMulti) / 2);
        else 
            spr.x += ((FlxG.width / 2) * player);

        curMania = newMania;

        if (SaveData.splitScroll && player == 1)
        {
            this.cameras = PlayState.p1.getNoteCams();
        }
        else if (SaveData.P2splitScroll && player == 0)
        {
            this.cameras = PlayState.p2.getNoteCams();
        }

        if ((player == 1 || (player != 1 && PlayState.multiplayer)) && SaveData.arrowLanes != "Off")
        {
            PlayState.instance.remove(lane);
            lane = new FlxSprite(0, 0).makeGraphic(Std.int(Note.noteWidths[curMania] * widthMulti), Std.int(FlxG.height * 2), flxcolorToUse);
            PlayState.instance.add(lane);
            lane.cameras = [PlayState.instance.camHUD];
            lane.alpha = SaveData.laneOpacity;
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
        centerOfArrow.set(x + (Note.noteWidths[curMania] * scaleMulti * widthMulti) / 2, y + (Note.noteWidths[curMania] * scaleMulti * widthMulti) / 2);

        if (whichPlayer == 2)
        {
            y = PlayState.gf.y - 200;
            x = (PlayState.gf.x + (PlayState.gf.width / 2)) - (Note.noteWidths[0] * 2) + Note.noteWidths[0] * curID;
        }


        
        if (inPlayState)
        {
            var StrumGroup:StrumLineGroup = PlayState.p1.strums;
            var modif = PlayState.p1.modifiers;
            var curPlayer = PlayState.getPlayerFromID(whichPlayer);
            StrumGroup = curPlayer.strums;
            modif = curPlayer.modifiers;

            if (this.curID == 10) //from mania changes
                return;

            this.strumLineAngle = modif.scrollAngle;

            var distanceToCenter = StrumGroup.strumLineCenter.x - defaultX;
            var strumPos = FlxAngle.getCartesianCoords(distanceToCenter, strumLineAngle + 90);
            this.setPosition(StrumGroup.strumLineCenter.x - strumPos.x, StrumGroup.strumLineCenter.y - strumPos.y);
            this.angle = 0;

            if (modif.StrumLinefollowAngle)
                this.angle = this.strumLineAngle + 90;
            var strumOffset = ModchartUtil.strumOffset(whichPlayer, curID, curMania);

            this.x += strumOffset[0];
            this.y += strumOffset[1];
            this.angle += strumOffset[2];

            this.alpha = modif.strumAlpha;
            this.scrollFactor.set(modif.strumScrollFactor[0], modif.strumScrollFactor[1]); //can change scroll factor because funi

            if (modif.boundStrums)
            {
                x = (x + FlxG.width) % FlxG.width;
                y = (y + FlxG.height) % FlxG.height;
            }

            if (modif.strumsFollowNotes != 0)
            {
                y = FlxMath.remapToRange(Conductor.songPosition % (Conductor.stepCrochet * (32 * modif.strumsFollowNotes)), 0, Conductor.stepCrochet * (32 * modif.strumsFollowNotes), 0, FlxG.height * 2);
                if (y > FlxG.height)
                    y = FlxMath.remapToRange(y, 0, FlxG.height, FlxG.height, 0) + FlxG.height;

                y -= Note.noteWidths[curMania] / 2;
            }



            PlayState.instance.call("StrumOffsets", [this]);


            if (whichPlayer == 0)
            {
                if (modif.overlap != 0)
                {
                    x = FlxMath.remapToRange(modif.overlap, 0, 1, this.x, PlayState.p1.strums.members[this.curID].x);
                    y = FlxMath.remapToRange(modif.overlap, 0, 1, this.x, PlayState.p1.strums.members[this.curID].y);
                    angle = FlxMath.remapToRange(modif.overlap, 0, 1, this.x, PlayState.p1.strums.members[this.curID].angle);
                }
            }



        }

    }
        
}