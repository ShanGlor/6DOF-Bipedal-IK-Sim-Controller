/*
6DOF Bipedal IK Sim/Controller by ShanGlor
Upload "StandardFirmata" sketch to Arduino
Tested on Processing 2.0.1 and 2.2.1
Tested on Processing 3.3 needs to install "Arduino" libs
Select from the serial port list on void setup, change "[1]" to your appropriate COM port. i.e. [2] or [3], mine is COM3 on [1]. 
Servos on D3, D5, D6 for left leg.  D9, D10 and D11 for right leg.
*/

import processing.serial.*;    
import cc.arduino.*;
Arduino arduino;
int rxpos;
int rypos;
int A2r, A3r, D2r, D3r, F2r;

int xpos;
int ypos;
int A2, A3, D2, D3, F2;

PVector originr;
int pelvis_length, rfemur_length, rtibia_length, rtarsal_length, rtoe_length;
int pelvis_angle,rhip_angle,rknee_angle,rtarsal_angle,rtoe_angle;
Segmentr pelvis, rfemur,rtibia,rtarsal,rtoe;
PVector drag_deltar = new PVector(0,0);
int hockr_radius = 35;
boolean hockr_drag = false;

PVector origin;
int femur_length, tibia_length, tarsal_length, toe_length;
int hip_angle,knee_angle,knee_angle2,tarsal_angle,toe_angle;
Segment femur,tibia,tarsal,toe;
PVector drag_delta = new PVector(0,0);
int hock_radius = 35;
boolean hock_drag = false;

void setup()
{  
  size(500,500,P2D);
  println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[1], 57600); //Select from the list your assigned COM port 
  arduino.pinMode(9, Arduino.SERVO);
  arduino.pinMode(10, Arduino.SERVO);
  arduino.pinMode(11, Arduino.SERVO);
  arduino.pinMode(3, Arduino.SERVO);
  arduino.pinMode(5, Arduino.SERVO);
  arduino.pinMode(6, Arduino.SERVO);    
  originr = new PVector(width/2, height/3); 
  
  pelvis_length=60;
  rfemur_length = 80;
  rtibia_length = 120;
  rtarsal_length = 50;
  rtoe_length = 1;
  pelvis_angle=60;
  rhip_angle = 150;
  rknee_angle = 79;
  rtarsal_angle = 180; //0 avian gait 
  rtoe_angle = 100;
  
  pelvis = new Segmentr(pelvis_length);
  pelvis.setOriginr(this.originr);
  pelvis.setRotationr(hip_angle);
  rfemur = new Segmentr(rfemur_length);
  rfemur.setOriginr(this.originr);
  rfemur.setRotationr(rhip_angle);

  rtibia = new Segmentr(rtibia_length);
  rtibia.setOriginr(rfemur.P2r);
  rtibia.setRotationr(rknee_angle);

  rtarsal = new Segmentr(rtarsal_length);
  rtarsal.setOriginr(rtibia.P2r);
  rtarsal.setRotationr(rtarsal_angle);
  
  rtoe = new Segmentr(rtoe_length);
  rtoe.setOriginr(rtarsal.P2r);
  rtoe.setRotationr(rtoe_angle);

  
  origin = new PVector(width/1.6, height/3);  
  femur_length = 80;
  tibia_length = 120;
  tarsal_length = 50;
  toe_length = 1;
  hip_angle = 90;
  knee_angle = 90;
  tarsal_angle = 180; //0 avian gait, edit also "float A3a"
  toe_angle = 90;

  femur = new Segment(femur_length);
  femur.setOrigin(this.origin);
  femur.setRotation(hip_angle);

  tibia = new Segment(tibia_length);
  tibia.setOrigin(femur.P2);
  tibia.setRotation(knee_angle);

  tarsal = new Segment(tarsal_length);
  tarsal.setOrigin(tibia.P2);
  tarsal.setRotation(tarsal_angle);
  
  toe = new Segment(toe_length);
  toe.setOrigin(tarsal.P2);
  toe.setRotation(toe_angle);
    
}

void draw()
{
    background(128); 
    stroke(#333333);
    strokeWeight(1);
    pelvis.draw(); 
    rfemur.draw();
    rtibia.draw();
    rtarsal.draw();
    rtoe.draw();
    femur.draw();
    tibia.draw();
    tarsal.draw();
    toe.draw();
    
    stroke(#333333);
    fill(#333333);
    
    text("RHip angle: "+ int(rfemur.rotationr), 10, 80); 
    text("RKnee angle: "+ int(A2r), 10, 100);
    text("RAnkle angle: "+ int(A3r), 10, 120);
    text("LHip angle: "+ int(femur.rotation), 10, 20); 
    text("LKnee angle: "+ int(A2), 10, 40);
    text("LAnkle angle: "+ int(A3), 10, 60);
    text("___________________________________________________________________________", 10, 327);
    
    //text("Upload FirmataStandard sketch on Arduino. Edit the line for right COM port.", 10, 440);
    text("LMB for left leg, RMB for right leg control. ", 10, 460);
    text(" =) ShanGlor", 10, 480);
    
    if(mouse_over_hockr()) draw_hockr();
    if(mouse_over_hock()) draw_hock1();
   
}

boolean mouse_over_hockr()
{
  return ( dist(rtibia.P2r.x, rtibia.P2r.y, mouseX, mouseY) <= hockr_radius);    
}

void draw_hockr()
{
   noStroke();
   fill(#CC3300,100);
   ellipse(rtibia.P2r.x,rtibia.P2r.y,hockr_radius,hockr_radius);
}

boolean mouse_over_hock()
{
  return ( dist(tibia.P2.x, tibia.P2.y, mouseX, mouseY) <= hock_radius);    
}

void draw_hock1()
{
   noStroke();
   fill(#0062cc,100);
   ellipse(tibia.P2.x,tibia.P2.y,hock_radius,hock_radius);
}

void mousePressed() 
{
   if (mouseButton == RIGHT) {
   if(!mouse_over_hockr()) return;
   hockr_drag = true;
   drag_deltar.x = rtibia.P2r.x - mouseX;
   drag_deltar.y = rtibia.P2r.y - mouseY;
   }
 
   else {   
   if(!mouse_over_hock()) return;
   hock_drag = true;
   drag_delta.x = tibia.P2.x - mouseX;
   drag_delta.y = tibia.P2.y - mouseY;
}
}

void mouseDragged() 
{ 
  if (mouseButton == RIGHT) {
  if(!hockr_drag) return;

   PVector targetr = new PVector( drag_deltar.x + mouseX, drag_deltar.y + mouseY);
   PVector rotsr =  IKr(rfemur_length,rtibia_length,targetr);

   rfemur.setRotationr(rotsr.x);
   rtibia.setOriginr(rfemur.P2r);
   rtibia.setRotationr(rotsr.y);
   rtarsal.setOriginr(rtibia.P2r);
   rtarsal.setRotationr(rtarsal_angle);
   rtoe.setOriginr(rtarsal.P2r);
   rtoe.setRotationr(rtoe_angle); 
  }  
   else {   
   if(!hock_drag) return;

   PVector target = new PVector( drag_delta.x + mouseX, drag_delta.y + mouseY);
   PVector rots =  IK(femur_length,tibia_length,target);

   femur.setRotation(rots.x);
   tibia.setOrigin(femur.P2);
   tibia.setRotation(rots.y);
   tarsal.setOrigin(tibia.P2);
   tarsal.setRotation(tarsal_angle);
   toe.setOrigin(tarsal.P2);
   toe.setRotation(toe_angle);    
   }
}

void mouseReleased() 
{
    if(hockr_drag) hockr_drag = false;
     if(hock_drag) hock_drag = false;
}

/**********************************************************
 ************************RIGHT IK**********************************/
 PVector IKr(int ar,int br,PVector dr)
 {
     PVector rotationsr = new PVector(0,0);
     
     float drx = dr.x - originr.x;
     float dry = dr.y - originr.y;
     
     //calculates the distance beetween the first link and the endpoint
     float distancer = sqrt(drx*drx+dry*dry);
     float cr = min(distancer, ar + br);       
         
     //calculates the angle between the distance segment and the first link
     float Br = acos((br * br - ar * ar - cr * cr)/(-2 * ar * cr));

     //calculate knee angle relative to femur 
     //float C = acos((c * c - a * a - b * b)/(-2 * a * b));  //results in radian
     float Cr = acos((ar * ar + br * br - cr * cr)/(2 * ar * br));
     float Er = degrees(Cr);  //converts radian to degrees
     A2r = Math.round(Er);  //rounds off        
     
     //calculates ankle angle relative to origin
     float Dr = atan2(dry,drx);
     float D1r = degrees(Dr);
     D2r = Math.round(D1r);          
     float D4r = 180-D2r;
     D3r = Math.round(D4r);
     
     //calculate ankle angle relative to tibia 
     float Fr = acos((rtibia_length * rtibia_length + cr * cr - rfemur_length * rfemur_length)/(2 * rtibia_length * cr));
     float F1r = degrees(Fr);
     F2r = Math.round(F1r);
     
     float A3ar = 180 -(F2r+D3r);  //for man run
     //float A3a = F2+D3;  //for chicken run
     A3r = Math.round(A3ar);
   
     float rhip_angle = degrees(Dr + Br); 
     float rknee_angle = degrees(Dr + Br + PI + Cr);
     if(rhip_angle > 360) rhip_angle -= 360;
     if(rknee_angle > 360) rknee_angle -= 360;
         
     rotationsr.x = rhip_angle;       
     rotationsr.y = rknee_angle;      
     return rotationsr;
 }

/**********************************************************
 ************************LEFT IK********************************/
 PVector IK(int a,int b,PVector d)
 {
     PVector rotations = new PVector(0,0);
     
     float dx = d.x - origin.x;
     float dy = d.y - origin.y;
     
     //calculates the distance beetween the first link and the endpoint
     float distance = sqrt(dx*dx+dy*dy);
     float c = min(distance, a + b);
      
         
     //calculates the angle between the distance segment and the first link
     float B = acos((b * b - a * a - c * c)/(-2 * a * c));

     //calculate knee angle relative to femur 
     float C = acos((c * c - a * a - b * b)/(-2 * a * b));  //results in radian
     float E = degrees(C);  //converts radian to degrees
     A2 = Math.round(E);  //rounds off
     
     //float A2a = sqrt(a * a + b * b - 2 * a * b * cos(A2));
     //float C = acos((a * a + b * b - c * c)/(2 * a * b));
     
     
     //calculates ankle angle relative to origin
     float D = atan2(dy,dx);
     float D1 = degrees(D);
     D2 = Math.round(D1);          
     float D4 = 180-D2;
     D3 = Math.round(D4);
     
     //calculate ankle angle relative to tibia 
     float F = acos((tibia_length * tibia_length + c * c - femur_length * femur_length)/(2 * tibia_length * c));
     float F1 = degrees(F);
     F2 = Math.round(F1);
     
     float A3a = 180 -(F2+D3);  //for man run
     //float A3a = F2+D3;  //for chicken run
     A3 = Math.round(A3a);
   
     float hip_angle = degrees(D + B); 
     float knee_angle = degrees(D + B + PI + C);
     if(hip_angle > 360) hip_angle -= 360;
     if(knee_angle > 360) knee_angle -= 360;
    
     
     rotations.x = hip_angle;
     //xpos = Math.round(hip_angle);
     //println(xpos); //
      
     rotations.y = knee_angle;
     //ypos = Math.round(knee_angle);
    // println(ypos); //
    // println("=========================");        
    
     return rotations;
 }

class Segmentr
{
    int sizer;
    PVector P1r,P2r;
    float rotationr;

    Segmentr(int sr)
    {
        sizer = sr;
        P1r = new PVector(0,0);
        P2r = new PVector(0,0);
    }
    
    void setOriginr(PVector origr)
    {
      P1r.x = origr.x;
      P1r.y = origr.y;
    }
    
    void setRotationr(float rotationr)
    {
      this.rotationr = rotationr;
      P2r.x = P1r.x + this.sizer * cos(radians(this.rotationr));
      P2r.y = P1r.y + this.sizer * sin(radians(this.rotationr));
    }

    void draw()
    {
      stroke(0);
      strokeWeight(2);
      line(P1r.x,P1r.y,P2r.x,P2r.y);
      
      stroke(255,0,0,100);
      fill(240,0,0,200);
      ellipse(P1r.x,P1r.y,4,4);
    

  
  arduino.servoWrite(9, constrain(int(rfemur.rotationr), 0, 180));
  arduino.servoWrite(10, constrain(A2r, 0, 180)); //knee angle
  arduino.servoWrite(11, constrain(A3r, 0, 180));  //ankle angle
  
  }}
  
  class Segment
{
    int size;
    PVector P1,P2;
    float rotation;

    Segment(int s)
    {
        size = s;
        P1 = new PVector(0,0);
        P2 = new PVector(0,0);
    }
    
    void setOrigin(PVector orig)
    {
      P1.x = orig.x;
      P1.y = orig.y;
    }
    
    void setRotation(float rotation)
    {
      this.rotation = rotation;
      P2.x = P1.x + this.size * cos(radians(this.rotation));
      P2.y = P1.y + this.size * sin(radians(this.rotation));
    }

    void draw()
    {
      
      stroke(0);
      strokeWeight(2);
      line(P1.x,P1.y,P2.x,P2.y);
      
      stroke(255,0,0,100);
      fill(240,0,0,200);
      ellipse(P1.x,P1.y,4,4);
      
  //arduino.servoWrite(9, xpos);  //hip angle
  arduino.servoWrite(3, constrain(int(femur.rotation), 0, 180));
  arduino.servoWrite(5, constrain(A2, 0, 180)); //knee angle
  arduino.servoWrite(6, constrain(A3, 0, 180));  //ankle angle
  }
}
