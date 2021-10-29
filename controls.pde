void mousePressed() {
  if (TW.anyPlaying()) TW.toggleMovie();
  else toggle();
}

void mouseReleased() {
  if (canClick())
    if (isControlling()) stopControlling(true);
    else if (canAddParticle() && isAddingParticle()) setParticleAddition();
}
void mouseWheel(MouseEvent event) {
  if (TW.anyPlaying()) {
    if (isPressingShift()) applyZoom(event, movieEnv, false);
  } else if ((isOnEnv() || !TW.anyShowToggle()) && isControllingCamera())
    applyZoom(event, ENV, true);
}
void mouseDragged() {
  if (TW.anyPlaying()) {
    if (isPressingShift()) dragScreen(movieEnv);
  } else if (isControllingCamera() && isOnEnv())
    dragScreen(ENV);
}

void keyPressed() {
  if (key == CODED && keyCode == CONTROL) keys[0] = true;
  else if (key == CODED && keyCode == SHIFT) keys[1] = true;
  else if (keyCode == BACKSPACE) keys[2] = true;
  else if (key == 'r') keys[3] = true;
  else if (key == 'c') keys[4] = true;
  else if (key == ' ') keys[5] = true;
  else if (key == 'q') keys[6] = true;
  else if (key == 'b') keys[7] = true;
  else if (key == 'e') keys[8] = true;
  else if (key == CODED && keyCode == UP) keys[9] = true;
  else if (key == CODED && keyCode == DOWN) keys[10] = true;
  else if (key == CODED && keyCode == LEFT) keys[11] = true;
  else if (key == CODED && keyCode == RIGHT) keys[12] = true;
  else if (key == 'f') keys[13] = true;
  for (int i = 0; i < keysDigits.length; i++)
    if (key == Character.forDigit(i + 1, 10)) {
      keysDigits[i] = true;
      break;
    }

  if (!isOnEnv() && !TW.anyPlaying()) navigateGlobal();
  else {
    if (!isMouseActing()) navigateModes();
    if (key == '') {
      ENV.select(ENV.getParticles());
      setPrompt("All particles selected");
    } else
      navigateCustoms();
  }

  if (keys[2] && (isAddingParticle() || isAddingSoftBody())) {
    interruptAddition();
    setPrompt("Interrupted");
  }
  if (keys[3]) {
    TW.removeCb.action();
    setPrompt("Particles removed");
  } else if (key == '') {
    TW.clearCb.action();
    setPrompt("Particles cleared");
  }
  if (keys[4] && !TW.controlCb.cannotClick()) {
    TW.controlCb.action();
    if (isControlling())
      setPrompt("Particle ready to control");
    else
      setPrompt("Particle released");
  }
  if (keys[5])
    if (TW.anyPlaying())
      pausedMovie = !pausedMovie;
    else
      pause = !pause;
  if (keys[6] && !TW.attachCb.cannotClick()) {
    TW.attachCb.action();
    setPrompt("Particles attached");
  }
  if (keys[7]) {
    TW.addBunchCb.action();
    setPrompt("Added " + addBunch + " particle(s)");
  }
  if (keys[8] && !TW.fixCb.cannotClick()) {
    TW.fixCb.action();
    setPrompt("Toggled static");
  }
  if (keys[9]) {
    dtExp++;
    updateTimestep();
    setPrompt(adaptToFramerate ? "Timestep adapted to framerate!" : "Timestep: " + timestep);
  }
  if (keys[10]) {
    dtExp--;
    updateTimestep();
    setPrompt(adaptToFramerate ? "Timestep adapted to framerate!" : "Timestep: " + timestep);
  }
  if (keys[11] && intPerFrame > 1) {
    intPerFrame--;
    setPrompt("Integrations per frame: " + intPerFrame);
  }
  if (keys[12]) {
    intPerFrame++;
    setPrompt("Integrations per frame: " + intPerFrame);
  }
  if (keys[13]) {
    drawMouseCoords = !drawMouseCoords;
    String isOn = drawMouseCoords ? "on" : "off";
    setPrompt("Mouse coordinates " + isOn);
  }

  for (int i = 0; i < ENV.getBackupCount(); i++)
    if (keysDigits[i])
      if (keys[2] && keys[0] && !TW.dataCbs[5 * i + 2].cannotClick()) {
        TW.dataCbs[5 * i + 2].action();
        setPrompt("Backup " + (i + 1) + ": Constants loaded");
      } else if (keys[0] && !TW.dataCbs[5 * i + 1].cannotClick()) {
        TW.dataCbs[5 * i + 1].action();
        setPrompt("Backup " + (i + 1) + ": Loaded");
      } else if (keys[2] && !TW.dataCbs[5 * i + 3].cannotClick()) {
        TW.dataCbs[5 * i + 3].action();
        setPrompt("Backup " + (i + 1) + ": Removed");
      } else if (!TW.dataCbs[5 * i + 0].cannotClick()) {
        TW.dataCbs[5 * i + 0].action();
        setPrompt("Backup " + (i + 1) + ": Saved");
      }
}
void keyReleased() {
  if (key == CODED && keyCode == CONTROL) keys[0] = false;
  else if (key == CODED && keyCode == SHIFT) keys[1] = false;
  else if (keyCode == BACKSPACE) keys[2] = false;
  else if (key == 'r') keys[3] = false;
  else if (key == 'c') keys[4] = false;
  else if (key == ' ') keys[5] = false;
  else if (key == 'q') keys[6] = false;
  else if (key == 'b') keys[7] = false;
  else if (key == 'e') keys[8] = false;
  else if (key == CODED && keyCode == UP) keys[9] = false;
  else if (key == CODED && keyCode == DOWN) keys[10] = false;
  else if (key == CODED && keyCode == LEFT) keys[11] = false;
  else if (key == CODED && keyCode == RIGHT) keys[12] = false;
  else if (key == 'f') keys[13] = false;
  for (int i = 0; i < keysDigits.length; i++)
    if (key == Character.forDigit(i + 1, 10)) {
      keysDigits[i] = false;
      break;
    }
}
void interruptAddition() {
  ENV.removeFromGroups(ENV.getParticle("toBeAdded")).removeParticle("toBeAdded");
  if (isAddingSoftBody())
    for (Particle p : toBeAdded.getLinealBody())
      ENV.removeFromGroups(p);
  toBeAdded = null;
}
void toggle() {
  if (canClickSwitch()) TW.toggleSwitch();
  if (canClickSettings()) TW.toggle();
  if (canClickRun()) TW.toggleRun();

  if (canClick())
    if (isControlling()) prepareControlledRelease();
    else if (canAddParticle()) {
      float mDens = md * pow(10, ctePots[6]) / selFacts[2];
      float cDens = cd * pow(10, ctePots[7]) / selFacts[3];
      float radius = rd * pow(10, ctePots[8]) / selFacts[0];
      prepareParticleAddition(mDens, cDens, radius, color(ptR, ptG, ptB));
    } else if (softBodyMode()) 
      if (toBeAdded != null) setSoftBodyAddition(); 
      else {
        float mDens = mdSb * pow(10, valSbPots[1]) / selFacts[2];
        float cDens = cdSb * pow(10, valSbPots[2]) / selFacts[3];
        float radius = rdSb * pow(10, valSbPots[3]) / selFacts[0];
        float stf = stiffness * pow(10, valSbPots[0]) / selFacts[2] * pow(selFacts[1], 2);
        float dmp = damp * pow(10, valSbPots[4]) * selFacts[1] / selFacts[2];
        prepareSoftBodyAddition(wdth * valSbPots[5], hght * valSbPots[6], mDens, cDens, radius, stf, dmp, color(sbR, sbG, sbB), terms, decay);
      } else if (selectingMode()) ENV.switchSelect(saveMousePos(ENV));
  if (!isOnEnv() && showPrev && TW.globalShowToggles[2]) TW.selectInPreview();
  else if (!isOnEnv() && showPrevSb && TW.globalShowToggles[1]) TW.selectSoftBodyPreview();
}
