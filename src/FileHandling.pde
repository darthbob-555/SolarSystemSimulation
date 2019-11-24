String fileName = "";

void resetObjects(){
  lScreen = new LoadingScreen(9);
  lScreen.setupPlanets();
  setupObjects();
  messages.add(new Message("Simulation reset", 180));
}

void saveToFile(String fileName){
  PrintWriter saveFile = createWriter(fileName + ".txt");
  
  for(int i = 0; i<objects.size(); i++){   
    saveFile.println(objects.get(i).getLabel());
    saveFile.println(objects.get(i).getType());
    saveFile.println(objects.get(i).getMass());
    saveFile.println(objects.get(i).getDensity());
    saveFile.println(objects.get(i).getPosition().x);
    saveFile.println(objects.get(i).getPosition().y);
    saveFile.println(objects.get(i).getPosition().z);
    saveFile.println(objects.get(i).getVelocity().x);
    saveFile.println(objects.get(i).getVelocity().y);
    saveFile.println(objects.get(i).getVelocity().z);
    saveFile.println(objects.get(i).getRotationSpeed());
    saveFile.println(objects.get(i).getOrbitObliquity());
    saveFile.println(objects.get(i).getTexture());
  }
  saveFile.println(simSpeed);
  
  saveFile.flush();
  saveFile.close();
  
  messages.add(new Message("Simulation saved to: " + fileName + ".txt", 180));
}

void reset(String action){
  objects = new ArrayList<CelestialBody>();
  objectFocus = inputCooldown = 0;
  loadingPhase = 1;
  
  if(action == "reload") thread("resetObjects");
  else if(action == "load") thread("loadObjectsFromFile");
}

boolean checkString(){ return true; }

boolean checkFloat(String string){
  boolean valid = false;
  try{
    Float.valueOf(string);
    valid = true;
  }
  catch (NumberFormatException e){ 
    println("Error in File!"); 
  }
  
  return valid;
}

boolean checkObject(int indexL, int indexU, String[] lines){
  boolean validData = true;
  for(int i = indexL; i<indexU; i++){
    if(i == indexL || i == indexL+1 || i == indexL+11) validData = checkString();
    else validData = checkFloat(lines[i]);
    
    if(!validData) break;
  }
  
  return validData;
}

void loadObjectsFromFile(){
  String[] lines = loadStrings(fileName + ".txt");
  int numberOfObjects = lines.length/13; //13 is the number of attribute lines per object
  lScreen = new LoadingScreen(numberOfObjects);
  lScreen.setupPlanets();
  
  for(int i = 0; i<numberOfObjects; i++){
    int index = i*13;
    if(!checkObject(index, index+11, lines)){
      messages.add(new Message("Error in file: " + fileName + ".txt", 180));
      return; //Check for errors in file
    }
    else objects.add(new CelestialBody(lines[index], lines[index+1], Float.valueOf(lines[index+2]), Float.valueOf(lines[index+3]), Float.valueOf(lines[index+4]), Float.valueOf(lines[index+5]), Float.valueOf(lines[index+6]), new PVector(Float.valueOf(lines[index+7]), Float.valueOf(lines[index+8]), Float.valueOf(lines[index+9])), Float.valueOf(lines[index+10]), Float.valueOf(lines[index+11]), lines[index+12]));  
  }
  
  simSpeed = Float.valueOf(lines[lines.length-1]);
  loadingPhase = 3;
  messages.add(new Message("Simulation loaded from: " + fileName + ".txt", 180));
}

void loadFromFile(String f){
  String[] file = loadStrings(f + ".txt");
  
  if(file != null){
    fileName = f;
    reset("load");
  }
  else messages.add(new Message("Could not find file: " + f + ".txt", 180));
}