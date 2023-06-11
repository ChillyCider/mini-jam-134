package;

import flixel.FlxSprite;

class MoveCommand implements Command
{
  public final sprite:FlxSprite;
  public final movements:Array<Compass>;

  public function new(sprite:FlxSprite, movements:Array<Compass>)
  {
    this.sprite = sprite;
    this.movements = movements;
  }

  public function execute(board:Board):Void
  {
    board.move(sprite, movements);
  }

  public function undo(board:Board):Void
  {
    final reversed = movements.copy();
    reversed.reverse();
    board.move(sprite, reversed);
  }
}
