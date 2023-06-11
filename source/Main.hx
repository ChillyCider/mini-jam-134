package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.system.scaleModes.PixelPerfectScaleMode;
import openfl.display.Sprite;

class Main extends Sprite
{
  public function new()
  {
    super();
    addChild(new FlxGame(0, 0, PlayState, 60, 60, true));

    FlxG.stage.quality = LOW;
    FlxG.scaleMode = new PixelPerfectScaleMode();
    FlxG.camera.pixelPerfectRender = true;
  }
}
