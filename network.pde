// --------------------------- definition of Network class ----------------------
class Network
{
  int size;
  Neuron[] neurons;
  int[] cfrom;
  int[] cto;
  
  Network(int s)
  {
    size = s;
    // allocate memory
    neurons = new Neuron[size];
    for (i=0; i<this.size; i++) {
      neurons[i] = new Neuron();
    }
    
    cfrom = new int[size];
    cto = new int[size];
  }
  
  Neuron node(int index)
  {
    return neurons[index];
  }
  
  void load_cell_positions_from_file(String filename)
  {
    String[] input = loadStrings(filename);
    if (input==null) exit();

    for (i=0; i<size; i++) {
      neurons[i].set_2D_position( round(float(input[2*i])*(width-2*border))+border,
        round(float(input[2*i+1])*(height-2*border)+border) );
    }
  }
  
  void load_connections_from_file(String filename)
  {
    String[] cinput = loadStrings(filename);
    if (cinput==null) exit();

    for (i=0; i<size; i++) {
      cfrom[i] = int(cinput[3*i])-1;
      cto[i] = int(cinput[3*i+1])-1;
    }
  }
  
  // void assemble_cell_sprites()
  // {
  //   // set internal connection arrays and create PGraphics shapes
  //   for (i=0; i<size; i++) {
  //     int[] x2s = new int[0];
  //     int[] y2s = new int[0];
  //     for (j=0; j<size; j++) {
  //       if ((cfrom[j]==i)&&(random(1.0)<FRACTION_OF_CONNECTIONS_SHOWN)) {
  //         x2s = append(x2s, neurons[cto[j]].getPosX());
  //         y2s = append(y2s, neurons[cto[j]].getPosY());
  //       }
  //     }
  //   }
  // }
  
  void give_me_a_ping_vasily()
  {
    for (i=0; i<size; i++) {
      neurons[i].blink();
    }
  }
  
}
