package;

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

class EventList
{
    public static var Events:Array<Array<String>> = [
        ["none", "none"],
        ["Move P1 Notes X", "Type in a calculation for the movement\nor select a preset."],
        ["Move P1 Notes Y", "Type in a calculation for the movement\nor select a preset."],
        ["Move P1 Notes Angle", "Type in a calculation for the movement\nor select a preset."],
        ["Stop All P1 Movements", ""],
        ["Move P2 Notes X", "Type in a calculation for the movement\nor select a preset."],
        ["Move P2 Notes Y", "Type in a calculation for the movement\nor select a preset."],
        ["Move P2 Notes Angle", "Type in a calculation for the movement\nor select a preset."],
        ["Stop All P2 Movements", ""],
        ["Change P1 Mania", "Type the new Mania Value.\n(WARNING: the song mania HAS to be set to 9k to work!)"],
        ["Change P2 Mania", "Type the new Mania Value.\n(WARNING: the song mania HAS to be set to 9k to work!)"],
        ["Change Camera Beats", "Type in Cam Zoom amount, Hud Zoom amount, and how often it zooms(in beats)\nSeperate Each value with a comma, no Spaces."],
        ["P1 Cam Shake on Note Hit", "Type in the shake intensity, then the duration\nSeperate each value with a commma, no spaces."],
        ["P2 Cam Shake on Note Hit", "Type in the shake intensity, then the duration\nSeperate each value with a commma, no spaces."]
    ];

    public static var noteMovementsPresets:Array<Array<String>> = [
        ["Wiggle Notes X", "x + 32 * math.sin((currentBeat * 1) + i + 1)"],
        ["Wiggle Notes Y", "y + 32 * math.sin((currentBeat * 1) + i + 1)"],
        ["Move Notes in Sync X", "x + 32 * math.sin((currentBeat * 1) * math.PI)"],
        ["Move Notes in Sync Y", "y + 32 * math.sin((currentBeat * 1) * math.PI)"],
        ["Cross P1 Notes X", "x - 300 * math.sin(currentBeat * 1) - 300"],
        ["Cross P2 Notes X", "x + 300 * math.sin(currentBeat * 1) + 300"]
        //["Cheating Notes X", "arrow.x + (math.sin(elapsedTime * 1) * ((i % 2) == 0 ? 1 : -1)) - (math.sin(elapsedTime * 1) * 1.5)"],
    ];

    public static function convertEventDataToEvent(eventName:String, data:String, daNote:Note)
    {
        trace("finding Event from Event Name"); 
        trace(eventName);
        trace(data);
        if (eventName == null)
            return;
        switch(eventName)
        {
            case "Start Player Strums X movement": //old names still here for legacy charts that still used them
                ModchartUtil.playerStrumsInfo[0] = data;
            case "Start Player Strums Y movement":
                ModchartUtil.playerStrumsInfo[1] = data;
            case "Start Player Strums Angle movement":
                ModchartUtil.playerStrumsInfo[2] = data;
            case "Start CPU Strums X movement":
                ModchartUtil.cpuStrumsInfo[0] = data;
            case "Start CPU Strums Y movement":
                ModchartUtil.cpuStrumsInfo[1] = data;
            case "Start CPU Strums Angle movement":
                ModchartUtil.cpuStrumsInfo[2] = data;
            case "Stop Player Strums X movement":
                ModchartUtil.playerStrumsInfo[0] = "";
            case "Stop Player Strums Y movement":
                ModchartUtil.playerStrumsInfo[1] = "";
            case "Stop Player Strums Angle movement":
                ModchartUtil.playerStrumsInfo[2] = "";
            case "Stop CPU Strums X movement":
                ModchartUtil.cpuStrumsInfo[0] = "";
            case "Stop CPU Strums Y movement":
                ModchartUtil.cpuStrumsInfo[1] = "";
            case "Stop CPU Strums Angle movement":
                ModchartUtil.cpuStrumsInfo[2] = "";

            case "Move P1 Notes X":
                ModchartUtil.playerStrumsInfo[0] = data;
            case "Move P1 Notes Y":
                ModchartUtil.playerStrumsInfo[1] = data;
            case "Move P1 Notes Angle":
                ModchartUtil.playerStrumsInfo[2] = data;
            case "Move P2 Notes X":
                ModchartUtil.cpuStrumsInfo[0] = data;
            case "Move P2 Notes Y":
                ModchartUtil.cpuStrumsInfo[1] = data;
            case "Move P2 Notes Angle":
                ModchartUtil.cpuStrumsInfo[2] = data;
            case "Stop All P1 Movements": 
                ModchartUtil.playerStrumsInfo = ["", "", ""];
            case "Stop All P2 Movements": 
                ModchartUtil.cpuStrumsInfo = ["", "", ""];

            case "Change P1 Mania":
                PlayState.instance.switchMania(Std.parseInt(data), 1);
            case "Change P2 Mania":
                PlayState.instance.switchMania(Std.parseInt(data), 0);
            case "Change Camera Beats": 
                var split:Array<String> = data.split(",");
                PlayState.beatCamZoom = Std.parseFloat(split[0]);
                PlayState.beatCamHUD = Std.parseFloat(split[1]);
                PlayState.beatCamHowOften = Std.parseInt(split[2]);
            case "P1 Cam Shake on Note Hit": 
                var split:Array<String> = data.split(",");
                ModchartUtil.P1CamShake = [Std.parseFloat(split[0]), Std.parseFloat(split[1])];
            case "P2 Cam Shake on Note Hit": 
                var split:Array<String> = data.split(",");
                ModchartUtil.P2CamShake = [Std.parseFloat(split[0]), Std.parseFloat(split[1])];
            default: 
                daNote.eventWasValid = false;
        }
    }
}

class ModchartUtil
{

    public static var playerStrumsInfo:Array<String> = ["", "", ""];
    public static var cpuStrumsInfo:Array<String> = ["", "", ""];

    public static var P1CamShake:Array<Float> = [0, 0];
    public static var P2CamShake:Array<Float> = [0, 0];

    public static var interp:Interp = new Interp();

    public static function getCharacter(charactername):Boyfriend
    {
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

    // epic modchart like effects using events instead of lua

	////////////////////////////////////////////////////////////////

    /*public static function ChangeArrowY(i:BabyArrow, Y:Float = 0)
        i.y = Y;
    public static function ChangeArrowX(i:BabyArrow, X:Float = 0)
        i.x = X;
    public static function ChangeArrowAngle(i:BabyArrow, Angle:Float = 0)
        i.angle = Angle;
    public static function ChangeArrowAlpha(i:BabyArrow, Alpha:Float = 0)
        i.alpha = Alpha;

    public static function resetArrowY(i:BabyArrow, Time:Float = 0.1)
        FlxTween.tween(i, {y: i.defaultY}, Time);
    public static function resetArrowX(i:BabyArrow, Time:Float = 0.1)
        FlxTween.tween(i, {x: i.defaultX}, Time);
    public static function resetArrowAngle(i:BabyArrow, Time:Float = 0.1)
        FlxTween.tween(i, {angle: i.defaultAngle}, Time);
    public static function resetArrowPos(i:BabyArrow, Time:Float = 0.1) //reset x and y
        FlxTween.tween(i, {y: i.defaultY, x: i.defaultX}, Time);
    public static function resetArrow(i:BabyArrow, Time:Float = 0.1) 
        FlxTween.tween(i, {y: i.defaultY, x: i.defaultX, angle: i.defaultAngle}, Time);*/

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

    function getEase(ease:String = '')
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

}