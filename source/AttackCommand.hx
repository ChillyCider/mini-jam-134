package;

class AttackCommand implements Command
{
  public final fromX:Int;
  public final fromY:Int;
  public final toX:Int;
  public final toY:Int;

  public function new(fromX:Int, fromY:Int, toX:Int, toY:Int)
  {
    this.fromX = fromX;
    this.fromY = fromY;
    this.toX = toX;
    this.toY = toY;
  }

  public function execute(board:Board):Void {}

  public function undo(board:Board):Void {}
}
