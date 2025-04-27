class Pocket {
  
  //5, 5, -ballDiameter + 0.01
  float xLoc;
  float yLoc;
  float zLoc;
  int sides = 18;
  float r = 20;
  float h = ballDiameter - 1;
  color colorBlack = color(0);
  color colorTable = color(39,107,64);
  
  Pocket (float xLoc, float yLoc, float zLoc){
    this.xLoc = xLoc;
    this.yLoc = yLoc;
    this.zLoc = zLoc;
  }
  
  void drawCylinder(){
  pushMatrix();
  noStroke();
  translate(xLoc,yLoc,zLoc);
  float angle = 360 / sides;
  float halfHeight = h / 2;
  // Draw top
  fill(colorBlack);
  beginShape();
  for(int i = 0; i < sides; i++){
    float x = cos(radians( i * angle )) * r;
    float y = sin(radians( i * angle )) * r;
    vertex( x, y, halfHeight );
  }
  endShape(CLOSE);
  
  // Draw Bottom
  fill(colorTable);
  beginShape();
  for(int i = 0; i < sides; i++){
    float x = cos(radians( i * angle )) * r;
    float y = sin(radians( i * angle )) * r;
    vertex ( x, y, -halfHeight );
  }
  endShape(CLOSE);
  
  // Draw body
  beginShape(TRIANGLE_STRIP);
  for (int i = 0; i < sides + 1; i++) {
      float x1 = cos( radians( i * angle ) ) * r;
      float y1 = sin( radians( i * angle ) ) * r;
      float x2 = cos( radians( i * angle ) ) * r;
      float y2 = sin( radians( i * angle ) ) * r;
      vertex( x1, y1, -halfHeight);
      vertex( x2, y2, halfHeight);
  }
  endShape(CLOSE);
  popMatrix();
  }
  
  void checkCollisionWithBall(Ball ball){
    //println("Checking collision with " + ball.name + " distance: " + dist(xLoc, yLoc, ball.position.x, ball.position.y));
    if(dist(xLoc, yLoc, ball.position.x, ball.position.y) < r){
      println(ball.name + " in the hole!");
      ball.position = new PVector(ballInHoleLocation, -ballDiameter - 25);
      ball.velocity = new PVector(0,0);
      ball.ballInHole = true;
      ballInHoleLocation += ballDiameter;
    }
  }
}
