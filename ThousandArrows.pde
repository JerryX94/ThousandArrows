class Me {
  color c;
  float ox;
  float oy;
  float dia;

  Me() {
    c = color(0);
    ox = mouseX;
    oy = mouseY;
    dia = 20;
  }

  void renew(color cc, float d) {
    c = cc;
    dia = d;
    ox = mouseX;
    oy = mouseY;
  }

  void display() {
    stroke(c);
    fill(c);
    ellipseMode(CENTER);
    ellipse(ox, oy, dia, dia);
  }
}

class Foe {
  color c;
  float ox;
  float oy;
  float tx;
  float ty;
  float len;
  float dhead;
  float dir;
  int dif;
  boolean vis;

  Foe() {
    c = color(0);
    ox = 0.;
    oy = 0.;
    tx = 0.;
    ty = 0.;
    len = 80.;
    dhead = 4.;
    dir = 0.;
    dif = 0;
    vis = false;
  }

  boolean out(float x, float y) {
    if (x < 0) return true;
    if (y < 0) return true;
    if (x > width) return true;
    if (y > height) return true;
    return false;
  }

  void renew(float oxn, float oyn, float dirn, int difn) {
    ox = oxn;
    oy = oyn;
    dir = dirn;
    dif = difn;
    tx = ox + len * cos(dir);
    ty = oy + len * sin(dir);
    if (out(tx, ty)) vis = false;
  }

  void display() {
    c = color(0, 0, 0, 192);
    stroke(c);
    line(ox, oy, tx, ty);
    c = color(255, 0, 0, 192);
    stroke(c);
    fill(c);
    ellipseMode(CENTER);
    ellipse(tx, ty, dhead, dhead);
  }
}

class FoeQueue {
  int maxN;
  int nQueue;
  int targRate;
  float arrowSpdLv;
  Foe[] ff;

  FoeQueue() {
    maxN = 50;
    nQueue = 0;
    targRate = 3;
    arrowSpdLv = 30.;
    ff = new Foe[maxN];
    for (int i = 0; i < maxN; i++) {
      ff[i] = new Foe();
    }
  }

  float target(float x0, float y0, float x1, float y1) {
    float tang = (y1 - y0) / (x1 - x0);
    return atan(tang);
  }

  void gen(int difn, float tarx, float tary) {
    float dirn, oxn, oyn;
    int num = difn / 3 + 1;
    for (int i = 0; i < maxN; i++) {
      if (!ff[i].vis) {
        num--;
        ff[i].vis = true;
        int edge = (int)random(4);
        switch(edge) {
        case 0:
          dirn = random(0, PI);
          oxn = random(width);
          if (random(targRate) < 1) dirn = target(oxn, 0, tarx, tary);
          ff[i].renew(oxn, 0, dirn, difn);
          break;
        case 1:
          dirn = random(0.5 * PI, 1.5 * PI);
          oyn = random(height);
          if (random(targRate) < 1) dirn = target(width, oyn, tarx, tary);
          ff[i].renew(width, oyn, dirn, difn);
          break;
        case 2:
          dirn = random(PI, 2 * PI);
          oxn = random(width);
          if (random(targRate) < 1) dirn = target(oxn, height, tarx, tary);
          ff[i].renew(oxn, height, dirn, difn);
          break;
        default:
          dirn = random(1.5 * PI, 2.5 * PI);
          oyn = random(height);
          if (random(targRate) < 1) dirn = target(0, oyn, tarx, tary);
          ff[i].renew(0, oyn, dirn, difn);
          break;
        }
        ff[i].display();
      }
      if (num <= 0) {
        break;
      }
    }
  }

  void renew() {
    for (int i = 0; i < maxN; i++) {
      if (ff[i].vis) {
        float dif = ff[i].dif / 2;
        float oxn = ff[i].ox + (ff[i].tx - ff[i].ox) * (dif + 1) / arrowSpdLv;
        float oyn = ff[i].oy + (ff[i].ty - ff[i].oy) * (dif + 1) / arrowSpdLv;
        ff[i].renew(oxn, oyn, ff[i].dir, ff[i].dif);
        ff[i].display();
      }
    }
  }
}


Me m;
FoeQueue f;

long fn = 0;
long fr = 60;
int tSize = 64;
int difficulty = 0;
int beginTime, endTime;
boolean begin = false;
boolean end = false;

boolean die() {
  for (int i = 0; i < f.maxN; i++) {
    if (f.ff[i].vis) {
      float disx = f.ff[i].tx - m.ox;
      float disy = f.ff[i].ty - m.oy;
      float dis = sqrt(disx * disx + disy * disy);
      if (dis < m.dia) return true;
    }
  }
  return false;
}

void setup() {
  size(800, 600);
  frameRate(fr);
  m = new Me();
  f = new FoeQueue();
}

void draw() {
  background(255);
  if (begin) {
    endTime = millis();
    textSize(tSize / 4);
    text((endTime - beginTime) / 1000., 9 * width / 10, height / 20);
    text("s", 39 * width / 40, height / 20);
    text("Round", width / 20, height / 20);
    text(difficulty + 1, 3 * width / 20, height / 20);
    fn++;
    if (fn % (10 * fr) == 0) {
      difficulty++;
    }
    f.renew();
    if (die()) {
      begin = false;
      end = true;
      endTime = millis();
    }
    if (fn % (fr / (difficulty + 1)) == 0) {
      f.gen(difficulty, m.ox, m.oy);
    }
  }
  if (end) {
    m.c = color(255, 0, 0);
    fill(0);
    textSize(tSize);
    textAlign(CENTER);
    text("You Lose", width / 2, height / 2 - tSize);
    text("Survival Time: (s)", width / 2, height / 2 + tSize);
    text((endTime - beginTime) / 1000., width / 2, height / 2 + 2 * tSize);
  }
  if (!begin && !end) {
    textSize(tSize);
    textAlign(CENTER);
    text("Dodge the Arrows!", width / 2, height / 2);
    textSize(tSize / 4);
    textAlign(CENTER);
    text("Click to Begin", width / 2, height / 2 + tSize);
    textSize(tSize / 2);
    textAlign(CENTER);
    text("Programmed by Jiayu", width / 2, 9 * height / 10);
  }
  m.renew(m.c, m.dia);
  m.display();
}

void mousePressed() {
  if (end) {
    exit();
  } else {
    begin = true;
    beginTime = millis();
  }
}
