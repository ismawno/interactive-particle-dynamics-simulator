void run() {
  if (forward) ENV.getIntegrator().forward();
  else ENV.getIntegrator().backward();
  if (TW.collisions()) ENV.getCollider().runCollisions(elasticity, glide, interpolPP);
  if (TW.constrain()) ENV.getBoundaries().constrain(elasticity, glide, interpolB);
  if (isFollowingCM()) ENV.moveOrigin(Physics.getCMPos(ENV.getGroup("focus")));
  time += forward ? ENV.getIntegrator().getDt() : - ENV.getIntegrator().getDt();
  timesteps++;
}
void display() {
  ENV.getVisualizer().showJoints().show();
  if (TW.drawLimits())
    ENV.getBoundaries().show(color(255, 150, 150));
  if (!ENV.getGroup("drawPath").isEmpty() && (!isAddingParticle() || !drawPathOnAddition) && (!isReleasing() || !ENV.getGroup("drawPath").contains(ENV.getParticle("controlled"))))
    drawPath(ENV.getGroup("drawPath"), dpLen, pow(10, dpDtExp), false, null);

  if (drawMouseCoords) drawMouseCoordinates();
  push();
  textSize(20);
  textAlign(CENTER);
  if (promptLife-- > 0) {
    fill(180, 255, 180, map(promptLife, 0, 120, 0, 255));
    text(prompt, width / 2, 50);
  }
  fill(180, 255, 180);
  if (pause) text("Paused", width / 2, height - 60);
  if (ENV.anyRec()) text("Recording! Do not modify number of particles or errors will occur", width / 2, height - 20);
  else
    if (isControllingCamera()) 
      if (isControlling()) text("Controlling particle & camera", width / 2, height - 20);
      else text("Controlling camera", width / 2, height - 20);
    else if (isControlling()) {
      text("Ready to control", width / 2, height - 40);
      textSize(16);
      text("Press shift to make the particle follow the mouse", width / 2, height - 20);
    } else if (softBodyMode()) {
      text("<- A |Adding soft body| D ->", width / 2, height - 40);
      textSize(16);
      text("Click to set the soft body and click again to add it", width / 2, height - 20);
    } else if (selectingMode()) {
      text("<- A |Selecting| D ->", width / 2, height - 40);
      textSize(16);
      text("Click and drag to select. Press CONTROL to change behaviour", width / 2, height - 20);
    } else {
      text("<- A |Adding particle| D ->", width / 2, height - 40);
      textSize(16);
      text("Click and drag to add a particle with some momentum", width / 2, height - 20);
      displayMini();
    }
  pop();
  if (showOrigin) showOrigin();
  String frameText = frameRate > 1 ? "FPS: " + round(frameRate) : "SPF: " + round(1 / frameRate);
  text(frameText, width - textWidth(frameText), 25);
  frames++;
}
void updateTimestep() {
  if (adaptToFramerate) timestep = 1.0 / frameRate;
  else timestep = pow(10, dtExp);
}
void setPrompt(String text) {
  prompt = text;
  promptLife = promptLifeSpan;
}
void showOrigin() {
  push();
  stroke(255);
  strokeWeight(4);
  int len = 10;
  PVector trans = ENV.getVisualizer().getTranslate();
  translate(trans.x, trans.y);
  line(-len, -len, len, len);
  line(-len, len, len, -len);
  pop();
}
void displayMini() {
  push();
  float mFact = dispFacts[2], cFact = dispFacts[3], lFact = dispFacts[0];
  float mDens, cDens, radius;
  color col;
  if (TW.anyCustoms()) {
    Particle p = ENV.getCustoms().getPts().get(TW.indexCustoms());
    mDens = p.getMass();
    cDens = p.getCharge();
    radius = p.getRadius();
    col = p.getColor();
  } else {
    radius = rd * pow(10, ctePots[8]) / selFacts[0];
    mDens = md * pow(10, ctePots[6]) / selFacts[2] * (isMDens ? pow(selFacts[0], 3) * 2 * TWO_PI * radius * radius * radius / 3 : 1);
    cDens = cd * pow(10, ctePots[7]) / selFacts[3] * (isCDens ? pow(selFacts[0], 3) * 2 * TWO_PI * radius * radius * radius / 3 : 1);
    col = color(ptR, ptG, ptB);
  }
  textSize(14);
  textAlign(CORNER);
  fill(col);
  float x = width / 2 + textWidth("Click and drag to add a particle with some momentum") / 1.8, y = height - 50, h = 12;
  circle(x, y, 20);
  text("Mass: " + mDens * mFact + " " + dispUnits[2], x + 10, y);
  text("Charge: " + cDens * cFact + " " + dispUnits[3], x + 10, y + h);
  text("Radius: " + radius * lFact + " " + dispUnits[0], x + 10, y + 2 * h);
  pop();
}
void saveRecords() {
  for (int i = 0; i < ENV.getIsRec().length; i++)
    if (ENV.getIsRec()[i]) {
      for (Particle p : ENV.getRecordings().getActors().get(Integer.toString(i)))
        if (isFollowingCM()) p.getRecord().saveRel(ENV.getGroup("focus"));
        else p.getRecord().save();
      break;
    }
}
void drawMouseCoordinates() {
  PVector pos = getMousePos(ENV);
  push();
  textSize(14);
  textAlign(CORNER);
  fill(50, 180, 255);
  text("X: " + (pos.x * dispFacts[0]) + dispUnits[0], mouseX + 12, mouseY);
  text("Y: " + (pos.y * dispFacts[0]) + dispUnits[0], mouseX + 12, mouseY + 12);
  pop();
}
void whileRunningSettingsWindow() {
  ENV.getIntegrator().setDt(timestep);
  if (TW.anyPlaying()) {
    TW.showMovie();
    return;
  }
  TW.show();
  TW.showRun();
  if (!isOnEnv() && showPrevSb && TW.globalShowToggles[1]) TW.controlSoftBodyPreview();
  if (run) {
    if (!pause)
      for (int i = 0; i < intPerFrame; i++)
        run();

    if (!pause) {
      if (!ENV.getGroup("quantities").isEmpty())
        plots.updateRecords();
      if (!ENV.getGroup("saveData").isEmpty())
        saveDataOfParticles();
      saveRecords();
    }
  }
}
void whileRunningSimulation() {
  ENV.getIntegrator().setDt(timestep);
  if (!pause) {
    for (int i = 0; i < intPerFrame; i++)
      run();
    saveRecords();
  }

  display();
  showData(this);
  showDistance();
  drawAccelField(vecDetail);
  drawContourLines(contDetail, contVals, minEdge, maxEdge);

  if (isSelecting())
    drawSelRectAndCheck(ENV, isPressingControl());

  if (!ENV.getGroup("quantities").isEmpty())
    plots.updateRecords();
  if (saveFrames)
    saveFrame("frames/output_frame#####.png");
  if (!ENV.getGroup("saveData").isEmpty() && !pause)
    saveDataOfParticles();
}
void saveDataOfParticles() { //PAUSAR SIEMPRE SI ESTA ESTO ACTIVADO Y SELECCIONAS ALGUNA PARTICULA
  List<Particle> pts = ENV.getGroup("saveData");
  float lenFact = dispFacts[0], timeFact = dispFacts[1], velFact = dispFacts[4], eFact = dispFacts[5];
  String pos = Float.toString(time * timeFact), vel = Float.toString(time * timeFact), energy = Float.toString(time * timeFact);
  for (Particle p : pts) {
    pos += "  " + p.getPos().x * lenFact + "  " + p.getPos().y * lenFact;
    vel += "  " + p.getVel().x * velFact + "  " + p.getVel().y * velFact;
    energy += "  " + p.getEnergy() * eFact;
  }
  outputPos.println(pos);
  outputVel.println(vel);
  outputEnergy.println(energy);
}

void resetCamera() {
  ENV.getVisualizer().setScaling(1).setTranslate(width / 2, height / 2);
}
void resetBoundaries() {
  ENV.getBoundaries().setConstrainPos(0, 0).setConstrainDim(width, height);
}
void updateBox(Environment ENV) {
  ENV.getBoundaries().setConstrainPos(width / 2 - ENV.getVisualizer().getTranslate().x, ENV.getVisualizer().getTranslate().y - height / 2);
  ENV.getBoundaries().getConstrainPos().div(ENV.getVisualizer().getScaling());
  ENV.getBoundaries().setConstrainDim(width / ENV.getVisualizer().getScaling(), height / ENV.getVisualizer().getScaling());
}
void dragScreen(Environment ENV) {
  ENV.getVisualizer().getTranslate().x += mouseX - pmouseX;
  ENV.getVisualizer().getTranslate().y += mouseY - pmouseY;
  if (dynBox)
    updateBox(ENV);
}
void applyZoom(MouseEvent event, Environment ENV, boolean moveOr) {

  PVector trans = ENV.getVisualizer().getTranslate();
  float z = ENV.getVisualizer().getScaling();
  if (moveOr && (trans.x != width / 2 || trans.y != height / 2) && !isFollowingCM()) {
    PVector move = PVector.sub(trans, new PVector(width / 2, height / 2)).div(z);
    move.x *= - 1;
    ENV.moveOrigin(move);
    trans.set(width / 2, height / 2);
  }

  z -= event.getCount() * 0.05 * z;
  if (z <= 0)
    resetCamera();
  else
    ENV.getVisualizer().setScaling(z);
  if (dynBox)
    updateBox(ENV);
}
void navigateGlobal() {
  if (key == 'w' || key == UP) indexGlobal--;
  else if (key == 's' || key == DOWN) indexGlobal++;
  else return;
  if (indexGlobal > TW.globalCbs.length - 1) indexGlobal = 0;
  else if (indexGlobal < 0) indexGlobal = TW.globalCbs.length - 1;
  TW.globalCbs[indexGlobal].action();
}
void navigateModes() {
  if (key == 'd' || key == RIGHT) indexModes++;
  else if (key == 'a' || key == LEFT) indexModes--;
  else return;
  TW.resetModes();
  if (indexModes > modes.length) indexModes = 0;
  else if (indexModes < 0) indexModes = modes.length;
  if (indexModes != 0) modes[indexModes - 1] = true;
}
void navigateCustoms() {
  if (key == 'w' || key == UP) indexCustoms++;
  else if (key == 's' || key == DOWN) indexCustoms--;
  else return;
  TW.resetToggleCustoms();
  if (indexCustoms > ENV.getCustoms().getPts().size()) indexCustoms = 0;
  else if (indexCustoms < 0) indexCustoms = ENV.getCustoms().getPts().size();
  if (indexCustoms != 0) TW.toggleCustoms[indexCustoms - 1] = true;
  for (int i = 0; i < ENV.getCustoms().getPts().size(); i++) ENV.getCustoms().getPts().get(i).setSelected(TW.toggleCustoms[i]);
}
void drawSelRectAndCheck(Environment ENV, boolean isPressingKey) {
  PVector tSPos = ENV.invTransform(getSavedMousePos());
  PVector dim = getMousePos(ENV).sub(getSavedMousePos());
  float sc = ENV.getVisualizer().getScaling();

  push();
  noFill();
  stroke(isPressingKey ? color(255, 255, 0) : 255);
  rect(tSPos.x, tSPos.y, dim.x * sc, - dim.y * sc);
  pop();

  for (Particle p : ENV.getParticles())
    if (overlaps(p.getPos(), getSavedMousePos().copy(), dim)) ENV.select(p);
    else if (isPressingKey) ENV.unSelect(p);
}
boolean overlaps(PVector pos, PVector rectPos, PVector dim) {
  if (dim.x < 0) rectPos.x += dim.x;
  if (dim.y < 0) rectPos.y += dim.y;
  return pos.x > rectPos.x && pos.x < rectPos.x + abs(dim.x) && pos.y > rectPos.y && pos.y < rectPos.y + abs(dim.y);
}

Particle getParticleAddition(PVector pos, float md, float cd, float rd, color col) {
  Particle p = new Particle(this, pos, 0, 0, md * pow(selFacts[0], 3), cd * pow(selFacts[0], 3), rd).setColor(col).setDynamic(!TW.addStatic());
  if (!isMDens) p.setMass(md);
  if (!isCDens) p.setCharge(cd);
  return p;
}
void addToDefaultGroupsBefore(Particle p) {
  if (showDataOnAddition) ENV.getGroup("showData").add(p);
  if (showDistOnAddition) ENV.getGroup("showDist").add(p);
}
void addToDefaultGroupsAfter(Particle p) {
  if (drawAFOnAddition) ENV.getGroup("accelField").add(p);
  if (drawCLOnAddition) ENV.getGroup("contLines").add(p);
  if (followCMOnAddition) ENV.getGroup("focus").add(p);
  if (qtsOnAddition) ENV.getGroup("quantities").add(p);
  if (drawPathOnAddition) ENV.getGroup("drawPath").add(p);
  if (drawTrailsOnAddition) {
    ENV.getGroup("trails").add(p);
    p.getVisualizer().trail().setTrailCapacity(trailsCap).setTrailLength(trailsLen);
  }
}
void addToDefaultGroups(Particle p) {
  addToDefaultGroupsBefore(p);
  addToDefaultGroupsAfter(p);
}
void prepareParticleAddition(float md, float cd, float rd, color col) {
  Particle p = TW.anyCustoms() ? ENV.getCustoms().getPts().get(TW.indexCustoms()).blindCopy().setSelected(false).setPos(saveMousePos(ENV).copy())
    : getParticleAddition(saveMousePos(ENV).copy(), md, cd, rd, col);
  p.getVisualizer().setTranslate(ENV.getVisualizer().getTranslate()).setScaling(ENV.getVisualizer().getScaling());
  ENV.setParticle("toBeAdded", p);
  addToDefaultGroupsBefore(p);
}
void whileParticleAddition() {
  Particle p = ENV.getParticle("toBeAdded");
  if (isPressingShift()) p.setPos(saveMousePos(ENV).copy());
  p.getVisualizer().show();
  if (p.isDynamic()) {
    p.setVel(isFollowingCM() ? getMouseVel(mVel).add(Physics.getCMVel(ENV.getGroup("focus"))) : getMouseVel(mVel));
    if (drawPathOnAddition && !isPressingShift()) drawPathExclusive(p, ENV.getGroup("drawPath"), dpLen, pow(10, dpDtExp), true);
  }
}
void setParticleAddition() {
  Particle p = ENV.getParticle("toBeAdded");
  ENV.add(p);
  ENV.removeParticle("toBeAdded");
  addToDefaultGroupsAfter(p);
}

void prepareSoftBodyAddition(int wdth, int hght, float md, float cd, float rd, float stf, float damp, color col, int terms, int decay) {
  toBeAdded = new SoftBody(this, wdth, hght, md * pow(selFacts[0], 3), cd * pow(selFacts[0], 3), rd);
  toBeAdded.setVertex("LBD", getMousePos(ENV)).setVertex("RBD", getMousePos(ENV));

  if (hght > 1) toBeAdded.setVertex("LTD", getMousePos(ENV)).setVertex("RTD", getMousePos(ENV));
  toBeAdded.setCrossJoints(crJoints).init().setColor(col).setStiffness(stf).setTerms(terms).setDecay(decay).setDampening(damp);

  if (relFixed) toBeAdded.fixVertices();
  for (Particle p : toBeAdded.getLinealBody()) {
    p.setDim(Environment.DIMENSION.TWO).getVisualizer().setTranslate(ENV.getVisualizer().getTranslate()).setScaling(ENV.getVisualizer().getScaling());
    addToDefaultGroupsBefore(p);
  }
  if (!isSbMDens) toBeAdded.setMass(md);
  if (!isSbCDens) toBeAdded.setCharge(cd);
  toBeAdded.setThickness(rd / 5);
}
void whileSoftBodyAddition() {
  if (toBeAdded.getHeight() > 1) {
    PVector pos = getMousePos(ENV);
    toBeAdded.setVertex("RTD", pos);
    toBeAdded.getVertex("RBD").getPos().x = pos.x;
    toBeAdded.getVertex("LTD").getPos().y = pos.y;
    toBeAdded.locateAsVertices();
  } else
    toBeAdded.setVertex("RBD", getMousePos(ENV)).locateAsVertices();

  ENV.getVisualizer().show(toBeAdded.getLinealBody()).showJoints(toBeAdded.getJoints());
}
void setSoftBodyAddition() {
  if (!autoAdjustEq) toBeAdded.setLength(0);
  ENV.add(toBeAdded);
  for (Particle p : toBeAdded.getLinealBody()) addToDefaultGroupsAfter(p);
  toBeAdded = null;
}

void prepareControlledRelease() {
  Particle p = ENV.getParticle("controlled");
  p.setPos(saveMousePos(ENV).copy()).setDynamic(true);
  if (isFollowingCM()) p.setVel(Physics.getCMVel(ENV.getGroup("focus")));
}
void whileReleasing() {
  Particle p = ENV.getParticle("controlled").setPos(getSavedMousePos().copy());
  p.setVel(isFollowingCM() ? getMouseVel(mVel).add(Physics.getCMVel(ENV.getGroup("focus"))) : getMouseVel(mVel));
  if (ENV.getGroup("drawPath").contains(p)) drawPath(ENV.getGroup("drawPath"), dpLen, pow(10, dpDtExp), true, p);
}
void whileControlling() {
  Particle p = ENV.getParticle("controlled");
  p.setPos(getMousePos(ENV));
  PVector vel = new PVector(); //new PVector(mouseX - pmouseX, mouseY - pmouseY).div(ENV.getIntegrator().getDt());
  p.setVel(isFollowingCM() ? Physics.getCMVel(ENV.getGroup("focus")).add(vel) : vel);
  if (!ENV.contains(p)) stopControlling(wasDynamic);
}
void stopControlling(boolean dyn) {
  ENV.getParticle("controlled").setDynamic(dyn);
  ENV.removeParticle("controlled");
}

void drawPath(List<Particle> pts, float time, float dt, boolean mouse, Particle p) {
  ENV.saveConfig().getIntegrator().setDt(dt);
  if (mouse) p.setVel(isFollowingCM() ? getMouseVel(mVel).add(Physics.getCMVel(ENV.getGroup("focus"))) : getMouseVel(mVel));
  for (float t = 0; t <= time; t += dt) {
    for (Particle p1 : pts) p1.getRecord().saveDispPos();
    if (forward) ENV.getIntegrator().forward();
    else ENV.getIntegrator().backward();
    if (TW.merge() && ENV.overlaps()) break;
    if (TW.collisions()) ENV.getCollider().runCollisions(elasticity, glide, interpolPP);
    if (TW.constrain()) ENV.getBoundaries().constrain(elasticity, glide, interpolB);
    if (isFollowingCM()) ENV.moveOrigin(Physics.getCMPos(ENV.getGroup("focus")));
    for (Particle p1 : pts) showPath(p1, t, time);
  }
  ENV.loadConfig().getIntegrator().setDt(timestep);
}
void drawPathExclusive(Particle p, List<Particle> pts, float time, float dt, boolean mouse) {
  ENV.add(p); 
  pts.add(p);
  drawPath(pts, time, dt, mouse, p);
  ENV.remove(p, false);
  pts.remove(p);
}
void showPath(Particle p, float t, float tf) {
  push();
  PVector prev = p.getRecord().getPrevDispPos();
  PVector translate = p.getVisualizer().getTranslate();
  float scaling = p.getVisualizer().getScaling();

  translate(translate.x, translate.y);
  scale(scaling, - scaling);

  strokeWeight(2 / scaling);
  int col = p.getColor();
  stroke(red(col), green(col), blue(col), 255 * (1 - t / tf));
  ;

  line(prev.x, prev.y, p.getPos().x, p.getPos().y);

  pop();
}

void drawAccelField(int detail) {
  if (ENV.getGroup("accelField").isEmpty()) return;
  if (accelMin == accelMax) TW.relativizeCb.action();
  push();
  translate(ENV.getVisualizer().getTranslate().x, ENV.getVisualizer().getTranslate().y);
  scale(ENV.getVisualizer().getScaling(), - ENV.getVisualizer().getScaling());

  Boundaries bounds = ENV.getBoundaries();
  float left = bounds.getLeftEdge(), right = bounds.getRightEdge(), bottom = bounds.getBottomEdge(), top = bounds.getTopEdge();
  PVector[][] field = Physics.getAccelField2D(ENV.getGroup("accelField"), bounds, detail);

  float dx = (right - left) / (detail - 1), dy = (top - bottom) / (detail - 1);
  for (int i = 0; i < detail; i++) {

    float x = left + i * dx;
    for (int j = 0; j < detail; j++) {

      float y = bottom + j * dy;
      float max = sqrt(dx * dx + dy * dy) / 3, min = max / 10, mag = map(field[i][j].limit(accelMax).mag(), accelMin, accelMax, min, max);
      field[i][j].setMag(mag);
      stroke(map(mag, min, max, 0, 255), 100, map(mag, min, max, 255, 0));
      arrow(x, y, x + field[i][j].x, y + field[i][j].y);
    }
  }
  pop();
}
void arrow(float x1, float y1, float x2, float y2) {
  strokeWeight(2 / ENV.getVisualizer().getScaling());
  line(x1, y1, x2, y2);
  push();
  translate(x2, y2);
  float a = atan2(x1-x2, y2-y1);
  rotate(a);
  line(0, 0, -10 / ENV.getVisualizer().getScaling(), -10 / ENV.getVisualizer().getScaling());
  line(0, 0, 10 / ENV.getVisualizer().getScaling(), -10 / ENV.getVisualizer().getScaling());
  pop();
}
color[] getContourColors(float[] values) {
  color[] cols = new color[values.length];
  float min = values[0];
  float max = values[values.length - 1];
  for (int i = 0; i < cols.length; i++)
    cols[i] = color(map(values[i], min, max, 255, 0), 100, map(values[i], min, max, 0, 255));

  return cols;
}
float[][] getMagField(PVector[][] field, int detail) {
  float[][] magF = new float[detail][detail];
  for (int i = 0; i < detail; i++)
    for (int j = 0; j < detail; j++)
      magF[i][j] = field[i][j].mag();
  return magF;
}
void drawContourLines(int detail, int vals, float minFact, float maxFact) {
  if (ENV.getGroup("contLines").isEmpty()) return;

  Boundaries bounds = ENV.getBoundaries();
  float left = bounds.getLeftEdge(), right = bounds.getRightEdge(), bottom = bounds.getBottomEdge(), top = bounds.getTopEdge();
  float[][] field = Physics.getPotField2D(ENV.getGroup("contLines"), bounds, detail);

  tensors.Float.Matrix matField = new tensors.Float.Matrix(field);
  float min = matField.min() + minFact * abs(matField.min());
  float max = matField.max() + maxFact * abs(matField.max());
  float[] values = Vector.linspace(min, max, vals).get();
  color[] cols = getContourColors(values);

  float dx = (right - left) / (detail - 1), dy = (top - bottom) / (detail - 1);
  push();
  translate(ENV.getVisualizer().getTranslate().x, ENV.getVisualizer().getTranslate().y);
  strokeWeight(2 / ENV.getVisualizer().getScaling());
  scale(ENV.getVisualizer().getScaling(), - ENV.getVisualizer().getScaling());
  for (int i = 0; i < detail- 1; i++)
    for (int j = 0; j < detail - 1; j++) {
      float xL = left + i * dx;
      float xR = left + (i + 1) * dx;
      float yB = bottom + j * dy;
      float yT = bottom + (j + 1) * dy;

      float BL = field[i][j];
      float BR = field[i + 1][j];
      float TL = field[i][j + 1];
      float TR = field[i + 1][j + 1];
      for (int k = 0; k < vals; k++) {
        float val = values[k];

        int matches = 0;
        PVector[] points = new PVector[2];

        if ((TL - val) * (TR - val) <= 0)
          points[matches++] = new PVector(map(val, TL, TR, xL, xR), yT);
        if ((TL - val) * (BL - val) <= 0)
          points[matches++] = new PVector(xL, map(val, BL, TL, yB, yT));

        if (matches < 2 && (BL - val) * (BR - val) <= 0)
          points[matches++] = new PVector(map(val, BL, BR, xL, xR), yB);
        if (matches < 2 && (TR - val) * (BR - val) <= 0)
          points[matches++] = new PVector(xR, map(val, BR, TR, yB, yT));

        stroke(cols[k]);
        if (points[1] != null)
          line(points[0].x, points[0].y, points[1].x, points[1].y);
      }
    }
  pop();
}

void showData(PApplet pa, List<Particle> pts, float[] energies) {
  pa.push();
  int i = 0;
  for (Particle p : pts) {
    pa.fill(p.getColor());
    pa.textSize(12);

    boolean notContained = !ENV.contains(p);
    if (notContained) {
      for (Interaction inter : ENV.getInteractions()) if (inter.includedInAddition()) Environment.implement(p, inter);
      for (ExternalForce ext : ENV.getExternals()) if (ext.includedInAddition()) Environment.implement(p, ext);
    }

    int h = 12;
    PVector pos = ENV.invTransform(p.getPos().x + p.getRadius(), p.getPos().y + p.getRadius());

    float mFact = dispFacts[2];
    float cFact = dispFacts[3];
    float vFact = dispFacts[4];
    float eFact = dispFacts[5];
    String vUnit = dispUnits[4] + "/" + dispUnits[5];
    String eUnit = dispUnits[6];
    if (isFollowingCM()) {
      List<Particle> rel = ENV.getGroup("focus");
      pa.text("Mass: " + p.getMass() * mFact + " " + dispUnits[2], pos.x, pos.y);
      pa.text("Charge: " + p.getCharge() * cFact + " " + dispUnits[3], pos.x, pos.y + h);
      pa.text("Vx: " + p.getRelVel(rel).x * vFact + " " + vUnit, pos.x, pos.y + 2 * h);
      pa.text("Vy: " + p.getRelVel(rel).y * vFact + " " + vUnit, pos.x, pos.y + 3 * h);
      if (energies == null) pa.text("Energy: " + p.getRelEnergy(rel) * eFact + " " + eUnit, pos.x, pos.y + 4 * h);
      else pa.text("Energy: " + energies[i++] * eFact + " " + eUnit, pos.x, pos.y + 4 * h);
    } else {
      pa.text("Mass: " + p.getMass() * mFact + " " + dispUnits[2], pos.x, pos.y);
      pa.text("Charge: " + p.getCharge() * cFact + " " + dispUnits[3], pos.x, pos.y + h);
      pa.text("Vx: " + p.getVel().x * vFact + " " + vUnit, pos.x, pos.y + 2 * h);
      pa.text("Vy: " + p.getVel().y * vFact + " " + vUnit, pos.x, pos.y + 3 * h);
      if (energies == null) pa.text("Energy: " + p.getEnergy() * eFact + " " + eUnit, pos.x, pos.y + 4 * h);
      else pa.text("Energy: " + energies[i++] * eFact + " " + eUnit, pos.x, pos.y + 4 * h);
    }
    if (notContained)
      ENV.neglectAll(p);
  }
  pa.pop();
}
void showData(PApplet pa) {
  showData(pa, ENV.getGroup("showData"), null);
}
void showDistance() {
  push();
  fill(255);
  stroke(255, 80);
  strokeWeight(3);
  textSize(15);
  textAlign(CENTER);
  List<Particle> sd = ENV.getGroup("showDist");
  for (int i = 0; i < sd.size(); i++)
    for (int j = i + 1; j < sd.size(); j++) {
      Particle p1 = sd.get(i), p2 = sd.get(j);
      
      PVector pos1 = ENV.invTransform(p1.getPos());
      PVector pos2 = ENV.invTransform(p2.getPos());
      PVector centerPos = PVector.add(pos1, pos2).div(2);
      line(pos1.x, pos1.y, pos2.x, pos2.y);
     
      PVector dir = PVector.sub(p1.getPos(), p2.getPos());
      //float lenFactor = ENV.getUnits().getLengthUnitScale();
      pos1 = ENV.invTransform(PVector.sub(p1.getPos(), dir.setMag(p1.getRadius())));
      pos2 = ENV.invTransform(PVector.add(p2.getPos(), dir.setMag(p2.getRadius())));
      PVector surfPos = PVector.add(pos1, pos2).div(2);
      //println(pos1, pos2);
      
      float centerDist = p1.getPos().dist(p2.getPos());
      float surfDist = centerDist - p1.getRadius() - p2.getRadius();
      text("C-C: " + centerDist * dispFacts[0] + " " + dispUnits[0], centerPos.x, centerPos.y - 20);
      text("S-S: " + surfDist * dispFacts[0] + " " + dispUnits[0], surfPos.x, surfPos.y);
    }
  pop();
}

boolean isOnEnv() {
  return !settings;
}
boolean canClick() {
  return isOnEnv() && !TW.overlapsSwitch(mouseX, mouseY) && !isControllingCamera();
}
boolean canClickSwitch() {
  return TW.overlapsSwitch(mouseX, mouseY);
}
boolean canClickSettings() {
  return !isOnEnv();
}
boolean canClickRun() {
  return TW.runToggle.overlaps(mouseX, mouseY);
}
boolean canAddParticle() {
  for (int i = 0; i < modes.length; i++) if (modes[i]) return false;
  return true;
}
boolean isControlling() {
  return ENV.getParticle("controlled") != null;
}
boolean isAddingParticle() {
  return ENV.getParticle("toBeAdded") != null;
}
boolean isAddingSoftBody() {
  return toBeAdded != null;
}
boolean isSelecting() {
  return mousePressed && selectingMode() && canClick();
}
boolean isMouseActing() {
  return isSelecting() || isAddingSoftBody() || isAddingParticle() || isControlling();
}
boolean softBodyMode() {
  return modes[0];
}
boolean selectingMode() {
  return modes[1];
}
boolean isReleasing() {
  return isControlling() && ENV.getParticle("controlled").isDynamic();
}
boolean isFollowingCM() {
  return !ENV.getGroup("focus").isEmpty();
}
boolean isControllingCamera() {
  return isPressingShift() && !isAddingParticle();
}

boolean isMouseWithin(PVector pos, float r) {
  return getMousePos(ENV).dist(pos) < r;
}

boolean isPressingControl() {
  return keys[0];
}
boolean isPressingShift() {
  return keys[1];
}
PVector getMousePos(Environment ENV) {
  return ENV.transform(mouseX, mouseY);
}
PVector saveMousePos(Environment ENV) {
  return mousePos = getMousePos(ENV);
}
PVector getSavedMousePos() {
  return mousePos;
}
PVector getMouseVel(float cte) {
  return PVector.sub(getSavedMousePos(), getMousePos(ENV)).mult(cte);
}
