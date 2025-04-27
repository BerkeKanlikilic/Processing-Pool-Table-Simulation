import controlP5.*;
import peasy.*;
import java.awt.Rectangle;

PeasyCam cam;
ControlP5 cp5;

Ball[] balls;
Pocket[] pockets;

Rectangle view;

int numberOfBalls = 16; // 15 + blanche
int ballDiameter = 15;
int cueBall = 15;

int numberOfPockets = 6;

int tableWidth = 280;
int tableDepth = 480;

int uiPosX = 50;
int uiPosY = 60;
int uiGap = 30;
int uiWidth = 150;
int uiHeight = 290;

float cueBallForce = 15;
float ballFriction = 0.01;
float ballMass = 5;

PVector cueBallVisualVector;
PVector cueBallVector;
float cueBallAngle = 1;

int ballInHoleLocation = 5;

boolean triangleSetup = true;

int myColor = color(255, 0, 0);

Textarea informationTextArea;
Textlabel topTextLabel;

void setup () {
  size (1280, 720, P3D);
  
  cam = new PeasyCam(this, 900);
  cp5 = new ControlP5(this);
  
  /////////////////////////////////////////////////////////////
  // UI Elements initiation
  /////////////////////////////////////////////////////////////
  
  cp5.setColorForeground(0xffaa0000);
  cp5.setColorBackground(0xff660000);
  cp5.setColorActive(0xffff0000);
  
  cp5.addSlider("Table Width").setRange(200,1200).setValue(280).setPosition(uiPosX + 5,uiPosY + 5).setSize(80,20).setSliderMode(Slider.FLEXIBLE);
  Slider depthSliderSlider = cp5.addSlider("Table Depth").setRange(320,1200).setValue(480).setPosition(uiPosX + 5,uiPosY + uiGap + 5).setSize(80,20).setSliderMode(Slider.FLEXIBLE);;
  
  cp5.addSlider("Ball Diameter").setRange(5,20).setValue(15).setPosition(uiPosX + 5,uiPosY + (uiGap * 2) + 5).setSize(80,20).setSliderMode(Slider.FLEXIBLE);
  cp5.addSlider("Ball Mass").setRange(1,10).setValue(5).setPosition(uiPosX + 5,uiPosY + (uiGap * 3) + 5).setSize(80,20).setSliderMode(Slider.FLEXIBLE);
  cp5.addSlider("Cueball Force").setRange(5,20).setValue(15).setPosition(uiPosX + 5,uiPosY + (uiGap * 4) + 5).setSize(80,20);
  cp5.addSlider("Friction").setRange(0.001,0.02).setValue(0.01).setPosition(uiPosX + 5,uiPosY + (uiGap * 5) + 5).setSize(80,20);
  cp5.addToggle("triangleSetup", true, uiPosX + 5, uiPosY + (uiGap * 6) + 5, 20, 20).setCaptionLabel("Triangle / Random\nPlacement").setMode(cp5.SWITCH);
  cp5.addButton("Hit Cue Ball", 10, uiPosX + 5, uiPosY + (uiGap * 7) + 25, 80, 20).setId(1);
  cp5.addButton("Reset", 10, uiPosX + 5, uiPosY + (uiGap * 8) + 25, 80, 20).setId(2);
  
  informationTextArea = cp5.addTextarea("informationText").setPosition(width - 250, 5).setSize(250,400).setFont(createFont("arial",14));
  topTextLabel = cp5.addTextlabel("topText").setPosition(width / 2 - 145, 20).setSize(290,400).setFont(createFont("arial",30));
  
  cp5.setAutoDraw(false);
  
  /////////////////////////////////////////////////////////////
  // Borders of the table (not visual)
  /////////////////////////////////////////////////////////////
  
  view = new Rectangle (0, 0, tableWidth, tableDepth);
  
  /////////////////////////////////////////////////////////////
  // Ball array initiation
  /////////////////////////////////////////////////////////////
  
  balls = new Ball[numberOfBalls];
  
  pockets = new Pocket[numberOfPockets];
  
  /////////////////////////////////////////////////////////////
  // Initiation of first set of balls
  /////////////////////////////////////////////////////////////
  
  initiateBalls (new PVector (tableWidth / 2, tableDepth / 3));
  
  /////////////////////////////////////////////////////////////
  // Initiation of pockets
  /////////////////////////////////////////////////////////////
  
  initiatePockets();
  
  /////////////////////////////////////////////////////////////
  // Initial cueball visual vector
  /////////////////////////////////////////////////////////////
  
  cueBallVisualVector = new PVector (0, -50);
}

void draw () {
  
  view = new Rectangle (0, 0, tableWidth, tableDepth);
  
  updatePockets();
  
  updateBalls();
  display();
  
  tableGraphics();
  gui();
  informationText();
  topTextArea();
  
  keybinds();
  
  cueballRay();
}

/////////////////////////////////////////////////////////////
// This Ray show the direction of the cue ball traveling
/////////////////////////////////////////////////////////////

void cueballRay(){
  if(balls[cueBall].ballInHole == false ){
    pushMatrix();
    stroke(255);
    line(
    balls[cueBall].position.x,
    balls[cueBall].position.y,
    balls[cueBall].position.x + cueBallVisualVector.x,
    balls[cueBall].position.y + cueBallVisualVector.y); 
    popMatrix();
  }
}

/////////////////////////////////////////////////////////////
// Table Graphics
/////////////////////////////////////////////////////////////

void tableGraphics(){
  pushMatrix();
  fill(19,87,44);
  noStroke();
  beginShape(TRIANGLE_STRIP);
  vertex(0,0,ballDiameter / 2);
  vertex(0,0,-ballDiameter - 10);
  vertex(tableWidth,0,ballDiameter / 2);
  vertex(tableWidth,0,-ballDiameter - 10);
  vertex(tableWidth,tableDepth,ballDiameter / 2);
  vertex(tableWidth,tableDepth,-ballDiameter - 10);
  vertex(0,tableDepth,ballDiameter / 2);
  vertex(0,tableDepth,-ballDiameter - 10);
  vertex(0,0,ballDiameter / 2);
  vertex(0,0,-ballDiameter - 10);
  fill(127);
  vertex(-20,-20,ballDiameter / 2);
  vertex(-20,-20,-ballDiameter - 10);
  vertex(tableWidth + 20, -20,ballDiameter / 2);
  vertex(tableWidth + 20,-20,-ballDiameter - 10);
  vertex(tableWidth + 20,tableDepth + 20,ballDiameter / 2);
  vertex(tableWidth + 20,tableDepth + 20,-ballDiameter - 10);
  vertex(-20,tableDepth + 20,ballDiameter / 2);
  vertex(-20,tableDepth + 20,-ballDiameter - 10);
  vertex(-20,-20,ballDiameter / 2);
  vertex(-20,-20,-ballDiameter - 10);
  endShape();
  
  fill(19,87,44);
  beginShape(TRIANGLE_STRIP);
  vertex(-20,-20,ballDiameter / 2);
  vertex(0,0,ballDiameter / 2);
  vertex(tableWidth + 20,-20,ballDiameter / 2);
  vertex(tableWidth,0,ballDiameter / 2);
  vertex(tableWidth + 20,tableDepth + 20,ballDiameter / 2);
  vertex(tableWidth,tableDepth,ballDiameter / 2);
  vertex(-20,tableDepth + 20,ballDiameter / 2);
  vertex(0,tableDepth,ballDiameter / 2);
  vertex(-20,-20,ballDiameter / 2);
  vertex(0,0,ballDiameter / 2);
  endShape();
  
  fill(127);
  stroke(0);
  beginShape();
  vertex(-20,-20,-ballDiameter - 10);
  vertex(tableWidth + 20,-20,-ballDiameter - 10);
  vertex(tableWidth + 20,tableDepth + 20,-ballDiameter - 10);
  vertex(-20,tableDepth + 20,-ballDiameter - 10);
  endShape(CLOSE);
  
  translate(tableWidth/2,tableDepth/2,-ballDiameter);
  noStroke();
  fill(39,107,64);
  box(tableWidth,tableDepth,ballDiameter - 1);
  popMatrix();
}



/////////////////////////////////////////////////////////////
// UI
/////////////////////////////////////////////////////////////

void gui() {
  hint(DISABLE_DEPTH_TEST);
  cam.beginHUD();
  fill(50);
  noStroke();
  rect(uiPosX,uiPosY,uiWidth,uiHeight);
  cp5.draw();
  cam.endHUD();
  hint(ENABLE_DEPTH_TEST);
}

void informationText(){
  informationTextArea.setText(
  "\n\nCueBall X Velocity: " + (cueBallVector != null ? cueBallVector.x : "0.0") +
  "\nCueBall Y Velocity: " + (cueBallVector != null ? cueBallVector.y : "0.0") +
  "\n\n\nInstructions: \n\nA and D : Change the direction\n\nSpace : Hit the ball" +
  "\n\nArrow Keys : Move Ball Any Direction\n\nR : Reset");
}

void topTextArea(){
  if(balls[cueBall].ballInHole == true){
    topTextLabel.setText("Cue Ball in the hole!\nReset to Play Again");
  } else {
    topTextLabel.setText("");
  }
}

/////////////////////////////////////////////////////////////
// UI Events
/////////////////////////////////////////////////////////////

void controlEvent(ControlEvent theEvent) {
  //if(theEvent.isController()){
  //  println("control event from: " + theEvent.getController().getName());
  //  println(", value: " + theEvent.getController().getValue());
  //}
  
  if(theEvent.getController().getName()=="Table Width"){
    if(cp5.getController("Table Width") != null && balls != null) {
      tableWidth = int(theEvent.getController().getValue());
      resetTable();
    }
  }
  
  if(theEvent.getController().getName()=="Table Depth"){
    if(cp5.getController("Table Depth") != null && balls != null) {
      tableDepth = int(theEvent.getController().getValue());
      resetTable();
    }
  }
  
  if(theEvent.getController().getName()=="Friction"){
    if(cp5.getController("Friction") != null && balls != null) {
      ballFriction = theEvent.getController().getValue();
      resetTable();
    }
  }
  
  if(theEvent.getController().getName()=="Cueball Force"){
    if(cp5.getController("Cueball Force") != null && balls != null) {
      cueBallForce = theEvent.getController().getValue();
    }
  }
  
  if(theEvent.getController().getName()=="Cueball Angle"){
    if(cp5.getController("Cueball Angle") != null && balls != null) {
      cueBallAngle = theEvent.getController().getValue();
    }
  }
  
  if(theEvent.getController().getName()=="Ball Diameter"){
    if(cp5.getController("Ball Diameter") != null && balls != null) {
      ballDiameter = int(theEvent.getController().getValue());
      resetTable();
    }
  }
  
  if(theEvent.getController().getName() == "Hit Cue Ball"){
    hitCueBall();
  }
  
  if(theEvent.getController().getName() == "Reset"){
    resetTable();
  }
  
  if(theEvent.getController().getName() == "triangleSetup"){
    if(theEvent.getController().getValue() == 1){
      triangleSetup = true;
      resetTable();
    } else {
      triangleSetup = false;
      resetTable();
    }
  }
  
  if(theEvent.getController().getName() == "Ball Mass"){
    // prevent warnings at start
    if(cp5.getController("Ball Mass") != null && balls != null) {
      ballMass = int(theEvent.getController().getValue());
      resetTable();
    }
  }
}

/////////////////////////////////////////////////////////////
// Update the balls positions
/////////////////////////////////////////////////////////////

void updateBalls() {
  for (int i = 0; i < numberOfBalls; i++) {
    balls[i].update();
  }
  
  for (int i = 0; i < numberOfBalls; i++) {
    for (int j = 0; j < numberOfBalls; j++) {
      if (j != i)
        balls[i].checkCircleCollision(balls[j]);
    }
  }
  
  for (int i = 0; i < numberOfBalls; i++) {
    balls[i].updateCollision();
  }
}

void updatePockets(){
  pockets[0].h = ballDiameter - 1;
  pockets[0].r = ballDiameter + 5;
  pockets[0].xLoc = 5;
  pockets[0].yLoc = 5;
  pockets[0].zLoc = -ballDiameter + 0.01;
  pockets[1].h = ballDiameter - 1;
  pockets[1].r = ballDiameter + 5;
  pockets[1].xLoc = tableWidth - 5;
  pockets[1].yLoc = 5;
  pockets[1].zLoc = -ballDiameter + 0.01;
  pockets[2].h = ballDiameter - 1;
  pockets[2].r = ballDiameter + 5;
  pockets[2].xLoc = 5;
  pockets[2].yLoc = tableDepth - 5;
  pockets[2].zLoc = -ballDiameter + 0.01;
  pockets[3].h = ballDiameter - 1;
  pockets[3].r = ballDiameter + 5;
  pockets[3].xLoc = tableWidth - 5;
  pockets[3].yLoc = tableDepth - 5;
  pockets[3].zLoc = -ballDiameter + 0.01;

  pockets[4].h = ballDiameter - 1;
  pockets[4].r = ballDiameter + 5;
  pockets[4].xLoc = 5;
  pockets[4].yLoc = tableDepth / 2;
  pockets[4].zLoc = -ballDiameter + 0.01;
  
  pockets[5].h = ballDiameter - 1;
  pockets[5].r = ballDiameter + 5;
  pockets[5].xLoc = tableWidth - 5;
  pockets[5].yLoc = tableDepth / 2;
  pockets[5].zLoc = -ballDiameter + 0.01;
  
  for(int i = 0; i < numberOfPockets; i++){
    for (int j = 0; j < numberOfBalls; j++) {
    pockets[i].checkCollisionWithBall(balls[j]);
    }
  }
}

/////////////////////////////////////////////////////////////
// Display the scene and the balls
/////////////////////////////////////////////////////////////

void display () {
  background (0);
  lights();
  
  displayBalls();
  displayPockets();
}

void displayBalls() {
  for (int i = 0; i < numberOfBalls; i++) {
    balls[i].display();
  }
}

void displayPockets(){
  for(int i = 0; i < numberOfPockets; i++){
    pockets[i].drawCylinder();
    //println("pocket " + i + " location: ",pockets[i].xLoc, pockets[i].yLoc, pockets[i].zLoc);
  }
}

/////////////////////////////////////////////////////////////
// Initiate and spawn the balls
/////////////////////////////////////////////////////////////

void initiateBalls(PVector summit) {
  int spacing = 2;
  int nbRangees = 5;
  
  float angle = 30 * PI / 180; // Triangle équilatérale 60
  
  PVector rowOffset = new PVector ( (ballDiameter + spacing) * sin(angle), (ballDiameter + spacing) * cos (angle));
  
  float offsetHorizontal = rowOffset.x * 2; // Espace entre chaque balle
  
  int index = 0;
  int startIndex = 0;
  for (int j = 0; j < nbRangees; j++) {
    if (index > numberOfBalls) break;
    startIndex = index;
    if(triangleSetup){
      balls[index++] = new Ball(summit.x - (j * rowOffset.x), summit.y - (j * rowOffset.y), ballDiameter, ballMass, ballFriction, "Ball " + index);
    } else {
      balls[index++] = new Ball(new PVector(random(pockets[0].r + ballDiameter,tableWidth - pockets[0].r - ballDiameter),random(pockets[0].r + ballDiameter,tableDepth - pockets[0].r - ballDiameter)), ballDiameter, ballMass, ballFriction, "Ball " + index);
    }
    
    for (int i = 0; i < j; i++) {
      if (index > numberOfBalls) break;
      if(triangleSetup){
        balls[index++] = new Ball (balls[startIndex].position.x + ((i + 1) * offsetHorizontal), balls[startIndex].position.y, ballDiameter, ballMass, ballFriction, "Ball " + index);
      } else {
        balls[index++] = new Ball (random(pockets[0].r + ballDiameter,tableWidth - pockets[0].r - ballDiameter), random(pockets[0].r + ballDiameter,tableDepth - pockets[0].r - ballDiameter), ballDiameter, ballMass, ballFriction, "Ball " + index);
      }
    }
  }
  
  // Create a Cueball
  balls[cueBall] = new Ball (summit.x, summit.y + tableDepth / 3, ballDiameter, ballMass, ballFriction, "Cueball");
  balls[cueBall].ballColor = color(255);
  
  /////////////////////////////////////////////////////////////
  // Repeat initiating until no balls are colliding with each other
  /////////////////////////////////////////////////////////////
  
  if(!triangleSetup){
    for (int i = 0; i < numberOfBalls; i++) {
      for (int j = 0; j < numberOfBalls; j++) {
        if (j != i) {
          if(balls[i].checkCircleCollisionValid(balls[j]) || balls[i].ballInHole){
            resetTable();
          }
        }
      }
    }
  }
}

/////////////////////////////////////////////////////////////
// Initiate and spawn pockets
/////////////////////////////////////////////////////////////

void initiatePockets(){
  pockets[0] = new Pocket(5, 5, -ballDiameter + 0.01);
  pockets[1] = new Pocket(tableWidth - 5, 5, -ballDiameter + 0.01);
  pockets[2] = new Pocket(5, tableDepth - 5, -ballDiameter + 0.01);
  pockets[3] = new Pocket(tableWidth - 5, tableDepth - 5, -ballDiameter + 0.01);
  pockets[4] = new Pocket(5, tableDepth / 2, -ballDiameter + 0.01);
  pockets[5] = new Pocket(tableWidth - 5, tableDepth / 2, -ballDiameter + 0.01);
}

/////////////////////////////////////////////////////////////
// Hitting the cueball
/////////////////////////////////////////////////////////////

void hitCueBall(){
  //println("Initiated with: " + cueBallVector);
  
  cueBallVector = cueBallVisualVector.normalize();
  cueBallVector.mult(cueBallForce);
  cueBallVisualVector = new PVector (0, -50);
  cueBallVisualVector.rotate(cueBallVector.heading() + HALF_PI);
  
  //println("cueBallVector: ",cueBallVector," cueBallVisual: ", cueBallVisualVector);
  
  balls[cueBall].velocity = cueBallVector;
}

/////////////////////////////////////////////////////////////
// Function that resets the table
/////////////////////////////////////////////////////////////

void resetTable(){
  initiateBalls (new PVector (tableWidth / 2, tableDepth / 3));
  ballInHoleLocation = 5;
}

/////////////////////////////////////////////////////////////
// Check if the mouse is in the UI region,
// if so disable the camera rotation
/////////////////////////////////////////////////////////////

boolean isMouseLocationOnUI(){
  if(mouseX > uiPosX && mouseX < (uiPosX + uiWidth) && mouseY > uiPosY && mouseY < (uiPosY + uiHeight)){
    return true;
  } else {
    return false;
  }
}

void mousePressed(){
  if(isMouseLocationOnUI()){
    cam.setActive(false);
  }else{
    cam.setActive(true);
  }
}

/////////////////////////////////////////////////////////////
// Keybinds and key presses for various functions
/////////////////////////////////////////////////////////////

void keyPressed(){
  if(key == ' ' && balls[cueBall].ballInHole == false){
    hitCueBall();
  }
  
  if(key == 'r' || key == 'R'){
    resetTable();
  }
  
  if(keyCode == UP && keyPressed && balls[cueBall].ballInHole == false){
    balls[cueBall].velocity = new PVector(0,-cueBallForce);
  } else if(keyCode == DOWN && keyPressed){
    balls[cueBall].velocity = new PVector(0,cueBallForce);
  } else if(keyCode == LEFT && keyPressed){
    balls[cueBall].velocity = new PVector(-cueBallForce,0);
  } else if(keyCode == RIGHT && keyPressed){
    balls[cueBall].velocity = new PVector(cueBallForce,0);
  }
}

void keybinds(){
  
  if((key == 'd' || key == 'D') && keyPressed && balls[cueBall].ballInHole == false){
    cueBallVisualVector.rotate(0.025f);
  }
  
  if((key == 'a' || key == 'A') && keyPressed && balls[cueBall].ballInHole == false){
    cueBallVisualVector.rotate(-0.025f);
  }
}
