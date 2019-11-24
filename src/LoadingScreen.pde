class LoadingScreen{
  public ArrayList<Planet> planets;
  public PGraphics pg;
  public int loadedInit, totalObj;
  
  public LoadingScreen(int tObj){
    this.planets = new ArrayList<Planet>();
    this.pg = createGraphics(125, 125);
    this.loadedInit = 0;
    this.totalObj = tObj;
  }
  
  void setupPlanets(){
    for(int i = 0; i<11; i++) planets.add(new Planet(i*10*1.5, 6*1.5, 3.75, i));  
  }
  
  void initialised(){ this.loadedInit++; }
  
  void display(){
    for(int i = 0; i<planets.size(); i++){
      for(int j = 0; j<2; j++) planets.get(i).display(); //Runs twice to prevent 'skipping' of frames causing breakes in the orbits
    }
    this.displayInfo();
  }
  
  void displayInfo(){
    pg.beginDraw();
    pg.background(0);
    pg.fill(255, 255, 255, 255);
    pg.textSize(32);
    pg.text(this.loadedInit + "/" + this.totalObj, 25, 25);
    pg.endDraw();
    image(pg, -100, 300);   
  }
}

class Planet{
  float ORBIT, SPEED, SIZE, INIT_ANGLE, angle;

  public Planet(float orbit, float size, float speed, float a) {
    this.ORBIT = orbit;  
    this.SIZE = size;
    this.SPEED = speed;
    this.INIT_ANGLE = a;
    this.angle = a+0.01;
    this.create();
  }

  void create() {
    fill(255, 255, 255);
    ellipse(0, 0, this.SIZE, this.SIZE);
  }
  
  void display(){
    if(this.angle-this.INIT_ANGLE >= 2*PI){
      background(0);
      this.angle = this.INIT_ANGLE;
    }
    
    pushMatrix();
    rotate(this.angle);
    translate(this.ORBIT, 0);
    ellipse(0, 0, this.SIZE, this.SIZE);
    popMatrix();
    
    this.angle += 0.01*this.SPEED;
  }
}

void showLoading(){
  switch(loadingPhase){
    case 1:
      background(0);
      loadingPhase = 2;
      break;
    case 2:
      cam.beginHUD();
      fill(255, 255, 255);
      textSize(32);
      textAlign(CENTER);
      text("Loading...", width/2, height/2+300);      
      pushMatrix();
      translate(width/2, height/2);
      lScreen.display();
      popMatrix();
      cam.endHUD();
      break;
    case 3:
      drawUI();
      loadingPhase = 0;
      break;
  }
}
