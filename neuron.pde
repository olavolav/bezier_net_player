// --------------------------- definition on Neuron class ----------------------
class Neuron
{
  int posx, posy;
  float deviatex, deviatey;
  // float relaxtime;
  // float pot;
  PGraphics cell, noise_image;
  int[] out_connections;
  // offset for displaying sprite
  int x_offset, y_offset;
  int x_sprite_dim, y_sprite_dim;
  float noise_scaling_factor = 2.0;
  
  Neuron(int posxtemp, int posytemp)
  {
    posx = posxtemp;
    posy = posytemp;
    // relaxtime = 100;
    // pot = random(0.9);
    deviatex = deviatey = 0.0;
    cell = null;
    noise_image = null;
    out_connections = null;
    x_offset = y_offset = 0;
    x_sprite_dim = y_sprite_dim = 0;
  }
  
  void setPos(int posxtemp, int posytemp)
  {
    posx = posxtemp;
    posy = posytemp;
    deviatex = deviatey = 0.0;
  }
  
  int getPosX()
  { return posx+int(deviatex); }
  
  int getPosY()
  { return posy+int(deviatey); }

  void setConnections(int[] cons)
  { out_connections = cons; }

  int[] getConnections()
  { return out_connections; }

  void display() {
    fill(passive_neuron_color,4);
    noStroke();
    ellipseMode(CENTER);
    deviatex = random(nblurradius) - nblurradius/2;
    deviatey = random(nblurradius) - nblurradius/2;
    ellipse(posx+int(deviatex), posy+int(deviatey), nradius*(random(1.0)+0.5), nradius*(random(1.0)+0.5));

    imageMode(CORNER);
    smooth();
    tint(passive_neuron_color,4);
    image(cell,posx+x_offset+deviatex,posy+y_offset+deviatey);
  }
  
  void blink()
  {
    imageMode(CORNER);
    if(!randomize_colors) {
      tint(neuron_color,100);
    } else {
      colorMode(HSB, 100);
      // tint(round(random(100)),100,100);
      tint(int(100.*float(posx)/screen.width),50,100,100);
      fill(int(100.*float(posx)/screen.width),100,100,10);
      colorMode(RGB, 255);
    }
    smooth();
    image(cell,posx+x_offset+deviatex,posy+y_offset+deviatey);

    if(randomize_colors) {
      ellipseMode(CENTER);
      noSmooth();
      // fill(neuron_color,10);
      noStroke();
      ellipse(posx+int(deviatex), posy+int(deviatey), 5*nradius*(random(1.0)+0.5), 5*nradius*(random(1.0)+0.5));
      ellipse(posx+int(deviatex), posy+int(deviatey), 10*nradius*(random(1.0)+0.5), 10*nradius*(random(1.0)+0.5));
      ellipse(posx+int(deviatex), posy+int(deviatey), 20*nradius*(random(1.0)+0.5), 20*nradius*(random(1.0)+0.5)); 
      // ellipse(posx+int(deviatex), posy+int(deviatey), 7, 7); // middle of neuron
    }
    
    // imageMode(CENTER);
    noSmooth();
    // 1. outer copy
    image(noise_image, posx+deviatex+noise_scaling_factor*x_offset, posy+deviatey+noise_scaling_factor*y_offset, noise_scaling_factor*noise_image.width, noise_scaling_factor*noise_image.height);
    // 2. inner copy
    // tint(color(#ffffff),100);
    // image(noise_image,posx+x_offset+deviatex,posy+y_offset+deviatey);

    smooth();
    noTint();
  }

  void create_cell_shape(int[] x2s, int[] y2s, color bg)
  {
    float min_balance = 5;
    int nr_connections = x2s.length;

    // first, add missing random connections if there are less than 3 present
    int sign;
    while(nr_connections < 2) {
      // println ("adding a connection.");
      if (random(1.0)>0.5) sign = -1;
      else sign = 1;
      // the following works because Java is call-by-value
      x2s = append(x2s, posx+sign*int(random(25,50)));

      if (random(1.0)>0.5) sign = -1;
      else sign = 1;
      y2s = append(y2s, posy+sign*int(random(25,50)));

      nr_connections++;
    }

    // second, add counter connection such that the cell position itself
    // is part of the final polygon (if there is no balance already)
    int xsum = 0;
    int ysum = 0;
    for (int i=0; i<nr_connections; i++) {
      xsum += x2s[i]-posx;
      ysum += y2s[i]-posy;
    }
    xsum /= nr_connections;
    ysum /= nr_connections;
    if ((abs(xsum)>min_balance)||(abs(ysum)>min_balance)) {
      x2s = append(x2s, posx+(-1)*xsum);
      y2s = append(y2s, posy+(-1)*ysum);
      nr_connections++;
      // println ("adding a connection for balancing.");
    }

    // third, sort the connections by angle 
    int[] x2sorted = new int[0];
    int[] y2sorted = new int[0];

    int lastindex = 0;
    int closestindex = 0;
    float closestangle;
    float actualangle;
    // leave first connection in place
    x2sorted = append(x2sorted,x2s[0]);
    y2sorted = append(y2sorted,y2s[0]);
    for (int i=1; i<nr_connections; i++)
    {
      closestangle = TWO_PI;
      for (int j=1; j<nr_connections; j++)
      {
        if (j!=lastindex)
        {
          actualangle = out_angle(posx,posy,x2s[lastindex],y2s[lastindex])-out_angle(posx,posy,x2s[j],y2s[j]);
        if (actualangle<0) actualangle += TWO_PI;

          if (actualangle<closestangle)
          {
            closestangle = actualangle;
            closestindex = j;
          }
        }
      }
      x2sorted = append(x2sorted,x2s[closestindex]);
      y2sorted = append(y2sorted,y2s[closestindex]);
      lastindex = closestindex;
    }


    // now, actually begin to draw the cell shape
    x_sprite_dim = max(posx,max(x2sorted)) - min(posx,min(x2sorted)) + 1;
    y_sprite_dim = max(posy,max(y2sorted)) - min(posy,min(y2sorted)) + 1;
    x_offset = min(posx,min(x2sorted)) - posx;
    y_offset = min(posy,min(y2sorted)) - posy;
    int ximageshift = min(posx,min(x2sorted));
    int yimageshift = min(posy,min(y2sorted));
    
    try {
      cell = createGraphics(x_sprite_dim,y_sprite_dim,JAVA2D);
    } catch(OutOfMemoryError E) {
      println("Unable to reserve more memory for node shape. Exiting.");
      exit();
    }
      
    cell.beginDraw();

    cell.smooth();
    cell.noStroke();
    cell.fill(#FFFFFF);

    // draw actual cell shape (assuming connections>2)
    cell.beginShape(POLYGON);
    cell.vertex((1-scale_axon_length)*posx+scale_axon_length*x2sorted[0]-ximageshift, (1-scale_axon_length)*posy+scale_axon_length*y2sorted[0]-yimageshift);
    for (int i=0; i<nr_connections-1; i++)
      cell.bezierVertex(posx-ximageshift, posy-yimageshift, posx-ximageshift, posy-yimageshift, (1-scale_axon_length)*posx+scale_axon_length*x2sorted[i+1]-ximageshift, (1-scale_axon_length)*posy+scale_axon_length*y2sorted[i+1]-yimageshift);
    cell.bezierVertex(posx-ximageshift, posy-yimageshift, posx-ximageshift, posy-yimageshift, (1-scale_axon_length)*posx+scale_axon_length*x2sorted[0]-ximageshift, (1-scale_axon_length)*posy+scale_axon_length*y2sorted[0]-yimageshift);
    
    // cell.filter(BLUR,6);

    cell.endShape(CLOSE);

    cell.endDraw();

    // return cell;
  }
  
  void create_noise_shape(int xdim, int ydim)
  {
    // 1st version: Gaussian kernel
    // noise_image = createGraphics(xdim,ydim,JAVA2D);
    // noise_image.beginDraw();
    // noise_image.noSmooth();
    // for (int i=0; i<=xdim; i++)
    //   for (int j=0; j<=xdim; j++) {
    //       noise_image.set(i,j,color(neuron_color,int(random(255.0 * (float)(Math.exp(-Math.pow( Math.sqrt(Math.pow(i-xdim/2,2)+Math.pow(j-ydim/2,2))/(xdim/6),2 )))))));
    //   }
    // noise_image.endDraw();
    
    // 2nd version: blurred copy of cell shape
    try {
      noise_image = createGraphics(cell.width,cell.height,P2D);
    } catch(OutOfMemoryError E) {
      println("Unable to reserve more memory for noise shape. Exiting.");
      exit();
    }
    
    noise_image.loadPixels();
    arrayCopy(cell.pixels, noise_image.pixels);
    noise_image.updatePixels();
    noise_image.filter(BLUR,4);
    // since the blur filter is buggy (transparent->black), reset alpha values
    noise_image.loadPixels();
    for(int i=0; i<noise_image.width*noise_image.height; i++) {
      noise_image.pixels[i] = color(#FFFFFF,int(brightness(noise_image.pixels[i])));
    }
    noise_image.updatePixels();
    noise_image.endDraw();
  }
  
}

void better_blenddown()
{
  simple_blenddown(10);

  noStroke();
  noSmooth();

  ellipseMode(CENTER);
  for (i=0; i<20; i++)
  {
    fill(background_color, 5);
    ellipse(int(random(width)), int(random(height)), int(random(nradius*50)), int(random(nradius*50)));
  }

  smooth();
}
