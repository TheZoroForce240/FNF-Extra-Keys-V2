package;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.effects.FlxFlicker;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import Controls.Control;
import openfl.utils.Function;
import lime.utils.Assets;
import flixel.FlxG;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
import hscript.ParserEx;
import hscript.InterpEx;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxBasic;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import openfl.utils.Assets as OpenFlAssets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
using StringTools;
import lime.app.Application;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import WiggleEffect.WiggleEffectType;
import openfl.filters.ShaderFilter;
import Shaders.HSVEffect;
import Shaders.HSVShader;
import Shaders.RayMarchEffect;
import Shaders.RayMarchShader;

class HscriptShit //funni modcharts
{
    public var interp:Interp;
    public var enabled:Bool = false;
    var script:Expr;

    public function new (path:String)
    {
        #if sys
		if (FileSystem.exists(path) && PlayState.modcharts)
		{
            try 
            {
                loadScript(path);
                enabled = true;
                setScriptVars();
                interp.execute(script);
            } 
            catch(e) 
            {
                trace(e.message);
            }

        }
        else 
        {
            trace("no file detected");
        }
        #end
    }
    public function call(tfisthis:String, shitToGoIn:Array<Dynamic>) 
    {
		if (interp.variables.exists(tfisthis)) //make sure it exists
        {
            //interp.variables.get(tfisthis)(); //uhh i think this work idk
            //trace(interp.variables.get(tfisthis));
            if (shitToGoIn.length > 0)
                interp.variables.get(tfisthis)(shitToGoIn[0]);
            else
                interp.variables.get(tfisthis)(); //if function doesnt need an arg

            //trace(shitToGoIn);

        }
            
	}
    public function set(tfisthis:String, shitToGoIn:Dynamic)
    {
        interp.variables.set(tfisthis, shitToGoIn); //set a var
    }

    public function loadScript(path:String)
    {
        var parser = new ParserEx(); //dunno what the difference is with ex ver but tryin it anyway, think there something i can do with classes or something but idk theres barely any documentation on it
        #if sys
		var rawCode = File.getContent(path);
		#else
		var rawCode = Assets.getText(path);
		#end
        parser.allowTypes = true;
        parser.allowMetadata = true;
        parser.allowJSON = true;
        parser.resumeErrors = true;
        script = parser.parseString(rawCode); //load da shit
        interp = new Interp();       
        //trace(script);
    }

    function setScriptVars()
    {
        interp.variables.set("loadScript", function () {});
        interp.variables.set("endScript", function () {});
		interp.variables.set("startSong", function (song) {});
        interp.variables.set("onPlayStateCreated", function () {}); //left this here cuz i used it before, just use onStateCreated
        interp.variables.set("onStateCreated", function () {});
        interp.variables.set("endSong", function () {});
		interp.variables.set("update", function (elapsed) {});
		interp.variables.set("stepHit", function(step) {});
        interp.variables.set("beatHit", function (beat) {});
        interp.variables.set("P1NoteHit", function (note:Note) {});
        interp.variables.set("P2NoteHit", function (note:Note) {});
        interp.variables.set("P1NoteMiss", function (note:Note) {});
        interp.variables.set("P2NoteMiss", function (note:Note) {});
        interp.variables.set("P1MissPress", function (direction:Int) {});
        interp.variables.set("P2MissPress", function (direction:Int) {});
        interp.variables.set("P1CpuNoteHit", function (note:Note) {});
        interp.variables.set("P2CpuNoteHit", function (note:Note) {});
        interp.variables.set("P3CpuNoteHit", function (note:Note) {}); //event notes
        interp.variables.set("characterMade", function (character:Character) {});
        interp.variables.set("onManiaChange", function (mania:Int) {});
        interp.variables.set("onStrumsGenerated", function (strums:StrumLineGroup) {});
        interp.variables.set("StrumOffsets", function (strum:BabyArrow) {});
        interp.variables.set("NoteOffsets", function (note:Note) {});
        interp.variables.set("cutscene", function () {}); //need to set allowSongStart to false, you can set up a custom in game cutscene here

        interp.variables.set("instance", PlayState.instance); //dont think this works but who cares
        interp.variables.set("PlayState", PlayState);
        interp.variables.set("Note", Note);
        interp.variables.set("BabyArrow", BabyArrow);
        interp.variables.set("StrumLineGroup", StrumLineGroup);
        interp.variables.set("Math", Math);
        interp.variables.set("FlxG", FlxG); //plz dont do bad thing with this, you have too much power
        interp.variables.set("FlxMath", FlxMath);
        interp.variables.set("FlxAngle", FlxAngle);
        interp.variables.set("ModchartUtil", ModchartUtil); //might need to rename this lol
        interp.variables.set("Conductor", Conductor);
        interp.variables.set("Character", Character);
        interp.variables.set("Boyfriend", Boyfriend);
        interp.variables.set("FlxEase", FlxEase);
        interp.variables.set("FlxTween", FlxTween);
        interp.variables.set("FlxSprite", FlxSprite);
        interp.variables.set("FlxTimer", FlxTimer);
        interp.variables.set("StringTools", StringTools);
        interp.variables.set("curStep", 0);
        interp.variables.set("curBeat", 0);
        interp.variables.set("stepCrochet", Conductor.stepCrochet);
        interp.variables.set("crochet", Conductor.crochet);
        interp.variables.set("bpm", Conductor.bpm);
        interp.variables.set("HealthIcon", HealthIcon);
        interp.variables.set("NoteSplash", NoteSplash);
        interp.variables.set("Std", Std);
        interp.variables.set("Paths", Paths);
        interp.variables.set("WiggleEffect", WiggleEffect);
        interp.variables.set("CoolUtil", CoolUtil);
        interp.variables.set("FlxTrail", FlxTrail);
        interp.variables.set("CacheShit", CacheShit); //not sure about this one, you could clear the cache i guess
        interp.variables.set("MainMenuState", MainMenuState);
        interp.variables.set("Controls", Controls);
        interp.variables.set("FlxText", FlxText);
        interp.variables.set("FlxSound", FlxSound);
        interp.variables.set("FlxFlicker", FlxFlicker);
        interp.variables.set("FlxTypedGroup", FlxTypedGroup);
        interp.variables.set("Main", Main);
        interp.variables.set("TitleState", TitleState);
        interp.variables.set("ColorPresets", ColorPresets);
        interp.variables.set("SaveData", SaveData);
        interp.variables.set("Application", Application);
        interp.variables.set("ShaderFilter", ShaderFilter);
        interp.variables.set("HSVEffect", HSVEffect);
        interp.variables.set("HSVShader", HSVShader);
        interp.variables.set("RayMarchEffect", RayMarchEffect);
        interp.variables.set("RayMarchShader", RayMarchShader);
        interp.variables.set("ScriptEvent", ScriptEvent);
        interp.variables.set("EventCallType", EventCallType);
        interp.variables.set("Player", Player);

        interp.variables.set("setStepEvent", function(_time:Dynamic, _function:String, _input:Array<Dynamic>)
        {
            PlayState.instance.scriptEvents.push(new StepScriptEvent(_time, _function, _input));
        });
        interp.variables.set("setBeatEvent", function(_time:Dynamic, _function:String, _input:Array<Dynamic>)
        {
            PlayState.instance.scriptEvents.push(new BeatScriptEvent(_time, _function, _input));
        });
        interp.variables.set("setStrumTimeEvent", function(_time:Dynamic, _function:String, _input:Array<Dynamic>)
        {
            PlayState.instance.scriptEvents.push(new StrumTimeScriptEvent(_time, _function, _input));
        });

        interp.variables.set("add", function(obj:FlxBasic) 
        {
            FlxG.state.add(obj);
        });
        interp.variables.set("remove", function(obj:FlxBasic) 
        {
            FlxG.state.remove(obj);
        });

        /*interp.variables.set("P1Health", PlayState.instance.P1Stats.health); //apparently these dont wanna work, can access directly through playstate though
        interp.variables.set("StrumLineStartY", PlayState.StrumLineStartY);
        interp.variables.set("playerStrums", PlayState.playerStrums);
        interp.variables.set("cpuStrums", PlayState.cpuStrums);
        interp.variables.set("gfStrums", PlayState.gfStrums);*/

        /*interp.variables.set("changeValue", function (varToUpdate:String, value:Dynamic) //waste of time lol
        {
            /*for (vars in interp.variables.keys())
            {
                if (!functionList.contains(interp.variables[vars])) //dont do this with function
                {

                }
            }
            trace("bruh");
            var split:Array<String> = varToUpdate.split(".");
            var shit:Dynamic = null;
            if (split.length < 1)
                Reflect.setProperty(PlayState.instance, varToUpdate, value); //just do playstate cuz it easier
            else
            {
                //do this at some point
            }
        });*/
    }
}

enum EventCallType //fuck you
{
    STRUMTIME;
    STEP;
    BEAT;
}

class ScriptEvent //a way to make modcharts cleaner by setting events at the start of the song, also means they cannot be missed from lag
{

    //public var callType:EventCallType;
    //fucking enum my ass
    public var callTime:Dynamic;
    public var functionToCall:String;
    public var functionInput:Array<Dynamic>;

    var wasCalled:Bool = false;

    public function new(_time:Dynamic, _function:String, _input:Array<Dynamic>)
    {
        callTime = _time;  
        functionToCall = _function;
        functionInput = _input;
    }

    public function check(shit:Int) //polymorphism go brrrr
    {
    }

    public function callEvent()
    {
        trace("called event");
        PlayState.instance.call(functionToCall, functionInput); //call the modchart function
        wasCalled = true;
        remove();
        
    }
    public function remove() 
        PlayState.instance.scriptEvents.remove(this);
}

class StrumTimeScriptEvent extends ScriptEvent
{
    public function new(_time:Dynamic, _function:String, _input:Array<Dynamic>)
    {
        super(_time, _function, _input);
    }

    override public function check(shit:Int)
    {
        if (callTime <= Conductor.songPosition && !wasCalled)
            callEvent(); 
    }
}
class StepScriptEvent extends ScriptEvent
{
    public function new(_time:Dynamic, _function:String, _input:Array<Dynamic>)
    {
        super(_time, _function, _input);
    }

    override public function check(shit:Int)
    {
        if (shit >= callTime && !wasCalled)
            callEvent(); 
    }
}
class BeatScriptEvent extends ScriptEvent
{
    public function new(_time:Dynamic, _function:String, _input:Array<Dynamic>)
    {
        super(_time, _function, _input);
    }

    override public function check(shit:Int)
    {
        if (shit >= callTime && !wasCalled)
            callEvent(); 
    }
}