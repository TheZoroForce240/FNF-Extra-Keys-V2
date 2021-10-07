package;

import lime.utils.Assets;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
using StringTools;


class ModchartUtil //where all da functions go, can be used for events and modcharts (also can be hard-coded i guess)
{

    // epic modchart like effects using events instead of lua
	// you change the numbers inside the things and set to enabled and bam you got moving arrows

	// i have some reasoning behind why i am doing it this way, firstly you can do modchart shit without modcharts, so people
	// who know nothing about coding can do modchart shit in the chart editor (once i set it up), secondly modcharts in most engines make the static arrows a variable in their lua state
	// and because of the mania switching, this likely wont work after switching, this system should hopefully fix this shit and automatically do everything, but idk there might be a better way to do this, kinda just tryin stuff
	
	public static var pXEnabled:Bool = false;
	public static var pXnum:Float = 0;
	public static var pXbeatShit:Float = 0;
	public static var pXExtra:Float = 0;
	public static var pXPi:Bool = false;
	public static var pXSin:Bool = false;

	public static var pYEnabled:Bool = false;
	public static var pYnum:Float = 0;
	public static var pYbeatShit:Float = 0;
	public static var pYExtra:Float = 0;
	public static var pYPi:Bool = false;
	public static var pYSin:Bool = false;

	public static var pAngleEnabled:Bool = false;
	public static var pAnglenum:Float = 0;
	public static var pAnglebeatShit:Float = 0;
	public static var pAngleExtra:Float = 0;
	public static var pAnglePi:Bool = false;
	public static var pAngleSin:Bool = false;

	public static var cpuXEnabled:Bool = false;
	public static var cpuXnum:Float = 0;
	public static var cpuXbeatShit:Float = 0;
	public static var cpuXExtra:Float = 0;
	public static var cpuXPi:Bool = false;
	public static var cpuXSin:Bool = false;

	public static var cpuYEnabled:Bool = false;
	public static var cpuYnum:Float = 0;
	public static var cpuYbeatShit:Float = 0;
	public static var cpuYExtra:Float = 0;
	public static var cpuYPi:Bool = false;
	public static var cpuYSin:Bool = false;

	public static var cpuAngleEnabled:Bool = false;
	public static var cpuAnglenum:Float = 0;
	public static var cpuAnglebeatShit:Float = 0;
	public static var cpuAngleExtra:Float = 0;
	public static var cpuAnglePi:Bool = false;
	public static var cpuAngleSin:Bool = false;

    //is it bad having this many public statics????

	////////////////////////////////////////////////////////////////

    public static function ChangeArrowY(i:BabyArrow, Y:Float = 0)
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
    public static function resetArrow(i:BabyArrow, Time:Float = 0.1) //just reset the whole fucking thing
        FlxTween.tween(i, {y: i.defaultY, x: i.defaultX, angle: i.defaultAngle}, Time);

    public static function CalculateArrowShit(i:BabyArrow, ID:Int, num:Float, whatToChange:Int, beatMulti:Float, extraShit:Float, UsePi:Bool = false, sin:Bool = true)
    {
        var CalculatedShit:Float = 0;
        var whatItsChanging:Float;
        switch (whatToChange)
        {
            case 0: 
                whatItsChanging = i.defaultX;
            case 1: 
                whatItsChanging = i.defaultY;
            case 2: 
                whatItsChanging = i.defaultAngle;
            default:
                whatItsChanging = i.defaultX; //backup
        }

        if (sin && !UsePi) //could probably be improved, but it allows modchart shit without modcharts
            CalculatedShit = whatItsChanging + num * Math.sin(beatMulti) + extraShit;
        else if (sin && UsePi)
            CalculatedShit = whatItsChanging + num * Math.sin((beatMulti) * Math.PI) + extraShit;
        else if (!sin && !UsePi)
            CalculatedShit = whatItsChanging + num * Math.cos(beatMulti) + extraShit;
        else  
            CalculatedShit = whatItsChanging + num * Math.cos((beatMulti) * Math.PI) + extraShit;

        return CalculatedShit;
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