package;

interface Command
{
  public function execute(board:Board):Void;
  public function undo(board:Board):Void;
}
