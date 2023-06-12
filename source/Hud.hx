package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;

@:nullSafety
class Hud extends FlxGroup
{
  public final originX:Float;
  public final originY:Float;
  public final area:FlxSprite;

  private final _panel:FlxSprite;
  private final _tv:Portrait;
  private final _tvOverlay:FlxSprite;

  public function new(originX:Float, originY:Float)
  {
    super();

    this.originX = originX;
    this.originY = originY;

    area = new FlxSprite(originX, originY);
    _panel = new FlxSprite(originX + FlxG.width - 32, originY);
    _tv = new Portrait(originX + FlxG.width - 32, originY);
    _tvOverlay = new FlxSprite(originX + FlxG.width - 32, originY);

    area.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
    _panel.makeGraphic(32, FlxG.height, 0xFFE0F0E8);
    _tvOverlay.loadGraphic(AssetPaths.tv_overlay__png__png);

    add(area);
    add(_panel);
    add(_tv);
    add(_tvOverlay);
  }

  public function changePortrait(name:String)
  {
    _tv.changePortrait(name);
  }
}
