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

using StringTools;

class StrumSettings
{
    public var x:Float = 0;
    public var y:Float = 0;
    public var angle:Float = 0;
    public var scaleX:Float = 1;
    public var scaleY:Float = 1;
    public var alpha:Float = 1;

    public var pn:Int = 1;

    //extra stuff for notes
    public var nDistMulti:Float = 1; //for reverse and shit on notes (fix sustains and shit)
    public var incomingAngle:Float = 0;
    public function new() {}
    public function set(a:Float,b:Float,c:Float,d:Float,e:Float,f:Float)
    {
        x = a;
        y = b;
        angle = c;
        scaleX = d;
        scaleY = e;
        alpha = f;
    }
    public function addOffsets(a:StrumSettings)
    {
        this.x += a.x;
        this.y += a.y;
        this.angle += a.angle;
        this.scaleX *= a.scaleX;
        this.scaleX *= a.scaleY;
        this.alpha *= a.alpha;
    }
    
    public function tweenX(to:Float,time:Float,ease:String)
        FlxTween.tween(this, {x: to}, time, {ease: ModchartUtil.getEase(ease)});
    public function tweenY(to:Float,time:Float,ease:String)
        FlxTween.tween(this, {y: to}, time, {ease: ModchartUtil.getEase(ease)});
    public function tweenAngle(to:Float,time:Float,ease:String)
        FlxTween.tween(this, {angle: to}, time, {ease: ModchartUtil.getEase(ease)});
    public function tweenScaleX(to:Float,time:Float,ease:String)
        FlxTween.tween(this, {scaleX: to}, time, {ease: ModchartUtil.getEase(ease)});
    public function tweenScaleY(to:Float,time:Float,ease:String)
        FlxTween.tween(this, {scaleY: to}, time, {ease: ModchartUtil.getEase(ease)});
    public function tweenAlpha(to:Float,time:Float,ease:String)
        FlxTween.tween(this, {alpha: to}, time, {ease: ModchartUtil.getEase(ease)});
    public function resetTween(time:Float,ease:String)
        FlxTween.tween(this, {x: 0, y:0, angle:0, scaleX: 1, scaleY:1, alpha:1}, time, {ease: ModchartUtil.getEase(ease)});
}

class BabyArrow extends FlxSprite
{
    var HSV:HSVEffect = new HSVEffect();

    public static var offsetshit:Float = 56; //112 is default width so half that is center, fixes all offsets on any scale

    var pathList:Array<String> = Note.pathList;

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

    public var nCol:String = ""; //note color
    public var whichPlayer:Int = 0;
    public var stylelol:String = ""; //note style (for pixel notes)
    public var colorShiz:Array<Float>; //hsv shit
    var pathToUse:Int = 0; //file path index for list
    public var scaleMulti:Float = 1; //for middlescroll
    public var widthMulti:Float = 1; //not used rn but can probably set up
    public var curMania:Int = 0; //for mania changes
    public var curScaleX:Float = 0.7; //for updating scale every frame
    public var curScaleY:Float = 0.7;

    public var defaultX:Float = 0; //for modchart shit
    public var defaultY:Float = 0;
    public var defaultAngle:Float = 0;

    public var defaultWidth:Float;

    public var curID:Int; //allows modcharts to use correct shit when using noteData with mania changes

    public var modifiers:Map<String, Dynamic> = [
        'dark' => 0.0,
        'stealth' => 0.0,
        'confusion' => 0.0,
        'reverse' => 0.0,
    ];

    public var strumOffsets:StrumSettings = new StrumSettings(); //dont think i can put in shitty map
    public var strumOffsetsTwo:StrumSettings = new StrumSettings(); //an extra one in case you need it
    public var bopOffset:StrumSettings = new StrumSettings();
    public var bopTo:StrumSettings = new StrumSettings();
    public var pressOffset:StrumSettings = new StrumSettings();
    public var bopTime:Float = 0;
    public var bopEase:String = 'cubeInOut';
    public var noteSine:Array<Float> = [0,0];
    //public var strumLineAngle:Float = 0;
    //public var strumLineCenter:FlxPoint;

    public var centerOfArrow:FlxPoint; //for sustain clipping

    var flxcolorToUse:FlxColor = FlxColor.BLACK; //for lanes
    var inPlayState:Bool = true; //fix customization menu

    public var strumLineAngle:Float = -90; //the entire strumtime can be angled, this is default num

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
            colorShiz = ColorPresets.noteColors[BabyArrow.colorFromData[maniaToUse][i % Note.MaxNoteData]];
        }
        else if (player == 1)
        {
            colorShiz = SaveData.noteColors[BabyArrow.colorFromData[maniaToUse][i % Note.MaxNoteData]];
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
        

        positionStrum();
        setupStrum();
        





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
        x += Note.maniaXOffsets[curMania];
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
        if (SaveData.arrowLanes == "Colored")
        {
            switch (nCol)
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
            lane = new FlxSprite(0, 0).makeGraphic(Std.int(Note.noteWidths[curMania] * widthMulti * 1.05), Std.int(FlxG.height * 2), flxcolorToUse);
            PlayState.instance.add(lane);
            lane.cameras = [PlayState.instance.camHUD];
            lane.alpha = SaveData.laneOpacity;
        }
    }

    public function loadStrum(path:String) //so you can change sprite mid song
    {
        frames = null;
        animation.destroyAnimations();

        nCol = Note.frameN[curMania][this.ID];

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
                animation.add('static', [colorFromData[curMania][ID % Note.MaxNoteData]]);
                animation.add('pressed', [colorFromData[curMania][ID % Note.MaxNoteData] + 9, colorFromData[curMania][ID % Note.MaxNoteData] + 18], 12, false);
                animation.add('confirm', [colorFromData[curMania][ID % Note.MaxNoteData] + 27, colorFromData[curMania][ID % Note.MaxNoteData] + 36], 24, false);

            default:
                var dir = dirArray[curMania][ID % Note.MaxNoteData];
                frames = Paths.getSparrowAtlas(path);
                animation.addByPrefix('green', 'arrowUP');
                animation.addByPrefix('blue', 'arrowDOWN');
                animation.addByPrefix('purple', 'arrowLEFT');
                animation.addByPrefix('red', 'arrowRIGHT');

                antialiasing = true;
                defaultWidth = width;
                setGraphicSize(Std.int(width * Note.noteScales[curMania] * scaleMulti));

                animation.addByPrefix('static', 'arrow' + dir);
                animation.addByPrefix('pressed', nCol + ' press', 24, false);
                animation.addByPrefix('confirm', nCol + ' confirm', 24, false);
                updateHitbox();
		}
        animation.play('static');
        curScaleX = scale.x;
        curScaleY = scale.y;
        if ((SaveData.downscroll && whichPlayer == 1) || (SaveData.P2downscroll && whichPlayer == 0))
            curScaleY *= -1;
        
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
            centerOrigin();
            updateHitbox();
            offset.x = frameWidth / 2;
            offset.y = frameHeight / 2;

            offset.x -= (offsetshit / 0.7) * (scale.x * scaleMulti);
            offset.y -= (offsetshit / 0.7) * (scale.x * scaleMulti); //do scale.x on y so it matches correctly, changing to scale.y will fuck it up just leave it
        }
    }
    public function moveKeyPositions(spr:FlxSprite, newMania:Int, player:Int):Void 
    {
        spr.x = 0;
        spr.visible = true;

        if ((SaveData.downscroll && player == 1) || (SaveData.P2downscroll && player == 0))
        {
            scale.y *= -1;
        }
        
        /*if (maniaSwitchPositions[newMania][spr.ID] == "alpha0")
        {
            spr.visible = false; //changed it visible rather than alpha so it doesnt interfere with modifiers
            curID = 10;
            spr.x += 2000; //make it offscreen to not fuck with the arrow lanes
        }            
        else
        {
            spr.x += Note.noteWidths[newMania] * maniaSwitchPositions[newMania][spr.ID] * scaleMulti * widthMulti;
            curID = maniaSwitchPositions[newMania][spr.ID];
        }*/

        var nCol = Note.frameN[PlayState.mania][spr.ID];
        if (Note.frameN[newMania].contains(nCol)) ////softcoded ye fuck you
        {
            curID = Note.frameN[newMania].indexOf(nCol);
            spr.x += Note.noteWidths[newMania] * curID * scaleMulti * widthMulti;
        }
        else
        {
            spr.visible = false; //changed it visible rather than alpha so it doesnt interfere with modifiers
            curID = 10;
            spr.x += 2000; //make it offscreen to not fuck with the arrow lanes
        }

        spr.x += Note.maniaXOffsets[newMania];
            
        spr.x += 50;
        if (SaveData.middlescroll && player == 1)
            spr.x += ((FlxG.width / 2) * 0.5) + ((Note.noteWidths[newMania] * widthMulti) / 2) - 40;
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
            lane = new FlxSprite(0, 0).makeGraphic(Std.int(Note.noteWidths[curMania] * widthMulti * 1.05), Std.int(FlxG.height * 2), flxcolorToUse);
            PlayState.instance.add(lane);
            lane.cameras = [PlayState.instance.camHUD];
            lane.alpha = SaveData.laneOpacity;
        }

        defaultX = spr.x;
    }

    static var rainbowColors:Array<FlxColor> = [
        0xFFFF0000,
        0xFFFF7F00,
        0xFFFFFF00,
        0xFF00FF00,
        0xFF0000FF,
        0xFF4B0082,
        0xFF9400D3
    ];
    override function update(elapsed:Float) 
    {
        super.update(elapsed);


        centerOfArrow.set(x + (Note.noteWidths[curMania] * scaleMulti * widthMulti * 0.75), y + (Note.noteWidths[curMania] * scaleMulti * widthMulti) / 2);
        if (lane != null)
        {
            lane.x = this.x + PlayState.keyAmmo[curMania];
            lane.y = this.y - 300;
        }

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

            if (!curPlayer.allowModifiers)
                return;

            //this.strumLineAngle = modif['scrollAngle'];

            var distanceToCenter = StrumGroup.strumLineCenter.x - defaultX;
            var strumPos = FlxAngle.getCartesianCoords(distanceToCenter, strumLineAngle + 90);
            this.setPosition(StrumGroup.strumLineCenter.x - strumPos.x, StrumGroup.strumLineCenter.y - strumPos.y);
            this.angle = 0;
            this.scale.x = curScaleX;
            this.scale.y = curScaleY;
            this.alpha = 1; //fucking dumbass
            this.color = 0x00FFFFFF;
            //this.alpha = modif['strumAlpha'];

            //if (modif['StrumLinefollowAngle'])
                //this.angle = this.strumLineAngle + 90;
            var strumOffset = ModchartUtil.strumOffset(whichPlayer, curID, curMania, this);

            this.x += strumOffset.x;
            this.y += strumOffset.y;
            this.angle += strumOffset.angle;
            this.scale.x *= strumOffset.scaleX;
            this.scale.y *= strumOffset.scaleY;
            this.alpha *= strumOffset.alpha;

            if (modif['rainbowNotes'] != 0)
            {
                this.color = rainbowColors[(Math.floor(PlayState.instance.currentBeat * modif['rainbowNotes'])) % rainbowColors.length];  
            }
            if (modif['flash'] != 0)
            {
                this.color = FlxColor.WHITE;
            }

            //this.scrollFactor.set(modif['strumScrollFactor'][0], modif['strumScrollFactor'][1]); //can change scroll factor because funi

            /*if (modif['boundStrums'])
            {
                x = (x + FlxG.width) % FlxG.width;
                y = (y + FlxG.height) % FlxG.height;
            }*/

            /*if (modif['strumsFollowNotes'] != 0)
            {
                y = FlxMath.remapToRange(Conductor.songPosition % (Conductor.stepCrochet * (32 * modif['strumsFollowNotes'])), 0, Conductor.stepCrochet * (32 * modif['strumsFollowNotes']), 0, FlxG.height * 2);
                if (y > FlxG.height)
                    y = FlxMath.remapToRange(y, 0, FlxG.height, FlxG.height, 0) + FlxG.height;

                y -= Note.noteWidths[curMania] / 2;
            }*/


            /*if (whichPlayer == 0)
            {
                if (modif['overlap'] != 0)
                {
                    x = FlxMath.remapToRange(modif['overlap'], 0, 1, this.x, PlayState.p1.strums.members[this.curID].x);
                    y = FlxMath.remapToRange(modif['overlap'], 0, 1, this.x, PlayState.p1.strums.members[this.curID].y);
                    angle = FlxMath.remapToRange(modif['overlap'], 0, 1, this.x, PlayState.p1.strums.members[this.curID].angle);
                }
            }*/

            

        }

    }



    public function tweenMod(modifToChange:String, modifValue:Dynamic, ?time:Float, ease:String = "linear") //new ver, literally just swapped time and ease args so it makes sense
    {
        if (time == null)
            time = Conductor.crochet / 1000;
        var easeToUse = ModchartUtil.getEase(ease);
        var startVal = modifiers[modifToChange];

        FlxTween.num(startVal, modifValue, time, {onUpdate: function(tween:FlxTween){
            var ting = FlxMath.lerp(startVal,modifValue, tween.percent);
            modifiers[modifToChange] = ting;
        }, ease: easeToUse, onComplete: function(tween:FlxTween) {
            modifiers[modifToChange] = modifValue;
        }});
    }
        
}