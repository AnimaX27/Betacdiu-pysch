package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flash.display.BitmapData;
import editors.ChartingState;

using StringTools;

typedef EventNote = {
	strumTime:Float,
	event:String,
	value1:String,
	value2:String
}

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var ignoreNote:Bool = false;
	public var hitByOpponent:Bool = false;
	public var noteWasHit:Bool = false;
	public var prevNote:Note;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var noteType(default, set):String = null;


	public var eventName:String = '';
	public var eventLength:Int = 0;
	public var eventVal1:String = '';
	public var eventVal2:String = '';

	public var colorSwap:ColorSwap;
	public var inEditor:Bool = false;
	public var gfNote:Bool = false;
	private var earlyHitMult:Float = 0.5;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	// Lua shit
	public var noteSplashDisabled:Bool = false;
	public var noteSplashTexture:String = null;
	public var noteSplashHue:Float = 0;
	public var noteSplashSat:Float = 0;
	public var noteSplashBrt:Float = 0;

	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var offsetAngle:Float = 0;
	public var multAlpha:Float = 1;

	public var copyX:Bool = true;
	public var copyY:Bool = true;
	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;

	public var hitHealth:Float = 0.023;
	public var missHealth:Float = 0.0475;

	public var texture(default, set):String = null;
	public var style(default, set):String = null;

	public var noAnimation:Bool = false;
	public var hitCausesMiss:Bool = false;
	public var distance:Float = 2000;//plan on doing scroll directions soon -bb

	private function set_texture(value:String):String {
		if(texture != value) {
			reloadNote('', value);
		}
		texture = value;
		return value;
	}

	private function set_style(value:String):String {
		if(style != value){	
			reloadNote('', texture, '', value);
		}
		style = value;
		return value;
	}

	private function set_noteType(value:String):String {
		noteSplashTexture = PlayState.SONG.splashSkin;
		colorSwap.hue = ClientPrefs.arrowHSV[noteData % 4][0] / 360;
		colorSwap.saturation = ClientPrefs.arrowHSV[noteData % 4][1] / 100;
		colorSwap.brightness = ClientPrefs.arrowHSV[noteData % 4][2] / 100;

		if(noteData > -1 && noteType != value) {
			switch(value) {
				case 'Hurt Note':
					ignoreNote = mustPress;
					if (PlayState.SONG.player2 == 'whittyCrazy')
					{
						loadGraphic(Paths.image('notestuff/bombNote'), true, 222, 152);
						loadImageNote();
					}
					else
					{
						reloadNote('HURT');
					}
					
					noteSplashTexture = 'HURTnoteSplashes';
					colorSwap.hue = 0;
					colorSwap.saturation = 0;
					colorSwap.brightness = 0;
					if(isSustainNote) {
						missHealth = 0.1;
					} else {
						missHealth = 0.3;
					}
					hitCausesMiss = true;
				case 'Fire Note':
					ignoreNote = mustPress;
					if(style.contains('pixel'))
					{
						loadGraphic(Paths.image('notestuff/NOTE_fire-pixel'), true, 21, 31);
						loadFirePixelNoteAnims();
					}
					else
					{
						texture = 'NOTE_fire';
						frames = Paths.getSparrowAtlas('notestuff/NOTE_fire');
						loadFireNoteAnims();
					}
			        				
					noteSplashTexture = 'HURTnoteSplashes';
					colorSwap.hue = 0;
					colorSwap.saturation = 0;
					colorSwap.brightness = 0;
					missHealth = 0.3;
					hitCausesMiss = true;
				case 'Makrov Note':
					if(style.contains('pixel')) {
						loadGraphic(Paths.image('notestuff/arrows-pixels'));
						width = width / 4;
						height = height / 5;
						loadGraphic(Paths.image('notestuff/arrows-pixels'), true, Math.floor(width), Math.floor(height));
						loadMakrovPixel();
					} else {
						frames = Paths.getSparrowAtlas('notestuff/markov');
						animation.addByPrefix('greenScroll', 'markov green0');
						animation.addByPrefix('redScroll', 'markov red0');
						animation.addByPrefix('blueScroll', 'markov blue0');
						animation.addByPrefix('purpleScroll', 'markov purple0');
	
						animation.addByPrefix('purpleholdend', 'markov pruple end hold');
						animation.addByPrefix('greenholdend', 'markov green hold end');
						animation.addByPrefix('redholdend', 'markov red hold end');
						animation.addByPrefix('blueholdend', 'markov blue hold end');
	
						animation.addByPrefix('purplehold', 'markov purple hold piece');
						animation.addByPrefix('greenhold', 'markov green hold piece');
						animation.addByPrefix('redhold', 'markov red hold piece');
						animation.addByPrefix('bluehold', 'markov blue hold piece');

						setGraphicSize(Std.int(width * 0.7));
						updateHitbox();
					    antialiasing = ClientPrefs.globalAntialiasing;
					}
				case 'Static Note':
					canBeHit = mustPress;
					frames = Paths.getSparrowAtlas('notestuff/staticNotes');
					hitCausesMiss = true;			
					missHealth = 0.3;
					loadNoteAnims();
				case 'Warring Note':
					canBeHit = mustPress;
					loadGraphic(Paths.image('notestuff/warningNote'), true, 157, 154);
					hitCausesMiss = true;			
					loadImageNote();
				case 'Phantom Note':
					ignoreNote = mustPress;
					frames = Paths.getSparrowAtlas('notestuff/PhantomNote');
					loadNoteAnims();
					missHealth = 0.3;
					hitCausesMiss = true;
				case 'Rushia':
					ignoreNote = mustPress;
					frames = Paths.getSparrowAtlas('notestuff/NOTE_rushia');

					animation.addByPrefix('greenScroll', 'green alone0');
					animation.addByPrefix('redScroll', 'red alone0');
					animation.addByPrefix('blueScroll', 'blue alone0');
					animation.addByPrefix('purpleScroll', 'purple alone0');
	
					animation.addByPrefix('purpleholdend', 'purple tail');
					animation.addByPrefix('greenholdend', 'green tail');
					animation.addByPrefix('redholdend', 'red tail');
					animation.addByPrefix('blueholdend', 'blue tail');
	
					animation.addByPrefix('purplehold', 'purple hold');
					animation.addByPrefix('greenhold', 'green hold');
					animation.addByPrefix('redhold', 'red hold');
					animation.addByPrefix('bluehold', 'blue hold');

					missHealth = 0.3;
					hitCausesMiss = true;					
				case 'Heart Note':
					ignoreNote = mustPress;
					frames = Paths.getSparrowAtlas('notestuff/NOTE_hatto');

					animation.addByPrefix('greenScroll', 'green alone0');
					animation.addByPrefix('redScroll', 'red alone0');
					animation.addByPrefix('blueScroll', 'blue alone0');
					animation.addByPrefix('purpleScroll', 'purple alone0');
	
					animation.addByPrefix('purpleholdend', 'purple tail');
					animation.addByPrefix('greenholdend', 'green tail');
					animation.addByPrefix('redholdend', 'red tail');
					animation.addByPrefix('blueholdend', 'blue tail');
	
					animation.addByPrefix('purplehold', 'purple hold');
					animation.addByPrefix('greenhold', 'green hold');
					animation.addByPrefix('redhold', 'red hold');
					animation.addByPrefix('bluehold', 'blue hold');
	
					noteSplashTexture = 'HURTnoteSplashes';
					colorSwap.hue = 0;
					colorSwap.saturation = 0;
					colorSwap.brightness = 0;
					if(isSustainNote) {
						missHealth = 0.1;
					} else {
						missHealth = 0.3;
					}
					hitCausesMiss = true;
				case 'Scythe Note':
					loadGraphic(Paths.image('notestuff/scytheNotes'), true, 150, 150);

					animation.add('greenScroll', [2]);
					animation.add('redScroll', [1]);
					animation.add('blueScroll', [3]);
					animation.add('purpleScroll', [0]);
	
					setGraphicSize(Std.int(width * 0.7));
					updateHitbox();
					antialiasing = ClientPrefs.globalAntialiasing;									
			    case 'No Animation':
					noAnimation = true;
				case 'GF Sing':
					gfNote = true;
			}
			noteType = value;
		}
		noteSplashHue = colorSwap.hue;
		noteSplashSat = colorSwap.saturation;
		noteSplashBrt = colorSwap.brightness;
		return value;
	}



	

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inEditor:Bool = false, ?noteStyle:String = 'normal')
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		this.style = noteStyle;
		this.inEditor = inEditor;

		if(PlayState.isPixelStage) style = 'pixel';

		x += (ClientPrefs.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X) + 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;
		if(!inEditor) this.strumTime += ClientPrefs.noteOffset;

		this.noteData = noteData;

		if(noteData > -1) {
			texture = '';
			colorSwap = new ColorSwap();
			shader = colorSwap.shader;

			x += swagWidth * (noteData % 4);
			if(!isSustainNote) { //Doing this 'if' check to fix the warnings on Senpai songs
				var animToPlay:String = '';
				switch (noteData % 4)
				{
					case 0:
						animToPlay = 'purple';
					case 1:
						animToPlay = 'blue';
					case 2:
						animToPlay = 'green';
					case 3:
						animToPlay = 'red';
				}
				animation.play(animToPlay + 'Scroll');
			}
		}

		// trace(prevNote);

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;
			multAlpha = 0.6;
			if(ClientPrefs.downScroll) flipY = true;

			offsetX += width / 2;
			copyAngle = false;

			switch (noteData)
			{
				case 0:
					animation.play('purpleholdend');
				case 1:
					animation.play('blueholdend');
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
			}

			updateHitbox();

			offsetX -= width / 2;

			if (style.contains('pixel'))
				offsetX += 30;

			if (prevNote.isSustainNote)
			{
				switch (prevNote.noteData)
				{
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
				}

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05;
				if(PlayState.instance != null)
				{
					prevNote.scale.y *= PlayState.instance.songSpeed;
				}

				if(style.contains('pixel')) {
					prevNote.scale.y *= 1.19;
					prevNote.scale.y *= (6 / height); //Auto adjust note size
				}
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}

			if(style.contains('pixel')) {
				scale.y *= PlayState.daPixelZoom;
				updateHitbox();
			}
		} else if(!isSustainNote) {
			earlyHitMult = 1;
		}
		x += offsetX;
	}

	var lastNoteOffsetXForPixelAutoAdjusting:Float = 0;
	var lastNoteScaleToo:Float = 1;
	public var originalHeightForCalcs:Float = 6;
	public function reloadNote(?prefix:String = '', ?texture:String = '', ?suffix:String = '', ?noteStyle:String = '') {
		if(prefix == null) prefix = '';
		if(texture == null) texture = '';
		if(noteStyle == null) noteStyle = '';
		if(suffix == null) suffix = '';
		
		var skin:String = texture;
		if(texture.length < 1) {
			skin = PlayState.SONG.arrowSkin;
			if(skin == null || skin.length < 1) {
				skin = 'NOTE_assets';
			}
		}

		var idk:String = noteStyle;
		if(idk.length < 1) {
			idk = style;
			if(idk == null || idk.length < 1) {
				idk = 'normal';
			}
		}

		var animName:String = null;
		if(animation.curAnim != null) {
			animName = animation.curAnim.name;
		}

		var arraySkin:Array<String> = skin.split('/');
		arraySkin[arraySkin.length-1] = prefix + arraySkin[arraySkin.length-1] + suffix;

		var lastScaleY:Float = scale.y;
		var blahblah:String = arraySkin.join('/');
		switch(idk)
		{
			case 'pixel':
				if(isSustainNote) {
					loadGraphic(Paths.image('pixelUI/' + blahblah + 'ENDS'));
					width = width / 4;
					height = height / 2;
					originalHeightForCalcs = height;
					loadGraphic(Paths.image('pixelUI/' + blahblah + 'ENDS'), true, Math.floor(width), Math.floor(height));
				} else {
					loadGraphic(Paths.image('pixelUI/' + blahblah));
					width = width / 4;
					height = height / 5;
					loadGraphic(Paths.image('pixelUI/' + blahblah), true, Math.floor(width), Math.floor(height));
				}
				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				loadPixelNoteAnims();
				antialiasing = false;
	
				if(isSustainNote) {
					offsetX += lastNoteOffsetXForPixelAutoAdjusting;
					lastNoteOffsetXForPixelAutoAdjusting = (width - 7) * (PlayState.daPixelZoom / 2);
					offsetX -= lastNoteOffsetXForPixelAutoAdjusting;
				}
			case 'normal':
				frames = Paths.getSparrowAtlas(blahblah);
				loadNoteAnims();
				antialiasing = ClientPrefs.globalAntialiasing;
			case 'pixel-corrupted' | 'neon-pixel' | 'doki-pixel':
				var suf:String = "";
				switch (style)
				{
					case 'pixel-corrupted':
						suf = '-corrupted';
					case 'neon-pixel':
						suf = '-neon';
					case 'doki-pixel':
						suf = '-doki';
				}

				
				loadGraphic(Paths.image('notestuff/arrows-pixels'+suf), true, 17, 17);
						
				animation.add('greenScroll', [6]);
				animation.add('redScroll', [7]);
				animation.add('blueScroll', [5]);
				animation.add('purpleScroll', [4]);

				if (isSustainNote)
				{
					loadGraphic(Paths.image('notestuff/arrowEnds'+suf), true, 7, 6);

					animation.add('purpleholdend', [4]);
					animation.add('greenholdend', [6]);
					animation.add('redholdend', [7]);
					animation.add('blueholdend', [5]);

					animation.add('purplehold', [0]);
					animation.add('greenhold', [2]);
					animation.add('redhold', [3]);
					animation.add('bluehold', [1]);
				}
			case  'gray' | 'corrupted' | 'kapi' | 'cross' | '1930' | 'taki' | 'fever' | 'agoti' | 'void' | 'shootin' | 'holofunk' | 'trollge' | 'starecrown' | 'tabi' | 'sketchy' | 'darker' | 'doki' | 'nyan' | 'amor' | 'bluskys' | 'bf-b&b' | 'bob' | 'bosip' | 'ron' | 'gloopy' | 'party-crasher' | 'eteled' | 'austin'| 'stepmania' | 'littleman':
				frames = Paths.getSparrowAtlas('notestuff/'+style);

				animation.addByPrefix('greenScroll', 'green0');
				animation.addByPrefix('redScroll', 'red0');
				animation.addByPrefix('blueScroll', 'blue0');
				animation.addByPrefix('purpleScroll', 'purple0');

				animation.addByPrefix('purpleholdend', 'pruple end hold');
				animation.addByPrefix('greenholdend', 'green hold end');
				animation.addByPrefix('redholdend', 'red hold end');
				animation.addByPrefix('blueholdend', 'blue hold end');

				animation.addByPrefix('purplehold', 'purple hold piece');
				animation.addByPrefix('greenhold', 'green hold piece');
				animation.addByPrefix('redhold', 'red hold piece');
				animation.addByPrefix('bluehold', 'blue hold piece');

				setGraphicSize(Std.int(width * 0.7));
				antialiasing = ClientPrefs.globalAntialiasing;
			case 'guitar':
				frames = Paths.getSparrowAtlas('notestuff/GH_NOTES');

				animation.addByPrefix('greenScroll', 'upNote0');
				animation.addByPrefix('redScroll', 'rightNote0');
				animation.addByPrefix('blueScroll', 'downNote0');
				animation.addByPrefix('purpleScroll', 'leftNote0');

				animation.addByPrefix('purpleholdend', 'leftHoldEnd');
				animation.addByPrefix('greenholdend', 'upHoldEnd');
				animation.addByPrefix('redholdend', 'rightHoldEnd');
				animation.addByPrefix('blueholdend', 'downHoldEnd');

				animation.addByPrefix('purplehold', 'leftHold0');
				animation.addByPrefix('greenhold', 'upHold0');
				animation.addByPrefix('redhold', 'rightHold0');
				animation.addByPrefix('bluehold', 'downHold0');

				antialiasing = ClientPrefs.globalAntialiasing;
			case 'bw':
				frames = Paths.getSparrowAtlas('notestuff/NOTE_assets_BW');

				animation.addByPrefix('greenScroll', 'green0');
				animation.addByPrefix('redScroll', 'red0');
				animation.addByPrefix('blueScroll', 'blue0');
				animation.addByPrefix('purpleScroll', 'purple0');

				animation.addByPrefix('purpleholdend', 'pruple end hold');
				animation.addByPrefix('greenholdend', 'green hold end');
				animation.addByPrefix('redholdend', 'red hold end');
				animation.addByPrefix('blueholdend', 'blue hold end');

				animation.addByPrefix('purplehold', 'purple hold piece');
				animation.addByPrefix('greenhold', 'green hold piece');
				animation.addByPrefix('redhold', 'red hold piece');
				animation.addByPrefix('bluehold', 'blue hold piece');

				setGraphicSize(Std.int(width * 0.7));
				antialiasing = ClientPrefs.globalAntialiasing;
		}

		if(isSustainNote) {
			scale.y = lastScaleY;
		}
		updateHitbox();

		if(animName != null)
			animation.play(animName, true);

		if(inEditor) {
			setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
			updateHitbox();
		}
	}

	function loadFireNoteAnims() {
		animation.addByPrefix('greenScroll', 'green fire');
		animation.addByPrefix('redScroll', 'red fire');
		animation.addByPrefix('blueScroll', 'blue fire');
		animation.addByPrefix('purpleScroll', 'purple fire');

		setGraphicSize(Std.int(width * 0.7));
		antialiasing = ClientPrefs.globalAntialiasing;
		updateHitbox();
	}

	function loadMakrovPixel() {
		animation.add('greenScroll', [22]);
		animation.add('redScroll', [23]);
		animation.add('blueScroll', [21]);
		animation.add('purpleScroll', [20]);

		antialiasing = false;
		setGraphicSize(Std.int(width * PlayState.daPixelZoom));
		updateHitbox();
	}

	function loadFirePixelNoteAnims() {
		animation.add('greenScroll', [6, 7, 6, 8], 8);
		animation.add('redScroll', [9, 10, 9, 11], 8);
		animation.add('blueScroll', [3, 4, 3, 5], 8);
		animation.add('purpleScroll', [0, 1 ,0, 2], 8);
		
		setGraphicSize(Std.int(width * PlayState.daPixelZoom));
		antialiasing = false;
		updateHitbox();
	}

	function loadImageNote() { //if Some Note Are Made by Nothing :/
		animation.add('greenScroll', [0]);
		animation.add('redScroll', [0]);
		animation.add('blueScroll', [0]);
		animation.add('purpleScroll', [0]);

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
	}

	function loadNoteAnims() {
		animation.addByPrefix('greenScroll', 'green0');
		animation.addByPrefix('redScroll', 'red0');
		animation.addByPrefix('blueScroll', 'blue0');
		animation.addByPrefix('purpleScroll', 'purple0');

		if (isSustainNote)
		{
			animation.addByPrefix('purpleholdend', 'pruple end hold');
			animation.addByPrefix('greenholdend', 'green hold end');
			animation.addByPrefix('redholdend', 'red hold end');
			animation.addByPrefix('blueholdend', 'blue hold end');

			animation.addByPrefix('purplehold', 'purple hold piece');
			animation.addByPrefix('greenhold', 'green hold piece');
			animation.addByPrefix('redhold', 'red hold piece');
			animation.addByPrefix('bluehold', 'blue hold piece');
		}

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
	}

	function loadPixelNoteAnims() {
		if(isSustainNote) {
			animation.add('purpleholdend', [PURP_NOTE + 4]);
			animation.add('greenholdend', [GREEN_NOTE + 4]);
			animation.add('redholdend', [RED_NOTE + 4]);
			animation.add('blueholdend', [BLUE_NOTE + 4]);

			animation.add('purplehold', [PURP_NOTE]);
			animation.add('greenhold', [GREEN_NOTE]);
			animation.add('redhold', [RED_NOTE]);
			animation.add('bluehold', [BLUE_NOTE]);
		} else {
			animation.add('greenScroll', [GREEN_NOTE + 4]);
			animation.add('redScroll', [RED_NOTE + 4]);
			animation.add('blueScroll', [BLUE_NOTE + 4]);
			animation.add('purpleScroll', [PURP_NOTE + 4]);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			// ok river
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
			{
				if((isSustainNote && prevNote.wasGoodHit) || strumTime <= Conductor.songPosition)
					wasGoodHit = true;
			}
		}

		if (tooLate && !inEditor)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}