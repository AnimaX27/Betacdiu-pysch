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
#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

//So this is stolen from Mag Engine bruh but this time had better vereion
class StageOffsetState extends MusicBeatState {
    var stageGroup:FlxTypedGroup<FlxBasic>;
	var bfLayersGroup:FlxTypedGroup<FlxBasic>;
	var gfLayersGroup:FlxTypedGroup<FlxBasic>;
	var dadLayersGroup:FlxTypedGroup<FlxBasic>;


    public var positions:Map<String,FlxPoint> = [
		"boyfriend"=> FlxPoint.get(770, 100),
		"dad"=> FlxPoint.get(100, 100),
		"gf"=> FlxPoint.get(400,130)
	];

    //Stage Data
    var stageData:StageFile;
    var boyfriend:Array<Dynamic>;
	var girlfriend:Array<Dynamic>;
	var opponent:Array<Dynamic>;

    //Character and Stage
    var stage:Stage;
    var bf:Character;
    var gf:Character;
    var dad:Character;


	public var daBf:String;
	public var daGf:String;
	public var daDad:String;


    var gridBG:FlxSprite;
    var shouldStayIn:FlxSprite;
    var createdLayer:FlxSprite = new FlxSprite();

    var layerAdded:Bool = false;
    var noStage:Bool;
    var stageCounter:Int;
    var confirmAdded:Bool = false;
    var animationsArray:Array<AnimationArray> = [];


    var UI_box:FlxUITabMenu;
	var UI_stagebox:FlxUITabMenu;
    var layers:LayerFile;

    private var camEditor:FlxCamera;
	private var camHUD:FlxCamera;
	private var camMenu:FlxCamera;
    var camFollow:FlxObject;
    var goToPlayState:Bool = true;
    var daStage:String;
    var stageList:Array<String> = [];
    var dumbTexts:FlxTypedGroup<FlxText>;
    var oldMousePosX:Int;
	var oldMousePosY:Int;

    var curChar:FlxSprite;
	var curCharIndex:Int = 0;
    var curAnim:Int = 0;
	var curCharString:String;
	var curChars:Array<FlxSprite>;
    var dragging:Bool = false;

    public function new(daStage:String = 'stage', ?daGf:String = 'gf', ?daBf:String = 'bf', daDad:String = 'dad', goToPlayState:Bool = true)
    {
		super();
		this.daStage = daStage;
        this.daGf = daGf;
        this.daBf = daBf;
        this.daDad = daDad;
		this.goToPlayState = goToPlayState;
        curCharString = daGf;
    }

    override function create()
    {

        stageGroup = new FlxTypedGroup<FlxBasic>();
		bfLayersGroup = new FlxTypedGroup<FlxBasic>();
		gfLayersGroup = new FlxTypedGroup<FlxBasic>();
		dadLayersGroup = new FlxTypedGroup<FlxBasic>();

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
		gf = new Character(400, 130, 'gf');
		startCharacterPos(gf);
		gf.scrollFactor.set(0.95, 0.95);
        add(gf);
        add(gfLayersGroup);

        dad = new Character(100, 100, 'dad');
        startCharacterPos(dad);
		add(dad);
        add(dadLayersGroup);

		bf = new Character(770, 100, 'bf', true);
        startCharacterPos(bf);
		add(bf);
        add(bfLayersGroup);

        curChars = [dad, bf, gf];
		curChar = curChars[curCharIndex];

		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);
		dumbTexts.cameras = [camHUD];
        createTexts();

        camFollow = new FlxObject(0, 0, 2, 2);
        camFollow.screenCenter();
        add(camFollow);

        var tipText:FlxText = new FlxText(FlxG.width - 20, FlxG.height, 0,
            "E/Q - Camera Zoom In/Out
            \nClick and Drag - Character Positions
            \nEnter - Set Character Positions
            \nR - Reset Current Zoom", 12);
        tipText.cameras = [camHUD];
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
            /*{name: 'Layers', label: 'layers'},
            {name: 'Animations', label: 'Animations'},*/
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
        /*addLayersUI();
        addAnimationUI();*/

        Conductor.changeBPM(150);
        FlxG.sound.playMusic(Paths.music('breakfast'), 1, true);

        FlxG.mouse.visible = true;
    }

    function startCharacterPos(character:Character) {
        character.x += character.positionArray[0];
		character.y += character.positionArray[1];
    }

    var stageDropDown:FlxUIDropDownMenuCustom;
    var check_isPixelStage:FlxUICheckBox;
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
    function addStageUI() {
        var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Stage";

        var saveStuff:FlxButton = new FlxButton(240, 20, "Save Stage", function() {
            saveStage(stageData);
        });

        cameraZoomStepper = new FlxUINumericStepper(15, saveStuff.y + 20, 0.1, 1, 0, 1.05, 1);

        nameInputText = new FlxUIInputText(15, cameraZoomStepper.y + 30, 200, "", 8);

        tab_group.add(nameInputText);
        tab_group.add(saveStuff);
        tab_group.add(cameraZoomStepper);
        tab_group.add(new FlxText(15, cameraZoomStepper.y - 18, 0, 'Default Cam Zoom:'));
        tab_group.add(new FlxText(15, nameInputText.y - 18, 0, 'Stage Name:'));
        UI_stagebox.addGroup(tab_group);
    }

	var animationDropDown:FlxUIDropDownMenuCustom;
	var animationInputText:FlxUIInputText;
	var animationNameInputText:FlxUIInputText;
	var animationIndicesInputText:FlxUIInputText;
	var animationNameFramerate:FlxUINumericStepper;
	var animationLoopCheckBox:FlxUICheckBox;

    /*function addAnimationUI() {
 		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Animations";
		
		animationInputText = new FlxUIInputText(15, 85, 80, '', 8);
		animationNameInputText = new FlxUIInputText(animationInputText.x, animationInputText.y + 35, 150, '', 8);
		animationIndicesInputText = new FlxUIInputText(animationNameInputText.x, animationNameInputText.y + 40, 250, '', 8);
		animationNameFramerate = new FlxUINumericStepper(animationInputText.x + 170, animationInputText.y, 1, 24, 0, 240, 0);
		animationLoopCheckBox = new FlxUICheckBox(animationNameInputText.x + 170, animationNameInputText.y - 1, null, null, "Should it Loop?", 100);

		animationDropDown = new FlxUIDropDownMenuCustom(15, animationInputText.y - 55, FlxUIDropDownMenuCustom.makeStrIdLabelArray([''], true), function(pressed:String) {
			var selectedAnimation:Int = Std.parseInt(pressed);
			var anim:AnimationArray = stage.animationsArray[selectedAnimation];
			animationInputText.text = anim.anim;
			animationNameInputText.text = anim.name;
			animationLoopCheckBox.checked = anim.loop;
			animationNameFramerate.value = anim.fps;

			var indicesStr:String = anim.indices.toString();
			animationIndicesInputText.text = indicesStr.substr(1, indicesStr.length - 2);
		});

		var addUpdateButton:FlxButton = new FlxButton(70, animationIndicesInputText.y + 30, "Add/Update", function() {
			var indices:Array<Int> = [];
			var indicesStr:Array<String> = animationIndicesInputText.text.trim().split(',');
			if(indicesStr.length > 1) {
				for (i in 0...indicesStr.length) {
					var index:Int = Std.parseInt(indicesStr[i]);
					if(indicesStr[i] != null && indicesStr[i] != '' && !Math.isNaN(index) && index > -1) {
						indices.push(index);
					}
				}
			}

			var lastAnim:String = '';
			if(stage.animationsArray[curAnim] != null) {
				lastAnim = stage.animationsArray[curAnim].anim;
			}

			var lastOffsets:Array<Int> = [0, 0];
			var idk:Array<Int> = [0, 0];
			for (anim in stage.animationsArray) {
				if(animationInputText.text == anim.anim) {
					if(createdLayer.animation.getByName(animationInputText.text) != null) {
						createdLayer.animation.remove(animationInputText.text);
					}
					stage.animationsArray.remove(anim);
				}
			}

			var newAnim:AnimationArray = {
				anim: animationInputText.text,
				name: animationNameInputText.text,
				fps: Math.round(animationNameFramerate.value),
				loop: animationLoopCheckBox.checked,
				indices: indices,
			};
			if(indices != null && indices.length > 0) {
				createdLayer.animation.addByIndices(newAnim.anim, newAnim.name, newAnim.indices, "", newAnim.fps, newAnim.loop);
			} else {
				createdLayer.animation.addByPrefix(newAnim.anim, newAnim.name, newAnim.fps, newAnim.loop);
			}

			stage.animationsArray.push(newAnim);

			if(lastAnim == animationInputText.text) {
				var leAnim:FlxAnimation = createdLayer.animation.getByName(lastAnim);
				if(leAnim != null && leAnim.frames.length > 0) {
					createdLayer.animation.play(lastAnim, true);
				} else {
					for(i in 0...stage.animationsArray.length) {
						if(stage.animationsArray[i] != null) {
							leAnim = createdLayer.animation.getByName(stage.animationsArray[i].anim);
							if(leAnim != null && leAnim.frames.length > 0) {
                                createdLayer.animation.play(stage.animationsArray[i].anim, true);
								curAnim = i;
								break;
							}
						}
					}
				}
			}

			reloadAnimationDropDown();
			trace('Added/Updated animation: ' + animationInputText.text);
		});

		var removeButton:FlxButton = new FlxButton(180, animationIndicesInputText.y + 30, "Remove", function() {
			for (anim in stage.animationsArray) {
				if(animationInputText.text == anim.anim) {
					var resetAnim:Bool = false;
					if(createdLayer.animation.curAnim != null && anim.anim == createdLayer.animation.curAnim.name) resetAnim = true;

					if(createdLayer.animation.getByName(anim.anim) != null) {
						createdLayer.animation.remove(anim.anim);
					}
					stage.animationsArray.remove(anim);

					if(resetAnim && stage.animationsArray.length > 0) {
						createdLayer.animation.play(stage.animationsArray[0].anim, true);
					}
					reloadAnimationDropDown();
					trace('Removed animation: ' + animationInputText.text);
					break;
				}
			}
		});

		tab_group.add(new FlxText(animationDropDown.x, animationDropDown.y - 18, 0, 'Animations:'));
		tab_group.add(new FlxText(animationInputText.x, animationInputText.y - 18, 0, 'Animation name:'));
		tab_group.add(new FlxText(animationNameFramerate.x, animationNameFramerate.y - 18, 0, 'Framerate:'));
		tab_group.add(new FlxText(animationNameInputText.x, animationNameInputText.y - 18, 0, 'Animation on .XML/.TXT file:'));
		tab_group.add(new FlxText(animationIndicesInputText.x, animationIndicesInputText.y - 18, 0, 'Animation Indices:'));

		tab_group.add(animationInputText);
		tab_group.add(animationNameInputText);
		tab_group.add(animationIndicesInputText);
		tab_group.add(animationNameFramerate);
		tab_group.add(animationLoopCheckBox);
		tab_group.add(addUpdateButton);
		tab_group.add(removeButton);
		tab_group.add(animationDropDown);
		UI_stagebox.addGroup(tab_group);       
    }*/

    var scrollFactorXStepper:FlxUINumericStepper;
    var scrollFactorYStepper:FlxUINumericStepper;

    var positionXStepper:FlxUINumericStepper;
	var positionYStepper:FlxUINumericStepper;

    var flipXCheckBox:FlxUICheckBox;
	var noAntialiasingCheckBox:FlxUICheckBox;
    var imageInputText:FlxUIInputText;
    var nameLayerInputText:FlxUIInputText;
    var scaleStepper:FlxUINumericStepper;

    function addLayersUI() {
        var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Layers";

        nameLayerInputText = new FlxUIInputText(15, 50, 200, "", 8);
        imageInputText = new FlxUIInputText(15, nameInputText.y + 50, 200, "", 8);
        positionXStepper = new FlxUINumericStepper(15, imageInputText.y + 50, 10, 0, -9000, 9000, 0);
        positionYStepper = new FlxUINumericStepper(positionXStepper.x + 60, positionXStepper.y, 10, 0, -9000, 9000, 0);

        scrollFactorXStepper = new FlxUINumericStepper(positionXStepper.x, positionXStepper.y + 40, 0.1, 0, -9000, 9000, 0);
		scrollFactorYStepper = new FlxUINumericStepper(positionYStepper.x, positionYStepper.y + 40, 0.1, 0, -9000, 9000, 0);

        flipXCheckBox = new FlxUICheckBox(15, scrollFactorYStepper.y + 50, null, null, "Flip X", 50);

        noAntialiasingCheckBox = new FlxUICheckBox(flipXCheckBox.x, flipXCheckBox.y + 40, null, null, "No Antialiasing", 80);

        scaleStepper = new FlxUINumericStepper(15, noAntialiasingCheckBox.y + 40, 0.1, 1, 0.05, 10, 1);

        var addLayer:FlxButton = new FlxButton(imageInputText.x + 210, imageInputText.y - 3, "Add Layer", function()
        {
			noStage = false;
			layerAdded = true;
			stageCounter + 1;
			var stageSwag:LayerFile = {
				name: nameLayerInputText.text,
				image: imageInputText.text,
				position: [positionXStepper.value, positionYStepper.value],
				scrollFactor: [scrollFactorXStepper.value, scrollFactorYStepper.value],
				scale: scaleStepper.value,
                flipX: flipXCheckBox.checked,
                animations: animationsArray
			};
			createdLayer = new FlxSprite();
			stageGroup.add(createdLayer);
			if (layerAdded)
			{
				stageData.layers.push(stageSwag);
			}
			// we need to make sure the created layer exists before being able to scale it or we'll experience a crash
			if (stageData.layers.contains(stageSwag))
			{
				for (cool in stageData.layers)
				{
					if (cool.image != "")
					{
						confirmAdded = true;
					}
				}
			}
        });

        var removeLayer:FlxButton = new FlxButton(addLayer.x, addLayer.y + 40, "Remove Layer", function()
        {
			if (!noStage)
            {
                var stageSwag:LayerFile = {
                    name: nameLayerInputText.text,
                    image: imageInputText.text,
                    position: [positionXStepper.value, positionYStepper.value],
                    scrollFactor: [scrollFactorXStepper.value, scrollFactorYStepper.value],
                    scale: scaleStepper.value,
                    flipX: flipXCheckBox.checked,
                    animations: animationsArray
                };
                stageGroup.remove(createdLayer);
                if (stageData.layers.contains(stageSwag))
                {
                    stageGroup.remove(createdLayer);
                    stageData.layers.remove(stageSwag);
                }
            }
        });
    }
    

    function updatePresence() {
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Stage Editor", "Stage: " + daStage);
		#end        
    }

    /*function reloadStageImage()
    {
		var lastAnim:String = '';
        var isAnimated:Bool = false;
		if(createdLayer.animation.curAnim != null && isAnimated) {
			lastAnim = createdLayer.animation.curAnim.name;
		}
		var anims:Array<AnimationArray> = stage.animationsArray.copy();
		if(Paths.fileExists('images/' + stage.imageFile + '/Animation.json', TEXT)) {
            isAnimated = true;
			createdLayer.frames = AtlasFrameMaker.construct(stage.imageFile);
		} else if(Paths.fileExists('images/' + stage.imageFile + '.txt', TEXT)) {
            isAnimated = true;
			createdLayer.frames = Paths.getPackerAtlas(stage.imageFile);
        } else if(Paths.fileExists('images/' + stage.imageFile + '.xml', TEXT)) {
            isAnimated = true;
			createdLayer.frames = Paths.getSparrowAtlas(stage.imageFile);
        }
		else {
			createdLayer.loadGraphic(Paths.image(stage.imageFile));
		}

		if(stage.animationsArray != null && stage.animationsArray.length > 0 && isAnimated) {
			for (anim in stage.animationsArray) {
				var animAnim:String = '' + anim.anim;
				var animName:String = '' + anim.name;
				var animFps:Int = anim.fps;
				var animLoop:Bool = !!anim.loop; //Bruh
				var animIndices:Array<Int> = anim.indices;
				if(animIndices != null && animIndices.length > 0) {
					createdLayer.animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
				} else {
					createdLayer.animation.addByPrefix(animAnim, animName, animFps, animLoop);
				}
			}
		} else if (isAnimated) {
            createdLayer.animation.addByPrefix('idle', 'BF idle dance', 24, false);
		}
		
		if(lastAnim != '' && isAnimated) {
			createdLayer.animation.play(lastAnim, true);
		}
    }*/

    function loadStage() {
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
            /*else if (sender == scaleStepper)
            {
                reloadStageImage();
                stage.jsonScale = sender.value;
                createdLayer.setGraphicSize(Std.int(createdLayer.width * stage.jsonScale));
                createdLayer.updateHitbox();
                
                if(createdLayer.animation.curAnim != null) {
                    createdLayer.animation.play(createdLayer.animation.curAnim.name, true);
                }
            }
            else if(sender == positionXStepper)
            {
                layers.position[0] = positionXStepper.value;
                createdLayer.x = layers.position[0];
            }
            else if(sender == positionYStepper)
            {
                layers.position[1] = positionXStepper.value;
                createdLayer.y = layers.position[1];
            }
            else if(sender == scrollFactorXStepper)
            {
                layers.scrollFactor[0] = scrollFactorXStepper.value;
                createdLayer.scrollFactor.x = layers.scrollFactor[0];
            }
            else if(sender == scrollFactorYStepper)
            {
                layers.scrollFactor[1] = scrollFactorYStepper.value;
                createdLayer.scrollFactor.y = layers.scrollFactor[1];
            }*/
        }
    }

    function createTexts()
    {
        for (i in 0...6)
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
    }
    
    function reloadTexts()
    {
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
            }
        }
    }

    var holdingObjectType:Null<Bool> = null;
    var isDad:Null<Bool> = null;
    var startMousePos:FlxPoint = new FlxPoint();
    var startComboOffset:FlxPoint = new FlxPoint();


    function getNextChar()
    {
		++curCharIndex;
		if (curCharIndex >= curChars.length)
        {
            curChar = curChars[0];
            curCharIndex = 0;
        }
        else
            curChar = curChars[curCharIndex];

		switch (curCharIndex)
		{
			case 0:
				curCharString = daDad;
			case 1:
				curCharString = daBf;
			case 2:
				curCharString = daGf;
		}
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

    override function update(elapsed:Float) {
        super.update(elapsed);

		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,
			
				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
                layers: [layers],
			};
		}
        else
        {
            stageData.defaultZoom = cameraZoomStepper.value;
            stageData.boyfriend = [bf.x, bf.y];
            stageData.girlfriend = [gf.x, gf.y];
            stageData.opponent = [dad.x, dad.y];
        }

        /*if(layers == null)
        {
            layers = {
                image: "stageback",
                position: [0, 0],
                scrollFactor: [0, 0],
                scale: 1,
                flipX: false,
                animations: []
            };
        }
        else
        {
            image: imageInputText.text,
            position: [positionXStepper.value, positionYStepper.value],
            scrollFactor: [scrollFactorXStepper.value, scrollFactorYStepper.value],
            scale: scaleStepper.value,
            flipX: flipXCheckBox.checked,
            animations: stage.animationsArray
        }*/

        if (FlxG.keys.justPressed.ENTER)
        {
            getNextChar();
        }

        if (FlxG.mouse.pressed && FlxCollision.pixelPerfectPointCheck(Math.floor(FlxG.mouse.x), Math.floor(FlxG.mouse.y), curChar) && !dragging)
        {
            dragging = true;
			updateMousePos();
        }

        if (dragging && FlxG.mouse.justMoved)
        {
            curChar.setPosition(-(oldMousePosX - FlxG.mouse.x) + curChar.x, -(oldMousePosY - FlxG.mouse.y) + curChar.y);
            updateMousePos();
        }

        if (dragging && FlxG.mouse.justReleased)
        {
            dragging = false;
            switch (curCharIndex)
            {
                case 0:
                    startCharacterPos(gf);
                case 1:
                    startCharacterPos(dad);
                case 2:
                    startCharacterPos(bf);
            }

            reloadTexts();
        }

        stage.update(elapsed);

        if(!stageDropDown.dropPanel.visible) {
            if (FlxG.keys.justPressed.R) {
                FlxG.camera.zoom = 1;
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
            reloadTexts();
            /*reloadAnimationDropDown();*/
			updatePresence();
		}
	}

    /*function reloadAnimationDropDown() {
		var anims:Array<String> = [];
		for (anim in stage.animationsArray) {
			anims.push(anim.anim);
		}
		if(anims.length < 1) anims.push('NO ANIMATIONS'); //Prevents crash

		animationDropDown.setData(FlxUIDropDownMenuCustom.makeStrIdLabelArray(anims, true));
	}*/
    
    function updateMousePos()
    {
        oldMousePosX = FlxG.mouse.x;
        oldMousePosY = FlxG.mouse.y;
    }

    var lastBeatHit:Int = -1;
    override public function beatHit()
    {
        super.beatHit();

        if(lastBeatHit == curBeat)
        {
            return;
        }

        if(curBeat % 2 == 0)
        {
            stage.beatHit(curBeat);
            gf.dance();
            bf.dance();
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
    
    function saveStage(stageFile:StageFile) {
        var data:String = Json.stringify(stageFile, "\t");
    
        if (data.length > 0)
        {
            _file = new FileReference();
            _file.addEventListener(Event.COMPLETE, onSaveComplete);
            _file.addEventListener(Event.CANCEL, onSaveCancel);
            _file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
            _file.save(data, nameInputText.text + ".json");
        }
    }
}