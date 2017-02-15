#include <SPI.h>

const int CS = 11;

void setup() {
  unsigned char upper, lower;
  Serial.begin(9600);
  delay(2000);
  SPI.begin();
  delay(2000);
  SPI.setBitOrder(MSBFIRST);
  SPI.setDataMode(SPI_MODE3);
  SPI.setClockDivider(SPI_CLOCK_DIV16);
  pinMode(CS, OUTPUT);
  digitalWrite(CS, LOW);
  SPI.transfer(0xB5);
  SPI.transfer(0x04);
  digitalWrite(CS, HIGH);
  delay(1);
  digitalWrite(CS, LOW);
  upper = SPI.transfer(0x00);
  lower = SPI.transfer(0x00);
  delay(1);
  digitalWrite(CS, HIGH);
  Serial.print(upper);
  Serial.print(lower);
}

void loop(){
  
  // If serial has received 
  if(Serial.available() > 0){   
    // if the recieved character is 'D'
      if(Serial.read() == 'D'){
        // Perform burst read on iSensor
        //iSensor.debug();
        //iSensor.burst_read();
        Serial.println("running script");
        delay(10);
      }
  }
  
}
