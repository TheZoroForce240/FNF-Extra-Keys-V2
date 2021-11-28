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
#if sys
import sys.io.File;
import sys.FileSystem;
#end


class HscriptShit //thing i wanna do in the future for funni modchart
{
    public var interp:Interp;
    public var enabled:Bool = false;
    var script:Expr;
    static var functionList = ["update", "stepHit", "updateGame", "loadScript", "beatHit", "startSong"];

    public function new (song:String)
    {
        var path = "assets/data/charts/" + song + "/script.hscript"; //using hx so its detected as haxe in vsc
        #if sys
		if (FileSystem.exists(path))
		{
            loadScript(path);
            enabled = true;
            setScriptVars();
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
        interp.execute(script);
        //trace(script);
    }

    function setScriptVars()
    {
        interp.variables.set("loadScript", function () {});
		interp.variables.set("startSong", function (song) {});
		interp.variables.set("update", function (elapsed) {});
		interp.variables.set("stepHit", function(step) {});
        interp.variables.set("beatHit", function (beat) {});
        interp.variables.set("instance", PlayState.instance);
        interp.variables.set("PlayState", PlayState);
        interp.variables.set("math", Math);
        interp.variables.set("FlxG", FlxG);
        interp.variables.set("FlxMath", FlxMath);
        interp.variables.set("FlxAngle", FlxAngle);
        interp.variables.set("P1Health", PlayState.instance.P1Stats.health);

        interp.variables.set("changeValue", function (varToUpdate:String, value:Dynamic) 
        {
            /*for (vars in interp.variables.keys())
            {
                if (!functionList.contains(interp.variables[vars])) //dont do this with function
                {

                }
            }*/
            trace("bruh");
            var split:Array<String> = varToUpdate.split(".");
            var shit:Dynamic = null;
            if (split.length < 1)
                Reflect.setProperty(PlayState.instance, varToUpdate, value); //just do playstate cuz it easier
            else
            {
                //do this at some point
            }
        });
    }



}