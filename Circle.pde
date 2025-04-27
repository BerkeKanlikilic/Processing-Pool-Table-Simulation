class Circle {
  private float diameter;
  PVector position;
  PVector velocity;
  PVector acceleration = new PVector (0, 0);
  float radius;
  float mass;
  float friction;
  
  boolean ballInHole = false;
  
  String name = "null";
  
  color ballColor = color(int(random(50,255)),int(random(50,255)),int(random(50,255)));
  
  Circle (float x, float y, float diameter, float mass, float friction, String name) {
    this.diameter = diameter;
    this.mass = mass;
    this.friction = friction;
    this.name = name;
    ballInHole = false;
    
    position = new PVector (x, y);
    velocity = new PVector (0, 0);
    radius = diameter / 2;
  }
  
  Circle (PVector position, float diameter, float mass, float friction, String name) {
    this.position = position;
    this.diameter = diameter;
    this.mass = mass;
    this.friction = friction;
    ballInHole = false;
    
    velocity = new PVector (0, 0);
    radius = diameter / 2;
  }
  
  void setdiameter (float diameter) {
    this.diameter = diameter;
    this.radius = diameter / 2;
  }
  
  float getdiameter () {
    return diameter;
  }
  
  void update() {
    if(ballInHole == true) return;
    checkOutsideBounds();
    
    velocity = velocity.mult(1 - friction);
    acceleration = PVector.div(velocity, mass);
    position.add(acceleration);
    
    velocity.x = Math.abs (velocity.x) < 0.005 ? 0 : velocity.x;
    velocity.y = Math.abs(velocity.y) < 0.005 ? 0 : velocity.y;
  }
  
  void checkOutsideBounds(){
    if(ballInHole == true) return;
    float x = position.x - radius;
    float xp = position.x + radius;
    float y = position.y - radius;
    float yp = position.y + radius;
    
    if(x < 0){
      velocity.x = -velocity.x;
    } else if (xp > tableWidth){
      velocity.x = -velocity.x;
    } else if (y < 0){
      velocity.y = -velocity.y;
    } else if (yp > tableDepth){
      velocity.y = -velocity.y;
    }
  }
  
  void display() {
    pushMatrix();
    fill (ballColor);
    noStroke();
    translate(position.x,position.y, 0);
    sphere(diameter/2);
    popMatrix();
  }
  
  boolean AABBCC (Circle circle) {
    float x = position.x - radius;
    float y = position.y - radius;
    
    float otherX = circle.position.x - circle.radius;
    float otherY = circle.position.y - circle.radius;
    
    return
      x < otherX + circle.getdiameter() &&
      x + diameter > otherX &&
      y < otherY + circle.getdiameter() &&
      y + diameter > otherY;
  }
  
  int checkRectangleCollision (Rectangle r) {
    if(ballInHole == true) return 0;
    float x = position.x - radius;
    float y = position.y - radius;
    
    int result = 0;
    
    if (x < r.x)
      result = 1;
    else if (x + diameter > r.x + r.width)
      result = 3;
    else if (y < r.y)
      result = 2;
    else if (y + diameter > r.y + r.height)
      result = 4;

    return result;
  }
  
  PVector tempVel = null;  
  
  PVector checkCircleCollision (Circle other) {
    if(ballInHole == true) return null;
    PVector result = null;
    
    if (AABBCC(other)) {
      PVector vDistance = PVector.sub (other.position, this.position);
      
      float magnitude = vDistance.mag();
      
      float sumRadius = this.radius + other.radius;
      
      if (magnitude < sumRadius) {
        
        float deltaPct = (sumRadius - magnitude) / magnitude;
        this.position.x = this.position.x - this.velocity.x * deltaPct;
        this.position.y = this.position.y - this.velocity.y * deltaPct;
        
        float collisionPointX =
            ((this.position.x * other.radius) + (other.position.x * this.radius))
            / (this.radius + other.radius);
        
        float collisionPointY =
            ((this.position.y * other.radius) + (other.position.y * this.radius))
            / (this.radius + other.radius);
        
        result = new PVector (collisionPointX, collisionPointY);
        
        PVector un = result.get();
        un.sub (this.position);
        un.normalize();
        
        PVector ut = new PVector (-un.y, un.x);
        
        float v1n = PVector.dot(un, this.velocity);
        float v1t = PVector.dot(ut, this.velocity);
        float v2n = PVector.dot(un, other.velocity);
        float v2t = PVector.dot(ut, other.velocity);
        
        v1n = (v1n * (this.mass - other.mass) + 2 * other.mass * v2n) / (this.mass + other.mass);
        
        un.mult (v1n);
        ut.mult (v1t);
        
        un.add (ut);
        
        tempVel = un.get();
      }      
    }
    
    return result;
  }
  
  Boolean checkCircleCollisionValid (Circle other) {
    if(ballInHole == true) return null;
    PVector result = null;
    
    if (AABBCC(other)) {
      PVector vDistance = PVector.sub (other.position, this.position);
      
      float magnitude = vDistance.mag();
      
      float sumRadius = this.radius + other.radius;
      
      if (magnitude < sumRadius) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
  
  void updateCollision() {
    
    if (tempVel != null) {
      this.velocity.x = tempVel.x;
      this.velocity.y = tempVel.y;
      
      tempVel = null;
    }
  }
  
}
