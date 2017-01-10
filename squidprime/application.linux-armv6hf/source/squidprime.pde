import netP5.*;
import oscP5.*;

// Some real-time FFT! This visualizes music in the frequency domain using a
// polar-coordinate particle system. Particle size and radial distance are modulated
// using a filtered FFT. Color is sampled from an image.

import ddf.minim.analysis.*;
import ddf.minim.*;

OPC opc;
PImage dot;
PImage colors;
Minim minim;
AudioInput in;
FFT fft;
float[] fftFilter;

OscP5 osc;
float red, green, blue;

float spin = 0.001;
float radiansPerBucket = radians(2);
float decay = 0.96;
float opacity = 70;
float minSize = 0.1;
float sizeScale = 0.6;

void setup()
{
  size(280, 280, P3D);
  osc = new OscP5(this, 10000);
  osc.plug(this, "redMangler", "/mrmr/slider/horizontal/0/jedermann");
  osc.plug(this, "greenMangler", "/mrmr/slider/horizontal/1/jedermann");
  osc.plug(this, "blueMangler", "/mrmr/slider/horizontal/2/jedermann");
  
  red = 1;
  green = 1;
  blue = 1;
  

  minim = new Minim(this); 

  // Small buffer size!
  in = minim.getLineIn();

  fft = new FFT(in.bufferSize(), in.sampleRate());
  fftFilter = new float[fft.specSize()];

  dot = loadImage("dot.png");
  colors = loadImage("colors.purples.png");

  // Connect to the local instance of fcserver
  opc = new OPC(this, "127.0.0.1", 7890);
//  opc.setColorCorrection(gamma, red, green, blue);
    opc.setColorCorrection(1.9, red, green, blue);
  
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
       println(address);
     }  
   }
  
  //Noodle starburst is simpler 
  int strips, startString, ledsPerStrip;
  startString = 2;
  strips = 6; //number of strips/lines
  ledsPerStrip = 50; //number of pixels in each line
  rad = 35; // inner (empty) radius
  separation = 2; //distance between each pixel
  
  for (int i=startString; i<(startString + strips); i++) {
     for (int j=0; j<ledsPerStrip; j++) {
       
       opc.led(i*64+j, int(sin(radians(i*360/strips))*(rad+j*separation))+width/2, int(cos(radians(i*360/strips))*(rad+j*separation))+height/2);
     }
  }
   
   
}

void draw()
{
  background(0);

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
  opc.setColorCorrection(1.9, red, green, blue);
  println(red + " " + green + " " + blue);
}
void greenMangler(float g) {
  green = g;
  opc.setColorCorrection(1.9, red, green, blue);
  println(red + " " + green + " " + blue);
}
void blueMangler(float b) {
  blue = b;
  opc.setColorCorrection(1.9, red, green, blue);
  println(red + " " + green + " " + blue);
}
  
  