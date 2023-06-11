package;

import flixel.FlxSprite;

interface Board
{
  public function move(sprite:FlxSprite, movements:Array<Compass>):Void;
}
