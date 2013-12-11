// --------------------------- definition of Controller class ----------------------
class Controller
{
  float real_time_in_MS = 0.0;
  
  void update() {
    real_time_in_MS = float(frameCount) * MS_PER_FRAME;
  }
  
}
