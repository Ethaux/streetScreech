import processing.sound.*;

FFT fft;
AudioIn in;
int bands = 2048;
float[] spectrum = new float[bands];
int maxIndex = 0;
float max = 0.0;


void setup() {
  size(1024, 360);
    
  // Create an Input stream which is routed into the Amplitude analyzer
  fft = new FFT(this, bands);
  in = new AudioIn(this, 0);
  
  // start the Audio Input
  in.start();
  
  // patch the AudioIn
  fft.input(in);
}      

void draw() { 
  fft.analyze(spectrum);
  max = spectrum[0];

  for(int i = 0; i < bands; i++){
    if(spectrum[i] > max) {
      max = spectrum[i];
      maxIndex = i;
    }
  }
  
  println(maxIndex*8000/1024);
}

// 818, 904, 3229
// 732, 1033, 1300-1500+
// 430, 600, 775 || 80, 101, 156
