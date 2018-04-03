// Audio_Input_01.pde
import beads.*;
AudioContext ac;

void setup() {
  size(800,800);
  ac = new AudioContext();
  // get an AudioInput UGen from the AudioContext
  // this will setup an input from whatever input is your 
  // default audio input (usually the microphone in)
  // changing audio inputs in beads is a little bit janky (as
  // of this writing)
  // so it's best to change your default input temporarily, 
  // if you want to use a different input
  UGen microphoneIn = ac.getAudioInput();
  // set up our usual master gain object
  Gain g = new Gain(ac, 1, 0.5);
  g.addInput(microphoneIn);
  ac.out.addInput(g);
  ac.start();
}

// draw the input waveform on screen
// this code is based on code from the Beads tutorials 
// written by Ollie Brown
void draw()
{
  background(0);
  loadPixels();
  //scan across the pixels
  for(int i = 0; i < width; i++)
  {
  // for each pixel, work out where in the current audio 
  // buffer we are
  int buffIndex = i * ac.getBufferSize() / width;
  // then work out the pixel height of the audio data at 
  // that point
  int vOffset = (int)((1 + ac.out.getValue(0, buffIndex)) *
  height / 2);
  //draw into Processing's convenient 1-D array of pixels
  pixels[vOffset * height + i] = color(255);
  }
  // paint the new pixel array to the screen
  updatePixels();
}
