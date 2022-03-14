package;

import flixel.tweens.FlxEase;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxCamera;
import openfl.filters.ShaderFilter;
import Shaders;
import WiggleEffect.WiggleEffectType;

/*
has most things that are duplicated for each player (strum groups, stats, cameras for downscroll, etc),
the strum group class has the rest of the stuff (notes, notesplash and strum notes)
*/
class Player
{

    public var strums:StrumLineGroup = null;
    public var generatedStrums:Bool = false;
    public var wiggleShit:WiggleEffect = new WiggleEffect();
    public var mustHitNotes:Bool = false;

    public var allowModifiers:Bool = true;

    public var Stats = {
		songScore : 0,
		fc : true,
		sicks : 0,
		goods : 0,
		bads : 0,
		shits : 0,
		sustainsHit : 0,
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
		acclerp : 0.0,
		npsArray : []
	};

    //a lot of this is inspired from notitg and other cool ass fnf modcharts
    //kinda just trying to replicate and make it all work with different key amounts and mania changes and shit

    public var modifiers:Map<String, Dynamic> = [ //move to a map so no more reflect bullshit (code should hopefully be faster i think??)
        "xOffset" => 0.0, //strum notes total offset (affects all notes)
        "yOffset" => 0.0,

        ///fun modifiers
        "spin" => 0.0, //makes notes spin
        "ghostNotes" => 0.0, //disappear when about to be hit
        "inverseGhostNotes" => 0.0, //appear when about to be hit
        
        "scramble" => 0.0, //notes follow the wrong strum note, doesnt change the input you have to press to hit the note
        "strumsFollowNotes" => 0.0, //instead of notes falling onto strums, strums move into the notes, value affects speed, smaller = faster
        "overlap" => 0.0, //overlaps p2 strums over p1, only works when used on p2

        //stuff from the hex modchart (which i think was from notitg or stepmania or something idk lol)
        "flip" => 0.0,
        "invert" => 0.0,
        "drunk" => 0.0,
        "tipsy" => 0.0,        

        "reverse" => 0.0, //opposite scroll
        "split" => 0.0, //split scroll
        "cross" => 0.0, //middle notes change scroll
        "alternate" => 0.0, //every 1 note changes scroll

        "dark" => 0.0, //strum alpha
        "stealth" => 0.0, //note alpha
        "confusion" => 0.0,
        //dizzy : 0.0,
        //wave : 0.0,

        "pingPong" => 0.0, //from hex again
        "halo" => 0.0,
        
        //my own shitty math
        "sideways" => 0.0, // side scroll (can do -1 for other side)
        "center" => 0.0, //center scroll (notes come from outside)
        "waveyAngle" => 0.0, //drunk/tipsy on incoming angles
        "druggedAngle" => 0.0, 

        //just basic stuff in case you need it
        "tanYAll" => 0.0,
        "tanYSplit" => 0.0,
        "tanYCross" => 0.0,
        "tanYAlternate" => 0.0,

        "tanXAll" => 0.0,
        "tanXSplit" => 0.0,
        "tanXCross" => 0.0,
        "tanXAlternate" => 0.0,

        "waveX" => 0.0,
        "waveY" => 0.0,

        //ideas for these are from my friend death1nsurance
        "swing" => 0.0, // notes move up and down
        "jumpy" => 0.0, //they bounce
        //unfinished
        "dislocated" => 0.0, //notes are offcentered slightly
        "chaos" => 0.0, //note go fucking everywhere
        "clutter" => 0.0, //notes move into each other
        "bop" => 0.0, //notes bounce with the beat
        "press" => 0.0, //notes move when pressed

        "scaleUp" => 0.0, //NOTE JUMPSCARE
        "rainbowNotes" => 0.0,
        "flash" => 0.0, //make notes white

        "slitherY" => 0.0,
        "slitherX" => 0.0, 
        "slitherScaleY" => 0.0,
        "slitherScaleX" => 0.0,
        "slitherIncomingAngle" => 0.0,
        
    ];
    public var modifiersValues:Map<String, Dynamic> = [ //stuff that doesnt use functions
        
        "scrollAngle" => -90, //moves entire strumline angle btw (easy side scroll lol)
        "incomingAngleIsStrumAngle" => false, //forces the incoming angle of a note to be the strumnotes angle
        "StrumLinefollowAngle" => false, //makes the strumnote angle snap to the angle of the strumline (just visual)
        "strumScrollFactor" => [0.0,0.0], //doesnt work rn

        "ghostOffset" => 300.0,
        "boundStrums" => false, //strums will loop around the screen if they go offscreen, kinda wonky though

        "haloWidth" => 50.0,
        "haloHeight" => 25.0,

        "drunkSpeed" => 1.0,
        "tipsySpeed" => 1.0,

        "tanWidth" => 32.0,
        "tanHeight" => 32.0,
        "tanSpeed" => 0.25,
        "waveWidth" => 32.0,
        "waveHeight" => 32.0,
        "waveSpeed" => 0.25,
    ];

    //NO LONGER USING THIS BECAUSE ITS A DUMB SYSTEM (still here to prevent crashes on old modcharts)
    public var modifValues = { //values stored for certain modifiers
        xOffset0 : 0.0,
        xOffset1 : 0.0,
        xOffset2 : 0.0,
        xOffset3 : 0.0,
        xOffset4 : 0.0,
        xOffset5 : 0.0,
        xOffset6 : 0.0,
        xOffset7 : 0.0,
        xOffset8 : 0.0,

        yOffset0 : 0.0,
        yOffset1 : 0.0,
        yOffset2 : 0.0,
        yOffset3 : 0.0,
        yOffset4 : 0.0,
        yOffset5 : 0.0,
        yOffset6 : 0.0,
        yOffset7 : 0.0,
        yOffset8 : 0.0,

        zOffset0 : 0.0,
        zOffset1 : 0.0,
        zOffset2 : 0.0,
        zOffset3 : 0.0,
        zOffset4 : 0.0,
        zOffset5 : 0.0,
        zOffset6 : 0.0,
        zOffset7 : 0.0,
        zOffset8 : 0.0,

        pressOffset0 : [0.0,0.0,0.0],
        pressOffset1 : [0.0,0.0,0.0],
        pressOffset2 : [0.0,0.0,0.0],
        pressOffset3 : [0.0,0.0,0.0],
        pressOffset4 : [0.0,0.0,0.0],
        pressOffset5 : [0.0,0.0,0.0],
        pressOffset6 : [0.0,0.0,0.0],
        pressOffset7 : [0.0,0.0,0.0],
        pressOffset8 : [0.0,0.0,0.0],

        bopOffset0 : [0.0,0.0,0.0],
        bopOffset1 : [0.0,0.0,0.0],
        bopOffset2 : [0.0,0.0,0.0],
        bopOffset3 : [0.0,0.0,0.0],
        bopOffset4 : [0.0,0.0,0.0],
        bopOffset5 : [0.0,0.0,0.0],
        bopOffset6 : [0.0,0.0,0.0],
        bopOffset7 : [0.0,0.0,0.0],
        bopOffset8 : [0.0,0.0,0.0],

        bopTo0 : [-20.0,0.0,0.0], //so you can set it manually
        bopTo1 : [0.0,20.0,0.0],
        bopTo2 : [0.0,-20.0,0.0],
        bopTo3 : [20.0,0.0,0.0],
        bopTo4 : [0.0,-20.0,0.0],
        bopTo5 : [-20.0,0.0,0.0],
        bopTo6 : [0.0,20.0,0.0],
        bopTo7 : [0.0,-20.0,0.0],
        bopTo8 : [20.0,0.0,0.0],

        noteSine0 : [0.0,1.0], //these make the notes wavy as they fall
        noteSine1 : [0.0,1.0],
        noteSine2 : [0.0,1.0],
        noteSine3 : [0.0,1.0],
        noteSine4 : [0.0,1.0],
        noteSine5 : [0.0,1.0],
        noteSine6 : [0.0,1.0],
        noteSine7 : [0.0,1.0],
        noteSine8 : [0.0,1.0],
  }

    public var playernum:Int;
    public var noteCams:Array<FlxCamera> = [];
    public var noteCamsSus:Array<FlxCamera> = [];    //so i can have wiggle sustains
    public var char:Boyfriend;
    public var isCpu:Bool = true;
    public var activeCharacters = [];
    public var curMania:Int = 0;
    public var curNoteScale:Float = 0.7;
    public var curNoteMania:Int = 0;
    public var prevNoteMania:Int = 0;
    public var lastManiaChange:Float = 0; //in strumtime

    public function new(player:Int = 0)
    {
        playernum = player;
    }
    public function resetManias(mania:Int)
    {
        curMania = mania;
        curNoteMania = mania;
        prevNoteMania = mania;
        lastManiaChange = 0;    
    }
	public function updateCams()
    {
        for (i in 0...PlayState.instance.amountOfNoteCams)
        {
            if (noteCamsSus[i] != null) //stop crashing
            {
                noteCamsSus[i].x = noteCams[i].x; //so sustain cam is always in same place as regaulr note cam
                noteCamsSus[i].y = noteCams[i].y;
                noteCamsSus[i].angle = noteCams[i].angle;
                noteCamsSus[i].zoom = noteCams[i].zoom;
            }

        }
    }

    public function createCams()
    {
        for (i in 0...PlayState.instance.amountOfNoteCams)
        {
            var noteCam = new FlxCamera();
            noteCam.bgColor.alpha = 0;
            noteCams.push(noteCam);

            var noteCamSus = new FlxCamera();
            noteCamSus.bgColor.alpha = 0;
            noteCamsSus.push(noteCamSus);
        }

    }
    public function addCams()
    {
        for (i in 0...PlayState.instance.amountOfNoteCams)
        {
            FlxG.cameras.add(noteCams[i]);
            FlxG.cameras.add(noteCamsSus[i]);

            noteCamsSus[i].setFilters([new ShaderFilter(wiggleShit.shader)]);
        }

        
    }
    public function resetStats()
    {
        Stats.songScore = 0;
		Stats.fc = true;
		Stats.sicks = 0;
		Stats.goods = 0;
		Stats.bads = 0;
		Stats.shits = 0;
		Stats.misses = 0;
		Stats.sustainsHit = 0;
		Stats.ghostmisses = 0;
		Stats.totalNotesHit = 0;
		Stats.accuracy = 0;
		Stats.curRank = "None";
		Stats.combo = 0;
		Stats.highestCombo = 0;
		Stats.nps = 0;
		Stats.highestNps = 0;
		Stats.health = 1;
		Stats.poisonHits = 0;
		Stats.npsArray = [];
    }

    public function downscrollCheck(downscroll:Bool)
    {

    }

    public function createStrums()
    {
        strums = new StrumLineGroup(playernum);
    }
    public function setNoteCams()
    {
        strums.noteSplashes.cameras = [];
        strums.cameras = [];
        strums.notes.cameras = [];
        for (i in 0...PlayState.instance.amountOfNoteCams)
        {
            strums.noteSplashes.cameras.push(noteCams[i]);
            strums.cameras.push(noteCams[i]);
            strums.notes.cameras.push(noteCams[i]);
        }
    }
    public function addNotes()
    {
        strums.notes = new FlxTypedGroup<Note>();
        PlayState.instance.add(strums.notes);
    }
    public function snapCams(camHUD:FlxCamera)
    {
        for (i in 0...PlayState.instance.amountOfNoteCams)
        {
            noteCams[i].x = camHUD.x; //so they match up when it moves, pretty much will just be for modcharts and shit
            noteCams[i].y = camHUD.y;
            noteCams[i].angle = camHUD.angle;
            noteCamsSus[i].x = camHUD.x; //so they match up when it moves, pretty much will just be for modcharts and shit
            noteCamsSus[i].y = camHUD.y;
            noteCamsSus[i].angle = camHUD.angle;
        }
    }
    public function getNoteCams(sus:Bool = false)
    {
        var cams:Array<FlxCamera> = [];
        if (!sus)
        {
            for (i in 0...PlayState.instance.amountOfNoteCams)
                cams.push(noteCams[i]);
        }
        else
        {
            for (i in 0...PlayState.instance.amountOfNoteCams)
                cams.push(noteCamsSus[i]);
        }
        return cams;
    }

    public function tweenModifier(modifToChange:String, modifValue:Dynamic, ease:String = "cubeInOut", ?time:Float)
    {
        if (time == null)
            time = Conductor.crochet / 1000;
        
        var easeToUse = ModchartUtil.getEase(ease);
    
        FlxTween.num(ModchartUtil.getModifierValue(modifToChange, this.playernum), modifValue, time, {onUpdate: function(tween:FlxTween){
            var ting = FlxMath.lerp(ModchartUtil.getModifierValue(modifToChange, this.playernum),modifValue, tween.percent);
            ModchartUtil.changeModifier(modifToChange, ting, this.playernum);
        }, ease: easeToUse, onComplete: function(tween:FlxTween) {
            ModchartUtil.changeModifier(modifToChange, modifValue, this.playernum);
        }});
    }


    public function tweenMod(modifToChange:String, modifValue:Dynamic, ?time:Float, ease:String = "linear") //new ver, literally just swapped time and ease args so it makes sense
    {
        if (time == null)
            time = Conductor.crochet / 1000;
        var easeToUse = ModchartUtil.getEase(ease);
        var startVal = ModchartUtil.getModifierValue(modifToChange, this.playernum);
    
        FlxTween.num(startVal, modifValue, time, {onUpdate: function(tween:FlxTween){
            var ting = FlxMath.lerp(startVal,modifValue, tween.percent);
            ModchartUtil.changeModifier(modifToChange, ting, this.playernum);
        }, ease: easeToUse, onComplete: function(tween:FlxTween) {
            ModchartUtil.changeModifier(modifToChange, modifValue, this.playernum);
        }});
    }
}