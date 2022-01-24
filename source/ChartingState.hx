package;

import flixel.input.keyboard.FlxKeyboard;
import flixel.input.keyboard.FlxKey;
import flixel.addons.ui.FlxUIGroup;
import Note.CharterSustain;
import Conductor.BPMChangeEvent;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import flixel.addons.ui.FlxSlider;
import flixel.addons.effects.chainable.FlxOutlineEffect;

import lime.media.openal.AL;

import flash.media.Sound;

import flash.desktop.Clipboard;
import flash.desktop.ClipboardFormats;
import flash.desktop.ClipboardTransferMode;

using StringTools;
import ModchartUtil;

class ChartingState extends MusicBeatState
{
	var _file:FileReference;

	var UI_box:FlxUITabMenu;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	var curSection:Int = 0;

	public static var lastSection:Int = 0;

	var bpmTxt:FlxText;
	var tutorialTxt:FlxText;
	var songSlider:FlxSlider;

	var strumLine:FlxSprite;
	var curSong:String = 'Dadbattle';
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;

	public static var GRID_SIZE:Int = 40;
	public static var S_GRID_SIZE:Int = 40;
	public static var GF_GRID:Int = 160;

	var dummyArrow:FlxSprite;

	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedSustains:FlxTypedGroup<CharterSustain>;
	var curRenderedTypes:FlxTypedGroup<FlxText>; //old system i used for note types, i figred out how to make them show properly, so now this is just used for displaying an alt note
	var curRenderedSpeed:FlxTypedGroup<FlxText>; //for displaying the text of note speed, so you know its different

	var gridBG:FlxSprite; //might reduce the amount of these at some point
	var gridBGAbove:FlxSprite;
	var gridBGBelow:FlxSprite;
	var gridBlackLine:FlxSprite;
	var gridBlackLineLeft:FlxSprite;
	var gridBlackLineRight:FlxSprite;
	var gridBlackLineTop:FlxSprite;
	var gridBlackLineBottom:FlxSprite;
	var _song:SwagSong;

	var topSection:SwagSection;
	var middleSection:SwagSection;
	var bottomSection:SwagSection;

	var newGridSize:Int = 8;

	var typingShit:FlxInputText;
	var eventTypingShit:FlxInputText;
	var strumTimeTypingShit:FlxInputText;
	var velChangeTypingShit:FlxInputText;
	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic>;

	var curSectionText:FlxText;
	var nextSectionText:FlxText;

	var tempBpm:Float = 0;

	var vocals:FlxSound;
	var player2:Boyfriend;
	var player1:Boyfriend;
	var gf:Character;
	private var gfSpeed:Int = 1;
	private var GFsDir:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];

	public static var noteTypes:Array<String> = ['Normal', 'Fire', 'Death', 'Warning', 'Angel', 'Alt Anim', 'Bob', 'Glitch', 'Poison', 'Health Drain'];

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;
	var keyAmmo:Array<Int> = PlayState.keyAmmo;
	private var lastNote:Note;

	var selectedType:Int = 0;

	var curNoteSpeed:Float = 1;
	var curNoteVelocity:Float = 1;
	var curNoteVelocityTime:Float = 0;
	var curVelcityToggleShit:Bool = false;

	var curEventData:Array<String> = ["none", ""];
	var curEventInfo:String = "";
	var curStrumID:Int = 0;

	var leftHitsounds:Bool = false;
	var rightHitsounds:Bool = false;
	var showCharacters:Bool = true;

	var dadcharacter:String;
	var bfcharacter:String;

	var daBeat:Int = 0;
	var daStep:Int = 0;

	var characterList:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));

	var hitSound:FlxSound;

	var snaps:Array<Float> = [1, 2, 3/4, 4, 6, 8, 12, 16, 32, 64, 96, 128, 192];
	var curSnap:Int = 0;

	var statusText:FlxText;

	var tutorialText = 
	"(L Clk) Place/Delete a note.
	(Shift) unsnap from Grid,
	(TAB) change the current snap.\nHold Shift to go back a snap.
	(CTRL + L Clk) a note to select it.
	(Q/E) extend a note's sustain length
	(R Clk + Hold) pull the sustain\nlength of a note to your mouse.
	(W/S or Scroll) move the strumline.
	(<-/-> or A/D) Change Current Section.
	(Space) Pause/Play the Song.
	(Hold Z/X) Draw Tool, autoplaces\nnotes wherever your mouse is.\n(X deletes instead)";

	var page2Text = 
	"(Hold C + L Clk) Highlight a note
	(CTRL + Arr Keys) Move\nHighlighted Notes
	(CTRL + A) Highlight whole section
	(DELETE) Remove Highlighted Notes
	(CTRL + C) Copy highlighted notes\nto the clipboard. (yes they actually go\nto your clipboard, note that it\ndoesn't copy speed, velocity\nchanges or events)
	(CTRL + X) Same as copy but removes\nnotes upon copying.
	(CTRL + V) Paste notes from Clipboard.\n(pastes from top to bottom)
	(CTRL + Z) Undo
	(CTRL + Y) Redo (disabled temporaraly)
	(CTRL + S) Save Chart";

	var page3Text = 
	"(CAPS LOCK) Real Time Charting Mode,\nplace notes as the song plays
	Left Side:\nD,F,SPACE,J,K (4/5k)\nS,D,F,SPACE,H,J,K (6/7k)\nA,S,D,F,SPACE,H,J,K,L (8/9k)
	Right Side:\nE,R,B,U,I (4/5k)\nW,E,R,B,U,I,O (6/7k)\nQ,W,E,R,B,Y,U,I,O (8/9k)
	This Mode disables other Controls!!!!\nSnaps affect note placements!!!";

	var realTimeCharting:Bool = false;

	override function create()
	{

		ChartingUtil.resetUndos();

        var pieceArray = ['stageBG', 'stageFront', 'stageCurtains'];
        for (i in 0...pieceArray.length)
        {
            var piece:StagePiece = new StagePiece(-450, -100, pieceArray[i]);
            piece.x += piece.newx;
            piece.y += piece.newy;
            add(piece);
			piece.scrollFactor.set();
		}

		ColorPresets.resetColors();

		curSection = 0;

		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, (GRID_SIZE * 8) + GF_GRID, GRID_SIZE * 16);
		add(gridBG);
		gridBGAbove = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, (GRID_SIZE * 8) + GF_GRID, GRID_SIZE * 16);
		add(gridBGAbove);
		gridBGAbove.y -= gridBG.height;
		gridBGBelow = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, (GRID_SIZE * 8) + GF_GRID, GRID_SIZE * 16);
		add(gridBGBelow);
		gridBGBelow.y += gridBG.height;

		gridBlackLine = new FlxSprite(gridBG.x + GF_GRID + (gridBG.width - GF_GRID) / 2, gridBG.y - gridBG.height).makeGraphic(2, Std.int(gridBG.height * 3), FlxColor.BLACK);
		add(gridBlackLine);

		gridBlackLineLeft = new FlxSprite(gridBG.x + GF_GRID, gridBG.y - gridBG.height).makeGraphic(2, Std.int(gridBG.height * 3), FlxColor.BLACK);
		add(gridBlackLineLeft);

		gridBlackLineRight = new FlxSprite(gridBG.x + gridBG.width, gridBG.y - gridBG.height).makeGraphic(2, Std.int(gridBG.height * 3), FlxColor.BLACK);
		add(gridBlackLineRight);

		gridBlackLineTop = new FlxSprite(gridBG.x, gridBG.y).makeGraphic(Std.int((GRID_SIZE * newGridSize) + GF_GRID), 2, FlxColor.BLACK);
		add(gridBlackLineTop);

		gridBlackLineBottom = new FlxSprite(gridBG.x, gridBG.y + gridBG.height).makeGraphic(Std.int((GRID_SIZE * newGridSize) + GF_GRID), 2, FlxColor.BLACK);
		add(gridBlackLineBottom);

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<CharterSustain>();
		curRenderedTypes = new FlxTypedGroup<FlxText>();
		curRenderedSpeed = new FlxTypedGroup<FlxText>();


		if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else
		{
			_song = {
				song: 'Test',
				notes: [],
				bpm: 150,
				needsVoices: true,
				player1: 'bf',
				player2: 'dad',
				gfVersion: 'gf',
				stage: 'stage',
				speed: 1,
				mania: 0,
				validScore: false,
				showGFStrums: false
			};
		}
		dadcharacter = _song.player2;
		bfcharacter = _song.player1;

		if (!characterList.contains(dadcharacter)) //stop the fucking game from crashing when theres a character that doesnt exist
			dadcharacter = "dad";
		if (!characterList.contains(bfcharacter))
			bfcharacter = "bf";

		leftIcon = new HealthIcon(bfcharacter);
		rightIcon = new HealthIcon(dadcharacter);
		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);

		leftIcon.setGraphicSize(0, 45);
		rightIcon.setGraphicSize(0, 45);

		add(leftIcon);
		add(rightIcon);

		leftIcon.setPosition(gridBG.x - 75, 0);
		rightIcon.setPosition((gridBG.x) + gridBG.width, 0);

		player2 = new Boyfriend(0, 100, dadcharacter, false, false);
		player1 = new Boyfriend(770, 450, bfcharacter, false, true);
		player1.scrollFactor.set();
		player2.scrollFactor.set();
		player1.alpha = 0.4;
		player2.alpha = 0.4;

		gf = new Character(400, 130, "gf");
		gf.scrollFactor.set();
		gf.alpha = 0.3;

		add(gf);
		add(player2);
		add(player1);

		if (_song.notes[curSection - 1] != null)
			topSection = _song.notes[curSection - 1];
		else
			topSection = null;

		if (_song.notes[curSection] != null)
			middleSection = _song.notes[curSection];

		if (_song.notes[curSection + 1] != null)
			bottomSection = _song.notes[curSection + 1];
		else
			bottomSection = null;

		FlxG.mouse.visible = true;
		FlxG.save.bind('funkin', 'ninjamuffin99'); //wtf does this even do

		tempBpm = _song.bpm;

		addSection();

		updateGrid();

		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		bpmTxt = new FlxText(1000, 50, 0, "", 16);
		bpmTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		statusText = new FlxText(0, 0, 0, "Loaded Chart Editor", 40);
		statusText.setFormat(Paths.font("vcr.ttf"), 40, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		statusText.scrollFactor.set();
		add(statusText);

		tutorialTxt = new FlxText(980, 50, 10000, "", 8);
		tutorialTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		tutorialTxt.scrollFactor.set();
		add(tutorialTxt);
		//tutorialTxt.text = tutorialText;

		curSectionText = new FlxText(gridBG.x - 50, gridBG.y, 0, "", 16);
		curSectionText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		add(curSectionText);

		nextSectionText = new FlxText(gridBG.x - 50, gridBG.y + gridBG.height, 0, "", 16);
		nextSectionText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		add(nextSectionText);

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width / 1), 4);
		add(strumLine);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		var tabs = [
			{name: "Controls", label: 'Controls'},
			{name: "Song", label: 'Song'},
			{name: "Section", label: 'Section'},
			{name: "Note", label: 'Note'},
			{name: "Event", label: 'Event'},
			{name: "Editor", label: 'Editor'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = FlxG.width / 2 + 40;
		UI_box.y = 20;
		add(UI_box);
		

		tutorialTxt.y = UI_box.y + UI_box.height + 85;

		addSongUI();
		addSectionUI();
		addNoteUI();
		addEditorUI();
		addEventUI();
		addInfoUI();

		add(curRenderedNotes);
		add(curRenderedSustains);
		add(curRenderedTypes);
		add(curRenderedSpeed);

		songSlider = new FlxSlider(FlxG.sound.music, 'time', 1000, 15, 0, FlxG.sound.music.length, 250, 15, 5);
		songSlider.valueLabel.visible = false;
		songSlider.maxLabel.visible = false;
		songSlider.minLabel.visible = false;
		add(songSlider);
		songSlider.scrollFactor.set();
		songSlider.callback = function(fuck:Float)
		{
			vocals.time = FlxG.sound.music.time;
			var shit = Std.int(FlxG.sound.music.time / (Conductor.crochet * 4)); //TODO uhh make this work properly with bpm changes or somethin

			if (Conductor.bpmChangeMap.length > 0)
			{
				var foundSection:Bool = false;
				var sec:Int = 1;
				var lastSecStartTime:Float = 0;
				while(!foundSection)
				{	
					var secStartTime = sectionStartTime(sec);
					if (FlxG.sound.music.time >= lastSecStartTime && FlxG.sound.music.time <= secStartTime)
					{
						shit = sec;
						foundSection = true;
					}
					else if (secStartTime >= FlxG.sound.music.length)
					{
						shit = 0;
						foundSection = true;
					}
					sec++;
					lastSecStartTime = secStartTime;
				}
			}




			changeSection(shit);
		};

		super.create();
	}
	function addInfoUI():Void
	{

		var infoShit:FlxText = new FlxText(10, 10, 10000, "", 8);
		infoShit.setFormat(Paths.font("vcr.ttf"), 14, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		infoShit.text = tutorialText;

		var currentPage = 0;

		
		function getPage(page:Int):String 
		{
			switch (page)
			{
				case 0: 
					return tutorialText;
				case 1: 
					return page2Text;
				case 2: 
					return page3Text;
				default: 
					return tutorialText;
			}
		}

		var nextPage:FlxButton = new FlxButton(210, 350, "Next Page", function()
		{
			currentPage++;
			if (currentPage > 2)
				currentPage = 0;
			if (currentPage < 0)
				currentPage = 2;

			infoShit.text = getPage(currentPage);
		});

		var prevPage:FlxButton = new FlxButton(10, 350, "Previous Page", function()
		{
			currentPage--;
			if (currentPage > 2)
				currentPage = 0;
			if (currentPage < 0)
				currentPage = 2;

			infoShit.text = getPage(currentPage);
		});


		var tab_group_info = new FlxUI(null, UI_box);
		tab_group_info.name = "Controls";
		tab_group_info.add(infoShit);
		tab_group_info.add(nextPage);
		tab_group_info.add(prevPage);

		UI_box.addGroup(tab_group_info);
	}

	function addSongUI():Void
	{
		var UI_songTitle = new FlxUIInputText(10, 10, 70, _song.song, 8);
		typingShit = UI_songTitle;

		var check_voices = new FlxUICheckBox(10, 25, null, null, "Has voice track", 100);
		check_voices.checked = _song.needsVoices;
		// _song.needsVoices = check_voices.checked;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
			trace('CHECKED!');
		};

		var gf_strum = new FlxUICheckBox(10, 350, null, null, "Show GF strums", 100);
		gf_strum.checked = _song.showGFStrums;
		gf_strum.callback = function()
		{
			_song.showGFStrums = gf_strum.checked;
			trace('CHECKED!');
		};



		var saveButton:FlxButton = new FlxButton(110, 8, "Save", function()
		{
			saveLevel();
		});
		saveButton.onOver.callback = function()
		{
			tutorialTxt.text = "Save the Chart as a .json";
		}

		var compatSaveButton:FlxButton = new FlxButton(110, 38, "Compat Save", function()
		{
			saveLevel(true);
		});
		compatSaveButton.onOver.callback = function()
		{
			tutorialTxt.text = "Save the Chart as a .json\nWithout events, note types, speed\n and velocity changes.\nGood for transferring to other Engines.";
		}

		var luaSaveButton:FlxButton = new FlxButton(110, 68, "Lua Save", function()
		{
			saveLevel(true, true);
		});
		luaSaveButton.onOver.callback = function()
		{
			tutorialTxt.text = "Save the Chart as a .json\nWith Formatting to work with\nLua based Extra keys.";
		}

		var reloadSong:FlxButton = new FlxButton(saveButton.x + saveButton.width + 10, saveButton.y, "Reload Audio", function()
		{
			loadSong(_song.song);
		});
		reloadSong.onOver.callback = function()
		{
			tutorialTxt.text = "Reload song audio file";
		}

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 30, "Reload JSON", function()
		{
			loadJson(_song.song.toLowerCase());
		});
		reloadSongJson.onOver.callback = function()
		{
			tutorialTxt.text = "Reload chart json file";
		}

		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'load autosave', loadAutosave);
		loadAutosaveBtn.onOver.callback = function()
		{
			tutorialTxt.text = "Load autosaved chart\n(saves everytime you \nchange section)";
		}

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 80, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 65, 0.1, 1, 1.0, 5000.0, 1);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';

		var characters:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));
		var stages:Array<String> = CoolUtil.coolTextFile(Paths.txt('stageList'));

		var p1DropDown = new FlxUIDropDownMenu(10, 120, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player1 = characters[Std.parseInt(character)];
		});
		p1DropDown.selectedLabel = _song.player1;
		p1DropDown.name = "p1";
		var p1Label = new FlxText(10,100,64,'Player 1');

		var p2DropDown = new FlxUIDropDownMenu(10, 170, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player2 = characters[Std.parseInt(character)];
		});
		p2DropDown.selectedLabel = _song.player2;
		p2DropDown.name = "p2";
		var p2Label = new FlxText(10,150,64,'Player 2');

		var gfDropDown = new FlxUIDropDownMenu(10, 220, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(gfVersion:String)
		{
			_song.gfVersion = characters[Std.parseInt(gfVersion)];
		});
		gfDropDown.selectedLabel = _song.gfVersion;
		gfDropDown.name = "gf";
		var gfLabel = new FlxText(10,200,64,'Gf');

		var StageDropDown = new FlxUIDropDownMenu(10, 270, FlxUIDropDownMenu.makeStrIdLabelArray(stages, true), function(stage:String)
		{
			_song.stage = stages[Std.parseInt(stage)];
		});
		StageDropDown.selectedLabel = _song.stage;
		StageDropDown.name = "stages";
		var StageLabel = new FlxText(10,250,64,'Stages');


		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);

		tab_group_song.add(check_voices);

		tab_group_song.add(saveButton);
		tab_group_song.add(compatSaveButton);
		tab_group_song.add(luaSaveButton);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperSpeed);

		tab_group_song.add(StageLabel);
		tab_group_song.add(StageDropDown);
		tab_group_song.add(gfLabel);
		tab_group_song.add(gfDropDown);
		tab_group_song.add(p2Label);
		tab_group_song.add(p2DropDown);
		tab_group_song.add(p1Label);
		tab_group_song.add(p1DropDown);
		tab_group_song.add(gf_strum);



		
		UI_box.addGroup(tab_group_song);
		UI_box.scrollFactor.set();

		FlxG.camera.follow(strumLine);
	}
	var eventInfoLabel:FlxText;
	var eventDropDown:FlxUIDropDownMenu;

	function addEventUI()
	{
		var tab_group_event = new FlxUI(null, UI_box);
		tab_group_event.name = 'Event';

		var reminderLabel = new FlxText(10, 10, 200, "Reminder: Event notes only work in the gf Chart!", 10);
		eventInfoLabel = new FlxText(150, 170, 150, "Current Event Info:\n" + curEventInfo, 10);

		var eventList:Array<String> = [];
		for (i in 0...EventList.Events.length)
			eventList.push(EventList.Events[i][0]);

		eventDropDown = new FlxUIDropDownMenu(10, 100, FlxUIDropDownMenu.makeStrIdLabelArray(eventList, true), function(event:String)
		{
			curEventData[0] = eventList[Std.parseInt(event)];
			curEventInfo = EventList.Events[Std.parseInt(event)][1];
		});
		eventDropDown.selectedLabel = curEventData[0];
		eventDropDown.name = "events";

		var EventInputText = new FlxUIInputText(10, 150, 260, curEventData[1], 8);
		eventTypingShit = EventInputText;

		/*var presetsList:Array<String> = [];
		for (i in 0...EventList.noteMovementsPresets.length)
			presetsList.push(EventList.noteMovementsPresets[i][0]);
		var presetData:Array<String> = [];
		for (i in 0...EventList.noteMovementsPresets.length)
			presetData.push(EventList.noteMovementsPresets[i][1]);
		var PresetDropDown = new FlxUIDropDownMenu(10, 200, FlxUIDropDownMenu.makeStrIdLabelArray(presetsList, true), function(event:String)
		{
			eventTypingShit.text = presetData[Std.parseInt(event)];
		});
		PresetDropDown.name = "presets";*/

		var eventListLabel = new FlxText(10,80,64,'Event List', 8);
		//var presetListLabel = new FlxText(10,180,64,'Presets', 12);
		//tab_group_event.add(PresetDropDown);
		tab_group_event.add(eventListLabel);
		tab_group_event.add(EventInputText);
		//tab_group_event.add(presetListLabel);
		tab_group_event.add(eventDropDown);
		tab_group_event.add(eventInfoLabel);
		tab_group_event.add(reminderLabel);
		UI_box.addGroup(tab_group_event);
	}

	function addEditorUI()
	{
		var tab_group_editor = new FlxUI(null, UI_box);
		tab_group_editor.name = 'Editor';

		var check_mute_inst = new FlxUICheckBox(10, 200, null, null, "Mute Instrumental", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			FlxG.sound.music.volume = vol;
		};

		var check_mute_vocals = new FlxUICheckBox(120, 200, null, null, "Mute Vocals", 100);
		check_mute_vocals.checked = false;
		check_mute_vocals.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_vocals.checked)
				vol = 0;

			vocals.volume = vol;
		};


		var check_leftHitsounds = new FlxUICheckBox(10, 10, null, null, "Play Left Side Hitsounds", 100);
		check_leftHitsounds.checked = false;
		check_leftHitsounds.callback = function()
		{
			leftHitsounds = false;
			if (check_leftHitsounds.checked)
				leftHitsounds = true;
		};

		var check_rightHitsounds = new FlxUICheckBox(10, 30, null, null, "Play Right Side Hitsounds", 100);
		check_rightHitsounds.checked = false;
		check_rightHitsounds.callback = function()
		{
			rightHitsounds = false;
			if (check_rightHitsounds.checked)
				rightHitsounds = true;
		};

		var check_characters = new FlxUICheckBox(10, 60, null, null, "Show Characters", 100);
		check_characters.checked = true;
		check_characters.callback = function()
		{
			showCharacters = false;
			if (check_characters.checked)
				showCharacters = true;

			if (showCharacters)
			{
				player1.alpha = 0.4;
				player2.alpha = 0.4;
				gf.alpha = 0.3;
			}
			else
			{
				player1.alpha = 0;
				player2.alpha = 0;
				gf.alpha = 0;
			}
		};

		var noteCleanup:FlxButton = new FlxButton(10, 160, "Note Cleanup", function()
		{
			for(sec in _song.notes)
				{
					for (daNote in sec.sectionNotes)
					{
						for (stackedNote in sec.sectionNotes)
						{
							if (daNote != stackedNote) //so it cant delete itself
							{
								if (stackedNote[0] > daNote[0]) //only check strumtimes larger than the note
									if (((stackedNote[0] - daNote[0]) < 20) && daNote[1] == stackedNote[1])
									{
										sec.sectionNotes.remove(stackedNote);
										break;
									}
							}
							else
								break;
						}
						/*var index:Int = sec.sectionNotes.indexOf(daNote);
						if (index < sec.sectionNotes.length)
							if ((sec.sectionNotes[index + 1][0] - daNote[0] < 20) && daNote[1] == sec.sectionNotes[index + 1][1])
								sec.sectionNotes.remove(daNote);*/

					}
				}
			updateGrid();
		});
		noteCleanup.onOver.callback = function()
		{
			tutorialTxt.text = "Removes stacked notes from\nthe chart";
		}

		tab_group_editor.add(check_leftHitsounds);
		tab_group_editor.add(check_rightHitsounds);
		tab_group_editor.add(check_characters);
		tab_group_editor.add(check_mute_inst);
		tab_group_editor.add(check_mute_vocals);
		tab_group_editor.add(noteCleanup);


		UI_box.addGroup(tab_group_editor);
	}

	var stepperLength:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		stepperLength = new FlxUINumericStepper(10, 10, 4, 0, 0, 999, 0);
		stepperLength.value = middleSection.lengthInSteps;
		stepperLength.name = "section_length";

		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 130, 1, 1, -999, 999, 0);

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last section", function()
		{
			copySection(Std.int(stepperCopy.value));
		});
		copyButton.onOver.callback = function()
		{
			tutorialTxt.text = "Copies the notes from the\nsection that are however\nmany back";
		}

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear Section", clearSection);
		clearSectionButton.onOver.callback = function()
		{
			tutorialTxt.text = "Clears all notes from the\ncurrent section.";
		}

		var swapSection:FlxButton = new FlxButton(10, 170, "Swap section", function()
		{
			ChartingUtil.SaveUndo(_song); //in case something fucks up with swap section idk
			for (i in 0...middleSection.sectionNotes.length)
			{
				var note = middleSection.sectionNotes[i];
				var half = keyAmmo[_song.mania];
				var nT = Math.floor(note[1] / (half * 2));
				note[1] = (note[1] + half) % (half * 2) + nT * (half * 2);
				middleSection.sectionNotes[i] = note;
				updateGrid();
				updateStatus("Swapped Section");
			}
		});

		swapSection.onOver.callback = function()
		{
			tutorialTxt.text = "Swaps which side the notes are\non";
		}

		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Must hit section", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = true;
		// _song.needsVoices = check_mustHit.checked;

		check_altAnim = new FlxUICheckBox(10, 350, null, null, "Alt Animation Section", 100);
		check_altAnim.name = 'check_altAnim';

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 200);
		check_changeBPM.name = 'check_changeBPM';

		tab_group_section.add(stepperLength);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_altAnim);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(swapSection);

		UI_box.addGroup(tab_group_section);
	}

	var stepperSusLength:FlxUINumericStepper;

	var stepperNoteTypes:FlxUINumericStepper;

	var stepperStrumID:FlxUINumericStepper;

	var stepperNoteSpeed:FlxUINumericStepper;

	var stepperNoteVelocity:FlxUINumericStepper;
	var stepperNoteVelocityTime:FlxUINumericStepper;

	
	var typeChangeLabel:FlxText;
	var speedLabel:FlxText;

	var velocityLabel:FlxText;
	var velocityTimeLabel:FlxText;

	var check_velStrum:FlxUICheckBox;
	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		stepperSusLength = new FlxUINumericStepper(10, 10, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 16);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';

		stepperNoteTypes = new FlxUINumericStepper(100, 55, 1, selectedType, 0, noteTypes.length - 1, 0);
		stepperNoteTypes.value = selectedType;
		stepperNoteTypes.name = 'note_types';

		typeChangeLabel = new FlxText(100, 75, 64, noteTypes[selectedType] + " notes");

		stepperNoteSpeed = new FlxUINumericStepper(200, 55, 0.1, curNoteSpeed, 1, 10, 1);
		stepperNoteSpeed.value = curNoteSpeed;
		stepperNoteSpeed.name = 'note_speed';

		speedLabel = new FlxText(200, 75, 64, "Scroll Speed: " + curNoteSpeed);

		stepperNoteVelocity = new FlxUINumericStepper(200, 105, 0.1, curNoteVelocity, 0.1, 2, 1);
		stepperNoteVelocity.value = curNoteVelocity;
		stepperNoteVelocity.name = 'note_velocity';

		velocityLabel = new FlxText(200, 125, 64, "Velocity Speed Multi: " + curNoteVelocity + "x" + " (WIP)");

		velocityTimeLabel = new FlxText(10, 175, 100, "Velocity Change Time");

		var strumLabel = new FlxText(10, 120, 100, "Strumtime");


		var strumIDLabel = new FlxText(200, 230, 100, "Strum ID (for extra strums)");
		stepperStrumID = new FlxUINumericStepper(200, 250, 1, curStrumID, 0, 99, 0);
		stepperStrumID.value = curStrumID;
		stepperStrumID.name = 'strumID';

		var applyLength:FlxButton = new FlxButton(100, 10, 'Apply', function()
		{
			if (curSelectedNote != null)
			{
				curSelectedNote[0] = Std.parseFloat(strumTimeTypingShit.text);
				curSelectedNote[2] = stepperSusLength.value;
				curSelectedNote[3] = stepperNoteTypes.value;
				curSelectedNote[4] = stepperNoteSpeed.value;
				curSelectedNote[5] = [stepperNoteVelocity.value, Std.parseFloat(velChangeTypingShit.text), check_velStrum.checked];
				if (curSelectedNote[1] < 0)
					curSelectedNote[6] = [curEventData[0], curEventData[1]];
				else
					curSelectedNote[6] = null;
				curSelectedNote[7] = curStrumID;
			}
		});
		applyLength.onOver.callback = function()
		{
			tutorialTxt.text = "Applies the things in this menu\nto the currently selected note";
		}

		var ammolabel = new FlxText(10,35,100,'Amount of Keys');

		var stepperMania:FlxUINumericStepper = new FlxUINumericStepper(10, 50, 1, 4, 1, 9, 1);
		stepperMania.value = keyAmmo[_song.mania];
		stepperMania.name = 'mania';

		var strumTimeShit = new FlxUIInputText(10, 140, 150, "", 8);
		strumTimeShit.filterMode = 3;
		strumTimeTypingShit = strumTimeShit;
		strumTimeShit.name = "StrumTime";

		var velChangeShit = new FlxUIInputText(10, 200, 150, "", 8);
		velChangeShit.filterMode = 3;
		velChangeTypingShit = velChangeShit;
		velChangeShit.name = "changeTime";

		check_velStrum = new FlxUICheckBox(10, 230, null, null, "Use Specific Strumtime for Velocity Change", 200);
		check_velStrum.name = 'check_velStrum';
		check_velStrum.callback = function()
		{
			curVelcityToggleShit = check_velStrum.checked;
		}

		var typelabel = new FlxText(100,35,64,'Note Types');
		
		tab_group_note.add(stepperSusLength);
		tab_group_note.add(applyLength);
		//tab_group_note.add(resetValues);
		tab_group_note.add(ammolabel);
		tab_group_note.add(stepperNoteTypes);
		tab_group_note.add(typeChangeLabel);
		tab_group_note.add(typelabel);
		tab_group_note.add(stepperMania);
		tab_group_note.add(speedLabel);
		tab_group_note.add(stepperNoteSpeed);
		tab_group_note.add(strumLabel);

		tab_group_note.add(strumTimeShit);
		tab_group_note.add(velChangeShit);
		tab_group_note.add(check_velStrum);

		tab_group_note.add(velocityLabel);

		tab_group_note.add(stepperNoteVelocity);
		tab_group_note.add(velocityTimeLabel);

		tab_group_note.add(strumIDLabel);
		tab_group_note.add(stepperStrumID);

		UI_box.addGroup(tab_group_note);
	}

	function loadSong(daSong:String):Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
			// vocals.stop();
		}

		FlxG.sound.playMusic(Sound.fromFile(Paths.inst(daSong)), 0.6);

		// WONT WORK FOR TUTORIAL OR TEST SONG!!! REDO LATER
		vocals = new FlxSound().loadEmbedded(Sound.fromFile(Paths.voices(daSong)));
		FlxG.sound.list.add(vocals);

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.onComplete = function()
		{
			vocals.pause();
			vocals.time = 0;
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			songSlider.maxValue = FlxG.sound.music.length;
			changeSection();
		};
	}

	function generateUI():Void
	{
		while (bullshitUI.members.length > 0)
		{
			bullshitUI.remove(bullshitUI.members[0], true);
		}

		// general shit
		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		bullshitUI.add(title);
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Must hit section':
					middleSection.mustHitSection = check.checked;
					updateHeads();

				case 'Change BPM':
					middleSection.changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
				case "Alt Animation":
					middleSection.altAnim = check.checked;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			if (wname == 'section_length')
			{
				if (nums.value <= 4)
					nums.value = 4;
				middleSection.lengthInSteps = Std.int(nums.value);
				updateGrid();
			}
			else if (wname == 'song_speed')
			{
				if (nums.value <= 0)
					nums.value = 0;
				_song.speed = nums.value;
			}
			else if (wname == 'song_bpm')
			{
				if (nums.value <= 0)
					nums.value = 1;
				tempBpm = Std.int(nums.value);
				Conductor.mapBPMChanges(_song);
				Conductor.changeBPM(Std.int(nums.value));
			}
			else if (wname == 'mania')
			{
				_song.mania = Note.ammoToMania[Std.int(nums.value)];
				updateGrid();
			}
			else if (wname == 'note_susLength')
			{
				if (curSelectedNote == null)
					return;

				if (nums.value <= 0)
					nums.value = 0;
				curSelectedNote[2] = nums.value;
				updateGrid();
			}
			else if (wname == 'section_bpm')
			{
				if (nums.value <= 0.1)
					nums.value = 0.1;
				middleSection.bpm = Std.int(nums.value);
				updateGrid();
			}
			else if (wname == 'note_type')
				{
					selectedType = Std.int(nums.value);
				}
		}
	}

	var updatedSection:Bool = false;

	function stepStartTime(step):Float
	{
		return _song.bpm / (step / 4) / 60;
	}
	function sectionStartTime(section:Int):Float
	{
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...section)
		{
			if (_song.notes[i] != null)
			{
				if (_song.notes[i].changeBPM)
				{
					if (_song.notes[i].bpm > 0) //no bad bad divide by 0
						daBPM = _song.notes[i].bpm;
				}
			}

			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	function getTimeOfSection(section:Int):Float
	{
		var start = sectionStartTime(section);
		var end = sectionStartTime(section + 1);
		return end - start;
	}

	override function update(elapsed:Float)
	{
		typeChangeLabel.text = noteTypes[Std.int(stepperNoteTypes.value)] + ' notes';
		speedLabel.text = "Speed: " + stepperNoteSpeed.value;
		velocityLabel.text = "Velocity: " + stepperNoteVelocity.value + "x";
		curStep = recalculateSteps();

		dadcharacter = _song.player2;
		bfcharacter = _song.player1;

		if (!characterList.contains(dadcharacter)) //stop the fucking game from crashing when theres a character that doesnt exist
			dadcharacter = "dad";
		if (!characterList.contains(bfcharacter))
			bfcharacter = "bf";

		if (_song.notes[curSection - 1] != null) //null checks to prevent crashes
			topSection = _song.notes[curSection - 1];
		else
			topSection = null;

		if (_song.notes[curSection] != null)
			middleSection = _song.notes[curSection];

		if (_song.notes[curSection + 1] != null)
			bottomSection = _song.notes[curSection + 1];
		else
			bottomSection = null;

		newGridSize = keyAmmo[_song.mania] * 2;
		if (gridBG.width != (GRID_SIZE * newGridSize) + GF_GRID)
		{
			updateStatus("Updated Grid Size");
			remove(gridBG);
			gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, (GRID_SIZE * newGridSize) + GF_GRID, GRID_SIZE * 16);
			add(gridBG);
			remove(gridBGAbove);
			gridBGAbove = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, (GRID_SIZE * newGridSize) + GF_GRID, GRID_SIZE * 16);
			add(gridBGAbove);
			remove(gridBGBelow);
			gridBGBelow = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, (GRID_SIZE * newGridSize) + GF_GRID, GRID_SIZE * 16);
			add(gridBGBelow);
			remove(gridBlackLineTop);
			gridBlackLineTop = new FlxSprite(gridBG.x, gridBG.y).makeGraphic(Std.int((GRID_SIZE * newGridSize) + GF_GRID), 2, FlxColor.BLACK);
			add(gridBlackLineTop);
			remove(gridBlackLineBottom);
			gridBlackLineBottom = new FlxSprite(gridBG.x, gridBG.y + gridBG.height).makeGraphic(Std.int((GRID_SIZE * newGridSize) + GF_GRID), 2, FlxColor.BLACK);
			add(gridBlackLineBottom);
		}

		gridBlackLine.x = gridBG.x + GF_GRID + (gridBG.width - GF_GRID) / 2;
		gridBlackLineLeft.x = gridBG.x + GF_GRID;
		gridBlackLineRight.x = gridBG.x + gridBG.width;
		gridBlackLineTop.y = gridBG.y;
		gridBlackLineBottom.y = gridBG.y + gridBG.height;

		curSectionText.text = Std.string(curSection);
		nextSectionText.text = Std.string(curSection + 1);
		curSectionText.x = gridBG.x - 50;
		nextSectionText.x = gridBG.x - 50;
		curSectionText.y = gridBlackLineTop.y;
		nextSectionText.y = gridBlackLineBottom.y;

		leftIcon.setPosition(gridBG.x - 75, gridBlackLineTop.y);
		rightIcon.setPosition((gridBG.x + 50) + gridBG.width, gridBlackLineTop.y);
		UI_box.x = bpmTxt.x - 20;
		UI_box.y = 100;

		gridBGAbove.y = gridBG.y - gridBG.height;
		gridBGBelow.y = gridBG.y + gridBG.height;


		Conductor.songPosition = FlxG.sound.music.time;
		_song.song = typingShit.text;
		curEventData[1] = eventTypingShit.text;
		if (curSelectedNote != null)
		{
			curSelectedNote[0] = Std.parseFloat(strumTimeTypingShit.text);
		}
		curNoteVelocityTime = Std.parseFloat(velChangeTypingShit.text);
		eventInfoLabel.text = "Current Event Info:\n" + curEventInfo;

		if (statusText.alpha > 0.13)
			statusText.alpha = FlxMath.roundDecimal(FlxMath.lerp(statusText.alpha, 0, 0.05), 2);
		else 
			statusText.alpha = 0;

		curRenderedNotes.forEach(function(note:Note)
		{
			if (note.strumTime <= Conductor.songPosition)
			{
				if (note.alpha != 0.5)
				{
					if (note.badNoteType)
						note.playedSound = true;

					if (!note.playedSound)
					{
						note.playedSound = true;
						if (note.rawNoteData < 4)
						{
							gf.playAnim('sing' + GFsDir[note.noteData], true);
							gf.holdTimer = 0;	
						}
						else if (!note.mustPress)
						{
							player2.playAnim('sing' + PlayState.sDir[_song.mania][note.noteData], true);
							player2.holdTimer = 0;
						}
						else if (note.mustPress)
						{
							player1.playAnim('sing' + PlayState.sDir[_song.mania][note.noteData], true);
							player1.holdTimer = 0;
						}


						if (note.rawNoteData < 4)
							trace("do nothing lol");
						if (((note.rawNoteData - 4) < keyAmmo[_song.mania]) && leftHitsounds)
							FlxG.sound.play(Paths.sound('ANGRY'));
						else if (((note.rawNoteData - 4) >= keyAmmo[_song.mania]) && rightHitsounds)
							FlxG.sound.play(Paths.sound('ANGRY'));
					}
					note.alpha = 0.5;
				}
			}
			else
			{
				note.alpha = 1;
				note.playedSound = false;
			}
		});
		curRenderedSustains.forEach(function(sus:CharterSustain)
		{
			var overlap = FlxG.overlap(strumLine, sus);
			if (overlap)
			{
				if ((sus.x < gridBlackLine.x && !middleSection.mustHitSection) || sus.x > gridBlackLine.x && middleSection.mustHitSection)
					player2.holdTimer = 0;
				else
					player1.holdTimer = 0;
			}
		});


		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime(curSection)) % (Conductor.stepCrochet * middleSection.lengthInSteps));

	 	strumLine.x = -80;

		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1))
		{
			if (_song.notes[curSection + 1] == null || _song.notes[curSection + 2] == null  || _song.notes[curSection + 3] == null)
			{
				addSection();
			}

			changeSection(curSection + 1, false);
		}

		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		var isDaMouseInGrid:Bool = FlxG.mouse.x > gridBG.x
		&& FlxG.mouse.x < gridBG.x + gridBG.width
		&& FlxG.mouse.y > gridBGAbove.y
		&& FlxG.mouse.y < gridBGAbove.y + (GRID_SIZE * middleSection.lengthInSteps * 3);

		var whichSectionYouIn:SwagSection = middleSection;
		if (FlxG.mouse.y > gridBG.y && FlxG.mouse.y < gridBG.y + (GRID_SIZE * middleSection.lengthInSteps))
			whichSectionYouIn = middleSection;
		else if (FlxG.mouse.y > gridBGAbove.y && FlxG.mouse.y < gridBGAbove.y + (GRID_SIZE * 16))
		{
			if (topSection != null)
				whichSectionYouIn = topSection;
		}
		else if (FlxG.mouse.y > gridBGBelow.y && FlxG.mouse.y < gridBGBelow.y + (GRID_SIZE * 16))
		{
			if (bottomSection != null)
				whichSectionYouIn = bottomSection;
		}
		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEach(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note))
					{
						if (FlxG.keys.pressed.CONTROL)
						{
							selectNote(note, whichSectionYouIn);
						}
						else if (FlxG.keys.pressed.C)
						{
							note.highlighted = true;
							highlightNote(note);
						}
						else
						{
							//('tryin to delete note...');
							ChartingUtil.SaveUndo(_song);
							deleteNote(note, whichSectionYouIn);
						}
					}
				});
			}
			else
			{
				if (isDaMouseInGrid)
				{
					if (!FlxG.keys.pressed.CONTROL && !FlxG.keys.pressed.C) //stop crashing
					{
						ChartingUtil.SaveUndo(_song); //save here so you can undo notes drawn with draw tool like how you would in a normal program
						addNote(whichSectionYouIn);
					}
						
				}
			}
		}
		if (FlxG.mouse.justPressedRight)
		{
			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEach(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note))
					{
						note.beingGrabbed = true;
						updateStatus("Grabbed note sustain");
						ChartingUtil.SaveUndo(_song);
					};
				});
			}
			else if (dummyArrow.overlaps(curRenderedSustains))
			{
				curRenderedSustains.forEach(function(sus:CharterSustain)
				{
					if (dummyArrow.overlaps(sus))
					{
						sus.note.beingGrabbed = true;
						updateStatus("Grabbed note sustain");
						ChartingUtil.SaveUndo(_song);
					};
				});
			}
		}
		if (FlxG.mouse.pressedRight)
		{
			curRenderedNotes.forEach(function(note:Note)
			{
				if (note.beingGrabbed)
				{
					var dummyStrum = getStrumTime(dummyArrow.y) + sectionStartTime(curSection);
					var stepsDown = dummyStrum - note.strumTime;
					if (dummyStrum > note.strumTime) //only do if dummyarrow is below note
					{
						for(sec in _song.notes)
						{
							for (daNote in sec.sectionNotes)
							{
								if (daNote[0] == note.strumTime && daNote[1] == (note.rawNoteData - 4))
								{
									daNote[2] = Conductor.stepCrochet * Std.int(stepsDown / Conductor.stepCrochet);
									updateStatus("Changed note sustain length");
									//trace('updating sustain in note array shijtt');
								}	
							}
						}
					}
					else
					{
						for(sec in _song.notes)
						{
							for (daNote in sec.sectionNotes)
							{
								if (daNote[0] == note.strumTime && daNote[1] == (note.rawNoteData - 4))
								{
									daNote[2] = 0; // reset it
								}									
							}
						}
					}
					updateNoteUI();
					updateGrid();
				}
			});
		}
		if (FlxG.mouse.justReleasedRight)
		{
			curRenderedNotes.forEach(function(note:Note)
			{
				if (note.beingGrabbed)
				{
					note.kill();
					curRenderedNotes.remove(note);
					note.destroy();

					updateNoteUI();
					updateGrid();
				}
				note.beingGrabbed = false;
			});
		}


			
		if (FlxG.keys.pressed.C)
			if (FlxG.sound.music.playing) //something i might try at some point, i forgot what this was
				{
					if (curStep != daStep)
					{
						daStep = curStep;
						
					}
				}
					

		if (curBeat != daBeat) //shitty version of beatHit() (because it didnt wanna work properly lol)
		{
			daBeat = curBeat;
			if (curBeat % gfSpeed == 0)
				gf.dance();
			if (!player1.animation.curAnim.name.startsWith("sing"))
				player1.dance();
			if (!player2.animation.curAnim.name.startsWith("sing"))
				player2.dance();
		}
		if (FlxG.keys.justPressed.TAB)
		{
			if (FlxG.keys.pressed.SHIFT)
				curSnap--;
			else
				curSnap++;

			updateStatus("Changed Snap");

			if (curSnap < 0)
				curSnap = snaps.length - 1;
			if (curSnap >= snaps.length - 1)
				curSnap = 0;
		}
		
		if (isDaMouseInGrid)
		{
			var arX = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			dummyArrow.x = arX;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / (GRID_SIZE / snaps[curSnap])) * (GRID_SIZE / snaps[curSnap]);
		}

		if (FlxG.keys.justPressed.ENTER)
		{
			updateStatus("Exiting...");
			autosaveSong();
			lastSection = curSection;

			PlayState.SONG = _song;
			FlxG.sound.music.stop();
			vocals.stop();
			Main.editor = false;
			FlxG.switchState(new PlayState());
		}


		var shiftThing:Int = 1;
		if (FlxG.keys.pressed.SHIFT)
			shiftThing = 4;

		if (!typingShit.hasFocus && !eventTypingShit.hasFocus) //so you cant do shit on accident when typing
		{
			if (FlxG.keys.justPressed.CAPSLOCK)
			{
				realTimeCharting = !realTimeCharting;
				updateStatus("Toggled real time charting");
			}
				

			if (!realTimeCharting)
			{
				if ((FlxG.keys.justPressed.X || FlxG.keys.justPressed.Z) && !FlxG.keys.pressed.CONTROL)
					ChartingUtil.SaveUndo(_song); //save just before drawing
	
				if (FlxG.keys.pressed.Z && !FlxG.keys.pressed.CONTROL)
					if (!FlxG.mouse.overlaps(curRenderedNotes))
						if (isDaMouseInGrid)
							if (!FlxG.keys.pressed.CONTROL) //stop crashing
								addNote(whichSectionYouIn); //allows you to draw notes by holding left click
		
				if (FlxG.keys.pressed.X && !FlxG.keys.pressed.CONTROL)
					if (FlxG.mouse.overlaps(curRenderedNotes))
						if (isDaMouseInGrid)
							curRenderedNotes.forEach(function(note:Note)
							{
								if (FlxG.mouse.overlaps(note))
									deleteNote(note, whichSectionYouIn); //mass deletion of notes
							});
	
				if (FlxG.keys.pressed.CONTROL)
				{
					if (FlxG.keys.justPressed.Z)
						undo();
					else if (FlxG.keys.justPressed.X)
						cutNotes();
					else if (FlxG.keys.justPressed.C)
						copyNotes();
					else if (FlxG.keys.justPressed.V)
						pasteNotes();
					else if (FlxG.keys.justPressed.A)
						highlightNotesInSection();
					else if (FlxG.keys.justPressed.S)
						saveLevel();
					/*else if (FlxG.keys.justPressed.Y)
						redo();*/ //disabled rn cuz it keeps forgetting the first undo
					else if (FlxG.keys.justPressed.LEFT)
						adjustNoteDatas(-1);
					else if (FlxG.keys.justPressed.RIGHT)
						adjustNoteDatas(1);
					else if (FlxG.keys.justPressed.UP)
						adjustNoteStep(-1);
					else if (FlxG.keys.justPressed.DOWN)
						adjustNoteStep(1);
				}
				else 
				{
					if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D && !FlxG.keys.pressed.CONTROL)
						changeSection(curSection + shiftThing);
					if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A && !FlxG.keys.pressed.CONTROL)
						changeSection(curSection - shiftThing);
				}
	
	
	
	
				if (FlxG.keys.justPressed.DELETE) //delete highlighted notes
					deleteHighlightedNotes();
	
	
	
				if (FlxG.keys.justPressed.E)
				{
					changeNoteSustain(Conductor.stepCrochet);
				}
				if (FlxG.keys.justPressed.Q)
				{
					changeNoteSustain(-Conductor.stepCrochet);
				}
				if (FlxG.keys.justPressed.SPACE)
				{
					if (FlxG.sound.music.playing)
					{
						FlxG.sound.music.pause();
						vocals.pause();
					}
					else
					{
						vocals.play();
						FlxG.sound.music.play();
					}
				}
	
				if (FlxG.keys.justPressed.R)
				{
					if (FlxG.keys.pressed.SHIFT)
						resetSection(true);
					else
						resetSection();
				}
	
				if (FlxG.mouse.wheel != 0)
				{
					FlxG.sound.music.pause();
					vocals.pause();
	
					FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
					vocals.time = FlxG.sound.music.time;
				}
				if (FlxG.keys.justPressed.BACKSPACE) //changed to backspace so people used to psych dont accientially leave the chart editor
				{
					autosaveSong();
					FlxG.switchState(new DebugState());
				}
					
	
				if (!FlxG.keys.pressed.SHIFT)
				{
					if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
					{
						FlxG.sound.music.pause();
						vocals.pause();
	
						var daTime:Float = 700 * FlxG.elapsed;
	
						if (FlxG.keys.pressed.W)
						{
							FlxG.sound.music.time -= daTime;
						}
						else
							FlxG.sound.music.time += daTime;
	
						vocals.time = FlxG.sound.music.time;
					}
				}
				else
				{
					if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S)
					{
						FlxG.sound.music.pause();
						vocals.pause();
	
						var daTime:Float = Conductor.stepCrochet * 2;
	
						if (FlxG.keys.justPressed.W)
						{
							FlxG.sound.music.time -= daTime;
						}
						else
							FlxG.sound.music.time += daTime;
	
						vocals.time = FlxG.sound.music.time;
					}
				}
			}
			else 
			{
				if (FlxG.keys.justPressed.ANY)
				{
					var controlsList = [
						["D", "F", "J", "K", "E", "R", "U", "I"],
						["S", "D", "F", "J", "K", "L", "W", "E", "R", "Y", "U", "I"],
						["A", "S", "D", "F", "SPACE", "H", "J", "K", "L", "Q", "W", "E", "R", "B", "Y", "U", "I", "O"],
						["D", "F", "SPACE", "J", "K", "E", "R", "B", "U", "I"],
						["S", "D", "F", "SPACE", "J", "K", "L", "W", "E", "R", "B", "Y", "U", "I"],
						["A", "S", "D", "F", "H", "J", "K", "L", "Q", "W", "E", "R", "Y", "U", "I", "O"],
						["SPACE", "B",],
						["D","K", "E", "I"],
						["D","SPACE","K", "E", "B","I"]
					];

					var controls = controlsList[_song.mania];

					for (i in 0...controls.length)
					{
						var data = -1;
						var input = FlxKey.fromString(controls[i]);
						if (FlxG.keys.checkStatus(input, JUST_PRESSED))
						{
							data = i;
							if (data != -1 && !FlxG.keys.pressed.CONTROL)
							{
								addNoteFromKey(data);
							}
						}
					}



					
				}
			}

			
		}

		labelsCheck();
		

		_song.bpm = tempBpm;
		var tempStep:String = Std.string(curStep);

		var tempsnap = Std.string(snaps[curSnap]);

		bpmTxt.text = bpmTxt.text = Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2))
			+ "\nSection: "
			+ curSection
			+ "   CurStep: "
			+ tempStep
			+ "\nCurrent Snap: "
			+ tempsnap
			+ "\n fuck you";
		super.update(elapsed);
	}

	function highlightNote(note:Note)
	{	
		var highlightedNote:Array<Dynamic> = [note.strumTime, note.rawNoteData - 4, note.sustainLength, note.noteType, note.section]; //save section it came from to fix strumtime/section to go in issues
		ChartingUtil.highlighedNotes.push(highlightedNote);
		highlightCheck();
		updateStatus("Highlighted note");
		//trace(ChartingUtil.highlighedNotes);
	}
	function highlightNotesInSection():Void
	{
		curRenderedNotes.forEach(function(note:Note)
		{
			if (note.section == curSection)
			{
				var highlightedNote:Array<Dynamic> = [note.strumTime, note.rawNoteData - 4, note.sustainLength, note.noteType, note.section]; //save section it came from to fix strumtime/section to go in issues
				ChartingUtil.highlighedNotes.push(highlightedNote);
			}
		});
		updateStatus("Highlighted all notes in this section");
		highlightCheck();
	}
	function highlightHalfOfSection(left:Bool):Void
		{
			curRenderedNotes.forEach(function(note:Note)
			{
				var sideToCheck = note.noteData >= PlayState.keyAmmo[_song.mania];
				if (left)
					sideToCheck = note.noteData < PlayState.keyAmmo[_song.mania];

				if (note.section == curSection && sideToCheck)
				{
					var highlightedNote:Array<Dynamic> = [note.strumTime, note.rawNoteData - 4, note.sustainLength, note.noteType, note.section]; //save section it came from to fix strumtime/section to go in issues
					ChartingUtil.highlighedNotes.push(highlightedNote);
				}
			});
			updateStatus("Highlighted all notes on the " + (left ? "left" : "right"));
			highlightCheck();
		}
	function highlightCheck():Void
	{
		for (note in ChartingUtil.highlighedNotes)
		{
			for (note2 in ChartingUtil.highlighedNotes)
			{
				if (note != note2)
					if (note[0] == note2[0] && note[1] == note2[1])
						ChartingUtil.highlighedNotes.remove(note2); //prevent duplicates (also remove stacked notes i guess)
			}
			var noteStillExists:Bool = false;
			for(sec in _song.notes)
			{
				for (daNote in sec.sectionNotes)
				{
					if (daNote[0] == note[0] && daNote[1] == note[1])
					{
						noteStillExists = true;
					}	
				}
			}
			if (!noteStillExists) //if you remove a note thats been highlighted
				ChartingUtil.highlighedNotes.remove(note);

			curRenderedNotes.forEach(function(note2:Note)
			{
				if (note[0] == note2.strumTime && note[1] == (note2.rawNoteData - 4))
				{
					note2.highlighted = true;
				}	
			});
		}
	}
	function deleteHighlightedNotes():Void 
	{
		if (ChartingUtil.highlighedNotes.length > 0)
		{
			ChartingUtil.SaveUndo(_song);
			for (note in ChartingUtil.highlighedNotes)
			{
				for(sec in _song.notes)
				{
					for (daNote in sec.sectionNotes)
					{
						if (daNote[0] == note[0] && daNote[1] == note[1])
						{
							sec.sectionNotes.remove(daNote);
						}	
					}
				}
			}
			ChartingUtil.highlighedNotes = [];
			updateStatus("Deleted all highlighted notes");
			updateGrid();
		}
		else
			updateStatus("Nothing to delete");
	}
	function copyNotes():Void
	{
		if (ChartingUtil.highlighedNotes.length > 0)
		{
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, ChartingUtil.highlighedNotes);
			updateStatus("Copied notes to clipboard");
		}
		else 
			updateStatus("Nothing to copy");
	}
	function cutNotes():Void 
	{
		if (ChartingUtil.highlighedNotes.length > 0)
		{
			ChartingUtil.SaveUndo(_song);
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, ChartingUtil.highlighedNotes);
			for (note in ChartingUtil.highlighedNotes)
			{
				for(sec in _song.notes)
				{
					for (daNote in sec.sectionNotes)
					{
						if (daNote[0] == note[0] && daNote[1] == note[1])
						{
							sec.sectionNotes.remove(daNote);
						}	
					}
				}
			}
			updateStatus("Cut notes and copied to clipboard");
			ChartingUtil.highlighedNotes = [];
			updateGrid();
		}
		updateStatus("Nothing to cut");
	}
	function pasteNotes():Void 
	{
		ChartingUtil.highlighedNotes = [];

		ChartingUtil.SaveUndo(_song);
		var clippy = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT);
		//trace(clippy);

		var notes:Array<Dynamic> = null;
		if (clippy != null)
			notes = ChartingUtil.convertClipboardNotesToNoteArray(clippy);

		if (notes == null)
		{
			updateStatus("Error pasting notes");
			return;
		}
		var smallestsec = -1;
		for (note in notes) //get smallest section first
		{
			var sec = note[4];
			if (smallestsec == -1)
				smallestsec = sec;

			if (sec < smallestsec)
				smallestsec = sec;
			
		}

		for (note in notes)
		{
			var sectionNoteCameFrom = note[4];
			var sectionToAddTo = curSection - (smallestsec - sectionNoteCameFrom);
			var daSec = FlxMath.maxInt(sectionToAddTo, sectionNoteCameFrom);

			var strum = note[0] - sectionStartTime(sectionNoteCameFrom);
			strum += sectionStartTime(sectionToAddTo);
			trace("came from: " + sectionNoteCameFrom);
			trace("da sec:" + daSec);
			trace("adding to: " + sectionToAddTo);
			//var foundSection = false;
			

			//var timeInSection = getTimeOfSection(curSection);
			//sectionToAddTo = Std.int(strum / timeInSection) - curSection; 
			


			var copiedNote:Array<Dynamic> = [strum, note[1], note[2], note[3]];
			if (_song.notes[sectionToAddTo] != null)
			{
				_song.notes[sectionToAddTo].sectionNotes.push(copiedNote);
				ChartingUtil.highlighedNotes.push(copiedNote);
			}
			else
			{
				trace("null section shit");
				updateStatus("Error pasting notes");
				return;
			}

		}
		updateStatus("Pasted notes from clipboard");
		updateGrid();
	}
	function adjustNoteDatas(change:Int = 0):Void //adjusts highlighted notes
	{
		if (ChartingUtil.highlighedNotes.length > 0)
		{
			ChartingUtil.SaveUndo(_song);
			for (note in ChartingUtil.highlighedNotes)
			{
				for(sec in _song.notes)
				{
					for (daNote in sec.sectionNotes)
					{
						if (daNote[0] == note[0] && daNote[1] == note[1])
						{
							if ((note[1] + change) > -1 && (note[1] + change) < keyAmmo[_song.mania] * 2)
							{
								daNote[1] += change;
								note[1] += change;
							}
						}
					}
				}
			}
			var left = change == -1;
			updateStatus("Moved all highlighted notes to the " + (left ? "left" : "right"));
			updateGrid();
		}
		else
			updateStatus("No notes highlighted");
	}
	function adjustNoteStep(change:Int = 0):Void //adjusts highlighted notes
	{
		if (ChartingUtil.highlighedNotes.length > 0)
		{
			ChartingUtil.SaveUndo(_song);
			for (note in ChartingUtil.highlighedNotes)
			{
				for(sec in _song.notes)
				{
					for (daNote in sec.sectionNotes)
					{
						if (daNote[0] == note[0] && daNote[1] == note[1])
						{
							if ((note[0] + (change * Conductor.stepCrochet)) >= sectionStartTime(curSection) &&
								(note[0] + (change * Conductor.stepCrochet)) < sectionStartTime(curSection) + (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps))
							{
								daNote[0] += change * Conductor.stepCrochet;
								note[0] += change * Conductor.stepCrochet;
							}
						}
					}
				}
			}
			var up = change == -1;
			updateStatus("Moved all highlighted notes " + (up ? "up" : "down"));
			updateGrid();
		}
		else
			updateStatus("No notes highlighted");
	}
	function resetHighlights():Void
	{
		curRenderedNotes.forEach(function(note:Note)
		{
			note.highlighted = false;	
		});
		ChartingUtil.highlighedNotes = [];
		highlightCheck();//just in case
	}

	function labelsCheck() //only flxbuttons have a hover callback so uhhh i did this for the others
	{
		switch(UI_box.selected_tab_id)
		{
			case "Song": 
				UI_box.getTabGroup("Song").forEachOfType(FlxUICheckBox, function(spr:FlxUICheckBox)
				{
					if (FlxG.mouse.overlaps(spr))
					{
						var lab = spr.getLabel().text;
						switch (lab)
						{
							case "Has voice track": 
								tutorialTxt.text = "Toggle if the song uses the\nVoices audio file.";
							case "Show GF strums": 
								tutorialTxt.text = "Toggle if gf's notes are visible\nwhile playing.";
						}
					}
					
				});
				UI_box.getTabGroup("Song").forEachOfType(FlxUINumericStepper, function(spr:FlxUINumericStepper)
				{
					if (FlxG.mouse.overlaps(spr))
					{
						var lab = spr.name;
						switch (lab)
						{
							case "song_speed": 
								tutorialTxt.text = "Changes the global scroll\nspeed of the song.";
							case "song_bpm": 
								tutorialTxt.text = "Changes the BPM of the song.";
						}
					}	
				});
				UI_box.getTabGroup("Song").forEachOfType(FlxUIDropDownMenu, function(spr:FlxUIDropDownMenu)
				{
					if (FlxG.mouse.overlaps(spr.header)) //apparently the whole list that appears counts??? so only check the header
					{
						var lab = spr.name;
						switch (lab)
						{
							case "p1": 
								tutorialTxt.text = "Selects the Player 1 Character\n(boyfriend)";
							case "p2": 
								tutorialTxt.text = "Selects the Player 2 Character\n(oppenent)";
							case "gf": 
								tutorialTxt.text = "Selects the Player 3 Character\n(gf)";
							case "stages": 
								tutorialTxt.text = "Selects the Stage used\nfor the song.";
						}
					}	
				});
			case "Event": 
				UI_box.getTabGroup("Event").forEachOfType(FlxUIDropDownMenu, function(spr:FlxUIDropDownMenu)
				{
					if (FlxG.mouse.overlaps(spr.header)) //apparently the whole list that appears counts??? so only check the header
					{
						var lab = spr.name;
						switch (lab)
						{
							case "events": 
								tutorialTxt.text = "The list of events";
							case "presets": 
								tutorialTxt.text = "Presets for arrow movements";
						}
					}	
				});
			case "Editor": 
				UI_box.getTabGroup("Editor").forEachOfType(FlxUICheckBox, function(spr:FlxUICheckBox)
				{
					if (FlxG.mouse.overlaps(spr))
					{
						var lab = spr.getLabel().text;
						switch (lab)
						{
							case "Mute Instrumental": 
								tutorialTxt.text = "mutes the instrumental";
							case "Mute Vocals": 
								tutorialTxt.text = "mutes the vocals";
							case "Play Left Side Hitsounds": 
								tutorialTxt.text = "Enables the hitsounds on the\nleft side of the grid\n(technially the middle grid)";
							case "Play Right Side Hitsounds": 
								tutorialTxt.text = "Enables the hitsounds on the\nright side of the grid";
							case "Show Characters": 
								tutorialTxt.text = "Toggles the visiblity of\nthe characters";
						}
					}	
				});
			case "Section": 
				UI_box.getTabGroup("Section").forEachOfType(FlxUINumericStepper, function(spr:FlxUINumericStepper)
				{
					if (FlxG.mouse.overlaps(spr))
					{
						var lab = spr.name;
						switch (lab)
						{
							case "section_length": 
								tutorialTxt.text = "Changes the number of steps\nin the section.";
							case "section_bpm": 
								tutorialTxt.text = "Changes the BPM to change\nto if change BPM is checked\n(requires a reload when first\nadding a bpm change)";
						}
					}	
				});
				UI_box.getTabGroup("Section").forEachOfType(FlxUICheckBox, function(spr:FlxUICheckBox)
				{
					if (FlxG.mouse.overlaps(spr))
					{
						var lab = spr.name;
						switch (lab)
						{
							case "check_mustHit": 
								tutorialTxt.text = "Toggles which character is the\nmain singer in the section,\nthe camera will point to\nthat character.\n(Checking means bf will be\nthe main singer)";
							case "check_altAnim": 
								tutorialTxt.text = "Checking means characters will\nuse their alt singing animation";
							case "check_changeBPM": 
								tutorialTxt.text = "Checking means the bpm will\nchange from that section\nonwards, the stepper below\nis bpm that its changed to.\n(you should reload the chart\neditor after adding a change)";
						}
					}	
				});
			case "Note": 
				UI_box.getTabGroup("Note").forEachOfType(FlxUINumericStepper, function(spr:FlxUINumericStepper)
				{
					if (FlxG.mouse.overlaps(spr))
					{
						var lab = spr.name;
						switch (lab)
						{
							case "note_susLength": 
								tutorialTxt.text = "The sustain length of the\ncurrently selected note, the\nstepper can be used to change\nit manually (press apply after)";
							case "note_types": 
								tutorialTxt.text = "Changes the note type of\nnotes you place after changing\nthis.";
							case "note_speed": 
								tutorialTxt.text = "Changes the scroll speed of\nnotes you place after changing\nthis.(1 = default scroll speed)";
							case "note_velocity": 
								tutorialTxt.text = "Changes the velocity change\nspeed multiplier of notes\nyou place after changing this.\n(requires a change time)";
							case "note_velocity_time": 
								tutorialTxt.text = "Changes the velocity change\ntime of notes you place\nafter changing this.\n(requires a speed multi, change\ntime is in milliseconds before\nstrumtime)";
							case "mania": 
								tutorialTxt.text = "Changes the amount of\nkeys for the song.";
							case "strumID": 
								tutorialTxt.text = "Changes which strums a note\ngoes to, you need to add extra\nplayers for this to work.\n0-2 do nothing, they are for default strums\nand cannot be set with this stepper.\nIt does not matter which side a\nnote is placed on, placing on\nthe gf side will do nothing.";
						}
					}	
				});
		}
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
				updateStatus("Changed note sustain length");

				curRenderedNotes.forEach(function(note:Note)
				{
					if ((curSelectedNote[1] + 4) == note.rawNoteData && curSelectedNote[0] == note.strumTime) //remove the note so sustain sprite can be updated, dumb work around lol
					{
						//trace("removed note to update sustain");
						note.kill();
						curRenderedNotes.remove(note);
						note.destroy();
					}
				});
			}
		}

		updateNoteUI();
		updateGrid();
	}

	function recalculateSteps():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		FlxG.sound.music.pause();
		vocals.pause();

		// Basically old shit from changeSection???
		FlxG.sound.music.time = sectionStartTime(curSection);

		if (songBeginning)
		{
			FlxG.sound.music.time = 0;
			curSection = 0;
		}

		vocals.time = FlxG.sound.music.time;
		updateCurStep();

		updateGrid();
		updateSectionUI();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		//trace('changing section' + sec);
		autosaveSong();

		if (_song.notes[sec] != null && _song.notes[sec + 1] != null)
		{
			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				FlxG.sound.music.pause();
				vocals.pause();

				/*var daNum:Int = 0;
					var daLength:Float = 0;
					while (daNum <= sec)
					{
						daLength += lengthBpmBullshit();
						daNum++;
				}*/

				FlxG.sound.music.time = sectionStartTime(curSection);
				vocals.time = FlxG.sound.music.time;
				updateCurStep();

				FlxG.sound.music.play();
				vocals.play();
			}

			updateGrid();
			updateSectionUI();
		}
	}

	function copySection(?sectionNum:Int = 1)
	{
		ChartingUtil.SaveUndo(_song);
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2], note[3], note[4], note[5]];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}
		updateStatus("Copied section " + (daSec - sectionNum) + " to section " + curSection);

		updateGrid();
	}

	function updateSectionUI():Void
	{
		stepperLength.value = _song.notes[curSection].lengthInSteps;
		check_mustHitSection.checked = _song.notes[curSection].mustHitSection;
		check_altAnim.checked = _song.notes[curSection].altAnim;
		check_changeBPM.checked = _song.notes[curSection].changeBPM;
		stepperSectionBPM.value = _song.notes[curSection].bpm;

		updateHeads();
	}

	function undo():Void
	{
		if (ChartingUtil.UndoList.length > 0)
		{
			_song.notes = ChartingUtil.Undo();
			resetHighlights();
			updateStatus("Undo");
		}	
		else
			updateStatus("Nothing to Undo");
		updateGrid();
	}
	function redo():Void
	{
		if (ChartingUtil.RedoList.length > 0)
		{
			_song.notes = ChartingUtil.Redo();
			updateStatus("Redo");
		}	
		else
			updateStatus("Nothing to Redo");
		updateGrid();
	}

	function updateHeads():Void
	{
		remove(leftIcon);
		remove(rightIcon);
		if (check_mustHitSection.checked)
		{
			leftIcon = new HealthIcon(bfcharacter);
			rightIcon = new HealthIcon(dadcharacter);
		}
		else
		{
			leftIcon = new HealthIcon(dadcharacter);
			rightIcon = new HealthIcon(bfcharacter);
		}

		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);

		leftIcon.setGraphicSize(0, 45);
		rightIcon.setGraphicSize(0, 45);

		add(leftIcon);
		add(rightIcon);
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null)
		{
			stepperSusLength.value = curSelectedNote[2];
			if (curSelectedNote[3] != null)
				stepperNoteTypes.value = curSelectedNote[3];
			if (curSelectedNote[4] != null)
				stepperNoteSpeed.value = curSelectedNote[4];
			if (curSelectedNote[5] != null)
			{
				stepperNoteVelocity.value = curSelectedNote[5][0];
				velChangeTypingShit.text = curSelectedNote[5][1];
				check_velStrum.checked = curSelectedNote[5][2];
			}
			if (curSelectedNote[6] != null)
			{
				curEventData[0] = curSelectedNote[6][0];
				curEventData[1] = curSelectedNote[6][1];
				eventDropDown.selectedLabel = curEventData[0];
				eventTypingShit.text = curEventData[1];
			}
			if (curSelectedNote[7] != null)
			{
				stepperStrumID.value = curSelectedNote[7];
			}
			strumTimeTypingShit.text = curSelectedNote[0];
		}

	}

	function updateGrid():Void
	{
		curRenderedSustains.clear();
		curRenderedSpeed.forEach(function(spr:FlxText)
		{
			spr.destroy();
		});
		curRenderedTypes.forEach(function(spr:FlxText)
		{
			spr.destroy();
		});
		curRenderedTypes.clear();
		curRenderedSpeed.clear();

		var sectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;

		var lastSectionInfo:Array<Dynamic> = null;
		if (curSection != 0 && _song.notes[curSection - 1] != null)
			lastSectionInfo = _song.notes[curSection - 1].sectionNotes; //in case of broken sections idk, people keep crashing an im assuming its this

		var nextSectionInfo:Array<Dynamic> = null;
		if (_song.notes[curSection + 1] != null)
			nextSectionInfo = _song.notes[curSection + 1].sectionNotes;

		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0)
		{
			Conductor.changeBPM(_song.notes[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
			updateStatus("Changed BPM");
		}
		else
		{
			// get last bpm
			var daBPM:Float = _song.bpm;
			for (i in 0...curSection)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}
		
		curRenderedNotes.forEach(function(note:Note) //finally stop notes from being cleared and repalce everytime the grid updates
		{
			note.updated = false;
		});

		for (i in sectionInfo)
		{
			var foundNote:Bool = false;
			curRenderedNotes.forEach(function(note:Note)
			{
				
				if ((i[1] + 4) == note.rawNoteData && i[0] == note.strumTime)
				{
					updateNotePos(note, "normal");
					updateCurRenderedStuff(note);
					note.updated = true;
					foundNote = true;
					//trace("reusing notes");
				}
			});
			if (!foundNote)
				generateNotes(i, "normal");
			
		}
		if (curSection != 0 && lastSectionInfo != null)
		{
			for (i in lastSectionInfo)
				{
					var foundNote:Bool = false;
					curRenderedNotes.forEach(function(note:Note)
					{
						
						if ((i[1] + 4) == note.rawNoteData && i[0] == note.strumTime)
						{
							updateNotePos(note, "above");
							updateCurRenderedStuff(note);
							note.updated = true;
							foundNote = true;
							//trace("reusing notes");
						}
					});
					if (!foundNote)
						generateNotes(i, "above");
				}
		}
		if (nextSectionInfo != null)
		{
			for (i in nextSectionInfo)
				{
					var foundNote:Bool = false;
					curRenderedNotes.forEach(function(note:Note)
					{
						
						if ((i[1] + 4) == note.rawNoteData && i[0] == note.strumTime)
						{
							updateNotePos(note, "below");
							updateCurRenderedStuff(note);
							note.updated = true;
							foundNote = true;
							//trace("reusing notes");
						}
					});
					if (!foundNote)
						generateNotes(i, "below");
				}
		}
		curRenderedNotes.forEach(function(note:Note)
		{
			if (!note.updated)
			{
				note.kill();
				curRenderedNotes.remove(note);
				note.destroy();
				//trace("removed unused notes");
			}
		});
		highlightCheck();
	}

	function updateNotePos(note:Note, sectionType:String = "normal")
	{
		switch (sectionType)
		{
			case "normal": 
				note.y = Math.floor(getYfromStrum((note.strumTime - sectionStartTime(curSection)) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));
			case "above": 
				note.y = Math.floor(getAboveYfromStrum((note.strumTime - sectionStartTime(curSection - 1)) % (Conductor.stepCrochet * _song.notes[curSection - 1].lengthInSteps)));
			case "below": 
				note.canPlaySound = false;
				note.y = Math.floor(getBelowYfromStrum((note.strumTime - sectionStartTime(curSection + 1)) % (Conductor.stepCrochet * _song.notes[curSection + 1].lengthInSteps)));
		}
	}

	function updateCurRenderedStuff(note:Dynamic)
	{
		if (note.speed != 1 && note.speed != null && note.speed != 0)
		{
			var thetext:String = Std.string(note.speed);
			var typeText:FlxText = new FlxText(note.x, note.y, 0, thetext, 25, true);
			typeText.color = FlxColor.fromRGB(255,0,0);
			curRenderedSpeed.add(typeText);
		}

		if (note.noteType == 5)
		{
			var thetext:String = Std.string(note.noteType);
			var typeText:FlxText = new FlxText(note.x, note.y, 0, thetext, 25, true);
			typeText.color = FlxColor.fromRGB(255,0,0);
			if (note.noteType == 5)
			{
				typeText.text = "Alt";
			}
			curRenderedTypes.add(typeText);
		}

		if (note.sustainLength > 0)
		{
			var xpos = note.x + (GRID_SIZE / 2);
			var ypos = note.y + GRID_SIZE;
			var height = Math.floor(FlxMath.remapToRange(note.sustainLength, 0, Conductor.stepCrochet * 16, 0, gridBG.height));
			var sustain:CharterSustain = new CharterSustain(xpos, ypos, 8, height, _song.mania, note);
			curRenderedSustains.add(sustain);
		}
	}

	private function generateNotes(i:Dynamic, sectionType:String = "normal")
	{
		var daNoteInfo = i[1]; //plus 4 for gf chart, so the negative note data will go onto gf chart
		daNoteInfo += 4;
		var daStrumTime = i[0];
		var daSus = i[2];
		var daType = i[3];
		var daSpeed = i[4];
		var daVelocity = i[5];
		var daEventData = i[6];
		var daGFNote = daNoteInfo <= 3;
		var fixedShit = daNoteInfo % 4;
		if (!daGFNote)
			fixedShit = ((daNoteInfo - 4) + keyAmmo[_song.mania]) % keyAmmo[_song.mania];

		var mustPress:Bool = false;

		var note:Note = new Note(daStrumTime, fixedShit, daType, false, daSpeed, daVelocity, true, daGFNote, mustPress, daEventData);
		note.inCharter = true;
		note.sustainLength = daSus;
		note.noteType = daType;
		note.speed = daSpeed;
		if (daVelocity != null)
		{
			if (daVelocity.length > 2)
			{
				note.velocityData = {
					SpeedMulti: daVelocity[0],
					ChangeTime: daVelocity[1],
					UseSpecificStrumTime: daVelocity[2]
				};
			}
			else //back compat
			{
				note.velocityData = {
					SpeedMulti: daVelocity[0],
					ChangeTime: daVelocity[1],
					UseSpecificStrumTime: false
				};
			}
		}

		note.rawNoteData = daNoteInfo;
		note.playedSound = true;
		note.updated = true;
		note.setGraphicSize(GRID_SIZE, GRID_SIZE);
		note.updateHitbox();


		switch (sectionType)
		{
			case "normal": 
				mustPress = _song.notes[curSection].mustHitSection;
				if ((note.rawNoteData - 4) >= keyAmmo[_song.mania])
					mustPress = !mustPress;
				note.section = curSection;
			case "above": 
				mustPress = _song.notes[curSection - 1].mustHitSection;
				if ((note.rawNoteData - 4) >= keyAmmo[_song.mania])
					mustPress = !mustPress;
				note.section = curSection - 1;
			case "below": 
				mustPress = _song.notes[curSection + 1].mustHitSection;
				if ((note.rawNoteData - 4) >= keyAmmo[_song.mania])
					mustPress = !mustPress;
				note.section = curSection + 1;
		}
		note.mustPress = mustPress;

		
		note.canPlaySound = true;
		
				
		note.x = Math.floor(daNoteInfo * GRID_SIZE);

		switch (sectionType)
		{
			case "normal": 
				note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime(curSection)) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));
			case "above": 
				note.y = Math.floor(getAboveYfromStrum((daStrumTime - sectionStartTime(curSection - 1)) % (Conductor.stepCrochet * _song.notes[curSection - 1].lengthInSteps)));
			case "below": 
				note.canPlaySound = false;
				note.y = Math.floor(getBelowYfromStrum((daStrumTime - sectionStartTime(curSection + 1)) % (Conductor.stepCrochet * _song.notes[curSection + 1].lengthInSteps)));
		}

		if (daSpeed != 1 && daSpeed != null && note.speed != 0)
		{
			var thetext:String = Std.string(daSpeed);
			var typeText:FlxText = new FlxText(note.x, note.y, 0, thetext, 25, true);
			typeText.color = FlxColor.fromRGB(255,0,0);
			curRenderedSpeed.add(typeText);
		}

		if (daType == 5)
		{
			var thetext:String = Std.string(daType);
			var typeText:FlxText = new FlxText(note.x, note.y, 0, thetext, 25, true);
			typeText.color = FlxColor.fromRGB(255,0,0);
			if (daType == 5)
			{
				typeText.text = "Alt";
			}
			curRenderedTypes.add(typeText);
		}

		curRenderedNotes.add(note);

		if (daSus > 0)
		{
			var xpos = note.x + (GRID_SIZE / 2);
			var ypos = note.y + GRID_SIZE;
			var height = Math.floor(FlxMath.remapToRange(note.sustainLength, 0, Conductor.stepCrochet * 16, 0, gridBG.height));
			var sustain:CharterSustain = new CharterSustain(xpos, ypos, 8, height, _song.mania, note);
			curRenderedSustains.add(sustain);
		}
	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			mania: _song.mania,
			changeBPM: false,
			mustHitSection: true,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false
		};

		_song.notes.push(sec);
	}

	function selectNote(note:Note, daSection:SwagSection):Void
	{
		
		for (i in daSection.sectionNotes)
		{
			if (i[0] == note.strumTime && i[1] == (note.rawNoteData - 4))
			{
				curSelectedNote = i;
				updateStatus("Selected Note");
			}
		}

		updateGrid();
		updateNoteUI();
	}

	function deleteNote(note:Note, daSection:SwagSection):Void
	{
		resetHighlights();
		//trace("ahhhhhhhhhhhhh");
		//i solved it hahahhahahahah
		//fuckjing strumtime are decimals ahghhhhhhhh
		var deleted:Bool = false;
		for (i in daSection.sectionNotes)
		{
			if (i[0] == note.strumTime && i[1] == (note.rawNoteData - 4))
			{
				//trace("please delete the note i fucking hate this");
				FlxG.log.add('FOUND EVIL NUMBER');
				daSection.sectionNotes.remove(i);
				deleted = true;
			}
		}
		if (!deleted)
		{
			//trace("fucking stupid fucking notes not being deleted");
			for(sec in _song.notes) //search the whole song rather than section
			{
				for (daNote in sec.sectionNotes)
				{
					if (daNote[0] == note.strumTime && daNote[1] == (note.rawNoteData - 4))
						sec.sectionNotes.remove(daNote);
				}
			}
		}

		//curRenderedNotes.remove(note);
		updateStatus("Deleted Note");
		updateGrid();
	}

	function clearSection():Void
	{
		ChartingUtil.SaveUndo(_song);
		_song.notes[curSection].sectionNotes = [];
		updateStatus("Cleared Section " + curSection);

		updateGrid();
	}

	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
		{
			_song.notes[daSection].sectionNotes = [];
		}

		updateGrid();
	}

	private function addNote(daSection:SwagSection, ?n:Note):Void
	{
		resetHighlights();

		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime(curSection);
		var noteData = Math.floor(FlxG.mouse.x / GRID_SIZE);
			
		var noteSus = 0;
		var noteType = 0;
		noteType = Std.int(stepperNoteTypes.value);
		var noteSpeed:Float = 1;
		noteSpeed = stepperNoteSpeed.value;
		var noteVelocity:Array<Dynamic> = [1, 0, false];
		noteVelocity = [stepperNoteVelocity.value, curNoteVelocityTime, check_velStrum.checked];
		var eventData:Array<String> = ["none", ""];
		eventData = [curEventData[0], curEventData[1]];
		

		if (_song.mania == 2 || _song.mania == 5)
			var noteData = Math.floor(FlxG.mouse.x / S_GRID_SIZE);

		noteData -= 4; //takes away for gf chart negative note data, i am doing it this way so charts dont need to be completely remade lol

		if (noteData < 0)
			eventData = null; //only save event data to negative note datas
		var strumID = stepperStrumID.value;

		if (n != null)
			daSection.sectionNotes.push([n.strumTime, n.noteData, n.sustainLength, n.noteType, n.speed, n.velocityData, n.eventData, n.strumID]);
		else
			daSection.sectionNotes.push([noteStrum, noteData, noteSus, noteType, noteSpeed, noteVelocity, eventData, strumID]);

		var thingy = daSection.sectionNotes[daSection.sectionNotes.length - 1];
		curSelectedNote = thingy;

		if (FlxG.keys.pressed.CONTROL)
			daSection.sectionNotes.push([noteStrum, (noteData -18), noteSus, noteType, noteSpeed, noteVelocity, eventData, strumID]);

		//trace(noteStrum);
		//trace(curSection);
		updateStatus("Added Note");

		updateGrid();
		updateNoteUI();
	}

	private function addNoteFromKey(data:Int):Void
	{
		resetHighlights();

		var strumY = Math.floor(strumLine.y / (GRID_SIZE / snaps[curSnap])) * (GRID_SIZE / snaps[curSnap]);

		var noteStrum = getStrumTime(strumY) + sectionStartTime(curSection);
		var noteData = Math.floor(data);
			
		var noteSus = 0;
		var noteType = 0;
		noteType = Std.int(stepperNoteTypes.value);
		var noteSpeed:Float = 1;
		noteSpeed = stepperNoteSpeed.value;
		var noteVelocity:Array<Float> = [1, 0];
		noteVelocity = [stepperNoteVelocity.value, stepperNoteVelocityTime.value];
		var eventData:Array<String> = ["none", ""];
		eventData = [curEventData[0], curEventData[1]];
		if (noteData >= 0)
			eventData = null;

		middleSection.sectionNotes.push([noteStrum, noteData, noteSus, noteType, noteSpeed, noteVelocity, eventData]);

		if (FlxG.keys.pressed.CONTROL)
			middleSection.sectionNotes.push([noteStrum, (noteData -18), noteSus, noteType, noteSpeed, noteVelocity, eventData]);

		updateStatus("Added Note");

		updateGrid();
		updateNoteUI();
	}

	/*override function beatHit()
	{
		if (curBeat % gfSpeed == 0)
			gf.dance();
		if (!player1.animation.curAnim.name.startsWith("sing"))
			player1.dance();
		if (_song.notes[curSection].mustHitSection)
			player2.dance();

		super.beatHit();
	}*/

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}
	function getAboveYfromStrum(strumTime:Float):Float
		{
			return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBGAbove.y, gridBGAbove.y + gridBGAbove.height);
		}
	function getBelowYfromStrum(strumTime:Float):Float
		{
			return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBGBelow.y, gridBGBelow.y + gridBGBelow.height);
		}

	private var daSpacing:Float = 0.3;

	function loadLevel():Void
	{
		trace(_song.notes);
	}

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function updateStatus(status:String)
	{
		statusText.text = status;
		statusText.alpha = 1;
	}

	function loadJson(song:String):Void
	{
		PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
		FlxG.resetState();
	}

	function loadAutosave():Void
	{
		PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
		FlxG.resetState();
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		FlxG.save.flush();
	}

	function cleanChart(chart:SwagSong)
	{
		for (sections in chart.notes)
		{
			for (danote in sections.sectionNotes)
			{
				if (danote[1] < 0) //remove event notes in the left grid
					sections.sectionNotes.remove(danote);

				if (danote[0] < 0)
					sections.sectionNotes.remove(danote);

				danote[3] = null;
				danote[4] = null;
				danote[5] = null;
				danote[6] = null;

			}
		}


		return chart;
	}
	function luaChartConvert(chart:SwagSong)
		{
			var dataConverts:Array<Array<Int>> = [
				[0, 1, 2, 3,  4, 5, 6, 7],
				[0, 2, 3, 0, 1, 3,  4, 6, 7, 4, 5, 7],
				[0, 1, 2, 3, 2, 0, 1, 2, 3,  4, 5, 6, 7, 6, 4, 5, 6, 7],
				[0, 1, 2, 2, 3,  4, 5, 6, 6, 7],
				[0, 2, 3, 2, 0, 1, 3,   4, 6, 7, 6, 4, 5, 7],
				[0, 1, 2, 3, 0, 1, 2, 3,  4, 5, 6, 7, 4, 5, 6, 7],
				[2,6],
				[0,1,4,7],
				[0,2,3,4,6,7]
			];
			var nTypeConverts:Array<Array<String>> = [
				[null, null, null, null,null, null, null, null],
				[null, null, null, "extras", null, "extras",null, null, null, "extras", null, "extras"],
				[null, null, null, null, "space", "extras", "extras", "extras", "extras",null, null, null, null, "space", "extras", "extras", "extras", "extras"],
				[null, null, "space", null, null,null, null, "space", null, null],
				[null, null, null, "space", "extras", null, "extras",null, null, null, "space", "extras", null, "extras"],
				[null, null, null, null, "extras", "extras", "extras", "extras",null, null, null, null, "extras", "extras", "extras", "extras"],
				["space","space"],
				[null,null,null,null],
				[null,"space",null,null,"space",null]
			];


			for (sections in chart.notes)
			{
				for (daNote in sections.sectionNotes)
				{
					//trace(nTypeConverts[_song.mania][daNote[1]]);
					daNote[3] = nTypeConverts[_song.mania][daNote[1]]; //do note type first cuz data gets changed after
					daNote[1] = dataConverts[_song.mania][daNote[1]];
					
				}
			}
	
	
			return chart;
		}

	private function saveLevel(compatibilityMode:Bool = false, luaSaveMode:Bool = false)
	{
		var json = {
			"song": _song
		};

		if (compatibilityMode)
		{
			var shit = Json.stringify({ //doin this so it doesnt act as a reference
				"song": _song
			});
			var thing:SwagSong = Song.parseJSONshit(shit);

			for (i in 0...25)
			{								//so sometimes it would miss random notes, loop it to be sure its all gone
				thing = cleanChart(thing); //do it 25 times to be 100% sure it works
			}								//upped to 25 cuz i dont trust it

			json = {
				"song": thing
			};
		}


		if (luaSaveMode)
		{
			var shit = Json.stringify({ //doin this so it doesnt act as a reference
				"song": _song
			});
			var thing:SwagSong = Song.parseJSONshit(shit);

			thing = luaChartConvert(thing);			

			json = {
				"song": thing
			};
		}



		var data:String = Json.stringify(json, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.song.toLowerCase() + ".json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}
}
