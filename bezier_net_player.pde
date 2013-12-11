// command to run:
// $ processing-java --run --force --sketch=/Users/olav/Documents/Processing/bezier_net_player/ --output=/tmp/processing/

import processing.opengl.*;

/* import processing.video.*;
MovieMaker mm;  // Declare MovieMaker object
boolean record_movie = false; */

import ddf.minim.*;
Minim minim;
AudioSample[] click = new AudioSample[2];

color NEURON_COLOR = #EFF7CF;
// color BACKGROUND_COLOR = #044304;
color BACKGROUND_COLOR = #000000;
int NUMBER_OF_NEURONS = 100;
int NUMBER_OF_CONNECTIONS = 1209;
int fired = 0;
float nradius;
float nblurradius;
int blinkpixels = 20;
int border = 10;
int FONT_SIZE = 26;

String PATH_TO_NETWORK_INFO = "./";

int sound;
int FRAMES_PER_SECOND = 15;
float MS_PER_FRAME = 2*10.0;
// float MS_PER_FRAME = 1000./float(FRAMES_PER_SECOND); // display in real time;

float CALCIUM_AT_DYE_CHANGE_ON_ACTION_POTENTIAL = 50.0;
float SATURATING_CALCIUM_AT_DYE_CONCENTRATION = 300.0;
float CALCIUM_UNBINDING_TIME_SCALE = 1000.0; // in [ms]

Screen display;
Controller control;

String SPIKE_INDEX_FILENAME = "/Users/olav/Desktop/Doktorarbeit/Causality/multi-topologies/Middle/LambdasAdaptive/s_index_net1_cc0_p0_w0.dat";
String SPIKE_TIMES_FILENAME = "/Users/olav/Desktop/Doktorarbeit/Causality/multi-topologies/Middle/LambdasAdaptive/s_times_net1_cc0_p0_w0.dat";
SpikeInput reader;
int current_spike_index;

boolean displayactivitycurve = true;
boolean act_as_drum_machine = false;
boolean randomize_colors = false;

float FRACTION_OF_CONNECTIONS_SHOWN = 1.0;
float SCALE_FACTOR_OF_AXON_LENGTH = 0.5;

int i, j, k;
Network net;

void setup() {
  display = new Screen(800, 600);
  frameRate(FRAMES_PER_SECOND);
  strokeWeight(8);
  control = new Controller();
  
  textFont(createFont("LucidaGrande", FONT_SIZE));
  textAlign(CENTER, CENTER);

  nradius = width/sqrt(float(NUMBER_OF_NEURONS));
  nblurradius = width/250.0;
  noSmooth();
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
  
  net = new Network(NUMBER_OF_NEURONS);
  
  // load positions
  println("loading "+PATH_TO_NETWORK_INFO+"pos_processing.txt ...");
  net.load_cell_positions_from_file(PATH_TO_NETWORK_INFO+"pos_processing.txt");

  // load connections
  println("loading "+PATH_TO_NETWORK_INFO+"cons_processing.txt ...");
  net.load_connections_from_file(PATH_TO_NETWORK_INFO+"cons_processing.txt");

  println("go!");
}


// -------------------------------------------------- main loop: start --------------------------------------------------

void draw() {
  // display.better_blenddown();
  display.simple_blenddown(3*40);
  // display.clear();
  
  // clear firing history of this frame
  fired = 0;
  
  // see if one or more neurons have spiked and if so, let them blink
  while( (current_spike_index = reader.get_next_spike_index(control.real_time_in_MS)) != -1 ) {
    // neuron fires now!
    net.node(current_spike_index).recieves_a_spike();
    fired++;
    // play drum machine!
    if ((fired>0) && act_as_drum_machine) {
      sound = 0;
      if (fired>3) sound = 1;
      // if (fired>6) sound = 2;
      // if (fired>10) sound = 3;
      click[sound].trigger();
    }
  }

  display.draw_neurons();
  display.display_activity_curve();
  display.display_current_time();
  display.display_frame_rate();
  // if (record_movie) mm.addFrame();  // Add window's pixels to movie
  control.update();
}

// -------------------------------------------------- main loop: end --------------------------------------------------

void keyPressed() {
  // fill(0, 102, 153);
  fill(#FFFFFF);
  textAlign(CENTER, CENTER);
  switch(key)
  {
    case ' ':
      boolean new_state = display.toogle_activity_curve();
      if(new_state)
        text("display activity curve: on", width/2, height/2);
      else text("display activity curve: off", width/2, height/2);
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


void stop() {
  click[0].close();
  click[1].close();
  // click[2].close();
  // click[3].close();
  minim.stop();
 
  super.stop();
}
