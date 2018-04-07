// Street Screech Retro Game
// LMC 4725

import beads.*;
import processing.sound.*;
Amplitude amp;
AudioIn in;
AudioContext ac;
PFont f;

PImage map;
PImage car;
int carX = 0;
int carY = 0;

int click = 0;

void setup() {
  size(900,800);
  background(0);
  f = createFont("ArcadeClassic",16,true); // Helvetica, 16 point, anti-aliasing on
  
  // load images
  map = loadImage("map1.png");
  car = loadImage("Ferrari.png"); //main car sprite
  
  carX = width/2 - 17;
  carY = height - car.height;
  
  ////sound
  //ac = new AudioContext();
  //// get an AudioInput UGen from the AudioContext
  //// this will setup an input from whatever input is your 
  //// default audio input (usually the microphone in)
  //// changing audio inputs in beads is a little bit janky (as
  //// of this writing)
  //// so it's best to change your default input temporarily, 
  //// if you want to use a different input
  //UGen microphoneIn = ac.getAudioInput();
  //// set up our usual master gain object
  //Gain g = new Gain(ac, 1, 0.5);
  //g.addInput(microphoneIn);
  //ac.out.addInput(g);
  //ac.start();
  
  amp = new Amplitude(this);
  in = new AudioIn(this, 0);
  in.start();
  amp.input(in);
  
}

void draw() {
  //going from start screen to first level
  if (click == 0) {
    startScreen();
  }
  else {
    firstLevel();
  }
  
  //click counter
  if (mousePressed) {
    click = 1;
  }
}

//change controls from mouse to voice
void controls() {
  // car moves forward
  //if (mousePressed) {
  //  carY--;
  //}
  
  //if car goes out of screen
  if (carY + car.height < 0) {
    //loops the car once out of screen
    carY = height;
  }
  
  String speedStr = nf(amp.analyze(), 0, 4);
  float speed = float(speedStr) * 10;
  println(speed);
  carY = carY - int(speed);
  
  //int vOffset = 0;
  //for(int i = 0; i < width; i++)
  //{
  //  // for each pixel, work out where in the current audio 
  //  // buffer we are
  //  int buffIndex = i * ac.getBufferSize() / width;
  //  // then work out the pixel height of the audio data at 
  //  // that point
  //  vOffset = (int)((1 + ac.out.getValue(0, buffIndex)) *
  //  height / 2);
    
  //  //print(vOffset + ","); //debug
  //}
  
  ////moves car forward
  //if ((int) vOffset > 400) {
  //    carY = carY - 1;
  //}
}

void startScreen() {
  background(80);

  fill(0);
  rect(0, 200, width, 400); //black line for widescreen effect
  
  //main title
  textFont(f, 72);
  fill(255);
  text("Street Screech", width/2 - 260, height/2);
  
  //instruction
  textFont(f, 32);
  fill(255, 255, 0);
  text("Click   to   Start", width/2 - 120, height/2 + 75); //leave spacing
}

void firstLevel() {
  image(map, 0, 0); //first level bg
  image(car, carX, carY);
  controls();
}
