library urlsGameLib;

import 'dart:html';
import 'dart:collection';

/**
 * Generic Sprite class
 */
class Sprite {
  int _x, _y, _width, _height;
  ImageElement _image;
  bool _alive;
  
  Sprite(this._image, this._x, this._y);
  
  void update(num time) {
    
  }
  
  void render(CanvasRenderingContext2D ctx) {
    ctx.drawImage(_image, _x, _y);
  }
  
  // Getters
  bool get alive => _alive;
  int get x => _x;
  int get y => _y;
  int get width => _width;
  int get height => _height;
  ImageElement get image => _image;
  
  
  // Setters
  set alive(bool alive) => _alive = alive;
  set x(int x) => _x = x;
  set y(int y) => _y = y;
  set width(int width) => _width = width;
  set height(int height) => _height = height;
  set image(ImageElement image) => _image = image;
  
  bool collidesWith(Sprite sprite) {
    if (x > sprite.x + sprite.width) return false;
    if (x + width < sprite.x) return false;
    if (y > sprite.y + sprite.height) return false;
    if (y + height < sprite.y) return false;
    return true;
  }
}

class GameState {
  GameScreen _screen;
  CanvasRenderingContext2D _ctx;
  
  GameState(this._ctx);
  
  void changeScreen(GameScreen screen) {
    if (_screen != null) _screen.dispose();
    _screen = screen;
    _screen.init();
  }
  
  void render() {
    if (_screen == null) return;
    _screen.render(_ctx);
  }
  
  void update(num time) {
    if (_screen == null) return;
    _screen.update(time);
  }
  
}

abstract class GameScreen {
  
  void render(CanvasRenderingContext2D ctx);
  void update(num time);
  void init();
  void dispose();
  
}

class Keyboard {
  HashMap<int, int> _keys = new HashMap<int, int>();

  Keyboard() {  
    window.onKeyDown.listen((KeyboardEvent e) {
      if (!_keys.containsKey(e.keyCode))
        _keys[e.keyCode] = e.timeStamp;
    });

    window.onKeyUp.listen((KeyboardEvent e) {
      _keys.remove(e.keyCode);
    });
  }
  isPressed(int keyCode) => _keys.containsKey(keyCode);
  purge() => _keys.clear();
}

class GameInput {
  Keyboard _keyboard;
  
  GameInput() {
    _keyboard = new Keyboard();
  }
}