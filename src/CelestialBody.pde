import java.math.*;

class CelestialBody{
  PVector position, velocity, acceleration;
  String name, type, textureOverlay;
  float mass, density, radius, INIT_MASS, rotationSpeed, ORBIT_OBLIQUITY;
  ArrayList<Trail> coordX, coordY, coordZ;
  PShape object;
  
  HashMap<String, Object> information;

  public CelestialBody(String name, String type, float mass, float density, float startX, float startY, float startZ, PVector velocity, float rotation, float obliquity, String texture){
    this.name = name;
    this.type = type;
    this.mass = this.INIT_MASS = mass;
    this.density = density;
    this.velocity     = velocity;
    this.position     = new PVector(startX, startY, startZ);
    this.acceleration = new PVector(0, 0, 0);
    this.textureOverlay = texture;
    this.rotationSpeed = rotation;
    this.ORBIT_OBLIQUITY = obliquity;
    
    this.radius = this.getRadius();
    
    this.coordX = new ArrayList<Trail>();
    this.coordY = new ArrayList<Trail>();
    this.coordZ = new ArrayList<Trail>();
    
    this.information = new HashMap<String, Object>();
    
    this.updateInformation();
    this.createObject();
  }
  
  PVector attract(CelestialBody object){
    //Find resultant force between position of this object and the other object
    PVector d = PVector.sub(this.position, object.position);
    //Find distance (length) of d
    float distance = d.mag()*pow(10, 8);
    //Force = (Gravity_Constant*Mass_Of_Object_1*Mass_Of_Object_2)/(distance^2)
    double s = ((double) G*this.mass*object.mass)/(distance*distance);
    float strength = (float) s/(simSpeed*simSpeed)*pow(10, 8);
    
    if(this.name=="Mercury" && object.getLabel()=="Sun") println("Period: " + (2*3.1415*distance/this.getVelocity().mag()));
    
    //Force of a vector = magnitude*direction
    d.setMag(strength);
    
    return d;
  }
  
  void updateInformation(){ //Assigns in the current information regarding a object
    String displayType = this.type == "RingPlanet" ? "Planet" : this.type; //Makes sure that planets of type RingPlanet return planet as their display name
  
    this.information.put("Name"    , this.name);
    this.information.put("Type"    , displayType);
    this.information.put("Mass"    , this.mass + "kg");
    this.information.put("Diameter", this.getRadius()*2 + "km");
    this.information.put("Density" , this.density + "g/cm³");
    this.information.put("Velocity", this.getVelocity().mag() + "m/s");
  }
  
  void createObject(){
    noStroke(); //Removes outline on sphere
    pushMatrix();
    sphereDetail(30); //Sets the detail of the sphere. More detail = more tesselations
    fill(255, 255, 255, 255); //Manual reset of fill
    this.object = createShape(SPHERE, this.radius/pow(10, 4)); //Creates sphere with the radius pre-calculated    
    this.object.setTexture(loadImage(this.textureOverlay)); //Sets the texture of the sphere
    //this.object.rotateZ(radians(this.ORBIT_OBLIQUITY));
    popMatrix();
    lScreen.initialised();
  }
  
  void applyMassChanges(){
    this.updateRadius();
    this.createObject();
  }
   
  void setCoords(){
    float trailLength = 255; //Default allocation of positional points

    this.coordX.add(new Trail(this.position.x, int(trailLength))); //Stores X points
    this.coordY.add(new Trail(this.position.y, int(trailLength))); //Stores Y points
    this.coordZ.add(new Trail(this.position.z, int(trailLength))); //Stores Z points
    
    if(this.coordX.size() >= trailLength){ //If the size of the list is bigger than 255 then start deleting the initial points
      this.coordX.remove(0);
      this.coordY.remove(0);
      this.coordZ.remove(0);
    }
  }
  
  void getInformation(){
    this.updateInformation();
    cam.beginHUD(); //Prevents Camera from interferring with text
    fill(255);
    textSize(26); //Size of text
    textAlign(LEFT); //Alligns text to left side of window
    text("" + this.information.get("Name"),     1150, 300); //--Displays information about object
    fill(255, 255, 255);
    textSize(20);
    text("" + this.information.get("Type"),     1150, 323);
    text("" + this.information.get("Mass"),     1150, 346);
    text("" + this.information.get("Diameter"), 1150, 369);
    text("" + this.information.get("Density"),  1150, 392);
    text("" + this.information.get("Velocity"), 1150, 415); //--
    cam.endHUD();
  }
  
  void updateRadius(){
    //V = m/ρ
    double volume = this.mass/this.density;
    //V = 4/3*PI*r^3
    //Convert to km^3
    volume /= pow(10, 9);
    //--Rearranges equation for radius
    double radiusCubed = volume/PI;
    radiusCubed *= float(3)/4;
    //--
    double radius = Math.pow(radiusCubed, float(1)/3);
    this.radius = (float) radius;
  }
  
  int getRadius(){
    this.updateRadius(); //Makes sure that the radius is correct and hasn't changed
    return (int) this.radius; //Returns the radius, truncating the decimal part as it is not necessary for calculations  
  }
  
  float getScaledRadius(){
    this.updateRadius(); //Makes sure that the radius is correct and hasn't changed
    return this.radius/pow(10, 4); //Returns the radius, scaled to the simulation
  }
  
  int getScaledVelocity(){
    float vel = this.velocity.mag()*simSpeed;
    return (int) vel; //Returns the velocity, relative to simulation speed
  }
  
  PVector getPosition(){ return this.position; }
  PVector getVelocity(){ return this.velocity; }
  float getMass(){ return this.mass; }
  float getDensity(){ return this.density; }
  float getRotationSpeed(){ return this.rotationSpeed/ (pow(10, 8)*simSpeed); } //Returns the real rotation speed of the object
  float getOrbitObliquity(){ return this.ORBIT_OBLIQUITY; }
  String getType(){ return this.type; }
  String getLabel(){ return this.name; }
  String getTexture(){ return this.textureOverlay; }
  
  void setMass(float newMass){ this.mass = newMass; }
  void setDensity(float newDensity){ this.density = newDensity; }
  void setRotationSpeed(float newSpeed){ this.rotationSpeed = newSpeed; }
   
  //Newton's 2nd Law F = MA
  void applyForce(PVector f){
    //A = F/M
    PVector accel = PVector.div(f, this.mass);
    acceleration.add(accel);
  }
  
  void update(){
    //Assuming t = +1s since last update
    this.velocity.add(this.acceleration);
    this.position.add(this.velocity);
    
    //Reset acceleration to 0
    this.acceleration = new PVector(0, 0, 0);
    
    this.object.rotateY(this.rotationSpeed);
  }
  
  void setupRings(){
    noStroke(); //Removes outline
    pushMatrix();

    translate(this.position.x, this.position.y, this.position.z);
    
    strokeWeight(4); //Size of one ring
    noFill(); //Do not fill in the ellipse
    for(int i = 0; i<32; i++){ //Number of rings to draw
      if(i < 10){
        stroke(222-(i*2), 184-(i*2), 150-(i*2)); //Outline Colour
        ellipse(0, 0, (this.radius/pow(10, 4)*7)+(i+32), (this.radius/pow(10, 4)*7)+(i+32)); //Draw ring
      }
      else if(i < 12){
        stroke(0, 0, 0); //Outline Colour
        ellipse(0, 0, (this.radius/pow(10, 4)*7)+(i+22), (this.radius/pow(10, 4)*7)+(i+22)); //Draw ring  
      }
      else{
        stroke(222-(i*2), 184-(i*2), 150-(i*2)); //Outline Colour
        ellipse(0, 0, (this.radius/pow(10, 4)*7)+(i), (this.radius/pow(10, 4)*7)+(i)); //Draw ring  
      }
    }
    noStroke(); //removes outline from future updates
    popMatrix();
  }

  void display(){
    beginShape();
    noStroke(); //Remove outline
    pushMatrix();
    translate(this.position.x, this.position.y, this.position.z); //Translate object to require coordinate
    //this.object.rotateZ(radians(this.getRotationSpeed()));
    sphereDetail(30);
    shape(this.object); //Draw object
    popMatrix();

    if(this.type == "RingPlanet") this.setupRings(); //Setups up rings if object is a ring object
    endShape();
  }
  
  void displayCoords(){
    beginShape();
    for(int i = 1; i<this.coordX.size(); i++){ //Start at 1 to prevent i-1 being less than 0
      if(this.coordX.get(i) != null && this.coordY.get(i) != null && this.coordZ.get(i) != null){
        this.coordX.get(i).opacity--; //Decreases opacity/visibily of coordinates to give a fading effect
        this.coordY.get(i).opacity--;
        this.coordZ.get(i).opacity--;
        strokeWeight(3);
        stroke(255, 255, 255, this.coordX.get(i).opacity); //Setup stroke as white with opacity
        //Draw lines to connect two points together
        line(this.coordX.get(i-1).coord, this.coordY.get(i-1).coord, this.coordZ.get(i-1).coord, this.coordX.get(i).coord, this.coordY.get(i).coord,this.coordZ.get(i).coord);
      }
    }
    endShape();
  }
}

class Trail{ //Class used to create a new trail
  float coord, opacity;
  
  public Trail(float coord, float lengthOfTrail){
    this.coord = coord;
    this.opacity = lengthOfTrail;
  }
}
