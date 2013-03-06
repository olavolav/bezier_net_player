import processing.opengl.*;

/* import processing.video.*;
MovieMaker mm;  // Declare MovieMaker object
boolean record_movie = false; */

import ddf.minim.*;
Minim minim;
AudioSample[] click = new AudioSample[2];

color NEURON_COLOR = #EFF7CF;
color BACKGROUND_COLOR = #044304;
// color BACKGROUND_COLOR = #000000;
int NUMBER_OF_NEURONS = 100;
int NUMBER_OF_CONNECTIONS = 1209;
int fired = 0;
float nradius;
float nblurradius;
int blinkpixels = 20;
int border = 10;

int rolling = 0;
int oldcurve = 5000;
int newcurve = 5000;

int sound;
long frame_counter = 0;
int FRAMES_PER_SECOND = 15;
float MS_PER_FRAME = 10.0;
// float MS_PER_FRAME = 1000./float(FRAMES_PER_SECOND); // display in real time;
float actual_time = 0.0;

String SPIKE_INDEX_FILENAME = "/Users/olav/Desktop/Doktorarbeit/Causality/multi-topologies/Middle/LambdasAdaptive/s_index_net1_cc0_p0_w0.dat";
String SPIKE_TIMES_FILENAME = "/Users/olav/Desktop/Doktorarbeit/Causality/multi-topologies/Middle/LambdasAdaptive/s_times_net1_cc0_p0_w0.dat";
SpikeInput reader;
int current_spike_index;

boolean displayactivitycurve = true;
boolean act_as_drum_machine = false;
boolean randomize_colors = false;

float FRACTION_OF_CONNECTIONS_SHOWN = 0.66;
float SCALE_FACTOR_OF_AXON_LENGTH = 0.33;

int i, j, k;
Neuron n1, n2;
Neuron[] net = new Neuron[NUMBER_OF_NEURONS];
int[] cfrom = new int[NUMBER_OF_CONNECTIONS];
int[] cto = new int[NUMBER_OF_CONNECTIONS];
boolean[] has_fired_in_this_frame = new boolean[NUMBER_OF_NEURONS];
// PGraphics noise_image;

void setup()
{
  frameRate(FRAMES_PER_SECOND);
  strokeWeight(8);
  
  textFont(createFont("LucidaGrande", 26));
  textAlign(CENTER, CENTER);
  // size(screen.width, screen.height, OPENGL);
  size(1280, 720, OPENGL);
  nradius = width/150.0;
  nblurradius = width/250.0;
  smooth();
  background(BACKGROUND_COLOR);

  /* println("initializing movie for export ...");
  mm = new MovieMaker(this, width, height, "/Users/olav/Desktop/bezier_net1.mov", 15); */
  
  minim = new Minim(this);
  // this loads mysong.wav from the data folder
  click[0] = minim.loadSample("../drums/Djemba 004.wav");
  // click[1] = minim.loadSample("../drums/Conga 001.wav");
  // click[2] = minim.loadSample("../drums/Human Clap 001.wav");
  // click[3] = minim.loadSample("../drums/Gabba Kick 001.wav");
  click[1] = minim.loadSample("../drums/Metalic Kick 001.wav");
  
  reader = new SpikeInput(SPIKE_INDEX_FILENAME, SPIKE_TIMES_FILENAME);
  
  // load positions
  // String path = selectFolder("Please choose path to network parameters");
  String path = "./";
  println("loading "+path+"pos_processing.txt ...");
  String[] input=loadStrings(path+"pos_processing.txt");
  
  for (i=0; i<NUMBER_OF_NEURONS; i++)
    net[i] = new Neuron(round(float(input[2*i])*(width-2*border))+border,
      round(float(input[2*i+1])*(height-2*border)+border));

  // load connections
  println("loading "+path+"cons_processing.txt ...");
  String[] cinput=loadStrings(path+"cons_processing.txt");
  if (cinput==null) exit();
  
  for (i=0; i<NUMBER_OF_CONNECTIONS; i++) {
    cfrom[i] = int(cinput[3*i])-1;
    cto[i] = int(cinput[3*i+1])-1;
  }

  // set internal connection arrays and create PGraphics shapes
  println("creating cell sprites ...");
  for (i=0; i<NUMBER_OF_NEURONS; i++) {
    int[] x2s = new int[0];
    int[] y2s = new int[0];
    for (j=0; j<NUMBER_OF_CONNECTIONS; j++) {
      if ((cfrom[j]==i)&&(random(1.0)<FRACTION_OF_CONNECTIONS_SHOWN)) {
        x2s = append(x2s, net[cto[j]].getPosX());
        y2s = append(y2s, net[cto[j]].getPosY());
      }
    }
    net[i].create_cell_shape(x2s, y2s, NEURON_COLOR);
  }
  println("creating noise sprites ...");
  for (i=0; i<NUMBER_OF_NEURONS; i++) {
    net[i].create_noise_shape(width/5,height/5); //(400,400);
  }
  for (i=0; i<NUMBER_OF_NEURONS; i++) {
    net[i].blink();
  }

  // println("creating noise pattern ...");
  // noise_image = create_noise_shape(width/10,height/10);
  
  println("go!");
}


// -------------------------------------------------- main loop: start --------------------------------------------------

void draw()
{
  // better_blenddown();
  simple_blenddown(3+3);

  frame_counter += 1;
  actual_time = frame_counter*MS_PER_FRAME;
  
  // net[int(frame_counter % NUMBER_OF_NEURONS)].display();

  // clear firing history of this frame
  fired = 0;
  for (i=0; i<NUMBER_OF_NEURONS; i++) {
    has_fired_in_this_frame[i] = false;
  }
  
  // see if one or more neurons have spiked and if so, let them blink
  while( (current_spike_index = reader.get_next_spike_index(actual_time)) != -1 ) {
    // neuron fires now!
    if(!has_fired_in_this_frame[current_spike_index]) {
      net[current_spike_index].blink();
      has_fired_in_this_frame[current_spike_index] = true;
      fired++;
    }
    // play drum machine!
    if ((fired>0) && act_as_drum_machine) {
      sound = 0;
      if (fired>3) sound = 1;
      // if (fired>6) sound = 2;
      // if (fired>10) sound = 3;
      click[sound].trigger();
    }
  }
  
  // display activity
  if(displayactivitycurve)
  {
    stroke(NEURON_COLOR, 200);
    strokeWeight(3);
    newcurve = int(height*0.9-3*fired+0*(random(5)-3));
    line(rolling, oldcurve, rolling+3, newcurve);
    oldcurve = newcurve;

    fill(#FFFFFF,50);
    noStroke();
    ellipseMode(CENTER);
    ellipse(rolling+3, newcurve, 10, 10);

  }
  rolling = (rolling+3)%width;

  // if (record_movie) mm.addFrame();  // Add window's pixels to movie
  
  // display current time
  fill(#FFFFFF,100);
  textAlign(LEFT, CENTER);
  text(str(int(actual_time))+" ms", 30, height/2);
}

// -------------------------------------------------- main loop: end --------------------------------------------------

void keyPressed()
{
  // fill(0, 102, 153);
  fill(#FFFFFF);
  textAlign(CENTER, CENTER);
  switch(key)
  {
    case ' ':
      if (displayactivitycurve)
        text("display activity curve: off", width/2, height/2);
      else text("display activity curve: on", width/2, height/2);
      displayactivitycurve = !displayactivitycurve;
      rolling = 0;
      break;
    /* case 's':
      if (record_movie) {
        mm.finish();
        text("recording: stopped", width/2, height/2);
      }
      record_movie = false;
      break; */
    case 'd':
      if (act_as_drum_machine)
        text("drums: off", width/2, height/2);
      else text("drums: on", width/2, height/2);
      act_as_drum_machine = !act_as_drum_machine;
      break;
    case 'c':
      text("switch colors", width/2, height/2);
      randomize_colors = !randomize_colors;
      break;
    default:
      text("non-functional key pressed", width/2, height/2);
  }
}


void simple_blenddown(int alpha)
{
  noSmooth();
  noStroke();
  if(!randomize_colors) {
    fill(BACKGROUND_COLOR, alpha);
  } else {
    fill(color(#000000), alpha);
  }
  rect(0, 0, width, height);
  smooth();
}


void stop()
{
  click[0].close();
  click[1].close();
  // click[2].close();
  // click[3].close();
  minim.stop();
 
  super.stop();
}