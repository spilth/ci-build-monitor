final String workflowFile = "ahp.xml";
final color successColor = color(0,192,0);
final color failureColor = color(255,0,0);
final color[] statusColors = {failureColor, successColor};

PFont font, font2;

XMLElement workflows;
XMLElement workflow;
String workflowTitle;
String projectTitle;
String workflowStatus;

int workflowCount = 0;
int workflowIndex = 0;
int msPerWorkflow = 4000;
int msSinceLastWorkflow = 0;
int lastMillis = 0;

boolean isPlaying = true;

void setup() {
  size(screen.width, screen.height);
  background(0);

  font = loadFont("Helvetica-Bold-48.vlw"); 
  font2 = loadFont("Helvetica-Bold-64.vlw");

  workflows = new XMLElement(this, workflowFile);
  workflowCount = workflows.getChildCount();
}

void draw() {
  msSinceLastWorkflow += millis() - lastMillis;
  lastMillis = millis();
  
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
  
  if (key == CODED) {
    if (keyCode == RIGHT) {
      selectNextWorkflow();
    }
    
    if (keyCode == LEFT) {
      selectPreviousWorkflow();
    }
  }
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
  background(getStatusColor(status));
} 

