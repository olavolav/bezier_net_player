// --------------------------- definition of SpikeInput class ----------------------
class SpikeInput
{
  BufferedReader fileReaderSpikeIndex;
  BufferedReader fileReaderSpikeTimes;
  
  int last_spike_index, new_spike_index, temp_spike_index;
  float last_spike_time, new_spike_time;
  String lineIndex, lineTime;
  
  SpikeInput(String index_file, String times_file) {
    last_spike_time = -1.0;
    last_spike_index = 0;
    
    println("Opening spike data files...");
    fileReaderSpikeIndex = createReader(index_file);    
    fileReaderSpikeTimes = createReader(times_file);    
  }
  
  int get_next_spike_index(float end_time_of_frame) {
    //  if the last loaded spike is still not due
    if(last_spike_time > end_time_of_frame) {
      return -1;
    }
    
    // otherwise the spike is due, so we load the next spike before returning
    try {
      lineIndex = fileReaderSpikeIndex.readLine();
      new_spike_index = int(lineIndex);
      lineTime = fileReaderSpikeTimes.readLine();
      new_spike_time = float(lineTime);
    }
    catch (IOException e) {
      e.printStackTrace();
      // Stop because of an error or file is empty
      noLoop();
    }
    temp_spike_index = last_spike_index;
    // copy loaded spike to last_spike
    last_spike_index = new_spike_index;
    last_spike_time = new_spike_time;
    
    return temp_spike_index;
  }
  
}
