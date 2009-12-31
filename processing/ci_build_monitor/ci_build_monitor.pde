final String workflowFile = "ahp.xml";
final color successColor = color(0,192,0);
final color failureColor = color(255,0,0);
final color[] statusColors = {failureColor, successColor};

PFont font;

XMLElement workflows;
XMLElement workflow;
String workflowTitle;
String projectTitle;
String workflowStatus;

int workflowCount = 0;
int workflowIndex = 0;
int secondsSinceLastWorkflow = 0;

void setup() {
  size(screen.width, screen.height);
  background(0);
  frameRate(1);

  font = loadFont("Helvetica-Bold-48.vlw"); 
  textAlign(CENTER);
  textFont(font);

  workflows = new XMLElement(this, workflowFile);
  workflowCount = workflows.getChildCount();
}

void draw() {
  if (secondsSinceLastWorkflow >= 3) {
    workflowIndex++;
    if (workflowIndex >= workflowCount) {
      workflowIndex = 0;
    }
    secondsSinceLastWorkflow = 0;
  }
  secondsSinceLastWorkflow++;
  
  workflow = workflows.getChild(workflowIndex);
  projectTitle = workflow.getChild(0).getContent();
  workflowTitle = workflow.getChild(1).getContent();
  workflowStatus =  workflow.getChild(2).getContent();

  drawStatusBackground(workflowStatus);
  
  fill(255);
  text(projectTitle, width / 2, height / 2 - 28);
  text(workflowTitle, width / 2 , (height / 2) + 28);
}

color getStatusColor(String status) {
  return statusColors[int(status.equals("success"))];
}


void drawStatusBackground(String status) {
  createGradient(width / 2, height / 2, width / 2, getStatusColor(workflowStatus), color(0));
} 
 
// from http://processing.org/learning/basics/radialgradient.html
void createGradient (float x, float y, float radius, color c1, color c2){
  float px = 0, py = 0, angle = 0;

  // calculate differences between color components 
  float deltaR = red(c2)-red(c1);
  float deltaG = green(c2)-green(c1);
  float deltaB = blue(c2)-blue(c1);
  // hack to ensure there are no holes in gradient
  // needs to be increased, as radius increases
  float gapFiller = 8.0;

  for (int i=0; i< radius; i++){
    for (float j=0; j<360; j+=1.0/gapFiller){
      px = x+cos(radians(angle))*i;
      py = y+sin(radians(angle))*i;
      angle+=1.0/gapFiller;
      color c = color(
      (red(c1)+(i)*(deltaR/radius)),
      (green(c1)+(i)*(deltaG/radius)),
      (blue(c1)+(i)*(deltaB/radius)) 
        );
      set(int(px), int(py), c);      
    }
  }
  // adds smooth edge 
  // hack anti-aliasing
  noFill();
  strokeWeight(3);
  ellipse(x, y, radius*2, radius*2);
}

