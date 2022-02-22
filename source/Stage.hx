package;
import editors.EditorPlayState;
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
//Some Class Stuff
import BGSprite;
import BackgroundGirls;
import BackgroundDancer;
import WiggleEffect;

using StringTools;
class Stage extends FlxTypedGroup<FlxBasic>
{
    public var curStage:String = DEFAULT_STAGE;
    public var defaultCamZoom:Float = 1.05;
    public static var DEFAULT_STAGE:String = 'stage'; //In case a stage is missing, it will use Stage on its place

    public var foreground:FlxTypedGroup<FlxBasic> = new FlxTypedGroup<FlxBasic>(); // stuff layered above every other layer
    public var overlay:FlxSpriteGroup = new FlxSpriteGroup(); // stuff that goes into the HUD camera. Layered before UI elements, still
    public var layers:Map<String,FlxTypedGroup<FlxBasic>> = [
        "boyfriend"=>new FlxTypedGroup<FlxBasic>(), // stuff that should be layered infront of all characters, but below the foreground
        "dad"=>new FlxTypedGroup<FlxBasic>(), // stuff that should be layered infront of the dad and gf but below boyfriend and foreground
        "gf"=>new FlxTypedGroup<FlxBasic>(), // stuff that should be layered infront of the gf but below the other characters and foreground
    ];


	public var gfVersion:String = 'gf';

    public var boppers:Array<Dynamic> = []; // should contain [sprite, bopAnimName, whichBeats]
    public var boppersAlt:Array<Dynamic> = []; // should contain [sprite, bopAnimName, whichBeats]
    public var dancers:Array<Dynamic> = []; // Calls the 'dance' function on everything in this array every beat

	public var songName:String = Paths.formatToSongPath(PlayState.SONG.song);

    //sometimes  public var is for event function
    //Week 2
    var halloweenBG:BGSprite;
	var halloweenWhite:BGSprite;

    //Week 3
	public var phillyCityLights:FlxTypedGroup<FlxSprite>;
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


    public function new(?stage:String = 'stage')
    {
        super();
        curStage = stage;
        switch(curStage)
        {
			case 'stage':
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
				bg.antialiasing = ClientPrefs.globalAntialiasing;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);

				var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				stageFront.antialiasing = ClientPrefs.globalAntialiasing;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;
				add(stageFront);

				if(!ClientPrefs.lowQuality)
				{
					var stageLight:FlxSprite = new FlxSprite(-125, -100).loadGraphic(Paths.image('stage_light'));
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.antialiasing = ClientPrefs.globalAntialiasing;
					stageLight.scrollFactor.set(0.9, 0.9);
					stageLight.active = false;
					add(stageLight);
					
					var stageLight:FlxSprite = new FlxSprite(1225, -100).loadGraphic(Paths.image('stage_light'));
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.antialiasing = ClientPrefs.globalAntialiasing;
					stageLight.scrollFactor.set(0.9, 0.9);
					stageLight.active = false;
					stageLight.flipX = true;
					add(stageLight);

					var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
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
			case 'philly':
				if(!ClientPrefs.lowQuality) {
					var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky', 'week3'));
					bg.scrollFactor.set(0.1, 0.1);
					add(bg);
				}

				var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city', 'week3'));
				city.scrollFactor.set(0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				add(city);

				phillyCityLights = new FlxTypedGroup<FlxSprite>();
				add(phillyCityLights);

				for (i in 0...5)
				{
					var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i, 'week3'));
					light.scrollFactor.set(0.3, 0.3);
					light.visible = false;
					light.setGraphicSize(Std.int(light.width * 0.85));
					light.updateHitbox();
					light.antialiasing = ClientPrefs.globalAntialiasing;
					phillyCityLights.add(light);						
				}

				if(!ClientPrefs.lowQuality) {
					var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain','week3'));
				    add(streetBehind);
				}
				

				phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train','week3'));
				add(phillyTrain);

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes','week3'));
				CoolUtil.precacheSound('train_passes');
				FlxG.sound.list.add(trainSound);

				var street:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/street','week3'));
				add(street);
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
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
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
			case 'mall':
				gfVersion = 'gf-christmas';
				var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls','week5'));
				bg.antialiasing = ClientPrefs.globalAntialiasing;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				if(!ClientPrefs.lowQuality)
				{
					upperBoppers = new FlxSprite(-240, -90);
					upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop','week5');
					upperBoppers.animation.addByPrefix('idle', "Upper Crowd Bob", 24, false);
					upperBoppers.antialiasing = ClientPrefs.globalAntialiasing;
					upperBoppers.scrollFactor.set(0.33, 0.33);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					boppersAlt.push(upperBoppers);
					add(upperBoppers);
	
					var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator','week5'));
					bgEscalator.antialiasing = ClientPrefs.globalAntialiasing;
					bgEscalator.scrollFactor.set(0.3, 0.3);
					bgEscalator.active = false;
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);
				}


				var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree','week5'));
				tree.antialiasing = ClientPrefs.globalAntialiasing;
				tree.scrollFactor.set(0.40, 0.40);
				add(tree);

				bottomBoppers = new FlxSprite(-300, 140);
				bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop','week5');
				bottomBoppers.animation.addByPrefix('idle', 'Bottom Level Boppers', 24, false);
				bottomBoppers.animation.addByPrefix('hey', 'Bottom Level Boppers HEY', 24, false);
				bottomBoppers.antialiasing = ClientPrefs.globalAntialiasing;
				bottomBoppers.scrollFactor.set(0.9, 0.9);
				bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
				bottomBoppers.updateHitbox();
				boppersAlt.push(bottomBoppers);
				add(bottomBoppers);


				var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow','week5'));
				fgSnow.active = false;
				fgSnow.antialiasing = ClientPrefs.globalAntialiasing;
				add(fgSnow);

				santa = new FlxSprite(-840, 150);
				santa.frames = Paths.getSparrowAtlas('christmas/santa','week5');
				santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
				santa.antialiasing = ClientPrefs.globalAntialiasing;
				boppersAlt.push(santa);
				add(santa);
			case 'mallEvil':
				var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG','week5'));
				bg.antialiasing = ClientPrefs.globalAntialiasing;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree','week5'));
				evilTree.antialiasing = ClientPrefs.globalAntialiasing;
				evilTree.scrollFactor.set(0.2, 0.2);
				add(evilTree);

				var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow",'week5'));
				evilSnow.antialiasing = ClientPrefs.globalAntialiasing;
				add(evilSnow);
			case 'school':
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

					if (songName == 'roses'){
						bgGirls.getScared();
					}
				}
			case 'schoolEvil':
				gfVersion = 'gf-pixel';
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				var posX = 400;
				var posY = 200;
				var bg:FlxSprite = new FlxSprite(posX, posY);
				if(!ClientPrefs.lowQuality) {
					bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool','week6');
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
		if(PlayState.instance.gf.animOffsets.exists('scared')) {
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
			PlayState.instance.gf.playAnim('hairBlow');
			PlayState.instance.gf.specialAnim = true;
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
		PlayState.instance.gf.danced = false; //Sets head to the correct position once the animation ends
		PlayState.instance.gf.playAnim('hairFall');
		PlayState.instance.gf.specialAnim = true;
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

	
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        switch(curStage)
        {
            case 'philly':
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
        }
    }

    public function beatHit(curBeat:Int)
    {
        if(!ClientPrefs.lowQuality){
            for (bg in boppers){
				bg.dance();
			}

			if (curBeat % 2 == 0 && curStage == 'tank') {
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
            case 'philly':
                if (!trainMoving)
					trainCooldown += 1;

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

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
            case 'limo':
				if (FlxG.random.bool(7) && henchmenDies)
					killHenchmen();//7 chance can see henchmen die
                if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
        }
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
		}
		player1Group.setPosition(PlayState.instance.BF_X, PlayState.instance.BF_Y);

		gfVersionGroup.setPosition(PlayState.instance.GF_X, PlayState.instance.GF_Y);
    }
}