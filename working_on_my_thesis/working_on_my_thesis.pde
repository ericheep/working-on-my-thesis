// carousel

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

float aspect;
int index;
int stroke = 15;
int NUM_PHOTOS;

PImage[] photos;
PShader grain;
PShader bleach;
PShader technicolor;
boolean load = false;

void setup() {
  fullScreen(P3D);
  noCursor();

  oscP5 = new OscP5(this, 12001);
  // myRemoteLocation = new NetAddress("127.0.0.1", 12000);

  strokeWeight(stroke);
  imageMode(CENTER);
  rectMode(CENTER);

  bleach = loadShader("bleach.glsl");
  bleach.set("amount", 0.4);

  technicolor = loadShader("technicolor1.glsl");
  technicolor.set("amount", 0.8);

  grain = loadShader("grain.glsl");
  grain.set("grainamount", 0.005);
}

void draw() {
  background(0);

  if (load) {
    grain.set("dimensions", float(photos[index].width), float(photos[index].height));

    if (photos[index].width > photos[index].height) {
      aspect = float(photos[index].height)/photos[index].width;
      image(photos[index], width * 0.5, height * 0.5, height, height * aspect);

      // rounded blurry corners
      noFill();
      blurryRectangle(height, height * aspect);
    } else {
      aspect = float(photos[index].width)/photos[index].height;
      image(photos[index], width * 0.5, height * 0.5, height * aspect, height);
      // rounded blurrly corners
      noFill();
      blurryRectangle(height * aspect, height);
    }

    filter(bleach);
    filter(grain);
    filter(technicolor);
  }
}

void blurryRectangle(float w, float h) {
  for (float i = 0; i < 20; i = i + 0.1) {
    stroke(0, 0, 0, 20 - i);
    rect(width * 0.5, height * 0.5, w - i, h - i, stroke);
  }
}

void oscEvent(OscMessage msg) {
  if (msg.checkAddrPattern("/index") == true) {
    index = msg.get(0).intValue();
  }
  if (msg.checkAddrPattern("/NUM_PHOTOS") == true) {
    NUM_PHOTOS = msg.get(0).intValue();
    photos = new PImage[NUM_PHOTOS];
  }
  if (msg.checkAddrPattern("/filename") == true) {
    photos[msg.get(0).intValue()] = loadImage(msg.get(1).stringValue());
    if (msg.get(0).intValue() == NUM_PHOTOS - 1) {
      load = true;
    }
  }
}