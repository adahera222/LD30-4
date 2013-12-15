import 'dart:html';
import 'dart:math';
import 'urlsGameLib.dart';

/**********************************************************
 * Global/Class Variables
 **********************************************************/

final FPS = 60;
num _timer = 0;
num _prevTick = 0;

AudioElement _sndClear;

AudioElement _song1;

ImageElement _fourPtStar;
ImageElement _circle;
ImageElement _diamond;
ImageElement _star;
ImageElement _triangle;
ImageElement _imgCursor;
ImageElement _imgCursorVerticle;

List<ImageElement> _imgSmoke;

const int PUZZLE_WIDTH = 9;
const int PUZZLE_HEIGHT = 9;

const int FOUR_PT_STAR = 1;
const int CIRCLE = 2;
const int DIAMOND = 3;
const int STAR = 4;
const int TRIANGLE = 5;

CanvasRenderingContext2D _ctx;
CanvasElement _canvas;
Keyboard _keyboard;
GameState _state;

Random _random = new Random();

/**********************************************************
 * Begin Main Class Section
 **********************************************************/

void main() {
  _canvas = querySelector("#canvas");
  _ctx = _canvas.context2D;
  _state = new GameState(_ctx);
  _state.changeScreen(new TitleScreen());
  _keyboard = new Keyboard();

  _sndClear = new AudioElement()..src = "sounds/clear.wav";
  
  _song1 = new AudioElement()..src = "music/easystages.wav"..loop = true;
  
  _fourPtStar = new ImageElement()..src = "images/4pt-star-block.png";
  _circle = new ImageElement()..src = "images/circle-block.png";
  _diamond = new ImageElement()..src = "images/diamond-block.png";
  _star = new ImageElement()..src = "images/star-block.png";
  _triangle = new ImageElement()..src = "images/triangle-block.png";
  _imgCursor = new ImageElement()..src = "images/cursor.png";
  _imgCursorVerticle = new ImageElement()..src = "images/cursor_verticle.png";
  
  _imgSmoke = [new ImageElement()..src = "images/smoke1.png", 
      new ImageElement()..src = "images/smoke2.png", new ImageElement()..src = "images/smoke3.png"];
  
  _timer = 1000 / FPS;
  window.animationFrame.then(run);
}

// Game Loop
bool run(num delta){
  num time = new DateTime.now().millisecondsSinceEpoch;
  
  update(time);
  _state.render();
  
  // Will launch this function at the next frame
  window.animationFrame.then(run);
}

// Game logics triggered at each frame
void update(num time){  
  if (time - _prevTick > _timer){
    // Reinitializes the timer
    _state.update(time);
    _prevTick = new DateTime.now().millisecondsSinceEpoch;
  }
}

/****************************************************
 * End Main Class Section
 ****************************************************/

/****************************************************
* Begin Game Specific Classes
*****************************************************/

class TitleScreen extends GameScreen {
  
  ImageElement _titleImage;
  
  void dispose() {
    _titleImage.remove();
  }

  void init() {
    _titleImage = new ImageElement();
    _titleImage.src = "images/title.png";
  }

  void render(CanvasRenderingContext2D ctx) {
    ctx.drawImage(_titleImage, 100, 0);
    ctx.drawImage(_fourPtStar, 232, 365);
    ctx.drawImage(_circle, 298, 365);
    ctx.drawImage(_diamond, 364, 365);
    ctx.drawImage(_star, 430, 365);
    ctx.drawImage(_triangle, 496, 365);
  }

  void update(num time) {
    if (_keyboard.isPressed(KeyCode.ENTER) || _keyboard.isPressed(KeyCode.SPACE)) {
      _ctx.clearRect(0, 0, 800, 600);
      _keyboard.purge();
      _state.changeScreen(new GamePlayScreen());
    }
  }
}

class WinScreen extends GameScreen {
  
  ImageElement _background;
  
  void dispose() {
    _background.remove();
  }

  void init() {
    _background = new ImageElement();
    _background.src = "images/winscreen.png";
  }

  void render(CanvasRenderingContext2D ctx) {
    ctx.drawImage(_background, 0, 0);
    ctx.drawImage(_fourPtStar, 232, 0);
    ctx.drawImage(_circle, 298, 0);
    ctx.drawImage(_diamond, 364, 0);
    ctx.drawImage(_star, 430, 0);
    ctx.drawImage(_triangle, 496, 0);
  }

  void update(num time) {
    if (_keyboard.isPressed(KeyCode.ENTER) || _keyboard.isPressed(KeyCode.SPACE)) {
      _ctx.clearRect(0, 0, 800, 600);
      _keyboard.purge();
      _state.changeScreen(new TitleScreen());
    }
  }
}

class GamePlayScreen extends GameScreen {
  
  ImageElement _background;
  Level _level;
  Cursor _cursor;
  
  void dispose() {
    _background.remove();
  }

  void init() {
    _background = new ImageElement();
    _background.src = "images/gameplaybg.png";
    changeLevel(new Level1());
    _cursor = new Cursor();
    _song1.play();
  }

  void render(CanvasRenderingContext2D ctx) {
    ctx.drawImage(_background, 0, 0);
    //_ctx.clearRect(0, 0, 800, 600);
    ctx.setFillColorRgb(0, 0, 0, 255);
    ctx.fillRect(98, 0, 5, 600);
    ctx.fillRect(697, 0, 5, 600);
    ctx.fillRect(98, 0, 604, 3);
    ctx.fillRect(98, 597, 604, 3);
    
    ctx.setFillColorRgb(128, 128, 128, 128);
    for (int i = 1; i <= 8; i++) {
      ctx.fillRect(103, (66 * i) + 3, 594, 1);
      ctx.fillRect((66 * i) + 103, 3, 1, 594);
    }
    
    if (_level == null) return;
    
    List<List<int>> puzzle = _level.puzzle;
    for (int i = 0; i < puzzle.length; i++) {
      for (int j = 0; j < puzzle[i].length; j++) {
        drawImage(ctx, (j * 66) + 103, (i * 66) + 3, puzzle[i][j]);
      }
    }
    
    _level.render(ctx);
    
    if (_level.complete) {
      ctx.font = "48pt Calibri";
      String strComplete = _level.title + " Completed!";
      ctx.setFillColorRgb(255, 255, 255, 255);
      ctx.fillText(strComplete, 150, 200);
      ctx.setFillColorRgb(0, 0, 0, 255);
      ctx.strokeText(strComplete, 150, 200);
      
      ctx.font = "32pt Calibri";
      strComplete = "Press 'enter' to move on.";
      ctx.setFillColorRgb(255, 255, 255, 255);
      ctx.fillText(strComplete, 185, 270);
      ctx.setFillColorRgb(0, 0, 0, 255);
      ctx.strokeText(strComplete, 185, 270);
    }
    else if (_level.failed) {
      ctx.font = "48pt Calibri";
      String strComplete = "You failed " +_level.title + "!";
      ctx.setFillColorRgb(255, 255, 255, 255);
      ctx.fillText(strComplete, 150, 200);
      ctx.setFillColorRgb(0, 0, 0, 255);
      ctx.strokeText(strComplete, 150, 200);
      
      strComplete = "Press 'r' to retry.";
      ctx.setFillColorRgb(255, 255, 255, 255);
      ctx.fillText(strComplete, 170, 270);
      ctx.setFillColorRgb(0, 0, 0, 255);
      ctx.strokeText(strComplete, 170, 270);
    }
    
    ctx.drawImage(_cursor.flipped ? _imgCursorVerticle : _imgCursor, 
        (_cursor.x * 66) + 103, (_cursor.y * 66) + 3);
  }
  
  void drawImage(CanvasRenderingContext2D ctx, int x, int y, int type) {
    ImageElement block;
    switch (type) {
      case FOUR_PT_STAR:
        block = _fourPtStar;
        break;
      case CIRCLE:
        block = _circle;
        break;
      case TRIANGLE:
        block = _triangle;
        break;
      case STAR:
        block = _star;
        break;
      case DIAMOND:
        block = _diamond;
        break;
      default:
        return;
    }
    ctx.drawImage(block, x + 1, y + 1);
  }

  void changeLevel(Level level) {
    if (_level != null) level.dispose();
    _level = level;
    _level.init();
  }
  
  void resetLevel() => _level.init();
  
  void update(num time) {
    _level.update(time);
    if (_keyboard.isPressed(KeyCode.LEFT) || _keyboard.isPressed(KeyCode.A)) {
      _cursor.moveLeft();
    }
    else if (_keyboard.isPressed(KeyCode.RIGHT) || _keyboard.isPressed(KeyCode.D)) {
      _cursor.moveRight();
    }
    
    if (_keyboard.isPressed(KeyCode.UP) || _keyboard.isPressed(KeyCode.W)) {
      _cursor.moveUp();
    }
    else if (_keyboard.isPressed(KeyCode.DOWN) || _keyboard.isPressed(KeyCode.S)) {
      _cursor.moveDown();
    }
    
    if (_keyboard.isPressed(KeyCode.ENTER)) {
      if (_level.complete) {
        _level.nextLevel(this);
      }
      else {
        _level.swap(_cursor);
      }
    }
    
    if (_keyboard.isPressed(KeyCode.SPACE)) {
      _cursor.flip();
    }
    
    if (_keyboard.isPressed(KeyCode.R)) {
      resetLevel();
    }
    _keyboard.purge();
  }
}

abstract class Level {
  List<List<int>> _puzzle;
  int _frameCount;
  int _animation;
  int _brickCount;
  int _movesRemaining;
  String _title;
  bool _complete;
  bool _failed;
  bool _triggerCheck;
  List<Point> _burningBlocks;
  List<Point> _bricksToRemove;
  
  void init() {
    _title = "";
    _burningBlocks = new List<Point>();
    _bricksToRemove = new List<Point>();
    _frameCount = 0;
    _animation = -1;
    _brickCount = 0;
    _complete = false;
    _failed = false;
    _movesRemaining = 1;
    _triggerCheck = false;
    _puzzle = new List<List<int>>();
  }
  
  void nextLevel(GamePlayScreen screen);
  void dispose() {}//_puzzle.clear();
  
  void render(CanvasRenderingContext2D ctx) {
    if (_animation != -1 && _burningBlocks.length > 0) {
      for (Point point in _burningBlocks) {
        ctx.drawImage(_imgSmoke[_animation], (point.y * 66) + 103, (point.x * 66) + 3);
      }
    }
  }
  
  void update(num time) {
    _frameCount++;
    if (_frameCount > 10) {
      _frameCount = 0;
      if (_animation != -1) {
        if (_animation + 1 >= _imgSmoke.length) {
          _animation = -1;
          _burningBlocks.clear();
//          _complete = checkComplete();
//          _failed = !_complete;
          _triggerCheck = true;
        }
        else {
          _animation++;
        }
        return;
      }
      
      bool falling = false;
      for (int i = PUZZLE_HEIGHT - 2; i >= 0; i--) {
        for (int j = 0; j < PUZZLE_WIDTH; j++) {
          if (_puzzle[i][j] != 0 && _puzzle[i+1][j] == 0) {
            _puzzle[i+1][j] = _puzzle[i][j];
            _puzzle[i][j] = 0;
            falling = true;
          }
        }
      }
      
      if (falling) return;
      
      for (int i = PUZZLE_HEIGHT - 1; i >= 0; i--) {
        for (int j = 0; j < PUZZLE_WIDTH; j++) {
          checkBrick(i, j);
        }
      }
      
      if (_bricksToRemove.length > 0) {
        for (Point point in _bricksToRemove) {
          _puzzle[point.x][point.y] = 0;
          _burningBlocks.add(new Point(point.x, point.y));
        }
        _sndClear.play();
        _frameCount = 0;
        _animation = 0;
        _bricksToRemove.clear();
        return;
      }
      if (_triggerCheck) {
        _complete = checkComplete();
        _failed = !complete;
      }
    }
  }
  
  void checkBrick(int x, int y) {
    int search = _puzzle[x][y];
    if (search == 0) return;
    
    _brickCount = 1;
    checkNextBrick(x - 1, y, 0, search);    // left
    checkNextBrick(x + 1, y, 2, search);    // right
    
    if (_brickCount >= 3) {
      _bricksToRemove.add(new Point(x, y));
      return;
    }
    
    _brickCount = 1;
    checkNextBrick(x, y - 1, 1, search);    // up
    checkNextBrick(x, y + 1, 3, search);    // down
    
    if (_brickCount >= 3) {
      _bricksToRemove.add(new Point(x, y));
    }
  }
  
  void checkNextBrick(int x, int y, int direction, int search) {
    switch (direction) {
      case 0:   // left
        if (x < 0) return;
        break;
      case 1:   // up
        if (y < 0) return;
        break;
      case 2:   // right
        if (x >= PUZZLE_WIDTH) return;
        break;
      case 3:   // down
        if (y >= PUZZLE_HEIGHT) return;
        break;
    }
    if (_puzzle[x][y] == search) {
      _brickCount++;
      switch(direction) {
        case 0:   // left
          checkNextBrick(x - 1, y, direction, search);
          break;
        case 1:   // up
          checkNextBrick(x, y - 1, direction, search);
          break;
        case 2:   // right
          checkNextBrick(x + 1, y, direction, search);
          break;
        case 3:   // down
          checkNextBrick(x, y + 1, direction, search);
          break;
      }
    }
  }
  
  GameState get state => _state;
  bool get failed => _failed;
  bool get complete => _complete;
  String get title => _title;
  List<List<int>> get puzzle => _puzzle;
  set title(String title) => _title = title;
  
  bool checkComplete() {
    for (int i = 0; i < PUZZLE_HEIGHT; i++) {
      for (int j = 0; j < PUZZLE_WIDTH; j++) {
        if (_puzzle[i][j] != 0) return false;
      }
    }
    return true;
  }
  
  void setBlankPuzzle() {
    _puzzle = new List<List<int>>();
    for (int i = 0; i < PUZZLE_HEIGHT; i++) {
      _puzzle.add(new List<int>());
      for (int j = 0; j < PUZZLE_WIDTH; j++) {
        _puzzle[i].add(0);
      }
    }
  }
  
  void swap(Cursor cursor) {
    if (_movesRemaining <= 0) return;
     
    int temp = _puzzle[cursor.y][cursor.x]; 
    Point pt = cursor.flipped ? new Point(cursor.x, cursor.y + 1) : new Point(cursor.x + 1, cursor.y);
    
    if (temp == 0 && _puzzle[pt.y][pt.x] == 0) return; 
    
    _puzzle[cursor.y][cursor.x] = _puzzle[pt.y][pt.x];
    _puzzle[pt.y][pt.x] = temp;
    _triggerCheck = true;
    _movesRemaining --;
  }
  
  //set puzzle(List<List<int>> puzzle) => _puzzle = puzzle;
}

//class TestLevel extends Level {
//  
//  void init() {
//    super.init();
//    _puzzle = new List<List<int>>();
//    for (int i = 0; i < PUZZLE_HEIGHT; i++) {
//      _puzzle.add(new List<int>());
//      for (int j = 0; j < PUZZLE_WIDTH; j++) {
//        _puzzle[i].add(_random.nextInt(5));
//      }
//    }
//  }
//}

class Point {
  int _x, _y;
  Point(this._x, this._y);
  int get x => _x;
  int get y => _y;
  set x(int x) => _x = x;
  set y(int y) => _y = y;
}

class Cursor {
  bool _flipped;
  int _x, _y;
  Cursor() {
    _x = 0;
    _y = 0;
    _flipped = false;
  }
  int get x => _x;
  int get y => _y;
  bool get flipped => _flipped;
//  set x(int x) => _x = x;
//  set y(int y) => _y = y;
//  set flipped(bool flipped) => _flipped = flipped;
  
  void flip() {
    _flipped = !_flipped;
    if (_flipped && _y >= PUZZLE_HEIGHT - 1) _y--;
    else if (!_flipped && _x >= PUZZLE_WIDTH - 1) _x--;
  }
  
  void moveRight() {
    if (_flipped) {
      if (_x + 1 < PUZZLE_WIDTH) _x++;
      return;
    }
    if (_x + 1 < PUZZLE_WIDTH - 1) _x++;
  }
  
  void moveLeft() {
    if (_x - 1 >= 0) _x--;
  }
  
  void moveUp() {
    if (_y - 1 >= 0) _y--;
  }
  
  void moveDown() {
    if (_flipped) {
      if (_y + 1 < PUZZLE_HEIGHT - 1) _y++;
      return;
    }
    if (_y + 1 < PUZZLE_HEIGHT) _y++;
  }
}

/****************************************************
* End Game Specific Classes
*****************************************************/


/****************************************************
* LEVELS
*****************************************************/

class Level1 extends Level {
  void init() {
    super.init();
    setBlankPuzzle();
    title = "Level 1";
    int type = _random.nextInt(6);
    type = type == 0 ? 1 : type;
    type = type > 5 ? 5 : type;
    puzzle[8][2] = type;
    puzzle[8][3] = type;
    puzzle[8][5] = type;
  }
  
  void render(CanvasRenderingContext2D ctx) {
    super.render(ctx);
    if (!complete && !failed) {
      ctx.font = "24pt Calibri";
      String temp = "Move with arrow keys or 'WADS'.";
      ctx.setFillColorRgb(255, 255, 255, 255);
      ctx.fillText(temp, 180, 40);
      ctx.setFillColorRgb(0, 0, 0, 255);
      ctx.strokeText(temp, 180, 40);
      temp = "Swap bricks with 'enter'.";
      ctx.setFillColorRgb(255, 255, 255, 255);
      ctx.fillText(temp, 245, 80);
      ctx.setFillColorRgb(0, 0, 0, 255);
      ctx.strokeText(temp, 245, 80);
    }
  }
  
  void nextLevel(GamePlayScreen screen) {
    screen.changeLevel(new Level2());
  } 
}

class Level2 extends Level {
  void init() {
    super.init();
    setBlankPuzzle();
    title = "Level 2";
    int type = _random.nextInt(6);
    type = type == 0 ? 1 : type;
    type = type > 5 ? 5 : type;
    puzzle[8][2] = type;
    puzzle[7][2] = type;
    puzzle[8][3] = type;
  }
  
  void render(CanvasRenderingContext2D ctx) {
    super.render(ctx);
    if (!complete && !failed) {
      ctx.font = "24pt Calibri";
      String temp = "Bricks are able to fall.";
      ctx.setFillColorRgb(255, 255, 255, 255);
      ctx.fillText(temp, 265, 40);
      ctx.setFillColorRgb(0, 0, 0, 255);
      ctx.strokeText(temp, 265, 40);
    }
  }
  
  void nextLevel(GamePlayScreen screen) {
    screen.changeLevel(new Level3());
  }
}

class Level3 extends Level {
  void init() {
    super.init();
    setBlankPuzzle();
    title = "Level 3";

    puzzle[8][2] = TRIANGLE;
    puzzle[8][3] = TRIANGLE;
    puzzle[7][4] = TRIANGLE;
    
    puzzle[7][2] = STAR;
    puzzle[7][3] = STAR;
    puzzle[8][4] = STAR;
  }
  
  void render(CanvasRenderingContext2D ctx) {
    super.render(ctx);
    if (!complete && !failed) {
      ctx.font = "24pt Calibri";
      String temp = "Press 'space' to rotate.";
      ctx.setFillColorRgb(255, 255, 255, 255);
      ctx.fillText(temp, 255, 40);
      ctx.setFillColorRgb(0, 0, 0, 255);
      ctx.strokeText(temp, 255, 40);
    }
  }
  
  void nextLevel(GamePlayScreen screen) {
    screen.changeLevel(new Level4());
  }
}

class Level4 extends Level {
  void init() {
    super.init();
    setBlankPuzzle();
    title = "Level 4";

    puzzle[7][3] = TRIANGLE;
    puzzle[8][3] = TRIANGLE;
    puzzle[8][4] = TRIANGLE;
    
    puzzle[6][3] = STAR;
    puzzle[7][4] = STAR;
    puzzle[8][5] = STAR;
  }
  
  void render(CanvasRenderingContext2D ctx) {
    super.render(ctx);
    if (!complete && !failed) {
      ctx.font = "24pt Calibri";
      String temp = "Bricks chain clear as they fall.";
      ctx.setFillColorRgb(255, 255, 255, 255);
      ctx.fillText(temp, 205, 40);
      ctx.setFillColorRgb(0, 0, 0, 255);
      ctx.strokeText(temp, 205, 40);
    }
  }
  
  void nextLevel(GamePlayScreen screen) {
    screen.changeLevel(new Level5());
  }
}

class Level5 extends Level {
  void init() {
    super.init();
    setBlankPuzzle();
    title = "Level 5";

    puzzle[8] = [0, 1, 1, 2, 2, 3, 2, 2, 0];
    puzzle[7] = [0, 1, 2, 3, 3, 4, 4, 0, 0];
    puzzle[6][4] = 4;
    puzzle[6][5] = 2;
  }
  
  void render(CanvasRenderingContext2D ctx) {
    super.render(ctx);
  }
  
  void nextLevel(GamePlayScreen screen) {
    screen.changeLevel(new Level6());
  }
}

class Level6 extends Level {
  void init() {
    super.init();
    setBlankPuzzle();
    title = "Level 6";

    puzzle[8] = [0, 1, 2, 1, 1, 4, 0, 0, 0];
    puzzle[7] = [0, 2, 2, 4, 4, 0, 0, 0, 0];
    puzzle[6] = [0, 0, 3, 2, 2, 0, 0, 0, 0];
    puzzle[5][2] = 2;
    puzzle[5][3] = 2;
    puzzle[4][2] = 3;
    puzzle[3][2] = 3;
    puzzle[2][2] = 1;
    puzzle[1][2] = 2;
  }
  
  void render(CanvasRenderingContext2D ctx) {
    super.render(ctx);
  }
  
  void nextLevel(GamePlayScreen screen) {
    screen.changeLevel(new Level7());
  }
}

class Level7 extends Level {
  void init() {
    super.init();
    setBlankPuzzle();
    title = "Level 7";

    puzzle[8] = [0, 0, 2, 2, 1, 3, 3, 4, 4];
    puzzle[7] = [0, 0, 0, 2, 2, 1, 3, 3, 0];
    puzzle[6] = [0, 0, 0, 0, 1, 2, 1, 1, 0];
    puzzle[5] = [0, 0, 0, 0, 1, 0, 4, 3, 0];
    puzzle[4][4] = 3;
    puzzle[3][4] = 2;
  }
  
  void render(CanvasRenderingContext2D ctx) {
    super.render(ctx);
  }
  
  void nextLevel(GamePlayScreen screen) {
    screen.changeLevel(new Level8());
  }
}

class Level8 extends Level {
  void init() {
    super.init();
    setBlankPuzzle();
    title = "Level 8";

    puzzle[8] = [0, 3, 3, 2, 3, 3, 2, 2, 0];
    puzzle[7] = [0, 4, 4, 3, 2, 2, 3, 3, 0];
    puzzle[6] = [0, 2, 2, 4, 1, 5, 5, 2, 0];
    puzzle[5] = [0, 3, 3, 2, 5, 2, 2, 4, 0];
    puzzle[4] = [0, 4, 4, 3, 3, 4, 4, 2, 0];
    puzzle[2][3] = 1;
    puzzle[3][2] = 1;
    puzzle[3][3] = 4;
    puzzle[3][5] = 3;
    puzzle[3][6] = 3;
    //puzzle[3][4] = 4;
  }
  
  void render(CanvasRenderingContext2D ctx) {
    super.render(ctx);
  }
  
  void nextLevel(GamePlayScreen screen) {
    screen.changeLevel(new Level9());
  }
}

class Level9 extends Level {
  void init() {
    super.init();
    setBlankPuzzle();
    title = "Level 9";

    puzzle[8] = [5, 1, 1, 2, 1, 1, 5, 1, 4];
    puzzle[7] = [2, 3, 4, 2, 4, 4, 5, 1, 4];
    puzzle[6] = [5, 2, 3, 1, 1, 3, 1, 3, 3];
    puzzle[5] = [5, 0, 2, 2, 0, 0, 5, 1, 4];
    puzzle[4][0] = 3;
    puzzle[4][3] = 1;
    puzzle[3][3] = 4;
  }
  
  void render(CanvasRenderingContext2D ctx) {
    super.render(ctx);
  }
  
  void nextLevel(GamePlayScreen screen) {
    _state.changeScreen(new WinScreen());
  }
}