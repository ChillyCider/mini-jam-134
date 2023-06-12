package;

import flixel.ui.FlxBar;

class TinyHealthBar extends FlxBar
{
  public function new()
  {
    super(0, 0, LEFT_TO_RIGHT, 16, 4, null, '', 0, 10, false);
    createFilledBar(0xFF183030, 0xFFA8C0B0, false, 0xFF183030);
    kill();
  }
}
