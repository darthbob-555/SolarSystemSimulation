void changeSpeed(int newSpeed){
  float difference = simSpeed/ (pow(10, 8)/newSpeed); //Find the difference between the old simulation speed and new one
  simSpeed = pow(10, 8)/newSpeed; //Set the simulation speed to be the default value/the new speed

  for(int i = 0; i<objects.size(); i++){
    objects.get(i).getVelocity().mult(difference); //Update the velocity of objects by the difference in simulation speed
    objects.get(i).setRotationSpeed(objects.get(i).getRotationSpeed()*difference);
  }
}

void changeMass(int multiplier){
  //If there is a change of mass
  if(objects.get(objectFocus).getMass() != objects.get(objectFocus).INIT_MASS*multiplier){
    objects.get(objectFocus).setMass(objects.get(objectFocus).INIT_MASS*multiplier);
    objects.get(objectFocus).applyMassChanges();
  }
}

void checkInput(){
  if(key == '+') nextobject(1); //Moves up in orbits to next object
  else if(key == '-') nextobject(-1); //Moves down in orbits to next object
}

void nextobject(int swtch){
  if(objectFocus+swtch >= 0 && objectFocus+swtch <= objects.size()-1){ //Prevents going pass furthest object or nearest object and crashing program
    objectFocus += swtch; //Increase/decreases based on input
    inputCooldown = 15; //Prevents user from inputting for another 15 frames ~0.25s
  }
}

void setupObjects(){
  //                             Name,      Type,        Mass,              Density, StartX, StartY,                      StartZ,                     Velocity,                          RotationSpeed,     FileName   
  objects.add(new CelestialBody("Sun",     "Star",       1.989*pow(10, 30), 1410,    0,      0,                           0,                          new PVector(0, 0, 0),              1/ (float)2114208,  0,    "sun.png"));
  objects.add(new CelestialBody("Mercury", "Planet",     3.301*pow(10, 23), 5430,    0,      57.5 *pow(10, 9)/pow(10, 8), 7.06*pow(10, 9)/pow(10, 8), new PVector(47400/simSpeed, 0, 0), 1/ (float)5067360,  0,    "mercury.png"));
  objects.add(new CelestialBody("Venus",   "Planet",     4.867*pow(10, 24), 5240,    0,      108.0*pow(10, 9)/pow(10, 8), 6.40*pow(10, 9)/pow(10, 8), new PVector(35000/simSpeed, 0, 0), 1/ (float)20996928, 178,  "venus.png"));
  objects.add(new CelestialBody("Earth",   "Planet",     5.972*pow(10, 24), 5510,    0,      149.6*pow(10, 9)/pow(10, 8), 0,                          new PVector(30000/simSpeed, 0, 0), 1/ (float)86400,    23.4, "earth.png"));
  objects.add(new CelestialBody("Mars",    "Planet",     6.417*pow(10, 23), 3940,    0,      227.8*pow(10, 9)/pow(10, 8), 7.38*pow(10, 9)/pow(10, 8), new PVector(24100/simSpeed, 0, 0), 1/ (float)88646,    5,    "mars.png"));
  objects.add(new CelestialBody("Jupiter", "Planet",     1.898*pow(10, 27), 1326,    0,      778.3*pow(10, 9)/pow(10, 8), 17.9*pow(10, 9)/pow(10, 8), new PVector(13100/simSpeed, 0, 0), 1/ (float)1024704,  3.08, "jupiter.png"));
  objects.add(new CelestialBody("Saturn",  "RingPlanet", 5.680*pow(10, 26), 687,     0,      1428 *pow(10, 9)/pow(10, 8), 62.1*pow(10, 9)/pow(10, 8), new PVector(9700 /simSpeed, 0, 0), 1/ (float)2545344,  26.7, "saturn.png"));
  objects.add(new CelestialBody("Uranus",  "Planet",     8.680*pow(10, 25), 1270,    0,      2871 *pow(10, 9)/pow(10, 8), 38.6*pow(10, 9)/pow(10, 8), new PVector(6800 /simSpeed, 0, 0), 1/ (float)62208,    97.9, "uranus.png"));
  objects.add(new CelestialBody("Neptune", "Planet",     1.020*pow(10, 26), 1638,    0,      4496 *pow(10, 9)/pow(10, 8), 139 *pow(10, 9)/pow(10, 8), new PVector(5400 /simSpeed, 0, 0), 1/ (float)57888,    29.6, "neptune.png"));  
  
  loadingPhase = 3;
}

CelestialBody createCelestialBody(int celestialBody, float x, float y, float z){
  String name = getObjectName(celestialBody);
  int clone = 1;
  boolean sameName = true;
  
  name += " Clone" + clone;
  
  NameLoop: //Name of the loop to allow breaking
  while (sameName){
    sameName = false;
    for(int i = 0; i<objects.size(); i++){
      if(name == objects.get(i).name){ //If the name of the object already exists
        clone++; //Increase the clone part of the name
        sameName = true;
        continue NameLoop; //Restarts the loop
      }
    }
  }
  
  switch(celestialBody){
    case 0:  return new CelestialBody(name, "Star",       1.989*pow(10, 30), 1410, x, y, z, new PVector(5000/simSpeed, 0, 0), 1/(2114208),  0,    "sun.png");
    case 1:  return new CelestialBody(name, "Planet",     3.301*pow(10, 23), 5430, x, y, z, new PVector(5000/simSpeed, 0, 0), 1/(5067360),  0,    "mercury.png");
    case 2:  return new CelestialBody(name, "Planet",     4.867*pow(10, 24), 5240, x, y, z, new PVector(5000/simSpeed, 0, 0), 1/(20996928), 23.4, "venus.png");
    case 3:  return new CelestialBody(name, "Planet",     5.972*pow(10, 24), 5510, x, y, z, new PVector(5000/simSpeed, 0, 0), 1/(86400),    178,  "earth.png");
    case 4:  return new CelestialBody(name, "Planet",     6.417*pow(10, 23), 3940, x, y, z, new PVector(5000/simSpeed, 0, 0), 1/(88646),    5,    "mars.png");
    case 5:  return new CelestialBody(name, "Planet",     1.898*pow(10, 27), 1326, x, y, z, new PVector(5000/simSpeed, 0, 0), 1/(1024704),  3.08, "jupiter.png");
    case 6:  return new CelestialBody(name, "RingPlanet", 5.680*pow(10, 26), 687,  x, y, z, new PVector(5000/simSpeed, 0, 0), 1/(2545344),  26.7, "saturn.png");
    case 7:  return new CelestialBody(name, "Planet",     8.680*pow(10, 25), 1270, x, y, z, new PVector(5000/simSpeed, 0, 0), 1/(62208),    97.9, "uranus.png");
    case 8:  return new CelestialBody(name, "Planet",     1.020*pow(10, 26), 1638, x, y, z, new PVector(5000/simSpeed, 0, 0), 1/(57888),    29.6, "neptune.png");  
    default: return null;
  }
}

String getObjectName(int cBody){
  switch(cBody){
    case 0:  return "Sun";
    case 1:  return "Mercury";
    case 2:  return "Venus";
    case 3:  return "Earth";
    case 4:  return "Mars";
    case 5:  return "Jupiter";
    case 6:  return "Saturn";
    case 7:  return "Uranus";
    case 8:  return "Neptune";
    default: return "null";
  }
}