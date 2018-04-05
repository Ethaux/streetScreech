// Street Screech Retro Game
// LMC 4725

PImage map;
PImage car;
int carX = 0;
int carY = 0;

void setup() {
  size(900,800);
  
  // load images
  map = loadImage("map1.png");
  car = loadImage("Ferrari.png"); //main car sprite
  
  carX = width/2 - 17;
  carY = height - car.height;
}

void draw() {
  image(map,0,0); //first level bg
  image(car, carX, carY);
  controls();
}

//change controls from mouse to voice
void controls() {
  if (mousePressed) {
    carY--;
  }
}