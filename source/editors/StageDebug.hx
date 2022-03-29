// you might recognize this as the same stage editor sitting idle in psych engine's pull requests, i am the maker of both that and this, just thought it would
// be cool to put this in mag engine since I MADE IT lol
package editors;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import flixel.FlxState;
import StageData.LayerFile;
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
import flixel.group.FlxSpriteGroup;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import haxe.Json;
import flixel.system.debug.interaction.tools.Pointer.GraphicCursorCross;
import lime.system.Clipboard;
import flixel.animation.FlxAnimation;
import flash.net.FileFilter;
import flixel.util.FlxCollision;
import StageData;
import animateatlas.AtlasFrameMaker;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

class StageDebug extends MusicBeatState
{
	var bgLayer:FlxTypedGroup<FlxSprite>;
	var layers:Array<String>;
	var directories:Array<String>;
	var defaultZoom:Float;
	var isPixelStage:Bool;
	var camFollow:FlxObject;
	var confirmAdded:Bool = false;

	var data:StageFile;
	var shouldStayIn:FlxSprite;

	public static var swagStage:StageFile;
	public static var stepperscrollX:FlxUIInputText;
	public static var stepperscrollY:FlxUIInputText;

	var scaleStepper:FlxUINumericStepper;
	var coolswagStage:StageData;
	var addedLayers:Array<LayerFile>;

	var createdLayer:FlxSprite = new FlxSprite();

	var boyfriend:Array<Dynamic>;
	var girlfriend:Array<Dynamic>;
	var opponent:Array<Dynamic>;

	//Characters
	var bf:Character;
    var gf:Character;
    var dad:Character;

	public var daBf:String;
	public var daGf:String;
	public var daDad:String;

	var layerAdded:Bool = false;

	var stageCounter:Int;
	var gridBG:FlxSprite;

	var noStage:Bool = true;

	var UI_box:FlxUITabMenu;
	var UI_stagebox:FlxUITabMenu;

	private var camEditor:FlxCamera;
	private var camHUD:FlxCamera;
	private var camMenu:FlxCamera;
	private var camTips:FlxCamera;

	// so many text boxes lol
	public static var nameInputText:FlxUIInputText;
	public static var directoryInputText:FlxUIInputText;
	public static var directoryInputTextcool:FlxUIInputText;
	public static var xInputText:FlxUIInputText;
	public static var yInputText:FlxUIInputText;
	public static var gfInputText:FlxUIInputText;
	public static var bfInputText:FlxUIInputText;
	public static var opponentinputtext:FlxUIInputText;
	public static var zoominputtext:FlxUIInputText;
	public static var dirinputtext:FlxUIInputText;
	public static var goToPlayState:Bool = true;
	var animationsArray:Array<AnimationArray> = [];

	var oldMousePosX:Int;
	var oldMousePosY:Int;

    var curChar:FlxSprite;
	var curCharIndex:Int = 0;
    var curAnim:Int = 0;
	var curCharString:String;
	var curChars:Array<FlxSprite>;
    var dragging:Bool = false;

	override function create()
	{
		gridBG = FlxGridOverlay.create(25, 25);
		add(gridBG);
		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow);

		camEditor = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camMenu = new FlxCamera();
		camMenu.bgColor.alpha = 0;
		camTips = new FlxCamera();
		camTips.bgColor.alpha = 0;

		FlxG.cameras.reset(camEditor);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camMenu);
		FlxG.cameras.add(camTips);
		FlxCamera.defaultCameras = [camEditor];

		var tabs = [{name: 'Layers', label: 'Layers'}, {name: 'Settings', label: 'Settings'},];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.cameras = [camMenu];

		UI_box.resize(250, 120);
		UI_box.x = FlxG.width - 275;
		UI_box.y = 25;
		UI_box.scrollFactor.set();

		UI_stagebox = new FlxUITabMenu(null, tabs, true);
		UI_stagebox.cameras = [camMenu];

		UI_stagebox.resize(350, 350);
		UI_stagebox.x = UI_box.x - 100;
		UI_stagebox.y = UI_box.y + UI_box.height;
		UI_stagebox.scrollFactor.set();
		add(UI_stagebox);

		addLayersUI();
		addSettingsUI();
		searchForLayer();

		UI_stagebox.selected_tab_id = 'Layers';

		var tipText:FlxText = new FlxText(FlxG.width - 20, FlxG.height, 0, "E/Q - Camera Zoom In/Out
        \nArrow Keys - Move Layer
        \nR - Reset Current Zoom", 12);
		tipText.cameras = [camTips];
		tipText.setFormat(null, 12, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tipText.scrollFactor.set();
		tipText.borderSize = 1;
		tipText.screenCenter(Y);
		tipText.x -= tipText.width;
		tipText.y -= tipText.height - 10;
		add(tipText);

		FlxG.mouse.visible = true;

		bgLayer = new FlxTypedGroup<FlxSprite>();
		add(bgLayer);

		bgLayer.add(createdLayer);


		// Characters
		gf = new Character(400, 130, 'gf');
		startCharacterPos(gf);
		gf.scrollFactor.set(0.95, 0.95);
		add(gf);

		dad = new Character(100, 100, 'dad');
		startCharacterPos(dad);
		add(dad);

		bf = new Character(770, 100, 'bf', true);
	    startCharacterPos(bf);
		add(bf);

		curChars = [dad, bf, gf];
		curChar = curChars[curCharIndex];

		super.create();
	}

	function startCharacterPos(character:Character) {
        character.x += character.positionArray[0];
		character.y += character.positionArray[1];
    }

	var scrollFactorXStepper:FlxUINumericStepper;
    var scrollFactorYStepper:FlxUINumericStepper;

    var positionXStepper:FlxUINumericStepper;
	var positionYStepper:FlxUINumericStepper;

    var flipXCheckBox:FlxUICheckBox;
	var noAntialiasingCheckBox:FlxUICheckBox;
    var imageInputText:FlxUIInputText;
    var nameLayerInputText:FlxUIInputText;
	
	function addLayersUI()
	{
		nameLayerInputText = new FlxUIInputText(15, 50, 200, "", 8);
		var namelabel = new FlxText(15, nameLayerInputText.y + 20, 64, 'Layer Name');
		directoryInputText = new FlxUIInputText(15, nameInputText.y + 50, 200, "", 8);
		var directlabel = new FlxText(15, directoryInputText.y + 20, 64, 'Image Directory');
		xInputText = new FlxUIInputText(15, directoryInputText.y + 50, 200, "", 8);

		positionXStepper = new FlxUINumericStepper(15, directoryInputText.y + 50, 10, 0, -9000, 9000, 0);
        positionYStepper = new FlxUINumericStepper(positionXStepper.x + 60, positionXStepper.y, 10, 0, -9000, 9000, 0);

        scrollFactorXStepper = new FlxUINumericStepper(positionXStepper.x, positionXStepper.y + 40, 0.1, 0, -9000, 9000, 0);
		scrollFactorYStepper = new FlxUINumericStepper(positionYStepper.x, positionYStepper.y + 40, 0.1, 0, -9000, 9000, 0);

		flipXCheckBox = new FlxUICheckBox(15, scrollFactorYStepper.y + 40, null, null, "Flip X", 50);

        noAntialiasingCheckBox = new FlxUICheckBox(flipXCheckBox.x, flipXCheckBox.y + 40, null, null, "No Antialiasing", 80);

		scaleStepper = new FlxUINumericStepper(240, directoryInputText.y, 0.1, 1, 0.05, 10, 1);

		var addLayer:FlxButton = new FlxButton(140, 20, "Add Layer", function()
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
			bgLayer.add(createdLayer);
			if (layerAdded)
			{
				swagStage.layers.push(stageSwag);
			}
			// we need to make sure the created layer exists before being able to scale it or we'll experience a crash
			if (swagStage.layers.contains(stageSwag))
			{
				for (cool in swagStage.layers)
				{
					if (cool.image != "")
					{
						confirmAdded = true;
					}
				}
			}
		});

		var removeLayer:FlxButton = new FlxButton(40, 20, "Remove Layer", function()
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
				deleteLayer();
				xInputText.text = "" + 0;
				yInputText.text = "" + 0;
				if (swagStage.layers.contains(stageSwag))
				{
					bgLayer.remove(createdLayer);
					swagStage.layers.remove(stageSwag);
				}
			}
		});

		removeLayer.color = FlxColor.RED;
		removeLayer.label.color = FlxColor.WHITE;

		var tab_group = new FlxUI(null, UI_stagebox);
		tab_group.name = "Layers";

        tab_group.add(new FlxText(15, imageInputText.y - 18, 0, 'Image file name:'));
		tab_group.add(new FlxText(15, scaleStepper.y - 18, 0, 'Scale:'));
		tab_group.add(new FlxText(positionXStepper.x, positionXStepper.y - 18, 0, 'Sprites X/Y:'));
		tab_group.add(new FlxText(scrollFactorXStepper.x, scrollFactorXStepper.y - 18, 0, 'Scroll Factor X/Y:'));
		tab_group.add(imageInputText);
		tab_group.add(addLayer);
        tab_group.add(removeLayer);
		tab_group.add(scaleStepper);
		tab_group.add(flipXCheckBox);
		tab_group.add(noAntialiasingCheckBox);
		tab_group.add(positionXStepper);
		tab_group.add(positionYStepper);
		tab_group.add(scrollFactorXStepper);
		tab_group.add(scrollFactorYStepper);
		UI_stagebox.addGroup(tab_group);
		UI_stagebox.scrollFactor.set();
	}

	var cameraZoomStepper:FlxUINumericStepper;
	function addSettingsUI()
	{
		cameraZoomStepper = new FlxUINumericStepper(15, 20, 0.1, 1, 0, 1.05, 1);
		var elabel = new FlxText(15, zoominputtext.y + 20, 64, 'Default Zoom');
		dirinputtext = new FlxUIInputText(15, zoominputtext.y + 50, 200, "", 8);
		var directorycoollabel = new FlxText(15, dirinputtext.y + 20, 64, 'Stage Name');

		var saveStuff:FlxButton = new FlxButton(240, 20, "Save Stage", function()
		{
			saveStage(swagStage);
		});

		var tab_group_settings = new FlxUI(null, UI_stagebox);
		tab_group_settings.name = "Settings";
		tab_group_settings.add(saveStuff);
		tab_group_settings.add(cameraZoomStepper);
		tab_group_settings.add(elabel);
		tab_group_settings.add(zoominputtext);
		tab_group_settings.add(dirinputtext);
		tab_group_settings.add(directorycoollabel);

		UI_stagebox.addGroup(tab_group_settings);

		UI_stagebox.scrollFactor.set();
	}

	function searchForLayer()
	{
        createdLayer.visible = false;
        var assetName:String = imageInputText.text.trim();
        var isAnimated:Bool = false;
        var lastAnim:String = '';
        if (assetName != null && assetName.length > 0)
        {
            if (Paths.fileExists('images/' + assetName + '.png', IMAGE))
            {
                createdLayer.loadGraphic(Paths.image(assetName));
                createdLayer.visible = true;
            }
            else if(Paths.fileExists('images/' + assetName + '/Animation.json', TEXT)) {
                isAnimated = true;
                createdLayer.frames = AtlasFrameMaker.construct(assetName);
            }
            else if(Paths.fileExists('images/' + assetName + '.txt', TEXT)) {
                isAnimated = true;
                createdLayer.frames = Paths.getPackerAtlas(assetName);
            } else if(Paths.fileExists('images/' + assetName + '.xml', TEXT)) {
                isAnimated = true;
                createdLayer.frames = Paths.getSparrowAtlas(assetName);
            }

            if(animationsArray != null && animationsArray.length > 0 && isAnimated) {
                for (anim in animationsArray) {
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
        }
        else
        {
            createdLayer.visible = false;
        }
	}

	function deleteLayer()
	{
		bgLayer.remove(createdLayer);
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			if (sender == scaleStepper)
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
				stageSwag.scale = sender.value;
				createdLayer.setGraphicSize(Std.int(createdLayer.width * stageSwag.scale));
			}
			else if(sender == cameraZoomStepper)
			{
				FlxG.camera.zoom = sender.value;
			}
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		searchForLayer();

		if(swagStage == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			swagStage = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,
			
				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
                layers: [],
			};
		}
        else
        {
            swagStage.defaultZoom = cameraZoomStepper.value;
            swagStage.boyfriend = [bf.x, bf.y];
            swagStage.girlfriend = [gf.x, gf.y];
            swagStage.opponent = [dad.x, dad.y];
        }


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

		if (FlxG.keys.pressed.LEFT)
		{
			createdLayer.x -= 1;
			positionXStepper.value = createdLayer.x;
		}
		else if (FlxG.keys.pressed.RIGHT)
		{
			createdLayer.x += 1;
			positionXStepper.value = createdLayer.x;
		}
		else if (FlxG.keys.pressed.UP)
		{
			createdLayer.y -= 1;
			positionYStepper.value = createdLayer.y;
		}
		else if (FlxG.keys.pressed.DOWN)
		{
			createdLayer.y += 1;
			positionYStepper.value = createdLayer.y;
		}

		if (FlxG.keys.justPressed.R)
		{
			FlxG.camera.zoom = 1;
		}
		if (FlxG.keys.pressed.E && FlxG.camera.zoom < 3)
		{
			FlxG.camera.zoom += elapsed * FlxG.camera.zoom;
			if (FlxG.camera.zoom > 3)
				FlxG.camera.zoom = 3;
		}
		if (FlxG.keys.pressed.Q && FlxG.camera.zoom > 0.1)
		{
			FlxG.camera.zoom -= elapsed * FlxG.camera.zoom;
			if (FlxG.camera.zoom < 0.1)
				FlxG.camera.zoom = 0.1;
		}
		camMenu.zoom = FlxG.camera.zoom;
		if (FlxG.keys.justPressed.ESCAPE)
		{
			MusicBeatState.switchState(new MasterEditorMenu());
			FlxG.sound.playMusic(Paths.music('freakyMenu'));

			FlxG.mouse.visible = false;
			return;
		}
	}


	function updateMousePos()
	{
		oldMousePosX = FlxG.mouse.x;
		oldMousePosY = FlxG.mouse.y;
	}


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

	private static var _file:FileReference;

	public static function saveStage(stageFile:StageFile)
	{
		var data:String = Json.stringify(stageFile, "\t");
		if (data.length > 0)
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data, dirinputtext.text + ".json");
		}
	}

	private static function onSaveComplete(_):Void
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
	private static function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	private static function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving file");
	}
}