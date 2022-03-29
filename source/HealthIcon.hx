package;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import openfl.display.Preloader.DefaultPreloader;
import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	public var isPlayer:Bool = false;
	public var is3icon:Bool = false;
	public var is5icon:Bool = false;
	private var char:String = '';
	
	public var wasAdded:Bool = false;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}

	public function swapOldIcon() {
		if(isOldIcon = !isOldIcon) changeIcon('bf-old');
		else changeIcon('bf');
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function changeIcon(char:String) {
		if(this.char != char) {
			switch(char)
			{
				default:
                    if(Paths.fileExists('images/icons/icon-' + char +'.png', IMAGE))
					{
						var file:Dynamic = Paths.image('icons/icon-' + char);
						loadGraphic(file); //Load stupidly first for getting the file size
						loadGraphic(file, true, Math.floor(width / 2), Math.floor(height)); //Then load it fr
						iconOffsets[0] = (width - 150) / 2;
						iconOffsets[1] = (width - 150) / 2;
						updateHitbox();
						animation.add(char, [0, 1], 0, false, isPlayer);
					}

					if(Paths.fileExists('images/icons/' + char + '-3.png', IMAGE))
					{
						var file:Dynamic = Paths.image('icons/' + char + '-3');
						loadGraphic(file); //Load stupidly first for getting the file size
						loadGraphic(file, true, Math.floor(width / 2), Math.floor(height)); //Then load it fr
						iconOffsets[0] = (width - 150) / 3;
						iconOffsets[1] = (width - 150) / 3;
						iconOffsets[2] = (width - 150) / 3;
						updateHitbox();
						is3icon = true;
						animation.add(char, [0, 1, 2], 0, false, isPlayer);
					}
					
					if(Paths.fileExists('images/icons/' + char + '-5.png', IMAGE))
					{
						var file:Dynamic = Paths.image('icons/' + char + '-5');
						loadGraphic(file); //Load stupidly first for getting the file size
						loadGraphic(file, true, Math.floor(width / 5), Math.floor(height)); //Then load it fr
						iconOffsets[0] = (width - 150) / 5;
						iconOffsets[1] = (width - 150) / 5;
						iconOffsets[2] = (width - 150) / 5;
						iconOffsets[3] = (width - 150) / 5;
						iconOffsets[4] = (width - 150) / 5;
						updateHitbox();
						is5icon = true;
						animation.add(char, [1, 4, 0, 2, 3], 0, false, isPlayer);
					}

					if(!Paths.fileExists('images/icons/icon-' + char +'.png', IMAGE))
					{
						var file:Dynamic = Paths.image('icons/icon-face');
						loadGraphic(file); //Load stupidly first for getting the file size
						loadGraphic(file, true, Math.floor(width / 2), Math.floor(height)); //Then load it fr
						iconOffsets[0] = (width - 150) / 2;
						iconOffsets[1] = (width - 150) / 2;
						updateHitbox();
						animation.add(char, [0, 1], 0, false, isPlayer);
					}
				case 'hypno2' | 'hypno-two':
					frames = Paths.getSparrowAtlas('icons/Hypno2 Health Icon');
					animation.addByPrefix(char, 'Hypno2 Icon', 24, true);
					updateHitbox();
			}


			
			animation.play(char);
			this.char = char;

			antialiasing = ClientPrefs.globalAntialiasing;
			if(char.endsWith('-pixel')) {
				antialiasing = false;
			}
		}
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
		offset.x = iconOffsets[2];
		offset.y = iconOffsets[3];
		offset.x = iconOffsets[4];
	}

	public function getCharacter():String {
		return char;
	}
}
