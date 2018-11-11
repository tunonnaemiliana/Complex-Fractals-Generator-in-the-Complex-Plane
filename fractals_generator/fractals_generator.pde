import interfascia.*;

//GLOBAL VARIABLES
int ITERATIONS = 100;
final float SAT = 0.8; 
final int COLORS = 17; 
float m=0;
final float ZOOMFACTOR = 2; // Bigger = more zoom
final int MAXZOOM = 17; // Set this higher to see the precision limit behaviour
boolean zoomEnabler=false;
boolean frameOptimizer = false;

// Some global variables to save our zoom state
boolean clickFlag = false; // Used to choose zoom origin
boolean spacebarFlag = false; // Used to zoom into the center
float rangeX = 5; // This is a good starting value to see the whole set
float rangeY; // Calculate the following during setup
float xmin; // x goes from xmin to xmax
float ymin;
float xmax;
float ymax; // y goes from ymin to ymax
int zoomStep = 0; // Keeps track of how many times we zoom

GUIController guiController;
IFTextField textField;
IFLabel ifLabel;
Button drawButton;
CloseButton exitButton;
boolean render=false;
float writtenPower=0;
PImage img;

void setup() {
  fullScreen();
  colorMode(HSB, COLORS);
  frameRate(300);
  rangeY = (rangeX * height) / width;
  resetXY();
  img = loadImage("img.png");
  guiController = new GUIController(this);
  textField = new IFTextField("Text Field", 25, 30, 150);
  ifLabel = new IFLabel("", 25, 70);
  drawButton = new Button(width-85,10);
  exitButton = new CloseButton(width-40,10);
  
  guiController.add(textField);
  guiController.add(ifLabel);
  
  textField.addActionListener(this);
}


void draw() {
  stroke(0,0,0);
  if(render){  
    loadPixels();
    
    // Using "else if" so we only process one at a time
  if (clickFlag && (mouseButton == LEFT)) {
    float clickX = map(mouseX, 0, width, xmin, xmax);
    float clickY = map(mouseY, 0, height, ymin, ymax);
    zoom(clickX, clickY);
    clickFlag = false;
    frameOptimizer = false;
    
  }
  else if (clickFlag && (mouseButton == RIGHT)) {
    resetXY();
    clickFlag = false;
    frameOptimizer = false;
  }
  else if (spacebarFlag) {
    float zeroX = xmin + (xmax - xmin) / 2; // Find the current origin values
    float zeroY = ymin + (ymax - ymin) / 2;
    zoom(zeroX, zeroY); // Zoom into the center
    spacebarFlag = false;
    frameOptimizer = false;
  }
  if(!frameOptimizer){
    frameOptimizer = true;
    float dx = (xmax - xmin) / (width);
    float dy = (ymax - ymin) / (height);
    
    float y = ymin;
    for (int j = 0; j < height; j++) {
    // Start x
      float x = xmin;
      for (int i = 0; i < width; i++) {
        
      // Now we test, as we iterate z = z^2 + cm does z tend towards infinity?
        float modulus;
        float phase = arctan(x,y);
        float a = x;
        float b = y;
        int n=0;
        while (n < ITERATIONS) {
          modulus = sqrt(pow(a,2) + pow(b,2));
          phase = arctan (a,b);
          modulus = pow(modulus,writtenPower);
          phase *= writtenPower;
          if (modulus > 2) 
            break;  // Bail
          a=modulus*cos(phase) + x;
          b=modulus*sin(phase) + y;
          n++;          
        }

      // We color each pixel based on how long it takes to get to infinity
        if (n == ITERATIONS) {
          pixels[i+j*width] = color(0);
        } else {
          int c = n % COLORS ;
          pixels[i+j*width] = color(c, COLORS * SAT, COLORS);
        }
        x += dx;
      }
      y += dy;
    }
    updatePixels();
    }
  }else{
    stroke(0);
    textSize(16);
    if(m>=16)
      m=0;
    else 
      m+=0.02;
    background(m,127,127);
    image(img,width/4,height/2);
    drawButton.display();
  }
  //println(frameRate);
  exitButton.display();
}


void actionPerformed(GUIEvent e) {
  if (e.getMessage().equals("Completed")) {
    ifLabel.setLabel(textField.getValue());
    writtenPower=Float.valueOf(textField.getValue());
    frameOptimizer = false;
  }
}
  
float arctan(float a, float b){
  float processingIsStupid = b/a;
  if(a<0 && b>0 || a<0 && b<0){
    return PI + atan(processingIsStupid);
  } else{
  return atan(processingIsStupid);
  }
}

void zoom(float newOriginX, float newOriginY) {
  float zoomDiffX = (xmax - xmin) / (2 * ZOOMFACTOR); // We use these to determine new xy range
  float zoomDiffY = (ymax - ymin) / (2 * ZOOMFACTOR); // The 2 splits the zoom range in half to add to newOriginX/Y
  if (zoomStep <= MAXZOOM) {
    xmin = newOriginX - zoomDiffX;
    ymin = newOriginY - zoomDiffY;
    xmax = newOriginX + zoomDiffX;
    ymax = newOriginY + zoomDiffY;
    zoomStep++;
    println(zoomStep,"New range: [" + xmin + ", " + xmax + "], [" + ymin + ", " + ymax + "]");
  }
  else {
    println("Max zoom reached.");
  }
  
}

void resetXY() {
  xmin = -rangeX/2; // Start at negative half the width and height
  ymin = -rangeY/2;
  xmax = xmin + rangeX;
  ymax = ymin + rangeY;
  zoomStep = 0;
}

void mouseClicked() {
  if(zoomEnabler) {
    clickFlag = true;
  }
}

void keyPressed() {
  if (key == ' ') spacebarFlag = true;
  else if (key == 'z') zoomEnabler=true;
}
void keyReleased(){
  if (key == 'z') zoomEnabler=false;
}

void mousePressed() {
  if (exitButton.isClicked(mouseX, mouseY))
     exit();
  if (drawButton.isClicked(mouseX, mouseY))
    render = true;
}
