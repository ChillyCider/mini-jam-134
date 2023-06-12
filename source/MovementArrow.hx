package;

import flixel.FlxSprite;

class MovementArrow extends FlxSprite
{
  public function new()
  {
    super(0, 0);
    loadGraphic(AssetPaths.fog__png, true, 16, 16);
    kill();
  }
}
