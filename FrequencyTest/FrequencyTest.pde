import beads.*;
AudioContext ac;
PowerSpectrum ps;
Frequency f;
Glide frequencyGlide;
WavePlayer wp;
float meanFrequency = 400.0;
color fore = color(255, 255, 255);
color back = color(0,0,0);

void setup()
{
  size(600,600);
  // set up the parent AudioContext object
  ac = new AudioContext();
  // set up a master gain object
  Gain g = new Gain(ac, 2, 0.5);
  ac.out.addInput(g);
  // get a microphone input unit generator
  UGen microphoneIn = ac.getAudioInput();
  // set up the WavePlayer and the Glide that will control 
  // its frequency
  frequencyGlide = new Glide(ac, 50, 10);
  wp = new WavePlayer(ac, frequencyGlide, Buffer.SINE);
  // connect the WavePlayer to the master gain
  g.addInput(wp);
  // In this block of code, we build an analysis chain
  // the ShortFrameSegmenter breaks the audio into short, 
  // discrete chunks.
  ShortFrameSegmenter sfs = new ShortFrameSegmenter(ac);
  // connect the microphone input to the ShortFrameSegmenter
  sfs.addInput(microphoneIn);
  // the FFT transforms that into frequency domain data
  FFT fft = new FFT();
  // connect the ShortFramSegmenter object to the FFT
  sfs.addListener(fft);
  // The PowerSpectrum turns the raw FFT output into proper 
  // audio data.
  ps = new PowerSpectrum();
  // connect the FFT to the PowerSpectrum
  fft.addListener(ps);
  // The Frequency object tries to guess the strongest
  // frequency for the incoming data. This is a tricky 
  // calculation, as there are many frequencies in any real 
  // world sound. Further, the incoming frequencies are 
  // effected by the microphone being used, and the cables 
  // and electronics that the signal flows through.
  f = new Frequency(44100.0f);
  // connect the PowerSpectrum to the Frequency object
  ps.addListener(f);
  // list the frame segmenter as a dependent, so that the 
  // AudioContext knows when to update it
  ac.out.addDependent(sfs);
  ac.start(); // start processing audio
}

// In the draw routine, we will write the current frequency 
// on the screen and set the frequency of our sine wave.
void draw()
{
  background(back);
  stroke(fore);
  // draw the average frequency on screen
  text(" Input Frequency: " + meanFrequency, 100, 100);
  // Get the data from the Frequency object. Only run this 
  // 1/4  frames so that we don't overload the Glide object 
  // with frequency changes.
  if( f.getFeatures() != null && random(1.0) > 0.75)
  {
    // get the data from the Frequency object
    float inputFrequency = f.getFeatures();
    // Only use frequency data that is under 3000Hz - this 
    // will include all the fundamentals of most instruments
    // in other words, data over 3000Hz will usually be 
    // erroneous (if we are using microphone input and 
    // instrumental/vocal sounds)
    if( inputFrequency < 3000)
    {
      // store a running average
      meanFrequency = (0.4 * inputFrequency) + 
      (0.6 * meanFrequency);
      // set the frequency stored in the Glide object
      frequencyGlide.setValue(meanFrequency);
    }
  }
}
