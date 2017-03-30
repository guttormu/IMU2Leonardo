#include "ADIS16364.h"    //library for reading data from IMU
#include <SPI.h>         // needed for Arduino versions later than 0018
#include <Ethernet2.h>
#include <EthernetUdp2.h>         // UDP library from: bjoern@cs.stanford.edu 12/30/2008
#include <stdlib.h>

//Instatiate ADIS16364 class as iSensor with CS pin 11(Arduino Leonardo)
ADIS16364 iSensor(9);

//Set interrupt pin for output
int interruptPin = 2;

// Enter a MAC address and IP address for your controller below.
byte mac[] = {
  0x90, 0xA2, 0xDA, 0x10, 0xB8, 0xB4
};
IPAddress ip(192, 168, 1, 44);
unsigned int localPort = 5200;      // local port to listen on

//Enter IPAddress and port of recipient part
IPAddress remoteip (192, 168, 1, 33);
unsigned int remoteport = 5100;


// buffers for receiving and sending data
char  ReplyBuffer[UDP_TX_PACKET_MAX_SIZE];       // a string for sending IMU data to master
char *DataOut;

// An EthernetUDP instance to let us send and receive packets over UDP
EthernetUDP Udp;

void setup() {
  //Gyroscope Precision Automatic Bias Null Calibration
  iSensor.gyro_prec_null();
  // start the Ethernet and UDP:
  Ethernet.begin(mac, ip);
  Udp.begin(localPort);
  pinMode(interruptPin, OUTPUT);
  digitalWrite(interruptPin, HIGH);
  delay(200);
}

void loop(){
  digitalWrite(interruptPin, LOW);
  SPI.beginTransaction(SPISettings(1000000, MSBFIRST, SPI_MODE3));
  iSensor.burst_read();
  digitalWrite(interruptPin, HIGH);
  Udp.beginPacket(remoteip, remoteport);
  for(int i = 0; i < 11; i++){
    //Scale measured value, and cast as long integer
    DataOut = ltoa(iSensor.sensor[i]*1000L, ReplyBuffer, 10);
    //Send sensor data to the recipient computer
    Udp.write(DataOut);
    Udp.write(" ");
  }
  Udp.endPacket();
  delay(100);
}
