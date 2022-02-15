package;


import flixel.FlxSprite;
import flixel.util.FlxColor;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import flixel.graphics.FlxGraphic;
import openfl.utils.ByteArray;
import flixel.FlxG;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import openfl.net.URLRequest;
import openfl.net.URLStream;
import openfl.display.BitmapData;

import flixel.text.FlxText;
import flixel.ui.FlxBar;

using StringTools;


//please steal/improve this code for your own engines!!!!!!!!!!!!!!!!!
//i want more mods to use this shit

//uhh just credit if you use ig lol

typedef DownloadableObj = 
{
    var urlPath:String;
    var type:String;
    var name:String;
}

//quick explaination on how the downloaded stuff actually gets in game,
//so when it downloads something it gets saved to the cache map, specifically the path it would be in if it was actually in the game files,
//does this so when it checks if its in the cache based on file path, it'll see that theres something in cache in just go with it, doesnt check if its actually in game files lol


class DownloadingState extends MusicBeatState
{
    var stuffToDownload:Array<DownloadableObj> = [];
    var stream:URLStream;
    var currentPos = 0;
    var downloadListLength = 0;

    var downloadText:FlxText;
    var progressBar:FlxBar;

    public function new(downloadList:Array<DownloadableObj>)
    {
        stuffToDownload = downloadList;
        super();
    }

    override function create()
    {
        if (stuffToDownload != null && stuffToDownload.length > 0)
        {
            PlayState.didDownloadContent = true;
            downloadListLength = stuffToDownload.length;
            var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
            bg.setGraphicSize(Std.int(bg.width * 1.1));
            bg.updateHitbox();
            bg.screenCenter();
            bg.antialiasing = true;
            add(bg);
            progressBar = new FlxBar(0,0, LEFT_TO_RIGHT, FlxG.width, 50, this, "currentPos", 0, downloadListLength);
            progressBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
            add(progressBar);	
            downloadText = new FlxText(0, FlxG.height * 0.9, 0, 'Starting Download...', 32);
            downloadText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
            add(downloadText);
            startDownload();
        }
        else
        {
            //PlayState.didDownloadContent = false; //stuff will just stay in cache and will fuck up things
            onLoad(); //just skip if theres nothing to download
        }
            

    }

    override function beatHit()
    {
        super.beatHit();
        /*if (stuffToDownload.length > 0)
        {
            var dots:Int = curBeat % 4;
            var dotsString:String = "";
            for (i in 0...dots)
                dotsString += ".";
            downloadText.text = "Downloading " + stuffToDownload[currentPos].name + " " + stuffToDownload[currentPos].type + dotsString;
        }*/
    }

    function startDownload()
    {
        var doSkip = skipCheck();
        
        if (!doSkip)
        {
            var urlPath:String = stuffToDownload[currentPos].urlPath;
            var request:URLRequest = new URLRequest(urlPath);
            stream = new URLStream();
            stream.load(request);
            stream.addEventListener(Event.COMPLETE, onCompleteEvent);
            stream.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
            //stream.addEventListener(Event., onCompleteEvent);
            downloadText.text = "Downloading " + stuffToDownload[currentPos].name + " " + stuffToDownload[currentPos].type + "...";
        }
        else 
        {
            currentPos++;
            if (currentPos == downloadListLength)
                onLoad();
            else 
                startDownload();
        }

    }

    function onCompleteEvent(Event:Event)
    {
        switch (stuffToDownload[currentPos].type) //im so fucking happy that this works
        {
            case 'charJson': 
                var data = stream.readUTFBytes(stream.bytesAvailable);
                CacheShit.jsons[Paths.imageJson("characters/" + stuffToDownload[currentPos].name + "/offsets")] = data; //save to where it would be in game files so it can be found by the caching system first
                //trace(data);
            case 'charImage': 
                var bytes:ByteArray = new ByteArray();
                stream.readBytes(bytes, 0, stream.bytesAvailable);
                var bitmapData = BitmapData.fromBytes(bytes); //load bytes and shit

                var imagePath = "assets/images/characters/" + stuffToDownload[currentPos].name + "/image.png";
                var image:FlxGraphic = FlxGraphic.fromBitmapData(bitmapData);
                image.persist = true;
                CacheShit.images[imagePath] = image;
                //trace('got dat image');
            case 'charXml': 
                var data = stream.readUTFBytes(stream.bytesAvailable);
                var xmlPath = "assets/images/characters/" + stuffToDownload[currentPos].name + "/image.xml";
                CacheShit.xmls[xmlPath] = data;
            case 'icon': 
                var bytes:ByteArray = new ByteArray();
                stream.readBytes(bytes, 0, stream.bytesAvailable);
                var bitmapData = BitmapData.fromBytes(bytes);
                var imagePath = "assets/images/characters/" + stuffToDownload[currentPos].name + "/icon.png";
                var image:FlxGraphic = FlxGraphic.fromBitmapData(bitmapData);
                image.persist = true;
                CacheShit.images[imagePath] = image;
                //trace(data);

            case 'stageJson': 
                var data = stream.readUTFBytes(stream.bytesAvailable);
                CacheShit.jsons['assets/data/stages/' + stuffToDownload[currentPos].name + '.json'] = data; 
            case 'pieceJson': 
                var data = stream.readUTFBytes(stream.bytesAvailable);
                CacheShit.jsons[Paths.imageJson("customStagePieces/" + stuffToDownload[currentPos].name + "/data")] = data;
            case 'pieceImage': 
                var bytes:ByteArray = new ByteArray();
                stream.readBytes(bytes, 0, stream.bytesAvailable);
                var bitmapData = BitmapData.fromBytes(bytes);
                var imagePath = "assets/images/customStagePieces/" + stuffToDownload[currentPos].name + "/image.png";
                var image:FlxGraphic = FlxGraphic.fromBitmapData(bitmapData);
                image.persist = true;
                CacheShit.images[imagePath] = image;
            case 'pieceXml': 
                var data = stream.readUTFBytes(stream.bytesAvailable);
                var xmlPath = "assets/images/customStagePieces/" + stuffToDownload[currentPos].name + "/image.xml";
                CacheShit.xmls[xmlPath] = data;

            case 'modchart': 
                var data = stream.readUTFBytes(stream.bytesAvailable);
                CacheShit.modcharts["assets/data/charts/" + PlayState.SONG.song.toLowerCase() + "/script.hscript"] = data; //save to where it would be in game file so it can be found by the caching system first
        }
        stream.close();
        currentPos++;

        if (currentPos == downloadListLength)
            onLoad();
        else 
            startDownload();
    }

    function onSaveError(event:Event)
    {
        FlxG.switchState(new MainMenuState());
    }


    function onLoad()
    {        
        LoadingState.loadAndSwitchState(new PlayState(), false, true);
    }


    function skipCheck():Bool 
    {
        var path:String = "";
        switch (stuffToDownload[currentPos].type) //check if its already downloaded/exists in game files
        {
            case 'charJson': 
                path = Paths.imageJson("characters/" + stuffToDownload[currentPos].name + "/offsets");
                if (CacheShit.jsons[path] != null)
                    return true;
            case 'charImage': 
                path = "assets/images/characters/" + stuffToDownload[currentPos].name + "/image.png";
                if (CacheShit.images[path] != null)
                    return true;
            case 'charXml': 
                path = "assets/images/characters/" + stuffToDownload[currentPos].name + "/image.xml";
                if (CacheShit.xmls[path] != null)
                    return true;
            case 'icon': 
                path = "assets/images/characters/" + stuffToDownload[currentPos].name + "/icon.png";
                if (CacheShit.images[path] != null)
                    return true;
            case 'stageJson': 
                path = 'assets/data/stages/' + stuffToDownload[currentPos].name + '.json';
                if (CacheShit.jsons[path] != null)
                    return true;
            case 'pieceJson': 
                path = Paths.imageJson("customStagePieces/" + stuffToDownload[currentPos].name + "/data");
                if (CacheShit.jsons[path] != null)
                    return true;
            case 'pieceImage': 
                path = "assets/images/customStagePieces/" + stuffToDownload[currentPos].name + "/image.png";
                if (CacheShit.images[path] != null)
                    return true;
            case 'pieceXml': 
                path = "assets/images/customStagePieces/" + stuffToDownload[currentPos].name + "/image.xml";
                if (CacheShit.xmls[path] != null)
                    return true;
            case 'modchart': 
                path = "assets/data/charts/" + PlayState.SONG.song.toLowerCase() + "/script.hscript";
                if (CacheShit.modcharts[path] != null)
                    return true;
        }
        #if sys
        if (FileSystem.exists(path))
            return true;
        #end
        return false;
    }
}