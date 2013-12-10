// --------------------------- definition of Screen class ----------------------
class Screen
{
  int rolling = 0;
  int oldcurve = 5000;
  int newcurve = 5000;
  boolean activity_curve_enabled = true;
  
  Screen(int x, int y) {
    // size(x, y, OPENGL);
    size(x, y, OPENGL);
  }
  
  void display_activity_curve() {
    if(activity_curve_enabled) {
      stroke(NEURON_COLOR, 200);
      strokeWeight(3);
      newcurve = int(height*0.9-3*fired+0*(random(5)-3));
      line(rolling, oldcurve, rolling+3, newcurve);
      oldcurve = newcurve;
      fill(#FFFFFF,50);
      noStroke();
      ellipseMode(CENTER);
      ellipse(rolling+3, newcurve, 10, 10);

      rolling = (rolling+3)%width;
    }
  }
  
  boolean toogle_activity_curve() {
    if(activity_curve_enabled) {
      activity_curve_enabled = false;
    } else {
      activity_curve_enabled = true;
      rolling = 0;
    }
    
    return activity_curve_enabled;
  }
  
  void display_current_time() {
    fill(#FFFFFF,100);
    textAlign(LEFT, CENTER);
    text(str(int(actual_time))+" ms", 30, height/2);
  }
  
  void simple_blenddown(int alpha) {
    noStroke();
    if(!randomize_colors) {
      fill(BACKGROUND_COLOR, alpha);
    } else {
      fill(color(#000000), alpha);
    }
    rect(0, 0, width, height);
  }
  
  void better_blenddown() {
    simple_blenddown(10);
    noStroke();
    ellipseMode(CENTER);
    for (i=0; i<20; i++) {
      fill(BACKGROUND_COLOR, 5);
      ellipse(int(random(width)), int(random(height)), int(random(nradius*50)), int(random(nradius*50)));
    }
  }
  
}
