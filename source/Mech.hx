package;

import flixel.FlxSprite;

class Mech extends FlxSprite
{
  public final walkSpeed:Int;
  public final attackPower:Int;
  public final maxHealth:Int;
  public final staminaLeft:Int = 2;

  public function new(x:Float, y:Float, walkSpeed:Int, attackPower:Int,
      maxHealth:Int, ?health:Int)
  {
    super(x, y);

    this.walkSpeed = walkSpeed;
    this.attackPower = attackPower;
    this.maxHealth = maxHealth;
    this.health = (health != null) ? health : maxHealth;

    loadGraphic(AssetPaths.halberd_troop__png, true, 16, 16);

    animation.add('idleL', [0, 1], 2);
    animation.add('idleR', [0, 1], 2, true, true);

    animation.play('idleR');
  }
}
