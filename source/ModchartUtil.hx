package;

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

class EventList
{
    public static var Events:Array<Array<String>> = [
        ["none", "none"],
        ["Change P1 Mania", "Type the new Mania Value.\n(WARNING: the song mania HAS to be set to 9k to work!)"],
        ["Change P2 Mania", "Type the new Mania Value.\n(WARNING: the song mania HAS to be set to 9k to work!)"],
        ["Change Extra Player Mania", "Type in the player ID,\nand Type the new Mania Value.\nSeperate each value with a commma, no spaces.\n(WARNING: the song mania HAS to be set to 9k to work!)"],
        ["Change Camera Beats", "Type in Cam Zoom amount, Hud Zoom amount, and how often it zooms(in beats)\nSeperate Each value with a comma, no Spaces."],
        ["P1 Cam Shake on Note Hit", "Type in the shake intensity, then the duration\nSeperate each value with a commma, no spaces."],
        ["P2 Cam Shake on Note Hit", "Type in the shake intensity, then the duration\nSeperate each value with a commma, no spaces."],
        ["Change P1 Modifier", "Type in the modifier name, then add a comma and\n type in the value of the modifier, no spaces btw"],
        ["Change P2 Modifier", "Type in the modifier name, then add a comma and\n type in the value of the modifier, no spaces btw"],
        ["Change P3 Modifier", "Type in the modifier name, then add a comma and\n type in the value of the modifier, no spaces btw\nOnly works if gf strums are enabled."]
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
        /*trace("finding Event from Event Name"); 
        trace(eventName);
        trace(data);*/
        if (eventName == null || eventName.trim() == '')
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
            case "Change Extra Player Mania":
                var split:Array<String> = data.split(",");
                PlayState.instance.switchMania(Std.parseInt(split[1]), Std.parseInt(split[2]));
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
            case "Change P1 Modifier": 
                var split:Array<String> = data.split(",");
                var value:Dynamic = 0.0;
                if (split[1] == "false")
                    value = false;
                else if (split[1] == "true")
                    value = true;
                else
                    value = Std.parseFloat(split[1]); //assume its a float??? i think floats will work with ints if there are any
                 
                ModchartUtil.changeModifier(split[0], value, 1);
            case "Change P2 Modifier": 
                var split:Array<String> = data.split(",");
                var value:Dynamic = 0.0;
                if (split[1] == "false")
                    value = false;
                else if (split[1] == "true")
                    value = true;
                else
                    value = Std.parseFloat(split[1]);
                    
                ModchartUtil.changeModifier(split[0], value, 0);

            case "Change P3 Modifier": 
                var split:Array<String> = data.split(",");
                var value:Dynamic = 0.0;
                if (split[1] == "false")
                    value = false;
                else if (split[1] == "true")
                    value = true;
                else
                    value = Std.parseFloat(split[1]);
                    
                ModchartUtil.changeModifier(split[0], value, 2);
                
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
        return curPlayer.modifValues;
    }


    public static function strumOffset(playernum:Int, noteData:Int, curMania:Int, strum:BabyArrow)
    {
        var xPos:Float = 0;
        var yPos:Float = 0;
        var ang:Float = 0;
        var scaleX:Float = 1;
        var scaleY:Float = 1;
        var alpha:Float = 1;

        var modif = getModif(playernum);
        var modifValues = getModifValues(playernum);
        var playe = PlayState.getPlayerFromID(playernum);
        if (!playe.allowModifiers)
            return [xPos,yPos,ang,scaleX,scaleY,alpha];

        var arrowSize = Note.noteWidths[curMania];
        var beat = PlayState.instance.currentBeat;
        var keyAmmo = PlayState.keyAmmo[curMania];

        xPos += modif['xOffset'];
        yPos += modif['yOffset'];

        xPos += strum.strumOffsets.x;
        yPos += strum.strumOffsets.y;
        ang += strum.strumOffsets.angle;
        scaleX *= strum.strumOffsets.scaleX;
        scaleY *= strum.strumOffsets.scaleY;
        alpha *= strum.strumOffsets.alpha;
        
        xPos += strum.strumOffsetsTwo.x;
        yPos += strum.strumOffsetsTwo.y;
        ang += strum.strumOffsetsTwo.angle;
        scaleX *= strum.strumOffsetsTwo.scaleX;
        scaleY *= strum.strumOffsetsTwo.scaleY;
        alpha *= strum.strumOffsetsTwo.alpha;
        //manual modifiers
        if (modif['sinWaveX'][0] != 0)
            xPos += sinWave(modif['sinWaveX'][0], modif['sinWaveX'][1], noteData);
        if (modif['sinWaveY'][0] != 0)
            yPos += sinWave(modif['sinWaveY'][0], modif['sinWaveY'][1], noteData);
        if (modif['cosWaveX'][0] != 0)
            xPos += cosWave(modif['cosWaveX'][0], modif['cosWaveX'][1], noteData);
        if (modif['cosWaveY'][0] != 0)
            yPos += cosWave(modif['cosWaveY'][0], modif['cosWaveY'][1], noteData);

        if (modif['sinMoveX'][0] != 0)
            xPos += sinMove(modif['sinMoveX'][0], modif['sinMoveX'][1]);
        if (modif['sinMoveY'][0] != 0)
            yPos += sinMove(modif['sinMoveY'][0], modif['sinMoveY'][1]);
        if (modif['cosMoveX'][0] != 0)
            xPos += cosMove(modif['cosMoveX'][0], modif['cosMoveX'][1]);
        if (modif['cosMoveY'][0] != 0)
            yPos += cosMove(modif['cosMoveY'][0], modif['cosMoveY'][1]);

        if (modif['swing'] != 0)
        {
            yPos += cosMove(modif['cosMoveY'][0], modif['cosMoveY'][1]);
        }

        if (modif['dislocated'] != 0)
        {
            yPos += (0 + 25 * Math.cos(modif['dislocated'] * noteData));
            xPos += (0 + 25 * Math.sin(modif['dislocated'] * noteData));
        }
        if (modif['chaos'] != 0)
        {
            yPos += (0 + (25*modif['chaos']) * Math.cos(PlayState.instance.currentBeat * (noteData + 1) *(25*modif['chaos'])));
            xPos += (0 + (25*modif['chaos']) * Math.sin(PlayState.instance.currentBeat * (noteData + 1) *(25*modif['chaos'])));
            ang += (0 + (25*modif['chaos']) * Math.sin(PlayState.instance.currentBeat * (noteData + 1) *(25*modif['chaos'])));
        }
        if (modif['spin'] != 0)
            ang += 0 + 180 * (PlayState.instance.currentBeat * modif['spin']);

        if (modif['press'] != 0)
        {
            xPos += strum.pressOffset.x;
            yPos += strum.pressOffset.y;
            ang += strum.pressOffset.angle;
            scaleX *= strum.pressOffset.scaleX;
            scaleY *= strum.pressOffset.scaleY;
            alpha *= strum.pressOffset.alpha;
        }
        if (modif['flip'] != 0)
            xPos += (arrowSize * 2 * (1.5 - noteData)) * modif['flip'];
        if (modif['invert'] != 0)
        {
            var invertShit = noteData % 2;
            if (invertShit == 0)
                invertShit = 1;
            else 
                invertShit = -1;
            xPos += (arrowSize * invertShit) * modif['invert'];
        }
        if (modif['drunk'] != 0)
            xPos += modif['drunk'] * Math.cos((Conductor.songPosition*0.001) + (noteData*(0.2)) + (1*0.2)) + (arrowSize*0.5);
        if (modif['tipsy'] != 0)
            yPos += modif['tipsy'] * Math.cos((Conductor.songPosition*0.001) * (1.2) + (noteData*(2.0)) + (1*(0.2))) + (arrowSize*0.4);

        if (modif['dark'] != 0 || strum.modifiers['dark'] != 0)
            alpha *= (1-modif['dark'])*(1-strum.modifiers['dark']);
        if (modif['confusion'] != 0 || strum.modifiers['confusion'] != 0)
            ang += modif['confusion'] + strum.modifiers['confusion'];
        //if (modifdizzy != 0)
            //ang += modifdizzy; //doesnt work well with my current setup

        if (modif['split'] != 0 || modif['cross'] != 0 || modif['alternate'] != 0 || modif['reverse'] != 0 || strum.modifiers['reverse'] != 0)
        {
            var amount = modif['reverse']+strum.modifiers['reverse'];
            if (modif['split'] != 0 && noteData+1 > keyAmmo/2)
                amount += modif['split'];
            if (modif['cross'] != 0 && noteData+1 > keyAmmo/4 && noteData < (keyAmmo/4)*3)
                amount += modif['cross'];
            if (modif['alternate'] != 0 && noteData % 2 == 1)
                amount += modif['alternate'];

            yPos += amount*450;
        }

        if (modif['pingPong'] != 0)
        {
            yPos += Math.min(-arrowSize * Math.sin(beat*Math.PI + noteData*Math.PI),0) * modif['pingPong'];
            var pingPong = beat - Math.floor(beat);
            if (beat % 2 > 1)
				pingPong = 1 - pingPong;

            var invertShit = noteData % 2;
            if (invertShit == 0)
                invertShit = 1;
            else 
                invertShit = -1;
            xPos += (arrowSize * invertShit) * (pingPong * 1.2) * modif['pingPong'];
        }

        if (modif['halo'] != 0)
        {
            var haloAng = 2*Math.PI*(noteData)/(keyAmmo) + ((beat)*0.5*Math.PI);
					
            xPos += modif['haloWidth'] * modif['halo'] * Math.sin(haloAng);
            yPos += modif['haloHeight'] * modif['halo'] * Math.cos(haloAng);
        }
            

        xPos += strum.bopOffset.x;
        yPos += strum.bopOffset.y;
        ang += strum.bopOffset.angle;
        scaleX *= strum.bopOffset.scaleX;
        scaleY *= strum.bopOffset.scaleY;
        alpha *= strum.bopOffset.alpha;

        /*if (modifclutter != 0)
        {
            xPos += ;
        }*/

            
        return [xPos,yPos,ang,scaleX,scaleY,alpha];
    }

    public static function sinWave(range:Float, speed:Float, noteData:Int)
        return 0 + range * Math.sin(PlayState.instance.currentBeat * speed * (noteData + 1));
    public static function cosWave(range:Float, speed:Float, noteData:Int)
        return 0 + range * Math.cos(PlayState.instance.currentBeat * speed * (noteData + 1));

    public static function sinMove(range:Float, speed:Float)
        return 0 + range * Math.sin(PlayState.instance.currentBeat * speed * Math.PI);
    public static function cosMove(range:Float, speed:Float)
        return 0 + range * Math.cos(PlayState.instance.currentBeat * speed * Math.PI);


    public static function noteModifierShit(daNote:Note, playernum:Int, strum:BabyArrow)
    {
        var modif = getModif(playernum);
        var modifValues = getModifValues(playernum);
        var playe = PlayState.getPlayerFromID(playernum);
        if (!playe.allowModifiers)
            return;

        if (modif['ghostNotes'] != 0)
        {
            if (daNote.curPos <= (Conductor.stepCrochet * modif['ghostNotes']) + modif['ghostOffset'])
                daNote.alpha = FlxMath.remapToRange(daNote.curPos, 0, (Conductor.stepCrochet * modif['ghostNotes']) + modif['ghostOffset'], 0, 1);
        }
        else if (modif['inverseGhostNotes'] != 0)
        {
            daNote.alpha = 0;
            if (daNote.curPos <= (Conductor.stepCrochet * modif['inverseGhostNotes']) + modif['ghostOffset'])
                daNote.alpha = FlxMath.remapToRange(daNote.curPos, 0, (Conductor.stepCrochet * modif['inverseGhostNotes']) + modif['ghostOffset'], 1, 0) * daNote.curAlpha;
        }


        if (modif['strumsFollowNotes'] != 0)
        {
            daNote.y = FlxMath.remapToRange(daNote.strumTime % (Conductor.stepCrochet * (32 * modif['strumsFollowNotes'])), 0, Conductor.stepCrochet * (32 * modif['strumsFollowNotes']), 0, FlxG.height * 2);
            if (daNote.y > FlxG.height)
                daNote.y = FlxMath.remapToRange(daNote.y, 0, FlxG.height, FlxG.height, 0) + FlxG.height;

            //daNote.y -= Note.noteWidths[daNote.curMania] / 2;

            if (daNote.strumTime >= Conductor.songPosition + (Conductor.stepCrochet * 12))
                daNote.alpha = 0.1 * daNote.curAlpha;
        }
        if (modif['stealth'] != 0 || strum.modifiers['stealth'] != 0)
            daNote.alpha *= (1-modif['dark'])*(1-strum.modifiers['stealth']);
    }

    public static function noteModifierShitBefore(daNote:Note, playernum:Int, strum:BabyArrow)
    {

        var modif = getModif(playernum);
        var modifValues = getModifValues(playernum);
        var playe = PlayState.getPlayerFromID(playernum);
        if (!playe.allowModifiers)
            return;

        if (modif['split'] != 0 || modif['cross'] != 0 || modif['alternate'] != 0 || modif['reverse'] != 0 || strum.modifiers['reverse'] != 0)
		{
            var amount = modif['reverse']+strum.modifiers['reverse'];
            if (modif['split'] != 0 && daNote.noteData+1 > (PlayState.keyAmmo[playe.curMania]/2))
                amount += modif['split'];
            if (modif['cross'] != 0 && daNote.noteData+1 > PlayState.keyAmmo[playe.curMania]/4 && daNote.noteData < (PlayState.keyAmmo[playe.curMania]/4)*3)
                amount += modif['cross'];
            if (modif['alternate'] != 0 && daNote.noteData % 2 == 1)
                amount += modif['alternate'];

            daNote.noteDistMulti = (1 - (amount * 2));
		}
        else
            daNote.noteDistMulti = 1;

        if (modif['incomingAngleIsStrumAngle'])
			daNote.curIncomingAngle = strum.angle - 90;

		if (modif['drugged'] != 0)
			daNote.curIncomingAngle = daNote.curIncomingAngle + 15 * Math.sin(PlayState.instance.currentBeat * modif['drugged']);
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