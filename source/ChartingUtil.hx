package;

import Section.SwagSection;
import haxe.Json;
import Song.SwagSong;

import openfl.desktop.Clipboard;

using StringTools;

class ChartingUtil //using for ctrl c/z/v/z/y in chart editor, still a work in progress
{

    public static var UndoList:Array<Array<SwagSection>> = []; //saves the section arrays from charting state
    public static var RedoList:Array<Array<SwagSection>> = [];
    public static var copiedSections:Array<Array<SwagSection>> = [];
    public static var highlighedNotes:Array<Dynamic> = [];
    public static var copiedNotes:Array<Dynamic> = [];


    public static function SaveUndo(_song:SwagSong)
    {
        var shit = Json.stringify({ //doin this so it doesnt act as a reference
			"song": _song
		});
        var song:SwagSong = Song.parseJSONshit(shit);

        UndoList.unshift(song.notes);
        if (UndoList.length >= 100) //save no more than 100 times to reduce memory usage
            UndoList.remove(UndoList[100]);

        /*trace("saveUndo");
        for (i in 0...UndoList.length)
        {
            var noteTotal = 0;
            for (section in UndoList[i])
                noteTotal += section.sectionNotes.length;
            trace(noteTotal);
        }*/
        /*trace("undo list");
        for (i in 0...UndoList.length)
        {
            var noteTotal = 0;
            for (section in UndoList[i])
                noteTotal += section.sectionNotes.length;
            trace(i + ": " + noteTotal);
        }
        trace("redo list");
        for (i in 0...RedoList.length)
        {
            var noteTotal = 0;
            for (section in RedoList[i])
                noteTotal += section.sectionNotes.length;
            trace(i + ": " + noteTotal);
        }*/

        RedoList = []; //reset Redos
    }

    public static function Undo()
    {
        var sections:Array<SwagSection> = UndoList[0];
        RedoList.unshift(sections);
        UndoList.splice(0, 1);
        return sections;
    }
    public static function Redo()
    {
        var sections:Array<SwagSection> = RedoList[0];
        UndoList.unshift(sections);
        RedoList.splice(0, 1);
        return sections;
    }

    public static function resetUndos():Void
    {
        UndoList = [];
        RedoList = [];
    }

    public static function convertClipboardNotesToNoteArray(clippy:String) //why tf is string to array so annoying to do
    {
        var notes:Array<Dynamic> = [];
        var lines:Array<String> = clippy.split("],");//find only commas next to square brackets

        
        if (lines.length > 0)
        {
            for (line in lines)
            {
                var lineNoLeftBrac = StringTools.replace(line, "[", ""); //remove all square brackets
                var lineNoRightBrac = StringTools.replace(lineNoLeftBrac, "]", "");
                var data:Array<String> = lineNoRightBrac.split(",");
                //trace(data);
                if (data.length < 3)
                    return null;
    
                var strum = Std.parseFloat(data[0]);
                var ndata = Std.parseInt(data[1]);
                var sussy = Std.parseFloat(data[2]);
                var ntype = Std.parseInt(data[3]);
                var sec = Std.parseInt(data[4]);
                //var veldata = Std.parseFloat(data[0]); dont copy this cuz its an array, fucks with the parsing
                notes.push([strum,ndata,sussy,ntype,sec]);
            }
        }
        else 
            return null;


        return notes;
    }

}