
package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxTimer;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.FlxObject;
import flixel.FlxBasic;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRandom;
import flixel.addons.display.FlxBackdrop;

#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end
import openfl.utils.AssetType;
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;
//Some Class Stuff
import StageData;
import BGSprite;
import BackgroundGirls;
import BackgroundDancer;
import WiggleEffect;
import FunkinLua;

using StringTools;

class Stage extends FlxTypedGroup<FlxBasic>
{
    public var curStage:String = DEFAULT_STAGE;
    public var defaultCamZoom:Float = 1.05;
    public static var DEFAULT_STAGE:String = 'stage'; //In case a stage is missing, it will use Stage on its place
	public static var instance:Stage;
	public var dad:Character;
    public var foreground:FlxTypedGroup<FlxBasic> = new FlxTypedGroup<FlxBasic>(); // stuff layered above every other layer
    public var overlay:FlxSpriteGroup = new FlxSpriteGroup(); // stuff that goes into the HUD camera. Layered before UI elements, still
	
	public var positions:Map<String,FlxPoint> = [
		"boyfriend"=> FlxPoint.get(770, 100),
		"dad"=> FlxPoint.get(100, 100),
		"gf"=> FlxPoint.get(400,130)
	];
    public var layers:Map<String,FlxTypedGroup<FlxBasic>> = [
        "boyfriend"=>new FlxTypedGroup<FlxBasic>(), // stuff that should be layered infront of all characters, but below the foreground
        "dad"=>new FlxTypedGroup<FlxBasic>(), // stuff that should be layered infront of the dad and gf but below boyfriend and foreground
        "gf"=>new FlxTypedGroup<FlxBasic>(), // stuff that should be layered infront of the gf but below the other characters and foreground
		"foreground"=>new FlxTypedGroup<FlxBasic>(), // stuff that should be layered infront of the characters 
    ];


	public var gfVersion:String = 'gf';

    public var boppers:Array<Dynamic> = []; // should contain [sprite, bopAnimName, whichBeats]
    public var boppersAlt:Array<Dynamic> = []; // should contain [sprite, bopAnimName, whichBeats]
    public var dancers:Array<Dynamic> = []; // Calls the 'dance' function on everything in this array every beat

	public var songName:String = Paths.formatToSongPath(PlayState.SONG.song);
	public var pre:String;
	public var suf:String;

    //sometimes  public var is for event function
    //Week 2
    var halloweenBG:BGSprite;
	var halloweenWhite:BGSprite;

    //Week 3
	public var blammedLightsBlack:ModchartSprite = null;
	public var phillyCityLightsEvent:FlxTypedGroup<FlxSprite> = null;
	public var phillyCityLights:FlxTypedGroup<FlxSprite> = null;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

    //Week 4
	public var limoKillingState:Int = 0;
	var limo:BGSprite;
	var limoMetalPole:BGSprite;
	var limoLight:BGSprite;
	var limoCorpse:BGSprite;
	var limoCorpseTwo:BGSprite;
	var bgLimo:BGSprite;
	var grpLimoParticles:FlxTypedGroup<BGSprite>;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

    //Week 5
	public var upperBoppers:FlxSprite;
	public var bottomBoppers:FlxSprite;
	public var santa:FlxSprite;
	public var heyTimer:Float;

    //Week 6
	public var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	public var bgGhouls:BGSprite;

	//Week7 ???
	var watchtower:FlxSprite;
	var tankRolling:FlxSprite;
	var tank0:FlxSprite;
	var tank1:FlxSprite;
	var tank2:FlxSprite;
	var tank3:FlxSprite;
	var tank4:FlxSprite;
	var tank5:FlxSprite;
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankAngle:Float = FlxG.random.float(-90, 45);
	var tankX:Int = 400;

	//Bob and Bosip
	var mini:FlxSprite;
	var mordecai:FlxSprite;
	var theEntireFuckingStage:FlxTypedGroup<FlxSprite>;
	var coolGlowyLights:FlxTypedGroup<FlxSprite>;
	var coolGlowyLightsMirror:FlxTypedGroup<FlxSprite>;
	var areYouReady:FlxTypedGroup<FlxSprite>;
	var walked:Bool = false;
	var walkingRight:Bool = true;
	var stopWalkTimer:Int = 0;
	var pastCurLight:Int = 1;

	//QT
	var qt_gas01:FlxSprite;
	var qt_gas02:FlxSprite;

	//Sussy Imposter
	var amogus:FlxSprite;
	var dripster:FlxSprite;
	var yellow:FlxSprite;
	var brown:FlxSprite;
	var orb:FlxSprite;
	var ass2:FlxSprite;
	var fortnite1:FlxSprite;
	var fortnite2:FlxSprite;

	//Enity
	var speaker:FlxSprite;

	// doki
	var sparkleFG:FlxBackdrop;
	var sparkleBG:FlxBackdrop;
	var pinkOverlay:FlxSprite;
	var bakaOverlay:FlxSprite;
	var vignette:FlxSprite;
	var staticshock:FlxSprite;
	var oldspace:FlxSprite;
	var camend:FlxObject;
	var popup:FlxSprite;
	var lights_front:FlxSprite;
	var deskfront:FlxSprite;
	var closet:FlxSprite;
	var clubroom:FlxSprite;
	var lights_back:FlxSprite;
	var banner:FlxSprite;
	var space:FlxBackdrop;
	var whiteflash:FlxSprite;
	var blackScreen:FlxSprite;
	var blackScreenBG:FlxSprite;
	var blackScreentwo:FlxSprite;
	var monika:FlxSprite;
	var sayori:FlxSprite;
	var yuri:FlxSprite;
	var natsuki:FlxSprite;
	var protag:FlxSprite;
	var imageBG:FlxSprite;
	var monikatransformer:FlxSprite;

	//Zardy
	var zardyBackground:FlxSprite;


	//Airplane
	public var graphMode:Int = 0;
	var graphMoveTimer:Int = -1;
	var graphMove:Float = 0;
	var neutralGraphPos:Float = 0;
	var graphBurstTimer:Int = 0;
	var graphPosition:Float;
	var shinyMode:Bool = false;
	var oldMode:Int = 0;

	var graphPointer:FlxObject;
	var grpGraph:FlxTypedGroup<FlxSprite>;
	var grpGraphIndicators:FlxTypedGroup<FlxSprite>;


	//mami
	var gorls:FlxSprite;
	var holyHomura:FlxSprite;
	var connectLight:FlxSprite;
	var lampsLeft:FlxSprite;
	var blackOverlay:FlxSprite;
	var darknessOverlay:FlxSprite;
	var gunSwarm:FlxSprite;
	var gunSwarmBack:FlxBackdrop;
	var gunSwarmFront:FlxBackdrop;
	var thisBitchSnapped:Bool = false;
	var whiteBG:FlxSprite;
	var otherBGStuff:FlxSprite;
	var lampsSubway:FlxSprite;
	var stageFront:FlxSprite;
	var tetrisLight:FlxSprite;
	var colorCycle:Int = 0;
	var latched:Bool = false;
	var tetrisCrowd:FlxSprite;
	var weebGorl:FlxSprite;
	

	//Camellia
	public var addedAmogus:Bool = false;
	public var concertZoom:Bool = false;
	public var crowd_front:FlxSprite;
	public var crowd_front2:FlxSprite;
	public var crowd_front3:FlxSprite;
	public var crowd_front4:FlxSprite;
	public var jabibi_amogus:FlxSprite;
	public var speaker_left:FlxSprite;
	public var speaker_right:FlxSprite;
	public var crowd_back:FlxSprite;
	public var crowd_back2:FlxSprite;
	public var crowd_back3:FlxSprite;
	public var crowd_back4:FlxSprite;
	public var timing:Float = 0.25;
	public var zoomLevel:Float = 0.41;
	public var easeThing = FlxEase.expoInOut;

    public function new(?stage:String = 'stage')
    {
        super();
        curStage = stage;
		instance = this;

        switch(curStage)
        {
			case 'stage'|'holostage' | 'FNAFstage' | 'holostage-corrupt' | 'arcade' | 'ballin' | 'holostage-past' | 'stuco':
				var stageShit:String ='';
				switch (curStage)
				{
					case 'stage':
						stageShit = 'stage/';
					case 'holostage':
						stageShit = 'holofunk/stage/';
					case 'FNAFstage':
						stageShit = 'FNAF/';
					case 'holostage-corrupt':
						stageShit = 'holofunk/stage/corrupt';
					case 'holostage-past':
						stageShit = 'holofunk/stage/past';
					case 'arcade':
						stageShit = 'kapi/';
					case 'ballin':
						stageShit = 'hex/';
					case 'stuco':
						stageShit = 'stuco';
				}
				if (curStage == 'holostage-corrupt')
				{
					var bg2 = new FlxSprite(-600, -200).loadGraphic(Paths.image('holofunk/stage/eyes'));
					bg2.antialiasing = true;
					bg2.scrollFactor.set(0.9, 0.9);
					bg2.active = false;
					add(bg2);
				}
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image(stageShit+'stageback'));
				bg.antialiasing = ClientPrefs.globalAntialiasing;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);

				var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image(stageShit+'stagefront'));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				stageFront.antialiasing = ClientPrefs.globalAntialiasing;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;
				add(stageFront);
                if (!ClientPrefs.lowQuality && curStage == 'FNAFstage' ||!ClientPrefs.lowQuality && curStage == 'stage') //idk why fnaf stage and default had this :/
				{
					var stageLight:FlxSprite = new FlxSprite(-125, -100).loadGraphic(Paths.image(stageShit+'stage_light'));
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.antialiasing = ClientPrefs.globalAntialiasing;
					stageLight.scrollFactor.set(0.9, 0.9);
					stageLight.active = false;
					add(stageLight);
					
					var stageLight:FlxSprite = new FlxSprite(1225, -100).loadGraphic(Paths.image(stageShit+'stage_light'));
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.antialiasing = ClientPrefs.globalAntialiasing;
					stageLight.scrollFactor.set(0.9, 0.9);
					stageLight.active = false;
					stageLight.flipX = true;
					add(stageLight);

					var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image(stageShit+'stagecurtains'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					stageCurtains.antialiasing = ClientPrefs.globalAntialiasing;
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;
					add(stageCurtains);				
				}
			case 'spooky':
				if(!ClientPrefs.lowQuality) {
					halloweenBG = new BGSprite('halloween_bg','week2', -200, -100, ['halloweem bg0', 'halloweem bg lightning strike']);
				} else {
					halloweenBG = new BGSprite('halloween_bg_low','week2', -200, -100);
				}
                add(halloweenBG);

				halloweenWhite = new BGSprite(null, -FlxG.width, -FlxG.height, 0, 0);
				halloweenWhite.makeGraphic(Std.int(FlxG.width * 3), Std.int(FlxG.height * 3), FlxColor.WHITE);
				halloweenWhite.alpha = 0;
				halloweenWhite.blend = ADD;
				layers.get('boyfriend').add(halloweenWhite);

				//PRECACHE SOUNDS
				CoolUtil.precacheSound('thunder_1');
				CoolUtil.precacheSound('thunder_2');
			case 'philly' | 'phillyannie':
				switch (curStage)
				{
					case 'philly': pre = 'philly';
					case 'phillyannie': pre = 'annie';
				}

				if(!ClientPrefs.lowQuality) {
					var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image(pre+'/sky', 'week3'));
					bg.scrollFactor.set(0.1, 0.1);
					add(bg);
				}

				var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image(pre+'/city', 'week3'));
				city.scrollFactor.set(0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				add(city);

				phillyCityLights = new FlxTypedGroup<FlxSprite>();
				add(phillyCityLights);

				for (i in 0...5)
				{
					var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image(pre+'/win' + i, 'week3'));
					light.scrollFactor.set(0.3, 0.3);
					light.visible = false;
					light.setGraphicSize(Std.int(light.width * 0.85));
					light.updateHitbox();
					light.antialiasing = ClientPrefs.globalAntialiasing;
					phillyCityLights.add(light);						
				}

				if(!ClientPrefs.lowQuality) {
					var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image(pre+'/behindTrain','week3'));
				    add(streetBehind);
				}
				

				phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image(pre+'/train','week3'));
				add(phillyTrain);

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes','week3'));
				CoolUtil.precacheSound('train_passes');
				FlxG.sound.list.add(trainSound);

				var street:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image(pre+'/street','week3'));
				add(street);


				if(!PlayState.instance.modchartSprites.exists('blammedLightsBlack')) {  
					//Creates blammed light black fade in case you didn't make your own
					blammedLightsBlack = new ModchartSprite(FlxG.width * -0.5, FlxG.height * -0.5);
					blammedLightsBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					var position:Int = PlayState.instance.members.indexOf(PlayState.instance.gfGroup);
					if(PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup) < position) {
						position = PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup);
					} else if(PlayState.instance.members.indexOf(PlayState.instance.dadGroup) < position) {
						position = PlayState.instance.members.indexOf(PlayState.instance.dadGroup);
					}
					PlayState.instance.insert(position, blammedLightsBlack);
		
					blammedLightsBlack.wasAdded = true;
					PlayState.instance.modchartSprites.set('blammedLightsBlack', blammedLightsBlack);
			    }
			    PlayState.instance.insert(members.indexOf(blammedLightsBlack) + 1, phillyCityLightsEvent);
			    blammedLightsBlack = PlayState.instance.modchartSprites.get('blammedLightsBlack');
			    blammedLightsBlack.alpha = 0.0;


				phillyCityLightsEvent = new FlxTypedGroup<FlxSprite>();
				layers.get("foreground").add(phillyCityLightsEvent);

				for (i in 0...5)
				{
					var light:FlxSprite = new FlxSprite(-10, 0).loadGraphic(Paths.image(pre+'/win' + i, 'week3'));
					light.scrollFactor.set(0.3, 0.3);
					light.visible = false;
					light.setGraphicSize(Std.int(light.width * 0.85));
					light.updateHitbox();
					light.antialiasing = ClientPrefs.globalAntialiasing;
					phillyCityLightsEvent.add(light);						
				}
			case 'philly-neo':
				if(!ClientPrefs.lowQuality) {
					var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('neo/sky', 'week3'));
					bg.scrollFactor.set(0.1, 0.1);
					add(bg);
				}


				var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('neo/phillybuildings', 'week3'));
				city.scrollFactor.set(0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				add(city);

				phillyCityLights = new FlxTypedGroup<FlxSprite>();
				add(phillyCityLights);

				for (i in 0...1)
				{
					var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('neo/light' + i, 'week3'));
					light.scrollFactor.set(0.3, 0.3);
					light.visible = false;
					light.setGraphicSize(Std.int(light.width * 0.85));
					light.updateHitbox();
					light.antialiasing = true;
					phillyCityLights.add(light);
				}

				if(!ClientPrefs.lowQuality) {
					var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('neo/roads', 'week3'));
					add(streetBehind);
				}


				phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('neo/train', 'week3'));
				add(phillyTrain);

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
				FlxG.sound.list.add(trainSound);
				trainSound.volume = 0.6;

				var street:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('neo/alleyway', 'week3'));
				add(street);


				if(!PlayState.instance.modchartSprites.exists('blammedLightsBlack')) {  
					//Creates blammed light black fade in case you didn't make your own
					blammedLightsBlack = new ModchartSprite(FlxG.width * -0.5, FlxG.height * -0.5);
					blammedLightsBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					var position:Int = PlayState.instance.members.indexOf(PlayState.instance.gfGroup);
					if(PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup) < position) {
						position = PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup);
					} else if(PlayState.instance.members.indexOf(PlayState.instance.dadGroup) < position) {
						position = PlayState.instance.members.indexOf(PlayState.instance.dadGroup);
					}
					PlayState.instance.insert(position, blammedLightsBlack);
		
					blammedLightsBlack.wasAdded = true;
					PlayState.instance.modchartSprites.set('blammedLightsBlack', blammedLightsBlack);
			    }
			    PlayState.instance.insert(members.indexOf(blammedLightsBlack) + 1, phillyCityLightsEvent);
			    blammedLightsBlack = PlayState.instance.modchartSprites.get('blammedLightsBlack');
			    blammedLightsBlack.alpha = 0.0;


				phillyCityLightsEvent = new FlxTypedGroup<FlxSprite>();
				layers.get("foreground").add(phillyCityLightsEvent);

				for (i in 0...1)
				{
					var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('neo/light' + i, 'week3'));
					light.scrollFactor.set(0.3, 0.3);
					light.visible = false;
					light.setGraphicSize(Std.int(light.width * 0.85));
					light.updateHitbox();
					light.antialiasing = ClientPrefs.globalAntialiasing;
					phillyCityLightsEvent.add(light);						
				}
			case 'limo':
				gfVersion = 'gf-car';
				var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset','week4'));
				skyBG.scrollFactor.set(0.1, 0.1);
				add(skyBG);
				if(!ClientPrefs.lowQuality) {
					limoMetalPole = new BGSprite('gore/metalPole','week4', -500, 220, 0.4, 0.4);
					add(limoMetalPole);

					bgLimo = new BGSprite('limo/bgLimo','week4', -150, 480, 0.4, 0.4, ['background limo pink'], true);
					add(bgLimo);

					limoCorpse = new BGSprite('gore/noooooo','week4', -500, limoMetalPole.y - 130, 0.4, 0.4, ['Henchmen on rail'], true);
					add(limoCorpse);

					limoCorpseTwo = new BGSprite('gore/noooooo','week4', -500, limoMetalPole.y, 0.4, 0.4, ['henchmen death'], true);
					add(limoCorpseTwo);

					grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);

					for (i in 0...5)
					{
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400, 'limo/limoDancer', 'week4');
						dancer.scrollFactor.set(0.4, 0.4);
						boppers.push(dancer);
						grpLimoDancers.add(dancer);
					}

					limoLight = new BGSprite('gore/coldHeartKiller','week4', limoMetalPole.x - 180, limoMetalPole.y - 80, 0.4, 0.4);
					add(limoLight);

					grpLimoParticles = new FlxTypedGroup<BGSprite>();
					add(grpLimoParticles);

					//PRECACHE BLOOD
					var particle:BGSprite = new BGSprite('gore/stupidBlood','week4', -400, -400, 0.4, 0.4, ['blood'], false);
					particle.alpha = 0.01;
					grpLimoParticles.add(particle);
					resetLimoKill();

					//PRECACHE SOUND
					CoolUtil.precacheSound('dancerdeath');
				}

				limo = new BGSprite('limo/limoDrive','week4', -120, 550, 1, 1, ['Limo stage'], true);
				layers.get('gf').add(limo);


				fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol', 'week4'));
				fastCar.antialiasing = ClientPrefs.globalAntialiasing;
				fastCar.visible = false;
				layers.get('boyfriend').add(fastCar);
				resetFastCar();

				limoKillingState = 0;
			case 'limoHolo':
				var skyBG:FlxSprite = new FlxSprite(-120, -100).loadGraphic(Paths.image('holofunk/limoholo/limoSunset'));
				skyBG.scrollFactor.set(0.1, 0.1);
				add(skyBG);

				if(!ClientPrefs.lowQuality) {
					var bgLimo:FlxSprite = new FlxSprite(-200, 480);
					bgLimo.frames = Paths.getSparrowAtlas('holofunk/limoholo/bgLimo');
					bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
					bgLimo.animation.play('drive');
					bgLimo.scrollFactor.set(0.4, 0.4);
					add(bgLimo);
	
					grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);
	
					for (i in 0...5)
					{
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 200, bgLimo.y - 360, 'holofunk/limoholo/limoDancer');
						dancer.scrollFactor.set(0.4, 0.4);
						grpLimoDancers.add(dancer);
					}
				}

				var limo = new FlxSprite(-120, 550);
				limo.frames = Paths.getSparrowAtlas('holofunk/limoholo/limoDrive');
				limo.animation.addByPrefix('drive', "Limo stage", 24);
				limo.animation.play('drive');
				limo.antialiasing = true;
				layers.get('gf').add(limo);

				var fastCar = new FlxSprite(-12600, 160).loadGraphic(Paths.image('holofunk/limoholo/fastCarLol'));
				layers.get('boyfriend').add(fastCar);

				fastCarCanDrive = true;				
			case 'mall'|'sofdeez':
				switch (curStage)
				{
					case 'mall':
						pre = 'christmas';
					case 'sofdeez':
						pre = 'skye';
				}

				gfVersion = 'gf-christmas';
				var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image(pre+'/bgWalls','week5'));
				bg.antialiasing = ClientPrefs.globalAntialiasing;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				if(!ClientPrefs.lowQuality)
				{
					upperBoppers = new FlxSprite(-240, -90);
					upperBoppers.frames = Paths.getSparrowAtlas(pre+'/upperBop','week5');
					upperBoppers.animation.addByPrefix('idle', "Upper Crowd Bob", 24, false);
					upperBoppers.antialiasing = ClientPrefs.globalAntialiasing;
					upperBoppers.scrollFactor.set(0.33, 0.33);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					boppersAlt.push(upperBoppers);
					add(upperBoppers);
	
					var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image(pre+'/bgEscalator','week5'));
					bgEscalator.antialiasing = ClientPrefs.globalAntialiasing;
					bgEscalator.scrollFactor.set(0.3, 0.3);
					bgEscalator.active = false;
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);
				}


				var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image(pre+'/christmasTree','week5'));
				tree.antialiasing = ClientPrefs.globalAntialiasing;
				tree.scrollFactor.set(0.40, 0.40);
				add(tree);

				if (pre == 'skye')
				{
					bottomBoppers = new FlxSprite(-540, -210);
					bottomBoppers.frames = Paths.getSparrowAtlas('skye/bottomBop','week5');
					bottomBoppers.animation.addByPrefix('idle', 'Bottom Level Boppers', 24, false);
					bottomBoppers.scrollFactor.set(1, 1);
				}
				else
				{
					bottomBoppers = new FlxSprite(-300, 140);
					bottomBoppers.frames = Paths.getSparrowAtlas('mall/bottomBop','week5');
					bottomBoppers.animation.addByPrefix('idle', 'Bottom Level Boppers', 24, false);
					bottomBoppers.animation.addByPrefix('hey', 'Bottom Level Boppers HEY', 24, false);
					bottomBoppers.scrollFactor.set(0.9, 0.9);
				}

				bottomBoppers.antialiasing = ClientPrefs.globalAntialiasing;
				bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
				bottomBoppers.updateHitbox();
				boppersAlt.push(bottomBoppers);
				add(bottomBoppers);



				var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image(pre+'/fgSnow','week5'));
				fgSnow.active = false;
				fgSnow.antialiasing = ClientPrefs.globalAntialiasing;
				add(fgSnow);

				santa = new FlxSprite(-840, 150);
				santa.frames = Paths.getSparrowAtlas(pre+'christmas/santa','week5');
				santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
				santa.antialiasing = ClientPrefs.globalAntialiasing;
				boppersAlt.push(santa);
				add(santa);
			case 'mallSoft':
				var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('soft/christmas/bgWalls'));
				bg.antialiasing = ClientPrefs.globalAntialiasing;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				if(!ClientPrefs.lowQuality)
				{
					upperBoppers = new FlxSprite(-240, -90);
					if (songName == 'ugh-remix' || songName == 'hope') {			
						upperBoppers.frames = Paths.getSparrowAtlas('soft/christmas/angrybogosbinted');
					}
					else {		
						upperBoppers.frames = Paths.getSparrowAtlas('soft/christmas/normalfuckerspng');	
					}
					upperBoppers.animation.addByPrefix('idle', "Upper Crowd Bob", 24, false);
					upperBoppers.antialiasing = ClientPrefs.globalAntialiasing;
					upperBoppers.scrollFactor.set(0.33, 0.33);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					boppersAlt.push(upperBoppers);
					add(upperBoppers);
	
					var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image(pre+'/bgEscalator','week5'));
					bgEscalator.antialiasing = ClientPrefs.globalAntialiasing;
					bgEscalator.scrollFactor.set(0.3, 0.3);
					bgEscalator.active = false;
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);
				}


				var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image(pre+'/christmasTree','week5'));
				tree.antialiasing = ClientPrefs.globalAntialiasing;
				tree.scrollFactor.set(0.40, 0.40);
				add(tree);

				bottomBoppers = new FlxSprite(-300, 140);
				if (songName == 'ugh-remix' || songName == 'hope') {
					bottomBoppers.frames = Paths.getSparrowAtlas('soft/christmas/bopit');
				}
				else{
					bottomBoppers.frames = Paths.getSparrowAtlas('soft/christmas/bop1');
				}
				bottomBoppers.animation.addByPrefix('idle', 'Bottom Level Boppers', 24, false);
				bottomBoppers.antialiasing = ClientPrefs.globalAntialiasing;
				bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
				bottomBoppers.updateHitbox();
				boppersAlt.push(bottomBoppers);
				add(bottomBoppers);
				if (songName == 'ugh-remix')
				{
					var blantadBG2 = new FlxSprite(-300, 120);
					blantadBG2.frames = Paths.getSparrowAtlas('soft/christmas/allAloneRIP');
					blantadBG2.animation.addByPrefix('bop', 'blantad', 24, false);
					blantadBG2.antialiasing = true;
					blantadBG2.scrollFactor.set(0.9, 0.9);
					add(blantadBG2);
				}

				var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('soft/christmas/fgSnow'));
				fgSnow.active = false;
				fgSnow.antialiasing = ClientPrefs.globalAntialiasing;
				add(fgSnow);

				santa = new FlxSprite(-840, 150);
				santa.frames = Paths.getSparrowAtlas('soft/christmas/santa1');
				santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
				santa.antialiasing = ClientPrefs.globalAntialiasing;
				boppersAlt.push(santa);
				add(santa);

				if (songName == 'ugh-remix')
				{
					var bgPico:Character = new Character(1164, 426, 'pico-soft-christmas');
					boppers.push(bgPico);
					add(bgPico);

					var parentsChristmas:Character = new Character(-400, 110, 'parents-christmas-soft');
					boppers.push(parentsChristmas);
					add(parentsChristmas);

					var bgBoyfriend:Character = new Character(-400, 110, 'bf-christmas-soft');
					boppers.push(bgBoyfriend);
					add(bgBoyfriend);
				}
			case 'mallEvil' | 'mallAnnie':
				switch(curStage)
				{
					case 'mallEvil':
						pre = 'christmas';
						suf = 'week5';
					case 'mallAnnie':
						pre = 'annie';
						suf = 'week3';
				}
				var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image(pre+'/evilBG', suf));
				bg.antialiasing = ClientPrefs.globalAntialiasing;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image(pre+'/evilTree', suf));
				evilTree.antialiasing = ClientPrefs.globalAntialiasing;
				evilTree.scrollFactor.set(0.2, 0.2);
				add(evilTree);

				var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image(pre+'/evilSnow', suf));
				evilSnow.antialiasing = ClientPrefs.globalAntialiasing;
				add(evilSnow);
			case 'school'|'school-sad':
				gfVersion = 'gf-pixel';
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky'));
				bgSky.scrollFactor.set(0.1, 0.1);
				add(bgSky);

				var repositionShit = -200;

				var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool'));
				bgSchool.scrollFactor.set(0.6, 0.90);
				add(bgSchool);

				var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet'));
				bgStreet.scrollFactor.set(0.95, 0.95);
				add(bgStreet);


				var widShit = Std.int(bgSky.width * 6);

				if(!ClientPrefs.lowQuality) {
					var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack','week6'));
					fgTrees.scrollFactor.set(0.9, 0.9);
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					fgTrees.updateHitbox();
					add(fgTrees);
				}

				var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
				bgTrees.frames = Paths.getPackerAtlas('weeb/weebTrees');
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				add(bgTrees);

				if(!ClientPrefs.lowQuality) {
					var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
					treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals','week6');
					treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
					treeLeaves.animation.play('leaves');
					treeLeaves.scrollFactor.set(0.85, 0.85);
					treeLeaves.setGraphicSize(widShit);
					treeLeaves.updateHitbox();
					add(treeLeaves);
				}

				bgSky.setGraphicSize(widShit);
				bgSchool.setGraphicSize(widShit);
				bgStreet.setGraphicSize(widShit);
				bgTrees.setGraphicSize(Std.int(widShit * 1.4));
			
				bgSky.updateHitbox();
				bgSchool.updateHitbox();
				bgStreet.updateHitbox();
				bgTrees.updateHitbox();
				

				if(!ClientPrefs.lowQuality){
					bgGirls = new BackgroundGirls(-100, 190);
				    bgGirls.scrollFactor.set(0.9, 0.9);
					bgGirls.setGraphicSize(Std.int(bgGirls.width * PlayState.daPixelZoom));
				    bgGirls.updateHitbox();
					boppers.push(bgGirls);
					add(bgGirls);

					if (songName == 'roses'||curStage == 'school-sad'){
						bgGirls.getScared();
					}
				}
			case 'schoolnoon':
				var bgSky = new FlxSprite().loadGraphic(Paths.image('corruption/weeb/weebSkynoon'));
				bgSky.scrollFactor.set(0.1, 0.1);
				add(bgSky);

				var bgSkyEvil = new FlxSprite().loadGraphic(Paths.image('corruption/weeb/weebSkyEvil'));
				bgSkyEvil.scrollFactor.set(0.1, 0.1);
				bgSkyEvil.alpha = 0;
				add(bgSkyEvil);

				var repositionShit = -200;

				var bgSchool = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('corruption/weeb/weebSchoolnoon'));
				bgSchool.scrollFactor.set(0.6, 0.90);
				add(bgSchool);

				var bgSchoolEvil = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('corruption/weeb/weebSchoolEvil'));
				bgSchoolEvil.scrollFactor.set(0.6, 0.90);
				bgSchoolEvil.alpha = 0;
				add(bgSchoolEvil);

				var bgStreet = new FlxSprite(repositionShit).loadGraphic(Paths.image('corruption/weeb/weebStreetnoon'));
				bgStreet.scrollFactor.set(0.95, 0.95);
				add(bgStreet);

				var bgStreetEvil = new FlxSprite(repositionShit).loadGraphic(Paths.image('corruption/weeb/weebStreetEvil'));
				bgStreetEvil.scrollFactor.set(0.95, 0.95);
				bgStreetEvil.alpha = 0;
				add(bgStreetEvil);

				var fgTrees = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('corruption/weeb/weebTreesBacknoon'));
				fgTrees.scrollFactor.set(0.9, 0.9);
				add(fgTrees);

				var fgTreesEvil = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('corruption/weeb/weebTreesBackEvil'));
				fgTreesEvil.scrollFactor.set(0.9, 0.9);
				fgTreesEvil.alpha = 0;
				add(fgTreesEvil);

				var bgTrees = new FlxSprite(repositionShit - 380, -800);
				bgTrees.frames = Paths.getPackerAtlas('corruption/weeb/weebTreesnoon');
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				add(bgTrees);

				var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
				treeLeaves.frames = Paths.getSparrowAtlas('corruption/weeb/petalsnoon');
				treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
				treeLeaves.animation.play('leaves');
				treeLeaves.scrollFactor.set(0.85, 0.85);
				add(treeLeaves);

				var widShit = Std.int(bgSky.width * 6);

				bgSky.setGraphicSize(widShit);
				bgSchool.setGraphicSize(widShit);
				bgStreet.setGraphicSize(widShit);
				bgTrees.setGraphicSize(Std.int(widShit * 1.4));
				fgTrees.setGraphicSize(Std.int(widShit * 0.8));
				treeLeaves.setGraphicSize(widShit);
				bgSkyEvil.setGraphicSize(widShit);
				bgSchoolEvil.setGraphicSize(widShit);
				fgTreesEvil.setGraphicSize(Std.int(widShit * 0.8));
				bgStreetEvil.setGraphicSize(widShit);

				fgTrees.updateHitbox();
				bgSky.updateHitbox();
				bgSchool.updateHitbox();
				bgStreet.updateHitbox();
				bgTrees.updateHitbox();
				treeLeaves.updateHitbox();
				fgTreesEvil.updateHitbox();
				bgSkyEvil.updateHitbox();
				bgSchoolEvil.updateHitbox();
				bgStreetEvil.updateHitbox();				
			case 'schoolEvil' | 'schoolEvild4':
				switch(curStage)
				{
					case 'schoolEvild4':
						pre = 'corruption/weeb/animatedEvilSchool';
						suf = 'shared';
					case 'schoolEvil':
						pre = 'weeb/animatedEvilSchool';
						suf = 'week6';
				}
				gfVersion = 'gf-pixel';
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				var posX = 400;
				var posY = 200;
				var bg:FlxSprite = new FlxSprite(posX, posY);
				if(!ClientPrefs.lowQuality) {
					bg.frames = Paths.getSparrowAtlas(pre, suf);
					bg.animation.addByPrefix('idle', 'background 2', 24);
					bg.animation.play('idle', true);
					bg.scrollFactor.set(0.8, 0.9);
					bg.scale.set(6, 6);
					add(bg);

					bgGhouls = new BGSprite('weeb/bgGhouls','week6', -100, 190, 0.9, 0.9, ['BG freaks glitch instance'], false);
					bgGhouls.setGraphicSize(Std.int(bgGhouls.width * PlayState.daPixelZoom));
					bgGhouls.updateHitbox();
					bgGhouls.visible = false;
					bgGhouls.antialiasing = false;
					add(bgGhouls);
				}
				else
				{
					bg.loadGraphic(Paths.image('weeb/animatedEvilSchool_low','week6'));
					bg.scrollFactor.set(0.8, 0.9);
					bg.scale.set(6, 6);
					add(bg);
				}
			case 'tank':
				gfVersion = 'gf-tankmen';
				if(PlayState.instance.boyfriend.curCharacter == 'bf-holding-gf')
				{
					GameOverSubstate.characterName = 'bf-holding-gf-dead';
				}
				
				var tankSky = new FlxSprite(-400, -400).loadGraphic(Paths.image('tank/tankSky', 'week7'));
				tankSky.antialiasing = ClientPrefs.globalAntialiasing;
				tankSky.scrollFactor.set(0, 0);
				tankSky.setGraphicSize(Std.int(tankSky.width * 2.7));
				tankSky.active = false;
				add(tankSky);

				var tankClouds = new FlxSprite(-700, -100).loadGraphic(Paths.image('tank/tankClouds', 'week7'));
				tankClouds.antialiasing = ClientPrefs.globalAntialiasing;
				tankClouds.scrollFactor.set(0.1, 0.1);
				tankClouds.active = true;
				tankClouds.velocity.x = FlxG.random.float(5, 15);
				add(tankClouds);

				var tankMountains = new FlxSprite(-300, -20).loadGraphic(Paths.image('tank/tankMountains', 'week7'));
				tankMountains.antialiasing = ClientPrefs.globalAntialiasing;
				tankMountains.scrollFactor.set(0.2, 0.2);
				tankMountains.setGraphicSize(Std.int(tankMountains.width * 1.1));
				tankMountains.active = false;
				tankMountains.updateHitbox();
				add(tankMountains);
			
				var tankBuildings = new FlxSprite(-200, 0).loadGraphic(Paths.image('tank/tankBuildings', 'week7'));
				tankBuildings.antialiasing = ClientPrefs.globalAntialiasing;
				tankBuildings.scrollFactor.set(0.3, 0.3);
				tankBuildings.setGraphicSize(Std.int(tankBuildings.width * 1.1));
				tankBuildings.active = false;
				add(tankBuildings);


				var tankRuins = new FlxSprite(-200, 0).loadGraphic(Paths.image('tank/tankRuins', 'week7'));
				tankRuins.antialiasing = ClientPrefs.globalAntialiasing;
				tankRuins.scrollFactor.set(0.35, 0.36);
				tankRuins.setGraphicSize(Std.int(tankRuins.width * 1.1));
				tankRuins.active = false;
				add(tankRuins);					
			
				if (!ClientPrefs.lowQuality) {
					var smokeLeft = new FlxSprite(-200, -100);
					smokeLeft.frames = Paths.getSparrowAtlas('tank/smokeLeft', 'week7');
					smokeLeft.animation.addByPrefix('idle', 'SmokeBlurLeft', 24, true);
					smokeLeft.animation.play('idle', true);
					smokeLeft.scrollFactor.set (0.4, 0.4);
					smokeLeft.antialiasing = ClientPrefs.globalAntialiasing;
					add(smokeLeft);
				
					var smokeRight = new FlxSprite(1100, -100);
					smokeRight.frames = Paths.getSparrowAtlas('tank/smokeRight', 'week7');
					smokeRight.animation.addByPrefix('idle', 'SmokeRight', 24, true);
					smokeRight.animation.play('idle', true);
					smokeRight.scrollFactor.set (0.4, 0.4);
					smokeRight.antialiasing = ClientPrefs.globalAntialiasing;
					add(smokeRight);
				}

				if(!ClientPrefs.lowQuality)
				{
					watchtower = new FlxSprite(100, 50);
					watchtower.frames = Paths.getSparrowAtlas('tank/tankWatchtower', 'week7');
					watchtower.animation.addByPrefix('idle', 'watchtower gradient color instance ', 24, false);
					watchtower.antialiasing = ClientPrefs.globalAntialiasing;
					watchtower.scrollFactor.set(0.5, 0.5);
					watchtower.setGraphicSize(Std.int(watchtower.width * 1.2));
					watchtower.antialiasing = ClientPrefs.globalAntialiasing;
					boppersAlt.push(watchtower);
					add(watchtower);
				}

			
				tankRolling = new FlxSprite(300,300);
				tankRolling.frames = Paths.getSparrowAtlas('tank/tankRolling', 'week7');
				tankRolling.animation.addByPrefix('idle', 'BG tank w lighting instance ', 24, true);
				tankRolling.scrollFactor.set(0.5, 0.5);
				tankRolling.antialiasing = ClientPrefs.globalAntialiasing;
				tankRolling.animation.play('idle');
				add(tankRolling);
			
				var tankGround = new FlxSprite(-420, -150).loadGraphic(Paths.image('tank/tankGround', 'week7'));
				tankGround.antialiasing = ClientPrefs.globalAntialiasing;
				tankGround.setGraphicSize(Std.int(tankGround.width * 1.15));
				tankGround.active = false;
				tankGround.updateHitbox();
				add(tankGround);

				if(!ClientPrefs.lowQuality)
				{
					tank0 = new FlxSprite(-500, 650);
					tank0.frames = Paths.getSparrowAtlas('tank/tank0', 'week7');
					tank0.animation.addByPrefix('idle', 'fg tankhead far right instance', 24, false);
					tank0.antialiasing = ClientPrefs.globalAntialiasing;
					boppersAlt.push(tank0);
					layers.get("boyfriend").add(tank0);
	
					tank1 = new FlxSprite(-300, 750);
					tank1.frames = Paths.getSparrowAtlas('tank/tank1', 'week7');
					tank1.animation.addByPrefix('idle', 'fg tankhead 5 instance ', 24, false);
					tank1.scrollFactor.set(2, 0.2);
					tank1.antialiasing = ClientPrefs.globalAntialiasing;
					boppersAlt.push(tank1);
					layers.get("boyfriend").add(tank1);
					
					tank2 = new FlxSprite(450, 940);
					tank2.frames = Paths.getSparrowAtlas('tank/tank2', 'week7');
					tank2.animation.addByPrefix('idle', 'foreground man 3 instance ', 24, false);
					tank2.scrollFactor.set(1.5, 1.5);
					tank2.antialiasing = ClientPrefs.globalAntialiasing;
					boppersAlt.push(tank2);
					layers.get("boyfriend").add(tank2);
					
					tank4 = new FlxSprite(1300, 900);
					tank4.frames = Paths.getSparrowAtlas('tank/tank4', 'week7');
					tank4.animation.addByPrefix('idle', 'fg tankman bobbin 3 instance ', 24, false);
					tank4.scrollFactor.set(1.5, 1.5);
					tank4.antialiasing = ClientPrefs.globalAntialiasing;
					boppersAlt.push(tank4);
					layers.get("boyfriend").add(tank4);
				
					tank5 = new FlxSprite(1620, 700);
					tank5.frames = Paths.getSparrowAtlas('tank/tank5', 'week7');
					tank5.animation.addByPrefix('idle', 'fg tankhead far right instance ', 24, false);
					tank5.scrollFactor.set(1.5, 1.5);
					tank5.antialiasing = ClientPrefs.globalAntialiasing;
					boppersAlt.push(tank5);
					layers.get("boyfriend").add(tank5);
					
					tank3 = new FlxSprite(1300, 1200);
					tank3.frames = Paths.getSparrowAtlas('tank/tank3', 'week7');
					tank3.animation.addByPrefix('idle', 'fg tankhead 4 instance ', 24, false);
					tank3.scrollFactor.set(1.5, 1.5);
					tank3.antialiasing = ClientPrefs.globalAntialiasing;
					boppersAlt.push(tank3);
					layers.get("boyfriend").add(tank3);
				}
			case 'night' | 'night2':
				defaultCamZoom = 0.75;

				theEntireFuckingStage = new FlxTypedGroup<FlxSprite>();
				add(theEntireFuckingStage);

				var bg1:FlxSprite = new FlxSprite(-970, -580).loadGraphic(Paths.image('b&b/night/BG1', 'shared'));
				bg1.antialiasing = true;
				bg1.scale.set(0.8, 0.8);
				bg1.scrollFactor.set(0.3, 0.3);
				bg1.active = false;
				theEntireFuckingStage.add(bg1);

				var bg2:FlxSprite = new FlxSprite(-1240, -650).loadGraphic(Paths.image('b&b/night/BG2', 'shared'));
				bg2.antialiasing = true;
				bg2.scale.set(0.5, 0.5);
				bg2.scrollFactor.set(0.6, 0.6);
				bg2.active = false;
				theEntireFuckingStage.add(bg2);

				if (curStage == 'night2')
				{
					mini = new FlxSprite(818, 189);
					mini.frames = Paths.getSparrowAtlas('b&b/night/bobsip','shared');
					mini.animation.addByPrefix('idle', 'bobsip', 24, false);
					mini.animation.play('idle');
					mini.scale.set(0.5, 0.5);
					mini.scrollFactor.set(0.6, 0.6);
					boppersAlt.push(mini);
					theEntireFuckingStage.add(mini);			
				}

				var bg3:FlxSprite = new FlxSprite(-630, -330).loadGraphic(Paths.image('b&b/night/BG3', 'shared'));
				bg3.antialiasing = true;
				bg3.scale.set(0.8, 0.8);
				bg3.active = false;
				theEntireFuckingStage.add(bg3);

				var bg4:FlxSprite = new FlxSprite(-1390, -740).loadGraphic(Paths.image('b&b/night/BG4', 'shared'));
				bg4.antialiasing = true;
				bg4.scale.set(0.6, 0.6);
				bg4.active = false;
				theEntireFuckingStage.add(bg4);

				var bg5:FlxSprite = new FlxSprite(-34, 90);
				bg5.antialiasing = true;
				bg5.scale.set(1.4, 1.4);
				bg5.frames = Paths.getSparrowAtlas('b&b/night/pixelthing', 'shared');
				bg5.animation.addByPrefix('idle', 'pixelthing', 24);
				bg5.animation.play('idle');
				add(bg5);

				var pc = new FlxSprite(115, 166);
				pc.frames = Paths.getSparrowAtlas('characters/pc', 'shared');
				pc.animation.addByPrefix('idle', 'PC idle', 24, false);
				pc.animation.addByPrefix('singUP', 'PC Note UP', 24, false);
				pc.animation.addByPrefix('singDOWN', 'PC Note DOWN', 24, false);
				pc.animation.addByPrefix('singLEFT', 'PC Note LEFT', 24, false);
				pc.animation.addByPrefix('singRIGHT', 'PC Note RIGHT', 24, false);
				add(pc);


				phillyCityLights = new FlxTypedGroup<FlxSprite>(); //I wonder this Events works for nights
				add(phillyCityLights);

				coolGlowyLights = new FlxTypedGroup<FlxSprite>();
				add(coolGlowyLights);

				coolGlowyLightsMirror = new FlxTypedGroup<FlxSprite>();
				add(coolGlowyLightsMirror);

				for (i in 0...4)
				{
					var light:FlxSprite = new FlxSprite().loadGraphic(Paths.image('b&b/night/light' + i, 'shared'));
					light.scrollFactor.set(0, 0);
					light.cameras = [PlayState.instance.camHUD];
					light.visible = false;
					light.updateHitbox();
					light.antialiasing = true;
					phillyCityLights.add(light);

					var glow:FlxSprite = new FlxSprite().loadGraphic(Paths.image('b&b/night/Glow' + i, 'shared'));
					glow.scrollFactor.set(0, 0);
					glow.cameras = [PlayState.instance.camHUD];
					glow.visible = false;
					glow.updateHitbox();
					glow.antialiasing = true;
					coolGlowyLights.add(glow);

					var glow2:FlxSprite = new FlxSprite().loadGraphic(Paths.image('b&b/night/Glow' + i, 'shared'));
					glow2.scrollFactor.set(0, 0);
					glow2.cameras = [PlayState.instance.camHUD];
					glow2.visible = false;
					glow2.updateHitbox();
					glow2.antialiasing = true;
					coolGlowyLightsMirror.add(glow2);
				}


				if(!PlayState.instance.modchartSprites.exists('blammedLightsBlack')) {  
					//Creates blammed light black fade in case you didn't make your own
					blammedLightsBlack = new ModchartSprite(FlxG.width * -0.5, FlxG.height * -0.5);
					blammedLightsBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					var position:Int = PlayState.instance.members.indexOf(PlayState.instance.gfGroup);
					if(PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup) < position) {
						position = PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup);
					} else if(PlayState.instance.members.indexOf(PlayState.instance.dadGroup) < position) {
						position = PlayState.instance.members.indexOf(PlayState.instance.dadGroup);
					}
					PlayState.instance.insert(position, blammedLightsBlack);
		
					blammedLightsBlack.wasAdded = true;
					PlayState.instance.modchartSprites.set('blammedLightsBlack', blammedLightsBlack);
			    }
			    PlayState.instance.insert(members.indexOf(blammedLightsBlack) + 1, phillyCityLightsEvent);
			    blammedLightsBlack = PlayState.instance.modchartSprites.get('blammedLightsBlack');
			    blammedLightsBlack.alpha = 0.0;


				phillyCityLightsEvent = new FlxTypedGroup<FlxSprite>();
				layers.get("foreground").add(phillyCityLightsEvent);

				for (i in 0...4)
				{
					var light:FlxSprite = new FlxSprite().loadGraphic(Paths.image('b&b/night/light' + i, 'shared'));
					light.scrollFactor.set(0, 0);
					light.cameras = [PlayState.instance.camHUD];
					light.visible = false;
					light.updateHitbox();
					light.antialiasing = true;
					phillyCityLightsEvent.add(light);
				}

				areYouReady = new FlxTypedGroup<FlxSprite>();
				add(areYouReady);

				for (i in 0...3) {
					var shit:FlxSprite = new FlxSprite();
					switch (i) {
						case 0:
							shit = new FlxSprite().loadGraphic(Paths.image('b&b/ARE', 'shared'));
						case 1:
							shit = new FlxSprite().loadGraphic(Paths.image('b&b/YOU', 'shared'));
						case 2:
							shit = new FlxSprite().loadGraphic(Paths.image('b&b/READY', 'shared'));
					}
					shit.cameras = [PlayState.instance.camHUD];
					shit.visible = false;
					areYouReady.add(shit);
				}
			case 'day':
				var bg1:FlxSprite = new FlxSprite(-970, -580).loadGraphic(Paths.image('b&b/day/BG1', 'shared'));
				bg1.antialiasing = true;
				bg1.scale.set(0.8, 0.8);
				bg1.scrollFactor.set(0.3, 0.3);
				bg1.active = false;
				add(bg1);

				var bg2:FlxSprite = new FlxSprite(-1240, -650).loadGraphic(Paths.image('b&b/day/BG2', 'shared'));
				bg2.antialiasing = true;
				bg2.scale.set(0.5, 0.5);
				bg2.scrollFactor.set(0.6, 0.6);
				bg2.active = false;
				add(bg2);

				var mini = new FlxSprite(849, 189);
				mini.frames = Paths.getSparrowAtlas('b&b/day/mini','shared');
				mini.animation.addByPrefix('idle', 'mini', 24, false);
				mini.animation.play('idle');
				mini.scale.set(0.4, 0.4);
				mini.scrollFactor.set(0.6, 0.6);
				boppersAlt.push(mini);
				add(mini);

				mordecai = new FlxSprite(130, 160);
				mordecai.frames = Paths.getSparrowAtlas('b&b/day/bluskystv','shared');
				mordecai.animation.addByIndices('walk1', 'bluskystv', [29, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13] , '', 24, false);
				mordecai.animation.addByIndices('walk2', 'bluskystv', [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28] , '', 24, false);
				mordecai.animation.play('walk1');
				mordecai.scale.set(0.4, 0.4);
				mordecai.scrollFactor.set(0.6, 0.6);
				add(mordecai);

				var bg3:FlxSprite = new FlxSprite(-630, -330).loadGraphic(Paths.image('b&b/day/BG3', 'shared'));
				bg3.antialiasing = true;
				bg3.scale.set(0.8, 0.8);
				bg3.active = false;
				add(bg3);
				
				phillyTrain = new FlxSprite(2000, 200).loadGraphic(Paths.image('b&b/day/PP_truck','shared'));
				phillyTrain.scale.set(1.2, 1.2);
				add(phillyTrain);
			case 'takiStage':
				defaultCamZoom = 0.6;

				var bg:FlxSprite = new FlxSprite(-200, -100).loadGraphic(Paths.image('fever/week2bgtaki'));
				bg.antialiasing = true;
				add(bg);

				var moreDark = new FlxSprite(0, 0).loadGraphic(Paths.image('fever/effectShit/evenMOREdarkShit'));
				moreDark.cameras = [PlayState.instance.camHUD];
				layers.get("boyfriend").add(moreDark);
			case 'polus' | 'polus2':
				var sky:FlxSprite = new FlxSprite(-834.3, -620.5).loadGraphic(Paths.image('impostor/polus/polusSky'));
				sky.antialiasing = true;
				sky.scrollFactor.set(0.5, 0.5);
				sky.active = false;
				add(sky);

				var rocks:FlxSprite = new FlxSprite(-915.8, -411.3).loadGraphic(Paths.image('impostor/polus/polusrocks'));
				rocks.updateHitbox();
				rocks.antialiasing = true;
				rocks.scrollFactor.set(0.6, 0.6);
				rocks.active = false;
				add(rocks);
				
				var hills:FlxSprite = new FlxSprite(-1238.05, -180.55).loadGraphic(Paths.image('impostor/polus/polusHills'));
				hills.updateHitbox();
				hills.antialiasing = true;
				hills.scrollFactor.set(0.9, 0.9);
				hills.active = false;
				add(hills);

				var warehouse:FlxSprite = new FlxSprite(-458.35, -315.6).loadGraphic(Paths.image('impostor/polus/polusWarehouse'));
				warehouse.updateHitbox();
				warehouse.antialiasing = true;
				warehouse.scrollFactor.set(0.9, 0.9);
				warehouse.active = false;
				add(warehouse);

				if (curStage == 'polus2')
				{
					var crowd:FlxSprite = new FlxSprite(-280.5, 240.8);
					crowd.frames = Paths.getSparrowAtlas('impostor/polus/CrowdBop');
					crowd.animation.addByPrefix('idle', 'CrowdBop', 24, false);
					crowd.animation.play('idle');
					crowd.scrollFactor.set(1, 1);
					crowd.antialiasing = true;
					crowd.updateHitbox();
					crowd.scale.set(1.5, 1.5);
					boppersAlt.push(crowd);
					add(crowd);
					
					var deadBF = new FlxSprite(532.95, 465.95).loadGraphic(Paths.image('impostor/polus/bfdead'));
					deadBF.antialiasing = true;
					deadBF.scrollFactor.set(1, 1);
					deadBF.updateHitbox();	
					layers.get('deadBF').add(deadBF);
				}

				var ground:FlxSprite = new FlxSprite(-580.9, 241.85).loadGraphic(Paths.image('impostor/polus/polusGround'));
				ground.updateHitbox();
				ground.antialiasing = true;
				ground.scrollFactor.set(1, 1);
				ground.active = false;
				add(ground);
			case 'reactor' | 'reactor-m':
				defaultCamZoom = 0.5;
				
				var bg:FlxSprite = new FlxSprite(-2300,-1700).loadGraphic(Paths.image('impostor/reactor/reactor background'));
				bg.setGraphicSize(Std.int(bg.width * 0.7));
				bg.antialiasing = true;
				bg.scrollFactor.set(1, 1);
				bg.active = false;
				add(bg);

				if (curStage == 'reactor')
				{
					var yellow = new FlxSprite(-400, 150);
					yellow.frames = Paths.getSparrowAtlas('impostor/reactor/susBoppers');
					yellow.animation.addByPrefix('idle', 'yellow sus', 24, false);
					yellow.animation.play('idle');
					yellow.setGraphicSize(Std.int(yellow.width * 0.7));
					yellow.antialiasing = true;
					yellow.scrollFactor.set(1, 1);
					yellow.active = true;
					add(yellow);
				}
	
				var pillar1:FlxSprite = new FlxSprite(-2300,-1700).loadGraphic(Paths.image('impostor/reactor/back pillars'));
				pillar1.setGraphicSize(Std.int(pillar1.width * 0.7));
				pillar1.antialiasing = true;
				pillar1.scrollFactor.set(1, 1);
				pillar1.active = false;
				add(pillar1);

				if (curStage == 'reactor')
				{
					var dripster = new FlxSprite(1375, 150);
					dripster.frames = Paths.getSparrowAtlas('impostor/reactor/susBoppers');
					dripster.animation.addByPrefix('idle', 'blue sus', 24, false);
					dripster.animation.play('idle');
					dripster.setGraphicSize(Std.int(dripster.width * 0.7));
					dripster.antialiasing = true;
					dripster.scrollFactor.set(1, 1);
					dripster.active = true;
					add(dripster);
				}
				
				var pillar2:FlxSprite = new FlxSprite(-2300,-1700).loadGraphic(Paths.image('impostor/reactor/middle pillars'));
				pillar2.setGraphicSize(Std.int(pillar2.width * 0.7));
				pillar2.antialiasing = true;
				pillar2.scrollFactor.set(1, 1);
				pillar2.active = false;
				add(pillar2);

				if (curStage == 'reactor')
				{
					amogus = new FlxSprite(1670, 250);
					amogus.frames = Paths.getSparrowAtlas('impostor/reactor/susBoppers');
					amogus.animation.addByPrefix('idle', 'white sus', 24, false);
					amogus.animation.play('idle');
					amogus.setGraphicSize(Std.int(amogus.width * 0.7));
					amogus.antialiasing = true;
					amogus.scrollFactor.set(1, 1);
					amogus.active = true;
					add(amogus); //STOP POSTING ABOUT AMONG US AHHHHH

					brown = new FlxSprite(-850, 190);
					brown.frames = Paths.getSparrowAtlas('impostor/reactor/susBoppers');
					brown.animation.addByPrefix('idle', 'brown sus', 24, false);
					brown.animation.play('idle');
					brown.setGraphicSize(Std.int(brown.width * 0.7));
					brown.antialiasing = true;
					brown.scrollFactor.set(1, 1);
					brown.active = true;
					add(brown);
				}

				var pillar3:FlxSprite = new FlxSprite(-2300,-1700).loadGraphic(Paths.image('impostor/reactor/front pillars'));
				pillar3.setGraphicSize(Std.int(pillar3.width * 0.7));
				pillar3.antialiasing = true;
				pillar3.scrollFactor.set(1, 1);
				pillar3.active = false;
				add(pillar3);

				var path:String;
				if (curStage == 'reactor-m')
					path = 'the device';
				else
					path = 'ball of big ol energy';

				orb = new FlxSprite(-460,-1300).loadGraphic('impostor/reactor/'+path);
				orb.setGraphicSize(Std.int(orb.width * 0.7));
				orb.antialiasing = true;
				orb.scrollFactor.set(1, 1);
				orb.active = false;
				add(orb);

				var cranes:FlxSprite = new FlxSprite(-735, -1500).loadGraphic(Paths.image('impostor/reactor/upper cranes'));
				cranes.setGraphicSize(Std.int(cranes.width * 0.7));
				cranes.antialiasing = true;
				cranes.scrollFactor.set(1, 1);
				cranes.active = false;
				add(cranes);

				var console1:FlxSprite = new FlxSprite(-260,150).loadGraphic(Paths.image('impostor/reactor/center console'));
				console1.setGraphicSize(Std.int(console1.width * 0.7));
				console1.antialiasing = true;
				console1.scrollFactor.set(1, 1);
				console1.active = false;
				add(console1);

				if (curStage == 'reactor-m')
				{
					fortnite1 = new FlxSprite();
					fortnite1.frames = Paths.getSparrowAtlas('impostor/reactor/fortnite1');
					fortnite1.animation.addByPrefix('idle', 'Bottom Level Boppers', 24, false);
					fortnite1.animation.play('idle');
					fortnite1.antialiasing = true;
					fortnite1.scrollFactor.set(1, 1);
					fortnite1.active = true;
					fortnite1.setPosition(-850, -200);
					add(fortnite1);

					fortnite2 = new FlxSprite();
					fortnite2.frames = Paths.getSparrowAtlas('impostor/reactor/fortnite2');
					fortnite2.animation.addByPrefix('idle', 'Bottom Level Boppers', 24, false);
					fortnite2.animation.play('idle');
					fortnite2.antialiasing = true;
					fortnite2.scrollFactor.set(1, 1);
					fortnite2.active = true;
					fortnite2.setPosition(1000, -200);
					add(fortnite2);
				}

				var console2:FlxSprite = new FlxSprite(-1380,450).loadGraphic(Paths.image('impostor/reactor/side console'));
				console2.setGraphicSize(Std.int(console2.width * 0.7));
				console2.antialiasing = true;
				console2.scrollFactor.set(1, 1);
				console2.active = false;
				add(console2);
				
				ass2 = new FlxSprite(0, FlxG.height * 1).loadGraphic(Paths.image('impostor/vignette')); 
				ass2.scrollFactor.set();
				ass2.screenCenter();
				ass2.cameras = [PlayState.instance.camHUD];
				layers.get("boyfriend").add(ass2);
			case 'bfroom':
				var bg = new FlxSprite().loadGraphic(Paths.image('bg_doxxie'));
				bg.setPosition(-184.35, -315.45);
				add(bg);
			case 'gfroom':
				var sky:FlxSprite = new FlxSprite(100, 100).loadGraphic(Paths.image('philly/sky', 'week3'));
				sky.scrollFactor.set(1, 1);
				sky.setGraphicSize(Std.int(sky.width * 0.7));
				sky.updateHitbox();
				add(sky);

				var city:FlxSprite = new FlxSprite(190, 100).loadGraphic(Paths.image('philly/city', 'week3'));
				city.scrollFactor.set(1, 1);
				city.setGraphicSize(Std.int(city.width * 0.55));
				city.updateHitbox();
				add(city);

				phillyCityLights = new FlxTypedGroup<FlxSprite>();
				add(phillyCityLights);

				for (i in 0...5)
				{
					var light:FlxSprite = new FlxSprite(city.x, city.y).loadGraphic(Paths.image('philly/win' + i, 'week3'));
					light.scrollFactor.set(1, 1);
					light.visible = false;
					light.setGraphicSize(Std.int(light.width * 0.55));
					light.updateHitbox();
					light.antialiasing = true;
					phillyCityLights.add(light);
				}

				var bg = new FlxSprite(-600, -200).loadGraphic(Paths.image('RoomBG'));
				bg.setGraphicSize(Std.int(bg.width * 1.8));
				bg.updateHitbox();
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);

				var tv = new FlxSprite(-370, 148).loadGraphic(Paths.image('tvLight'));
				tv.setGraphicSize(Std.int(tv.width * 1.8));
				tv.updateHitbox();
				tv.antialiasing = true;
				tv.scrollFactor.set(0.9, 0.9);
				tv.active = false;
				add(tv);

				if (songName == 'you-cant-run')
				{
					var tv2 = new FlxSprite(-370, 148).loadGraphic(Paths.image('tvSchool'));
					tv2.setGraphicSize(Std.int(tv2.width * 1.8));
					tv2.updateHitbox();
					tv2.antialiasing = true;
					tv2.scrollFactor.set(0.9, 0.9);
					tv2.active = false;
					add(tv2);
				}

				if(!PlayState.instance.modchartSprites.exists('blammedLightsBlack')) {  
					//Creates blammed light black fade in case you didn't make your own
					blammedLightsBlack = new ModchartSprite(FlxG.width * -0.5, FlxG.height * -0.5);
					blammedLightsBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					var position:Int = PlayState.instance.members.indexOf(PlayState.instance.gfGroup);
					if(PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup) < position) {
						position = PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup);
					} else if(PlayState.instance.members.indexOf(PlayState.instance.dadGroup) < position) {
						position = PlayState.instance.members.indexOf(PlayState.instance.dadGroup);
					}
					PlayState.instance.insert(position, blammedLightsBlack);
		
					blammedLightsBlack.wasAdded = true;
					PlayState.instance.modchartSprites.set('blammedLightsBlack', blammedLightsBlack);
			    }
			    PlayState.instance.insert(members.indexOf(blammedLightsBlack) + 1, phillyCityLightsEvent);
			    blammedLightsBlack = PlayState.instance.modchartSprites.get('blammedLightsBlack');
			    blammedLightsBlack.alpha = 0.0;


				phillyCityLightsEvent = new FlxTypedGroup<FlxSprite>();
				layers.get("foreground").add(phillyCityLightsEvent);

				for (i in 0...4)
				{
					var light:FlxSprite = new FlxSprite(city.x, city.y).loadGraphic(Paths.image('philly/win' + i, 'week3'));
					light.scrollFactor.set(1, 1);
					light.visible = false;
					light.setGraphicSize(Std.int(light.width * 0.55));
					light.updateHitbox();
					light.antialiasing = true;
					phillyCityLightsEvent.add(light);
				}
			case 'pillars':
				var white:FlxSprite = new FlxSprite().makeGraphic(FlxG.width * 5, FlxG.height * 5, FlxColor.fromRGB(255, 230, 230));
				white.screenCenter();
				white.scrollFactor.set();
				add(white);

				var void:FlxSprite = new FlxSprite(0, 0);
				void.frames = Paths.getSparrowAtlas('entity/agoti/the_void');
				void.animation.addByPrefix('move', 'VoidShift', 50, true);
				void.animation.play('move');
				void.setGraphicSize(Std.int(void.width * 2.5));
				void.screenCenter();
				void.y += 250;
				void.x += 55;
				void.antialiasing = true;
				void.scrollFactor.set(0.7, 0.7);
				add(void);

				var bgpillar:FlxSprite = new FlxSprite(-1000, -700);
				bgpillar.frames = Paths.getSparrowAtlas('entity/agoti/Pillar_BG_Stage');
				bgpillar.animation.addByPrefix('move', 'Pillar_BG', 24, true);
				bgpillar.animation.play('move');
				bgpillar.setGraphicSize(Std.int(bgpillar.width * 1.25));
				bgpillar.antialiasing = true;
				bgpillar.scrollFactor.set(0.7, 0.7);
				add(bgpillar);

				if (songName == 'crucify')
				{
					var rock:FlxSprite = new FlxSprite().loadGraphic(Paths.image('entity/agoti/rock', 'shared'));
					rock.setPosition(600,250);
					rock.scrollFactor.set(0.95, 0.95);
					add(rock);
				}

				speaker = new FlxSprite(-650, 600);
				speaker.frames = Paths.getSparrowAtlas('entity/agoti/LoudSpeaker_Moving');
				speaker.animation.addByPrefix('bop', 'StereoMoving', 24, false);
				speaker.updateHitbox();
				speaker.antialiasing = true;
				add(speaker);
			case 'Doki-club-room':
				var arrayPostions:Array<Float> = [-700, -520];

				deskfront = new FlxSprite(arrayPostions[0], arrayPostions[1]).loadGraphic(Paths.image('doki/clubroom/DesksFront'));
				deskfront.setGraphicSize(Std.int(deskfront.width * 1.6));
				deskfront.updateHitbox();
				deskfront.antialiasing = true;
				deskfront.scrollFactor.set(1.3, 0.9);
				layers.get("boyfriend").add(deskfront);

				var closet:FlxSprite = new FlxSprite(arrayPostions[0], arrayPostions[1]).loadGraphic(Paths.image('doki/clubroom/DDLCfarbg'));
				closet.setGraphicSize(Std.int(closet.width * 1.6));
				closet.updateHitbox();
				closet.antialiasing = true;
				closet.scrollFactor.set(0.9, 0.9);
				add(closet);

				var clubroom:FlxSprite = new FlxSprite(arrayPostions[0], arrayPostions[1]).loadGraphic(Paths.image('doki/clubroom/DDLCbg'));
				clubroom.setGraphicSize(Std.int(clubroom.width * 1.6));
				clubroom.updateHitbox();
				clubroom.antialiasing = true;
				clubroom.scrollFactor.set(1, 0.9);
				add(clubroom);



				if(!ClientPrefs.lowQuality)
				{
					monika = new FlxSprite(0, 0);
					monika.frames = Paths.getSparrowAtlas('doki/bgdoki/monika');
					monika.animation.addByPrefix('idle', "Moni BG", 24, false);
					monika.antialiasing = true;
					monika.scrollFactor.set(1, 0.9);
					monika.setGraphicSize(Std.int(monika.width * 0.7));
					monika.updateHitbox();
	
					sayori = new FlxSprite(0, 0);
					sayori.frames = Paths.getSparrowAtlas('doki/bgdoki/sayori');
					sayori.animation.addByPrefix('idle', "Sayori BG", 24, false);
					sayori.antialiasing = true;
					sayori.scrollFactor.set(1, 0.9);
					sayori.setGraphicSize(Std.int(sayori.width * 0.7));
					sayori.updateHitbox();
	
					natsuki = new FlxSprite(0, 0);
					natsuki.frames = Paths.getSparrowAtlas('doki/bgdoki/natsuki');
					natsuki.animation.addByPrefix('idle', "Natsu BG", 24, false);
					natsuki.antialiasing = true;
					natsuki.scrollFactor.set(1, 0.9);
					natsuki.setGraphicSize(Std.int(natsuki.width * 0.7));
					natsuki.updateHitbox();
	
					protag = new FlxSprite(0, 0);
					protag.frames = Paths.getSparrowAtlas('doki/bgdoki/protag');
					protag.animation.addByPrefix('idle', "Protag-kun BG", 24, false);
					protag.antialiasing = true;
					protag.scrollFactor.set(1, 0.9);
					protag.setGraphicSize(Std.int(protag.width * 0.7));
					protag.updateHitbox();
	
					yuri = new FlxSprite(0, 0);
					yuri.frames = Paths.getSparrowAtlas('doki/bgdoki/yuri');
					yuri.animation.addByPrefix('idle', "Yuri BG", 24, false);
					yuri.antialiasing = true;
					yuri.scrollFactor.set(1, 0.9);
					yuri.setGraphicSize(Std.int(yuri.width * 0.7));
					yuri.updateHitbox();
	
					switch(PlayState.instance.dad.curCharacter)
					{
						case 'sayori':

							add(yuri);
							yuri.x = -74;
							yuri.y = 176;

							add(natsuki);
							natsuki.x = 1088;
							natsuki.y = 275;
						case 'nat'|'natsuki':

							add(yuri);
							yuri.x = 130;
							yuri.y = 176;
	
							add(sayori);
							sayori.x = 1050;
							sayori.y = 250;
						case 'yuri'|'yuri-crazy':
	
							add(sayori);
							sayori.x = -49;
							sayori.y = 247;
							add(natsuki);

							natsuki.x = 1044;
							natsuki.y = 290;
						case 'monika':
	
							add(sayori);
							sayori.x = 134;
							sayori.y = 246;

							add(natsuki);
							natsuki.x = 1044;
							natsuki.y = 290;

							add(yuri);
							yuri.x = -74;
							yuri.y = 176;							
					}
				}

			case 'Doki-club-room-evil':
				defaultCamZoom = 0.8;

				var scale = 1;
				var posX = -350;
				var posY = -167;

				var space = new FlxBackdrop(Paths.image('doki/bigmonika/Sky'), 0.1, 0.1);
				space.velocity.set(-10, 0);
				// space.scale.set(1.65, 1.65);
				add(space);
				
				var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('doki/bigmonika/BG'));
				bg.antialiasing = true;
				// bg.scale.set(2.3, 2.3);
				bg.scrollFactor.set(0.4, 0.6);
				add(bg);

				var stageFront:FlxSprite = new FlxSprite(-452, -77).loadGraphic(Paths.image('doki/bigmonika/FG'));
				stageFront.antialiasing = true;
				// stageFront.scale.set(1.5, 1.5);
				stageFront.scrollFactor.set(1, 1);
				add(stageFront);

				var popup = new FlxSprite(312, 432);
				popup.frames = Paths.getSparrowAtlas('doki/bigmonika/bigika_delete');
				popup.animation.addByPrefix('idle', "PopUpAnim", 24, false);
				popup.antialiasing = true;
				popup.scrollFactor.set(1, 1);
				popup.setGraphicSize(Std.int(popup.width * 1));
				popup.updateHitbox();
				popup.animation.play('idle', true);
				if (songName != 'epiphany') popup.visible = false;
				layers.get("boyfriend").add(popup);
			case 'ITB':
				defaultCamZoom = 0.70;

				var bg17:FlxSprite = new FlxSprite(-701, -300).loadGraphic(Paths.image('b&b/ITB/Layer 5', 'shared'));
				bg17.antialiasing = true;
				bg17.scrollFactor.set(0.3, 0.3);
				bg17.active = false;
				add(bg17);

				var bg16:FlxSprite = new FlxSprite(-701, -300).loadGraphic(Paths.image('b&b/ITB/Layer 4', 'shared'));
				bg16.antialiasing = true;
				bg16.scrollFactor.set(0.4, 0.4);
				bg16.active = false;
				add(bg16);

				var bg15:FlxSprite = new FlxSprite(-701, -300).loadGraphic(Paths.image('b&b/ITB/Layer 3', 'shared'));
				bg15.antialiasing = true;
				bg15.scrollFactor.set(0.6, 0.6);
				bg15.active = false;
				add(bg15);

				var bg14:FlxSprite = new FlxSprite(-701, -300).loadGraphic(Paths.image('b&b/ITB/Layer 2', 'shared'));
				bg14.antialiasing = true;
				bg14.scrollFactor.set(0.7, 0.7);
				bg14.active = false;
				add(bg14);

				var bg1:FlxSprite = new FlxSprite(-701, -300).loadGraphic(Paths.image('b&b/ITB/Layer 1 (back tree)', 'shared'));
				bg1.antialiasing = true;
				bg1.scrollFactor.set(0.7, 0.7);
				bg1.active = false;
				add(bg1);

				var bg13:FlxSprite = new FlxSprite(-701, -300).loadGraphic(Paths.image('b&b/ITB/Layer 1 (Tree)', 'shared'));
				bg13.antialiasing = true;
				bg13.active = false;
				add(bg13);

				var bg4:FlxSprite = new FlxSprite(-701, -300).loadGraphic(Paths.image('b&b/ITB/Layer 1 (flower and grass)', 'shared'));
				bg4.antialiasing = true;
				bg4.active = false;
				add(bg4);

				phillyCityLights = new FlxTypedGroup<FlxSprite>();
				add(phillyCityLights);

				for (i in 0...2)
				{
					var light:FlxSprite = new FlxSprite(-701, -300).loadGraphic(Paths.image('b&b/ITB/light'+i, 'shared'));
					light.antialiasing = true;
					light.scrollFactor.set(0.8, 0.8);
					light.alpha = 0;
					light.active = false;
					phillyCityLights.add(light);
				}

				var bg5:FlxSprite = new FlxSprite(-701, -300).loadGraphic(Paths.image('b&b/ITB/Layer 1 (Grass 2)', 'shared'));
				bg5.antialiasing = true;
				bg5.active = false;
				add(bg5);

				var bg8:FlxSprite = new FlxSprite(-701, -300).loadGraphic(Paths.image('b&b/ITB/Layer 1 (Lamp)', 'shared'));
				bg8.antialiasing = true;
				bg8.active = false;
				layers.get("gf").add(bg8);

				var bg6:FlxSprite = new FlxSprite(-701, -300).loadGraphic(Paths.image('b&b/ITB/Layer 1 (Grass)', 'shared'));
				bg6.antialiasing = true;
				bg6.active = false;
				layers.get("gf").add(bg6);

				var bg7:FlxSprite = new FlxSprite(-701, -300).loadGraphic(Paths.image('b&b/ITB/Layer 1 (Ground)', 'shared'));
				bg7.antialiasing = true;
				bg7.active = false;
				layers.get("gf").add(bg7);
			case 'neopolis'://Neon
				defaultCamZoom = 1.05;

				var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSkyNeon'));
				bgSky.scrollFactor.set(0.1, 0.1);
				add(bgSky);

				var repositionShit = -200;

				var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreetNeon'));
				bgStreet.scrollFactor.set(0.95, 0.95);
				add(bgStreet);

				var widShit = Std.int(bgSky.width * 6);

				bgSky.setGraphicSize(widShit);
				bgStreet.setGraphicSize(widShit);

				bgSky.updateHitbox();
				bgStreet.updateHitbox();
			case 'school-monika-finale':
				defaultCamZoom = 0.9;

				var posX = 50;
				var posY = 200;

				var space = new FlxBackdrop(Paths.image('monika/FinaleBG_1'));
				space.velocity.set(-10, 0);
				space.antialiasing = false;
				space.scrollFactor.set(0.1, 0.1);
				space.scale.set(1.65, 1.65);
				add(space);

				var bg2 = new FlxSprite(70, posY).loadGraphic(Paths.image('monika/FinaleBG_2'));
				bg2.antialiasing = false;
				bg2.scale.set(2.3, 2.3);
				bg2.scrollFactor.set(0.4, 0.6);
				add(bg2);

				var stageFront2 = new FlxSprite(posX, posY).loadGraphic(Paths.image('monika/FinaleFG'));
				stageFront2.antialiasing = false;
				stageFront2.scale.set(1.5, 1.5);
				stageFront2.scrollFactor.set(1, 1);
				add(stageFront2);
			case 'cg5Stage':
				defaultCamZoom = 0.9;

				var bg = new FlxSprite(-535, -166).loadGraphic(Paths.image('cg5/mixroom'));
				bg.antialiasing = true;
				bg.setGraphicSize(Std.int(bg.width * 0.9));
				bg.updateHitbox();
				bg.scrollFactor.set(1, 0.9);
				bg.active = false;
				add(bg);

				var stageFront = new FlxSprite(-507, -117).loadGraphic(Paths.image('cg5/recordroom'));
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(1, 0.9);
				stageFront.active = false;
				stageFront.setGraphicSize(Std.int(stageFront.width * 0.9));
				stageFront.updateHitbox();
				layers.get("gf").add(stageFront);

				var stageFront2 = new FlxSprite(-507, -117).loadGraphic(Paths.image('cg5/room_lights'));
				stageFront2.antialiasing = true;
				stageFront2.scrollFactor.set(1, 0.9);
				stageFront2.active = false;
				stageFront2.setGraphicSize(Std.int(stageFront2.width * 0.9));
				stageFront2.updateHitbox();
				layers.get("gf").add(stageFront2);
			case 'acrimony':
				defaultCamZoom = 0.98;

				var schoolBg:FlxSprite = new FlxSprite(-550, -900).loadGraphic(Paths.image('maginage/Schoolyard'));
				schoolBg.antialiasing = true;
				schoolBg.scrollFactor.set(0.85, 0.98);
				schoolBg.setGraphicSize(Std.int(schoolBg.width * 0.65));
				schoolBg.updateHitbox();
				add(schoolBg);

				var modCrowdBig = new FlxSprite(-290, 55);
				modCrowdBig.frames = Paths.getSparrowAtlas('maginage/Crowd2');
				modCrowdBig.animation.addByPrefix('bop', 'Crowd2_Idle', 24, false);
				modCrowdBig.antialiasing = true;
				modCrowdBig.scrollFactor.set(0.9, 0.95);
				modCrowdBig.updateHitbox();
				add(modCrowdBig);
			case 'sunshine' | 'withered':
				defaultCamZoom = 1.05;
				switch (curStage)
				{
					case 'sunshine': pre = 'happy';
					case 'withered': pre = 'slightlyannoyed_';				
				}

				var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('bob/'+pre+'sky'));
				bg.updateHitbox();
				bg.active = false;
				bg.antialiasing = true;
				bg.scrollFactor.set(0.1, 0.1);
				add(bg);
				
				var ground:FlxSprite = new FlxSprite(-537, -158).loadGraphic(Paths.image('bob/'+pre+'ground'));
				ground.updateHitbox();
				ground.active = false;
				ground.antialiasing = true;
				add(ground);
			case 'hungryhippo'|'hungryhippo-blantad':
				defaultCamZoom = 0.6;

				if (curStage == 'hungryhippo-blantad'){
					suf = '_blantad';
				}
				var bg = new FlxSprite(-800, -600).loadGraphic(Paths.image('rebecca/hungryhippo_bg'+suf));
		
				bg.scrollFactor.set(1.0, 1.0);
				add(bg);
			case 'alleysoft':
				defaultCamZoom = 0.8;

				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('soft/alleybg'));
				bg.antialiasing = true;
				bg.scrollFactor.set(1, 1);
				bg.active = false;
				add(bg);

				var stageFront:FlxSprite = new FlxSprite(-630,-200).loadGraphic(Paths.image('soft/alleyfloor'));
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(1, 1);
				stageFront.active = false;
				add(stageFront);
				
				var stageCurtains:FlxSprite = new FlxSprite(-200, -100).loadGraphic(Paths.image('soft/alleycat'));
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
				stageCurtains.updateHitbox();
				stageCurtains.antialiasing = true;
				stageCurtains.scrollFactor.set(1.3, 1.3);
				stageCurtains.active = false;
				layers.get("boyfirend").add(stageCurtains);																		
			case 'alley': //Hypno Lullaby bruh
				var consistentPosition:Array<Float> = [-300, -600];
				var resizeBG:Float = 0.7;
				defaultCamZoom = 0.7;
				
				var background:BGSprite = new BGSprite('hypno/Hypno bg background', consistentPosition[0], consistentPosition[1]);
				background.setGraphicSize(Std.int(background.width * resizeBG));
				background.updateHitbox();
				add(background);

				var midGround:BGSprite = new BGSprite('hypno/Hypno bg midground', consistentPosition[0], consistentPosition[1]);
				midGround.setGraphicSize(Std.int(midGround.width * resizeBG));
				midGround.updateHitbox();
				add(midGround);

				var foreground:BGSprite = new BGSprite('hypno/Hypno bg foreground', consistentPosition[0], consistentPosition[1]);
				foreground.setGraphicSize(Std.int(foreground.width * resizeBG));
				foreground.updateHitbox();
				layers.get("boyfriend").add(foreground);
			case 'out'://Shaggy
				defaultCamZoom = 0.8;

				var sky:BGElement = new BGElement('shaggy/OBG/sky', -1204, -456, 0.15, 1, 0);
				add(sky);

				var clouds:BGElement = new BGElement('shaggy/OBG/clouds', -988, -260, 0.25, 1, 1);
				add(clouds);

				var backMount:BGElement = new BGElement('shaggy/OBG/backmount', -700, -40, 0.4, 1, 2);
				add(backMount);

				var middleMount:BGElement = new BGElement('shaggy/OBG/middlemount', -240, 200, 0.6, 1, 3);
				add(middleMount);

				var ground:BGElement = new BGElement('shaggy/OBG/ground', -660, 624, 1, 1, 4);
				add(ground);
			case 'gamer':
				var bg:FlxSprite = new FlxSprite(-1130, -380).loadGraphic(Paths.image('liz/bgamser'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				var stageFront:FlxSprite = new FlxSprite(-730, -2012).loadGraphic(Paths.image('liz/bgMain'));
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;
				add(stageFront);

				var zero16 = new FlxSprite(-387, 173);
				zero16.frames = Paths.getSparrowAtlas("liz/016_Assets");
				zero16.animation.addByPrefix('idle', "016 idle", 24, false);
				boppersAlt.push(zero16);
				add(zero16);
			case 'room'://nonsense
			    defaultCamZoom = 0.8;
				var out:FlxSprite = new FlxSprite(-600, 40).loadGraphic(Paths.image('nonsense/Outside'));
				out.setGraphicSize(Std.int(out.width * 0.8));
				out.antialiasing = true;
				out.scrollFactor.set(0.8, 0.8);
				out.active = false;
				add(out);	

				var roomin:FlxSprite = new FlxSprite(-800, -370).loadGraphic(Paths.image('nonsense/BACKGROUND'));
				roomin.setGraphicSize(Std.int(roomin.width * 0.9));
				roomin.antialiasing = true;
				roomin.active = false;
				add(roomin);
			case 'tgt'|'tgt2':
				var stagebackImage:String = '';
				var stageFrontImage:String = '';
				var stageCurtatinsImage:String = '';
				switch(curStage)
				{
					case 'tgt':
						stagebackImage = 'tgt/stageback';
						stageFrontImage = 'tgt/stagefront';
						stageCurtatinsImage = 'tgt/stagecurtains';
					case 'tgt2':
						stagebackImage = 'tgt/stageback2';
						stageFrontImage = 'tgt/stagefront2';
						stageCurtatinsImage = 'tgt/stagecurtains2';
				}

				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image(stagebackImage));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);

				var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image(stageFrontImage));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;
				add(stageFront);

				var stageCurtains:FlxSprite = new FlxSprite(-450, -150).loadGraphic(Paths.image(stageCurtatinsImage));
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.87));
				stageCurtains.updateHitbox();
				stageCurtains.antialiasing = true;
				stageCurtains.scrollFactor.set(1.1, 1.1);
				stageCurtains.active = false;
				add(stageCurtains);
			case 'airplane1' | 'airplane2':
				defaultCamZoom = 0.6;

				switch (curStage)
				{
					case  'airplane1':
						suf = 'Sky Clear';
					case 'airplane2':
						suf = 'Sky Storm';
				}

				var sky:FlxSprite = new FlxSprite(-600, -600).loadGraphic(Paths.image('rich/'+suf, 'shared'));
				sky.antialiasing = FlxG.save.data.anitialiasing;
				sky.scrollFactor.set(0.6, 0.6);
				add(sky);

				var bg:FlxSprite = new FlxSprite(-600, -600).loadGraphic(Paths.image('rich/Background', 'shared'));
				bg.antialiasing = FlxG.save.data.anitialiasing;
				bg.scrollFactor.set(1, 1);
				bg.active = false;
				add(bg);

				var theGraph:FlxSprite = new FlxSprite(646, -20).loadGraphic(Paths.image('rich/TV', 'shared'));
				theGraph.antialiasing = FlxG.save.data.anitialiasing;
				theGraph.scrollFactor.set(1, 1);
				theGraph.active = false;
				add(theGraph);

				graphPointer = new FlxObject(1140, 200, 0, 0);
				add(graphPointer);

				graphPosition = graphPointer.y;

				grpGraph = new FlxTypedGroup<FlxSprite>();
				add(grpGraph);
				
				grpGraphIndicators = new FlxTypedGroup<FlxSprite>();
				add(grpGraphIndicators);

				for (i in 0...3) {
					var indic:FlxSprite = new FlxSprite(681, 234);
					indic.visible = false;
					switch (i) {
						case 0:
							indic.loadGraphic(Paths.image('rich/Graph STABLE', 'shared'));
							indic.visible = true;
						case 1:
							indic.loadGraphic(Paths.image('rich/Graph UP', 'shared'));
						case 2:
							indic.loadGraphic(Paths.image('rich/Graph DOWN', 'shared'));
					}
				}
				neutralGraphPos = graphPointer.y;
				graphBurstTimer = FlxG.random.int(90, 150);

				var bg2:FlxSprite = new FlxSprite(-600, 600).loadGraphic(Paths.image('rich/Foreground', 'shared'));
				bg2.antialiasing = FlxG.save.data.antialiasing;
				bg2.scrollFactor.set(1.3, 1.3);
				bg2.active = false;
				add(bg2);
			case 'street1' | 'street2' | 'street3'://Mickey Creepypasta
				defaultCamZoom = 0.9;

				var bg = new FlxSprite(-500, -200).loadGraphic(Paths.image(curStage));
				bg.setGraphicSize(Std.int(bg.width * 0.9));
				bg.updateHitbox();
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;		
				add(bg);
			case 'zardyMaze':
				defaultCamZoom = 0.9;

				zardyBackground = new FlxSprite(-600, -200);
				zardyBackground.frames = Paths.getSparrowAtlas('zardy/Maze', 'shared');
				zardyBackground.animation.addByPrefix('Maze','Stage', 16);
				zardyBackground.antialiasing = true;
				zardyBackground.scrollFactor.set(0.9, 0.9);
				zardyBackground.animation.play('Maze');
				add(zardyBackground);
			case 'FMMstage' | 'FMMstagedusk' | 'FMMstagenight':
				var time:String = '';

				defaultCamZoom = 0.6;

				switch (curStage)
				{
					case 'FMMstage':
						time = 'Day';
					case 'FMMstagedusk':
						time = 'Dusk';
					case 'FMMstagenight':
						time = 'Night';
				}
				
				var bg:FlxSprite = new FlxSprite(-1000, -350).loadGraphic(Paths.image('FMMStage/FMM'+time+'BG'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = false;
				add(bg);

				var FMMBuildings:FlxSprite = new FlxSprite(-1290, -380).loadGraphic(Paths.image('FMMStage/FMM'+time+'Buildings'));
				FMMBuildings.setGraphicSize(Std.int(FMMBuildings.width * 1.1));
				FMMBuildings.updateHitbox();
				FMMBuildings.antialiasing = true;
				FMMBuildings.scrollFactor.set(0.7, 0.7);
				FMMBuildings.active = false;
				add(FMMBuildings);

				var FMMRail:FlxSprite = new FlxSprite(-1290, -490).loadGraphic(Paths.image('FMMStage/FMM'+time+'Rail'));
				FMMRail.setGraphicSize(Std.int(FMMRail.width * 1.1));
				FMMRail.updateHitbox();
				FMMRail.antialiasing = true;
				FMMRail.scrollFactor.set(0.8, 0.8);
				FMMRail.active = false;
				add(FMMRail);

				var FMMFront:FlxSprite = new FlxSprite(-1290, -475).loadGraphic(Paths.image('FMMStage/FMM'+time+'Front'));
				FMMFront.setGraphicSize(Std.int(FMMFront.width * 1.1));
				FMMFront.updateHitbox();
				FMMFront.antialiasing = true;//
				FMMFront.scrollFactor.set(0.9, 0.9);
				FMMFront.active = false;
				add(FMMFront);
			case 'sunkStage':
				defaultCamZoom = 0.9;
			
				var bg = new FlxSprite(-400, 0).loadGraphic(Paths.image('exe/SunkBG'));
				bg.antialiasing = true;
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				bg.scrollFactor.set(0.95, 0.95);
				bg.active = false;
				add(bg);
			case 'mind':
				defaultCamZoom = 0.8;

				var bg:FlxSprite = new FlxSprite(-600, -145).loadGraphic(Paths.image('corruption/tormentor/TormentorBG'));
				bg.updateHitbox();
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);	

				var funnytv:FlxSprite = new FlxSprite(120, 145);
				funnytv.frames = Paths.getSparrowAtlas('corruption/tormentor/TormentorStatic');
				funnytv.animation.addByPrefix('idle', 'Tormentor Static', 24);
				funnytv.animation.play('idle');
				funnytv.scrollFactor.set(0.9, 0.9);
				funnytv.setGraphicSize(Std.int(funnytv.width * 1.3));
				add(funnytv);
			case 'mind2':
				defaultCamZoom = 0.8;
				
				var wBg = new FlxSprite(-600, -145).loadGraphic(Paths.image('corruption/tormentor/shit'));
				wBg.updateHitbox();
				wBg.antialiasing = true;
				wBg.scrollFactor.set(0.9, 0.9);
				wBg.active = false;
				add(wBg);

				var bg2 = new FlxSprite(-600, -145).loadGraphic(Paths.image('corruption/tormentor/fuck'));
				bg2.updateHitbox();
				bg2.antialiasing = true;
				bg2.scrollFactor.set(0.9, 0.9);
				bg2.active = false;
				add(bg2);

				var bg = new FlxSprite(-600, -145).loadGraphic(Paths.image('corruption/tormentor/TormentorBG'));
				bg.updateHitbox();
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);	

				var funnytv = new FlxSprite(120, 145);
				funnytv.frames = Paths.getSparrowAtlas('corruption/tormentor/TormentorStatic');
				funnytv.animation.addByPrefix('idle', 'Tormentor Static', 24);
				funnytv.animation.play('idle');
				funnytv.scrollFactor.set(0.9, 0.9);
				funnytv.setGraphicSize(Std.int(funnytv.width * 1.3));
				add(funnytv);
			case 'momiStage':
				defaultCamZoom = 0.9;

				var bg:FlxSprite = new FlxSprite(-175.3, -225.95).loadGraphic(Paths.image('momi/bg'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 1);
				bg.active = false;
				add(bg);	

				var dust = new FlxSprite( -238.3, 371.55);
				dust.frames = Paths.getSparrowAtlas("momi/dust");
				dust.animation.addByPrefix("bop", "dust", 24, false);
				dust.scrollFactor.set(1.2, 1.2);
				dust.visible = false;
				dust.animation.play("bop");
				layers.get("boyfriend").add(dust);	
					
				var car = new FlxSprite( -1514.4, 199.8);
				car.scrollFactor.set(1.2,1.2);
				car.frames = Paths.getSparrowAtlas("momi/car");
				car.animation.addByPrefix("go", "car", 24, false);
				car.visible = true;
				car.animation.play("go");
				layers.get("boyfriend").add(car);
				if(songName == "gura-nazel" || songName == "nazel")dust.visible = true;
			case 'studio':
				defaultCamZoom = 0.9;

				var speakerScale:Float = 0.845;

				var bg_back:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('studio/studio_evenfurtherback'));
				bg_back.setGraphicSize(Std.int(bg_back.width * 0.845));
				bg_back.screenCenter();
				bg_back.antialiasing = true;
				bg_back.scrollFactor.set(0.85, 0.85);
				bg_back.active = false;
				bg_back.x += 32;
				add(bg_back);	

				var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('studio/studio_back'));
				bg.setGraphicSize(Std.int(bg.width * 0.845));
				bg.screenCenter();
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);	

				var cy_spk1 = new FlxSprite(0, 0);
				cy_spk1.frames = Paths.getSparrowAtlas("studio/studio_speaker");
				cy_spk1.animation.addByPrefix('idle', 'speaker', 24);
				cy_spk1.animation.play('idle');
				cy_spk1.antialiasing = true;
				cy_spk1.scale.x = speakerScale;
				cy_spk1.scale.y = speakerScale;
				cy_spk1.screenCenter();
				cy_spk1.scrollFactor.set(0.9, 0.9);
				cy_spk1.x += -672;
				cy_spk1.y += -32;
				boppersAlt.push(cy_spk1);
				add(cy_spk1);	

				var cy_spk2 = new FlxSprite(0, 0);
				cy_spk2.frames = Paths.getSparrowAtlas("studio/studio_speaker");
				cy_spk2.animation.addByPrefix('idle', 'speaker', 24);
				cy_spk2.animation.play('idle');
				cy_spk2.antialiasing = true;
				cy_spk2.scale.x = speakerScale;
				cy_spk2.scale.y = speakerScale;
				cy_spk2.screenCenter();
				cy_spk2.scrollFactor.set(0.9, 0.9);
				cy_spk2.x += 640;
				cy_spk2.y += -32;
				cy_spk2.flipX = true;
				boppersAlt.push(cy_spk2);
				add(cy_spk2);	

				var bg_fx:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('studio/studio_fx'));
				bg_fx.setGraphicSize(Std.int(bg.width * 0.845));
				bg_fx.screenCenter();
				bg_fx.antialiasing = true;
				bg_fx.scrollFactor.set(0.9, 0.9);
				bg_fx.active = false;
				add(bg_fx);
			case 'studio-crash':
				defaultCamZoom = 0.9;

				var cy_crash = new FlxSprite(0, 0);
				cy_crash.frames = Paths.getSparrowAtlas("studio/crash_back");
				cy_crash.animation.addByPrefix('code', 'code', 24, true);
				cy_crash.antialiasing = true;
				cy_crash.setGraphicSize(Std.int(cy_crash.width * 1.75));
				cy_crash.screenCenter();
				cy_crash.antialiasing = true;
				cy_crash.scrollFactor.set(0.85, 0.85);
				cy_crash.x += 32;
				cy_crash.y += 80;
				cy_crash.animation.play('code');
				add(cy_crash);
			case 'street-bob':
				defaultCamZoom = 0.9;

				var bg:FlxSprite = new FlxSprite(-100,10).loadGraphic(Paths.image('bob/happyRon_sky'));
				bg.updateHitbox();
				bg.scale.x = 1.2;
				bg.scale.y = 1.2;
				bg.active = false;
				bg.antialiasing = true;
				bg.scrollFactor.set(0.1, 0.1);
				add(bg);	

				var ground:FlxSprite = new FlxSprite(-537, -250).loadGraphic(Paths.image('bob/happyRon_ground'));
				ground.updateHitbox();
				ground.active = false;
				ground.antialiasing = true;
				add(ground);
			case 'kbStreet':
				defaultCamZoom = 0.8125;

				//Back Layer - Normal
				var streetBG = new FlxSprite(-750, -145).loadGraphic(Paths.image('qt/streetBack'));
				streetBG.antialiasing = true;
				streetBG.scrollFactor.set(0.9, 0.9);
				add(streetBG);	

				//Front Layer - Normal
				var streetFront:FlxSprite = new FlxSprite(-820, 710).loadGraphic(Paths.image('qt/streetFront'));
				streetFront.setGraphicSize(Std.int(streetFront.width * 1.15));
				streetFront.updateHitbox();
				streetFront.antialiasing = true;
				streetFront.scrollFactor.set(0.9, 0.9);
				streetFront.active = false;
				add(streetFront);	

				var qt_tv01 = new FlxSprite(-62, 540);
				qt_tv01.frames = Paths.getSparrowAtlas('qt/TV_V5');
				qt_tv01.animation.addByPrefix('idle', 'TV_Idle', 24, true);
				qt_tv01.animation.addByPrefix('eye', 'TV_brutality', 24, true); //Replaced the hex eye with the brutality symbols for more accurate lore.
				qt_tv01.animation.addByPrefix('error', 'TV_Error', 24, true);	
				qt_tv01.animation.addByPrefix('404', 'TV_Bluescreen', 24, true);		
				qt_tv01.animation.addByPrefix('alert', 'TV_Attention', 32, false);		
				qt_tv01.animation.addByPrefix('watch', 'TV_Watchout', 24, true);
				qt_tv01.animation.addByPrefix('drop', 'TV_Drop', 24, true);
				qt_tv01.animation.addByPrefix('sus', 'TV_sus', 24, true);
				qt_tv01.setGraphicSize(Std.int(qt_tv01.width * 1.2));
				qt_tv01.updateHitbox();
				qt_tv01.antialiasing = true;
				qt_tv01.scrollFactor.set(0.89, 0.89);
				qt_tv01.animation.play('idle');
				add(qt_tv01);	
			
				qt_gas01 = new FlxSprite();
				qt_gas01.frames = Paths.getSparrowAtlas('qt/Gas_Release');
				qt_gas01.animation.addByPrefix('burst', 'Gas_Release', 38, false);	
				qt_gas01.animation.addByPrefix('burstALT', 'Gas_Release', 49, false);
				qt_gas01.animation.addByPrefix('burstFAST', 'Gas_Release', 76, false);	
				qt_gas01.setGraphicSize(Std.int(qt_gas01.width * 2.5));	
				qt_gas01.antialiasing = true;
				qt_gas01.scrollFactor.set();
				qt_gas01.alpha = 0.72;
				qt_gas01.setPosition(-180,250);
				qt_gas01.angle = -31;	
				layers.get("boyfriend").add(qt_gas01);			

				qt_gas02 = new FlxSprite();
				qt_gas02.frames = Paths.getSparrowAtlas('qt/Gas_Release');
				qt_gas02.animation.addByPrefix('burst', 'Gas_Release', 38, false);	
				qt_gas02.animation.addByPrefix('burstALT', 'Gas_Release', 49, false);
				qt_gas02.animation.addByPrefix('burstFAST', 'Gas_Release', 76, false);	
				qt_gas02.setGraphicSize(Std.int(qt_gas02.width * 2.5));
				qt_gas02.antialiasing = true;
				qt_gas02.scrollFactor.set();
				qt_gas02.alpha = 0.72;
				qt_gas02.setPosition(1320,250);
				qt_gas02.angle = 31;
				layers.get("boyfriend").add(qt_gas02); 
			case 'room-space':
				defaultCamZoom = 0.8;
				
				var space:FlxSprite = new FlxSprite(-800, -370).loadGraphic(Paths.image('nonsense/Outside_Space'));
				space.setGraphicSize(Std.int(space.width * 0.8));
				space.antialiasing = true;
				space.scrollFactor.set(0.8, 0.8);
				space.active = false;
				add(space);	
				
				var spaceTex = Paths.getSparrowAtlas('nonsense/BACKGROUND_space');

				var NHroom = new FlxSprite( -800, -370);
				NHroom.frames = spaceTex;
				NHroom.animation.addByPrefix('space', 'Wall Broken anim', 24, true);
				NHroom.animation.play('space');
				NHroom.setGraphicSize(Std.int(NHroom.width * 0.9));
				NHroom.antialiasing = true;
				add(NHroom);
			case 'melonfarm':
				var bg:FlxSprite = new FlxSprite(-90, -20).loadGraphic(Paths.image('fever/melonfarm/sky'));
				bg.scrollFactor.set(0.1, 0.1);
				add(bg);

				var city:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('fever/melonfarm/bg'));
				add(city);	

				var street:FlxSprite = new FlxSprite(-70).loadGraphic(Paths.image('fever/melonfarm/street'));
				add(street);
			case 'mainfest-sky':
				defaultCamZoom = 0.9;

				var manifestBG = new FlxSprite(-388, -232);
				manifestBG.frames = Paths.getSparrowAtlas('sky/bg_manifest');
				manifestBG.animation.addByPrefix('idle', 'bg_manifest0', 24, false);
				manifestBG.animation.addByPrefix('noflash', 'bg_noflash0', 24, false);		
				manifestBG.scrollFactor.set(0.4, 0.4);
				manifestBG.antialiasing = true;
				manifestBG.animation.play('noflash');
				add(manifestBG);	

				var manifestFloor = new FlxSprite(-1053, -465);
				manifestFloor.frames = Paths.getSparrowAtlas('sky/floorManifest');
				manifestFloor.animation.addByPrefix('idle', 'floorManifest0', 24, false);
				manifestFloor.animation.addByPrefix('noflash', 'floornoflash0', 24, false);
				manifestFloor.antialiasing = true;
				manifestFloor.animation.play('noflash');
				manifestBG.scrollFactor.set(0.9, 0.9);
				add(manifestFloor);
			case 'skyBroke':
				defaultCamZoom = 0.9;

				var manifestBG = new FlxSprite(-388, -232);
				manifestBG.frames = Paths.getSparrowAtlas('sky/bg_annoyed');
				manifestBG.animation.addByPrefix('idle', 'bg2', 24, false);
				manifestBG.animation.addByIndices('noflash', "bg2", [5], "", 24, false);
				manifestBG.scrollFactor.set(0.4, 0.4);
				manifestBG.antialiasing = true;
				manifestBG.animation.play('noflash');
				add(manifestBG);	

				var manifestHole = new FlxSprite (160, -70);
				manifestHole.frames = Paths.getSparrowAtlas('sky/manifesthole');
				manifestHole.animation.addByPrefix('idle', 'manifest hole', 24, false);
				manifestHole.animation.addByIndices('noflash', "manifest hole", [5], "", 24, false);
				manifestHole.scrollFactor.set(0.7, 1);
				manifestHole.setGraphicSize(Std.int(manifestHole.width * 0.9));
				manifestHole.updateHitbox();
				manifestHole.animation.play('noflash');
				manifestHole.antialiasing = true;
				add(manifestHole);
			case 'churchselever' | 'churchsarv' | 'churchruv' | 'churchsarvdark':
				var pillars:FlxSprite;
				var floor:FlxSprite;
				var bg:FlxSprite;

				if (curStage == 'churchsarvdark')
				{
					curStage = 'churchsarv';
				}

				floor = new FlxSprite(-660, -1060).loadGraphic(Paths.image('sacredmass/'+curStage+'/floor'));
				floor.setGraphicSize(Std.int(floor.width * 1.3));
				floor.updateHitbox();
				floor.antialiasing = true;
				floor.scrollFactor.set(0.9, 0.9);
				floor.active = false;
				if(curStage == 'churchsarvdark')
				{
					floor.color = 0xFFD6ABBF;
				}
				add(floor);	

				bg = new FlxSprite(-660, -1060).loadGraphic(Paths.image('sacredmass/'+curStage+'/bg'));
				bg.setGraphicSize(Std.int(bg.width * 1.3));
				bg.updateHitbox();
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				if(curStage == 'churchsarvdark')
				{
					bg.color = 0xFFD6ABBF;
				}
				add(bg);	

				pillars = new FlxSprite(-660, -1060).loadGraphic(Paths.image('sacredmass/'+curStage+'/pillars'));
				pillars.setGraphicSize(Std.int(pillars.width * 1.3));
				pillars.updateHitbox();
				pillars.antialiasing = true;
				pillars.scrollFactor.set(0.9, 0.9);
				pillars.active = false;
				if(curStage == 'churchsarvdark')
				{
					pillars.color = 0xFFD6ABBF;
				}
				add(pillars);	



				if (curStage == 'churchruv')
				{
					var pillarbroke = new FlxSprite(-660, -1060).loadGraphic(Paths.image('sacredmass/churchruv/pillarbroke'));
					pillarbroke.setGraphicSize(Std.int(pillarbroke.width * 1.3));
					pillarbroke.updateHitbox();
					pillarbroke.antialiasing = true;
					pillarbroke.scrollFactor.set(0.9, 0.9);
					pillarbroke.active = false;
					layers.get("gf").add(pillarbroke);
				}
			case 'destroyedpaper':
				defaultCamZoom = 0.75;

				var bg:FlxSprite = new FlxSprite(-230, -95);
				bg.frames = Paths.getSparrowAtlas('Sketchy/destroyedpaperjig');
				bg.animation.addByPrefix('idle', 'DestroyedPaper', 24);
				bg.setGraphicSize(Std.int(bg.width * 0.5));
				bg.animation.play('idle');
				bg.scrollFactor.set(0.8, 1.0);
				bg.scale.set(2.3, 2.3);
				bg.antialiasing = true;
				add(bg);	

				var rips:FlxSprite = new FlxSprite(-230, -95);
				rips.frames = Paths.getSparrowAtlas('Sketchy/PaperRips');
				rips.animation.addByPrefix('idle', 'Ripping Graphic', 24);
				rips.setGraphicSize(Std.int(rips.width * 0.5));
				rips.animation.play('idle');
				rips.scrollFactor.set(1.0, 1.0);
				rips.scale.set(2.0, 2.0);
				rips.antialiasing = true;
				add(rips);
			case 'staged2' | 'staged3':
				var stageShit:String = '';
				
				stageShit = curStage;

				defaultCamZoom = 0.9;
				
				if (curStage == 'staged3')
				{
					var bg = new FlxSprite(-260, -220);
					bg.frames = Paths.getSparrowAtlas('corruption/staged3/stageback');
					bg.animation.addByPrefix('idle', 'stageback animated', 24, true);
					bg.setGraphicSize(Std.int(bg.width * 1.1));
					bg.updateHitbox();
					bg.antialiasing = true;
					bg.scrollFactor.set(0.9, 0.9);
					bg.animation.play('idle');
					add(bg);	
				}	

				if (curStage == 'staged2')
				{
					var bg = new FlxSprite(-600, -200).loadGraphic(Paths.image('corruption/staged2/stageback'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					add(bg);	

					var ladder:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('corruption/staged2/ladder'));
					ladder.antialiasing = true;
					ladder.scrollFactor.set(0.9, 0.9);
					ladder.active = false;
					add(ladder);	
				}
				
				var stageFront = new FlxSprite(-650, 600).loadGraphic(Paths.image('corruption/'+stageShit+'/stagefront'));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;
				add(stageFront);	

				var stageCurtains = new FlxSprite(-500, -300).loadGraphic(Paths.image('corruption/'+stageShit+'/stagecurtains'));
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
				stageCurtains.updateHitbox();
				stageCurtains.antialiasing = true;
				stageCurtains.scrollFactor.set(1.3, 1.3);
				stageCurtains.active = false;
				add(stageCurtains);
			case 'curse':
				defaultCamZoom = 0.8;
				
				var bg = new FlxSprite(-600, -300).loadGraphic(Paths.image('tabi/normal_stage'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);	

				var sumtable:FlxSprite = new FlxSprite(-600, -300).loadGraphic(Paths.image('tabi/sumtable'));
				sumtable.antialiasing = true;
				sumtable.scrollFactor.set(0.9, 0.9);
				sumtable.active = false;
				layers.get("boyfriend").add(sumtable);
			case 'neko-bedroom':
				defaultCamZoom = 0.7;

				var bedroom = new FlxSprite(-600, -200).loadGraphic(Paths.image('neko/bg_bedroom', 'shared'));
				bedroom.antialiasing = true;
				bedroom.scrollFactor.set(0.97, 0.97);
				bedroom.active = false;
				add(bedroom);
			case 'garStage' | 'eddhouse2':
				defaultCamZoom = 0.9;
				switch (curStage)
				{
					case 'garStage': pre = 'garcello';
					case 'eddhouse2': pre = 'tord';
				}

				var bg = new FlxSprite(-500, -170).loadGraphic(Paths.image(pre+'/garStagebg'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);

				var stageFront:FlxSprite = new FlxSprite(-500, -200).loadGraphic(Paths.image(pre+'/garStage'));
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;
				add(stageFront);
			case 'arcade4':
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('kapi/closed'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);

				if(!ClientPrefs.lowQuality)
				{
					bottomBoppers = new FlxSprite(-600, -200);
					bottomBoppers.frames = Paths.getSparrowAtlas('kapi/bgFreaks');
					bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
					bottomBoppers.antialiasing = true;
					bottomBoppers.scrollFactor.set(0.92, 0.92);
					bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
					bottomBoppers.updateHitbox();
					add(bottomBoppers);
				}


				var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('kapi/stagefront'));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;
				add(stageFront);

				phillyCityLights = new FlxTypedGroup<FlxSprite>();
				add(phillyCityLights);

				for (i in 0...4)
				{
					var light:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('kapi/win' + i));
					light.scrollFactor.set(0.9, 0.9);
					light.visible = false;
					light.updateHitbox();
					light.antialiasing = true;
					phillyCityLights.add(light);
				}

				if(!ClientPrefs.lowQuality)
				{
					upperBoppers = new FlxSprite(-600, -200);
					upperBoppers.frames = Paths.getSparrowAtlas('kapi/upperBop');
					upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
					upperBoppers.antialiasing = true;
					upperBoppers.scrollFactor.set(1.05, 1.05);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 1));
					upperBoppers.updateHitbox();
					add(upperBoppers);			
				}

				if(!PlayState.instance.modchartSprites.exists('blammedLightsBlack')) {  
					//Creates blammed light black fade in case you didn't make your own
					blammedLightsBlack = new ModchartSprite(FlxG.width * -0.5, FlxG.height * -0.5);
					blammedLightsBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					var position:Int = PlayState.instance.members.indexOf(PlayState.instance.gfGroup);
					if(PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup) < position) {
						position = PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup);
					} else if(PlayState.instance.members.indexOf(PlayState.instance.dadGroup) < position) {
						position = PlayState.instance.members.indexOf(PlayState.instance.dadGroup);
					}
					PlayState.instance.insert(position, blammedLightsBlack);
		
					blammedLightsBlack.wasAdded = true;
					PlayState.instance.modchartSprites.set('blammedLightsBlack', blammedLightsBlack);
			    }
			    PlayState.instance.insert(members.indexOf(blammedLightsBlack) + 1, phillyCityLightsEvent);
			    blammedLightsBlack = PlayState.instance.modchartSprites.get('blammedLightsBlack');
			    blammedLightsBlack.alpha = 0.0;


				phillyCityLightsEvent = new FlxTypedGroup<FlxSprite>();
				layers.get("foreground").add(phillyCityLightsEvent);

				for (i in 0...1)
				{
					var light:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('kapi/win' + i));
					light.scrollFactor.set(0.9, 0.9);
					light.visible = false;
					light.updateHitbox();
					light.antialiasing = true;
					phillyCityLightsEvent.add(light);						
				}
			case 'stadium':
				defaultCamZoom = 0.575;

				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('b3/stadium'));
				bg.antialiasing = true;
				bg.scrollFactor.set(1, 1);
				bg.active = false;
				add(bg);

				if(!ClientPrefs.lowQuality)
				{
					var upperBoppers = new FlxSprite(-600, -255);
					upperBoppers.frames = Paths.getSparrowAtlas('b3/mia_boppers');
					upperBoppers.animation.addByPrefix('idle', "Back Crowd Bop", 24, false);
					upperBoppers.antialiasing = true;
					upperBoppers.scrollFactor.set(1, 1);
					upperBoppers.updateHitbox();
					upperBoppers.animation.play('idle');
					add(upperBoppers);
					boppersAlt.push(upperBoppers);
	
					bottomBoppers = new FlxSprite(-600, -266);
					bottomBoppers.frames = Paths.getSparrowAtlas('b3/mia_boppers');
					bottomBoppers.animation.addByPrefix('idle', "Front Crowd Bop", 24, false);
					bottomBoppers.antialiasing = true;
					bottomBoppers.scrollFactor.set(1, 1);
					bottomBoppers.updateHitbox();
					bottomBoppers.animation.play('idle');
					add(bottomBoppers);
					boppersAlt.push(bottomBoppers);
				}

				var lights:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('b3/lights'));
				lights.antialiasing = true;
				lights.scrollFactor.set(1, 1);
				lights.active = false;
				layers.get('boyfriend').add(lights);
			case 'throne':
				var bg = new FlxSprite(-550, -243).loadGraphic(Paths.image('anchor/watah'));
				bg.scrollFactor.set(0.1, 0.1);
				bg.setGraphicSize(Std.int(bg.width * 1.5));
				bg.updateHitbox();
				bg.antialiasing = true;
				add(bg);

				var bg2 = new FlxSprite(-1271, -724).loadGraphic(Paths.image('anchor/throne'));
				bg2.scrollFactor.set(0.9, 0.9);
				bg2.setGraphicSize(Std.int(bg2.width * 1.95));
				bg2.updateHitbox();
				bg2.antialiasing = true;
				add(bg2);

				if(!ClientPrefs.lowQuality)
				{
					bottomBoppers = new FlxSprite(-564, 2);
					bottomBoppers.frames = Paths.getSparrowAtlas('anchor/feesh3');
					bottomBoppers.animation.addByPrefix('idle', 'ikan', 24, false);
					bottomBoppers.antialiasing = true;
					bottomBoppers.scrollFactor.set(0.9, 0.9);
					bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 0.95));
					bottomBoppers.updateHitbox();
					add(bottomBoppers);
					boppersAlt.push(bottomBoppers);
							
					var bgcrowd = new FlxSprite(-1020, 460);
					bgcrowd.frames = Paths.getSparrowAtlas('anchor/front');
					bgcrowd.animation.addByPrefix('idle', 'ikan', 24, false);
					bgcrowd.antialiasing = true;
					bgcrowd.setGraphicSize(Std.int(bgcrowd.width * 1.2));
					bgcrowd.updateHitbox();
					layers.get("boyfriend").add(bgcrowd);
					boppersAlt.push(bgcrowd);				
				}
			case 'prologue':
				defaultCamZoom = 0.9;

				if(!ClientPrefs.lowQuality) {
					var bg:FlxSprite = new FlxSprite(-100, -100).loadGraphic(Paths.image('prologue/rooftopsky'));
					add(bg);
				}

				var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('prologue/distantcity'));
				add(city);

				phillyCityLights = new FlxTypedGroup<FlxSprite>();
				add(phillyCityLights);

				for (i in 0...5)
				{
					var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('prologue/win' + i));
					light.scrollFactor.set(0.3, 0.3);
					light.visible = false;
					light.setGraphicSize(Std.int(light.width * 0.85));
					light.updateHitbox();
					light.antialiasing = true;
					phillyCityLights.add(light);
				}

				if(!ClientPrefs.lowQuality) {
					var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('prologue/poll'));
					add(streetBehind);
				}
		
				var street:FlxSprite = new FlxSprite(-130, 50).loadGraphic(Paths.image('prologue/rooftop'));
				add(street);

				if(!PlayState.instance.modchartSprites.exists('blammedLightsBlack')) {  
					//Creates blammed light black fade in case you didn't make your own
					blammedLightsBlack = new ModchartSprite(FlxG.width * -0.5, FlxG.height * -0.5);
					blammedLightsBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					var position:Int = PlayState.instance.members.indexOf(PlayState.instance.gfGroup);
					if(PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup) < position) {
						position = PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup);
					} else if(PlayState.instance.members.indexOf(PlayState.instance.dadGroup) < position) {
						position = PlayState.instance.members.indexOf(PlayState.instance.dadGroup);
					}
					PlayState.instance.insert(position, blammedLightsBlack);
		
					blammedLightsBlack.wasAdded = true;
					PlayState.instance.modchartSprites.set('blammedLightsBlack', blammedLightsBlack);
			    }
			    PlayState.instance.insert(members.indexOf(blammedLightsBlack) + 1, phillyCityLightsEvent);
			    blammedLightsBlack = PlayState.instance.modchartSprites.get('blammedLightsBlack');
			    blammedLightsBlack.alpha = 0.0;


				phillyCityLightsEvent = new FlxTypedGroup<FlxSprite>();
				layers.get("foreground").add(phillyCityLightsEvent);

				for (i in 0...5)
				{
					var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('prologue/win' + i));
					light.scrollFactor.set(0.3, 0.3);
					light.visible = false;
					light.setGraphicSize(Std.int(light.width * 0.85));
					light.updateHitbox();
					light.antialiasing = true;
					phillyCityLightsEvent.add(light);						
				}
			case 'ripdiner':
				defaultCamZoom = 0.5;
				var bg:FlxSprite = new FlxSprite(-820, -200).loadGraphic(Paths.image('fever/lastsongyukichi','shared'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);

				var bottomBoppers3 = new FlxSprite(-800, -180);
				bottomBoppers3.frames = Paths.getSparrowAtlas('fever/CROWD1', 'shared');
				bottomBoppers3.animation.addByPrefix('idle', "CROWD1", 24, false);
				bottomBoppers3.animation.play('idle');
				bottomBoppers3.scrollFactor.set(0.9, 0.9);
				layers.get("boyfriend").add(bottomBoppers3);
				boppersAlt.push(bottomBoppers3);
			case 'genocide':
				var genocideBG = new FlxSprite(-600, -300).loadGraphic(Paths.image('tabi/fire/wadsaaa'));
				genocideBG.antialiasing = true;
				genocideBG.scrollFactor.set(0.9, 0.9);
				add(genocideBG);

				if(!ClientPrefs.lowQuality) //MOST FIRE NEED LOWQUALITY
				{
					var siniFireBehind = new FlxTypedGroup<SiniFire>();
					for (i in 0...2)
					{
						var daFire:SiniFire = new SiniFire(genocideBG.x + (720 + (((95 * 10) / 2) * i)), genocideBG.y + 180, true, false, 30, i * 10, 84);
						daFire.antialiasing = true;
						daFire.scrollFactor.set(0.9, 0.9);
						daFire.scale.set(0.4, 1);
						daFire.y += 50;
						siniFireBehind.add(daFire);
					}
						
					add(siniFireBehind);

				}
						
				var genocideBoard = new FlxSprite(genocideBG.x, genocideBG.y).loadGraphic(Paths.image('tabi/fire/boards'));
				genocideBoard.antialiasing = true;
				genocideBoard.scrollFactor.set(0.9, 0.9);
				add(genocideBoard);

				if(!ClientPrefs.lowQuality)
				{
					var siniFireFront = new FlxTypedGroup<SiniFire>();

					var fire1:SiniFire = new SiniFire(genocideBG.x + (-100), genocideBG.y + 889, true, false, 30);
					fire1.antialiasing = true;
					fire1.scrollFactor.set(0.9, 0.9);
					fire1.scale.set(2.5, 1.5);
					fire1.y -= fire1.height * 1.5;
					fire1.flipX = true;
					siniFireFront.add(fire1);
						
					var fire2:SiniFire = new SiniFire((fire1.x + fire1.width) - 80, genocideBG.y + 889, true, false, 30);
					fire2.antialiasing = true;
					fire2.scrollFactor.set(0.9, 0.9);
					fire2.y -= fire2.height * 1;
					siniFireFront.add(fire2);
						
					var fire3:SiniFire = new SiniFire((fire2.x + fire2.width) - 30, genocideBG.y + 889, true, false, 30);
					fire3.antialiasing = true;
					fire3.scrollFactor.set(0.9, 0.9);
					fire3.y -= fire3.height * 1;
					siniFireFront.add(fire3);
		
					var fire4:SiniFire = new SiniFire((fire3.x + fire3.width) - 10, genocideBG.y + 889, true, false, 30);
					fire4.antialiasing = true;
					fire4.scrollFactor.set(0.9, 0.9);
					fire4.scale.set(1.5, 1.5);
					fire4.y -= fire4.height * 1.5;
					siniFireFront.add(fire4);
					add(siniFireFront);
				}

				var path:String = "";
				if (PlayState.SONG.song.toLowerCase() == 'crucify')
					path = 'tabi/fire/glowyfurniture2';
				else
					path = 'tabi/fire/glowyfurniture';

				var fuckYouFurniture:FlxSprite = new FlxSprite(genocideBG.x, genocideBG.y).loadGraphic(Paths.image(path));
				fuckYouFurniture.antialiasing = true;
				fuckYouFurniture.scrollFactor.set(0.9, 0.9);
				add(fuckYouFurniture);

				var destBoombox:FlxSprite = new FlxSprite(400, 130).loadGraphic(Paths.image('tabi/fire/Destroyed_boombox'));
				destBoombox.y += (destBoombox.height - 648) * -1;
				destBoombox.y += 150;
				destBoombox.x -= 110;
				destBoombox.scale.set(1.2, 1.2);
				add(destBoombox);

				var sumsticks:FlxSprite = new FlxSprite(-600, -300).loadGraphic(Paths.image('tabi/fire/overlayingsticks'));
				sumsticks.antialiasing = true;
				sumsticks.scrollFactor.set(0.9, 0.9);
				sumsticks.active = false;
				layers.get("boyfriend").add(sumsticks);
			case 'neon':
				defaultCamZoom = 0.7;
				var hscriptPath = 'shootin/neon/';

				if(!ClientPrefs.lowQuality) {
					var bg = new FlxSprite(-430, -438).loadGraphic(Paths.image(hscriptPath + 'sky'));
					bg.scrollFactor.set(0.1, 0.1);
					bg.antialiasing = true;
					add(bg);
				}

				var city = new FlxSprite(-2000, -300).loadGraphic(Paths.image(hscriptPath + 'city'));
				city.antialiasing = true;
   				city.updateHitbox();
				add(city);

				var phillyCityLights = new FlxTypedGroup<FlxSprite>();
				add(phillyCityLights);

				for (i in 0...5)
				{
					var light:FlxSprite = new FlxSprite(-120, 117).loadGraphic(Paths.image(hscriptPath + 'win' + i + ''));
					light.visible = false;
					light.antialiasing = true;
					phillyCityLights.add(light);
				}

				if(!ClientPrefs.lowQuality) {
					var streetBehind = new FlxSprite(-40, 10).loadGraphic(Paths.image(hscriptPath + 'behindTrain'));
					streetBehind.antialiasing = true;
					add(streetBehind);
				}

				phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image(hscriptPath + 'train'));
				phillyTrain.antialiasing = true;
				add(phillyTrain);

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
				FlxG.sound.list.add(trainSound);

				var street = new FlxSprite(-120, 117).loadGraphic(Paths.image(hscriptPath + 'street'));
				street.antialiasing = true;
				add(street);

				if (PlayState.SONG.song.toLowerCase() == 'technokinesis')
				{
					var chara = new Character(250, 300, 'chara');
					add(chara);
				}

				if(!PlayState.instance.modchartSprites.exists('blammedLightsBlack')) {  
					//Creates blammed light black fade in case you didn't make your own
					blammedLightsBlack = new ModchartSprite(FlxG.width * -0.5, FlxG.height * -0.5);
					blammedLightsBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					var position:Int = PlayState.instance.members.indexOf(PlayState.instance.gfGroup);
					if(PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup) < position) {
						position = PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup);
					} else if(PlayState.instance.members.indexOf(PlayState.instance.dadGroup) < position) {
						position = PlayState.instance.members.indexOf(PlayState.instance.dadGroup);
					}
					PlayState.instance.insert(position, blammedLightsBlack);
		
					blammedLightsBlack.wasAdded = true;
					PlayState.instance.modchartSprites.set('blammedLightsBlack', blammedLightsBlack);
			    }
			    PlayState.instance.insert(members.indexOf(blammedLightsBlack) + 1, phillyCityLightsEvent);
			    blammedLightsBlack = PlayState.instance.modchartSprites.get('blammedLightsBlack');
			    blammedLightsBlack.alpha = 0.0;


				phillyCityLightsEvent = new FlxTypedGroup<FlxSprite>();
				layers.get("foreground").add(phillyCityLightsEvent);

				for (i in 0...5)
				{
					var light:FlxSprite = new FlxSprite(-120, 117).loadGraphic(Paths.image(hscriptPath + 'win' + i + ''));
					light.visible = false;
					light.antialiasing = true;
					phillyCityLightsEvent.add(light);						
				}
			case 'defeat':
				var defeat:FlxSprite = new FlxSprite(0, 100).loadGraphic(Paths.image('impostor/blackBG', 'shared'));		
				defeat.setGraphicSize(Std.int(defeat.width * 2));
				defeat.scrollFactor.set(1,1);
				defeat.antialiasing = true;
				add(defeat);
			case 'studioLot':
				var bg:FlxSprite = new FlxSprite(-300, -400).loadGraphic(Paths.image('studioLot/sky'));
				bg.antialiasing = FlxG.save.data.antialiasing;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);

				var mountainback:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('studioLot/mountainback'));
				mountainback.updateHitbox();
				mountainback.scrollFactor.set(0.9, 0.9);
				mountainback.active = false;
				add(mountainback);

				var moutainsfoward:FlxSprite = new FlxSprite(-500, 100).loadGraphic(Paths.image('studioLot/moutainsfoward'));
				moutainsfoward.updateHitbox();
				moutainsfoward.scrollFactor.set(0.9, 0.9);
				moutainsfoward.active = false;
				add(moutainsfoward);

				var bushes:FlxSprite = new FlxSprite(-100, -700).loadGraphic(Paths.image('studioLot/bushes'));
				bushes.updateHitbox();
				bushes.antialiasing = FlxG.save.data.antialiasing;
				bushes.scrollFactor.set(0.9, 0.9);
				bushes.active = false;
				add(bushes);

				var studio:FlxSprite = new FlxSprite(0, -1000).loadGraphic(Paths.image('studioLot/studio'));
				studio.updateHitbox();
				studio.scrollFactor.set(0.9, 0.9);
				studio.active = false;
				add(studio);

				var ground:FlxSprite = new FlxSprite(-1200, 560).loadGraphic(Paths.image('studioLot/ground'));
				ground.setGraphicSize(Std.int(ground.width * 2));
				ground.updateHitbox();
				ground.scrollFactor.set(0.9, 0.9);
				ground.active = false;
				add(ground);
			case 'incident':
				var bgt:FlxSprite = new FlxSprite(-500, -260).loadGraphic(Paths.image('BB1'));
				bgt.active = false;				
				add(bgt);

				if(PlayState.instance.gf.curCharacter.endsWith('-noSpeaker'))//if GF DON'T HAVE ANY SPEAKER
				{
					var trashcan:FlxSprite = new FlxSprite(565, 420).loadGraphic(Paths.image('trashcan'));
					trashcan.scrollFactor.set(0.95, 0.95);
					trashcan.active = false;			
					add(trashcan);
				}
			case 'stare':
				var starecrownBG = new FlxSprite(-400, -175);
				starecrownBG.frames = Paths.getSparrowAtlas('starecrown/Maze');
				starecrownBG.animation.addByPrefix('idle', 'Stage');
				starecrownBG.animation.play('idle');
				starecrownBG.antialiasing = true;
				starecrownBG.scrollFactor.set(0.3, 0.3);
				starecrownBG.setGraphicSize(Std.int(starecrownBG.width * 1.5));
				starecrownBG.updateHitbox();
				add(starecrownBG);
			case 'garStageRise':
				var bg = new FlxSprite(-500, -170).loadGraphic(Paths.image('garcello/garStagebgRise'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);

				var stageFront:FlxSprite = new FlxSprite(-500, -200).loadGraphic(Paths.image('garcello/garStageRise'));
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;
				add(stageFront);
			case 'garStageDead':
				var bg:FlxSprite = new FlxSprite(-500, -170).loadGraphic(Paths.image('garcello/garStagebgAlt'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.7, 0.7);
				bg.active = false;
				add(bg);

				var smoker:FlxSprite = new FlxSprite(0, -290);
				smoker.frames = Paths.getSparrowAtlas('garcello/garSmoke');
				smoker.setGraphicSize(Std.int(smoker.width * 1.7));
				smoker.alpha = 0.3;
				smoker.animation.addByPrefix('garsmoke', "smokey", 13);
				smoker.animation.play('garsmoke');
				smoker.scrollFactor.set(0.7, 0.7);
				add(smoker);

				var bgAlley:FlxSprite = new FlxSprite(-500, -200).loadGraphic(Paths.image('garcello/garStagealt'));
				bgAlley.antialiasing = true;
				bgAlley.scrollFactor.set(0.9, 0.9);
				bgAlley.active = false;
				add(bgAlley);

				var corpse:FlxSprite = new FlxSprite(-230, 540).loadGraphic(Paths.image('garcello/gardead'));
				corpse.antialiasing = true;
				corpse.scrollFactor.set(0.9, 0.9);
				corpse.active = false;
				add(corpse);

				var smoke:FlxSprite = new FlxSprite(0, 0);
				smoke.frames = Paths.getSparrowAtlas('garcello/garSmoke');
				smoke.setGraphicSize(Std.int(smoke.width * 1.6));
				smoke.animation.addByPrefix('garsmoke', "smokey", 15);
				smoke.animation.play('garsmoke');
				smoke.scrollFactor.set(1.1, 1.1);
				layers.get("boyfriend").add(smoke);
			case 'operaStage' | 'operaStage-old':
				switch (curStage)
				{
					case 'operaStage': pre = 'operastage';
					case 'operaStage-old': pre = 'operastage_old';
				}
	
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('backgrounds/'+pre+'/stageback','shared'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);

				var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('backgrounds/'+pre+'/stagefront','shared'));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;
				add(stageFront);
			case 'motherland':
				var bg:FlxSprite = new FlxSprite(-705, -705).loadGraphic(Paths.image('holofunk/russia/motherBG'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);

				if (PlayState.SONG.song.toLowerCase() == 'killer-scream')
				{
					var bluescreen:FlxSprite = new FlxSprite(-655, -505).loadGraphic(Paths.image('holofunk/russia/bluescreen'));
					bluescreen.antialiasing = true;
					bluescreen.scrollFactor.set(0.9, 0.9);
					bluescreen.active = false;
					bluescreen.setGraphicSize(Std.int(bluescreen.width * 1.4));
					bluescreen.updateHitbox();
					add(bluescreen);
				}
				
				var bg2:FlxSprite = new FlxSprite(-735, -670).loadGraphic(Paths.image('holofunk/russia/motherFG'));
				bg2.antialiasing = true;
				bg2.scrollFactor.set(0.9, 0.9);
				bg2.active = false;
				bg2.setGraphicSize(Std.int(bg2.width * 1.1));
				bg2.updateHitbox();
				add(bg2);

				var plants:FlxSprite = new FlxSprite(-705, -705).loadGraphic(Paths.image('holofunk/russia/plants'));
				plants.antialiasing = true;
				plants.scrollFactor.set(1.3, 1.3);
				plants.active = false;
				plants.setGraphicSize(Std.int(plants.width * 1.5));
				plants.updateHitbox();
				plants.setPosition(-1415, -1220);
				layers.get("boyfriend").add(plants);

				var blackScreen = new FlxSprite(-1000, -500).makeGraphic(Std.int(FlxG.width * 5), Std.int(FlxG.height * 5), FlxColor.BLACK);
				layers.get("boyfriend").add(blackScreen);
			case 'glitcher':
				var glitcherBG = new FlxSprite(-600, -200).loadGraphic(Paths.image('hex/stageback_glitcher'));
				glitcherBG.antialiasing = true;
				glitcherBG.scrollFactor.set(0.9, 0.9);
				glitcherBG.active = false;
				add(glitcherBG);

				var glitcherFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('hex/stagefront_glitcher'));
				glitcherFront.setGraphicSize(Std.int(glitcherFront.width * 1.1));
				glitcherFront.updateHitbox();
				glitcherFront.antialiasing = true;
				glitcherFront.scrollFactor.set(0.9, 0.9);
				glitcherFront.active = false;
				add(glitcherFront);

				var wireBG = new FlxSprite(-600, -200).loadGraphic(Paths.image('hex/WIREStageBack'));
				wireBG.antialiasing = true;
				wireBG.scrollFactor.set(0.9, 0.9);
				wireBG.active = false;
				add(wireBG);
			case 'hallway':
				var bg:FlxSprite = new FlxSprite(-360, -210).loadGraphic(Paths.image('eteled/glitchhallway'));
				bg.antialiasing = FlxG.save.data.antialiasing;
				bg.scrollFactor.set(1, 1);
				bg.active = false;
				add(bg);
			case 'market':
				var bg:FlxSprite = new FlxSprite(-650, -50).loadGraphic(Paths.image('entity/AldryxBG'));
				bg.antialiasing = FlxG.save.data.antialiasing;
				bg.scrollFactor.set(1, 1);
				bg.active = false;
				add(bg);
			case 'hall':
				var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('entity/NikusaBG'));
				bg.antialiasing = FlxG.save.data.antialiasing;
				bg.scrollFactor.set(1, 1);
				bg.setPosition(-1000, -425);
				bg.active = false;
				add(bg);
			case 'sonicStage':
				
				var bgspec = new FlxSprite(-600, -600).makeGraphic(3840, 2160, (FlxColor.fromString('#' + 'D60000'))); // some parts are too low and can be seen with maijin
				bgspec.antialiasing = true;
				bgspec.scrollFactor.set(1, 1);
				bgspec.active = false;
				add(bgspec);

				var sSKY:FlxSprite = new FlxSprite(-222, 134).loadGraphic(Paths.image('exe/PolishedP1/SKY'));
				sSKY.antialiasing = true;
				sSKY.scrollFactor.set(1, 1);
				sSKY.active = false;
				add(sSKY);

				var hills:FlxSprite = new FlxSprite(-264, -156 + 150).loadGraphic(Paths.image('exe/PolishedP1/HILLS'));
				hills.antialiasing = true;
				hills.scrollFactor.set(1.1, 1);
				hills.active = false;
				add(hills);

				var bg2:FlxSprite = new FlxSprite(-345, -289 + 170).loadGraphic(Paths.image('exe/PolishedP1/FLOOR2'));
				bg2.updateHitbox();
				bg2.antialiasing = true;
				bg2.scrollFactor.set(1.2, 1);
				bg2.active = false;
				add(bg2);

				var bg:FlxSprite = new FlxSprite(-297, -246 + 150).loadGraphic(Paths.image('exe/PolishedP1/FLOOR1'));
				bg.antialiasing = true;
				bg.scrollFactor.set(1.3, 1);
				bg.active = false;
				add(bg);

				if(!ClientPrefs.lowQuality)
				{
					var eggman:FlxSprite = new FlxSprite(-218, -219 + 150).loadGraphic(Paths.image('exe/PolishedP1/EGGMAN'));
					eggman.updateHitbox();
					eggman.antialiasing = true;
					eggman.scrollFactor.set(1.32, 1);
					eggman.active = false;
					add(eggman);
	
					var tail:FlxSprite = new FlxSprite(-199 - 150, -259 + 150).loadGraphic(Paths.image('exe/PolishedP1/TAIL'));
					tail.updateHitbox();
					tail.antialiasing = true;
					tail.scrollFactor.set(1.34, 1);
					tail.active = false;
					add(tail);
	
					var knuckle:FlxSprite = new FlxSprite(185 + 100, -350 + 150).loadGraphic(Paths.image('exe/PolishedP1/KNUCKLE'));
					knuckle.updateHitbox();
					knuckle.antialiasing = true;
					knuckle.scrollFactor.set(1.36, 1);
					knuckle.active = false;
					add(knuckle);
	
					var sticklol:FlxSprite = new FlxSprite(-100, 50);
					sticklol.frames = Paths.getSparrowAtlas('exe/PolishedP1/TailsSpikeAnimated');
					sticklol.animation.addByPrefix('a', 'Tails Spike Animated instance 1', 4, true);
					sticklol.setGraphicSize(Std.int(sticklol.width * 1.2));
					sticklol.updateHitbox();
					sticklol.antialiasing = true;
					sticklol.scrollFactor.set(1.37, 1);
					add(sticklol);
				}
			case 'sonicFUNSTAGE':
				var funsky:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('exe/FunInfiniteStage/sonicFUNsky'));
				funsky.setGraphicSize(Std.int(funsky.width * 0.9));
				funsky.antialiasing = true;
				funsky.scrollFactor.set(0.3, 0.3);
				funsky.active = false;
				add(funsky);

				var funbush:FlxSprite = new FlxSprite(-42, 171).loadGraphic(Paths.image('exe/FunInfiniteStage/Bush2'));
				funbush.antialiasing = true;
				funbush.scrollFactor.set(0.3, 0.3);
				funbush.active = false;
				add(funbush);

				if(!ClientPrefs.lowQuality)
				{
					var funpillarts2ANIM = new FlxSprite(182, -100); // Zekuta why...
					funpillarts2ANIM.frames = Paths.getSparrowAtlas('exe/FunInfiniteStage/Majin Boppers Back');
					funpillarts2ANIM.animation.addByPrefix('idle', 'MajinBop2 instance 1', 24);
					// funpillarts2ANIM.setGraphicSize(Std.int(funpillarts2ANIM.width * 0.7));
					funpillarts2ANIM.antialiasing = true;
					funpillarts2ANIM.scrollFactor.set(0.6, 0.6);
					add(funpillarts2ANIM);
					boppersAlt.push(funpillarts2ANIM);
				}


				var funbush2:FlxSprite = new FlxSprite(132, 354).loadGraphic(Paths.image('exe/FunInfiniteStage/Bush 1'));
				funbush2.antialiasing = true;
				funbush2.scrollFactor.set(0.3, 0.3);
				funbush2.active = false;
				add(funbush2);

				if(!ClientPrefs.lowQuality)
				{
					var funpillarts1ANIM = new FlxSprite(-169, -167);
					funpillarts1ANIM.frames = Paths.getSparrowAtlas('exe/FunInfiniteStage/Majin Boppers Front');
					funpillarts1ANIM.animation.addByPrefix('idle', 'MajinBop1 instance 1', 24);
					// funpillarts1ANIM.setGraphicSize(Std.int(funpillarts1ANIM.width * 0.7));
					funpillarts1ANIM.antialiasing = true;
					funpillarts1ANIM.scrollFactor.set(0.6, 0.6);
					add(funpillarts1ANIM);
					boppersAlt.push(funpillarts1ANIM);
				}


				var funfloor:FlxSprite = new FlxSprite(-340, 660).loadGraphic(Paths.image('exe/FunInfiniteStage/floor BG'));
				funfloor.antialiasing = true;
				funfloor.scrollFactor.set(0.5, 0.5);
				funfloor.active = false;
				add(funfloor);

				if(!ClientPrefs.lowQuality)
				{
					var funboppers1ANIM = new FlxSprite(1126, 903);
					funboppers1ANIM.frames = Paths.getSparrowAtlas('exe/FunInfiniteStage/majin FG1');
					funboppers1ANIM.animation.addByPrefix('idle', 'majin front bopper1', 24);
					funboppers1ANIM.antialiasing = true;
					funboppers1ANIM.scrollFactor.set(0.8, 0.8);
					layers.get("boyfriend").add(funboppers1ANIM);
					boppersAlt.push(funboppers1ANIM);
	
					var funboppers2ANIM = new FlxSprite(-293, 871);
					funboppers2ANIM.frames = Paths.getSparrowAtlas('exe/FunInfiniteStage/majin FG2');
					funboppers2ANIM.animation.addByPrefix('idle', 'majin front bopper2', 24);
					funboppers2ANIM.antialiasing = true;
					funboppers2ANIM.scrollFactor.set(0.8, 0.8);
					layers.get("boyfriend").add(funboppers2ANIM);
					boppersAlt.push(funboppers2ANIM);
				}
			case 'trioStage'|'trioStageTwo':
				var sSKY:FlxSprite = new FlxSprite(-621.1, -395.65).loadGraphic(Paths.image('exe/Phase3/Glitch'));
				sSKY.antialiasing = true;
				sSKY.scrollFactor.set(0.9, 1);
				sSKY.active = false;
				sSKY.scale.x = 1.2;
				sSKY.scale.y = 1.2;
				add(sSKY);

				if(curStage == 'trioStageTwo')
				{
					var p3staticbg = new FlxSprite(0, 0);
					p3staticbg.frames = Paths.getSparrowAtlas('exe/NewTitleMenuBG');
					p3staticbg.animation.addByPrefix('P3Static', 'TitleMenuSSBG instance 1', 24, true);
					p3staticbg.animation.play('P3Static');
					p3staticbg.screenCenter();
					p3staticbg.scale.x = 4.5;
					p3staticbg.scale.y = 4.5;
					add(p3staticbg);
				}


				var trees:FlxSprite = new FlxSprite(-607.35, -401.55).loadGraphic(Paths.image('exe/Phase3/Trees'));
				trees.antialiasing = true;
				trees.scrollFactor.set(0.95, 1);
				trees.active = false;
				trees.scale.x = 1.2;
				trees.scale.y = 1.2;
				add(trees);
				
				var bg2:FlxSprite = new FlxSprite(-623.5, -410.4).loadGraphic(Paths.image('exe/Phase3/Trees2'));
				bg2.updateHitbox();
				bg2.antialiasing = true;
				bg2.scrollFactor.set(1, 1);
				bg2.active = false;
				bg2.scale.x = 1.2;
				bg2.scale.y = 1.2;
				add(bg2);

				var bg:FlxSprite = new FlxSprite(-630.4, -266).loadGraphic(Paths.image('exe/Phase3/Grass'));
				bg.antialiasing = true;
				bg.scrollFactor.set(1.1, 1);
				bg.active = false;
				bg.scale.x = 1.2;
				bg.scale.y = 1.2;
				add(bg);
			case 'subway':
				defaultCamZoom = 0.7;
				var bg:FlxSprite = new FlxSprite(-500, -500).loadGraphic(Paths.image('mami/BGSky'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);

				var trainSubway:FlxSprite = new FlxSprite(-500, -100).loadGraphic(Paths.image('mami/BGTrain', 'shared'));
				trainSubway.updateHitbox();
				trainSubway.antialiasing = true;
				trainSubway.scrollFactor.set(0.9, 0.9);
				trainSubway.active = false;
				add(trainSubway);

				stageFront = new FlxSprite(-500, 600).loadGraphic(Paths.image('mami/BGFloor', 'shared'));
				stageFront.updateHitbox();
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;
				add(stageFront);

				lampsSubway = new FlxSprite(-500, -300).loadGraphic(Paths.image('mami/BGLamps', 'shared'));
				lampsSubway.updateHitbox();
				lampsSubway.antialiasing = true;
				lampsSubway.scrollFactor.set(0.9, 0.9);
				lampsSubway.active = false;
				add(lampsSubway);

				lampsLeft = new FlxSprite(-500, -300).loadGraphic(Paths.image('mami/BGLampLights', 'shared'));
				lampsLeft.updateHitbox();
				lampsLeft.antialiasing = true;
				lampsLeft.scrollFactor.set(0.9, 0.9);
				lampsLeft.active = false;
				layers.get("boyfriend").add(lampsLeft);

				weebGorl = new FlxSprite(1200, 0);
				weebGorl.frames = Paths.getSparrowAtlas('mami/BG/BGbackgirl', 'shared');
				weebGorl.animation.addByPrefix('move', "Symbol 6 instance 1", 24, false);
				weebGorl.antialiasing = true;
				weebGorl.scrollFactor.set(0.9, 0.9);
				weebGorl.updateHitbox();
				weebGorl.active = true;
				add(weebGorl);

				otherBGStuff = new FlxSprite(-530, -50).loadGraphic(Paths.image('mami/BGRandomshit', 'shared'));
				otherBGStuff.updateHitbox();
				otherBGStuff.antialiasing = true;
				otherBGStuff.scrollFactor.set(0.9, 0.9);
				otherBGStuff.active = false;
				add(otherBGStuff);		
			
				gorls = new FlxSprite(-360, 150);
				gorls.frames = Paths.getSparrowAtlas('mami/BGGirlsDance', 'shared');
				gorls.animation.addByPrefix('move', "girls dancing instance 1", 24, false);
				gorls.antialiasing = true;
				gorls.scrollFactor.set(0.9, 0.9);
				gorls.updateHitbox();
				gorls.active = true;
				add(gorls);

				connectLight = new FlxSprite(0, 0).loadGraphic(Paths.image('mami/connect_flash', 'shared'));
				connectLight.setGraphicSize(Std.int(connectLight.width * 1));
				connectLight.updateHitbox();
				connectLight.antialiasing = true;
				connectLight.scrollFactor.set(0, 0);
				connectLight.active = false;
				connectLight.alpha = 0.0;
				connectLight.cameras = [PlayState.instance.camOther];
				add(connectLight);
			case 'subway-holy':
				var bg:FlxSprite = new FlxSprite(-500, -500).loadGraphic(Paths.image('mami/BGSky'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);

				var trainSubway:FlxSprite = new FlxSprite(-500, -100).loadGraphic(Paths.image('mami/BGTrain', 'shared'));
				trainSubway.updateHitbox();
				trainSubway.antialiasing = true;
				trainSubway.scrollFactor.set(0.9, 0.9);
				trainSubway.active = false;
				add(trainSubway);

				whiteBG = new FlxSprite(-480, -480).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
				whiteBG.updateHitbox();
				whiteBG.antialiasing = true;
				whiteBG.scrollFactor.set(0, 0);
				whiteBG.active = false;
				whiteBG.alpha = 0.0;
				add(whiteBG);

				gunSwarmBack = new FlxBackdrop(Paths.image('mami/HOLY/HOLY_gunsbackconstant'), 1, 0, true, true);
				gunSwarmBack.scrollFactor.set(0.8, 0);
				add(gunSwarmBack);
				gunSwarmBack.velocity.set(-8500, 1500);
				gunSwarmBack.alpha = 0.0;

				stageFront = new FlxSprite(-500, 600).loadGraphic(Paths.image('mami/HOLY/HOLY_floor', 'shared'));
				stageFront.updateHitbox();
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;
				add(stageFront);

				lampsSubway = new FlxSprite(-500, -300).loadGraphic(Paths.image('mami/BGLamps', 'shared'));
				lampsSubway.updateHitbox();
				lampsSubway.antialiasing = true;
				lampsSubway.scrollFactor.set(0.9, 0.9);
				lampsSubway.active = false;
				add(lampsSubway);

				lampsLeft = new FlxSprite(-500, -300).loadGraphic(Paths.image('mami/HOLY/HOLY_BGLampLights', 'shared'));
				lampsLeft.updateHitbox();
				lampsLeft.antialiasing = true;
				lampsLeft.scrollFactor.set(0.9, 0.9);
				lampsLeft.active = false;
				layers.get("boyfriend").add(lampsLeft);

				otherBGStuff = new FlxSprite(-530, -50).loadGraphic(Paths.image('mami/HOLY/HOLY_objects', 'shared'));
				otherBGStuff.updateHitbox();
				otherBGStuff.antialiasing = true;
				otherBGStuff.scrollFactor.set(0.9, 0.9);
				otherBGStuff.active = false;
				add(otherBGStuff);				

				holyHomura = new FlxSprite(-360, 350);
				holyHomura.frames = Paths.getSparrowAtlas('mami/HOLY/HOLY_women', 'shared');
				holyHomura.animation.addByPrefix('move', "animegirl", 24, false);
				holyHomura.antialiasing = true;
				holyHomura.scrollFactor.set(0.9, 0.9);
				holyHomura.updateHitbox();
				holyHomura.active = true;
				add(holyHomura);

				gunSwarm = new FlxSprite(-1000, 0).loadGraphic(Paths.image('mami/HOLY/HOLY_guns', 'shared'));
				gunSwarm.setGraphicSize(Std.int(gunSwarm.width * 1));
				gunSwarm.antialiasing = true;
				gunSwarm.scrollFactor.set(0.9, 0.9);
				gunSwarm.updateHitbox();
				gunSwarm.active = true;
				gunSwarmFront = new FlxBackdrop(Paths.image('mami/HOLY/HOLY_gunsfrontconstant'), 1, 0, true, true);
				gunSwarmFront.scrollFactor.set(1.1, 0);
			case 'missingno':
				var resizeBG:Float = 6;
				var consistentPosition:Array<Float> = [-670, -240];

				var background:FlxSprite = new FlxSprite(consistentPosition[0] + 30, consistentPosition[1]);
				
				background.frames = Paths.getSparrowAtlas('hypno/missingno/bg', 'shared');
				background.animation.addByPrefix('idle', 'sky', 24, true);
				background.animation.play('idle');
				background.scale.set(resizeBG, resizeBG);
				background.updateHitbox();
				background.scrollFactor.set(0.3, 0.3);
				add(background);

				var missingnoOcean = new FlxSprite(consistentPosition[0], consistentPosition[1]);
				missingnoOcean.frames = Paths.getSparrowAtlas('hypno/missingno/BG_Assets', 'shared');
				missingnoOcean.animation.addByPrefix('idle', 'Bg Ocean', 24, true);
				missingnoOcean.animation.play('idle');
				missingnoOcean.scale.set(resizeBG, resizeBG);
				missingnoOcean.updateHitbox();
				missingnoOcean.scrollFactor.set(0.4, 0.4);
				add(missingnoOcean);

				var ground:FlxSprite = new FlxSprite(consistentPosition[0], consistentPosition[1]);
				ground.frames = Paths.getSparrowAtlas('hypno/missingno/BG_Assets', 'shared');
				ground.animation.addByPrefix('idle', 'Bg Wave', 24, true);
				ground.animation.play('idle');
				ground.scale.set(resizeBG, resizeBG);
				ground.updateHitbox();
				add(ground);
			default:
				// STAGE SCRIPTS
				#if (MODS_ALLOWED && LUA_ALLOWED)
				var doPush:Bool = false;
				var luaFile:String = 'stages/' + curStage + '.lua';
				if(FileSystem.exists(Paths.modFolders(luaFile))) {
					luaFile = Paths.modFolders(luaFile);
					doPush = true;
			    } else {
					luaFile = Paths.getPreloadPath(luaFile);
					if(FileSystem.exists(luaFile)) {
						doPush = true;
					}
				}
				
			    if(doPush) 
					PlayState.instance.luaArray.push(new FunkinLua(luaFile));
				#end
        }
    }

    var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

    function lightningStrikeShit(curBeat:Int):Void
    {
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		if(!ClientPrefs.lowQuality) halloweenBG.animation.play('halloweem bg lightning strike');

		lightningOffset = FlxG.random.int(8, 24);
		lightningStrikeBeat = curBeat;

		if(PlayState.instance.boyfriend.animOffsets.exists('scared')) {
			PlayState.instance.boyfriend.playAnim('scared', true);
		}
		if(PlayState.instance.gf.animOffsets.exists('scared') && PlayState.instance.gf != null) {
			PlayState.instance.gf.playAnim('scared', true);
		}

		if(ClientPrefs.camZooms) {
			FlxG.camera.zoom += 0.015;
			PlayState.instance.camHUD.zoom += 0.03;

			if(!PlayState.instance.camZooming) { //Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
				FlxTween.tween(FlxG.camera, {zoom: PlayState.instance.defaultCamZoom}, 0.5);
				FlxTween.tween(PlayState.instance.camHUD, {zoom: 1}, 0.5);
			}
		}

		if(ClientPrefs.flashing) {
			halloweenWhite.alpha = 0.4;
			FlxTween.tween(halloweenWhite, {alpha: 0.5}, 0.075);
			FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
		}
    }


    var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;
	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;
    var startedMoving:Bool = false;
    var curLight:Int = 0;

    function trainStart():Void
    {
        trainMoving = true;
        if (!trainSound.playing)
            trainSound.play(true);
    }

    function updateTrainPos():Void
    {
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			if(PlayState.instance.gf != null)
			{
				PlayState.instance.gf.playAnim('hairBlow');
				PlayState.instance.gf.specialAnim = true;
			}
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
    }

    function trainReset():Void
    {
		if(PlayState.instance.gf != null)
		{
			PlayState.instance.gf.danced = false; //Sets head to the correct position once the animation ends
			PlayState.instance.gf.playAnim('hairFall');
			PlayState.instance.gf.specialAnim = true;
		}
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;        
    }


    var fastCarCanDrive:Bool = true;
	var henchmenDies:Bool = true;
    public var carTimer:FlxTimer;
    var limoSpeed:Float = 0;
    public function resetFastCar():Void
    {
 		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCar.visible = false;
		fastCarCanDrive = true;
    }

    function fastCarDrive()
    {
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.visible = true;
		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		carTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
			carTimer = null;
		});       
    }

    function resetLimoKill():Void
    {
        limoMetalPole.x = -500;
        limoMetalPole.visible = false;
        limoLight.x = -500;
        limoLight.visible = false;
        limoCorpse.x = -500;
        limoCorpse.visible = false;
        limoCorpseTwo.x = -500;
        limoCorpseTwo.visible = false;
		henchmenDies = true;
    }

    public function killHenchmen():Void
    {
        if(!ClientPrefs.lowQuality) {
            if(limoKillingState < 1) {
				henchmenDies = false;
                limoMetalPole.x = -400;
                limoMetalPole.visible = true;
                limoLight.visible = true;
                limoCorpse.visible = false;
                limoCorpseTwo.visible = false;
                limoKillingState = 1;

                #if ACHIEVEMENTS_ALLOWED
                Achievements.henchmenDeath++;
                FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;
                var achieve:String = PlayState.instance.checkForAchievement(['roadkill_enthusiast']);
                if (achieve != null) {
                    PlayState.instance.startAchievement(achieve);
                } else {
                    FlxG.save.flush();
                }
                FlxG.log.add('Deaths: ' + Achievements.henchmenDeath);
                #end
            }
        }           
    }

	public function updateGraph() 
	{
		graphPointer.y += graphMove;
		
		var theColor = FlxColor.ORANGE;

		if (shinyMode && graphMoveTimer == 1) {
			graphPointer.y += FlxG.random.float(4, 4.1, [0]);
			neutralGraphPos = graphPointer.y;
		}
		
		if (graphMoveTimer > 0) {
			graphMoveTimer--;
		} else if (graphMoveTimer == 0) {
			graphMove = 0;
			graphMoveTimer = -1;
			if (shinyMode) {
				shinyMode = false;
				graphMode = oldMode;
			}
		}
		switch (graphMode) {
			case 0:
				var a = FlxG.random.int(0, 150);
				
				if (graphBurstTimer > 0) {
					graphBurstTimer--;
				} else if (graphBurstTimer == 0) {
					graphBurstTimer = FlxG.random.int(90, 220);
					//graphBurstTimer = -1;
					if (graphMoveTimer <= 0) {
						graphMove = FlxG.random.float(-0.4, 0.4, [0]);
						graphMoveTimer = FlxG.random.int(8, 20);
					}
				}
				if (graphPointer.y < neutralGraphPos - 30)
					graphPointer.y = neutralGraphPos - 30;
				if (graphPointer.y > neutralGraphPos + 30)
					graphPointer.y = neutralGraphPos + 30;
				
			case 1:
				theColor = FlxColor.GREEN;
				var a = FlxG.random.int(0, 130);
				
				if (graphBurstTimer > 0) {
					graphBurstTimer--;
				} else if (graphBurstTimer == 0) {
					graphBurstTimer = FlxG.random.int(80, 180);
					//graphBurstTimer = -1;
					if (graphMoveTimer <= 0) {
						graphMove = FlxG.random.float(-0.6, 0.2, [0]);
						graphMoveTimer = FlxG.random.int(10, 20);
					}
				}
			case 2:
				theColor = FlxColor.RED;
				var a = FlxG.random.int(0, 130);

				if (graphBurstTimer > 0) {
					graphBurstTimer--;
				} else if (graphBurstTimer == 0) {
					graphBurstTimer = FlxG.random.int(80, 180);
					//graphBurstTimer = -1;
					if (graphMoveTimer <= 0) {
						graphMove = FlxG.random.float(-0.2, 0.5, [0]);
						graphMoveTimer = FlxG.random.int(10, 20);
					}
				}
		}

		if (graphPointer.y < -1)
			graphPointer.y = -1;
		if (graphPointer.y > 225)
			graphPointer.y = 225;
			
		var thePoint = new FlxSprite(graphPointer.x, graphPointer.y).makeGraphic(4, 4, theColor);
		grpGraph.add(thePoint);

		graphPosition = thePoint.y;

		if (grpGraph.length > 0) {
			grpGraph.forEach(function(spr:FlxSprite)
			{
				spr.x -= 0.5;
				if (spr.x < 676.15)
					grpGraph.remove(spr);
			}); 
		}
		if (FlxG.keys.justPressed.I) {
			switchGraphMode(0);
		}
		if (FlxG.keys.justPressed.O) {
			switchGraphMode(1);
		}
		if (FlxG.keys.justPressed.P) {
			switchGraphMode(2);
		}		
	}

	function switchGraphMode(mode:Int) 
	{
		grpGraphIndicators.forEach(function(spr:FlxSprite)
		{
			spr.visible = false;
		}); 
	
		grpGraphIndicators.members[mode].visible = true;
		graphMode = mode;
		switch (mode) {
			case 0:
				neutralGraphPos = graphPointer.y;
		}
	}


	override function destroy() {
		super.destroy();

		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = 'stages/' + curStage + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}
		
		if(doPush) 
		{
			for (luaInstance in PlayState.instance.luaArray)
			{
				if(luaInstance.scriptName == luaFile)
				{
					PlayState.instance.luaArray.remove(luaInstance); 
				}
			}
		}
		#end
	}


	override function add(obj:FlxBasic){
		return super.add(obj);
		PlayState.instance.callOnLuas('onCreate', []);//Added this is For visible on STUFF
	}

	
    override function update(elapsed:Float)
    {
        super.update(elapsed);

		PlayState.instance.callOnLuas('onUpdate', [elapsed]);

        switch(curStage)
        {
			case 'philly' | 'phillyannie' | 'philly-neo':
                if (trainMoving)
                {
                    trainFrameTiming += elapsed;
    
                    if (trainFrameTiming >= 1 / 24)
                    {
                        updateTrainPos();
                        trainFrameTiming = 0;
                    }                        
                }
                phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;
            case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoParticles.forEach(function(spr:BGSprite) {
						if(spr.animation.curAnim.finished) {
							spr.kill();
							grpLimoParticles.remove(spr, true);
							spr.destroy();
						}
					});

					switch(limoKillingState) {
						case 1:
							limoMetalPole.x += 5000 * elapsed;
							limoLight.x = limoMetalPole.x - 180;
							limoCorpse.x = limoLight.x - 50;
							limoCorpseTwo.x = limoLight.x + 35;

							var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
							for (i in 0...dancers.length) {
								if(dancers[i].x < FlxG.width * 1.5 && limoLight.x > (370 * i) + 130) {
									switch(i) {
										case 0 | 3:
											if(i == 0) FlxG.sound.play(Paths.sound('dancerdeath'), 0.5);

											var diffStr:String = i == 3 ? ' 2 ' : ' ';
											var particle:BGSprite = new BGSprite('gore/noooooo','week4', dancers[i].x + 200, dancers[i].y, 0.4, 0.4, ['hench leg spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo','week4', dancers[i].x + 160, dancers[i].y + 200, 0.4, 0.4, ['hench arm spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo','week4', dancers[i].x, dancers[i].y + 50, 0.4, 0.4, ['hench head spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);

											var particle:BGSprite = new BGSprite('gore/stupidBlood','week4', dancers[i].x - 110, dancers[i].y + 20, 0.4, 0.4, ['blood'], false);
											particle.flipX = true;
											particle.angle = -57.5;
											grpLimoParticles.add(particle);
										case 1:
											limoCorpse.visible = true;
										case 2:
											limoCorpseTwo.visible = true;
									} //Note: Nobody cares about the fifth dancer because he is mostly hidden offscreen :(
									dancers[i].x += FlxG.width * 2;
								}
							}

							if(limoMetalPole.x > FlxG.width * 2) {
								resetLimoKill();
								limoSpeed = 800;
								limoKillingState = 2;
							}

						case 2:
							limoSpeed -= 4000 * elapsed;
							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x > FlxG.width * 1.5) {
								limoSpeed = 3000;
								limoKillingState = 3;
							}

						case 3:
							limoSpeed -= 2000 * elapsed;
							if(limoSpeed < 1000) limoSpeed = 1000;

							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x < -275) {
								limoKillingState = 4;
								limoSpeed = 800;
							}

						case 4:
							bgLimo.x = FlxMath.lerp(bgLimo.x, -150, CoolUtil.boundTo(elapsed * 9, 0, 1));
							if(Math.round(bgLimo.x) == -150) {
								bgLimo.x = -150;
								limoKillingState = 0;
							}
					}

					if(limoKillingState > 2) {
						var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
						for (i in 0...dancers.length) {
							dancers[i].x = (370 * i) + bgLimo.x + 280;
						}
						henchmenDies = false;
					}
				}
            case 'mall':
                if(heyTimer > 0) {
                    heyTimer -= elapsed;
                    if(heyTimer <= 0) {
                        bottomBoppers.animation.play('bop');
                        heyTimer = 0;
                    }
                }
            case 'schoolEvil':
                if(!ClientPrefs.lowQuality && bgGhouls.animation.curAnim.finished) {
					bgGhouls.visible = false;
				}
			case 'tank':
				tankAngle += FlxG.elapsed * tankSpeed;
				tankRolling.angle = tankAngle - 90 + 15;
				tankRolling.x = tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180));
				tankRolling.y = 1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180));
			case 'ITB':
				var lightsTimer:Array<Int> = [200, 700];
				for (i in 0...phillyCityLights.members.length) {
					if (lightsTimer[i] == 0) {
						lightsTimer[i] = -1;
						FlxTween.tween(phillyCityLights.members[i], {alpha: 1}, (Conductor.stepCrochet * 16 / 1000), {ease: FlxEase.quadOut, 
							onComplete: function(tween:FlxTween)
							{
								FlxTween.tween(phillyCityLights.members[i], {alpha: 0}, (Conductor.stepCrochet * 16 / 1000), {ease: FlxEase.quadIn, 
									onComplete: function(tween:FlxTween)
									{
										var daRando:FlxRandom = new FlxRandom();
										lightsTimer[i] = daRando.int(1000, 1500);
									}, 
								});
							}, 
						});
					} else
						lightsTimer[i]--;
				}
			case 'reactor' | 'reactor-m':
				orb.scale.x = FlxMath.lerp(0.7, orb.scale.x, 0.90);
				orb.scale.y = FlxMath.lerp(0.7, orb.scale.y, 0.90);
			    orb.alpha = FlxMath.lerp(0.96, orb.alpha, 0.90);
				ass2.alpha = FlxMath.lerp(1, ass2.alpha, 0.90);
			case 'zardymaze':
				if (zardyBackground.animation.finished){
					zardyBackground.animation.play('Maze');
				}
			case 'airplane':
				updateGraph();					
        }

		PlayState.instance.callOnLuas('onUpdatePost', [elapsed]);
    }

	public function stepHit(curStep:Int) {
		//do literally nothing dumbass
		PlayState.instance.setOnLuas('curStep', curStep);//DAWGG?????
		PlayState.instance.callOnLuas('onStepHit', []);
	}

    public function beatHit(curBeat:Int)
    {
        if(!ClientPrefs.lowQuality){
            for (bg in boppers){
				bg.dance();
			}

			if (curBeat % 2 == 0 && curStage == 'tank' && curStage == 'arcade4') {
				for(alt in boppersAlt){
					alt.animation.play('idle');
				}
			}
			else
			{
				for(alt in boppersAlt){
					alt.animation.play('idle');
				}
			}
           
        }

        switch(curStage)
        {
			case 'mall':
				if(heyTimer <= 0) bottomBoppers.animation.play('bop');
            case 'spooky':
                if(FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
                    lightningStrikeShit(curBeat);
			case "philly" | "phillyannie" | "prologue" | "neon" | "gfroom" | "philly-neo":
				if (curStage != "prologue" && curStage != "neon" && curStage != 'gfroom')
				{
					if (!trainMoving)
						trainCooldown += 1;

					if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
					{
						trainCooldown = FlxG.random.int(-4, 0);
						trainStart();
					}
				}


				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1, [curLight]);

					phillyCityLights.members[curLight].visible = true;
					phillyCityLights.members[curLight].alpha = 1;
				}
			case 'limo'|'limoholo':
				if (FlxG.random.bool(7) && henchmenDies && curStage != 'limoHolo')//YOU IDOIT THAT IN HOLO DON'T HAVE A DEATH DANCER
					killHenchmen();//7 chance can see henchmen die
				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case 'day':
				mini.animation.play('idle', true);
				if (stopWalkTimer == 0) {
					if (walkingRight)
						mordecai.flipX = false;
					else
						mordecai.flipX = true;
					if (walked)
						mordecai.animation.play('walk1');
					else
						mordecai.animation.play('walk2');
					if (walkingRight)
						mordecai.x += 10;
					else
						mordecai.x -= 10;
					walked = !walked;
					trace(mordecai.x);
					if (mordecai.x == 480 && walkingRight) { 
						stopWalkTimer = 10;
						walkingRight = false;
					} else if (mordecai.x == -80 && !walkingRight) { 
						stopWalkTimer = 8;
						walkingRight = true;
					}
				} else 
					stopWalkTimer--;
			case 'kbStreet':
				if(curBeat >= 80 && curBeat <= 208) 
				{
					if (curBeat % 16 == 0)
					{
						qt_gas01.animation.play('burst');
						qt_gas02.animation.play('burst');
					}
				}
			case 'reactor':
				if(curBeat % 4 == 0) 
				{
					amogus.animation.play('idle', true);
					dripster.animation.play('idle', true);
					yellow.animation.play('idle', true);
					brown.animation.play('idle', true);
					orb.scale.set(0.75, 0.75);
					ass2.alpha = 0.9;
					orb.alpha = 1;
				}
			case 'reactor-m':
				if(curBeat % 4 == 0) 
				{
					fortnite1.animation.play('idle', true);
					fortnite2.animation.play('idle', true);
					orb.scale.set(0.75, 0.75);
					ass2.alpha = 0.9;
					orb.alpha = 1;
				}
			case 'pillars':
				speaker.animation.play('bop');
			case 'subway':
				if(curBeat % 2 == 1)
				{
					gorls.animation.play('move', true);
					weebGorl.animation.play('move', true);
				}
			case 'subway-holy':
				if(curBeat % 2 == 1)
					holyHomura.animation.play('move', true);
			case 'lost':
			case 'Doki-club-room':
				if(curBeat % 2 == 0)
				{
					monika.animation.play('idle', true);
					sayori.animation.play('idle', true);
					natsuki.animation.play('idle', true);
					protag.animation.play('idle', true);
					yuri.animation.play('idle', true);
				}
        }

		PlayState.instance.setOnLuas('curBeat', curBeat);//DAWGG?????
		PlayState.instance.callOnLuas('onBeatHit', []);
    }

	public function setPositions(?player1Group:FlxSpriteGroup,?player2Group:FlxSpriteGroup,?gfVersionGroup:FlxSpriteGroup)
    {
		if(PlayState.instance.dad.curCharacter.startsWith('gf')) {//IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			PlayState.instance.dad.setPosition(PlayState.instance.GF_X, PlayState.instance.GF_Y);
			PlayState.instance.dad.scrollFactor.set(0.95, 0.95);
		}
		else
		{
			player2Group.setPosition(PlayState.instance.DAD_X, PlayState.instance.DAD_Y);
			PlayState.instance.dad.scrollFactor.set(1, 1);
		}
		player1Group.setPosition(PlayState.instance.BF_X, PlayState.instance.BF_Y);

		gfVersionGroup.setPosition(PlayState.instance.GF_X, PlayState.instance.GF_Y);
    }
}