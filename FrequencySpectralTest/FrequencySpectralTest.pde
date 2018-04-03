import beads.*;
// how many peaks to track and resynth
int numPeaks = 32;
AudioContext ac;
Gain masterGain;
PowerSpectrum ps;
SpectralPeaks sp;
Gain[] g;
Glide[] gainGlide;
Glide[] frequencyGlide;
WavePlayer[] wp;
float meanFrequency = 400.0;
color fore = color(255, 255, 255);
color back = color(0,0,0);

void setup()
{
  size(600,600);
  // set up the parent AudioContext object
  ac = new AudioContext();
  // set up a master gain object
  masterGain = new Gain(ac, 2, 0.5);
  ac.out.addInput(masterGain);
  // get a microphone input unit generator
  UGen microphoneIn = ac.getAudioInput();
  frequencyGlide = new Glide[numPeaks];
  wp = new WavePlayer[numPeaks];
  g = new Gain[numPeaks];
  gainGlide = new Glide[numPeaks];
  for( int i = 0; i < numPeaks; i++ )
  {
    // set up the WavePlayer and the Glides that will control
    // its frequency and gain
    frequencyGlide[i] = new Glide(ac, 440, 1);
    wp[i] = new WavePlayer(ac,
    frequencyGlide[i], 
    Buffer.SINE);
    gainGlide[i] = new Glide(ac, 0.0, 1);
    g[i] = new Gain(ac, 1, gainGlide[i]);
    // connect the WavePlayer to the master gain
    g[i].addInput(wp[i]);
    masterGain.addInput(g[i]);
  }
  // in this block of code, we build an analysis chain
  // the ShortFrameSegmenter breaks the audio into short, 
  // discrete chunks
  ShortFrameSegmenter sfs = new ShortFrameSegmenter(ac);
  // connect the microphone input to the ShortFrameSegmenter
  sfs.addInput(microphoneIn);
  // the FFT transforms that into frequency domain data
  FFT fft = new FFT();
  // connect the ShortFramSegmenter object to the FFT
  sfs.addListener(fft);
  // the PowerSpectrum turns the raw FFT output into proper  
  // audio data
  ps = new PowerSpectrum();
  // connect the FFT to the PowerSpectrum
  fft.addListener(ps);
  // the SpectralPeaks object stores the N highest Peaks
  sp = new SpectralPeaks(ac, numPeaks);
  // connect the PowerSpectrum to the Frequency object
  ps.addListener(sp);
  // list the frame segmenter as a dependent, so that the 
  // AudioContext knows when to update it
  ac.out.addDependent(sfs);
  // start processing audio
  ac.start();
}

// in the draw routine, we will write the current frequency 
// on the screen and set the frequency of our sine wave
void draw()
{
  background(back);
  stroke(fore);
  text("Use the microphone to trigger resynthesis", 
  100, 100);
  // get the data from the SpectralPeaks object
  // only run this 1/4 frames so that we don't overload the 
  // Glide object with frequency changes
  if( sp.getFeatures() != null && random(1.0) > 0.5)
  {
    // get the data from the SpectralPeaks object
    float[][] features = sp.getFeatures();
    for( int i = 0; i < numPeaks; i++ )
    {
      if(features[i][0] < 10000.0) 
      frequencyGlide[i].setValue(features[i][0]);
      if(features[i][1] > 0.01) 
      gainGlide[i].setValue(features[i][1]);
      else gainGlide[i].setValue(0.0);
    }
  }
}
