#include <AFMotor.h>

// Stepper motor with 200 steps per revolution (1.8 degree) connected to motor port #1 (M1 & M2)
AF_Stepper motor(200, 1);

int steps = 0;
long mus_per_step = 0;
int operation = 0;
String speedandsteps;

void setup() {
  Serial.begin(9600); // set up Serial library at 9600 bps
}

void loop() {
  if(operation > 0){
    motor.setSpeedMicroseconds(mus_per_step);
    if(steps >= 0){
      motor.step(steps, BACKWARD, SINGLE);
    }else{
      motor.step(-steps, FORWARD, SINGLE);
    }
    operation = 0;
  } else {//If no operation then see if there is an input
    if(Serial.available() > 0) {
      speedandsteps = Serial.readString();
      int str_len = speedandsteps.length() + 1;
      char charBuf[str_len];
      speedandsteps.toCharArray( charBuf, str_len );
      char * strtokIndx;
      strtokIndx = strtok(charBuf,",");
      mus_per_step = atol(strtokIndx);
      strtokIndx = strtok(NULL, ",");
      steps = atoi(strtokIndx);
      operation = 1;
    }
  }
  delay(50);
}
