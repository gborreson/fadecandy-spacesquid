import netP5.*;
import oscP5.*;

// Some real-time FFT! This visualizes music in the frequency domain using a
// polar-coordinate particle system. Particle size and radial distance are modulated
// using a filtered FFT. Color is sampled from an image.

import ddf.minim.analysis.*;
import ddf.minim.*;

PShader effect;
OPC opc;
PImage dot;
PImage colors;
Minim minim;
AudioInput in;
FFT fft;
float[] fftFilter;

OscP5 osc;

float spin = 0.001;
float spinMax = 0.003; // multiplier for OSC float
float bucketDegrees = 2;
float radiansPerBucket = radians(bucketDegrees); // 2 degrees
float decay = 0.975;
float decayRange = 0.05; // multiplier maximum subtracted from 1.0 by OSC float
float opacity = 70;
float opacityMax = 100; // multiplier for OSC float
float minSize = 0.2;
float minSizeMax = 0.5; // multiplier for OSC float
float sizeScale = 0.3;
float sizeScaleMax = 1;
float gain = -64.0;
float gainRange = 50;

float gamma = 2.5; //fadecandy default
float gammaMax = 5; // beyond 5 doesn't make much sense
float red = .7; // whitepoint red, 70% default to make less dazzling
float green = .7; // whitepoint green
float blue = .7; // whitepoint blue
float bgRed = 0; // background red
float bgGreen = 0; // background green
float bgBlue = 0; // background blue

void setup()
{
  size(280, 280, P3D);
  //frameRate(30);
  
  //effect = loadShader("effect.glsl");
  //effect.set("resolution", float(width), float(height));
  
  osc = new OscP5(this, 10000);
  osc.plug(this, "redMangler", "/red");
  osc.plug(this, "greenMangler", "/green");
  osc.plug(this, "blueMangler", "/blue");
  osc.plug(this, "gammaMangler", "/gamma");
  osc.plug(this, "opacityMangler", "/opacity");
  osc.plug(this, "decayMangler", "/decay");
  osc.plug(this, "minSizeMangler", "/minSize");
  osc.plug(this, "sizeScaleMangler", "/sizeScale");
  osc.plug(this, "bgRedMangler", "/bgRed");
  osc.plug(this, "bgGreenMangler", "/bgGreen");
  osc.plug(this, "bgBlueMangler", "/bgBlue");
  osc.plug(this, "gainMangler", "/gain");
  
  gamma = 2.5;
  gammaMax = 5; //multiplier for OSC float input 0-1 range
  red = .7;
  green = .7;
  blue = .7;
  
  
  

  minim = new Minim(this); 

  // Small buffer size!
  in = minim.getLineIn(Minim.MONO);
  in.setGain(gain);

  fft = new FFT(in.bufferSize(), in.sampleRate());
  fftFilter = new float[fft.specSize()];

  dot = loadImage("dot.png");
  colors = loadImage("colors.rainbow.png");

  // Connect to the local instance of fcserver
  opc = new OPC(this, "127.0.0.1", 7890);
//  opc.setColorCorrection(gamma, red, green, blue);
    opc.setColorCorrection(gamma, red, green, blue);
  
//  opc.ledGrid8x8(0 * 64, width * 1/8, height * 1/4, height/16, 0, true);
//  opc.ledGrid8x8(1 * 64, width * 3/8, height * 1/4, height/16, 0, true);
//  opc.ledGrid8x8(2 * 64, width * 5/8, height * 1/4, height/16, 0, true);
//  opc.ledGrid8x8(3 * 64, width * 7/8, height * 1/4, height/16, 0, true);
//  opc.ledGrid8x8(4 * 64, width * 1/8, height * 3/4, height/16, 0, true);
//  opc.ledGrid8x8(5 * 64, width * 3/8, height * 3/4, height/16, 0, true);
//  opc.ledGrid8x8(6 * 64, width * 5/8, height * 3/4, height/16, 0, true);
//  opc.ledGrid8x8(7 * 64, width * 7/8, height * 3/4, height/16, 0, true);
// opc.ledStrip(0, 50, 3*width/4, height/2, width / 140.0, 0, false);
//  opc.ledStrip(64, 50, 3*width/4, height/2 - 10, width / 140.0, 0, false);
//  opc.ledStrip(128, 50, 3*width/4, height/2 - 20, width / 140.0, PI/4, false);
//  opc.ledStrip(192, 50, 3*width/4, height/2 - 30, width / 140.0, 0, false);
//  opc.ledStrip(256, 50, 3*width/4, height/2 - 40, width / 140.0, 0, false);
//  opc.ledStrip(320, 50, 3*width/4, height/2 - 50, width / 140.0, 0, false);
//  opc.ledStrip(384, 50, 3*width/4, height/2 - 60, width / 140.0, 0, false);
//  opc.ledStrip(448, 50, 3*width/4, height/2 - 70, width / 140.0, 0, false);
  
  
  //Make a big ol' starburst of pixels radiating out from the centre
  int strings, ledsPerString, ledsPerSegment, segmentsPerString, segments, rad, separation;
  strings = 2; //number of LED strings
  ledsPerString = 50; //number of pixels in each string
  rad = 15; // inner (empty) radius
  separation = 4; //distance between each pixel, along radius
  segmentsPerString = 10; //Number of segments each string is broken into
  ledsPerSegment = ledsPerString / segmentsPerString; //So we know when to flip directions
  segments = strings * segmentsPerString; //Total segments
  
  boolean outward; //direction of mapping
  int stringNum; //string number starting with 0
  int ledCount = 0;
  int address;
   for (int i=0; i<segments; i++) { //one line per segment
     for (int j=0; j<ledsPerSegment; j++) {
       address = int(ledCount/ledsPerString)*64 + ledCount % ledsPerString;
       stringNum = int(ledCount/ledsPerString); //starts at zero, increments whenever ledCount exceeds ledsPerString
       if (i % 2 == 0) { //Even segment, drawn outward
         opc.led(address, int(sin(radians(i*360/segments))*(rad+j*separation))+width/2, int(cos(radians(i*360/segments))*(rad+j*separation))+height/2);         
       } else { //Odd segment, drawn inward
         int k=ledsPerSegment-j-1;
         opc.led(address, int(sin(radians(i*360/segments))*(rad+k*separation))+width/2, int(cos(radians(i*360/segments))*(rad+k*separation))+height/2);
       }
       ledCount++;
       println("centre " + address + " angle " + i*360/segments + " strip " + stringNum);
     }  
   }
   
   // for other half, again but offset half a rotation between strips
   for (int i=0; i<segments; i++) { //one line per segment
     for (int j=0; j<ledsPerSegment; j++) {
       address = int(ledCount/ledsPerString)*64 + ledCount % ledsPerString;
       stringNum = int(ledCount/ledsPerString); //starts at zero, increments whenever ledCount exceeds ledsPerString
       if (i % 2 == 0) { //Even segment, drawn outward
         opc.led(address, int(sin(radians((float(i)+0.5)*360/segments))*(rad+j*separation))+width/2, int(cos(radians((float(i)+0.5)*360/segments))*(rad+j*separation))+height/2);         
       } else { //Odd segment, drawn inward
         int k=ledsPerSegment-j-1;
         opc.led(address, int(sin(radians((float(i)+0.5)*360/segments))*(rad+k*separation))+width/2, int(cos(radians((float(i)+0.5)*360/segments))*(rad+k*separation))+height/2);
       }
       ledCount++;
       println("centre " + address + " angle " + (float(i)+0.5)*360/segments + " strip " + stringNum);
     }  
   }
  
  //Noodle starburst is simpler 
  int strips, startString, ledsPerStrip;
  startString = 4;
  strips = 8; //number of strips/lines
  ledsPerStrip = 50; //number of pixels in each line
  rad = 35; // inner (empty) radius
  separation = 2; //distance between each pixel
  
  for (int i=0; i< strips; i++) {
     for (int j=0; j<ledsPerStrip; j++) {
       address = int(ledCount/ledsPerString)*64 + ledCount % ledsPerString;
       stringNum = int(ledCount/ledsPerString);
       
       opc.led(address, int(sin(radians(i*360/strips))*(rad+j*separation))+width/2, int(cos(radians(i*360/strips))*(rad+j*separation))+height/2);
       println("noodle channel " + i + " address " + address + " angle " + i*360/strips  + " strip " + stringNum);
       ledCount++;
   }
  }
   
   
}

void draw()
{
  background(bgRed, bgGreen, bgBlue);

  //effect.set("time", millis() / 500.0);
  //effect.set("hue", float(millis()) % 10000 / 10000);  
  
  //shader(effect);
  //rect(0, 0, width, height);
  //resetShader();

  fft.forward(in.mix);
  for (int i = 0; i < fftFilter.length; i++) {
    fftFilter[i] = max(fftFilter[i] * decay, log(1 + fft.getBand(i)));
  }
 
  for (int i = 0; i < fftFilter.length; i += 3) {   
    color rgb = colors.get(int(map(i, 0, fftFilter.length-1, 0, colors.width-1)), colors.height/2);
    tint(rgb, fftFilter[i] * opacity);
    blendMode(ADD);
 
    float size = height * (minSize + sizeScale * fftFilter[i]);
    PVector center = new PVector(width * (fftFilter[i] * 0.2), 0);
    center.rotate(millis() * spin + i * radiansPerBucket);
    center.add(new PVector(width * 0.5, height * 0.5));
 
    image(dot, center.x - size/2, center.y - size/2, size, size);
  }
}

void oscEvent(OscMessage m) {
  println(m.addrPattern() + " , " + m.typetag());
}
void redMangler(float r) {
  red = r;
  opc.setColorCorrection(gamma, red, green, blue);
  println(red + " " + green + " " + blue);
}
void greenMangler(float g) {
  green = g;
  opc.setColorCorrection(gamma, red, green, blue);
  println(red + " " + green + " " + blue);
}
void blueMangler(float b) {
  blue = b;
  opc.setColorCorrection(gamma, red, green, blue);
  println(red + " " + green + " " + blue);
}
void gammaMangler(float g) {
  gamma = g * gammaMax;
  opc.setColorCorrection(gamma, red, green, blue);
  println("gamma " + gamma);
}
void opacityMangler(float o) {
  opacity = o * opacityMax;
  println("opacity " + opacity);
}
void minSizeMangler(float m) {
  minSize = m * minSizeMax;
  println("minSize " + minSize);
}
void sizeScaleMangler(float s) {
  sizeScale = s * sizeScaleMax;
  println("sizeScale " + sizeScale);
}  
void decayMangler(float d) {
  decay = 1.0 - (d * decayRange);
  println("decay " + decay);
}  
void bgRedMangler(float r) {
  bgRed = r * 255;
  println("bgRed " + bgRed);
}
void bgGreenMangler(float g) {
  bgGreen = g * 255;
  println("bgGreen " + bgGreen);
}
void bgBlueMangler(float b) {
  bgBlue = b * 255;
  println("bgBlue " + bgBlue);
}
void gainMangler(float g) {
  gain = -80.0 + g * gainRange;
  in.setGain(gain);
  println("gain " + gain);
}

  