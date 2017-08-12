
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