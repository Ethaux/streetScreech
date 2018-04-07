import processing.sound.*;

FFT fft;
AudioIn in;
int bands = 2048;
float[] spectrum = new float[bands];
int maxIndex = 0;
float max = 0.0;


void setup() {
  size(1024, 360);
  background(255);
  max = spectrum[0];
    
  // Create an Input stream which is routed into the Amplitude analyzer
  fft = new FFT(this, bands);
  in = new AudioIn(this, 0);
  
  // start the Audio Input
  in.start();
  
  // patch the AudioIn
  fft.input(in);
}      

void draw() { 
  background(255);
  fft.analyze(spectrum);
  max = spectrum[0];

  for(int i = 0; i < bands; i++){
    // The result of the FFT is normalized
    // draw the line for frequency band i scaling it up by 5 to get more amplitude.
    //line( i, height, i, height - spectrum[i]*height*5 );
    if(spectrum[i] > max) {
      max = spectrum[i];
      maxIndex = i;
    }
  }
  
  println(maxIndex*44100/1024);
}
