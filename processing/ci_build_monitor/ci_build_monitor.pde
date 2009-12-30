PFont font;

XMLElement workflows;
XMLElement workflow;
int index;
int numWorkflows;
String workflowTitle;
String projectTitle;
String workflowStatus;

color successColor = color(0, 192, 0);
color failureColor = color(255, 0, 0);

color[] statusColors = {failureColor, successColor};

void setup() {
  frameRate(1);
  size(screen.width / 2, screen.height / 2);
  background(0);

  font = loadFont("TrebuchetMS-48.vlw"); 
  textAlign(CENTER);
  textFont(font);

  workflows = new XMLElement(this, "ahp.xml");
  numWorkflows = workflows.getChildCount();
}

void draw() {
  index = constrain(second(), 0, numWorkflows - 1) ;
  workflow = workflows.getChild(index);
  projectTitle = workflow.getChild(0).getContent();
  workflowTitle = workflow.getChild(1).getContent();
  workflowStatus =  workflow.getChild(2).getContent();
  fill(getStatusColor(workflowStatus));
  rect(0,0, screen.width, screen.height);
  fill(255);

  text(projectTitle, width / 2, height / 2);
  text(workflowTitle, width / 2 , (height / 2) + 50);
}

color getStatusColor(String status) {
  return statusColors[int(status.equals("success"))];
}
