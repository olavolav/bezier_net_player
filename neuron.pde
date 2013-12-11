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
  float calcium_concentration_at_dye = 0.0;
  
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
    calcium_concentration_at_dye += CALCIUM_AT_DYE_CHANGE_ON_ACTION_POTENTIAL;
  }
  
  float calcium_fluorescence() { // unit-less
    // saturating Hill function
    return calcium_concentration_at_dye/(calcium_concentration_at_dye + SATURATING_CALCIUM_AT_DYE_CONCENTRATION);
  }
  
  void update() {
    calcium_concentration_at_dye *= (1.0 - MS_PER_FRAME/CALCIUM_UNBINDING_TIME_SCALE);
  }
  
}
