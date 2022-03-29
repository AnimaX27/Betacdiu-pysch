package editors;

#if desktop
import Discord.DiscordClient;
#end
import animateatlas.AtlasFrameMaker;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.graphics.FlxGraphic;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import haxe.Json;
import Stage;
import flixel.system.debug.interaction.tools.Pointer.GraphicCursorCross;
import lime.system.Clipboard;
import flixel.animation.FlxAnimation;
import StageData;
import flixel.math.FlxPoint;
import flixel.util.FlxCollision;
import FunkinLua;
#if MODS_ALLOWED
import sys.FileSystem;
#end
using StringTools;


//So this is stolen from Mag Engine bruh but this time had better vereion
class StageEditorState extends MusicBeatState
{
    var stageGroup:FlxTypedGroup<FlxBasic>;
	var bfLayersGroup:FlxTypedGroup<FlxBasic>;
	var gfLayersGroup:FlxTypedGroup<FlxBasic>;
	var dadLayersGroup:FlxTypedGroup<FlxBasic>;
    public var modchartSpritesGroup:Array<ModchartSprite> = [];

    public var positions:Map<String,FlxPoint> = [
		"boyfriend"=> FlxPoint.get(770, 100),
		"dad"=> FlxPoint.get(100, 100),
		"gf"=> FlxPoint.get(400,130)
	];

    public var camera_position:Map<String,FlxPoint> = [
		"boyfriend"=> FlxPoint.get(0, 0),
		"dad"=> FlxPoint.get(0, 0),
		"gf"=> FlxPoint.get(0, 0),
	];

    //Stage Data
    var stageData:StageFile;
    

    //Character and Stage
    var stage:Stage;
    public var bf:Character;
    public var gf:Character;
    public var dad:Character;


	public var daBf:String;
	public var daGf:String;
	public var daDad:String;

    var charBF:String = 'bf';
    var charGF:String = 'gf';
    var charDad:String = 'dad';


    var gridBG:FlxSprite;
    var cameraFollowPointer:FlxSprite;

    var layerAdded:Bool = false;
    var noStage:Bool;
    var stageCounter:Int;
    var confirmAdded:Bool = false;

    var UI_box:FlxUITabMenu;
	var UI_stagebox:FlxUITabMenu;

    private var camEditor:FlxCamera;
	private var camHUD:FlxCamera;
	private var camMenu:FlxCamera;
    var camFollow:FlxObject;
    var goToPlayState:Bool = true;
    var daStage:String;
    var stageList:Array<String> = [];
    var characterList:Array<String> = [];
    var dumbTexts:FlxTypedGroup<FlxText>;
    var oldMousePosX:Int;
	var oldMousePosY:Int;

    var curChar:Character;
	var curCharIndex:Int = 0;
    var curAnim:Int = 0;
	var curCharString:String;
	var curChars:Array<Character>;

    //Stage Flies
    var cameraPositions:Array<FlxPoint>;
    var curCameraPosition:FlxPoint;
    var charsPosition:Array<FlxPoint>;
    var curCharPosition:FlxPoint;

    public static var instance:StageEditorState;

    public function new(daStage:String = 'sonicStage', goToPlayState:Bool = true)
    {
		super();
		this.daStage = daStage;
		this.goToPlayState = goToPlayState;
    }

    override function create()
    {
        instance = this;
        
        PlayState.instance.isEditor = true;
        stageGroup = new FlxTypedGroup<FlxBasic>();
		bfLayersGroup = new FlxTypedGroup<FlxBasic>();
		gfLayersGroup = new FlxTypedGroup<FlxBasic>();
		dadLayersGroup = new FlxTypedGroup<FlxBasic>();

        var pointer:FlxGraphic = FlxGraphic.fromClass(GraphicCursorCross);
		cameraFollowPointer = new FlxSprite().loadGraphic(pointer);
		cameraFollowPointer.setGraphicSize(40, 40);
		cameraFollowPointer.updateHitbox();
		cameraFollowPointer.color = FlxColor.WHITE;
		add(cameraFollowPointer);

        noStage = true;

		camEditor = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camMenu = new FlxCamera();
		camMenu.bgColor.alpha = 0;

		FlxG.cameras.reset(camEditor);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camMenu);
		FlxCamera.defaultCameras = [camEditor];

        gridBG = FlxGridOverlay.create(25, 25);
        add(gridBG);

        loadStage();
        reloadStageOptions();

        add(stageGroup);

		// Characters
		gf = new Character(400, 130, charGF);
		startCharacterPos(gf);
        add(gf);
        add(gfLayersGroup);

        dad = new Character(100, 100, charDad);
        startCharacterPos(dad);
        add(dad);
        add(dadLayersGroup);

		bf = new Character(770, 100, charBF, true);
        startCharacterPos(bf);
        add(bf);
        add(bfLayersGroup);

        curChars = [dad, bf, gf];
		curChar = curChars[curCharIndex];

        charsPosition = [positions.get('dad'), positions.get('boyfriend'), positions.get('gf')];
        curCharPosition = charsPosition[curCharIndex];

        cameraPositions = [camera_position.get('dad'), camera_position.get('boyfriend'), camera_position.get('gf')];
        curCameraPosition = cameraPositions[curCharIndex];

		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);
		dumbTexts.cameras = [camHUD];
        genBoyPos();

        camFollow = new FlxObject(0, 0, 2, 2);
        camFollow.screenCenter();
        add(camFollow);

        var tipText:FlxText = new FlxText(FlxG.width - 20, FlxG.height, 0,
            "E/Q - Camera Zoom In/Out
            \nEnter - Next Character
            \nR - Reset Current Zoom", 12);
        tipText.cameras = [camMenu];
        tipText.setFormat(null, 12, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        tipText.scrollFactor.set();
        tipText.borderSize = 1;
        tipText.screenCenter(Y);
        tipText.x -= tipText.width;
        tipText.y -= tipText.height - 10;
        add(tipText);
    

        FlxG.camera.follow(camFollow);

        var tabs = [
            {name: 'Settings', label: 'Settings'},
        ];

        UI_box = new FlxUITabMenu(null, tabs, true);
        UI_box.cameras = [camMenu];
        UI_box.resize(250, 120);
        UI_box.x = FlxG.width - 275;
        UI_box.y = 25;
        UI_box.scrollFactor.set();

        var tabs = [
            {name: 'Stage', label: 'Stage'},
            /*{name: 'Stage Settings', label: 'Stage Settings'}*/
        ];

        UI_stagebox = new FlxUITabMenu(null, tabs, true);
        UI_stagebox.cameras = [camMenu];
        UI_stagebox.resize(350, 350);
        UI_stagebox.x = UI_box.x - 100;
        UI_stagebox.y = UI_box.y + UI_box.height;
        UI_stagebox.scrollFactor.set();
        add(UI_stagebox);
        add(UI_box);

        addSettingsUI();
        addStageUI();
        /*addSettingsStageUI();*/

        Conductor.changeBPM(150);
        FlxG.sound.playMusic(Paths.music('breakfast'), 1, true);

        FlxG.mouse.visible = true;
    }

    function startCharacterPos(character:Character) {
        character.x += character.positionArray[0];
		character.y += character.positionArray[1];
    }

    var stageDropDown:FlxUIDropDownMenuCustom;
    var stageNameInputText:FlxUIInputText;
    var check_isPixelStage:FlxUICheckBox;
    var check_isTypingMode:FlxUICheckBox;
    function addSettingsUI() {
        var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Settings";

        check_isPixelStage = new FlxUICheckBox(10, 60, null, null, "Pixel Stage", 100);
		check_isPixelStage.checked = stageData.isPixelStage;
		check_isPixelStage.callback = function()
		{
			stageData.isPixelStage = !stageData.isPixelStage;
		};

        stageDropDown = new FlxUIDropDownMenuCustom(10, 30, FlxUIDropDownMenuCustom.makeStrIdLabelArray([''], true), function(stage:String)
        {
            daStage = stageList[Std.parseInt(stage)];
            loadStage();
            updatePresence();
            reloadStageDropDown();
        });
        stageDropDown.selectedLabel = daStage;
        reloadStageDropDown();

        var reloadStage:FlxButton = new FlxButton(140, 20, "Reload Stage", function()
        {
            loadStage();
            reloadStageDropDown();
        });

        tab_group.add(new FlxText(stageDropDown.x, stageDropDown.y - 18, 0, 'Stage:'));
		tab_group.add(check_isPixelStage);
		tab_group.add(reloadStage);
		tab_group.add(stageDropDown);
		UI_box.addGroup(tab_group);
    }

    var nameInputText:FlxUIInputText;
    var cameraZoomStepper:FlxUINumericStepper;
    var zoominputtext:FlxUIInputText;
	var positionCameraXStepper:FlxUINumericStepper;
	var positionCameraYStepper:FlxUINumericStepper;
    var positionXStepper:FlxUINumericStepper;
	var positionYStepper:FlxUINumericStepper;
    var cameraSpeedStepper:FlxUINumericStepper;
    var check_hiddenGF:FlxUICheckBox;
    function addStageUI() {
        var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Stage";

        var saveStuff:FlxButton = new FlxButton(240, 20, "Save Stage", function() {
            saveStage();
        });

        cameraZoomStepper = new FlxUINumericStepper(15, saveStuff.y + 20, 0.1, 1, 0, 1.05, 1);

        nameInputText = new FlxUIInputText(15, cameraZoomStepper.y + 30, 200, "", 8);

        var reloadStage:FlxButton = new FlxButton(140, nameInputText.y + 40, "Reload Stage by Input Texts", function()
        {
            daStage = nameInputText.text;
            loadStage();
            reloadStageDropDown();
        });

        positionXStepper = new FlxUINumericStepper(15, reloadStage.y + 50, 10, curCharPosition.x, -9000, 9000, 0);
		positionYStepper = new FlxUINumericStepper(positionXStepper.x + 60, positionXStepper.y, 10, curCharPosition.y, -9000, 9000, 0);

        positionCameraXStepper = new FlxUINumericStepper(positionXStepper.x, positionXStepper.y + 40, 10, curCameraPosition.x, -9000, 9000, 0);
		positionCameraYStepper = new FlxUINumericStepper(positionYStepper.x, positionYStepper.y + 40, 10, curCameraPosition.y, -9000, 9000, 0);

        cameraSpeedStepper = new FlxUINumericStepper(15, positionCameraYStepper.y + 50, 1, curCameraPosition.x, 0, 9000, 0);

        check_hiddenGF = new FlxUICheckBox(15, cameraSpeedStepper.y + 60, null, null, "Hide GF", 100);
		check_hiddenGF.checked = !gf.visible;
        if(stageData.hide_girlfriend) check_hiddenGF.checked = !check_hiddenGF.checked;
		check_hiddenGF.callback = function()
		{
			stageData.hide_girlfriend = !stageData.hide_girlfriend;
            gf.visible = !gf.visible;
		};

        tab_group.add(nameInputText);
        tab_group.add(reloadStage);
        tab_group.add(saveStuff);
        tab_group.add(cameraZoomStepper);
        tab_group.add(positionXStepper);
        tab_group.add(positionYStepper);
        tab_group.add(positionCameraXStepper);
        tab_group.add(positionCameraYStepper);
        tab_group.add(cameraSpeedStepper);
        tab_group.add(check_hiddenGF);
        tab_group.add(new FlxText(15, cameraZoomStepper.y - 18, 0, 'Default Cam Zoom:'));
        tab_group.add(new FlxText(15, nameInputText.y - 18, 0, 'Stage Name:'));
        tab_group.add(new FlxText(positionXStepper.x, positionXStepper.y - 18, 0, 'Position Character X/Y:'));
        tab_group.add(new FlxText(positionCameraXStepper.x, positionCameraXStepper.y - 18, 0, 'Character Camera X/Y:'));
        tab_group.add(new FlxText(cameraSpeedStepper.x, cameraSpeedStepper.y - 18, 0, 'Camera Speed:'));
        UI_stagebox.addGroup(tab_group);
    }


    function updatePresence() {
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Stage Editor", "Stage: " + daStage);
		#end        
    }


    function loadStage() {
        var f:Int = modchartSpritesGroup.length-1;
		while(f >= 0){
			var memb:ModchartSprite = modchartSpritesGroup[f];
			if(memb != null) {
				memb.kill();
				modchartSpritesGroup.remove(memb);
				memb.destroy();
			}
			--f;
		}

        var i:Int = stageGroup.members.length-1;
		while(i >= 0) {
			var memb:FlxBasic = stageGroup.members[i];
			if(memb != null) {
				memb.kill();
				stageGroup.remove(memb);
				memb.destroy();
			}
			--i;
		}

        var g:Int = gfLayersGroup.members.length-1;
        while(g >= 0) {
			var memb:FlxBasic = gfLayersGroup.members[i];
			if(memb != null) {
				memb.kill();
				gfLayersGroup.remove(memb);
				memb.destroy();
			}
			--g;
		}

        var d:Int = dadLayersGroup.members.length-1;
        while(d >= 0) {
			var memb:FlxBasic = dadLayersGroup.members[i];
			if(memb != null) {
				memb.kill();
				dadLayersGroup.remove(memb);
				memb.destroy();
			}
			--d;
		}

        var b:Int = bfLayersGroup.members.length-1;
        while(b >= 0) {
			var memb:FlxBasic = bfLayersGroup.members[i];
			if(memb != null) {
				memb.kill();
				bfLayersGroup.remove(memb);
				memb.destroy();
			}
			--b;
		}

        stageGroup.clear();
        gfLayersGroup.clear();
		dadLayersGroup.clear();
		bfLayersGroup.clear();

        stageData = StageData.getStageFile(daStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,
			
				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,
			
				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};
		}

        stage = new Stage(daStage);
        stageGroup.add(stage);
        gfLayersGroup.add(stage.layers.get("gf"));
		dadLayersGroup.add(stage.layers.get("dad"));
		bfLayersGroup.add(stage.layers.get("boyfriend"));

        reloadStageOptions();
    }

    override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
    {
        if(id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper)) {
            if(sender == cameraZoomStepper)
            {
                FlxG.camera.zoom = sender.value;
            }
            else if(sender == positionXStepper)
            {
                curChar.x = sender.value;
                curChar.x += curChar.positionArray[0];
                curCharPosition.x = sender.value;
                genBoyPos();
            }
            else if(sender == positionYStepper)
            {
                curChar.y = sender.value;
                curChar.y += curChar.positionArray[1];
                curCharPosition.y = sender.value;
                genBoyPos();
            }
            else if(sender == positionCameraXStepper)
            {
                var x:Float = curChar.getMidpoint().x;
                curCameraPosition.x = sender.value;
                camFollow.x = x + curChar.cameraPosition[0] + sender.value;
                genBoyPos();
            }
            else if(sender == positionCameraYStepper)
            {
                var y:Float = curChar.getMidpoint().y;
                curCameraPosition.y = sender.value;
                camFollow.y = y + curChar.cameraPosition[1] + sender.value;
                genBoyPos();
            }
        }
    }

    /*function updatePointerPos() {
        //I don't GET THIS IS THING WON'T WORK
		var x:Float = curChar.getMidpoint().x;
		var y:Float = curChar.getMidpoint().y;
        x = curChar.cameraPosition[0] + curCameraPosition.x;
		y = curChar.cameraPosition[1] + curCameraPosition.y;

		x -= cameraFollowPointer.width / 2;
		y -= cameraFollowPointer.height / 2;
		cameraFollowPointer.setPosition(x, y);
	}*/

    function genBoyPos()
    {
        var i:Int = dumbTexts.members.length-1;
		while(i >= 0) {
			var memb:FlxText = dumbTexts.members[i];
			if(memb != null) {
				memb.kill();
				dumbTexts.remove(memb);
				memb.destroy();
			}
			--i;
		}
		dumbTexts.clear();

        for (i in 0...12)
        {
            var text:FlxText = new FlxText(10, 48 + (i * 30), 0, '', 24);
            text.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            text.scrollFactor.set();
            text.borderSize = 2;
            dumbTexts.add(text);
            text.cameras = [camHUD];

            if(i > 1)
            {
                text.y += 24;
            }
        }

        for (i in 0...dumbTexts.length)
        {
            switch(i)
            {
                case 0: dumbTexts.members[i].text = 'Boyfriend Positions:';
                case 1: dumbTexts.members[i].text = '[' + bf.x + ', ' + bf.y + ']';
                case 2: dumbTexts.members[i].text = 'GirlFriend Positions:';
                case 3: dumbTexts.members[i].text = '[' + gf.x + ', ' + gf.y + ']';
                case 4: dumbTexts.members[i].text = 'Opponent Positions:';
                case 5: dumbTexts.members[i].text = '[' + dad.x + ', ' + dad.y + ']';
                case 6: dumbTexts.members[i].text = 'Boyfriend Camera Positions:';
                case 7: dumbTexts.members[i].text = '[' + camera_position.get("boyfriend").x  + ', ' +  camera_position.get("boyfriend").y  + ']';
                case 8: dumbTexts.members[i].text = 'Girlfriend Camera Positions:';
                case 9: dumbTexts.members[i].text = '[' + camera_position.get("gf").x  + ', ' +  camera_position.get("gf").y  + ']';
                case 10: dumbTexts.members[i].text = 'Opponent Camera Positions:';
                case 11: dumbTexts.members[i].text = '[' + camera_position.get("dad").x + ', ' +  camera_position.get("dad").y + ']';
            }
        }
    }

    function getNextChar()
    {
		++curCharIndex;
		if (curCharIndex >= curChars.length && curCharIndex >= charsPosition.length)
        {
            curChar = curChars[0];
            curCharPosition = charsPosition[0];
            curCameraPosition = cameraPositions[0];
            curCharIndex = 0;
        }
        else
            curChar = curChars[curCharIndex];
            curCharPosition = charsPosition[curCharIndex];
            curCameraPosition = cameraPositions[curCharIndex];
    }

    function reloadCharacterDropDown(customDropDown:FlxUIDropDownMenuCustom, daChar:String) {
		var charsLoaded:Map<String, Bool> = new Map();

		#if MODS_ALLOWED
		characterList = [];
		var directories:Array<String> = [Paths.mods('characters/'), Paths.mods(Paths.currentModDirectory + '/characters/'), Paths.getPreloadPath('characters/')];
		for (i in 0...directories.length) {
			var directory:String = directories[i];
			if(FileSystem.exists(directory)) {
				for (file in FileSystem.readDirectory(directory)) {
					var path = haxe.io.Path.join([directory, file]);
					if (!sys.FileSystem.isDirectory(path) && file.endsWith('.json')) {
						var charToCheck:String = file.substr(0, file.length - 5);
						if(!charsLoaded.exists(charToCheck)) {
							characterList.push(charToCheck);
							charsLoaded.set(charToCheck, true);
						}
					}
				}
			}
		}
		#else
		characterList = CoolUtil.coolTextFile(Paths.txt('characterList'));
		#end

		customDropDown.setData(FlxUIDropDownMenuCustom.makeStrIdLabelArray(characterList, true));
		customDropDown.selectedLabel = daChar;        
    }

    function reloadStageDropDown() 
    {
        var stagesLoaded:Map<String, Bool> = new Map();
    
        #if MODS_ALLOWED
        stageList = [];
        var directories:Array<String> = [Paths.mods('stages/'), Paths.mods(Paths.currentModDirectory + '/stages/'), Paths.getPreloadPath('stages/')];
        for (i in 0...directories.length) {
            var directory:String = directories[i];
            if(FileSystem.exists(directory)) {
                for (file in FileSystem.readDirectory(directory)) {
                    var path = haxe.io.Path.join([directory, file]);
                    if (!sys.FileSystem.isDirectory(path) && file.endsWith('.json')) {
                        var charToCheck:String = file.substr(0, file.length - 5);
                        if(!stagesLoaded.exists(charToCheck)) {
                            stageList.push(charToCheck);
                            stagesLoaded.set(charToCheck, true);
                        }
                    }
                }
            }
        }
        #else
        stageList = CoolUtil.coolTextFile(Paths.txt('stageList'));
        #end

        stageDropDown.setData(FlxUIDropDownMenuCustom.makeStrIdLabelArray(stageList, true));
        stageDropDown.selectedLabel = daStage;        
    }

    var colorSine:Float = 0;
    override function update(elapsed:Float) {
        super.update(elapsed);

        PlayState.instance.callOnLuas('onUpdate', [elapsed]);

        if (FlxG.keys.justPressed.ENTER)
        {
            getNextChar();
        }
        
        var inputTexts:Array<FlxUIInputText> = [nameInputText];
        for (i in 0...inputTexts.length) {
			if(inputTexts[i].hasFocus) {
				if(FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.V) { //Copy paste
					inputTexts[i].text = ClipboardAdd(inputTexts[i].text);
					inputTexts[i].caretIndex = inputTexts[i].text.length;
					getEvent(FlxUIInputText.CHANGE_EVENT, inputTexts[i], null, []);
				}
				if(FlxG.keys.justPressed.ENTER) {
					inputTexts[i].hasFocus = false;
				}
				FlxG.sound.muteKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.volumeUpKeys = [];
				super.update(elapsed);
				return;
			}
		}

        colorSine += elapsed;
        var colorVal:Float = 0.7 + Math.sin(Math.PI * colorSine) * 0.3;
        curChar.color = FlxColor.fromRGBFloat(colorVal, colorVal, colorVal, 0.999); //Alpha can't be 100% or the color won't be updated for some reason, guess i will die
       

        var controlArray:Array<Bool> = [FlxG.keys.justPressed.LEFT, FlxG.keys.justPressed.RIGHT, FlxG.keys.justPressed.UP, FlxG.keys.justPressed.DOWN];

        stage.update(elapsed);

        if(!stageDropDown.dropPanel.visible) {
            if (FlxG.keys.justPressed.R) {
                FlxG.camera.zoom = 0.9;
                bf.setPosition(770, 100);
                startCharacterPos(bf);

                dad.setPosition(100, 100);
                startCharacterPos(dad);

                gf.setPosition(400, 130);
                startCharacterPos(gf);
             }
             if (FlxG.keys.pressed.E && FlxG.camera.zoom < 3) {
                FlxG.camera.zoom += elapsed * FlxG.camera.zoom;
                if(FlxG.camera.zoom > 3) FlxG.camera.zoom = 3;
            }
            if (FlxG.keys.pressed.Q && FlxG.camera.zoom > 0.1) {
                FlxG.camera.zoom -= elapsed * FlxG.camera.zoom;
                if(FlxG.camera.zoom < 0.1) FlxG.camera.zoom = 0.1;
            } 

            if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L)
            {
                var addToCam:Float = 500 * elapsed;
                if (FlxG.keys.pressed.SHIFT)
                    addToCam *= 4;

                if (FlxG.keys.pressed.I)
                    camFollow.y -= addToCam;
                else if (FlxG.keys.pressed.K)
                    camFollow.y += addToCam;

                if (FlxG.keys.pressed.J)
                    camFollow.x -= addToCam;
                else if (FlxG.keys.pressed.L)
                    camFollow.x += addToCam;
            }
            camMenu.zoom = FlxG.camera.zoom;
            if (FlxG.keys.justPressed.ESCAPE) {
                if(goToPlayState) {
                    MusicBeatState.switchState(new PlayState());
                } else {
                    MusicBeatState.switchState(new editors.MasterEditorMenu());
                    FlxG.sound.playMusic(Paths.music('freakyMenu'));
                }
                FlxG.mouse.visible = false;
                return; 
            }
        }

        Conductor.songPosition = FlxG.sound.music.time;
    }

    function reloadStageOptions() {
		if(UI_stagebox != null) {
			cameraZoomStepper.value = stageData.defaultZoom;
			check_isPixelStage.checked = stageData.isPixelStage;

            bf.x = stageData.boyfriend[0];
            bf.y = stageData.boyfriend[1];
            startCharacterPos(bf);
            
            dad.x = stageData.opponent[0];
            dad.y = stageData.opponent[1];
            startCharacterPos(dad);

            gf.x = stageData.girlfriend[0];
            gf.y = stageData.girlfriend[1];
            startCharacterPos(gf);
            genBoyPos();
			updatePresence();
		}
	}

    function updateMousePos()
    {
        oldMousePosX = FlxG.mouse.x;
        oldMousePosY = FlxG.mouse.y;
        startCharacterPos(curChar);
    }

    var lastStepHit:Int = -1;
    override function stepHit()
    {
        super.stepHit();
        if(curStep == lastStepHit) {
            return;
        }
    
        stage.stepHit(curStep);
    
        lastStepHit = curStep;
        PlayState.instance.setOnLuas('curStep', curStep);
        PlayState.instance.callOnLuas('onStepHit', []);
    }

    var lastBeatHit:Int = -1;
    override public function beatHit()
    {
        super.beatHit();
        PlayState.instance.setOnLuas('curBeat', curBeat);//DAWGG?????
		PlayState.instance.callOnLuas('onBeatHit', []);

        if(lastBeatHit == curBeat)
        {
            return;
        }

        if(curBeat % 2 == 0)
        {
            stage.beatHit(curBeat);
            bf.dance();
            gf.dance();
            dad.dance();
        }

        lastBeatHit = curBeat;
    }

    var _file:FileReference;

    function onSaveComplete(_):Void
    {
        _file.removeEventListener(Event.COMPLETE, onSaveComplete);
        _file.removeEventListener(Event.CANCEL, onSaveCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _file = null;
        FlxG.log.notice("Successfully saved file.");            
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
        FlxG.log.error("Problem saving file"); 
    }
    
    function saveStage() {
        var json = {
            "directory": null,
            "defaultZoom": cameraZoomStepper.value,
            "isPixelStage": check_isPixelStage.checked,
        
            "boyfriend": [positions.get('boyfriend').x, positions.get('boyfriend').y],
            "girlfriend": [positions.get('gf').x, positions.get('gf').y],
            "opponent": [positions.get('dad').x, positions.get('dad').y],
            "hide_girlfriend": check_hiddenGF.checked,

            "camera_boyfriend":[camera_position.get('boyfriend').x, camera_position.get('boyfriend').y],
            "camera_opponent": [camera_position.get('dad').x, camera_position.get('dad').y],
            "camera_girlfriend": [camera_position.get('gf').x, camera_position.get('gf').y],
            "camera_speed": cameraSpeedStepper.value,
        };

        var data:String = Json.stringify(json, "\t");
    
        if (data.length > 0)
        {
            _file = new FileReference();
            _file.addEventListener(Event.COMPLETE, onSaveComplete);
            _file.addEventListener(Event.CANCEL, onSaveCancel);
            _file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
            _file.save(data, daStage + ".json");
        }
    }

    function ClipboardAdd(prefix:String = ''):String {
		if(prefix.toLowerCase().contains('v') || prefix.toLowerCase().contains('null')) //probably copy paste attempt
		{
			prefix = prefix.substring(0, prefix.length-1);
		}

		var text:String = prefix + Clipboard.text.replace('\n', '');
		return text;
	}
}