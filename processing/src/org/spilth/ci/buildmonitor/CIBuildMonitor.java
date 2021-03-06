package org.spilth.ci.buildmonitor;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;

import processing.core.*;
import processing.xml.*;

public class CIBuildMonitor extends PApplet {
	private static final long serialVersionUID = 1L;

	String workflowUrl = null;
	String urlFile = null;

	static String defaultUrlFile = "url.txt";
	static String helpText = "H = Toggle Help\nR = Reload Feed\nU = Choose URL File\nSpace = Pause Monitor\nLeft/Right Arrow = Previous/Next Workflow";

	int successColor = color(0, 192, 0);
	int failureColor = color(255, 0, 0);

	PFont normalFont, bigFont, smallFont;

	XMLElement workflows;
	XMLElement workflow;
	String workflowTitle;
	String projectTitle;
	String workflowStatus;
	String workflowStamp;
	String workflowBuildLife;
	String workflowDuration;

	int backgroundColor;

	int workflowCount = 0;
	int workflowIndex = 0;

	int msReloadTime = 2 * 60 * 1000;
	int msPerWorkflow = 5000;
	int msSinceLastWorkflow = 0;
	int msSinceLastReload = 0;
	int lastMillis = 0;

	boolean isPlaying = true;
	boolean isHelping = false;

	public void setup() {
		selectUrlFile();
		loadFeedUrl();

		// Hopefully temporary placeholder to make Proclipsing plug-in happy when exporting
		size(640,480);
		
		size(screen.width, screen.height);
		background(0);

		normalFont = loadFont("Helvetica-Bold-48.vlw");
		bigFont = loadFont("Helvetica-Bold-64.vlw");
		smallFont = loadFont("Helvetica-Bold-24.vlw");

		loadFeed();
	}

	void selectUrlFile() {
		BufferedReader reader = createReader(defaultUrlFile);

		if (reader == null) {
			urlFile = selectInput("Select URL file");

			if (urlFile == null) {
				exit();

			} else {
				copyFeedUrlFile();
			}
		}
	}

	void copyFeedUrlFile() {
		BufferedReader reader2 = createReader(urlFile);
		PrintWriter writer = createWriter("url.txt");

		try {
			writer.println(reader2.readLine());
			writer.flush();
			writer.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	void loadFeedUrl() {
		BufferedReader reader = createReader(defaultUrlFile);
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

	public void draw() {
		msSinceLastWorkflow += millis() - lastMillis;
		msSinceLastReload += millis() - lastMillis;
		lastMillis = millis();

		if (msSinceLastReload >= msReloadTime) {
			loadFeed();
		}

		if (isPlaying && msSinceLastWorkflow >= msPerWorkflow) {
			selectNextWorkflow();
		}

		workflow = workflows.getChild(workflowIndex);

		drawStatusBackground();
		drawProject();
		drawWorkflow();
		drawStamp();
		drawBuildLife();
		drawDuration();
		drawChangeCount();

		drawMonitorState();
		drawHelp();
	}

	void drawProject() {
		projectTitle = workflow.getChild(0).getContent();

		fill(255);
		textAlign(CENTER);
		textFont(bigFont);
		text(projectTitle, width / 2, height / 2 - 32);
	}

	void drawWorkflow() {
		workflowTitle = workflow.getChild(1).getContent();

		fill(255);
		textAlign(CENTER);
		textFont(normalFont);
		text(workflowTitle, width / 2, (height / 2) + 28);
	}

	void drawStamp() {
		workflowStamp = workflow.getChild(3).getContent();

		fill(255, 75);
		textAlign(CENTER);
		textFont(smallFont);
		text("Stamp: " + workflowStamp, width / 2, (height / 2) + 60);
	}

	void drawBuildLife() {
		workflowBuildLife = workflow.getChild(4).getContent();

		fill(255, 75);
		textAlign(CENTER);
		textFont(smallFont);
		text("Build Life ID: " + workflowBuildLife, width / 2,
				(height / 2) + 100);
	}

	void drawDuration() {
		workflowDuration = workflow.getChild(5).getContent();

		fill(255, 50);
		textAlign(RIGHT);
		textFont(smallFont);
		text("Build Duration: " + workflowDuration, width - 8, height - 50);
	}

	void drawChangeCount() {
		workflowDuration = workflow.getChild(6).getContent();

		fill(255, 50);
		textAlign(CENTER);
		textFont(smallFont);
		text("Change Count: " + workflowDuration, width / 2, height - 50);
	}

	int getStatusColor(String status) {
		if (status.equals("success")) {
			return successColor;
		}
		
		return failureColor;
	}

	public void drawMonitorState() {
		if (!isPlaying) {
			textAlign(LEFT);
			text("Paused - Showing " + (workflowIndex + 1) + " of "
					+ workflowCount, 8, height - 50);
		}
	}

	public void drawHelp() {
		if (isHelping) {
			textAlign(LEFT);
			textFont(smallFont);
			text(helpText, 8, 30);
		}
	}

	public void keyPressed() {
		if (key == ' ') {
			isPlaying = !isPlaying;
		}

		if (key == 'h') {
			isHelping = !isHelping;
		}

		if (key == 'r') {
			loadFeed();
			workflowIndex = 0;

		}

		if (key == 'u') {
			noLoop();
			selectUrlFile();
			loadFeedUrl();
			loadFeed();
			loop();
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
		msSinceLastWorkflow = 0;
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

	void drawStatusBackground() {
		workflowStatus = workflow.getChild(2).getContent();

		backgroundColor = lerpColor(lerpColor(color(0),
				getStatusColor(workflowStatus), (float) 0.25),
				getStatusColor(workflowStatus), (float) msSinceLastWorkflow
						/ msPerWorkflow);
		background(backgroundColor);
	}

	public static void main(String _args[]) {
		PApplet
				.main(new String[] { org.spilth.ci.buildmonitor.CIBuildMonitor.class
						.getName() });
	}
}
