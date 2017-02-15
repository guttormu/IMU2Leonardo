#include "ADIS16364.h"
#include <SPI.h>

ADIS16364 iSensor(11);
const int CS = 11;

void setup() {
  Serial.begin(9600);
  pinMode(CS, OUTPUT);
  SPI.beginTransaction(SPISettings(1000000, MSBFIRST, SPI_MODE3));
  digitalWrite(CS, LOW);
  SPI.transfer(0xBE);
  SPI.transfer(0x10);
  digitalWrite(CS, HIGH);
  delay(30000);
  
}

void loop(){
  
  // If serial has received 
  if(Serial.available() > 0){   
    // if the recieved character is 'D'
      if(Serial.read() == 'D'){
        // Perform burst read on iSensor
        iSensor.debug();
        iSensor.burst_read();
  
        //Formating is specific to the python script provided
        Serial.print("[ ");
        for(int i = 0; i < 11; i++){
          Serial.print(iSensor.sensor[i]);
          if(i!=10)
            Serial.print(" ");
        }
        Serial.println(" ]");
        delay(10);
      }
  }
  
}
