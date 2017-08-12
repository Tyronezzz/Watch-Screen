// Version: 3.1
// Description: Basic function of an editor tool. Draw an arrow instead of an img.
// Author: Tyrone
// Date: 2017.08.10

// LEFT: click to set the position, drag to controll the direction and the force
// RIGHT: click to confirm the operation
// CENTER: reset.


import processing.video.*;
import controlP5.*;
import java.math.BigDecimal;   
import java.util.ArrayList;
java.text.DecimalFormat df = new java.text.DecimalFormat("#.#"); 

//flags
int scl = 0;
int d1=0, done=0;
boolean sttop;
PImage playhead;    
boolean playing = true;

ControlP5 cp5;
Movie movie;
float time_to_now;
Table table;
int xc = 200, yc = 230, r = 145;           //center of the circle, default radius 125
double xx =0 , yy = 0;                     // intersaction vertex of the circle
int counter_r = 10;                        // radius of the intersaction circle
PImage img4;                         // arrow icon, watch icon 
double picx, picy;                         // position of the arrow
float ptoxy;                               // distance from the cursor to the intersaction point
double k;                                  // k of arrow
float dragx, dragy;                        // record the lastest update position of mousedrag
int inix = 450;                            // left side of the buttons
ArrayList <ainfo> new_info;               // dynamic array to store the info the arrow
boolean pause_play= true;                 // a flag to control play/pause
int force_max=90;
//double x_line=0, y_line=0;              
double prex, prey;
int slider_width=312;
int rotspd = 30;  // 30 degree/frame 
float tyrot=0;
int sflg;
int showarc =0;
float pRexx, pReyy=0; 
int movstate=0; 
float ratio;
float ads;
float prelen;
int redcolor = 255;
int order=0;
int gbcolor=0;
float startangle, stopangle;
String text_str = "";

public class ainfo
{
  public int frameNo;
  public float angle1;
  public float angle2;
  public float intensity;
  public float duration;
  public float arrowx, arrowy;
  public float arrowtheta;
  public float arrowratio;
}

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
 
void setButtons()
{
  cp5 = new ControlP5(this);   // set the buttons here
  PImage[] imgs = {loadImage("play.png"),loadImage("play.png"),loadImage("play.png")};
  PImage[] imgs2 = {loadImage("pre.png"),loadImage("pre.png"),loadImage("pre.png")};
  PImage[] imgs3 = {loadImage("next.png"),loadImage("next.png"),loadImage("next.png")};     
  PImage[] imgs4 = {loadImage("change.png"),loadImage("change.png"),loadImage("change.png")};     
  PImage[] imgs5 = {loadImage("delete.png"),loadImage("delete.png"),loadImage("delete.png")};     
  PImage[] imgs6 = {loadImage("save.png"),loadImage("save.png"),loadImage("save.png")};     

   cp5.addButton("play")
     .setValue(128)
     .setPosition(inix,100)
     .setWidth(104)
     .setHeight(24)
     .setImages(imgs)
     .setColorActive(color(40,96,144)) // color for click
     .setColorBackground(color(51, 122,183)) // default color
     .setColorForeground(color(40,96,144))    // mouse over
     .updateSize()
     .addCallback(new CallbackListener() 
     {
       public void controlEvent(CallbackEvent event) 
       {    
         if (pause_play==true && event.getAction() == ControlP5.ACTION_RELEASED) //pause
         {
           movstate = 1;
           movie.pause();       
           playing = false;
           pause_play = false;         
         }   
         else if (pause_play==false && event.getAction() == ControlP5.ACTION_RELEASED) //play
         {
           movstate = 0;
           movie.play();
           playing = true;
           done=0;
           pause_play = true;
         }
       }
      });   
      
      cp5.addButton("pre")
     .setValue(128)
     .setPosition(inix+104,100)
     .setWidth(104)
     .setHeight(24)
     .setImages(imgs2)
     .setColorActive(color(40,96,144)) // color for click
     .setColorBackground(color(51, 122,183)) // default color
     .setColorForeground(color(40,96,144))    // mouse over
     .updateSize()
     .addCallback(new CallbackListener() 
     {
       public void controlEvent(CallbackEvent event) 
       {
         if (event.getAction() == ControlP5.ACTION_RELEASED) //push???
         {
           done=0;
           int nowframe =(int) (movie.time() * movie.frameRate);
           if (0 < nowframe) 
             setFrame(nowframe  -1);       
           movie.pause();
           playing = false;
         }
       }
      });   
      
     cp5.addButton("next")
     .setValue(128)
     .setPosition(inix+208,100)
     .setWidth(104)
     .setHeight(24)
     .setImages(imgs3)
     .setColorActive(color(40,96,144)) // color for click
     .setColorBackground(color(51, 122,183)) // default color
     .setColorForeground(color(40,96,144))    // mouse over
     .updateSize()
     .addCallback(new CallbackListener() 
     {
       public void controlEvent(CallbackEvent event) 
       {
         if (event.getAction() == ControlP5.ACTION_RELEASED) //push???
         {
           done=0;
           int nowframe =(int) (movie.time() * movie.frameRate);
           if(nowframe < getLength() - 1)
             setFrame( (int)(movie.time() *movie.frameRate +1));       
           movie.pause();
           playing = false;
         }
       }
      });                 
         
     cp5.addButton("Save change")
     .setValue(128)
     .setPosition(inix,180)
     .setWidth(104)
     .setHeight(24)
     .setImages(imgs4)
     .updateSize()
     .addCallback(new CallbackListener() 
     {
       public void controlEvent(CallbackEvent event) 
       {
          if (event.getAction() == ControlP5.ACTION_RELEASED) //push???
         {            
            // ((Textfield)(cp5.getController(" "))).setText("34");
            float mdur = Float.parseFloat(((Textfield)(cp5.getController(" "))).getText());        
            int frame_sum = (int) (mdur * movie.frameRate/1000);                        // ms
            
            println(movie.frameRate+"||"+frame_sum);
            for(int j=0;j<frame_sum;j++)
            {
                ainfo ain = new ainfo();                        // arraylist
                sflg = 0;
                ain.frameNo = getFrame()+j;
                ain.angle1 = coor_to_angle(xc, yc, xx, yy, r);
                ain.angle2 = coor_to_angle(xx, yy, dragx, dragy, ptoxy);
                ain.intensity = ptoxy;                
                ain.arrowx = (float)xx;
                ain.arrowy = (float)yy;      
                ain.arrowratio = ptoxy;          
               // ain.duration = Float.parseFloat(((Textfield)(cp5.getController(" "))).getText());  
               
                if(new_info.size()>0)
                {
                  if(Math.abs(ain.angle1 - new_info.get(new_info.size()-1).angle1) > rotspd * (ain.frameNo - new_info.get(new_info.size()-1).frameNo))
                    {
                        sflg=1;
                        text_str = "It cannot rortate such an angle during the frames...";
                        println("It cannot rortate such an angle during the frames...");
                    }         
                }                        
                
                for(int i=0;i<new_info.size();i++)
                {                                        
                    if(getFrame()+j==new_info.get(i).frameNo)
                    {                    
                        new_info.set(i, ain);
                        sflg=1;
                        text_str = "Change the same frameNo"+ getFrame();
                        println("Change the same frameNo"+ getFrame());                   
                    }
                }   
  
               if(done==1 && sflg==0)
               {
                
                 pRexx =(float) xx;
                 pReyy =(float) yy; 
                 showarc=1;
                 new_info.add(ain);
                 text_str = "Already save the info of the frame...";
                 println("Already save the info of the frame...");
               }       
             }
            
            
            if(done==1)
            {
                Button lbl = cp5.addButton(""+getFrame());
                //println(lbl.getName());
                lbl.setPosition(inix + (float)(getFrame()*slider_width)/(float)getLength(),140);
                int lblWid = (int)((float)(mdur*movie.frameRate*slider_width)/( (float)getLength()*1000 ));
                if(lblWid < 1) lblWid = 1;
                lbl.setSize(lblWid,18);
                lbl.setLabelVisible(false);    
               
            }
              
            else
            {
                text_str = "Nothing has been done... You cannot save it...";
                println("Nothing has been done... You cannot save it...");
            }
                
            done=0;      
          }
       }
      });  
      
      cp5.addButton("Delete")
     .setValue(128)
     .setPosition(inix+104,180)
     .setWidth(104)
     .setHeight(24)
     .setImages(imgs5)
     .updateSize()
     .addCallback(new CallbackListener() 
     {
       public void controlEvent(CallbackEvent event) 
       {
         if (event.getAction() == ControlP5.ACTION_RELEASED) //push???
         {
            done=0;
            if(new_info.size()==0)
            {
              text_str = "It is empty now...";
              println("It is empty now...You cannot delete anything...");            
            }
            else
            {
             
              for(int i=0;i<new_info.size();i++)
              {                   
                 
                  if(getFrame()==new_info.get(i).frameNo)
                  {                    
                      new_info.remove(i);
                      cp5.remove(""+getFrame());
                      text_str = "Already remove the info of frameNo."+getFrame();
                      println("Already remove the info of frameNo."+getFrame());
                  }
              }         
            }
                      
         }
       }
      });     
      
      cp5.addButton("Save file")
     .setValue(128)
     .setPosition(inix+208,180)
     .setWidth(104)
     .setHeight(24)
     .setImages(imgs6)
     .updateSize()
     .addCallback(new CallbackListener() 
     {
       public void controlEvent(CallbackEvent event) 
       {
         if (event.getAction() == ControlP5.ACTION_RELEASED) //push???
         {
              table = new Table();  
              table.addColumn("Frame_No.");
              table.addColumn("angle1");
              table.addColumn("angle2");
              table.addColumn("intensity");
              table.addColumn("duration");
              
              for(int i=0;i<new_info.size();i++)
              {                   
                  TableRow newRow = table.addRow();
                  newRow.setInt("Frame_No.", new_info.get(i).frameNo);
                  newRow.setFloat("angle1", new_info.get(i).angle1);
                  newRow.setFloat("angle2", new_info.get(i).angle2);
                  newRow.setFloat("intensity", new_info.get(i).intensity);
                  newRow.setFloat("duration", new_info.get(i).duration);                   //unknown  
              }   
              text_str ="Already saved it...";
              println("Already saved it..."); 
              saveTable(table, "data/new.csv");
              done=0;
              
         }
       }
      });    
      
      fill(0);
      cp5.addTextfield(" ")
     .setPosition(inix+240,255)
     .setSize(50,20)
    // .setFontColor(color(0, 0, 0))
    .setColor(color(0))
     .setColorBackground(color(255)) 
     .setFont(createFont("arial",16))
     .setAutoClear(false)
     ;
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

void mousePressed()
{
  int result = (mouseX- xc)* (mouseX- xc) + (mouseY-yc) * (mouseY-yc);
  if(mouseButton == LEFT && mouseX >= inix && mouseX <= inix + slider_width && mouseY >=130 && mouseY <= 140)
  {    
    setFrame(getLength()*(mouseX-inix)/slider_width);    
    movie.pause();    
    playing = false;    
  }
  
  if(mouseButton == LEFT && d1==0)
  {
      if( (int)result >=Math.pow((r-50),2) && (int)result<=Math.pow(r+50, 2))
      {      
        if(xc == mouseX)
        {
          
        }
        else
        {
            double k = (yc-mouseY)/(xc-mouseX);
            double b = mouseY-(yc-mouseY)/(xc-mouseX)*mouseX;
            double A = 1+k*k;
            double B = (2*k*(b-yc)-2*xc);
            double C = xc*xc+(b-yc)*(b-yc)-r*r;
            double sqrt_delta = Math.sqrt(B*B-4*A*C);
            if(mouseX>xc)
            {
              xx = (-B + sqrt_delta)/(2*A);
              yy = k*xx+b;
            }
            
            else
            {
              xx = (-B - sqrt_delta)/(2*A);
              yy = k*xx+b;
            }          
            scl=1;      
        }             
      }
      
      else
      {       
      }
  }
}


void mouseDragged()
{ 
  if(scl==1 && d1==0 && mouseX<inix)
   {
       done=0;
       noLoop();
       ellipseMode(CENTER);  
       ellipse((float)xx, (float)yy, counter_r/2, counter_r/2);
       
       k = (yy-mouseY)/(xx-mouseX);
       double b = mouseY-(yy-mouseY)/(xx-mouseX)*mouseX;
       double A = 1+k*k;
       double B = (2*k*(b-yy)-2*xx);
       double C = xx*xx+(b-yy)*(b-yy)-force_max*force_max;                         // 50/2
       double sqrt_delta = Math.sqrt(B*B-4*A*C);
       picx = (mouseX+xx)/2;
       picy = (mouseY+ yy)/2;
       ptoxy =(float) Math.sqrt( (mouseX-xx)*(mouseX-xx) + (mouseY-yy)*(mouseY-yy) );
       if(ptoxy>100)
       {
           ptoxy = 100; 
       }
     
       else
       {
           dragx = mouseX;
           dragy = mouseY;           
       }
        
       done=1;
       loop();
       prex= xx;
       prey=yy;      
   }
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