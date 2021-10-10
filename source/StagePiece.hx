package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import lime.utils.Assets;
import flixel.util.FlxTimer;

using StringTools;

class StagePiece extends FlxSprite
{
    public var part:String = "stageFront";
    public var newx:Float = 0;
    public var newy:Float = 0;
    public var danceable:Bool = false;
    public static var daBeat:Int = 0;

	public function new(x:Float = 0, y:Float = 0, ?piece:String = "stageFront")
        {
            super(x, y); //x and y are optional, so epic for loop can be used


            var tex:FlxAtlasFrames;
            part = piece;
            antialiasing = true;
            switch(part) //where you put each sprite in the stage
            {
                /////////////////////////////////////////////// week 1
                case 'stageBG': 
                    loadGraphic(Paths.image('stageback'));
                    newx = -600;
                    newy = -200;
                    scrollFactor.set(0.9, 0.9);
                    active = false;
                case 'stageFront': 
                    loadGraphic(Paths.image('stagefront'));
                    newx = -650;
                    newy = 600;
                    setGraphicSize(Std.int(width * 1.1));
                    updateHitbox();
                    scrollFactor.set(0.9, 0.9);
                    active = false;
                case 'stageCurtains': 
                    loadGraphic(Paths.image('stagecurtains'));
                    newx = -500;
                    newy = -300;
                    setGraphicSize(Std.int(width * 0.9));
                    updateHitbox();
                    scrollFactor.set(1.3, 1.3);
                    active = false;

                /////////////////////////////////////////////////////// week 2
                case 'halloweenBG': 
                    danceable = true;
                    tex = Paths.getSparrowAtlas('halloween_bg');
                    frames = tex;
                    newx = -200;
                    newy = -100;
					animation.addByPrefix('idle', 'halloweem bg0');
					animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
					animation.play('idle');
                /////////////////////////////////////////////////////// week 3


                //////////////////////////////////////////////////////// week 4

                case 'limoSkyBG': 
                    loadGraphic(Paths.image('limo/limoSunset'));
                    newx = -120;
                    newy = -50;
                    scrollFactor.set(0.1, 0.1);
                case 'limoBG': 
                    tex = Paths.getSparrowAtlas('limo/bgLimo');
                    frames = tex;
                    newx = -200;
                    newy = 480;
                    animation.addByPrefix('drive', "background limo pink", 24);
					scrollFactor.set(0.4, 0.4);
                    animation.play('drive');
                case 'bgDancer': 
                    danceable = true;
                    tex = Paths.getSparrowAtlas("limo/limoDancer");
                    frames = tex;
                    animation.addByIndices('danceLeft', 'bg dancer sketch PINK', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		            animation.addByIndices('danceRight', 'bg dancer sketch PINK', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		            animation.play('danceLeft');
                    newy = 80;
                    newx = 130;
                    scrollFactor.set(0.4, 0.4);
                case 'limoOverlay': 
                    loadGraphic(Paths.image('limo/limoOverlay'));
                    newx = -500;
                    newy = -600;
                    alpha = 0.5;
                case 'limo': 
                    tex = Paths.getSparrowAtlas('limo/limoDrive');
                    frames = tex;
                    newx = -120;
                    newy = 550;
                    animation.addByPrefix('drive', "Limo stage", 24);
					animation.play('drive');
                case 'fastCar': 
                    danceable = true;
                    loadGraphic(Paths.image('limo/fastCarLol'));
                    newx = -300;
                    newy = 160;
                    resetFastCar();
                ///////////////////////////////////////////////////////////// week 5
                case 'mallBG': 
                    loadGraphic(Paths.image('christmas/bgWalls'));
                    newx = -1000;
                    newy = -500;
                    scrollFactor.set(0.2, 0.2);
					active = false;
					setGraphicSize(Std.int(width * 0.8));
					updateHitbox();
                case 'mallUpperBoppers':
                    danceable = true;
                    tex = Paths.getSparrowAtlas('christmas/upperBop');
                    frames = tex;
                    newx = -240;
                    newy = -90;
                    animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
					scrollFactor.set(0.33, 0.33);
					setGraphicSize(Std.int(width * 0.85));
					updateHitbox();
                case 'mallEscalator': 
                    loadGraphic(Paths.image('christmas/bgEscalator'));
                    newx = -1100;
                    newy = -600;
                    scrollFactor.set(0.3, 0.3);
					active = false;
					setGraphicSize(Std.int(width * 0.9));
					updateHitbox();
                case 'mallTree': 
                    loadGraphic(Paths.image('christmas/christmasTree'));
                    newx = 370;
                    newy = -250;
                    scrollFactor.set(0.40, 0.40);
                case 'mallBottomBoppers': 
                    danceable = true;
                    tex = Paths.getSparrowAtlas('christmas/bottomBop');
                    frames = tex;
                    newx = -300;
                    newy = 140;
                    animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
					scrollFactor.set(0.9, 0.9);
					setGraphicSize(Std.int(width * 1));
					updateHitbox();
                case 'mallSnow': 
                    loadGraphic(Paths.image('christmas/fgSnow'));
                    newx = -600;
                    newy = 700;
                    active = false;
                case 'mallSanta': 
                    danceable = true;
                    tex = Paths.getSparrowAtlas('christmas/santa');
                    frames = tex;
                    newx = -840;
                    newy = 150;
                    animation.addByPrefix('bop', 'santa idle in fear', 24, false);
                /////////////////////////////////////////////////////// week 5 (winter horrorland)
                case 'mallEvilBG': 
                    loadGraphic(Paths.image('christmas/evilBG'));
                    newx = -400;
                    newy = -500;
                    scrollFactor.set(0.2, 0.2);
                    active = false;
                    setGraphicSize(Std.int(width * 0.8));
                    updateHitbox();
                case 'mallEvilTree': 
                    loadGraphic(Paths.image('christmas/evilTree'));
                    newx = 300;
                    newy = -300;
                    scrollFactor.set(0.2, 0.2);
                case 'mallEvilSnow': 
                    loadGraphic(Paths.image("christmas/evilSnow"));
                    newx = -200;
                    newy = 700;
                //////////////////////////////////////////////////////// week 6
                case 'school-bgSky':
                    loadGraphic(Paths.image('weeb/weebSky'));
                    scrollFactor.set(0.1, 0.1);
                    antialiasing = false;
                case 'school-bgSchool': 
                    loadGraphic(Paths.image('weeb/weebSchool'));
                    scrollFactor.set(0.6, 0.90);
                    antialiasing = false;
                case 'school-bgStreet': 
                    loadGraphic(Paths.image('weeb/weebStreet'));
                    scrollFactor.set(0.95, 0.95);
                    antialiasing = false;
                case 'school-fgTrees': 
                    loadGraphic(Paths.image('weeb/weebTreesBack'));
                    scrollFactor.set(0.9, 0.9);
                    newx = 170;
                    newy = 130;
                    antialiasing = false;
                case 'school-bgTrees': 
                    tex = Paths.getPackerAtlas('weeb/weebTrees');
                    frames = tex;
                    animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
                    animation.play('treeLoop');
                    scrollFactor.set(0.85, 0.85);
                    newx = -380;
                    newy = -800;
                    antialiasing = false;
                case 'school-treeLeaves': 
                    tex = Paths.getSparrowAtlas('weeb/petals');
                    frames = tex;
                    animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
		            animation.play('leaves');
		            scrollFactor.set(0.85, 0.85);
                    newy = -40;
                    antialiasing = false;
                case 'bgGirls': 
                    tex = Paths.getSparrowAtlas('weeb/bgFreaks');
                    frames = tex;
                    animation.addByIndices('danceLeft', 'BG girls group', CoolUtil.numberArray(14), "", 24, false);
                    animation.addByIndices('danceRight', 'BG girls group', CoolUtil.numberArray(30, 15), "", 24, false);
                    animation.play('danceLeft');
                    newx = -100;
                    newy = 190;
                    scrollFactor.set(0.9, 0.9);
                    danceable = true;
                    if (PlayState.SONG.song.toLowerCase() == 'roses')
                    {
                            getScared();
                    }
                    setGraphicSize(Std.int(this.width * PlayState.daPixelZoom));
		            updateHitbox();
                    antialiasing = false;
                ///////////////////////////////////////////////////////////// week 6 (thorns)
                case 'schoolEvilBG': 
                    tex = Paths.getSparrowAtlas('weeb/animatedEvilSchool');
                    frames = tex;
                    newx = 400;
                    newy = 200;
                    animation.addByPrefix('idle', 'background 2', 24);
                    animation.play('idle');
                    scrollFactor.set(0.8, 0.9);
                    scale.set(6, 6);
                    antialiasing = false;
                ////////////////////////////////////////////////////////////// your own stage pieces go here

                case "non-animated example": //please use these examples to copy paste for your own
                    loadGraphic(Paths.image('file path here'));
                    newx = -400; //x and y
                    newy = -500;
                    scrollFactor.set(0.2, 0.2); //scroll factor
                    setGraphicSize(Std.int(width * 0.8)); //do this or scale.set
                    updateHitbox();
                    danceable = false; //danceble means it can do something every beat, set this in dance()
                case "animated example": 
                    tex = Paths.getSparrowAtlas('path here');
                    frames = tex;
                    newx = 400;
                    newy = 200;
                    animation.addByPrefix('idle', 'background 2', 24); //set the animations here
                    animation.play('idle');
                    scrollFactor.set(0.8, 0.9);
                    scale.set(6, 6);
                    danceable = false; //danceble means it can do something every beat, set this in dance()
            }
            
        }

    public function getScared():Void //only for week 6 bg girls
        {
            animation.addByIndices('danceLeft', 'BG fangirls dissuaded', CoolUtil.numberArray(14), "", 24, false);
            animation.addByIndices('danceRight', 'BG fangirls dissuaded', CoolUtil.numberArray(30, 15), "", 24, false);
            dance();
        }

    var danceDir:Bool = false;
    var fastCarCanDrive:Bool = true;
    var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
    public function dance():Void //not always dance, just what the piece does every beat
        {
            if (danceable)
            {
                switch (part)
                {
                    case 'bgGirls' | 'bgDancer':
                        danceDir = !danceDir;
    
                        if (danceDir)
                            animation.play('danceRight', true);
                        else
                            animation.play('danceLeft', true);

                    case 'mallSanta' | 'mallUpperBoppers' | 'mallBottomBoppers': 
                        animation.play("bop", true);
                    case 'fastCar': 
                        if (FlxG.random.bool(10) && fastCarCanDrive)
                            fastCarDrive();
                    case 'halloweenBG': 
                        if (FlxG.random.bool(10) && daBeat > lightningStrikeBeat + lightningOffset)
                            lightningStrikeShit();


                }
            }  
        }

    override function update(elapsed:Float)
        {
            super.update(elapsed);

        }

    function lightningStrikeShit():Void //for week 2
        {
            FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
            animation.play('lightning');
            lightningStrikeBeat = daBeat;
            lightningOffset = FlxG.random.int(8, 24);
            PlayState.boyfriend.playAnim('scared', true);
            PlayState.gf.playAnim('scared', true);
        }

	function resetFastCar():Void //for week 4
	{
		x = -12600;
		y = FlxG.random.int(140, 250);
		velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive() //for week 4
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}
        
}
/*class Stage //was gonns use this but its fine how it is
{
    public var pieceList:Array<String> = [];
    public var stageZoom:Float = 1.05;
    public function new(stage:String)
        {
            super();

            //pieces = new FlxTypedGroup<StagePiece>();
            //add(pieces);
            switch (stage)
            { 
                case "stage": 
                    stageZoom = 0.9;
                    pieceList = ['stageBG', 'stageFront', 'stageCurtains']; //add order
                case "spooky": 

                case "philly": 

                case "limo": 

                case "mall": 

                case "mallEvil": 

                case "school": 

                case "schoolEvil": 

            }
            for (i in 0...pieceList.length)
            {
                var thepiece:StagePiece = new StagePiece(pieceList[i]);

                this.add(thepiece);

            }
            super();
        }
} */