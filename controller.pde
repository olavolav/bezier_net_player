// --------------------------- definition of Controller class ----------------------
class Controller
{
  float real_time_in_MS = 0.0;
  
  void update() {
    real_time_in_MS = float(frameCount) * MS_PER_FRAME;
    
    for (i=0; i<NUMBER_OF_NEURONS; i++) {
      net.node(i).update();
    }
    
  }
  
}
