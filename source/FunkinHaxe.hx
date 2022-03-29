package;
#if HAXE_ALLOWED
import haxe.Interp;
import haxe.Exception;
#end
import animateatlas.AtlasFrameMaker;
import flixel.FlxG;
import flixel.addons.effects.FlxTrail;
import flixel.input.keyboard.FlxKey;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSprite;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets;
import flixel.math.FlxMath;
import flixel.util.FlxSave;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import Type.ValueType;
import Controls;
import DialogueBoxPsych;

using StringTools;

class FunkinHaxe {
    public static var Function_Stop:Dynamic = 1;
	public static var Function_Continue:Dynamic = 0;
	public static var tag:String = '';

	#if HAXE_ALLOWED
	public var haxe:Interp = null;
	#end
	public var camTarget:FlxCamera;
	public var scriptName:String = '';
	var gonnaClose:Bool = false;

	public var accessedProps:Map<String, Dynamic> = null;
    public function new(script:String) {
        #if HAXE_ALLOWED
        haxe = new Interp();
        scriptName = script;

        trace('lua file loaded succesfully:' + script);

		#if (haxe >= "4.0.0")
		accessedProps = new Map();
		#else
		accessedProps = new Map<String, Dynamic>();
		#end

        // Haxe shit
		set('Function_Stop', Function_Stop);
		set('Function_Continue', Function_Continue);
		set('luaDebugMode', false);
		set('luaDeprecatedWarnings', true);
		set('inChartEditor', false);

		// Song/Week shit
		set('curBpm', Conductor.bpm);
		set('bpm', PlayState.SONG.bpm);
		set('scrollSpeed', PlayState.SONG.speed);
		set('crochet', Conductor.crochet);
		set('stepCrochet', Conductor.stepCrochet);
		set('songLength', FlxG.sound.music.length);
		set('songName', PlayState.SONG.song);
		set('startedCountdown', false);

		set('isStoryMode', PlayState.isStoryMode);
		set('difficulty', PlayState.storyDifficulty);
		set('difficultyName', CoolUtil.difficulties[PlayState.storyDifficulty]);
		set('weekRaw', PlayState.storyWeek);
		set('week', WeekData.weeksList[PlayState.storyWeek]);
		set('seenCutscene', PlayState.seenCutscene);
		
		// Block require and os, Should probably have a proper function but this should be good enough for now until someone smarter comes along and recreates a safe version of the OS library
		set('require', false);

		// Camera poo
		set('cameraX', 0);
		set('cameraY', 0);
		
		// Screen stuff
		set('screenWidth', FlxG.width);
		set('screenHeight', FlxG.height);

		// PlayState cringe ass nae nae bullcrap
		set('curBeat', 0);
		set('curStep', 0);

		set('score', 0);
		set('misses', 0);
		set('hits', 0);

		set('rating', 0);
		set('ratingName', '');
		set('ratingFC', '');
		set('version', MainMenuState.psychEngineVersion.trim());
		
		set('inGameOver', false);
		set('mustHitSection', false);
		set('altAnim', false);
		set('gfSection', false);

		// Gameplay settings
		set('healthGainMult', PlayState.instance.healthGain);
		set('healthLossMult', PlayState.instance.healthLoss);
		set('instakillOnMiss', PlayState.instance.instakillOnMiss);
		set('botPlay', PlayState.instance.cpuControlled);
		set('practice', PlayState.instance.practiceMode);

		for (i in 0...4) {
			set('defaultPlayerStrumX' + i, 0);
			set('defaultPlayerStrumY' + i, 0);
			set('defaultOpponentStrumX' + i, 0);
			set('defaultOpponentStrumY' + i, 0);
		}

		// Default character positions woooo
		set('defaultBoyfriendX', PlayState.instance.BF_X);
		set('defaultBoyfriendY', PlayState.instance.BF_Y);
		set('defaultOpponentX', PlayState.instance.DAD_X);
		set('defaultOpponentY', PlayState.instance.DAD_Y);
		set('defaultGirlfriendX', PlayState.instance.GF_X);
		set('defaultGirlfriendY', PlayState.instance.GF_Y);

		// Character shit
		set('boyfriendName', PlayState.SONG.player1);
		set('dadName', PlayState.SONG.player2);
		set('gfName', PlayState.SONG.player3);

		// Some settings, no jokes
		set('downscroll', ClientPrefs.downScroll);
		set('middlescroll', ClientPrefs.middleScroll);
		set('framerate', ClientPrefs.framerate);
		set('ghostTapping', ClientPrefs.ghostTapping);
		set('hideHud', ClientPrefs.hideHud);
		set('timeBarType', ClientPrefs.timeBarType);
		set('scoreZoom', ClientPrefs.scoreZoom);
		set('cameraZoomOnBeat', ClientPrefs.camZooms);
		set('flashingLights', ClientPrefs.flashing);
		set('noteOffset', ClientPrefs.noteOffset);
		set('healthBarAlpha', ClientPrefs.healthBarAlpha);
		set('noResetButton', ClientPrefs.noReset);
		set('lowQuality', ClientPrefs.lowQuality);

		#if windows
		set('buildTarget', 'windows');
		#elseif linux
		set('buildTarget', 'linux');
		#elseif mac
		set('buildTarget', 'mac');
		#elseif html5
		set('buildTarget', 'browser');
		#elseif android
		set('buildTarget', 'android');
		#else
		set('buildTarget', 'unknown');
		#end

        public function executeFunction(name:String, ?args:Array<Any>):Dynamic {
            if (haxe == null) {
                return null;
            }
            if (haxe.variables.exists(funcName)) {
                var f = haxe.variables.get(funcName);
                if (args == null) {
                    var result = null;
                    try {
                        result = f();
                    } catch(e) {
                        this.trace('$e');
                    }
                    return result;
                } else {
                    var result = null;
                    try {
                        result = Reflect.callMethod(null, f, args);
                    } catch(e) {
                        this.trace('$e');
                    }
                    return result;
                }
                // f();
            }
            return null;
        }

        public function loadFile(path:String) {
            if (path.trim() == "") return;
            fileName = Path.withoutDirectory(path);
            var p = path;
            if (Path.extension(p) == "") {
                var exts = ["hx", "hsc", "hscript"];
                for (e in exts) {
                    if (FileSystem.exists('$p.$e')) {
                        p = '$p.$e';
                        fileName += '.$e';
                        break;
                    }
                }
            }
            try {
                hscript.execute();
            } catch(e) {
                this.trace('${e.message}');
            }
        }
        #end
    }

    public function set(variable:String, data:Dynamic) {
		#if HAXE_ALLOWED
		if(haxe == null) {
			return;
		}
        haxe.variables.set(variable, data);
		#end
	}

    public function get(variable:String) {
        #if HAXE_ALLOWED
		if(haxe == null) {
			return;
		}
        haxe.variables.get(variable);
		#end
    }
}

