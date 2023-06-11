package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.path.FlxPath;
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
  public var attackSymbol:FlxSprite;
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
    attackSymbol = new FlxSprite();
    hudArea = new FlxSprite(-500, -500);

    final proj = new LDtkProject();
    level = proj.all_worlds.Default.all_levels.Level_3;
    level.l_Tiles.render(tiles);
    level.l_Touchup.render(tiles);

    tiles.pixelPerfectRender = true;

    underlayTilemap = new FlxTilemap();
    underlayTilemap.loadMapFromArray([for (i in 0...level.l_Tiles.cWid * level.l_Tiles.cHei) 0],
      level.l_Tiles.cWid, level.l_Tiles.cHei, AssetPaths.fog__png, 16, 16);

    overlayTilemap = new FlxTilemap();
    overlayTilemap.loadMapFromArray([for (i in 0...(level.l_Tiles.cWid * level.l_Tiles.cHei)) 0],
      level.l_Tiles.cWid, level.l_Tiles.cHei, AssetPaths.fog__png, 16, 16);

    panel.makeGraphic(32, FlxG.height, 0xFFE0F0E8);
    tvOverlay.loadGraphic(AssetPaths.tv_overlay__png__png);

    diamond.loadGraphic(AssetPaths.diamond__png, true, 16, 16);
    diamond.animation.add('default', [0, 1, 2, 3], 20);
    diamond.animation.play('default');
    diamond.kill();

    final mech = new Mech(48, 48, 3, 1, 10);
    friends.add(mech);
    portraitMap.set(mech, 'cat');

    enemies.add(new Mech(48 + 32, 32, 3, 1, 10));
    portraitMap.set(enemies.members[0], 'cat');

    attackSymbol.loadGraphic(AssetPaths.fog__png, true, 16, 16);
    attackSymbol.animation.frameIndex = 12;
    attackSymbol.kill();

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
    add(attackSymbol);
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

    FlxG.camera.minScrollX = 0;
    FlxG.camera.minScrollY = 0;
    FlxG.camera.maxScrollX = level.l_Tiles.pxWid;
    FlxG.camera.maxScrollY = level.l_Tiles.pxHei;
  }

  override public function destroy()
  {
    hudCam.destroy();
    super.destroy();
  }

  override public function update(elapsed:Float)
  {
    super.update(elapsed);

    if (FlxMath.pointInCoordinates(FlxG.mouse.x, FlxG.mouse.y,
      FlxG.camera.scroll.x, FlxG.camera.scroll.y,
      FlxG.camera.scroll.x
      + FlxG.width
      - 32
      - 1,
      FlxG.camera.scroll.y
      + FlxG.height
      - 1))
    {
      final ptX = Std.int(FlxG.mouse.x / 16);
      final ptY = Std.int(FlxG.mouse.y / 16);

      // Highlight grid space
      gridHighlight.x = ptX * 16 - 2;
      gridHighlight.y = ptY * 16 - 2;

      if (FlxG.mouse.justPressed)
      {
        trySelect(ptX, ptY);
      }
    }

    final camSpeed = 30;
    var camMoved = false;
    if (FlxG.keys.pressed.W)
    {
      camera.scroll.y -= camSpeed * elapsed;
      camMoved = true;
    }

    if (FlxG.keys.pressed.A)
    {
      camera.scroll.x -= camSpeed * elapsed;
      camMoved = true;
    }

    if (FlxG.keys.pressed.S)
    {
      camera.scroll.y += camSpeed * elapsed;
      camMoved = true;
    }

    if (FlxG.keys.pressed.D)
    {
      camera.scroll.x += camSpeed * elapsed;
      camMoved = true;
    }

    if (camMoved) {}
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

      final moves = findReachable(mech);
      focused = mech;
      fillOverlayTilemap(1);
      overlayTilemap.setTile(Math.round(mech.x / 16), Math.round(mech.y / 16),
        0);
      for (m in moves)
      {
        final endX = Math.round(m.tail().x / 16);
        final endY = Math.round(m.tail().y / 16);

        overlayTilemap.setTile(endX, endY, 0);
      }

      return;
    }

    if (focused != null)
    {
      tv.changePortrait('off');
      diamond.kill();
      fillOverlayTilemap(0);
      focused = null;
    }
  }

  private function fillOverlayTilemap(tile:Int)
  {
    for (y in 0...overlayTilemap.heightInTiles)
      for (x in 0...overlayTilemap.widthInTiles)
        overlayTilemap.setTile(x, y, tile);
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

  private function findReachable_inner(paths:Array<FlxPath>, stamina:Int,
      x:Int, y:Int):Bool
  {
    if (stamina == 0)
      return false;

    return true;
  }

  private function findReachable(mech:FlxSprite):Array<FlxPath>
  {
    return [
      new FlxPath([new FlxPoint(mech.x,
        mech.y), new FlxPoint(mech.x + 16, mech.y)]),
      new FlxPath([new FlxPoint(mech.x,
        mech.y), new FlxPoint(mech.x, mech.y + 16)])
    ];
  }

  public function move(sprite:FlxSprite, movements:Array<Compass>)
  {
    // move a piece
  }
}
