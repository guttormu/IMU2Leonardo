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

#include <SPI.h>         // needed for Arduino versions later than 0018
#include <Ethernet2.h>
#include <EthernetUdp2.h>         // UDP library from: bjoern@cs.stanford.edu 12/30/2008
#include <stdlib.h>

//Chip Select (CS) pin
int CS = 9;

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
  pinMode(CS, OUTPUT);
  SPI.begin();
  Ethernet.begin(mac, ip);
  Serial.println(Ethernet.localIP());
  //Serial.println(CS);
  Udp.begin(localPort);
  SPI.beginTransaction(SPISettings(1000000, MSBFIRST, SPI_MODE3));
  digitalWrite(CS, HIGH);
  delay(200);
}

void loop(){
  double sensor[11];
  unsigned char bits[11] = {12, 14, 14, 14, 14, 14, 14, 12, 12, 12, 12};
  unsigned char offset_bin[11] = {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1};

  unsigned char upper,lower,mask;
  unsigned int raw;
  double scale[11] = {2.418e-3, 0.05, 0.05, 0.05, 1, 1, 1, 0.136, 0.136, 0.136, 805.8e-6};
  double add[11] = {0, 0, 0, 0, 0, 0, 0, 25, 25, 25, 0};
  

  SPI.beginTransaction(SPISettings(1000000, MSBFIRST, SPI_MODE3));
  digitalWrite(CS, LOW);
  
  SPI.transfer(0x3E);
  SPI.transfer(0x00);
  delayMicroseconds(1);
  
  for(int i = 0; i < 11; i++){
    upper = SPI.transfer(0x00);
    lower = SPI.transfer(0x00);
    mask = 0xFF >> (16 - bits[i]);
    raw = ( ( mask & upper ) << 8 ) | ( lower );
    sensor[i] = (( ( offset_bin[i] )?( raw ):( signed_double( bits[i], raw ) ) ) * scale[i] + add[i])*1000L;
    delayMicroseconds(1);
  }
  digitalWrite(CS, HIGH);
    
  //Send sensor data to the recipient computer
  Udp.beginPacket(remoteip, remoteport);
  for(int i = 0; i < 11; i++){
    testout = ltoa(sensor[i], buffer1, 10);
    Udp.write(testout);
    Udp.write(" ");
  }
  Udp.endPacket();
  delay(5000);
}

double signed_double(unsigned char nbits, unsigned int num){
  unsigned int mask, padding;
  // select correct mask
  mask = 1 << (nbits -1);
  
  // if MSB is 1, then number is negative, so invert it and add one
  // if MSB is 0, then just return the number 
  return (num & mask)?( -1.0 * (~(num | 0xFF << nbits)  + 1) ):( 1.0 * num );
}
