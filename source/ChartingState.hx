package;

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

import lime.media.openal.AL;

#if sys
import flash.media.Sound;
#end

using StringTools;

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

	var strumLine:FlxSprite;
	var curSong:String = 'Dadbattle';
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;

	var GRID_SIZE:Int = 40;
	var S_GRID_SIZE:Int = 40;
	var GF_GRID:Int = 160;

	var dummyArrow:FlxSprite;

	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;
	var curRenderedTypes:FlxTypedGroup<FlxSprite>; //old system i used for note types, i figred out how to make them show properly, so now this is just used for displaying an alt note
	var curRenderedSpeed:FlxTypedGroup<FlxSprite>; //for displaying the text of note speed, so you know its different

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
	private var sDir:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	private var GFsDir:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;
	var keyAmmo:Array<Int> = [4, 6, 9, 5, 7, 8, 1, 2, 3];
	private var lastNote:Note;

	var selectedType:Int = 0;

	var curNoteSpeed:Float = 1;
	var curNoteVelocity:Float = 1;
	var curNoteVelocityTime:Float = 0;

	var leftHitsounds:Bool = true;
	var rightHitsounds:Bool = true;
	var showCharacters:Bool = true;

	var dadcharacter:String;
	var bfcharacter:String;

	var daBeat:Int = 0;
	var daStep:Int = 0;

	var characterList:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));

	var hitSound:FlxSound;
	var pitches:Array<Float> = [1.5, 0.5, 1, 2, 0.7, 1.6, 2.3, 0.3, 1.2]; //kinda just picked random ones

	override function create()
	{
		// my epic stage system
        var pieceArray = ['stageBG', 'stageFront', 'stageCurtains'];
        for (i in 0...pieceArray.length)
        {
            var piece:StagePiece = new StagePiece(-450, -100, pieceArray[i]);
            piece.x += piece.newx;
            piece.y += piece.newy;
            add(piece);
			piece.scrollFactor.set();
		}

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
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();
		curRenderedTypes = new FlxTypedGroup<FlxSprite>();
		curRenderedSpeed = new FlxTypedGroup<FlxSprite>();


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
				validScore: false
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
			{name: "Song", label: 'Song'},
			{name: "Section", label: 'Section'},
			{name: "Note", label: 'Note'},
			{name: "Editor", label: 'Editor'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = FlxG.width / 2 + 40;
		UI_box.y = 20;
		add(UI_box);

		addSongUI();
		addSectionUI();
		addNoteUI();
		addEditorUI();

		add(curRenderedNotes);
		add(curRenderedSustains);
		add(curRenderedTypes);
		add(curRenderedSpeed);

		super.create();
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



		var saveButton:FlxButton = new FlxButton(110, 8, "Save", function()
		{
			saveLevel();
		});

		var reloadSong:FlxButton = new FlxButton(saveButton.x + saveButton.width + 10, saveButton.y, "Reload Audio", function()
		{
			loadSong(_song.song);
		});

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 30, "Reload JSON", function()
		{
			loadJson(_song.song.toLowerCase());
		});

		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'load autosave', loadAutosave);

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 80, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 65, 0.1, 1, 1.0, 5000.0, 1);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';

		var characters:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));
		var gfVersions:Array<String> = CoolUtil.coolTextFile(Paths.txt('gfVersionList'));
		var stages:Array<String> = CoolUtil.coolTextFile(Paths.txt('stageList'));

		var p1DropDown = new FlxUIDropDownMenu(10, 120, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player1 = characters[Std.parseInt(character)];
		});
		p1DropDown.selectedLabel = _song.player1;

		var p1Label = new FlxText(10,100,64,'Player 1');

		var p2DropDown = new FlxUIDropDownMenu(10, 170, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player2 = characters[Std.parseInt(character)];
		});
		p2DropDown.selectedLabel = _song.player2;

		var p2Label = new FlxText(10,150,64,'Player 2');

		var gfDropDown = new FlxUIDropDownMenu(10, 220, FlxUIDropDownMenu.makeStrIdLabelArray(gfVersions, true), function(gfVersion:String)
		{
			_song.gfVersion = gfVersions[Std.parseInt(gfVersion)];
		});
		gfDropDown.selectedLabel = _song.gfVersion;

		var gfLabel = new FlxText(10,200,64,'Gf');

		var StageDropDown = new FlxUIDropDownMenu(10, 270, FlxUIDropDownMenu.makeStrIdLabelArray(stages, true), function(stage:String)
		{
			_song.stage = stages[Std.parseInt(stage)];
		});
		StageDropDown.selectedLabel = _song.stage;

		var StageLabel = new FlxText(10,250,64,'Stages');


		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);

		tab_group_song.add(check_voices);

		tab_group_song.add(saveButton);
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



		
		UI_box.addGroup(tab_group_song);
		UI_box.scrollFactor.set();

		FlxG.camera.follow(strumLine);
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

		var check_leftHitsounds = new FlxUICheckBox(10, 10, null, null, "Play Left Side Hitsounds", 100);
		check_leftHitsounds.checked = true;
		check_leftHitsounds.callback = function()
		{
			leftHitsounds = false;
			if (check_leftHitsounds.checked)
				leftHitsounds = true;
		};

		var check_rightHitsounds = new FlxUICheckBox(10, 30, null, null, "Play Right Side Hitsounds", 100);
		check_rightHitsounds.checked = true;
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

		tab_group_editor.add(check_leftHitsounds);
		tab_group_editor.add(check_rightHitsounds);
		tab_group_editor.add(check_characters);
		tab_group_editor.add(check_mute_inst);
		tab_group_editor.add(noteCleanup);


		UI_box.addGroup(tab_group_editor);
	}

	var stepperLength:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var check_changeMania:FlxUICheckBox;
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

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear", clearSection);

		var swapSection:FlxButton = new FlxButton(10, 170, "Swap section", function()
		{
			
			for (i in 0...middleSection.sectionNotes.length)
			{
				var note = middleSection.sectionNotes[i];
				var half = keyAmmo[_song.mania];
				var nT = Math.floor(note[1] / (half * 2));
				note[1] = (note[1] + half) % (half * 2) + nT * (half * 2);
				middleSection.sectionNotes[i] = note;
				updateGrid();
			}
		});

		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Must hit section", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = true;
		// _song.needsVoices = check_mustHit.checked;

		check_altAnim = new FlxUICheckBox(10, 400, null, null, "Alt Animation", 100);
		check_altAnim.name = 'check_altAnim';

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
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

	var stepperNoteSpeed:FlxUINumericStepper;

	var stepperNoteVelocity:FlxUINumericStepper;
	var stepperNoteVelocityTime:FlxUINumericStepper;

	var noteTypes:Array<String> = ['Normal', 'Fire', 'Death', 'Warning', 'Angel', 'Alt Anim', 'Bob', 'Glitch'];
	var typeChangeLabel:FlxText;
	var speedLabel:FlxText;

	var velocityLabel:FlxText;
	var velocityTimeLabel:FlxText;
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

		speedLabel = new FlxText(200, 75, 64, "Speed: " + curNoteSpeed);

		stepperNoteVelocity = new FlxUINumericStepper(200, 105, 0.1, curNoteVelocity, 0.1, 2, 1);
		stepperNoteVelocity.value = curNoteVelocity;
		stepperNoteVelocity.name = 'note_velocity';

		velocityLabel = new FlxText(200, 125, 64, "Velocity: " + curNoteVelocity + "x" + " (WIP)");

		stepperNoteVelocityTime = new FlxUINumericStepper(200, 155, 10, curNoteVelocityTime, 0, 5000, 0);
		stepperNoteVelocityTime.value = curNoteVelocityTime;
		stepperNoteVelocityTime.name = 'note_velocity_time';

		velocityTimeLabel = new FlxText(200, 175, 64, "Velocity Time: -" + curNoteVelocityTime + " (WIP)");

		check_changeMania = new FlxUICheckBox(10, 60, null, null, 'Change Mania', 100);
		check_changeMania.name = 'check_changeMania';

		var applyLength:FlxButton = new FlxButton(100, 10, 'Apply');

		var ammolabel = new FlxText(10,35,64,'Amount of Keys');

		var typelabel = new FlxText(100,35,64,'Note Types');
		var m_check = new FlxUICheckBox(10, 165, null, null, "6", 100);
		m_check.checked = (_song.mania == 1);
		m_check.callback = function()
		{
			_song.mania = 0;
			if (m_check.checked)
			{
				_song.mania = 1;
			}
			trace('vos sos puto');
		};

		var m_check2 = new FlxUICheckBox(10, 225, null, null, "9", 100);
		m_check2.checked = (_song.mania == 2);
		m_check2.callback = function()
		{
			_song.mania = 0;
			if (m_check2.checked)
			{
				_song.mania = 2;
			}
			trace('vos sos puto otra vez no weí');
		};
		var m_check3 = new FlxUICheckBox(10, 145, null, null, "5", 100);
		m_check3.checked = (_song.mania == 3);
		m_check3.callback = function()
		{
			_song.mania = 0;
			if (m_check3.checked)
			{
				_song.mania = 3;
			}
			trace('5 keys pog');
		};
		var m_check4 = new FlxUICheckBox(10, 185, null, null, "7", 100);
		m_check4.checked = (_song.mania == 4);
		m_check4.callback = function()
		{
			_song.mania = 0;
			if (m_check4.checked)
			{
				_song.mania = 4;
			}
			trace('7 keys pog');
		};
		var m_check5 = new FlxUICheckBox(10, 205, null, null, "8", 100);
		m_check5.checked = (_song.mania == 5);
		m_check5.callback = function()
		{
			_song.mania = 0;
			if (m_check5.checked)
			{
				_song.mania = 5;
			}
			trace('8 keys pog');
		};
		var m_check6 = new FlxUICheckBox(10, 65, null, null, "1", 100);
		m_check6.checked = (_song.mania == 5); 
		m_check6.callback = function()
		{
			_song.mania = 0;
			if (m_check6.checked)
			{
				_song.mania = 6;
			}
			trace('1 keys pog');
		};
		var m_check7 = new FlxUICheckBox(10, 85, null, null, "2", 100);
		m_check7.checked = (_song.mania == 7);
		m_check7.callback = function()
		{
			_song.mania = 0;
			if (m_check7.checked)
			{
				_song.mania = 7;
			}
			trace('2 keys pog');
		};
		var m_check8 = new FlxUICheckBox(10, 105, null, null, "3", 100);
		m_check8.checked = (_song.mania == 5);
		m_check8.callback = function()
		{
			_song.mania = 0;
			if (m_check8.checked)
			{
				_song.mania = 8;
			}
			trace('3 keys pog');
		};

		var m_check0 = new FlxUICheckBox(10, 125, null, null, "4", 100);
		m_check0.checked = (_song.mania == 0);
		m_check0.callback = function()
		{
			_song.mania = 0;
			if (m_check0.checked)
			{
				_song.mania = 0;
			}
			trace('4 keys cringe');
		};

		tab_group_note.add(stepperSusLength);
		tab_group_note.add(applyLength);
		//tab_group_note.add(resetValues);
		tab_group_note.add(ammolabel);
		tab_group_note.add(stepperNoteTypes);
		tab_group_note.add(typeChangeLabel);
		tab_group_note.add(typelabel);
		tab_group_note.add(m_check0);
		tab_group_note.add(m_check);
		tab_group_note.add(m_check2);
		tab_group_note.add(m_check3);
		tab_group_note.add(m_check4);
		tab_group_note.add(m_check5);
		tab_group_note.add(m_check6);
		tab_group_note.add(m_check7);
		tab_group_note.add(m_check8);
		tab_group_note.add(speedLabel);
		tab_group_note.add(stepperNoteSpeed);

		tab_group_note.add(stepperNoteVelocity);
		tab_group_note.add(velocityLabel);

		tab_group_note.add(stepperNoteVelocityTime);
		tab_group_note.add(velocityTimeLabel);

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
		/* 
			var loopCheck = new FlxUICheckBox(UI_box.x + 10, UI_box.y + 50, null, null, "Loops", 100, ['loop check']);
			loopCheck.checked = curNoteSelected.doesLoop;
			tooltips.add(loopCheck, {title: 'Section looping', body: "Whether or not it's a simon says style section", style: tooltipType});
			bullshitUI.add(loopCheck);

		 */
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

				case 'Change Mania':
					middleSection.changeMania = check.checked;
					FlxG.log.add('changed the mania');
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
			if (_song.notes[i].changeBPM)
			{
				daBPM = _song.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	override function update(elapsed:Float)
	{
		typeChangeLabel.text = noteTypes[Std.int(stepperNoteTypes.value)] + ' notes';
		speedLabel.text = "Speed: " + stepperNoteSpeed.value;
		velocityLabel.text = "Velocity: " + stepperNoteVelocity.value + "x";
		velocityTimeLabel.text = "Velocity Time: -" + stepperNoteVelocityTime.value;
		curStep = recalculateSteps();

		dadcharacter = _song.player2;
		bfcharacter = _song.player1;

		if (!characterList.contains(dadcharacter)) //stop the fucking game from crashing when theres a character that doesnt exist
			dadcharacter = "dad";
		if (!characterList.contains(bfcharacter))
			bfcharacter = "bf";

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

		newGridSize = keyAmmo[_song.mania] * 2;
		if (gridBG.width != (GRID_SIZE * newGridSize) + GF_GRID)
		{
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

		switch(_song.mania)
		{
			case 0: 
				sDir = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
			case 1: 
				sDir = ['LEFT', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'RIGHT'];
			case 2: 
				sDir = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'UP', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
			case 3: 
				sDir = ['LEFT', 'DOWN', 'UP', 'UP', 'RIGHT'];
			case 4: 
				sDir = ['LEFT', 'UP', 'RIGHT', 'UP', 'LEFT', 'DOWN', 'RIGHT'];
			case 5: 
				sDir = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
			case 6: 
				sDir = ['UP'];
			case 7: 
				sDir = ['LEFT', 'RIGHT'];
			case 8:
				sDir = ['LEFT', 'UP', 'RIGHT'];
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
							player2.playAnim('sing' + sDir[note.noteData], true);
							player2.holdTimer = 0;
						}
						else if (note.mustPress)
						{
							player1.playAnim('sing' + sDir[note.noteData], true);
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
		curRenderedSustains.forEach(function(sus:FlxSprite)
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
						else
						{
							trace('tryin to delete note...');
							deleteNote(note, whichSectionYouIn);
						}
					}
				});
			}
			else
			{
				if (isDaMouseInGrid)
				{
					if (!FlxG.keys.pressed.CONTROL) //stop crashing
						addNote(whichSectionYouIn);
				}
			}
		}
		if (FlxG.keys.pressed.Z)
			if (!FlxG.mouse.overlaps(curRenderedNotes))
				if (isDaMouseInGrid)
					if (!FlxG.keys.pressed.CONTROL) //stop crashing
						addNote(whichSectionYouIn); //allows you to draw notes by holding left click

		if (FlxG.keys.pressed.X)
			if (FlxG.mouse.overlaps(curRenderedNotes))
				if (isDaMouseInGrid)
					curRenderedNotes.forEach(function(note:Note)
					{
						if (FlxG.mouse.overlaps(note))
							deleteNote(note, whichSectionYouIn); //mass deletion of notes
					});
			
		if (FlxG.keys.pressed.C)
			if (FlxG.sound.music.playing) //something i might try at some point
				{
					if (curStep != daStep)
					{
						daStep = curStep;
						
					}
				}
					

		if (curBeat != daBeat) //shitty version of beatHit()
		{
			daBeat = curBeat;
			if (curBeat % gfSpeed == 0)
				gf.dance();
			if (!player1.animation.curAnim.name.startsWith("sing"))
				player1.dance();
			if (!player2.animation.curAnim.name.startsWith("sing"))
				player2.dance();
		}
		
		if (isDaMouseInGrid)
		{
			var arX = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (_song.mania == 2 || _song.mania == 5) arX = Math.floor(FlxG.mouse.x / S_GRID_SIZE) * S_GRID_SIZE;
			dummyArrow.x = arX;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
		}

		if (FlxG.keys.justPressed.ENTER)
		{
			lastSection = curSection;

			PlayState.SONG = _song;
			FlxG.sound.music.stop();
			vocals.stop();
			Main.editor = false;
			FlxG.switchState(new PlayState());
		}

		if (FlxG.keys.justPressed.E)
		{
			changeNoteSustain(Conductor.stepCrochet);
		}
		if (FlxG.keys.justPressed.Q)
		{
			changeNoteSustain(-Conductor.stepCrochet);
		}

		if (FlxG.keys.justPressed.TAB)
		{
			if (FlxG.keys.pressed.SHIFT)
			{
				UI_box.selected_tab -= 1;
				if (UI_box.selected_tab < 0)
					UI_box.selected_tab = 2;
			}
			else
			{
				UI_box.selected_tab += 1;
				if (UI_box.selected_tab >= 3)
					UI_box.selected_tab = 0;
			}
		}

		if (!typingShit.hasFocus)
		{
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
			if (FlxG.keys.justPressed.ESCAPE)
				FlxG.switchState(new DebugState());

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

		_song.bpm = tempBpm;

		var shiftThing:Int = 1;
		if (FlxG.keys.pressed.SHIFT)
			shiftThing = 4;
		if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
			changeSection(curSection + shiftThing);
		if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
			changeSection(curSection - shiftThing);

		bpmTxt.text = bpmTxt.text = Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2))
			+ "\nSection: "
			+ curSection
			+ "\nCurStep: "
			+ curStep;
		super.update(elapsed);
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
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
		trace('changing section' + sec);

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

			if (newGridSize > 18)
				FlxG.switchState(new StoryMenuState());
		}
	}

	function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2], note[3], note[4], note[5]];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

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
				stepperNoteVelocityTime.value = curSelectedNote[5][1];
			}

		}

	}

	function updateGrid():Void
	{
		while (curRenderedNotes.members.length > 0)
		{
			curRenderedNotes.remove(curRenderedNotes.members[0], true);
		}

		while (curRenderedSustains.members.length > 0)
		{
			curRenderedSustains.remove(curRenderedSustains.members[0], true);
		}

		while (curRenderedTypes.members.length > 0)
			{
				curRenderedTypes.remove(curRenderedTypes.members[0], true);
			}
		while (curRenderedSpeed.members.length > 0)
			{
				curRenderedSpeed.remove(curRenderedSpeed.members[0], true);
			}

		var sectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;

		var lastSectionInfo:Array<Dynamic> = null;
		if (curSection != 0 && _song.notes[curSection - 1] != null)
			lastSectionInfo = _song.notes[curSection - 1].sectionNotes; //in case of broken sections idk, people keep crashing an im assuming its this

		var nextSectionInfo:Array<Dynamic> = null;
		if (_song.notes[curSection + 1] != null)
			nextSectionInfo = _song.notes[curSection + 1].sectionNotes;

		if (middleSection.changeBPM && middleSection.bpm > 0)
		{
			Conductor.changeBPM(middleSection.bpm);
			FlxG.log.add('CHANGED BPM!');
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

		for (i in sectionInfo)
		{
			generateNotes(i, "normal");
		}
		if (curSection != 0 && lastSectionInfo != null)
		{
			for (i in lastSectionInfo)
				{
					generateNotes(i, "above");
				}
		}
		if (nextSectionInfo != null)
		{
			for (i in nextSectionInfo)
				{
					generateNotes(i, "below");
				}
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
		var daGFNote = daNoteInfo <= 3;
		var fixedShit = daNoteInfo % 4;
		if (!daGFNote)
			fixedShit = ((daNoteInfo - 4) + keyAmmo[_song.mania]) % keyAmmo[_song.mania];

		var mustPress:Bool = false;

		var note:Note = new Note(daStrumTime, fixedShit, daType, false, daSpeed, daVelocity, true, daGFNote);
		note.inCharter = true;
		note.sustainLength = daSus;
		note.noteType = daType;
		note.speed = daSpeed;
		note.velocityData = daVelocity;
		note.setGraphicSize(GRID_SIZE, GRID_SIZE);
		note.updateHitbox();
		note.rawNoteData = daNoteInfo;
		note.playedSound = true;

		switch (sectionType)
		{
			case "normal": 
				mustPress = _song.notes[curSection].mustHitSection;
				if ((note.rawNoteData - 4) >= keyAmmo[_song.mania])
					mustPress = !mustPress;
			case "above": 
				mustPress = _song.notes[curSection - 1].mustHitSection;
				if ((note.rawNoteData - 4) >= keyAmmo[_song.mania])
					mustPress = !mustPress;
			case "below": 
				mustPress = _song.notes[curSection + 1].mustHitSection;
				if ((note.rawNoteData - 4) >= keyAmmo[_song.mania])
					mustPress = !mustPress;
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
		
		if (_song.mania == 2 || _song.mania == 5)
		{
			note.setGraphicSize(S_GRID_SIZE, GRID_SIZE);
			note.x = Math.floor(daNoteInfo * S_GRID_SIZE);
		}

		if (daSpeed != 1 && daSpeed != null)
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
			var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2),
				note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 16, 0, gridBG.height)));
			curRenderedSustains.add(sustainVis);
		}
	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			mania: _song.mania,
			changeBPM: false,
			changeMania: false,
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
			}
		}

		updateGrid();
		updateNoteUI();
	}

	function deleteNote(note:Note, daSection:SwagSection):Void
	{
		trace("ahhhhhhhhhhhhh");
		//i solved it hahahhahahahah
		//fuckjing strumtime are decimals ahghhhhhhhh
		var deleted:Bool = false;
		for (i in daSection.sectionNotes)
		{
			if (i[0] == note.strumTime && i[1] == (note.rawNoteData - 4))
			{
				trace("please delete the note i fucking hate this");
				FlxG.log.add('FOUND EVIL NUMBER');
				daSection.sectionNotes.remove(i);
				deleted = true;
			}
		}
		if (!deleted)
		{
			trace("fucking stupid fucking notes not being deleted");
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

		updateGrid();
	}

	function clearSection():Void
	{
		_song.notes[curSection].sectionNotes = [];

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
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime(curSection);
		var noteData = Math.floor(FlxG.mouse.x / GRID_SIZE);
			
		var noteSus = 0;
		var noteType = 0;
		noteType = Std.int(stepperNoteTypes.value);
		var noteSpeed:Float = 1;
		noteSpeed = stepperNoteSpeed.value;
		var noteVelocity:Array<Float> = [1, 0];
		noteVelocity = [stepperNoteVelocity.value, stepperNoteVelocityTime.value];

		if (_song.mania == 2 || _song.mania == 5)
			var noteData = Math.floor(FlxG.mouse.x / S_GRID_SIZE);

		noteData -= 4; //takes away for gf chart negative note data, i am doing it this way so charts dont need to be completely remade lol

		if (n != null)
			daSection.sectionNotes.push([n.strumTime, n.noteData, n.sustainLength, n.noteType, n.speed, n.velocityData]);
		else
			daSection.sectionNotes.push([noteStrum, noteData, noteSus, noteType, noteSpeed, noteVelocity]);

		var thingy = daSection.sectionNotes[daSection.sectionNotes.length - 1];
		curSelectedNote = thingy;

		if (FlxG.keys.pressed.CONTROL)
			daSection.sectionNotes.push([noteStrum, (noteData -18), noteSus, noteType, noteSpeed, noteVelocity]);

		trace(noteStrum);
		trace(curSection);

		updateGrid();
		updateNoteUI();

		autosaveSong();
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

	private function saveLevel()
	{
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json);

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
