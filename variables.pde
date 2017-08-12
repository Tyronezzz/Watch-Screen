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