import oscP5.*;
import netP5.*;

import processing.video.*;

OscP5 osc;
NetAddress receiver;
int recv_port = 32323;

int num_movies = 3;

String[] file_src = {
  "candycutscaled.mp4",
  "helterskeltyscaled.mp4",
  "afropresentisscaled.mp4"
};

Boolean movie_init = false;
Boolean[] playing = new Boolean[num_movies];
int[] mov_tint = new int[num_movies];

Movie[] movies = new Movie[num_movies];

float[] topleft_x = new float[num_movies];
float[] topleft_y = new float[num_movies];

float max_vol = 0.25;
float vid_width;
float vid_height;
float aspect_rto = 0.75;

int per_row = 2; //vids per row

void setup()
{

  float start_y; // y_coord to start video grid
 size(640,480);
 frameRate(24);
 
  osc = new OscP5( this , recv_port );
  receiver = new NetAddress( "127.0.0.1" , recv_port );

 
 vid_width = width/float(per_row);
 vid_height = vid_width *  aspect_rto;
 start_y = height/2.0 - vid_height;


 for(int i = 0; i < num_movies; i++)
 {
   int cur_row = int(i / per_row);
   int cur_col = i  % per_row;

   topleft_x[i] = cur_col * vid_width;
   topleft_y[i] = start_y + (cur_row * vid_height);
   playing[i] = false;
   mov_tint[i] = 0;

   // movie loading
   movies[i] = new Movie(this, file_src[i]);
   movies[i].speed(1.0);
   movies[i].volume(0.0);
   movies[i].speed(1.0);
   //movies[i].loop();
   movie_init = true;

 };


 
}

void draw()
{
  background(0);
  for(int i = 0; i < num_movies; i++)
  {
    Boolean is_playing = playing[i];
    if(is_playing == true)
    {
      float cur_x = topleft_x[i];
      float cur_y = topleft_y[i];
      int cur_tint = mov_tint[i];
      tint(255, cur_tint);
      image(movies[i], cur_x, cur_y, vid_width, vid_height);
    };
    

  };
}

void movieEvent(Movie m) {
  m.read();
}


float[] parse_osc(String cur_str)
{
   return float(split(cur_str, ",")); 
}


void set_video_params(int vid_idx, float play_float, float cur_x, float cur_y)
{
  
  if(vid_idx < movies.length)
  {

      Boolean want_playing = (play_float > 0.0) && (cur_x >= 0.0) && (cur_y >= 0.0);
      Boolean cur_playing = playing[vid_idx];
  
      if(want_playing)
      {
        float cur_rate = map(cur_x, 0.0, 1.0, 0.1, 2.0);
        float cur_vol = map(cur_y, 0.0, 1.0, 0.1, max_vol);
        int cur_tint = int(map(cur_y, 0.0, 1.0, 0.0, 255.0));
        if(!cur_playing)
        {
          playing[vid_idx] = true;
          movies[vid_idx].loop();
          println("playing: ", vid_idx);
        };
        movies[vid_idx].speed(cur_rate);
        movies[vid_idx].volume(cur_vol);
        mov_tint[vid_idx] = cur_tint;
      }
      else
      {
    
        if(cur_playing)
        {
          playing[vid_idx] = false;
          movies[vid_idx].noLoop();
          movies[vid_idx].stop();
        };
      };

  };
}

void oscEvent( OscMessage m ) {

  if (m.getTypetag( ).equals("s") && movie_init)
  {
    float[] cn = parse_osc(m.stringValue(0));
    if(m.getAddress().equals("/red"))
    {
      set_video_params(0, cn[0], cn[1], cn[2]);
    }
    else if(m.getAddress().equals("/blue"))
    {
      set_video_params(1, cn[0], cn[1], cn[2]);
    }
    else if(m.getAddress().equals("/purple"))
    {
    
    }
    else if(m.getAddress().equals("/green"))
    {
       set_video_params(2, cn[0], cn[1], cn[2]);
    };
  };
  //print( ", typetag: " + m.getTypetag( ) );
}
