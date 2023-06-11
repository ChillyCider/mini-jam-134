package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;

enum abstract Turn(Int)
{
  var PlayerTurn;
  var EnemyTurn;
}

class PlayState extends FlxState implements Board
{
  public var level:LDtkProject.LDtkProject_Level;
  public var tiles:FlxSpriteGroup;
  public var underlayTilemap:FlxTilemap;
  public var friends:FlxTypedSpriteGroup<Mech>;
  public var enemies:FlxTypedSpriteGroup<Mech>;
  public var healthBars:FlxTypedSpriteGroup<FlxBar>;
  public var diamond:FlxSprite;
  public var focused:Null<FlxSprite>;
  public var portraitMap:Map<FlxSprite, String>;
  public var overlayTilemap:FlxTilemap;
  public var gridHighlight:FlxSprite;
  public var tv:Portrait;
  public var tvOverlay:FlxSprite;
  public var panel:FlxSprite;
  public var letterbox:Letterbox;
  public var hudCam:FlxCamera;
  public var hudArea:FlxSprite;

  override public function create()
  {
    super.create();

    bgColor = 0xFF183030;

    tiles = new FlxSpriteGroup();
    friends = new FlxTypedSpriteGroup<Mech>();
    enemies = new FlxTypedSpriteGroup<Mech>();
    healthBars = new FlxTypedSpriteGroup<FlxBar>();
    diamond = new FlxSprite();
    portraitMap = new Map<FlxSprite, String>();
    gridHighlight = new FlxSprite();
    panel = new FlxSprite(-500 + FlxG.width - 32, -500);
    tv = new Portrait(-500 + FlxG.width - 32, -500);
    tvOverlay = new FlxSprite(-500 + FlxG.width - 32, -500);
    letterbox = new Letterbox(-500, -500);
    hudArea = new FlxSprite(-500, -500);

    final proj = new LDtkProject();
    level = proj.all_worlds.Default.all_levels.Level_3;
    level.l_Tiles.render(tiles);
    level.l_Touchup.render(tiles);

    underlayTilemap = new FlxTilemap();
    underlayTilemap.loadMapFromArray([for (i in 0...level.l_Tiles.cWid * level.l_Tiles.cHei) 0],
      Std.int((FlxG.width - 32) / 16), Std.int(FlxG.height / 16),
      AssetPaths.fog__png, 16, 16);

    overlayTilemap = new FlxTilemap();
    overlayTilemap.loadMapFromArray([for (i in 0...(level.l_Tiles.cWid * level.l_Tiles.cHei)) 0],
      Std.int((FlxG.width - 32) / 16), Std.int(FlxG.height / 16),
      AssetPaths.fog__png, 16, 16);
    overlayTilemap.kill();

    panel.makeGraphic(32, FlxG.height, 0xFFE0F0E8);
    tvOverlay.loadGraphic(AssetPaths.tv_overlay__png__png);

    diamond.loadGraphic(AssetPaths.diamond__png, true, 16, 16);
    diamond.animation.add('default', [0, 1, 2, 3], 20);
    diamond.animation.play('default');
    diamond.kill();

    final mech = new Mech(48, 48, 3, 1, 10);
    friends.add(mech);
    portraitMap.set(mech, 'cat');

    for (i in 0...9)
    {
      final bar = new FlxBar(0, 10 * i, LEFT_TO_RIGHT, 16, 2);
      bar.createFilledBar(0xFF183030, 0xFFA8C0B0, false, 0xFF183030);
      bar.setRange(0, 10);
      bar.value = 5;
      bar.kill();
      healthBars.add(bar);
    }

    gridHighlight.loadGraphic(AssetPaths.grid_focus__png, true, 20, 20);
    gridHighlight.animation.add('default', [0, 1], 4);
    gridHighlight.animation.play('default');

    add(tiles);
    add(underlayTilemap);
    add(diamond);
    add(friends);
    add(enemies);
    add(healthBars);
    add(overlayTilemap);
    overlayTilemap.setTile(1, 1, 1);
    add(hudArea);
    add(panel);
    add(tv);
    add(tvOverlay);
    add(gridHighlight);
    add(letterbox);

    hudArea.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
    hudCam = new FlxCamera();
    FlxG.cameras.add(hudCam);
    hudCam.bgColor = FlxColor.TRANSPARENT;
    hudCam.follow(hudArea, NO_DEAD_ZONE);
  }

  override public function destroy()
  {
    hudCam.destroy();
    super.destroy();
  }

  override public function update(elapsed:Float)
  {
    super.update(elapsed);

    if (FlxMath.pointInCoordinates(FlxG.mouse.x, FlxG.mouse.y, 0, 0,
      FlxG.width - 32 - 1, FlxG.height - 1))
    {
      final ptX = Std.int((FlxG.mouse.x - FlxG.camera.x) / 16);
      final ptY = Std.int((FlxG.mouse.y - FlxG.camera.y) / 16);

      // Highlight grid space
      gridHighlight.x = Std.int(FlxG.mouse.x / 16) * 16 - 2;
      gridHighlight.y = Std.int(FlxG.mouse.y / 16) * 16 - 2;

      if (FlxG.mouse.justPressed)
      {
        trySelect(ptX, ptY);
      }
    }
  }

  private function trySelect(x:Int, y:Int)
  {
    final mech = mechAt(x, y);
    if (focused != mech && mech != null)
    {
      diamond.revive();
      diamond.x = mech.x;
      diamond.y = mech.y;

      final portrait = portraitMap.get(cast mech);
      if (portrait != null)
      {
        tv.changePortrait(portrait);
      }

      focused = mech;
      clearOverlayTilemap();
      calcMoveFog();
      overlayTilemap.revive();

      return;
    }

    if (focused != null)
    {
      tv.changePortrait('off');
      diamond.kill();
      clearOverlayTilemap();
      focused = null;
    }
  }

  private function clearOverlayTilemap()
  {
    for (y in 0...overlayTilemap.heightInTiles)
      for (x in 0...overlayTilemap.widthInTiles)
        overlayTilemap.setTile(x, y, 0);
  }

  private function calcMoveFog()
  {
    for (col in 0...overlayTilemap.widthInTiles)
      for (row in 0...overlayTilemap.heightInTiles)
      {
        overlayTilemap.setTile(col, row,
          (col != 3) ? 1 : overlayTilemap.getTile(col, row));
      }
  }

  private function mechAt(x:Int, y:Int):Null<Mech>
  {
    final expectedX:Float = x * 16;
    final expectedY:Float = y * 16;

    for (friend in friends)
      if (FlxMath.equal(friend.x, expectedX)
        && FlxMath.equal(friend.y, expectedY))
      {
        return friend;
      }

    for (enemy in enemies)
      if (FlxMath.equal(enemy.x, expectedX)
        && FlxMath.equal(enemy.y, expectedY))
      {
        return enemy;
      }

    return null;
  }

  public function listCommands(mech:FlxSprite):Array<Array<Command>>
  {
    return [];
  }

  public function move(sprite:FlxSprite, movements:Array<Compass>)
  {
    // move a piece
  }
}
