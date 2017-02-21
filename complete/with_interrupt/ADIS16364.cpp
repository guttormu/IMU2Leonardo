////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Analog Devices, Inc.
//  June 2012
//  By: Adam Gleason, and Brian Holford
////////////////////////////////////////////////////////////////////////////////////////////////////////
//  ADIS16364.cpp
////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
//  This file is part of Interfacing ADIS16364 with Arduino example.
//
//  Interfacing ADIS16364 with Arduino example is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Lesser Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Interfacing ADIS16364 with Arduino example is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Lesser Public License for more details.
//
//  You should have received a copy of the GNU Lesser Public License
//  along with Interfacing ADIS16364 with Arduino example.  If not, see <http://www.gnu.org/licenses/>.
////////////////////////////////////////////////////////////////////////////////////////////////////////

#include "ADIS16364.h"

////////////////////////////////////////////////////////////////////////////
//                          ADIS16364(int CS)
////////////////////////////////////////////////////////////////////////////
// Constructor with configurable CS pin
////////////////////////////////////////////////////////////////////////////
// CS - Chip select pin
////////////////////////////////////////////////////////////////////////////
ADIS16364::ADIS16364(int CS){
  // Set CS pin to specified value
  this->CS = CS;
  // Begin SPI
  SPI.begin();
  // Set CS pin to be an Output
  pinMode(CS, OUTPUT);
  // Setup SPI
  set_SPI();
  // Initialize CS pin to be high
  digitalWrite(CS, HIGH);
  // Don't use lower power mode
  low_power = 0;
  // Wake device up, incase it's sleeping
  wake();
}

////////////////////////////////////////////////////////////////////////////
//                           Destructor
////////////////////////////////////////////////////////////////////////////
ADIS16364::~ADIS16364(){
  // Put device to sleep
  sleep();
  // Close SPI bus
  SPI.end();

}

////////////////////////////////////////////////////////////////////////////
//                        void burst_read()
////////////////////////////////////////////////////////////////////////////
// Performs a burst read, and stores the output into the sensor[] array
////////////////////////////////////////////////////////////////////////////
void ADIS16364::burst_read(){
  unsigned char bits[11] = {12, 14, 14, 14, 14, 14, 14, 12, 12, 12, 12};
  unsigned char offset_bin[11] = {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1};

  unsigned char upper,lower,mask;
  unsigned int raw;
  double scale[11] = {2.418e-3, 0.05, 0.05, 0.05, 1, 1, 1, 0.136, 0.136, 0.136, 805.8e-6};
  double add[11] = {0, 0, 0, 0, 0, 0, 0, 25, 25, 25, 0};
  
  
  digitalWrite(CS, LOW);
  
  SPI.transfer(0x3E);
  SPI.transfer(0x00);
  delay_cycle();
  
  for(int i = 0; i < 11; i++){
    upper = SPI.transfer(0x00);
    lower = SPI.transfer(0x00);
    mask = 0xFF >> (16 - bits[i]);
    raw = ( ( mask & upper ) << 8 ) | ( lower );
    sensor[i] = ( ( offset_bin[i] )?( raw ):( signed_double( bits[i], raw ) ) ) * scale[i] + add[i];
    delay_cycle();
  }
   
  digitalWrite(CS, HIGH);
}

////////////////////////////////////////////////////////////////////////////
//                           void debug()
////////////////////////////////////////////////////////////////////////////
// Use this to print (most) all the readable registers over the serial port
////////////////////////////////////////////////////////////////////////////
// TODO: Add other registers
////////////////////////////////////////////////////////////////////////////
void ADIS16364::debug(){
  
  // print all readable registers
  Serial.println("Device ID:");
  Serial.println(device_id());
  
  // perform burst read
  burst_read();
  
  Serial.print("Supply Voltage: ");
  Serial.print(sensor[SUPPLY]);
  Serial.println(" V");
  
  Serial.print("Gyroscope: ");
  Serial.print("(");
  Serial.print(sensor[XGYRO]);
  Serial.print(", ");
  Serial.print(sensor[YGYRO]);
  Serial.print(", ");
  Serial.print(sensor[ZGYRO]);
  Serial.println(") deg / s");
  
  Serial.print("Accelerometer: ");
  Serial.print("(");
  Serial.print(sensor[XACCEL]);
  Serial.print(", ");
  Serial.print(sensor[YACCEL]);
  Serial.print(", ");
  Serial.print(sensor[ZACCEL]);
  Serial.println(") mg");
  
  Serial.print("Temperature: ");
  Serial.print("(");
  Serial.print(sensor[XTEMP]);
  Serial.print(", ");
  Serial.print(sensor[YTEMP]);
  Serial.print(", ");
  Serial.print(sensor[ZTEMP]);
  Serial.println(") dec C");
  
  Serial.print("Analog Input: ");
  Serial.print(sensor[ANALOG]);
  Serial.println(" V");
    
  Serial.print("Gyro Offset: ");
  Serial.print("(");
  Serial.print(x_gyro_offset());
  Serial.print(", ");
  Serial.print(y_gyro_offset());
  Serial.print(", ");
  Serial.print(z_gyro_offset());
  Serial.println(") deg / s");
  
  Serial.print("Accel Offset: ");
  Serial.print("(");
  Serial.print(x_accel_offset());
  Serial.print(", ");
  Serial.print(y_accel_offset());
  Serial.print(", ");
  Serial.print(z_accel_offset());
  Serial.println(") mg");
}

////////////////////////////////////////////////////////////////////////////
//        unsigned int read(unsigned char nbits, unsigned char reg)
////////////////////////////////////////////////////////////////////////////
// Reads a register on the iSensor
////////////////////////////////////////////////////////////////////////////
// nbits - Bit width of the register you're reading, usually 14 or 12
// reg - Address of the register you're reading, see memory map for macros
// return - raw value from register, masking only nbits wide
////////////////////////////////////////////////////////////////////////////
// TODO: Add support for alarm/error flag
////////////////////////////////////////////////////////////////////////////
unsigned int ADIS16364::read(unsigned char nbits, unsigned char reg){
  // initialize variables
  unsigned char upper, lower, mask; 

  // Get upper and lower unsigned chars
  digitalWrite(CS, LOW);
  SPI.transfer(reg);
  SPI.transfer(0x00);
  digitalWrite(CS, HIGH);
  delay_cycle();
  digitalWrite(CS, LOW);
  upper = SPI.transfer(0x00);
  lower = SPI.transfer(0x00);
  digitalWrite(CS, HIGH);

  // calculate mask
  mask = 0xFF >> (16 - nbits);
  
  // Combine upper and lower, and return
  return ( ( upper & mask ) << 8 ) | ( lower );
}

////////////////////////////////////////////////////////////////////////////
//           void write(unsigned char reg, unsigned int value)
////////////////////////////////////////////////////////////////////////////
// Writes to a register on the iSensor
////////////////////////////////////////////////////////////////////////////
// reg - Address of the register you're writing to
// value - The value you want to set the register to
////////////////////////////////////////////////////////////////////////////
void ADIS16364::write(unsigned char reg, unsigned int value){
  // set lower byte
  digitalWrite(CS, LOW);
  SPI.transfer(reg | 0x80);
  SPI.transfer(value & 0x00FF);
  digitalWrite(CS, HIGH);
  delay_cycle();
  // set upper byte
  digitalWrite(CS, LOW);
  SPI.transfer( (reg + 1) | 0x80 );
  SPI.transfer( value >> 8 );
  digitalWrite(CS, HIGH);
}

////////////////////////////////////////////////////////////////////////////
//        double signed_double(unsigned char nbits, unsigned int num)
////////////////////////////////////////////////////////////////////////////
// Performs a two's complement to signed double conversion
////////////////////////////////////////////////////////////////////////////
// nbits - Bit width of the number you're trying to convert
// num - Two's complement form number you're trying to convert
// return - Signed double precision representation
////////////////////////////////////////////////////////////////////////////
double ADIS16364::signed_double(unsigned char nbits, unsigned int num){
  unsigned int mask, padding;
  // select correct mask
  mask = 1 << (nbits -1);
  
  // if MSB is 1, then number is negative, so invert it and add one
  // if MSB is 0, then just return the number 
  return (num & mask)?( -1.0 * (~(num | 0xFF << nbits)  + 1) ):( 1.0 * num );
}

////////////////////////////////////////////////////////////////////////////
//        unsigned int twos_comp(double num)
////////////////////////////////////////////////////////////////////////////
// Performs a signed double to two's complement conversion
////////////////////////////////////////////////////////////////////////////
// num - Signed double form of number you're trying to convert
// return - Two's complement representation
////////////////////////////////////////////////////////////////////////////
unsigned int ADIS16364::twos_comp(double num){
  unsigned int raw;
  
  if(num < 0){
    raw = ~((unsigned int)(-num) - 1);
  }else{
    raw = (unsigned int)num;
  }
  return raw;
}

////////////////////////////////////////////////////////////////////////////
//                        unsigned int device_id()
////////////////////////////////////////////////////////////////////////////
// Gets the device id 
////////////////////////////////////////////////////////////////////////////
// return - Device ID
////////////////////////////////////////////////////////////////////////////
unsigned int ADIS16364::device_id(){
  // Read 14 bits from the PROD_ID register
  return read(14, PROD_ID); 
}

////////////////////////////////////////////////////////////////////////////
//                      double x_gyro_offset()
////////////////////////////////////////////////////////////////////////////
// Get the value of the XGYRO_OFF register
////////////////////////////////////////////////////////////////////////////
// return - Value of the X - axis gyro offset, in deg/sec
////////////////////////////////////////////////////////////////////////////
double ADIS16364::x_gyro_offset(){
  unsigned int raw_value = read(13, XGYRO_OFF);
  return signed_double(13, raw_value)*0.0125;
}

////////////////////////////////////////////////////////////////////////////
//                      double y_gyro_offset()
////////////////////////////////////////////////////////////////////////////
// Get the value of the YGYRO_OFF register
////////////////////////////////////////////////////////////////////////////
// return - Value of the Y - axis gyro offset, in deg/sec
////////////////////////////////////////////////////////////////////////////
double ADIS16364::y_gyro_offset(){
  unsigned int raw_value = read(13, YGYRO_OFF);
  return signed_double(13, raw_value)*0.0125;
}

////////////////////////////////////////////////////////////////////////////
//                      double z_gyro_offset()
////////////////////////////////////////////////////////////////////////////
// Get the value of the ZGYRO_OFF register
////////////////////////////////////////////////////////////////////////////
// return - Value of the Z - axis gyro offset, in deg/sec
////////////////////////////////////////////////////////////////////////////
double ADIS16364::z_gyro_offset(){
  unsigned int raw_value = read(13, ZGYRO_OFF);
  return signed_double(13, raw_value)*0.0125;
}

////////////////////////////////////////////////////////////////////////////
//                      double x_accel_offset()
////////////////////////////////////////////////////////////////////////////
// Get the value of the XACCL_OFF register
////////////////////////////////////////////////////////////////////////////
// return - Value of the X - axis accel offset, in g force
////////////////////////////////////////////////////////////////////////////
double ADIS16364::x_accel_offset(){
  unsigned int raw_value = read(12, XACCL_OFF);
  return signed_double(12, raw_value);
}

////////////////////////////////////////////////////////////////////////////
//                      double y_accel_offset()
////////////////////////////////////////////////////////////////////////////
// Get the value of the YACCL_OFF register
////////////////////////////////////////////////////////////////////////////
// return - Value of the Y - axis accel offset, in g force
////////////////////////////////////////////////////////////////////////////
double ADIS16364::y_accel_offset(){
  unsigned int raw_value = read(12, YACCL_OFF);
  return signed_double(12, raw_value);
}

////////////////////////////////////////////////////////////////////////////
//                      double z_accel_offset()
////////////////////////////////////////////////////////////////////////////
// Get the value of the ZACCL_OFF register
////////////////////////////////////////////////////////////////////////////
// return - Value of the Z - axis accel offset, in g force
////////////////////////////////////////////////////////////////////////////
double ADIS16364::z_accel_offset(){
  unsigned int raw_value = read(12, ZACCL_OFF);
  return signed_double(12, raw_value);
}

////////////////////////////////////////////////////////////////////////////
//                    void x_gyro_offset(double value)
////////////////////////////////////////////////////////////////////////////
// Offset the X - Axis gyro
////////////////////////////////////////////////////////////////////////////
// value - The amount of offset you want, in deg/sec
////////////////////////////////////////////////////////////////////////////
void ADIS16364::x_gyro_offset(double value){
  write(XGYRO_OFF, twos_comp(value/0.0125));
}

////////////////////////////////////////////////////////////////////////////
//                    void y_gyro_offset(double value)
////////////////////////////////////////////////////////////////////////////
// Offset the Y - Axis gyro
////////////////////////////////////////////////////////////////////////////
// value - The amount of offset you want, in deg/sec
////////////////////////////////////////////////////////////////////////////
void ADIS16364::y_gyro_offset(double value){
  write(YGYRO_OFF, twos_comp(value/0.0125));
}

////////////////////////////////////////////////////////////////////////////
//                    void z_gyro_offset(double value)
////////////////////////////////////////////////////////////////////////////
// Offset the Z - Axis gyro
////////////////////////////////////////////////////////////////////////////
// value - The amount of offset you want, in deg/sec
////////////////////////////////////////////////////////////////////////////
void ADIS16364::z_gyro_offset(double value){
  write(ZGYRO_OFF,twos_comp(value/0.0125));
}

////////////////////////////////////////////////////////////////////////////
//                    void x_accel_offset(double value)
////////////////////////////////////////////////////////////////////////////
// Offset the X - Axis accelerometer
////////////////////////////////////////////////////////////////////////////
// value - The amount of offset you want, in g force
////////////////////////////////////////////////////////////////////////////
void ADIS16364::x_accel_offset(double value){
  write(XACCL_OFF, twos_comp(value));
}

////////////////////////////////////////////////////////////////////////////
//                    void y_accel_offset(double value)
////////////////////////////////////////////////////////////////////////////
// Offset the Y - Axis accelerometer
////////////////////////////////////////////////////////////////////////////
// value - The amount of offset you want, in g force
////////////////////////////////////////////////////////////////////////////
void ADIS16364::y_accel_offset(double value){
  write(YACCL_OFF, twos_comp(value));
}

////////////////////////////////////////////////////////////////////////////
//                    void z_accel_offset(double value)
////////////////////////////////////////////////////////////////////////////
// Offset the Z - Axis accelerometer
////////////////////////////////////////////////////////////////////////////
// value - The amount of offset you want, in g force
////////////////////////////////////////////////////////////////////////////
void ADIS16364::z_accel_offset(double value){
  write(ZACCL_OFF, twos_comp(value));
}

////////////////////////////////////////////////////////////////////////////
//                       void gyro_null()
////////////////////////////////////////////////////////////////////////////
// Perform an automatic gyro null, this will delay for 50 ms
////////////////////////////////////////////////////////////////////////////
// NOTES: Not Tested!
////////////////////////////////////////////////////////////////////////////
void ADIS16364::gyro_null(){
  write(GLOB_CMD, 0x0001);
  delay(50);
}

////////////////////////////////////////////////////////////////////////////
//                     void gyro_prec_null()
////////////////////////////////////////////////////////////////////////////
// Perform an automatic precision gyro null, This will delay for 30 s
////////////////////////////////////////////////////////////////////////////
// NOTES: Not Tested!
////////////////////////////////////////////////////////////////////////////
void ADIS16364::gyro_prec_null(){
  write(GLOB_CMD, 0x0010);
  delay(30000);
}

////////////////////////////////////////////////////////////////////////////
//                       void low_power_mode()
////////////////////////////////////////////////////////////////////////////
// Puts iSensor into low power mode, SCLK = 250 kHz
////////////////////////////////////////////////////////////////////////////
// NOTES: Not Tested!
////////////////////////////////////////////////////////////////////////////
void ADIS16364::low_power_mode(){
  // Set low power mode
  write(SMPL_PRD, 0x000A);
  // Set low power mode flag
  low_power = 1;
  // Change SPI clock to 250 kHz
  SPI.setClockDivider(SPI_CLOCK_DIV64);
  // delay just to be safe
  delay_cycle();
}

////////////////////////////////////////////////////////////////////////////
//                        void normal_mode()
////////////////////////////////////////////////////////////////////////////
// Puts iSensor into normal mode, SCLK = 1MHz
////////////////////////////////////////////////////////////////////////////
// NOTES: Not Tested!
////////////////////////////////////////////////////////////////////////////
void ADIS16364::normal_mode(){
  // Set low power mode
  write(SMPL_PRD, 0x0001);
  // Unset low power mode flag
  low_power = 0;
  // Change SPI clock to 1 MHz
  SPI.setClockDivider(SPI_CLOCK_DIV16);
  // delay just to be safe
  delay_cycle();
}

////////////////////////////////////////////////////////////////////////////
//                          void sleep()
////////////////////////////////////////////////////////////////////////////
// Puts iSensor into indefinite sleep mode
// to awake device, call wake(), or cycle power
////////////////////////////////////////////////////////////////////////////
// NOTES: Not Tested!
////////////////////////////////////////////////////////////////////////////
void ADIS16364::sleep(){
  write(SLP_CNT, 0x0100);
}

////////////////////////////////////////////////////////////////////////////
//                        void sleep(double dur)
////////////////////////////////////////////////////////////////////////////
// Puts iSensor into sleep mode for a specified duration
////////////////////////////////////////////////////////////////////////////
// dur - Sleep duration in seconds
////////////////////////////////////////////////////////////////////////////
// NOTES: Not Tested!
////////////////////////////////////////////////////////////////////////////
void ADIS16364::sleep(double dur){
  write(SLP_CNT, ( (unsigned int)(dur / 0.5) ) & 0x00FF);
}

////////////////////////////////////////////////////////////////////////////
//                            void wake()
////////////////////////////////////////////////////////////////////////////
// Wakes up iSensor from sleep
////////////////////////////////////////////////////////////////////////////
// NOTES: Not Tested!
////////////////////////////////////////////////////////////////////////////
void ADIS16364::wake(){
    digitalWrite(CS, LOW);
    delay_cycle();
    digitalWrite(CS, HIGH);
}

////////////////////////////////////////////////////////////////////////////
//                      void factory_reset()
////////////////////////////////////////////////////////////////////////////
// Perform factory reset on iSensor
////////////////////////////////////////////////////////////////////////////
void ADIS16364::factory_reset(){
  write(GLOB_CMD, 0x0002);
  delay(50);
}



////////////////////////////////////////////////////////////////////////////
//                       **** PRIVATE METHODS ****
////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////
//                        void set_SPI()
////////////////////////////////////////////////////////////////////////////
// Sets SPI to normal mode
////////////////////////////////////////////////////////////////////////////
void ADIS16364::set_SPI(void){
  // Set to MSB first
  SPI.setBitOrder(MSBFIRST);
  // Set to SPI mode 3
  SPI.setDataMode(SPI_MODE3);
  // Set SPI clock, 1 MHz
  SPI.setClockDivider(SPI_CLOCK_DIV16);
}

////////////////////////////////////////////////////////////////////////////
//                        void delay_cycle()
////////////////////////////////////////////////////////////////////////////
// Delays Arduino for once SCLK cycle
////////////////////////////////////////////////////////////////////////////
void ADIS16364::delay_cycle(){
  if(low_power){
    // if low power mode, delay for 1/250e3
    delayMicroseconds(4);
  }else{
    // if normal mode delay for 1/1e6
    delayMicroseconds(1);
  }
}  
