package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.NumTween;

class Letterbox extends FlxSpriteGroup
{
  private final _top:FlxSprite;
  private final _bottom:FlxSprite;
  private final _tween:NumTween;

  public function new(x:Float, y:Float)
  {
    super(x, y);

    pixelPerfectPosition = true;

    _top = new FlxSprite(0, -32);
    _bottom = new FlxSprite(0, FlxG.height);
    _tween = FlxTween.num(0, 0, 0, {
      ease: FlxEase.bounceOut,
      type: PERSIST
    }, _tweenUpdate);

    _top.makeGraphic(FlxG.width, 32, 0xFF183030);
    _top.pixelPerfectPosition = true;
    _bottom.loadGraphicFromSprite(_top);
    _bottom.pixelPerfectPosition = true;

    add(_top);
    add(_bottom);
  }

  public function show(duration:Float)
  {
    _tween.tween(0, 1, duration, _tweenUpdate);
  }

  public function hide(duration:Float)
  {
    _tween.tween(1, 0, duration, _tweenUpdate);
  }

  private function _tweenUpdate(v:Float)
  {
    _top.y = -32 + 32 * v;
    _bottom.y = FlxG.height - 32 * v;
  }
}
