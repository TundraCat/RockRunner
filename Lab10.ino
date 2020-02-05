
#include <LiquidCrystal.h>
#include <time.h>
// initialize the library by associating any needed LCD interface pin
// with the arduino pin number it is connected to
const int rs = 12, en = 11, d4 = 5, d5 = 4, d6 = 3, d7 = 2;
LiquidCrystal lcd(rs, en, d4, d5, d6, d7);


byte person[8] = {
  0b00100,
  0b01010,
  0b00100,
  0b00100,
  0b01110,
  0b10101,
  0b00100,
  0b01010
};

byte rock[8] = {
  0b00100,
  0b00110,
  0b01010,
  0b01101,
  0b01001,
  0b11101,
  0b10011,
  0b11111,
};

extern "C" { 
  void initAD();
  unsigned int readAD(byte pin);
  
}

extern "C" void initGame();
extern "C" void control();
extern "C" void checkCollision();

//variables
extern byte charX, charY;
extern byte bposX[3];
extern byte bposY[3];
extern byte endGame;
extern byte level;

extern "C" void printChar(){

  lcd.write((byte) 0);
  
}//end printChar

extern "C" void printLose(){

  lcd.clear();
  lcd.setCursor(0,0);
  lcd.print("You lose :( !");
}//end printLose

extern "C" void printWin() {

  lcd.clear();
  lcd.setCursor(0,0);
  lcd.print("You win :) !");
  if(level < 3)
  {
    lcd.clear();
  }//end if
  
}//end printWin

extern "C" void moveCursor(){

  lcd.setCursor(charX, charY);
  
}//end moveCursor

extern "C" void printBarr(){

  lcd.write((byte) 1);
  
}//end printBarr

extern "C" void printNull(){

  lcd.print(" ");
  
}//end printNull

extern "C" void placeObjects(){

  control();
  delay(200);
  
}//end placeObjects

extern "C" void preamble(){
  
  for (int i = 0 ; i < 3; i++) {
    bposX[i] = 5 * i + rand() % 5 + 1;
    bposY[i] = rand() % 2;
    lcd.setCursor(bposX[i], bposY[i]);
    printBarr();
    if(bposY[i] == 0)
      bposY[i] = 1;
    else
      bposY[i] = 0;
  }//end for
}//end preamble

void setup() {
   lcd.begin(16, 2);
   lcd.createChar(0,person);
   lcd.createChar(1,rock);

 Serial.begin(9600);
   initAD();
   preamble();
   initGame();
   level = 0;
}//end setup


void loop() {
  if (endGame!=1){
    placeObjects();
    Serial.println(charX,DEC);
    Serial.println(charY,DEC);
    checkCollision();
    
  }//end if
  if(endGame == 1 && level < 3)
  {
    lcd.clear();
    endGame = 0;
    level++;
    //initAD();
    preamble();
    initGame();
  }//end if
 if(endGame == 1 && level >= 3)
  {
    lcd.setCursor(0,1);
    lcd.print("Try Again?");
    if(readAD(2) == 1)
    {
      lcd.clear();
      preamble();
      initGame();
      level = 0;
      endGame = 0;
    }//end if
  }
}//end loop

