import java.awt.Font;
import java.awt.font.FontRenderContext;
import java.awt.geom.AffineTransform;

public class MainInterface{
  public ArrayList<Window> layers;

  public MainInterface(){
    this.layers = new ArrayList<Window>();
  }

  void setupButtons(){
    layers.add(new Window(        0,    height-37,  width,    34, "bg")); //Creates background for buttons
    layers.add(new WindowTypeable(0,    height-37,  width/15, 34, "speed", 6)); //Adds in simulation speed window
    layers.add(new WindowText(    90,   height-37,  width/10, 34, "time", "Seconds")); //Adds in simulation time window
    layers.add(new WindowTypeable(1150, height-438, width/10, 20, "mass", 6)); //Adds in mass of object window 
    layers.add(new WindowTypeable(227,  height-37,  width/30, 34, "ZoomSpeed", 3));
    layers.add(new WindowText(    273,  height-37,  width/10, 34, "ZoomSpeed", "Scroll Speed"));
    layers.add(new WindowCascade( 410,  height-37,  width/20, 34, "cBodySelector",  9));
    layers.add(new WindowCascade( 478,  height-37,  width/10, 34, "Main Menu", 4));
  }
  
  void displayButtons(){
    for(int i = 0; i<layers.size(); i++) layers.get(i).display();  
  }
}

public class Window{
  public float posX, posY, h, w;
  public String use;

  public Window(float x, float y, float w, float h, String u){
    this.posX = x;
    this.posY = y;
    this.w = w;
    this.h = h;
    this.use = u;
  }

  void display(){
    if(this.use.contains("celestialBody")){
      int objectNumber = Integer.valueOf(this.use.replaceAll("[^0-9]", ""));
      stroke(255, 255, 255);
      noFill();
      ellipse(this.posX+this.w/2, this.posY+this.h/2, this.w, this.h);
      fill(255, 255, 255);
      textSize(22);
      text(getObjectName(objectNumber), this.posX+this.w/2, this.posY+this.h/2);
    }
    else if(this.use.contains("file")){
      String objectNumber = this.use.replaceAll("file", "");
      stroke(255, 255, 255);
      noFill();
      rect(this.posX, this.posY, this.w, this.h);
      fill(255, 255, 255);
      textSize(22);
      text(objectNumber, this.posX+this.w/2, this.posY+this.h/2);
    }
    else{
      strokeWeight(2);
      stroke(255, 255, 255); //Colour the outline in the window
      fill(0, 0, 0);
      rect(this.posX, this.posY, this.w, this.h); //Display window
    }
    noStroke();
  }
}

public class Button extends Window{        
  public Button(float x, float y, float w, float h, String u){
    super(x, y, w, h, u);
  }

  boolean checkMousePosition(){
    if ((mouseX > super.posX && mouseX < super.posX+super.w) && (mouseY > super.posY && mouseY < super.posY+super.h)) return true; //Checks to see if mouse is over the window
    else return false;
  }
}

public class WindowCascade extends Button{
  public ArrayList<Button> buttonList;
  public boolean open;
  
  public WindowCascade(float x, float y, float w, float h, String u, int n){
    super(x, y, w, h, u);
    this.buttonList = new ArrayList<Button>();
    this.open = false;
    
    this.setupArray(n, y, h); //Sets up the number of buttons
  }
  
  
  void setupArray(int n, float y, float h){
    if(super.use == "cBodySelector"){
      for(int i = 0; i<n; i++) this.buttonList.add(new Button((i+1)*width/11, y-120, h*3, h*3, "celestialBody" + i));
    }
    else if(super.use == "Main Menu"){
      this.buttonList.add(new Button(width/2-3*h/2, height/2-w,   h*3, h*2, "fileSave"));
      this.buttonList.add(new Button(width/2-3*h/2, height/2-w/2, h*3, h*2, "fileLoad"));
      this.buttonList.add(new Button(width/2-3*h/2, height/2,     h*3, h*2, "fileReload"));
      this.buttonList.add(new Button(width/2-3*h/2, height/2+w/2, h*3, h*2, "fileExit"));
    }
  }
  
  void update(){
    if(mousePressed){
      if(super.checkMousePosition() && !this.open) this.open = true;
      else if(!super.checkMousePosition()) this.open = false;
    }
  }
  
  void fileHandling(int swtch){
    if(swtch == 0) main.layers.add(new WindowTypeable(width/2-width/10, height/2-17, width/5, 34, "inputName", 20));
    else if(swtch == 1) main.layers.add(new WindowTypeable(width/2-width/10, height/2-17, width/5, 34, "outputName", 20));
    else if(swtch == 2) reset("reload");
    else if(swtch == 3) exit();
    else return;
  }
  
  void placeObject(int swtch){
    CelestialBody cBody = createCelestialBody(swtch, cam.getPosition()[0], cam.getPosition()[1], cam.getPosition()[2]);
    objects.add(cBody);
  }
  
  void display(){
    if(this.open){
      for(int i = 0; i<this.buttonList.size(); i++){
        if(buttonList.get(i).checkMousePosition() && mousePressed){ //If player selects a button
          if(this.use == "cBodySelector") placeObject(i);
          else if(this.use == "Main Menu") this.fileHandling(i);
        }
        else buttonList.get(i).display(); //Else, just display the buttons
      }
    }
    
    this.update();
    super.display();
    
    fill(255, 255, 255);
    textSize(22);
    //textAlign(CENTER); //Alligns the text to be center in the window
    String text = super.use == "cBodySelector" ? "+" : super.use;
    text(text, super.posX+(super.w/2), super.posY+(super.h/2)+7); //Displays the text
  }
}

public class WindowTypeable extends Button{
  public String input;
  public boolean canType;
  public int cooldown, value, charLength;

  public WindowTypeable(float x, float y, float w, float h, String u, int l){
    super(x, y, w, h, u);
    //this.input = "1"; //Default value should be one to display
    this.cooldown = 10;
    this.value = 0;
    this.charLength = l;
    
    if(u == "inputName" || u == "outputName" || u == "celestialBody"){
      this.input = "";
      this.canType = true;
    }
    else{
      this.input = "1";
      this.canType = false;
    }
  }
  
  void submitValue(){
    if(super.use == "speed"){
      if(this.value > 100000){
        this.value = 100000; //If the value is bigger than 100,000 then set the value to be 100,000
        this.input = String.valueOf(this.value);
      }
      changeSpeed(this.value); //Changes the speed of the simulation for the objects  
    }
    else if(super.use == "mass") changeMass(this.value); //Changes the mass of the objects  
    else if(super.use == "ZoomSpeed"){
      if(this.value > 100){
        this.value = 100; //If the value is bigger than 100 then set the value to be 100
        this.input = String.valueOf(this.value);
      }
      cam.setWheelScale(this.value); //Sets scaling speed
    }
    else if(super.use == "inputName"){
      saveToFile(this.input);
      main.layers.remove(this); //Removes the window from the list
    }
    else if(super.use == "outputName"){
      loadFromFile(this.input);
      main.layers.remove(this); //Removes the window from the list
    }
  }
  
  void addKeyToInput(){
    if(this.input.length() < this.charLength) this.input += key;
    keyPressed = !keyPressed;
  }

  void getInput(){
    if(keyPressed && this.cooldown == 0){ //Checks if an input is entered
      if(key == RETURN || key == ENTER){
        if(super.use == "inputName" || super.use == "outputName") this.submitValue();
        else{
          int newValue = 0;
          try{  
            newValue = Integer.valueOf(this.input); //Gets the integer value of the input
          }catch (NumberFormatException e){
            messages.add(new Message("Number is too big!", 180));
            this.input = "1";
          }
          
          if(newValue != 0){ 
            this.value = newValue; //Sets the value to be the new one
            this.input = Integer.toString(this.value); //Sets the input (displayed to user) as the value it now has, in String form
            this.submitValue();
          }
        }
      }
      else if(key == BACKSPACE && this.input.length() > 0) this.input = this.input.substring(0, this.input.length()-1); //Reduces the inputs length by 1 for user to delete last inputted character
      else if(Character.isDigit(key)) this.addKeyToInput(); //If the character input is a digit, enter it into the input string
      else if(Character.isLetter(key) && (super.use == "inputName" || super.use == "outputName")) this.addKeyToInput();
      
      this.cooldown = 8; //Increase the cooldown so the user has to wait 8 frames (~0.075s) before inputting anymore characters to prevent tapping a key entering multiple times
    }
  }

  void update(){   
    if(this.canType) this.getInput(); //Try to get input from user
    if(mousePressed && cooldown == 0) { //If the user clicks
      if(super.checkMousePosition()) this.canType = true;
      else{
        if(super.use == "inputName" || super.use == "outputName") main.layers.remove(this); //Removes the window from the list
        else this.canType = false;
      }
    }
  }

  void display(){   
    this.update();
    
    int textSizeModifier = int(super.h/20); //This value scales down the text based on the height of the window
    
    FontRenderContext fontRender = new FontRenderContext(new AffineTransform(), true, true); //Class instantiation from library
    Font font = new Font("SansSerif", Font.PLAIN, 23-textSizeModifier); //Class instantiation from library for font sizing
    int textWidth = (int) (font.getStringBounds(this.input, fontRender).getWidth()); //Get width of font
    int textHeight = (int) (font.getStringBounds(this.input, fontRender).getHeight()); //Get width of font
    
    if((super.use == "mass" && this.canType) || super.use != "mass"){
      super.display();
      fill(255, 255, 255);
      textAlign(LEFT); //Alligns text to left side of window
      textSize(20-textSizeModifier);
      text(this.input, super.posX+2, super.posY+(super.h/2)+textHeight/3); //Displays the input on the window
      
      if(this.canType){
        stroke(0, 255, 0); //Set outline to be green if the user is selected on it
        line(super.posX+textWidth+2+2, super.posY+1, super.posX+2+2+textWidth, super.posY-1+super.h); //Display the cursor for the user as they type
      }
    }

    if(this.cooldown > 0) this.cooldown--;
  }
}

public class WindowText extends Window{
  public String text;

  public WindowText(float x, float y, float w, float h, String u, String t){
    super(x, y, w, h, u);
    this.text = t;
  }

  void display(){
    super.display(); //Diplays the window
    fill(0, 255, 0);
    textAlign(CENTER); //Alligns the text to be center in the window
    text(this.text, super.posX+(super.w/2), super.posY+(super.h/2)+5); //Displays the text
  }
}

public class Message{
  public String msg;
  public int time;
  
  public Message(String m, int t){
    this.msg = m;
    this.time = t;
  }
  
  void display(int offset){
    textSize(26);
    textAlign(CENTER);
    text(msg, width/2, height/5+offset);
    time--;
  }
}

void displayOutlines(){  
  if(objects.size() == objectFocus) return;
  float distance = sqrt(pow(cam.getPosition()[0]-objects.get(objectFocus).position.x, 2)+pow(cam.getPosition()[1]-objects.get(objectFocus).position.y, 2)+pow(cam.getPosition()[2]-objects.get(objectFocus).position.z, 2));
  float size = distance/50;
  if(size > 50){
    sphereDetail(30);
    float opacity = size-50 < 32 ? size-50 : 32; //Maximum opacity should be 32
    
    for(int i = 0; i<objects.size(); i++){   
      fill(255, 255, 255, opacity);
      
      pushMatrix();
      translate(objects.get(i).getPosition().x, objects.get(i).getPosition().y, objects.get(i).getPosition().z);
      sphere(objects.get(i).getScaledRadius() + distance/75);
      popMatrix();
    }
  }
}

void drawUI() {
  displayOutlines();
  
  cam.beginHUD(); //Prevents the camera from interferring with the UI elements
  main.displayButtons(); //Diplays all the windows/UI elements
  
  if(messages.size() > 0){
    for(int i = 0; i<messages.size(); i++){
      messages.get(i).display(i*50);
      if(messages.get(i).time == 0) messages.remove(i);
    }
  }
  cam.endHUD();
}