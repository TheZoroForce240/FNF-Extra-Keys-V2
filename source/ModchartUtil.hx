package;

import BabyArrow.StrumSettings;
import openfl.filters.BitmapFilter;
import flixel.FlxCamera;
import openfl.filters.ShaderFilter;
import lime.utils.Assets;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.math.FlxRect;
import flixel.math.FlxVelocity;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
using StringTools;


class EventType
{
    public var name:String;
    public var info:String;
    public var arg1Type:String;
    public var arg2Type:String;
    public var arg3Type:String;
    public var arg4Type:String;
    public var arg5Type:String;
    public function new(name:String,info:String,t1:String,t2:String,t3:String,t4:String,t5:String)
    {
        this.name = name;
        this.info = info;
        arg1Type = t1;
        arg2Type = t2;
        arg3Type = t3;
        arg4Type = t4;
        arg5Type = t5;
    }
}

class EventList
{
    public static var Events:Array<EventType> = [
        new EventType('Change P1 Mania', 'Sets the Current Key amount of Player 1(you)\nNeeds to be set to 9k to work', 'stepperInt', 'none', 'none', 'none', 'none'),
        new EventType('Change P2 Mania', 'Sets the Current Key amount of Player 1(you)\nNeeds to be set to 9k to work', 'stepperInt', 'none', 'none', 'none', 'none'),
        new EventType('Change Extra Player Mania', 'Sets the Current Key amount of Player 1(you)\nNeeds to be set to 9k to work\nEnter the Player ID of the extra player(above 2)', 'stepperInt', 'stepperInt', 'none', 'none', 'none'),
        new EventType('Set P1 Modifier', 'Sets a Modifer From the List', 'modDropDown', 'stepper1Dec', 'none', 'none', 'none'),
        new EventType('Set P2 Modifier', 'Sets a Modifer From the List', 'modDropDown', 'stepper1Dec', 'none', 'none', 'none'),
        new EventType('Set Extra Player Modifier', 'Sets a Modifer From the List', 'modDropDown', 'stepper1Dec', 'none', 'none', 'none'),
        new EventType('Tween P1 Modifier', 'Tween a Modifer From the List\nValue 3 = Tween\nValue 4 = Time in Steps', 'modDropDown', 'stepper1Dec', 'tweenDropDown', 'stepper1Dec', 'none'),
        new EventType('Tween P2 Modifier', 'Tween a Modifer From the List\nValue 3 = Tween\nValue 4 = Time in Steps', 'modDropDown', 'stepper1Dec', 'tweenDropDown', 'stepper1Dec', 'none'),
        new EventType('Tween Extra Player Modifier', 'Tween a Modifer From the List\nValue 3 = Tween\nValue 4 = Time in Steps', 'modDropDown', 'stepper1Dec', 'tweenDropDown', 'stepper1Dec', 'none'),
        new EventType('Call Script Function', 'Call a function inside the Song Script\nValue 1 = Func name\nValue 2 = Args(add a comma for multiple args, no spaces)', 'typing', 'typing', 'none', 'none', 'none')
    ];

    public static var tweenList:Array<String> = [ //pain
        'linear',
        'cubeIn',
        'cubeOut',
        'cubeInOut',
        'quadIn',
        'quadOut',
        'quadInOut',
        'quartIn',
        'quartOut',
        'quartInOut',
        'quintIn',
        'quintOut',
        'quintInOut',
        'sineIn',
        'sineOut',
        'sineInOut',
        'backIn',
        'backOut',
        'backInOut',
        'bounceIn',
        'bounceOut',
        'bounceInOut',
        'circIn',
        'circOut',
        'circInOut',
        'elasticIn',
        'elasticOut',
        'elasticInOut',
        'expoIn',
        'expoOut',
        'expoInOut',
        'smoothStepIn',
        'smoothStepOut',
        'smoothStepInOut',
        'smootherStepIn',
        'smootherStepOut',
        'smootherStepInOut'
    ];
    public static var baseModifiers:Map<String, Dynamic> = [ //just copy pasted so its easier
        "xOffset" => 0.0, 
        "yOffset" => 0.0,
        "spin" => 0.0,
        "ghostNotes" => 0.0, 
        "inverseGhostNotes" => 0.0,
        "scramble" => 0.0, 
        "strumsFollowNotes" => 0.0,
        "overlap" => 0.0, 
        "flip" => 0.0,
        "invert" => 0.0,
        "drunk" => 0.0,
        "tipsy" => 0.0,        

        "reverse" => 0.0, 
        "split" => 0.0,
        "cross" => 0.0,
        "alternate" => 0.0,

        "dark" => 0.0, 
        "stealth" => 0.0, 
        "confusion" => 0.0,
        "pingPong" => 0.0,
        "halo" => 0.0,     
        "sideways" => 0.0, 
        "center" => 0.0, 
        "waveyAngle" => 0.0, 
        "druggedAngle" => 0.0, 

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

        "swing" => 0.0, 
        "jumpy" => 0.0, 
        //unfinished
        "dislocated" => 0.0,
        "chaos" => 0.0, 
        "clutter" => 0.0, 
        "bop" => 0.0, 
        "press" => 0.0,
    ];
}

class ModchartUtil //i love tearing down my own code to recode it over and over, now the 3rd time doing it with this
{

    public static var playerStrumsInfo:Array<String> = ["", "", ""];
    public static var cpuStrumsInfo:Array<String> = ["", "", ""];

    public static var P1CamShake:Array<Float> = [0, 0];
    public static var P2CamShake:Array<Float> = [0, 0];

    public static var interp:Interp = new Interp();

    //helper functions
    public static function getCharacter(charactername):Boyfriend    
    {
        if (!PlayState.characters)
            return PlayState.boyfriend; //prevent crashes with extra characters when chracters are disabled


        if (PlayState.dad.curCharacter == charactername)
            return PlayState.dad;
        else if (PlayState.boyfriend.curCharacter == charactername)
            return PlayState.boyfriend;
        for (character in PlayState.extraCharacters)
        {
            if (character.curCharacter == charactername)
                return character;
        }

        return null;
    }
    public static function getNoteFromID(id)
    {
        for (i in PlayState.instance.unspawnNotes)
            if (i.ID == id)
                return i;
        for (i in PlayState.p1.strums.notes)
            if (i.ID == id)
                return i;
        for (i in PlayState.p2.strums.notes)
            if (i.ID == id)
                return i;
        for (i in PlayState.p3.strums.notes)
            if (i.ID == id)
                return i;
        
        return null;
    }
    public static function getStagePiece(piecename)
    {
        for (i in PlayState.instance.StagePiecesBEHIND)
            if (i.part == piecename)
                return i;
        for (i in PlayState.instance.StagePiecesGF)
            if (i.part == piecename)
                return i;
        for (i in PlayState.instance.StagePiecesDAD)
            if (i.part == piecename)
                return i;
        for (i in PlayState.instance.StagePiecesBF)
            if (i.part == piecename)
                return i;
        for (i in PlayState.instance.StagePiecesFRONT)
            if (i.part == piecename)
                return i;
        
        return null;
    }

    //alright here the modifier shit
    //modifier struct is in player.hx btw
    public static function getModif(playernum:Int)
    {
        var curPlayer = PlayState.getPlayerFromID(playernum);
        return curPlayer.modifiers;
    }
    public static function getModifValues(playernum:Int)
    {
        var curPlayer = PlayState.getPlayerFromID(playernum);
        return curPlayer.modifiersValues;
    }


    public static function strumOffset(playernum:Int, noteData:Int, curMania:Int, strum:BabyArrow, curPos:Float = 0, ?daNote:Note)
    {
        var offsetShit:StrumSettings = new StrumSettings();
        offsetShit.pn = playernum;
        var modif = getModif(playernum);
        var modifValues = getModifValues(playernum);
        var playe = PlayState.getPlayerFromID(playernum);
        if (!playe.allowModifiers)
            return offsetShit;

        var arrowSize = Note.noteWidths[curMania];
        var beat = PlayState.instance.currentBeat;
        var keyAmmo = PlayState.keyAmmo[curMania];

        offsetShit.addOffsets(strum.strumOffsets);
        offsetShit.addOffsets(strum.strumOffsetsTwo);
        offsetShit.addOffsets(strum.bopOffset);
 
        for (modifier => modifVal in modif)
        {
            if (modifVal != 0)
            {
                //trace(modifier);
                var func = Reflect.getProperty(Modifier, modifier); //lets see if reflect works for this, will do switch case if it ends up bad
                if (Reflect.isFunction(func))
                {
                    func(modif[modifier],arrowSize,noteData,curMania,offsetShit,curPos);
                }
            }
        }
        var strumModif = strum.modifiers;
        for (modifier => modifVal in strumModif) //do shit for strum specific
            {
                if (modifVal != 0)
                {
                    //trace(modifier);
                    var func = Reflect.getProperty(Modifier, modifier);
                    if (Reflect.isFunction(func))
                    {
                        func(modif[modifier],arrowSize,noteData,curMania,offsetShit,curPos);
                    }
                }
            }
        PlayState.instance.call("StrumOffsets", [[strum, offsetShit]]);
        return offsetShit;
    }

    //old shit i dont use anymore but still exists because compatibility
    public static function CalculateArrowShit(i:BabyArrow, ID:Int, strumnum:Int = 1, thingToCalculate:String = "X", beat:Float)
    {
        var CalculatedShit:Float = 0;
        var stringToBeExecuted:String = "";
        var shit:Int = 0;
        switch (thingToCalculate)
        {
            case "X": 
                shit = 0;
            case "Y": 
                shit = 1;
            case "Angle":
                shit = 2;
        }
        if (strumnum == 1)
            stringToBeExecuted = playerStrumsInfo[shit];
        else 
            stringToBeExecuted = cpuStrumsInfo[shit];

        if (stringToBeExecuted == "")
            return;

        interp.variables.set("arrow", i);
        interp.variables.set("i", ID);
        interp.variables.set("x", i.defaultX);
        interp.variables.set("y", i.defaultY);
        interp.variables.set("elapsedTime", PlayState.instance.elapsedTime);
        interp.variables.set("defaultAngle", i.defaultAngle);
        interp.variables.set("currentBeat", beat);
        interp.variables.set("math", Math);
        interp.variables.set("FlxG", FlxG);
        interp.variables.set("FlxMath", FlxMath);
        interp.variables.set("FlxAngle", FlxAngle);
        interp.variables.set("FlxPoint", FlxPoint);
        interp.variables.set("FlxRandom", FlxRandom);
        interp.variables.set("FlxRect", FlxRect);
        interp.variables.set("FlxVelocity", FlxVelocity);

        var parser = new Parser();
		var expr:Expr;

        try
        {
            expr = parser.parseString(stringToBeExecuted);
            CalculatedShit = interp.execute(expr);
            
            switch (thingToCalculate)
            {
                case "X": 
                    i.x = CalculatedShit;
                case "Y": 
                    i.y = CalculatedShit;
                case "Angle":
                    i.angle = CalculatedShit;
            }
        }
        catch (unknown:Dynamic)
        {
            trace("error or something idk");
        }
    }

    public static function getEase(ease:String = '')
    {
        switch (ease.toLowerCase())
        {
            case 'backin': 
                return FlxEase.backIn;
			case 'backinout': 
                return FlxEase.backInOut;
			case 'backout': 
                return FlxEase.backOut;
			case 'bouncein': 
                return FlxEase.bounceIn;
			case 'bounceinout': 
                return FlxEase.bounceInOut;
			case 'bounceout': 
                return FlxEase.bounceOut;
			case 'circin': 
                return FlxEase.circIn;
			case 'circinout':
                return FlxEase.circInOut;
			case 'circout': 
                return FlxEase.circOut;
			case 'cubein': 
                return FlxEase.cubeIn;
			case 'cubeinout': 
                return FlxEase.cubeInOut;
			case 'cubeout': 
                return FlxEase.cubeOut;
			case 'elasticin': 
                return FlxEase.elasticIn;
			case 'elasticinout': 
                return FlxEase.elasticInOut;
			case 'elasticout': 
                return FlxEase.elasticOut;
			case 'expoin': 
                return FlxEase.expoIn;
			case 'expoinout': 
                return FlxEase.expoInOut;
			case 'expoout': 
                return FlxEase.expoOut;
			case 'quadin': 
                return FlxEase.quadIn;
			case 'quadinout': 
                return FlxEase.quadInOut;
			case 'quadout': 
                return FlxEase.quadOut;
			case 'quartin': 
                return FlxEase.quartIn;
			case 'quartinout': 
                return FlxEase.quartInOut;
			case 'quartout': 
                return FlxEase.quartOut;
			case 'quintin': 
                return FlxEase.quintIn;
			case 'quintinout': 
                return FlxEase.quintInOut;
			case 'quintout': 
                return FlxEase.quintOut;
			case 'sinein': 
                return FlxEase.sineIn;
			case 'sineinout': 
                return FlxEase.sineInOut;
			case 'sineout': 
                return FlxEase.sineOut;
			case 'smoothstepin': 
                return FlxEase.smoothStepIn;
			case 'smoothstepinout': 
                return FlxEase.smoothStepInOut;
			case 'smoothstepout': 
                return FlxEase.smoothStepInOut;
			case 'smootherstepin': 
                return FlxEase.smootherStepIn;
			case 'smootherstepinout': 
                return FlxEase.smootherStepInOut;
			case 'smootherstepout': 
                return FlxEase.smootherStepOut;
            default: 
                return FlxEase.linear;
        }
    }

    public static function changeModifier(name:String, value:Dynamic, playernum:Int)
    {
        var modif = getModif(playernum);
        modif[name] = value;
    }

    public static function getModifierValue(name:String, playernum:Int)
    {
        var modif = getModif(playernum);
        //trace(name + Reflect.getProperty(modif, name));
        return modif[name];
    }
}


class Modifier //TODO, set up so its not checking modifiers every frame, only active ones
{

    public var name:String;
    public var strumFunc:(playernum:Int, noteData:Int, curMania:Int, strum:BabyArrow)->Void;
    public var noteFunc:(daNote:Note, playernum:Int, strum:BabyArrow)->Void;
    public var value:Dynamic;

    public function new(name:String)
    {
        this.name = name;
    }




    /*public function setStrumFunction()
    {
        switch(name)
        {

        }
    }*/

    //for strums


    //not all of the math in here was made by me

    public static function xOffset(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
        pos.x += val;
    public static function yOffset(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
        pos.y += val;
    public static function spin(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
        pos.angle += 180 * (PlayState.instance.currentBeat * val);
    public static function flip(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
        pos.x += (arrowSize * 2 * (1.5 - noteData)) * val;
    public static function invert(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
    {
        var invertShit = noteData % 2;
        if (invertShit == 0)
            invertShit = 1;
        else 
            invertShit = -1;
        pos.x += (arrowSize * invertShit) * val;
    }
    public static function drunk(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
    {
        var modif = ModchartUtil.getModifValues(pos.pn);
        pos.x += val * (Math.cos( ((Conductor.songPosition*0.001) + (noteData*0.2) + (curPos)*(10/FlxG.height)) * (modif['drunkSpeed']*0.2)) * arrowSize*0.5);
    }
    public static function tipsy(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
    {
        var modif = ModchartUtil.getModifValues(pos.pn);
        pos.y += val * ( Math.cos( Conductor.songPosition*0.001 *(1.2) + noteData*(2.0) + modif['tipsySpeed']*(0.2) ) * arrowSize*0.4 );
    }  
    public static function dark(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
    {
        if (curPos == 0)
            pos.alpha *= (1-val);
    }
    public static function confusion(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
        pos.angle += val;
    public static function reverse(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
    {
        pos.y += val*520;
        pos.nDistMulti = 1-(val*2);
    }  
    public static function split(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
    {
        pos.y += noteData+1 > PlayState.keyAmmo[mania]/2 ? val*520 : 0;
        pos.nDistMulti = noteData+1 > PlayState.keyAmmo[mania]/2 ? 1-(val*2) : 1;
    }
        
    public static function cross(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
    {
        pos.y += noteData+1 > PlayState.keyAmmo[mania]/4 && noteData < (PlayState.keyAmmo[mania]/4)*3 ? val*520 : 0;
        pos.nDistMulti = noteData+1 > PlayState.keyAmmo[mania]/4 && noteData < (PlayState.keyAmmo[mania]/4)*3 ? 1-(val*2) : 1;
    }   
    public static function alternate(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
    {
        pos.y += noteData % 2 == 1 ? val*520 : 0;
        pos.nDistMulti = noteData % 2 == 1 ? 1-(val*2) : 1;
    }   
    public static function pingPong(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
    {
        pos.y += Math.min(-arrowSize * Math.sin(PlayState.instance.currentBeat*Math.PI + noteData*Math.PI),0) * val;
        var pingPong = PlayState.instance.currentBeat - Math.floor(PlayState.instance.currentBeat);
        if (PlayState.instance.currentBeat % 2 > 1)
            pingPong = 1 - pingPong;

        var invertShit = noteData % 2;
        if (invertShit == 0)
            invertShit = 1;
        else 
            invertShit = -1;
        pos.x += (arrowSize * invertShit) * (pingPong * 1.2) * val;
    }
    public static function halo(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
    {
        var haloAng = 2*Math.PI*(noteData)/(PlayState.keyAmmo[mania]) + ((PlayState.instance.currentBeat)*0.5*Math.PI);
        var modif = ModchartUtil.getModifValues(pos.pn);
					
        pos.x += modif['haloWidth'] * val * Math.sin(haloAng);
        pos.y += modif['haloHeight'] * val * Math.cos(haloAng);
    }

    public static function sideways(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
    {
        pos.y += Math.abs(val)*(arrowSize*noteData); //do math.abs to make negative work for opposite side scroll
        pos.x += Math.abs(val)*(arrowSize*-noteData) + val*(arrowSize*((PlayState.keyAmmo[mania]+1)/2));
        pos.incomingAngle += 90 * val;
        pos.angle += 90 * Math.abs(val);
    }  

    public static function center(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
    {
        //pos.y += Math.abs(val)*(arrowSize*-noteData); 
        pos.x += Math.abs(val)*(arrowSize*-noteData);// move all strums into same place, well if there isnt any other affects it will
        pos.y += ((FlxG.height / 2)-100)*val;
        switch(PlayState.sDir[mania][noteData])
        {
            case 'LEFT':    
                pos.incomingAngle += 90 * val;
            case 'DOWN': 
                pos.incomingAngle += 180 * val;
            case 'UP': 
                pos.incomingAngle += 0 * val;
            case 'RIGHT': 
                pos.incomingAngle += -90 * val;
        }

        pos.nDistMulti *= 0.5;
    }  

    public static function waveyAngle(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float) //drunk but incoming angle
        pos.incomingAngle += val * (Math.cos( ((Conductor.songPosition*0.001) + (noteData*0.2) + (curPos)*(10/FlxG.height)) * (1*0.2)) * arrowSize*0.5);
    public static function druggedAngle(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float) //tipsy but incoming angle
        pos.incomingAngle += val * ( Math.cos( Conductor.songPosition*0.001 *(1.2) + noteData*(2.0) + 1*(0.2) ) * arrowSize*0.4 );


    public static function tanYAll(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
    {
        var modif = ModchartUtil.getModifValues(pos.pn);   
        pos.y += modif['tanHeight'] * Math.tan((PlayState.instance.currentBeat) * modif['tanSpeed'] * Math.PI);
    }
    public static function tanYSplit(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
    {
        var modif = ModchartUtil.getModifValues(pos.pn);  
        if (noteData+1 > PlayState.keyAmmo[mania]/2) 
            pos.y += modif['tanHeight'] * Math.tan((PlayState.instance.currentBeat) * modif['tanSpeed'] * Math.PI);
        else 
            pos.y += -modif['tanHeight'] * Math.tan((PlayState.instance.currentBeat) * modif['tanSpeed'] * Math.PI);
    }
    public static function tanYCross(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
    {
        var modif = ModchartUtil.getModifValues(pos.pn);
        if (noteData+1 > PlayState.keyAmmo[mania]/4 && noteData < (PlayState.keyAmmo[mania]/4)*3)  
            pos.y += modif['tanHeight'] * Math.tan((PlayState.instance.currentBeat) * modif['tanSpeed'] * Math.PI);
        else 
            pos.y += -modif['tanHeight'] * Math.tan((PlayState.instance.currentBeat) * modif['tanSpeed'] * Math.PI);
    }
    public static function tanYAlternate(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
    {
        var modif = ModchartUtil.getModifValues(pos.pn);   
        if (noteData % 2 == 1)
            pos.y += modif['tanHeight'] * Math.tan((PlayState.instance.currentBeat) * modif['tanSpeed'] * Math.PI);
        else 
            pos.y += -modif['tanHeight'] * Math.tan((PlayState.instance.currentBeat) * modif['tanSpeed'] * Math.PI);
    }

    public static function tanXAll(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
    {
        var modif = ModchartUtil.getModifValues(pos.pn);   
        pos.x += modif['tanWidth'] * Math.tan((PlayState.instance.currentBeat) * modif['tanSpeed'] * Math.PI);
    }
    public static function tanXSplit(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
    {
        var modif = ModchartUtil.getModifValues(pos.pn);  
        if (noteData+1 > PlayState.keyAmmo[mania]/2) 
            pos.x += modif['tanWidth'] * Math.tan((PlayState.instance.currentBeat) * modif['tanSpeed'] * Math.PI);
        else 
            pos.x += -modif['tanWidth'] * Math.tan((PlayState.instance.currentBeat) * modif['tanSpeed'] * Math.PI);
    }
    public static function tanXCross(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
    {
        var modif = ModchartUtil.getModifValues(pos.pn);
        if (noteData+1 > PlayState.keyAmmo[mania]/4 && noteData < (PlayState.keyAmmo[mania]/4)*3)  
            pos.x += modif['tanWidth'] * Math.tan((PlayState.instance.currentBeat) * modif['tanSpeed'] * Math.PI);
        else 
            pos.x += -modif['tanWidth'] * Math.tan((PlayState.instance.currentBeat) * modif['tanSpeed'] * Math.PI);
    }
    public static function tanXAlternate(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
    {
        var modif = ModchartUtil.getModifValues(pos.pn);   
        if (noteData % 2 == 1)
            pos.x += modif['tanWidth'] * Math.tan((PlayState.instance.currentBeat) * modif['tanSpeed'] * Math.PI);
        else 
            pos.x += -modif['tanWidth'] * Math.tan((PlayState.instance.currentBeat) * modif['tanSpeed'] * Math.PI);
    }

    public static function waveX(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
    {
        var modif = ModchartUtil.getModifValues(pos.pn);
        pos.x += modif['waveWidth'] * Math.sin((PlayState.instance.currentBeat + (noteData*modif['waveSpeed'])) * Math.PI);
    }
    public static function waveY(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
    {
        var modif = ModchartUtil.getModifValues(pos.pn);
        pos.y += modif['waveHeight'] * Math.cos((PlayState.instance.currentBeat + (noteData*modif['waveSpeed'])) * Math.PI);
    }
        

    


    public static function jumpy(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
    {
        var noteYShit = Math.cos((Conductor.songPosition*0.001) + (noteData*0.2)) * val;

        pos.y += noteYShit*(FlxG.height / 2) + 250;
        pos.nDistMulti = 1-(noteYShit*2);
    }

    public static function swing(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
    {
        var dataShit = noteData;
        if (pos.pn == 1)
            dataShit = Math.floor(Math.abs(dataShit - (PlayState.keyAmmo[mania]-1)));

        var noteYShit = Math.cos((Conductor.songPosition*0.001) + (dataShit*0.2)) * val * (dataShit*0.2);
        pos.y += noteYShit*(FlxG.height / 2) + 250;
        pos.nDistMulti = 1-(noteYShit*2);
    }

    //for notes, need to redo some of these to fit better with new systems

    public static function ghostNotes(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
    {
        var modif = ModchartUtil.getModifValues(pos.pn);
        if (curPos != 0)
        {
            if (curPos <= (Conductor.stepCrochet * val) + modif['ghostOffset'])
                pos.alpha = FlxMath.remapToRange(curPos, 0, (Conductor.stepCrochet * val) + modif['ghostOffset'], 0, 1);
        }

        
    }
    public static function inverseGhostNotes(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
    {
        var modif = ModchartUtil.getModifValues(pos.pn);
        if (curPos != 0)
        {
            pos.alpha = 0;
            if (curPos <= (Conductor.stepCrochet * val) + modif['ghostOffset'])
                pos.alpha = FlxMath.remapToRange(curPos, 0, (Conductor.stepCrochet * val) + modif['ghostOffset'], 1, 0);
        }

    }

    public static function strumsFollowNotes(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float) //most of this needs note shit so uhh, should prob redo at some point
    {
        //var modif = ModchartUtil.getModifValues(pos.pn);

        /*daNote.y = FlxMath.remapToRange(daNote.strumTime % (Conductor.stepCrochet * (32 * modif['strumsFollowNotes'])), 0, Conductor.stepCrochet * (32 * modif['strumsFollowNotes']), 0, FlxG.height * 2);
        if (daNote.y > FlxG.height)
            daNote.y = FlxMath.remapToRange(daNote.y, 0, FlxG.height, FlxG.height, 0) + FlxG.height;

        if (daNote.strumTime >= Conductor.songPosition + (Conductor.stepCrochet * 12))
            daNote.alpha = 0.1 * daNote.curAlpha;*/
    }
    public static function stealth(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
    {
        if (curPos != 0)
            pos.alpha *= (1-val);
    }

    public static function scaleUp(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float) //NOTE JUMPSCARE
    {
        if (((curPos)*(10/FlxG.height))/25 != 0)
        {
            pos.scaleX = (1 / ((curPos)*(10/FlxG.height))*10) * val;
            pos.scaleY = (1 / ((curPos)*(10/FlxG.height))*10) * val;

            pos.scaleX *= -1 * -val;
            pos.scaleY *= -1 * -val;
            pos.y -= 220 * val;
        }
        if (curPos == 0)
        {
            //pos.y += 150 * val;
            pos.alpha *= (1 - (1 * val));
            //pos.scaleX *= 3;
            //pos.scaleY *= 3;
        }
        
    }  


    public static function slitherY(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
    {
        pos.y += 20 * Math.sin( (curPos+250)/76 ) * val;  
    }
    public static function slitherX(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
    {
        pos.x += 20 * Math.sin( (curPos+250)/76 ) * val;  
    }
    public static function slitherScaleX(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
    {
        if (curPos != 0)
            pos.scaleX *= Math.abs(1 * Math.cos( (curPos+250)/150 ) * val);  
    }
    public static function slitherScaleY(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
    {
        if (curPos != 0)
            pos.scaleY *= Math.abs(1 * Math.cos( (curPos+250)/150 ) * val);  
    }
    public static function slitherIncomingAngle(val:Float, arrowSize:Float, noteData:Int, mania:Int, pos:StrumSettings, curPos:Float)
    {
        pos.incomingAngle += 20 * Math.sin( (curPos+250)/76 ) * val;  
    }
        
}



