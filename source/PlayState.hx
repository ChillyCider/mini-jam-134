package;

class PlayState extends LevelState implements Board
{
  override public function create()
  {
    final proj = new LDtkProject();
    level = proj.all_worlds.Default.all_levels.Level_0;
    super.create();
  }
}
