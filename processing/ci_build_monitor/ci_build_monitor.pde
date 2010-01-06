String workflowUrl = null;
String urlFile = null;
final String defaultUrlFile = "url.txt";

final color successColor = color(0,192,0);
final color failureColor = color(255,0,0);
final color[] statusColors = {failureColor, successColor};

PFont font, font2;

XMLElement workflows;
XMLElement workflow;
String workflowTitle;
String projectTitle;
String workflowStatus;
color backgroundColor;

int workflowCount = 0;
int workflowIndex = 0;

int msReloadTime = 2 * 60 * 1000;
int msPerWorkflow = 5000;
int msSinceLastWorkflow = 0;
int msSinceLastReload = 0;
int lastMillis = 0;

boolean isPlaying = true;

void setup() {
  selectUrlFile();
  loadFeedUrl();
  
  size(screen.width, screen.height);
  background(0);

  font = loadFont("Helvetica-Bold-48.vlw"); 
  font2 = loadFont("Helvetica-Bold-64.vlw");
  
  loadFeed();
}

void selectUrlFile() {
  BufferedReader reader = createReader(defaultUrlFile);
  
  if (reader == null) {
    urlFile = selectInput();

    if (urlFile == null) {
      exit();
    }
  } else {
    urlFile = defaultUrlFile; 
  }
}

void loadFeedUrl() {
  BufferedReader reader = createReader(urlFile);
  String line;

  try {
    line = reader.readLine();
  } catch (IOException e) {

    e.printStackTrace();
    line = null;
  }
  
  if (line == null) {
    println("No URL found in url.txt");
    exit();

  } else {
    workflowUrl = line;
  }
}

void draw() {
  msSinceLastWorkflow += millis() - lastMillis;
  msSinceLastReload   += millis() - lastMillis;
  lastMillis = millis();

  if (msSinceLastReload >= msReloadTime) {
    loadFeed();
  }
  
  if (isPlaying && msSinceLastWorkflow >= msPerWorkflow) {
    selectNextWorkflow();
  }
  
  workflow = workflows.getChild(workflowIndex);
  projectTitle = workflow.getChild(0).getContent();
  workflowTitle = workflow.getChild(1).getContent();
  workflowStatus =  workflow.getChild(2).getContent();

  drawStatusBackground(workflowStatus);
  
  fill(255);
  
  textAlign(CENTER);
  textFont(font2);
  text(projectTitle, width / 2, height / 2 - 32);

  textFont(font);
  text(workflowTitle, width / 2 , (height / 2) + 28);

  drawMonitorState();
}

color getStatusColor(String status) {
  return statusColors[int(status.equals("success"))];
}

public void drawMonitorState() {
  if (!isPlaying) {
    textAlign(LEFT);
    text("Paused", 8, height -50);
  }
}

void keyPressed() {  
  if (key == ' ') {
    isPlaying = !isPlaying;
  }
  
  if (key == 'r') {
    loadFeed();
  }
  
  if (key == CODED) {
    if (keyCode == RIGHT) {
      selectNextWorkflow();
    }
    
    if (keyCode == LEFT) {
      selectPreviousWorkflow();
    }
    
  }
}

void loadFeed() {
  workflows = new XMLElement(this, workflowUrl);
  workflowCount = workflows.getChildCount();
  msSinceLastReload = 0;
}

void selectNextWorkflow() {
  workflowIndex++;
  if (workflowIndex >= workflowCount) {
    workflowIndex = 0;
  }
  msSinceLastWorkflow = 0;
}

void selectPreviousWorkflow() {
  workflowIndex--;
  if (workflowIndex < 0) {
    workflowIndex = workflowCount - 1;
  }
  msSinceLastWorkflow = 0;
}

void drawStatusBackground(String status) {
  backgroundColor = lerpColor(
    lerpColor(color(0), getStatusColor(status), .25),
    getStatusColor(status), (float) msSinceLastWorkflow / msPerWorkflow
  );
  background(backgroundColor);
}


