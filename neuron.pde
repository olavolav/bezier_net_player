// --------------------------- definition of Neuron class ----------------------
class Neuron
{
  int posx, posy;
  PGraphics cell, noise_image;
  // offset for displaying sprite
  int x_offset, y_offset;
  int x_sprite_dim, y_sprite_dim;
  float noise_scaling_factor = 2.0;
  int frame_count_at_last_blinking = -1;
  
  Neuron() {
    posx = posy = 0;
    cell = null;
    noise_image = null;
    x_offset = y_offset = 0;
    x_sprite_dim = y_sprite_dim = 0;
  }
  
  void set_2D_position(int posxtemp, int posytemp) {
    posx = posxtemp;
    posy = posytemp;
  }
  
  void recieves_a_spike() {
    if(frame_count_at_last_blinking == frameCount) return;
    frame_count_at_last_blinking = frameCount;
    display.let_neuron_blink(this);
  }
  
}
