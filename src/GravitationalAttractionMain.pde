import peasy.*;

ArrayList<CelestialBody> objects;
ArrayList<Message> messages;
PeasyCam cam;
int objectFocus, inputCooldown, loadingPhase;

float simSpeed = pow(10, 4);
float G = 6.67408*pow(10, -11);

MainInterface main = new MainInterface();
LoadingScreen lScreen;

void setup() {
  fullScreen(P3D);
  //size(1200, 600, P3D);
  background(0);
  frameRate(60);
  
  //Instantiate PeasyCam for camera work
  cam = new PeasyCam(this, width/2);
  cam.setResetOnDoubleClick(false); //Prevents double clicking resetting camera
  cam.setWheelScale(1); //Set scaling speed
  perspective(PI/3, float(width)/height, 1, 3000000); //Camera render distance/default angular values
  
  messages = new ArrayList<Message>(); //Creates a list of type Message
  objects = new ArrayList<CelestialBody>(); //Creates a list of type Celestial Body
  main.setupButtons(); //Sets up buttons
  
  objectFocus = inputCooldown = 0;
  loadingPhase = 1;
  lScreen = new LoadingScreen(9);
  lScreen.setupPlanets();
 
  thread("setupObjects");
}

void draw(){
  if(loadingPhase == 0){
    background(0); //Resets the background to black to 'reset' the screen
    
    if(cam != null && (objects != null && objects.size() > 0)){
      cam.lookAt(objects.get(objectFocus).getPosition().x, objects.get(objectFocus).getPosition().y, objects.get(objectFocus).getPosition().z, 0L); //Look at planet currently chosen
      
      updateObjects(); //Updates and displays the new positions of the objects and other celestial bodies since last frame
      drawUI(); //Draws the UI
    }
    
    if(keyPressed && inputCooldown == 0) checkInput(); //Gets the input from the keyboard, providing an input has not been recently gotten
    
    if(inputCooldown > 0) inputCooldown--;
  }
  else showLoading();
}

void updateObjects(){
   for(int i = 0; i<objects.size(); i++){ //Loop through list of objects
     for(int j = 0; j<objects.size(); j++){ //For each object, apply attraction to currently looped object
       if(i != j){ //Do not attract object to itself
         detectCollision(i, j); //Detect collision between objects
         if(i != objects.size() && j != objects.size()){ //Breaks out of method to prevent a crash if an object collides and therefore no longer exists
           PVector objectForce = objects.get(j).attract(objects.get(i)); //Get force from other object
           objects.get(i).applyForce(objectForce); //Apply force to this object
         }
       }
     }
     
     objects.get(i).update(); //Update the object
     objects.get(i).setCoords(); //Set the coordinates for the trail
     objects.get(i).displayCoords(); //Display the trail
     objects.get(i).display(); //Display object
   }
   
   objects.get(objectFocus).getInformation(); //Displays information of the currently selected object
}

void detectCollision(int i, int j){
  PVector distance = PVector.sub(objects.get(i).getPosition(), objects.get(j).getPosition());
  float dis = distance.mag();
  //If the distance is smaller than the radii combined then the objects must be inside/touching each other
  if(dis <= objects.get(i).getScaledRadius()+objects.get(j).getScaledRadius()) this.collide(objects.get(i), objects.get(j));    
}

void collide(CelestialBody cBody1, CelestialBody cBody2){ 
  float vol1 = cBody1.getMass()/cBody1.getDensity();
  float vol2 = cBody2.getMass()/cBody2.getDensity();
  float totalVol = vol1 + vol2; //Gets the total volume of the two object
  
  if(cBody1.getMass() > cBody2.getMass()){
    cBody1.setMass(cBody1.getMass()+cBody2.getMass());
    cBody1.setDensity(cBody1.getMass()/totalVol);
    cBody1.updateRadius();
    removeObject(cBody2);
  }
  else{
    cBody2.setMass(cBody2.getMass()+cBody1.getMass());
    cBody2.density = cBody2.getMass()/totalVol;
    cBody2.updateRadius();  
    removeObject(cBody1);
  }
}

void removeObject(CelestialBody object){
  int index = objects.indexOf(object);
  if(index == objectFocus && objectFocus == objects.size()-1) objectFocus = 0; //Resets to the first object in the list to prevent crashing due to camera trying to follow a now non-existent object
  objects.remove(object);
}
