import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.sound.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class game extends PApplet {

// Street Screech Retro Game
// LMC 4725

// Frequency Tests
// 80, 101, 156
// 54, 85, 257
// 85, 234, 367
// 125, 179, 671

//import beads.*;

Amplitude amp;
AudioIn in;
AudioIn fftIn;
FFT fft;
//AudioContext ac;
PFont f;

PImage map1;
PImage map2;
PImage map3;
PImage car;
PImage cow1;
PImage cow2;

//car position
int carXPos = 0;
int carYPos = 0;

//car speed
float carX = 0;
float carY = 0;
float carDirection = 0;
String speedStr = "";
float speed = 0.0f;

int bands = 2048;
float[] spectrum = new float[bands];
int maxIndex = 0;
float max = 0.0f;
int freq = 0;
int[] lowFreqGroup = {90, 120};
int[] highFreqGroup = {140, 210};
int[] usedFreqGroup = new int[2];

int click = 0;
int level;

public void setup() {
  
  background(0);
  f = createFont("ArcadeClassic",16,true); // Helvetica, 16 point, anti-aliasing on
  
  // load images
  map1 = loadImage("map1.png");
  map2 = loadImage("map2.png");
  map3 = loadImage("map3.png");
  car = loadImage("Ferrari.png"); //main car sprite
  cow1 = loadImage("cow1.png");
  cow2 = loadImage("cow2.png");
  
  carX = width/2 - 17;
  carY = height - car.height;
  carXPos = (int) carX;
  carYPos = (int) carY;
  
  usedFreqGroup[0] = 90;
  usedFreqGroup[1] = 130;
  
  level = 1;
  
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
  
  fft = new FFT(this, bands);
  amp = new Amplitude(this);
  in = new AudioIn(this, 0);
  in.start();
  fftIn = new AudioIn(this, 0);
  fftIn.start();
  amp.input(in);
  fft.input(fftIn);
}

public void draw() {
  //going from start screen to first level
  if (click == 0) {
    startScreen();
  }
  else {
    goToLevel();
  }
  
  //click counter
  if (mousePressed) {
    click = 1;
  }
}

//change controls from mouse to voice
public void controls() {  
  //Forward Speed
  speedStr = nf(amp.analyze(), 0, 4);
  speed = PApplet.parseFloat(speedStr) * 10;
  //println(speed);
  float xTemp = carX + speed*sin(radians(carDirection));
  float yTemp = carY - speed*cos(radians(carDirection));
  if(xTemp > 0 && xTemp < width) {
    carX = carX + speed*sin(radians(carDirection));
  }
  if(yTemp < height) {
    carY = carY - speed*cos(radians(carDirection));
  }
  
  //Rotation Speed
  fft.analyze(spectrum);
  max = spectrum[0];

  for(int i = 0; i < bands; i++){
    if(spectrum[i] > max) {
      max = spectrum[i];
      maxIndex = i;
    }
  }
  
  freq = maxIndex*8000/1024;
  //println(freq);
  
  if(freq <= usedFreqGroup[0] && freq >= 40) {
    carDirection -= 3;
  } else if(freq >= usedFreqGroup[1] && freq <= 700) {
    carDirection += 3;
  }
  
  //Draw the car
  pushMatrix();
  carXPos = (int) (carX + car.width/2);
  carYPos = (int) (carY + car.height/2);
  
  translate(carXPos, carYPos);
  rotate(radians(carDirection));
  image(car, -car.width/2, -car.height/2);
  popMatrix();
  
  //bounds of screen
  if (carYPos > height) {
    carYPos = height - car.height;
  } else if (carXPos < 0) {
    carXPos = 0;
  } else if (carXPos > width) {
    carXPos = width - car.height;
  } else if (carYPos < 0 && (carXPos < 400 || carXPos > 500)) {
    carYPos = 0;
  }
  
  
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

public void startScreen() {
  background(80);

  fill(0);
  rect(0, 200, width, 400); //black line for widescreen effect

  textAlign(CENTER);
  
  //main title
  textFont(f, 78);
  fill(255, 255, 0);
  text("Street Screech", width/2, height/2 - 80);
  
  //Frequency Group Control instruction
  textFont(f, 32);
  fill(255);
  //leave extra space between words for regular spacing
  text("Press  up  arrow  key  for  higher  voices", width/2, height/2 + 90);
  text("Press  down  arrow  for  lower  voices", width/2, height/2 + 130);
  
  //General instruction
  textFont(f, 50);
  fill(255, 255, 0); //yellow
  text("Click  to  Start", width/2, height/2 + 10); //leave spacing
}

public void goToLevel() {
  if (click == 1) {
    if(level == 1) {
      firstLevel();
    }
    
    if (carYPos < 0 && level == 1) {
      level++;
      secondLevel();
      
      carX = carX + car.width/2 + 55;
      carY = height - car.height;
    }
    
    if (carY > 0 && level == 2) {
      secondLevel();
    }
    
    if (carY < 0 && level == 2) {
      level++;
      thirdLevel();
      carX = 135;
      carY = height - car.height;
    }
    
    if (level == 3) {
      thirdLevel();
    }
  }
  
  println("CarX Pos: " + carXPos + ", CarY Pos: " + carYPos + ", Freq: " + freq);
}

public void firstLevel() {
  image(map1, 0, 0); //first level bg
  
  pushMatrix();
  carXPos = (int) (carX + car.width/2);
  carYPos = (int) (carY + car.height/2);
  
  translate(carXPos, carYPos);
  rotate(radians(carDirection));
  popMatrix();
  
  controls();
}

public void secondLevel() {
  image(map2, 0, 0);
  pushMatrix();
  carXPos = (int) (carX + car.width/2 + 90);
  carYPos = (int) (carY + car.height/2);
  
  translate(carXPos, carYPos);
  rotate(radians(carDirection));
  popMatrix();
  
  controls();

}

public void thirdLevel() {
  image(map3, 0, 0);
  
  pushMatrix();
  carXPos = (int) (carX + car.width/2 - 300);
  carYPos = (int) (carY + car.height/2);
  
  translate(carXPos, carYPos);
  rotate(radians(carDirection));
  popMatrix();
  
  controls();
}

public void win() {
  background(0);
  cow1.resize(300,200);
  image(cow1, width/2 - 150, height/2 - 200);
  
  textAlign(CENTER);
  
  textFont(f, 78);
  fill(255, 255, 0);
  text("You  Win!", width/2, height/2 + 120);
  
  textFont(f, 50);
  fill(255);
  text("You're  finally  home", width/2, height/2 + 200);
}

public void keyPressed() {
  if(keyCode == UP){
    usedFreqGroup[0] += 10;
    usedFreqGroup[1] += 10;
  } else if(keyCode == DOWN) {
    usedFreqGroup[0] -= 10;
    usedFreqGroup[1] -= 10;
  }
}
  public void settings() {  size(900,800); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "game" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
