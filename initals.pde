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