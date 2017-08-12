
public void controlEvent(ControlEvent theEvent) 
{    
  if(theEvent.isAssignableFrom(Button.class))
  {
      //println(theEvent.getController().getName());    
      try{    
        setFrame(Integer.parseInt(theEvent.getController().getName()));    
        movie.pause();    
         playing = false;    
      }catch(Exception e){    
        return;    
      }  
  }
}
 

public float coor_to_angle(double pcx, double pcy, double px, double py, double rr)                // calculate the angle using coordinate. 360.
{  
    float anglea = (float) Math.acos( (px-pcx)/rr );  
    anglea *= 180/PI;
    if(py>pcy)
    {
        anglea = 360- anglea;
    } 
    return anglea; 
}


public int getFrame() 
{    
  return ceil(movie.time() * 30) - 1;
}

void keyPressed() 
{    
    if(keyCode == 32)  //space
    {    
      if(playing) movie.pause();    
      else movie.play();    
      playing = !playing;    
    }    
    
    if(keyCode==37 || keyCode==65)  // left
    {
      done=0;
      int nowframe =(int) (movie.time() * movie.frameRate);
      if (0 < nowframe) 
        setFrame(nowframe  -1);       
      movie.pause();
      playing = false;
    }
    
    if(keyCode==39 || keyCode==68)    //right
    {
      done=0;
      int nowframe =(int) (movie.time() * movie.frameRate);
      if(nowframe < getLength() - 1)
        setFrame( (int)(movie.time() *movie.frameRate +1));       
      movie.pause();
      playing = false;
    }
}
  
void setup() 
{
  size(800, 490);
  background(255);         // 
  img4 = loadImage("watch33.png");  
  playhead = loadImage("playheadT.png");  
  new_info = new ArrayList();
    
  movie = new Movie(this, "transit.mov");        //path
  movie.loop();
  sttop = true;
  time_to_now = 0;
  setButtons();
  
  imageMode(CENTER);    
  image(img4, xc, yc);  
  imageMode(CORNER);
  
  PFont mono;
  mono = loadFont("Verdana-48.vlw");
  textFont(mono);
}

void drawwatch()
{
  imageMode(CENTER);    
  image(img4, xc, yc);  
}


void setFrame(int n) 
{
  movie.play();
  playing = true;
  float frameDuration = 1.0 / movie.frameRate;        // The duration of a single frame:
  float where = (n + 0.5) * frameDuration;         // We move to the middle of the frame by adding 0.5:
  float diff = movie.duration() - where;          // Taking into account border effects:
  if (diff < 0) 
  {
    where += diff - 0.25 * frameDuration;
  }
  time_to_now = where; 
  sttop = true;
  movie.jump(where);
  movie.pause();  
  playing = false;
}  


int getLength() 
{
  return int(movie.duration() * movie.frameRate);
}


void movieEvent(Movie m) 
{
  m.read();
}

void onEnter() 
{
    cursor(HAND);
    println("enter");    
}


void draw()
{
  background(255);
  imageMode(CORNER);
  image(movie, xc-r, yc-r, 2*r, 2*r); 
  imageMode(CENTER);    
  image(img4, xc, yc);  
  imageMode(CORNER); 
  
  
  if(sttop==true)
  {
    time_to_now = movie.time();
  } 
  
  
  int result = (mouseX- xc)* (mouseX- xc) + (mouseY-yc) * (mouseY-yc);  
  if( (int)result >=Math.pow((r-50),2) && (int)result<=Math.pow(r+50, 2))
  {
    cursor(HAND);
  }
  
  else
    cursor(ARROW);
  
  if(mousePressed && mouseButton == RIGHT)              // LOCK
  {
     d1 = 1; 
  }
  
  if(mousePressed && mouseButton == CENTER)              // RESET
  {
     d1 = 0; 
     done=0;
     drawwatch();
  }
  
  if(done==1)
  {
     ads = (float)Math.sqrt( (dragx-xc)*(dragx-xc)+(dragy-yc)*(dragy-yc) );
     
     strokeWeight(8);
     stroke(255);
     drawArrow((float)xx, (float)yy, ptoxy, 360- coor_to_angle(xx, yy, dragx, dragy, ptoxy));   
     prelen = ptoxy;
     strokeWeight(5);
     stroke(0);
     drawArrow((float)xx, (float)yy, ptoxy, 360- coor_to_angle(xx, yy, dragx, dragy, ptoxy));    
   //  println((360-startangle)+"||agl:"+(360 - stopangle));    
  }
    
    if(showarc==1)
    {
       noFill();
       if(redcolor>190 && order==0)
       {
           stroke(redcolor--, gbcolor++, gbcolor++);
           if(redcolor==190)
               order = 1;
       }
         
       else if(order==1)
       {
           stroke(redcolor++, gbcolor--, gbcolor--);
           if(redcolor==255)
               order = 0;
       }   
       
       int indexx=0, indexx2=new_info.size()-1;
       if(movstate == 1)
       {
          if(new_info.size()<1)
              tyrot = rotspd;
          else
          {
              int sh = 1;
              for(int i =0;i<new_info.size();i++)
              {
                  if(getFrame()>new_info.get(i).frameNo)
                  {
                      if(indexx<new_info.get(i).frameNo)
                      {
                          indexx = new_info.get(i).frameNo;
                      }
                  
                  }
                  
                  if(getFrame() < new_info.get(i).frameNo)
                      if(indexx2 > new_info.get(i).frameNo)
                      {
                          indexx2 = new_info.get(i).frameNo;
                      }
              
              }
         //  indexx = (getFrame()*2 <indexx+indexx2 ? indexx:indexx2 );             
            tyrot =  rotspd * Math.abs(getFrame() - indexx);
            println("rottt:"+indexx);
             // tyrot =  rotspd * Math.abs(getFrame() - new_info.get(new_info.size()-1).frameNo);
          }
              
          if(tyrot>0)
          {
              startangle = coor_to_angle(xc, yc, pRexx, pReyy, r) - tyrot ;
              stopangle = coor_to_angle(xc, yc, pRexx, pReyy, r) + tyrot ;  
              strokeWeight(5);
              if(startangle>=stopangle)
                 arc(xc, yc, 2*r, 2*r, (360-startangle)/180*(PI), (360 - stopangle)/180*(PI));             
              else
                 arc(xc, yc, 2*r, 2*r, (360-stopangle)/180*(PI), (360 - startangle)/180*(PI));       
          }
        }              
    }
 
    textSize(12);
    fill(0); 
    text("FrameNo", inix, 240);
    text("Angle1", inix+60, 240);
    text("Angle2", inix+120, 240);
    text("Intensity", inix+180, 240);
    text("Duration", inix+240, 240); 
 
  if(done==1)
  { 
    text(getFrame(), inix, 270);
    text(df.format(coor_to_angle(xc, yc, xx, yy, r)), inix+60, 270);
    text(df.format(coor_to_angle(xx, yy, dragx, dragy, ptoxy)), inix+120, 270);
    text(df.format(ptoxy), inix+180, 270);
  }
  
   text(text_str, inix, 330);   
  for(int i=0;i<new_info.size();i++)
  {        
      //text(new_info.get(i).frameNo, inix, 300+i*30);                                         // default y: 300
    //  text(new_info.get(i).angle1, inix+60, 300+i*30);
    //  text(new_info.get(i).angle2, inix+120, 300+i*30);
    //  text(new_info.get(i).intensity, inix+180, 300+i*30);
     // text(new_info.get(i).duration, inix+240, 300+i*30);      
      
      if(getFrame()==new_info.get(i).frameNo)
      {
          strokeWeight(8);
          stroke(255);
          drawArrow(new_info.get(i).arrowx, new_info.get(i).arrowy, new_info.get(i).arrowratio, 360- new_info.get(i).angle2);
          strokeWeight(5);
          stroke(0);
          drawArrow(new_info.get(i).arrowx, new_info.get(i).arrowy, new_info.get(i).arrowratio, 360- new_info.get(i).angle2);   
      }
  }
  
  noStroke();    
  fill(200);    
  rect(inix,140,slider_width,18);    
  fill(0, 102, 153);     
      
  imageMode(CENTER);    
  pushMatrix();    
  translate((float)inix+(float)(getFrame()*slider_width)/(float)getLength(), (float)145);    
  scale(0.1, 0.1);    
  image(playhead, 0, 0);    
  popMatrix(); 
  fill(255, 255, 255); 
  text("Intensity: "+df.format(ptoxy), xc-45, 1.8*yc); 
}

void drawArrow(float cx, float cy, float len, float angle)
{
  pushMatrix();
  translate(cx, cy);
  rotate(radians(angle));
  line(0,0,len, 0);
  line(len, 0, len - 8, -8);
  line(len, 0, len - 8, 8);
  popMatrix();
}