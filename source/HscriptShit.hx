package;

import openfl.utils.Function;
import lime.utils.Assets;
import flixel.FlxG;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
import hscript.ParserEx;
import hscript.InterpEx;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import openfl.utils.Assets as OpenFlAssets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
using StringTools;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import Shaders;


class HscriptShit //funni modcharts
{
    public var interp:Interp;
    public var enabled:Bool = false;
    var script:Expr;

    public function new (song:String)
    {
        var path = "assets/data/charts/" + song + "/script.hscript";
        #if sys
		if (FileSystem.exists(path))
		{
            loadScript(path);
            enabled = true;
            setScriptVars();
            interp.execute(script);
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
        script = parser.parseString(rawCode); //load da shit
        interp = new Interp();       
        //trace(script);
    }

    function setScriptVars()
    {
        interp.variables.set("loadScript", function () {});
        interp.variables.set("endScript", function () {});
		interp.variables.set("startSong", function (song) {});
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
        interp.variables.set("P1NoteSpawned", function (note:Note) {}); //3.5 seconds before strumtime
        interp.variables.set("P2NoteSpawned", function (note:Note) {}); 
        interp.variables.set("P3NoteSpawned", function (note:Note) {});
        interp.variables.set("P1NoteNowOnScreen", function (note:Note) {}); //when you can see them on screen
        interp.variables.set("P2NoteNowOnScreen", function (note:Note) {});
        interp.variables.set("P3NoteNowOnScreen", function (note:Note) {});

        interp.variables.set("instance", PlayState.instance); //dont think this works but who cares
        interp.variables.set("PlayState", PlayState);
        interp.variables.set("Note", Note);
        interp.variables.set("BabyArrow", BabyArrow);
        interp.variables.set("StrumLineGroup", StrumLineGroup);
        interp.variables.set("math", Math);
        interp.variables.set("FlxG", FlxG); //plz dont do bad thing with this, you have too much power
        interp.variables.set("FlxMath", FlxMath);
        interp.variables.set("FlxAngle", FlxAngle);
        interp.variables.set("ModchartUtil", ModchartUtil); //might need to rename this lol
        interp.variables.set("Conductor", Conductor);
        interp.variables.set("Character", Character);
        interp.variables.set("Boyfriend", Boyfriend);
        interp.variables.set("FlxEase", FlxEase);
        interp.variables.set("FlxTween", FlxTween);
        interp.variables.set("FlxTimer", FlxTimer);
        interp.variables.set("StringTools", StringTools);
        interp.variables.set("curStep", 0);
        interp.variables.set("curBeat", 0);
        interp.variables.set("HealthIcon", HealthIcon);
        interp.variables.set("NoteSplash", NoteSplash);
        interp.variables.set("Std", Std);
        interp.variables.set("Paths", Paths);
        interp.variables.set("CoolUtil", CoolUtil);
        interp.variables.set("CacheShit", CacheShit); //not sure about this one, you could clear the cache i guess
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