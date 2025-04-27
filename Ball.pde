class Ball extends Circle {
  Ball (float x, float y, float diametre, float mass, float friction, String name) {
    super(x, y, diametre, mass, friction, name);
  }
  
  Ball (PVector position, float diametre, float mass, float friction, String name) {
    super (position, diametre, mass, friction, name);
  }
}
