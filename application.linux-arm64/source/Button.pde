// a button with side equal to 30 pixels

class Button 
{
  int minX, minY, side;
  
  Button(int x1, int y1)
 {
    minX = x1; minY = y1; side = 30; 
 } 
  
  boolean isClicked( int x, int y)
  {
   if (( x >= minX) && (x <= (minX+side)) && ( y >= minY) && (y <= (minY+side)))
     return true;
   else
     return false;
  }
 
  void display()
   {
     rectMode(CORNER); 
     rect( minX, minY, side, side);
   } 
  
}

class CloseButton extends Button
{
  
  CloseButton(int x1, int y1)
  {
      super(x1, y1);
   }
   
   void display()
   {
      super.display();
      strokeWeight(2);
      ellipse(minX+15,minY+15,20,20);
      strokeWeight(1);
   }
}
