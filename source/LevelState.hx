package;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.path.FlxPath;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;

enum abstract ArrowSprite(Int) from Int to Int
{
  var ARW_HORIZ = 2;
  var ARW_VERT = 3;
  var ARW_BEND_NE = 4;
  var ARW_BEND_SE = 5;
  var ARW_BEND_SW = 6;
  var ARW_BEND_NW = 7;
  var ARW_STOP_N = 8;
  var ARW_STOP_E = 9;
  var ARW_STOP_S = 10;
  var ARW_STOP_W = 11;
}

class LevelState extends FlxState implements Board
{
  public final ANGLE_ARROW_MAPPING:Map<Int, Array<Int>> = [
    90 => [2, 10, -1, ARW_BEND_SW, ARW_VERT, ARW_BEND_SE],
    180 => [3, 11, ARW_BEND_SW, -1, ARW_BEND_NW, ARW_HORIZ],
    -90 => [4, 8, ARW_VERT, ARW_BEND_NW, -1, ARW_BEND_NE],
    0 => [5, 9, ARW_BEND_SE, ARW_HORIZ, ARW_BEND_NE, -1]
  ];
  public var level:LDtkProject.LDtkProject_Level;
  public var tiles:FlxSpriteGroup;
  public var friends:FlxTypedSpriteGroup<Mech>;
  public var enemies:FlxTypedSpriteGroup<Mech>;
  public var healthBars:FlxTypedSpriteGroup<FlxBar>;
  public var hud:Hud;
  public var diamond:FlxSprite;
  public var arrowSprites:FlxTypedGroup<MovementArrow>;
  public var focused:Null<FlxSprite>;
  public var overlayTilemap:FlxTilemap;
  public var gridHighlight:FlxSprite;
  public var letterbox:Letterbox;
  public var attackSymbol:FlxSprite;
  public var hudCam:FlxCamera;
  public var unitMoves:Array<FlxPath>;
  public var waiting:Bool;
  public var ghost:FlxSprite;
  public var isPlayerTurn:Bool;

  override public function create()
  {
    super.create();

    bgColor = 0xFF183030;

    tiles = new FlxSpriteGroup();
    friends = new FlxTypedSpriteGroup<Mech>();
    enemies = new FlxTypedSpriteGroup<Mech>();
    healthBars = new FlxTypedSpriteGroup<FlxBar>();
    diamond = new FlxSprite();
    arrowSprites = new FlxTypedGroup<MovementArrow>();
    gridHighlight = new FlxSprite();
    letterbox = new Letterbox(-500, -500);
    attackSymbol = new FlxSprite();
    ghost = new FlxSprite();
    unitMoves = [];
    waiting = false;
    level.l_Tiles.render(tiles);
    level.l_Touchup.render(tiles);

    isPlayerTurn = true;

    tiles.pixelPerfectRender = true;

    overlayTilemap = new FlxTilemap();
    overlayTilemap.loadMapFromArray([for (i in 0...(level.l_Tiles.cWid * level.l_Tiles.cHei)) 0],
      level.l_Tiles.cWid, level.l_Tiles.cHei, AssetPaths.fog__png, 16, 16);

    hud = new Hud(-500, -500);

    diamond.loadGraphic(AssetPaths.diamond__png, true, 16, 16);
    diamond.animation.add('default', [0, 1, 2, 3], 20);
    diamond.animation.play('default');
    diamond.kill();

    friends.add(new Mech(48, 48, 3, 1, 10, 3, 'cat'));
    enemies.add(new Mech(48 + 16, 48, 3, 1, 10, 3, 'cat'));

    attackSymbol.loadGraphic(AssetPaths.fog__png, true, 16, 16);
    attackSymbol.animation.frameIndex = 12;
    attackSymbol.reset(-60, -60);

    ghost.kill();

    for (i in 0...9)
    {
      final bar = new TinyHealthBar();
      bar.value = 5;
      bar.setRange(0, 10);
      healthBars.add(bar);
    }

    for (i in 0...12)
    {
      arrowSprites.add(new MovementArrow());
    }

    gridHighlight.loadGraphic(AssetPaths.grid_focus__png, true, 20, 20);
    gridHighlight.animation.add('default', [0, 1], 4);
    gridHighlight.animation.play('default');
    unitMoves = [];

    add(tiles);
    add(diamond);
    add(friends);
    add(enemies);
    add(arrowSprites);
    add(healthBars);
    add(overlayTilemap);
    add(attackSymbol);
    add(ghost);
    add(hud);
    add(gridHighlight);
    add(letterbox);

    hudCam = new FlxCamera();
    FlxG.cameras.add(hudCam);
    hudCam.bgColor = FlxColor.TRANSPARENT;
    hudCam.follow(hud.area, NO_DEAD_ZONE);

    FlxG.camera.setScrollBounds(0, level.l_Tiles.pxWid, 0, level.l_Tiles.pxHei);
  }

  override public function destroy()
  {
    hudCam.destroy();
    super.destroy();
  }

  override public function update(elapsed:Float)
  {
    super.update(elapsed);

    var camSpeed = 30, camXMove = 0.0, camYMove = 0.0;
    if (FlxG.keys.pressed.W)
      camYMove -= camSpeed * elapsed;
    if (FlxG.keys.pressed.A)
      camXMove -= camSpeed * elapsed;
    if (FlxG.keys.pressed.S)
      camYMove += camSpeed * elapsed;
    if (FlxG.keys.pressed.D)
      camXMove += camSpeed * elapsed;
    camera.scroll.x += camXMove;
    camera.scroll.y += camYMove;

    if (waiting)
      return;

    if (isPlayerTurn)
    {
      final scrX = FlxG.camera.scroll.x;
      final scrY = FlxG.camera.scroll.y;

      if (FlxMath.pointInCoordinates(FlxG.mouse.x, FlxG.mouse.y, scrX, scrY,
        scrX + FlxG.width - 32 - 1, scrY + FlxG.height - 1))
      {
        final ptX = Std.int(FlxG.mouse.x / 16);
        final ptY = Std.int(FlxG.mouse.y / 16);

        // Highlight grid space
        gridHighlight.x = ptX * 16 - 2;
        gridHighlight.y = ptY * 16 - 2;

        var highlightedPath:Null<FlxPath> = null;
        var highlightedAttack:Null<Mech> = null;

        if (focused != null && unitMoves.length > 0)
        {
          clearArrowSprites();

          attackSymbol.x = -60;
          attackSymbol.y = -60;

          // Are we attacking somebody that can be attacked?
          for (e in enemies.members)
          {
            if (FlxG.mouse.overlaps(e))
            {
              highlightedPath = findAttack(unitMoves, e);
              if (highlightedPath != null)
              {
                highlightedAttack = e;
                attackSymbol.x = e.x;
                attackSymbol.y = e.y;
              }
              break;
            }
          }

          // Are we just moving?
          if (highlightedPath == null)
          {
            for (m in unitMoves)
            {
              if (FlxMath.equal(m.tail().x, 16 * ptX + 8)
                && FlxMath.equal(m.tail().y, 16 * ptY + 8))
              {
                highlightedPath = m;
                break;
              }
            }
          }

          if (highlightedPath != null)
          {
            buildArrowSprites(highlightedPath);
          }
        }

        if (FlxG.mouse.justPressed)
        {
          if (highlightedPath != null)
          {
            final actor:Mech = cast focused;
            unitMoves.remove(highlightedPath);
            clearUnitMoves();
            actor.path = highlightedPath;
            actor.staminaLeft -= highlightedPath.nodes.length - 1;
            highlightedPath.onComplete = (path) ->
            {
              waiting = false;
              if (highlightedAttack != null)
              {
                highlightedAttack.health -= actor.attackPower;
                actor.staminaLeft += 3;
              }
            };
            highlightedPath.start(null, 100);
            waiting = true;
            deselect();
          }
          else
          {
            trySelect(ptX, ptY);
          }
        }
      }
    }
    else
    {
      // Not player's turn
    }
  }

  private function deselect()
  {
    clearArrowSprites();

    if (focused != null)
    {
      hud.changePortrait('off');
      diamond.kill();
      fillOverlayTilemap(0);
      focused = null;
      clearUnitMoves();
    }
  }

  private function clearArrowSprites()
  {
    for (spr in arrowSprites.members)
      spr.kill();
  }

  private function buildArrowSprites(path:FlxPath)
  {
    for (i in 1...path.nodes.length)
    {
      final prev = path.nodes[i - 1], cur = path.nodes[i];
      final next:Null<FlxPoint> = (i < path.nodes.length
        - 1) ? path.nodes[i + 1] : null;
      final prevAngle = Math.round(Math.atan2(prev.y - cur.y,
        prev.x - cur.x) * 180 / Math.PI);

      final spr = arrowSprites.recycle(MovementArrow);
      spr.reset(cur.x - 8, cur.y - 8);

      var frame = ANGLE_ARROW_MAPPING.get(prevAngle)[1];
      if (next != null)
      {
        final nextAngle = Math.round(Math.atan2(next.y - cur.y,
          next.x - cur.x) * 180 / Math.PI);

        frame = ANGLE_ARROW_MAPPING.get(prevAngle)[ANGLE_ARROW_MAPPING.get(nextAngle)[0]];
      }

      spr.animation.frameIndex = frame;
    }
  }

  private function selectFriend(mech:Mech)
  {
    diamond.reset(mech.x, mech.y);
    hud.changePortrait(mech.portrait);

    clearUnitMoves();
    fillOverlayTilemap(1);

    unitMoves = mech.findReachable(mech.staminaLeft, (x, y) ->
    {
      for (e in enemies.members)
      {
        if (x == Math.round(e.x / 16) && y == Math.round(e.y / 16))
          return true;
      }
      return false;
    });
    focused = mech;
    overlayTilemap.setTile(Math.round(mech.x / 16), Math.round(mech.y / 16), 0);
    for (m in unitMoves)
    {
      final endX = Math.floor(m.tail().x / 16);
      final endY = Math.floor(m.tail().y / 16);

      overlayTilemap.setTile(endX, endY, 0);
    }

    // Go through all the above paths and see if the mech can attack
    if (mech.canStillAttack)
      for (e in enemies.members)
        if (findAttack(unitMoves, e) != null)
          overlayTilemap.setTile(Math.round(e.x / 16), Math.round(e.y / 16), 0);
  }

  private function selectEnemy(mech:Mech) {}

  private function trySelect(x:Int, y:Int)
  {
    final ptX = 16.0 * x;
    final ptY = 16.0 * y;
    var mech:Mech;

    if ((mech = sprAt(friends, ptX, ptY)) != null && focused != mech)
      selectFriend(mech);
    else if ((mech = sprAt(enemies, ptX, ptY)) != null && focused != mech)
      selectEnemy(mech);
    else
      deselect();
  }

  private function findAttack(moves:Array<FlxPath>, enemy:Mech):Null<FlxPath>
  {
    for (m in moves)
      if (FlxMath.distanceToPoint(enemy, m.tail()) < 20)
        return m;
    return null;
  }

  private function clearUnitMoves()
  {
    for (m in unitMoves)
      m.destroy();
    unitMoves = [];
  }

  private function fillOverlayTilemap(tile:Int)
  {
    for (y in 0...overlayTilemap.heightInTiles)
      for (x in 0...overlayTilemap.widthInTiles)
        overlayTilemap.setTile(x, y, tile);
  }

  private function sprAt<T:FlxSprite>(group:FlxTypedSpriteGroup<T>, x:Float,
      y:Float):Null<T>
  {
    for (spr in group.members)
      if (FlxMath.equal(spr.x, x) && FlxMath.equal(spr.y, y))
        return spr;

    return null;
  }

  public function move(sprite:FlxSprite, movements:Array<Compass>)
  {
    // move a piece
  }
}
