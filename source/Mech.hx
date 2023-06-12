package;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.path.FlxPath;

class Mech extends FlxSprite
{
  public final walkSpeed:Int;
  public final attackPower:Int;
  public final maxHealth:Int;
  public final maxStamina:Int;
  public final portrait:String;
  public var staminaLeft:Int;
  public var canStillAttack:Bool;

  public function new(x:Float, y:Float, walkSpeed:Int, attackPower:Int,
      maxHealth:Int, maxStamina:Int, portrait:String, ?health:Int)
  {
    super(x, y);

    this.walkSpeed = walkSpeed;
    this.attackPower = attackPower;
    this.maxHealth = maxHealth;
    this.health = (health != null) ? health : maxHealth;
    this.maxStamina = maxStamina;
    this.portrait = portrait;
    this.staminaLeft = maxStamina;
    this.canStillAttack = true;

    loadGraphic(AssetPaths.halberd_troop__png, true, 16, 16);

    animation.add('idleL', [0, 1], 2);
    animation.add('idleR', [0, 1], 2, true, true);

    animation.play('idleR');
  }

  private function findReachable_inner(paths:Array<FlxPath>,
      pathSoFar:FlxPath, checkBlocked:(Int, Int) -> Bool, stamina:Int, x:Int,
      y:Int)
  {
    final pt = FlxPoint.get(16 * x + 8, 16 * y + 8);
    if (checkBlocked(x, y))
    {
      pt.put();
      return;
    }

    final newPath = new FlxPath(pathSoFar.nodes);
    newPath.addPoint(pt);
    paths.push(newPath);

    if (stamina <= 0)
      return;

    findReachable_inner(paths, newPath, checkBlocked, stamina - 1, x - 1, y);
    findReachable_inner(paths, newPath, checkBlocked, stamina - 1, x, y - 1);
    findReachable_inner(paths, newPath, checkBlocked, stamina - 1, x + 1, y);
    findReachable_inner(paths, newPath, checkBlocked, stamina - 1, x, y + 1);
  }

  public function findReachable(stamina:Int,
      checkBlocked:(Int, Int) -> Bool):Array<FlxPath>
  {
    final paths = new Array<FlxPath>();
    final beginX = Math.round(x / 16);
    final beginY = Math.round(y / 16);
    final p = new FlxPath();
    findReachable_inner(paths, p, checkBlocked, stamina, beginX, beginY);
    paths.sort((a, b) -> a.nodes.length - b.nodes.length);
    return paths;
  }
}
