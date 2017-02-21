/*
  UDPSendReceiveString:
  This sketch receives UDP message strings, prints them to the serial port
  and sends an "acknowledge" string back to the sender

  A Processing sketch is included at the end of file that can be used to send
  and received messages for testing with a computer.

  created 21 Aug 2010
  by Michael Margolis

  This code is in the public domain.
*/

#include "ADIS16364.h"    //library for reading data from IMU
#include <SPI.h>         // needed for Arduino versions later than 0018
#include <Ethernet2.h>
#include <EthernetUdp2.h>         // UDP library from: bjoern@cs.stanford.edu 12/30/2008
#include <stdlib.h>

//Instatiate ADIS16364 class as iSensor with CS pin 11(Arduino Leonardo)
ADIS16364 iSensor(9);

// Enter a MAC address and IP address for your controller below.
byte mac[] = {
  0x90, 0xA2, 0xDA, 0x10, 0xB8, 0xC4
};
IPAddress ip(192, 168, 1, 10);
unsigned int localPort = 5200;      // local port to listen on

//Enter IPAddress and port of recipient part
IPAddress remoteip (192, 168, 1, 1);
unsigned int remoteport = 5100;


// buffers for receiving and sending data
char  ReplyBuffer[UDP_TX_PACKET_MAX_SIZE];       // a string for sending IMU data to master
char buffer1[32];
char *testout;

// An EthernetUDP instance to let us send and receive packets over UDP
EthernetUDP Udp;

void setup() {
  Serial.begin(9600);
  while (!Serial) {
    ; //wait for serial port to connect
  }
  // start the Ethernet and UDP:
  Ethernet.begin(mac, ip);
  Serial.println(Ethernet.localIP());
  Udp.begin(localPort);
  delay(200);
}

void loop(){
  Serial.println("Running script");
  SPI.beginTransaction(SPISettings(1000000, MSBFIRST, SPI_MODE3));
  iSensor.burst_read();
  Udp.beginPacket(remoteip, remoteport);
  for(int i = 0; i < 11; i++){
    //Scale measured value, and cast as long integer
    testout = ltoa(iSensor.sensor[i]*1000L, buffer1, 10);
    //Send sensor data to the recipient computer
    Udp.write(testout);
    Udp.write(" ");
  }
  Udp.endPacket();
  Serial.println(iSensor.sensor[0]);
  delay(5000);
}
