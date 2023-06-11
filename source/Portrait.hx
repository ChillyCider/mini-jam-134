package;

import flixel.FlxSprite;
import flixel.util.FlxTimer;

class Portrait extends FlxSprite
{
  private final _timer:FlxTimer;
  private var _nextPortrait:String = 'off';

  public function new(x:Float, y:Float)
  {
    super(x, y);

    _timer = new FlxTimer();
    _timer.loops = 1;
    _timer.onComplete = _timerComplete;

    loadGraphic(AssetPaths.noise__png, true, 32, 32);

    animation.add('static', [0, 1, 2, 3], 30);
    animation.add('cat', [4]);
    animation.add('off', [5]);

    animation.play('off');
  }

  override public function destroy()
  {
    _timer.destroy();
    super.destroy();
  }

  private function _timerComplete(timer:FlxTimer)
  {
    animation.play(_nextPortrait);
  }

  public function changePortrait(name:String)
  {
    _nextPortrait = name;
    animation.play('static');
    _timer.reset(0.4);
  }
}
