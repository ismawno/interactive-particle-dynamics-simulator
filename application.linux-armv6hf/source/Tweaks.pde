class Tweaks {

  //Global
  checkBox.CheckBox[] globalCbs;
  checkBox.CheckBox swtch, runToggle, saveAndExit;
  ControlP5 genCp, sbCp, selCp, intCp, shapesCp, dataCp, unitsCp, instrCp, movieCp;
  ControlP5[] cps;

  int w, h;
  float scalingX = 1, scalingY = 1;
  boolean[] globalShowToggles;

  //Movie
  checkBox.CheckBox[] movieCbs;
  checkBox.CheckBox exitMovieCb, pauseMovieCb, reverseMovieCb, trailMovieCb;

  //General
  checkBox.CheckBox[] generalCbs;
  checkBox.CheckBox[] potsCbs;
  checkBox.CheckBox mergeCb, trailsCb, clearCb, addBunchCb, dynBoxCb, resetCamCb, resetBoundsCb, showOriginCb, 
    saveCustomCb, drawPathCb;
  checkBox.CheckBox addExpRepCb, addExpAtCb, remExpRepCb, remExpAtCb, addExpVel, remExpVel, mDensCb, cDensCb;

  boolean[] generalToggles, toggleCustoms;
  String[] generalNames;

  //SoftBodies
  checkBox.CheckBox[] softBodiesCbs;
  checkBox.CheckBox addSoftBodyCb, relFixedCb, attachCb, autoAdjustEqCb, 
    sbMDensCb, sbCDensCb, previewSbCb, crossJointsCb, plusWCb, minusWCb, plusHCb, minusHCb;
  SoftBody previewSb;
  Environment softBodyEnv;

  //Selected
  checkBox.CheckBox[] selectedCbs;
  checkBox.CheckBox selCb, selAllCb, deSelAllCb, removeCb, controlCb, fixCb, setMCb, setCCb, setRCb, CMCb, warpCb, 
    showDataCb, vecFCb, contLCb, showDistCb, previewCb, collectDataCb, histCb, plotDistCb, plotXYCb, clearMemCb, relativizeCb;
  List<PVector> previewPos = new ArrayList<PVector>();

  //Integration
  checkBox.CheckBox[] integCbs;
  checkBox.CheckBox pauseCb, resetTimeCb, reverseCb, runTimingCb, interPPCb, interBCb, adaptToFramerateCb;
  Integrator.METHOD[] metList;

  //Data
  checkBox.CheckBox[] dataCbs;
  checkBox.CheckBox saveFramesCb, saveDataCb, doneSaveDataCb, saveProgramCb;

  //Shapes
  checkBox.CheckBox[] shapesCbs;
  checkBox.CheckBox boxCb, fBoxCb, circCb;

  //Units
  checkBox.CheckBox[] unitsCbs;
  checkBox.CheckBox envUnitsCb;

  //Instructions
  checkBox.CheckBox[] instrCbs, examplesCbs;
  checkBox.CheckBox arrowLeftCb, arrowRightCb;
  Environment examplesEnv;
  int exampleId, totExamples;
  boolean[] instrToggles;

  Tweaks() {
    this.w = 200;
    this.h = 50;
  }

  void initialize() {
    initControllers();
    initGlobal();
    initSpecial();
    initGeneral();
    initSoftBody();
    initSelected();
    initIntegration();
    initShapes();
    initDataManagement();
    initUnits();
    initInstructions();
    initMovie();
    hide();
    plots = new Plots(main);
    for (ControlP5 cp5 : cps)
      for (ControllerInterface<?> ci : cp5.getAll())
        ci.setPosition(new float[] {ci.getPosition()[0] * scalingX, ci.getPosition()[1] * scalingY});
  }
  void toggle() {
    toggleGlobal();
    toggleExit();
    if (globalShowToggles[0])
      toggleGeneral();
    else if (globalShowToggles[1])
      toggleSoftBody();
    else if (globalShowToggles[2])
      toggleSelected();
    else if (globalShowToggles[3])
      toggleIntegration();
    else if (globalShowToggles[4])
      toggleShapes();
    else if (globalShowToggles[5])
      toggleDataManagement();
    else if (globalShowToggles[6])
      toggleUnits();
    else if (globalShowToggles[7])
      toggleInstructions();
  }
  void show() {
    push();
    scale(scalingX, scalingY);
    showGlobal();
    showExit();
    if (globalShowToggles[0])
      showGeneral();
    else if (globalShowToggles[1])
      showSoftBody();
    else if (globalShowToggles[2])
      showSelected();
    else if (globalShowToggles[3])
      showIntegration();
    else if (globalShowToggles[4])
      showShapes();
    else if (globalShowToggles[5])
      showDataManagement();
    else if (globalShowToggles[6])
      showUnits();
    else if (globalShowToggles[7])
      showInstructions();
    pop();
  }

  void initControllers() {
    genCp = new ControlP5(main);
    sbCp = new ControlP5(main);
    selCp = new ControlP5(main);
    intCp = new ControlP5(main);
    shapesCp = new ControlP5(main);
    dataCp = new ControlP5(main);
    unitsCp = new ControlP5(main);
    instrCp = new ControlP5(main);
    movieCp = new ControlP5(main);
    cps = new ControlP5[] {genCp, sbCp, selCp, intCp, shapesCp, dataCp, unitsCp, instrCp, movieCp};
  }
  void initSpecial() {
    swtch = new checkBox.CheckBox(main, width / scalingX - w, height / scalingY - h, 200, 50, "Settings") {
      @Override public void tweak() {
        setDesc("Turns on or off the settings window");
      }
      @Override public void action() {
        settings = !settings;
        if (!settings)
          hideSl();
        else {
          simScreenshot = get();
          simScreenshot.resize(16 * 30, 9 * 30);
          for (int i = 0; i < globalShowToggles.length; i++)
            if (globalShowToggles[i]) {
              showSl(i);
              break;
            }
        }
      }
      @Override public boolean isDone() {
        return settings;
      }
    };
    runToggle = new checkBox.CheckBox(main, width / scalingX - 2 * w, height / scalingY - h, 200, 50, "Run") {
      @Override public void tweak() {
        setDesc("Runs the simulation in background while you are in settings");
      }
      @Override public void action() {
        run = !run;
      }
      @Override public boolean isDone() {
        return run;
      }
    };
    saveAndExit = new checkBox.CheckBox(main, 0, (globalShowToggles.length + 1) * h, w, h, "Save & exit") {
      @Override public void action() {
        ENV.stopRecording();
        ENV.clearRecords();
        ENV.save(main);
        exit();
      }
    };
    saveAndExit.setScale(scalingX, scalingY).tweak();
    swtch.setScale(scalingX, scalingY).tweak();
    runToggle.setScale(scalingX, scalingY).tweak();
  }
  void toggleSwitch() {
    if (anyPlaying()) return;
    swtch.action();
    for (Particle p : ENV.getGroup("trails"))
      p.getVisualizer().setTrailCapacity(trailsCap).setTrailLength(trailsLen);
  }
  void showSwitch() {
    if (!anyPlaying()) {
      push();
      scale(scalingX, scalingY);
      swtch.show();
      pop();
    }
  }
  void toggleRun() {
    runToggle.action();
  }
  void showRun() {
    push();
    scale(scalingX, scalingY);
    runToggle.show();
    pop();
  }
  void toggleExit() {
    if (saveAndExit.overlaps(mouseX, mouseY))
      saveAndExit.action();
  }
  void showExit() {
    saveAndExit.show();
  }
  boolean overlapsSwitch(float x, float y) {
    return swtch.overlaps(x, y);
  }

  void initGlobal() {
    int x = 0;
    int y = 0;

    globalNames = new String[] {"General", "Soft bodies", "Advanced", "Integration", "Shapes", "Data management", "Units", "Help & controls"};
    globalShowToggles = new boolean[globalNames.length];
    globalCbs = new checkBox.CheckBox[globalNames.length];

    for (int i = 0; i < globalCbs.length; i++) {
      globalCbs[i] = new checkBox.CheckBox(main, x, y + (i + 1) * h, w, h, globalNames[i]) {
        @Override public void action() {
          if (!globalShowToggles[getInt()]) {
            hide();
            TW.show(getInt());
            indexGlobal = getInt();
          } else {
            hide();
            indexGlobal = 0;
          }
        }
        @Override public boolean isDone() {
          return globalShowToggles[getInt()];
        }
      };
      globalCbs[i].setInt(i);
    }
    for (checkBox.CheckBox cb : globalCbs) cb.setScale(scalingX, scalingY).tweak();
  }
  void toggleGlobal() {
    for (checkBox.CheckBox cb : globalCbs)
      if (cb.overlaps(mouseX, mouseY)) {
        cb.action();
        break;
      }
  }
  void showGlobal() {
    for (checkBox.CheckBox cb : globalCbs)
      cb.show();
    push();
    textSize(25);
    text("Settings", 10, 30);
    stroke(255);
    strokeWeight(3);
    line(225, 0, 225, height / scalingY);
    if (!anyShowToggle()) {
      int xi = 250, yi = 80, xf = 920;
      int h = 35;
      textSize(50);
      text("SPDSim", xi, yi - 25); 
      textSize(24);
      text("Simple Particle Dynamics Simulator", xi, yi);
      text("Current particles: " + ENV.getParticles().size(), xi, yi + h);
      text("Current selected particles: " + ENV.getSelected().size(), xi, yi + 2 * h);
      text("Press shift while hovering on a checkbox to see a brief description of what it does!", xi, yi + 3 * h);
      text("If you feel lost, go to 'Help & controls' to read the small guide and see some examples of what you can do.", xi, yi + 4 * h);
      text("There are many hotkeys available that make your life easier, all listed in 'Help & controls'.", xi, yi + 5 * h);

      h = 30;
      strokeWeight(2);
      textSize(20);
      noFill();
      float fact = dispFacts[0];
      String unit = dispUnits[0];
      float X = width * fact / ENV.getVisualizer().getScaling(), Y = height * fact / ENV.getVisualizer().getScaling();
      text("Dimensions of the environment: (" + X + unit + " x " + Y + unit + ") = " + X * Y + unit + "^2", xi, yi + 8 * h);
      rect(xi, yi + 9 * h, 16 * 30, 9 * 30);
      if (simScreenshot != null)
        image(simScreenshot, xi, yi + 9 * h);
    }
    pop();
  }

  void initGeneral() {
    int x = 250;
    int y = 0;
    List<checkBox.CheckBox> tempCbs = new ArrayList<checkBox.CheckBox>();

    generalNames = new String[] {"Constrain", "Add static", "Draw boundaries", "Collisions"};
    generalToggles = new boolean[generalNames.length];

    for (int i = 0; i < generalNames.length; i++) {
      checkBox.CheckBox cb = new checkBox.CheckBox(main, x, y + (i + 1) * h, w, h, generalNames[i]) {
        @Override public void action() {
          generalToggles[getInt()] = !generalToggles[getInt()];
        }
        @Override public boolean isDone() {
          return generalToggles[getInt()];
        }
      };
      tempCbs.add(cb.setInt(i));
    }
    generalToggles[0] = true;
    generalToggles[2] = true;
    generalToggles[3] = true;

    tempCbs.get(0).setDesc("Make the particles bounce at the boundaries of the scene.");
    tempCbs.get(1).setDesc("The particles you add will be static: They will not move at all.");
    tempCbs.get(2).setDesc("Draw the boundaries of the scene. If constrain is on, particles will bounce at these boundaries.");
    tempCbs.get(3).setDesc("Enable collisions between particles. By default, they will bounce against each other.");

    ctePots = new int[9];
    for (int i = 0; i < ctePots.length; i++) {
      checkBox.CheckBox minus = new checkBox.CheckBox(main, 0, 0, w / 8, h / 2, "-") {
        @Override public void action() {
          ctePots[getInt()]--;
        }
      };
      checkBox.CheckBox plus = new checkBox.CheckBox(main, 0, 0, w / 8, h / 2, "+") {
        @Override public void action() {
          ctePots[getInt()]++;
        }
      };
      tempCbs.add(minus.setInt(i));
      tempCbs.add(plus.setInt(i));
    }
    String[] interNames = new String[] {"Electric (+) (G, I)", "Electric (-) (G, I)", "Exponential(G, I)", "Gravitation(G, I)"};
    for (int i = 0; i < 4; i++) {
      checkBox.CheckBox selCb = new checkBox.CheckBox(main, x + 3 * w, y + (i + 1.5) * h, w / 6, h / 2, "Sel") {
        @Override public void action() {
          boolean allSelected = !ENV.getInteractions().get(getInt()).getParticles().isEmpty();
          for (Particle p : ENV.getInteractions().get(getInt()).getParticles()) if (!p.isSelected()) allSelected = false;
          if (allSelected)
            ENV.unSelect(ENV.getInteractions().get(getInt()).getParticles());
          else
            (isPressingControl() ? ENV : ENV.clearSelected()).select(ENV.getInteractions().get(getInt()).getParticles());
        }
        @Override public void tweak() {
          textSize = 18;
        }
        @Override public boolean isDone() {
          for (Particle p : ENV.getInteractions().get(getInt()).getParticles()) if (!p.isSelected()) return false;
          return !ENV.getInteractions().get(getInt()).getParticles().isEmpty();
        }
      };
      checkBox.CheckBox intCb = new checkBox.CheckBox(main, x + w, y + (i + 1) * h, w, h, interNames[i]) {
        @Override public void action() {
          interRoutine(ENV.getInteractions().get(getInt()));
        }
        @Override public boolean isDone() {
          Interaction inter = ENV.getInteractions().get(getInt()); 
          return inter.includedInAddition();
        }
        @Override public boolean hasToClick() {
          Interaction inter = ENV.getInteractions().get(getInt()); 
          return !isDone() && !inter.getParticles().isEmpty();
        }
      };
      tempCbs.add(selCb.setInt(i));
      tempCbs.add(intCb.setInt(i));
    }
    String[] extNames = new String[] {"Gravity(G, EF)", "Drag(G, EF)"};
    for (int i = 0; i < 2; i++) {
      checkBox.CheckBox selCb = new checkBox.CheckBox(main, x + 3 * w, y + (i + 5.5) * h, w / 6, h / 2, "Sel") {
        @Override public void action() {
          boolean allSelected = !ENV.getExternals().get(getInt()).getParticles().isEmpty();
          for (Particle p : ENV.getExternals().get(getInt()).getParticles()) if (!p.isSelected()) allSelected = false;

          if (allSelected) 
            ENV.unSelect(ENV.getExternals().get(getInt()).getParticles());
          else
            (isPressingControl() ? ENV : ENV.clearSelected()).select(ENV.getExternals().get(getInt()).getParticles());
        }
        @Override public boolean isDone() {
          for (Particle p : ENV.getExternals().get(getInt()).getParticles()) if (!p.isSelected()) return false;
          return !ENV.getExternals().get(getInt()).getParticles().isEmpty();
        }
      };
      checkBox.CheckBox extCb = new checkBox.CheckBox(main, x + w, y + (i + 5) * h, w, h, extNames[i]) {
        @Override public void action() {
          extRoutine(ENV.getExternals().get(getInt()));
        }
        @Override public boolean isDone() {
          ExternalForce ext = ENV.getExternals().get(getInt()); 
          return ext.includedInAddition();
        }
        @Override public boolean hasToClick() {
          ExternalForce ext = ENV.getExternals().get(getInt()); 
          return !isDone() && !ext.getParticles().isEmpty();
        }
      };
      tempCbs.add(selCb.setInt(i));
      tempCbs.add(extCb.setInt(i));
    }

    tempCbs.get(23).setDesc("Enables repulsive electrical interactions between particles, assuming positive charge.");
    tempCbs.get(25).setDesc("Enables attractive electrical interactions between particles, assuming positive charge.");
    tempCbs.get(27).setDesc("Enables exponential interactions. Can be attractive or repulsive depending on the constant and charge sign.");
    tempCbs.get(29).setDesc("Enables gravitational interactions. It is always attractive and depends on the particles' mass.");
    tempCbs.get(31).setDesc("Enables gravity: A constant force whose direction (up or down) depends on the sign.");
    tempCbs.get(33).setDesc("Enables drag, a force that slows particles down depending on their velocities, much like a fluid.");

    addExpRepCb = new checkBox.CheckBox(main, x + 2.5 * w + w / 8, y + 3 * h / 2, w / 8, h / 2, "+") {
      @Override public void action() {
        expRep++;
      }
    };
    remExpRepCb = new checkBox.CheckBox(main, x + 2.5 * w, y + 3 * h / 2, w / 8, h / 2, "-") {
      @Override public void action() {
        expRep--;
      }
      @Override public boolean cannotClick() {
        return expRep < 2;
      }
    };

    genCp.addSlider("elRepCte").setPosition(x + 2 * w + 10, y + h).setRange(1, 10).setValue(elRepCte).setSize(round(scalingX * w * 2 / 3), round(scalingY * h / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Units").setColorLabel(color(255));
    addExpAtCb = new checkBox.CheckBox(main, x + 2.5 * w + w / 8, y + 5 * h / 2, w / 8, h / 2, "+") {
      @Override public void action() {
        expAt++;
      }
    };
    remExpAtCb = new checkBox.CheckBox(main, x + 2.5 * w, y + 5 * h / 2, w / 8, h / 2, "-") {
      @Override public void action() {
        expAt--;
      }
      @Override public boolean cannotClick() {
        return expAt < 2;
      }
    };

    addExpVel = new checkBox.CheckBox(main, x + 2.5 * w + w / 8, y + 13 * h / 2, w / 8, h / 2, "+") {
      @Override public void action() {
        expVel++;
      }
    };
    remExpVel = new checkBox.CheckBox(main, x + 2.5 * w, y + 13 * h / 2, w / 8, h / 2, "-") {
      @Override public void action() {
        expVel--;
      }
      @Override public boolean cannotClick() {
        return expVel < 2;
      }
    };

    genCp.addSlider("elAtCte").setPosition(x + 2 * w + 10, y + 2 * h).setRange(1, 10).setValue(elAtCte).setSize(round(scalingX * w * 2 / 3), round(scalingY * h / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Units").setColorLabel(color(255));
    genCp.addSlider("expCte1").setPosition(x + 2 * w + 10, y + 3* h).setRange( - 10, 10).setValue(expCte1).setSize(round(scalingX * w * 2 / 3), round(scalingY * h / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Units").setColorLabel(color(255));
    genCp.addSlider("expCte2").setPosition(x + 2 * w + 10, y + 3.5 * h).setRange( - 1, 1).setValue(expCte2).setSize(round(scalingX * w * 2 / 3), round(scalingY * h / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Units").setColorLabel(color(255));

    genCp.addSlider("gravitCte").setPosition(x + 2 * w + 10, y + 4 * h).setRange(1, 10).setValue(gravitCte).setSize(round(scalingX * w * 2 / 3), round(scalingY * h / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Units").setColorLabel(color(255));

    genCp.addSlider("gravCte").setPosition(x + 2 * w + 10, y + 5 * h).setRange( - 10, 10).setValue(gravCte).setSize(round(scalingX * w * 2 / 3), round(scalingY * h / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Units").setColorLabel(color(255));

    genCp.addSlider("dragCte").setPosition(x + 2 * w + 10, y + 6 * h).setRange(1, 10).setValue(dragCte).setSize(round(scalingX * w * 2 / 3), round(scalingY * h / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Units").setColorLabel(color(255));

    int len = generalNames.length + 1;
    mergeCb = new checkBox.CheckBox(main, x, y + len++ * h, w, h, "Merge") {
      @Override public void tweak() {
        setDesc("If collisions are on, particles will merge on collisions instead of bouncing.");
      }
      @Override public void action() {
        if (!isDone())
          ENV.getCollider().setCollisionMode(Collider.COLLISIONMODE.MERGE);
        else
          ENV.getCollider().setCollisionMode(Collider.COLLISIONMODE.BOUNCE);
      }
      @Override public boolean isDone() {
        return ENV.getCollider().getCollisionMode() == Collider.COLLISIONMODE.MERGE;
      }
      @Override public boolean cannotClick() {
        return !collisions();
      }
    };
    drawPathCb = new checkBox.CheckBox(main, x, y + len++ * h, w, h, "Draw path(G)") {
      @Override public void tweak() {
        setDesc("Particles will have its path predicted by some timesteps. Can severely reduce performance!");
      }
      @Override public void action() {
        groupRoutine("drawPath");
        if (!isPressingControl())
          drawPathOnAddition = !drawPathOnAddition;
      }
      @Override public boolean isDone() {
        return drawPathOnAddition;
      }
      @Override public boolean hasToClick() {
        return !ENV.getGroup("drawPath").isEmpty() && !isDone();
      }
    };
    trailsCb = new checkBox.CheckBox(main, x, y + len++ * h, w, h, "Trails(G)") {
      @Override public void tweak() {
        setDesc("Particles will leave a small trail that will fade out over time. Can severely reduce performance!");
      }
      @Override public void action() {
        groupRoutine("trails");
        if (!isPressingControl())
          drawTrailsOnAddition = !drawTrailsOnAddition;
        ENV.getVisualizer().noTrails();
        ENV.getVisualizer().trails(ENV.getGroup("trails"));
      }
      @Override public boolean isDone() {
        return drawTrailsOnAddition;
      }
      @Override public boolean hasToClick() {
        return !ENV.getGroup("trails").isEmpty() && !isDone();
      }
    };
    genCp.addSlider("trailsCap").setPosition(x + w, trailsCb.getPos().y).setRange(100, 1000).setValue(100).setSize(round(scalingX * w * 2 / 3), round(scalingY * h / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Trail cap").setColorLabel(color(255));
    genCp.addSlider("trailsLen").setPosition(x + w, trailsCb.getPos().y + h / 2).setRange(1, 10).setValue(1).setSize(round(scalingX * w * 2 / 3), round(scalingY * h / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Trail length").setColorLabel(color(255));
    clearCb = new checkBox.CheckBox(main, x, y + len++ * h, w, h, "Clear") {
      @Override public void tweak() {
        setDesc("Removes all particles. HOTKEY: CONTROL + R");
      }
      @Override public void action() {
        if (isControlling()) stopControlling(true);
        ENV.clear().clearGroups().clearSelected();
      }
      @Override public boolean isDone() {
        return ENV.isEmpty();
      }
    };
    addBunchCb = new checkBox.CheckBox(main, x, y + len++ * h, w, h, "Add bunch") {
      @Override public void tweak() {
        setDesc("Adds a bunch of particles scattered randomly around the scene. HOTKEY: B");
      }
      @Override public void action() {
        for (int i = 0; i < addBunch; i++) {
          Boundaries bounds = ENV.getBoundaries();
          float x = random(bounds.getLeftEdge(), bounds.getRightEdge()), y = random(bounds.getBottomEdge(), bounds.getTopEdge());
          Particle p;
          if (anyCustoms())
            p = ENV.getCustoms().getPts().get(indexCustoms()).blindCopy().setSelected(false).setPos(x, y);
          else {
            float mDens = md * pow(10, ctePots[6]) / selFacts[2];
            float cDens = cd * pow(10, ctePots[7]) / selFacts[3];
            float radius = rd * pow(10, ctePots[8]) / selFacts[0];
            p = getParticleAddition(new PVector(x, y), mDens, cDens, radius, color(ptR, ptG, ptB));
          }
          ENV.add(p);
          addToDefaultGroups(p);
        }
      }
    };

    genCp.addSlider("addBunch").setPosition(x + w, y + (len - 0.5) * h).setRange(1, 100).setValue(1).setSize(round(scalingX * w * 2 / 3), round(scalingY * h / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("N").setColorLabel(color(255));


    mDensCb = new checkBox.CheckBox(main, x + w + 35, y + 11 * h, w / 2, h / 2, "Density") {
      @Override public void action() {
        isMDens = !isMDens;
      }
      @Override public boolean isDone() {
        return isMDens;
      }
      @Override public void tweak() {
        textSize = 15;
      }
    };
    cDensCb = new checkBox.CheckBox(main, x + w + 35, y + 11.5 * h, w / 2, h / 2, "Density") {
      @Override public void action() {
        isCDens = !isCDens;
      }
      @Override public boolean isDone() {
        return isCDens;
      }
      @Override public void tweak() {
        textSize = 15;
      }
    };
    saveCustomCb = new checkBox.CheckBox(main, 520 + 35, 660, w, h, "Save particle configuration") {
      @Override public void tweak() {
        textSize = 17;
        setDesc("Save the current particle configuration to a slot to be able to use it again later");
      }
      @Override public void action() {
        float mDens = md * pow(10, ctePots[6]) / selFacts[2];
        float cDens = cd * pow(10, ctePots[7]) / selFacts[3];
        float radius = rd * pow(10, ctePots[8]) / selFacts[0];
        Particle p = getParticleAddition(new PVector(0, 0), mDens, cDens, radius, color(ptR, ptG, ptB));
        p.getVisualizer().setTranslate(0, 0);
        ENV.getCustoms().getPts().add(p);
      }
      @Override public boolean cannotClick() {
        return ENV.getCustoms().getPts().size() >= toggleCustoms.length;
      }
    };

    genCp.addSlider("md").setPosition(x, y + 11 * h).setRange(1, 10).setValue(1).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Mass").setColorLabel(color(255));
    genCp.addSlider("cd").setPosition(x, y + 11.5 * h).setRange(-10, 10).setValue(1).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Charge").setColorLabel(color(255));
    genCp.addSlider("rd").setPosition(x, y + 12 * h).setRange(1, 10).setValue(10).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Radius").setColorLabel(color(255));

    genCp.addSlider("ptR").setPosition(x, y + 13 * h).setRange(0, 255).setValue(255).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 0, 0))
      .setColorActive(color(255, 0, 0, 130)).setColorBackground(color(255, 130)).setLabel("Red").setColorLabel(color(255));
    genCp.addSlider("ptG").setPosition(x, y + 13.5 * h).setRange(0, 255).setValue(255).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(0, 255, 0))
      .setColorActive(color(0, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Green").setColorLabel(color(255));
    genCp.addSlider("ptB").setPosition(x, y + 14 * h).setRange(0, 255).setValue(255).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(0, 0, 255))
      .setColorActive(color(0, 0, 255, 130)).setColorBackground(color(255, 130)).setLabel("Blue").setColorLabel(color(255));

    genCp.addSlider("ptsPlot").setPosition(4.75 * w, 12.5 * h).setRange(100, 1000).setValue(100).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Points of the plot").setColorLabel(color(255));
    genCp.addSlider("minPlot").setPosition(4.75 * w, 13 * h).setRange(1, 100).setValue(1).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Minimum distance").setColorLabel(color(255));
    genCp.addSlider("maxPlot").setPosition(4.75 * w, 13.5 * h).setRange(1, 1000).setValue(100).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Maximum distance").setColorLabel(color(255));

    dynBoxCb = new checkBox.CheckBox(main, x + 2 * w, y + 8 * h, w / 2, h, "Dynamic boundaries") {
      @Override public void tweak() {
        textSize = 17;
        setDesc("The boundaries will follow and adapt to the camera.");
      }
      @Override public void action() {
        dynBox = !dynBox;
        if (dynBox) updateBox(ENV);
      }
      @Override public boolean isDone() {
        return dynBox;
      }
    };
    showOriginCb = new checkBox.CheckBox(main, x + 2 * w + w / 2, y + 8 * h, w / 2, h, "Show origin") {
      @Override public void tweak() {
        textSize = 17;
        setDesc("Shows the origin as a cross X.");
      }
      @Override public void action() {
        showOrigin = !showOrigin;
      }
      @Override public boolean isDone() {
        return showOrigin;
      }
    };
    resetCamCb = new checkBox.CheckBox(main, x + 2 * w, y + 9 * h, w / 2, h, "Reset camera") {
      @Override public void tweak() {
        textSize = 17;
        setDesc("Resets the camera's position and zoom.");
      }
      @Override public void action() {
        if (dynBox) resetBoundaries();
        resetCamera();
      }
      @Override public boolean isDone() {
        return ENV.getVisualizer().getScaling() == 1 && ENV.getVisualizer().getTranslate().x == width / 2 && ENV.getVisualizer().getTranslate().y == height / 2;
      }
    };
    resetBoundsCb = new checkBox.CheckBox(main, x + 2 * w + w / 2, y + 9 * h, w / 2, h, "Reset boundaries") {
      @Override public void tweak() {
        textSize = 17;
        setDesc("Resets the boundaries' position to align with the camera.");
      }
      @Override public void action() {
        resetBoundaries();
      }
      @Override public boolean isDone() {
        return ENV.getBoundaries().getConstrainPos().x == 0.0 && ENV.getBoundaries().getConstrainPos().y == 0.0 && ENV.getBoundaries().getConstrainDim().x == width && ENV.getBoundaries().getConstrainDim().y == height;
      }
    };

    int id = generalNames.length;
    tempCbs.get(0 + id).setPos(x + 3 * w + h / 2 + 25, y + h);
    tempCbs.get(1 + id).setPos(x + 3 * w + h + 25, y + h);
    tempCbs.get(2 + id).setPos(x + 3 * w + h / 2 + 25, y + 2 * h);
    tempCbs.get(3 + id).setPos(x + 3 * w + h + 25, y + 2 * h);
    tempCbs.get(4 + id).setPos(x + 3 * w + h / 2 + 25, y + 3 * h);
    tempCbs.get(5 + id).setPos(x + 3 * w + h + 25, y + 3 * h);
    tempCbs.get(6 + id).setPos(x + 3 * w + h / 2 + 25, y + 4 * h);
    tempCbs.get(7 + id).setPos(x + 3 * w + h + 25, y + 4 * h);
    tempCbs.get(8 + id).setPos(x + 3 * w + h / 2 + 25, y + 5 * h);
    tempCbs.get(9 + id).setPos(x + 3 * w + h + 25, y + 5 * h);
    tempCbs.get(10 + id).setPos(x + 3 * w + h / 2 + 25, y + 6 * h);
    tempCbs.get(11 + id).setPos(x + 3 * w + h + 25, y + 6 * h);
    tempCbs.get(12 + id).setPos(x + 3 * w / 2 + 2 * h + 15, y + 11 * h);
    tempCbs.get(13 + id).setPos(x + 3 * w / 2 + 2.5 * h + 15, y + 11 * h);
    tempCbs.get(14 + id).setPos(x + 3 * w / 2 + 2 * h + 15, y + 11.5 * h);
    tempCbs.get(15 + id).setPos(x + 3 * w / 2 + 2.5 * h + 15, y + 11.5 * h);
    tempCbs.get(16 + id).setPos(x + 3 * w / 2 + 2 * h + 15, y + 12 * h);
    tempCbs.get(17 + id).setPos(x + 3 * w / 2 + 2.5 * h + 15, y + 12 * h);

    toggleCustoms = new boolean[8];
    for (int i = 0; i < toggleCustoms.length; i++) {
      checkBox.CheckBox add = new checkBox.CheckBox(main, x + i * 160, y + 15 * h, w / 4, h / 2, "Add") {
        @Override public void action() {
          if (toggleCustoms[getInt()])
            resetToggleCustoms();
          else {
            resetToggleCustoms();
            toggleCustoms[getInt()] = true;
          }
          for (int i = 0; i < ENV.getCustoms().getPts().size(); i++) ENV.getCustoms().getPts().get(i).setSelected(toggleCustoms[i]);
        }
        @Override public boolean isDone() {
          return toggleCustoms[getInt()];
        }
        @Override public boolean cannotClick() {
          return getInt() >= ENV.getCustoms().getPts().size();
        }
      };
      checkBox.CheckBox rem = new checkBox.CheckBox(main, x + w / 4 + i * 160, y + 15 * h, w / 4, h / 2, "Rem") {
        @Override public void action() {
          ENV.getCustoms().getPts().remove(getInt());
          toggleCustoms[getInt()] = false;
        }
        @Override public boolean cannotClick() {
          return getInt() >= ENV.getCustoms().getPts().size() || anyCustoms();
        }
      };
      tempCbs.add(add.setInt(i));
      tempCbs.add(rem.setInt(i));
    }

    int excess = 18;
    generalCbs = new checkBox.CheckBox[tempCbs.size() + excess];
    for (int i = 0; i < tempCbs.size(); i++)
      generalCbs[i] = tempCbs.get(i);

    id = tempCbs.size();
    generalCbs[id + 0] = drawPathCb;
    generalCbs[id + 1] = trailsCb;
    generalCbs[id + 2] = clearCb;
    generalCbs[id + 3] = addBunchCb;
    generalCbs[id + 4] = addExpRepCb;
    generalCbs[id + 5] = remExpRepCb;
    generalCbs[id + 6] = addExpAtCb;
    generalCbs[id + 7] = remExpAtCb;
    generalCbs[id + 8] = mDensCb;
    generalCbs[id + 9] = cDensCb;
    generalCbs[id + 10] = mergeCb;
    generalCbs[id + 11] = dynBoxCb;
    generalCbs[id + 12] = showOriginCb;
    generalCbs[id + 13] = resetCamCb;
    generalCbs[id + 14] = resetBoundsCb;
    generalCbs[id + 15] = addExpVel;
    generalCbs[id + 16] = remExpVel;
    generalCbs[id + 17] = saveCustomCb;
    for (checkBox.CheckBox cb : generalCbs) cb.setScale(scalingX, scalingY).tweak();
  }
  void toggleGeneral() {
    for (checkBox.CheckBox cb : generalCbs) 
      if (cb.overlaps(mouseX, mouseY) && !cb.cannotClick()) {
        cb.action(); 
        break;
      }
  }
  void showGeneral() {
    push();
    textSize(22);
    text("General options", 250, 30);
    text("Interactions & EFs", 450, 30);
    text("Addition options", 250, 525);
    text("Plot options", 4.75 * w, 12 * h);
    text("Environment & display", 3.25 * w, 7.5 * h);

    fill(ptR, ptG, ptB);
    circle(520, 685, 50);
    textSize(16);
    float mFact = dispFacts[2];
    float cFact = dispFacts[3];
    float lFact = dispFacts[0];

    for (int i = 0; i < ENV.getCustoms().getPts().size(); i++) {
      Particle p = ENV.getCustoms().getPts().get(i);
      float x = 260 + i * 160, y = h + 15.5 * h, sbRev = p.getRadius();
      p.setPos(x, - y).setRadius(10).getVisualizer().show(main, false);

      int h = 12;
      PVector pos = new PVector(p.getPos().x + p.getRadius(), - p.getPos().y - p.getRadius());
      p.setRadius(sbRev);
      fill(p.getColor());
      text("Mass: " + p.getMass() * mFact + " " + dispUnits[2], pos.x, pos.y);
      text("Charge: " + p.getCharge() * cFact + " " + dispUnits[3], pos.x, pos.y + h);
      text("Radius: " + p.getRadius() * lFact + " " + dispUnits[0], pos.x, pos.y + 2 * h);
    }

    fill(255);
    if (expRep == 1)
      text("~ 1 / r", 660, 90);
    else
      text("~ 1 / r^" + expRep, 660, 90);
    if (expAt == 1)
      text("~ 1 / r", 660, 140);
    else
      text("~ 1 / r^" + expAt, 660, 140);
    if (expVel == 1)
      text("~ v", 660, 340);
    else
      text("~ v^" + expVel, 660, 340); 

    int x = 5 * w / 2 + 6 * h + 25, y = 5 * h / 4 + 5;
    for (int i = 0; i < 6; i++)
      text("x 10^" + ctePots[i], x, y + i * h);
    x = 240 + 3 * w / 2 + 50; 
    y = 565;
    for (int i = 6; i < 9; i++)
      text("x 10^" + ctePots[i], x, y + (i - 6) * h / 2);

    x = 250;
    y = h;
    textSize(18);
    for (int i = 0; i < 4; i++)
      text(ENV.getInteractions().get(i).getParticles().size(), x + 3 * w + w / 6 + 5, y + (i + 0.9) * h);
    for (int i = 4; i < 6; i++)
      text(ENV.getExternals().get(i - 4).getParticles().size(), x + 3 * w + w / 6 + 5, y + (i + 0.9) * h);

    pop();
    for (checkBox.CheckBox cb : generalCbs) cb.show();
    plots.drawGeneral();
  }

  void initSoftBody() {

    int x = 250;
    int y = h;

    List<checkBox.CheckBox> tempCbs = new ArrayList<checkBox.CheckBox>();
    valSbPots = new int[7];
    for (int i = 0; i < valSbPots.length - 2; i++) {
      checkBox.CheckBox minus = new checkBox.CheckBox(main, 0, 0, w / 8, h / 2, "-") {
        @Override public void action() {
          valSbPots[getInt()]--;
        }
      };
      checkBox.CheckBox plus = new checkBox.CheckBox(main, 0, 0, w / 8, h / 2, "+") {
        @Override public void action() {
          valSbPots[getInt()]++;
        }
      };
      tempCbs.add(minus.setInt(i));
      tempCbs.add(plus.setInt(i));
    }

    tempCbs.get(0).setPos(x + 3 * w / 2 + 2 * h + 15, 7 * h);
    tempCbs.get(1).setPos(x + 3 * w / 2 + 2.5 * h + 15, 7 * h);
    tempCbs.get(2).setPos(x + 3 * w / 2 + 2 * h + 15, 7.5 * h);
    tempCbs.get(3).setPos(x + 3 * w / 2 + 2.5 * h + 15, 7.5 * h);
    tempCbs.get(4).setPos(x + 3 * w / 2 + 2 * h + 15, 8 * h);
    tempCbs.get(5).setPos(x + 3 * w / 2 + 2.5 * h + 15, 8 * h);
    tempCbs.get(6).setPos(x + 3 * w / 2 + 2 * h + 15, 8.5 * h);
    tempCbs.get(7).setPos(x + 3 * w / 2 + 2.5 * h + 15, 8.5 * h);
    tempCbs.get(8).setPos(x + 3 * w / 2 + .5 * h + 15, 11.5 * h);
    tempCbs.get(9).setPos(x + 3 * w / 2 + h + 15, 11.5 * h);

    valSbPots[5] = 1;
    valSbPots[6] = 1;

    plusWCb = new checkBox.CheckBox(main, x + w / 2 + 4 * h, 9.5 * h, w / 8, h / 2, "+") {
      @Override public void action() {
        valSbPots[5]++;
        initSoftBodyPreview();
      }
    };
    minusWCb = new checkBox.CheckBox(main, x + w / 2 + 3.5 * h, 9.5 * h, w / 8, h / 2, "-") {
      @Override public void action() {
        valSbPots[5]--; 
        initSoftBodyPreview();
      }
      @Override public boolean cannotClick() {
        return valSbPots[5] < 2;
      }
    };
    plusHCb = new checkBox.CheckBox(main, x + w / 2 + 4 * h, 10 * h, w / 8, h / 2, "+") {
      @Override public void action() {
        valSbPots[6]++; 
        initSoftBodyPreview();
      }
    };
    minusHCb = new checkBox.CheckBox(main, x + w / 2 + 3.5 * h, 10 * h, w / 8, h / 2, "-") {
      @Override public void action() {
        valSbPots[6]--; 
        initSoftBodyPreview();
      }
      @Override public boolean cannotClick() {
        return valSbPots[6] < 2;
      }
    };

    addSoftBodyCb = new checkBox.CheckBox(main, x, y, w, h, "Add soft body") {
      @Override public void tweak() {
        setDesc("Toggles soft bodies addition on mouse click.");
      }
      @Override public void action() {
        if (modes[0])
          resetModes();
        else {
          resetModes();
          modes[0] = true;
        }
        indexModes = 1;
      }
      @Override public boolean isDone() {
        return modes[0];
      }
    };
    relFixedCb = new checkBox.CheckBox(main, x, y + h, w, h, "Fixed vertices") {
      @Override public void tweak() {
        setDesc("The soft body will have its vertices fixed (static).");
      }
      @Override public void action() {
        relFixed = !relFixed;
      }
      @Override public boolean isDone() {
        return relFixed;
      }
    };
    attachCb = new checkBox.CheckBox(main, x, y + 2 * h, w, h, "Attach") {
      @Override public void tweak() {
        setDesc("Attach particles with springs. Must have selected at least two particles! HOTKEY: Q");
      }
      @Override public void action() {
        float stf = stiffness * pow(10, valSbPots[0]) / selFacts[2] * pow(selFacts[1], 2);
        for (int i = 0; i < ENV.getSelected().size(); i++) {
          Particle p1 = ENV.getSelected().get(i);
          for (int j = i + 1; j < ENV.getSelected().size(); j++) {
            Particle p2 = ENV.getSelected().get(j);
            ENV.add(new Spring(p1, p2, stf, 0, terms, decay).setDampening(damp * pow(10, valSbPots[4])).setColor(color(sbR, sbG, sbB)));
          }
        }
      }
      @Override public boolean cannotClick() {
        return ENV.getSelected().size() < 2;
      }
    };

    sbMDensCb = new checkBox.CheckBox(main, x + w + 35, y + 6.5 * h, w / 2, h / 2, "Density") {
      @Override public void action() {
        isSbMDens = !isSbMDens;
      }
      @Override public boolean isDone() {
        return isSbMDens;
      }
      @Override public void tweak() {
        textSize = 15;
      }
    };
    sbCDensCb = new checkBox.CheckBox(main, x + w + 35, y + 7 * h, w / 2, h / 2, "Density") {
      @Override public void action() {
        isSbCDens = !isSbCDens;
      }
      @Override public boolean isDone() {
        return isSbCDens;
      }
      @Override public void tweak() {
        textSize = 15;
      }
    };
    previewSbCb = new checkBox.CheckBox(main, x, y + 13.5 * h, w, h, "Show preview") {
      @Override public void tweak() {
        setDesc("Shows an exact copy of the soft body you will be adding to the simulation.");
      }
      @Override public void action() {
        initSoftBodyPreview();
        showPrevSb = !showPrevSb;
      }
      @Override public boolean isDone() {
        return showPrevSb;
      }
    };
    crossJointsCb = new checkBox.CheckBox(main, x, y + 3 * h, w, h, "Crossed joints") {
      @Override public void tweak() {
        setDesc("Enables the particles to have crossed springs attached. Restart the preview to see the efect.");
      }
      @Override public void action() {
        crJoints = !crJoints;
      }
      @Override public boolean isDone() {
        return crJoints;
      }
    };
    autoAdjustEqCb = new checkBox.CheckBox(main, x, y + 4 * h, w, h, "Auto-adjust equilibrium") {
      @Override public void tweak() {
        textSize = 17;
        setDesc("Sets the spring's length according to its initial configuration. Restart the preview to see the efect.");
      }
      @Override public void action() {
        autoAdjustEq = !autoAdjustEq;
      }
      @Override public boolean isDone() {
        return autoAdjustEq;
      }
    };

    sbCp.addSlider("stiffness").setPosition(x, y + 6 * h).setRange(1, 10).setValue(1).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Stiffness").setColorLabel(color(255));
    sbCp.addSlider("mdSb").setPosition(x, y + 6.5 * h).setRange(1, 10).setValue(1).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Mass").setColorLabel(color(255));
    sbCp.addSlider("cdSb").setPosition(x, y + 7 * h).setRange(-10, 10).setValue(1).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Charge").setColorLabel(color(255));
    sbCp.addSlider("rdSb").setPosition(x, y + 7.5 * h).setRange(1, 10).setValue(10).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Radius").setColorLabel(color(255));

    sbCp.addSlider("wdth").setPosition(x, y + 8.5 * h).setRange(2, 10).setValue(10).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Width").setColorLabel(color(255));
    sbCp.addSlider("hght").setPosition(x, y + 9 * h).setRange(1, 10).setValue(1).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Height").setColorLabel(color(255));

    sbCp.addSlider("terms").setPosition(x, y + 9.5 * h).setRange(1, 10).setValue(1).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Terms").setColorLabel(color(255));
    sbCp.addSlider("decay").setPosition(x, y + 10 * h).setRange(1, 10).setValue(6).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Decay").setColorLabel(color(255));
    sbCp.addSlider("damp").setPosition(x, y + 10.5 * h).setRange(0, 10).setValue(0).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Dampening").setColorLabel(color(255));

    sbCp.addSlider("sbR").setPosition(x, y + 12 * h).setRange(0, 255).setValue(255).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 0, 0))
      .setColorActive(color(255, 0, 0, 130)).setColorBackground(color(255, 130)).setLabel("Red").setColorLabel(color(255));
    sbCp.addSlider("sbG").setPosition(x, y + 12.5 * h).setRange(0, 255).setValue(255).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(0, 255, 0))
      .setColorActive(color(0, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Green").setColorLabel(color(255));
    sbCp.addSlider("sbB").setPosition(x, y + 13 * h).setRange(0, 255).setValue(255).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(0, 0, 255))
      .setColorActive(color(0, 0, 255, 130)).setColorBackground(color(255, 130)).setLabel("Blue").setColorLabel(color(255));

    int excess = 12, id = tempCbs.size();
    softBodiesCbs = new checkBox.CheckBox[id + excess];
    for (int i = 0; i < id; i++)
      softBodiesCbs[i] = tempCbs.get(i);

    softBodiesCbs[id + 0] = addSoftBodyCb;
    softBodiesCbs[id + 1] = relFixedCb;
    softBodiesCbs[id + 2] = attachCb;
    softBodiesCbs[id + 3] = sbMDensCb;
    softBodiesCbs[id + 4] = sbCDensCb;
    softBodiesCbs[id + 5] = previewSbCb;
    softBodiesCbs[id + 6] = crossJointsCb;
    softBodiesCbs[id + 7] = autoAdjustEqCb;
    softBodiesCbs[id + 8] = plusWCb;
    softBodiesCbs[id + 9] = minusWCb;
    softBodiesCbs[id + 10] = plusHCb;
    softBodiesCbs[id + 11] = minusHCb;

    for (checkBox.CheckBox cb : softBodiesCbs) cb.setScale(scalingX, scalingY).tweak();
    initSoftBodyPreview();
  }
  void initSoftBodyPreview() {
    softBodyEnv = new Environment(main).setDim(ENV.getDim());
    softBodyEnv.getVisualizer().setTranslate(width / 2, height / 2);
    softBodyEnv.getBoundaries().setConstrainPos(softBodyEnv.transform(width / (2 * scalingX), height / (2 * scalingY)));
    softBodyEnv.getBoundaries().getConstrainDim().x /= scalingX;
    softBodyEnv.getBoundaries().getConstrainDim().y /= scalingY;

    float x1 = 750, x2 = width - 50, y1 = 30 * h / 2, y2 = 5 * h / 2;
    PVector pos1 = softBodyEnv.transform(x1, y1), pos2 = softBodyEnv.transform(x2, y1);
    PVector pos3 = softBodyEnv.transform(x1, y2), pos4 = softBodyEnv.transform(x2, y2);

    previewSb = new SoftBody(main, wdth * valSbPots[5], hght * valSbPots[6], 1, 1, 1, 1);
    previewSb.setVertex("LBD", pos1).setVertex("RBD", pos2);
    if (hght * valSbPots[6] > 1) previewSb.setVertex("LTD", pos3).setVertex("RTD", pos4);
    previewSb.setCrossJoints(crJoints).init().locateAsVertices();

    if (!autoAdjustEq) previewSb.setLength(0);
    softBodyEnv.add(previewSb).removeParticle("controlled");
  }
  void toggleSoftBody() {
    for (checkBox.CheckBox cb : softBodiesCbs)
      if (cb.overlaps(mouseX, mouseY) && !cb.cannotClick())
        cb.action();
  }
  void showSoftBody() {
    push();
    textSize(22);
    text("Soft body options", 250, 30);
    text("Addition options", 250, 30 + 300);
    if (showPrevSb)
      showSoftBodyPreview();

    textSize(20);
    int x = 250, y = 12 * h + 25;
    String force = "F = -kr";
    if (terms == 1)
      text(force, x, y);
    else {
      force += " * [1";
      for (int i = 1; i < terms; i++)
        force += " + r^" + (2 * i) + (decay > 1 ? "/ (" + 2 * i + "^" + decay + ")" : "");
      text(force + "]", x, y);
    }

    textSize(16);
    x = 240 + 3 * w / 2 + 50; 
    y = 365; 
    for (int i = 0; i < valSbPots.length - 3; i++)
      text("x 10^" + valSbPots[i], x, y + i * h / 2);

    text("x 10^" + valSbPots[4], x - 75, y + 9 * h / 2);
    text("x " + valSbPots[5], x - 100, 9.75 * h);
    text("x " + valSbPots[6], x - 100, 10.25 * h);
    pop();
    for (checkBox.CheckBox cb : softBodiesCbs) cb.show();
  }
  void showSoftBodyPreview() {
    textSize(18);
    text("Click on the nodes to move the preview!", 250, 16 * h);
    text("Some changes require to restart the preview", 250, 16 * h + 20);

    if (wdth * valSbPots[5] != previewSb.getWidth() || hght * valSbPots[6] != previewSb.getHeight())
      initSoftBodyPreview();
    if (isSbMDens) previewSb.setMassDens(mdSb * pow(10, valSbPots[1]) * pow(selFacts[0], 3) / selFacts[2]);
    else previewSb.setMass(mdSb * pow(10, valSbPots[1]) / selFacts[2]);
    if (isSbCDens) previewSb.setChargeDens(cdSb * pow(10, valSbPots[2]) * pow(selFacts[0], 3) / selFacts[3]);
    else previewSb.setCharge(cdSb * pow(10, valSbPots[2]) / selFacts[3]);
    if (relFixed) previewSb.fixVertices();
    else previewSb.releaseVertices();
    previewSb.setDampening(damp * pow(10, valSbPots[4]) / selFacts[2] * selFacts[1]);

    previewSb.setTerms(terms).setDecay(decay);
    previewSb.setRadius(rdSb * pow(10, valSbPots[3]) / selFacts[0]).setThickness(rdSb * pow(10, valSbPots[3]) / (5 * selFacts[0]));
    previewSb.setStiffness(stiffness * pow(10, valSbPots[0]) / selFacts[2] * pow(selFacts[1], 2)).setColor(color(sbR, sbG, sbB));
    previewSb.setColor(color(sbR, sbG, sbB));

    softBodyEnv.getIntegrator().setDt(timestep);
    for (int i = 0; i < intPerFrame; i++) {
      softBodyEnv.getIntegrator().forward();
      softBodyEnv.getCollider().runCollisions(elasticity, glide);
      softBodyEnv.getBoundaries().constrain();
    }
    softBodyEnv.getVisualizer().showJoints().show();
  }
  void selectSoftBodyPreview() {
    if (softBodyEnv.getParticle("controlled") != null)
      softBodyEnv.removeParticle("controlled");
    else
      for (Particle p : softBodyEnv.getParticles()) 
        if (p.isWithin(softBodyEnv.transform(mouseX / scalingX, mouseY / scalingY)))
          softBodyEnv.setParticle("controlled", p);
  }
  void controlSoftBodyPreview() {
    if (softBodyEnv.getParticle("controlled") != null) 
      softBodyEnv.getParticle("controlled").setPos(softBodyEnv.transform(mouseX / scalingX, mouseY / scalingY)).setVel(0, 0);
  }

  void initSelected() {

    int x = 250;
    int y = h;
    List<checkBox.CheckBox> tempCbs = new ArrayList<checkBox.CheckBox>();
    plotQts = new boolean[6];
    String[] names = new String[] {"Energy", "Kinetic energy", "Potential energy", "Momentum", "Angular momentum"};
    for (int i = 0; i < plotQts.length - 1; i++) {
      checkBox.CheckBox cb = new checkBox.CheckBox(main, x + 2 * w, y + i * h, w, h, names[i]) {
        @Override public void action() {
          if (hist)
            if (!plotQts[getInt()]) {
              resetPlotQts();
              plotQts[getInt()] = true;
            } else
              resetPlotQts();
          else
            plotQts[getInt()] = !plotQts[getInt()];
        }
        @Override public boolean isDone() {
          return plotQts[getInt()];
        }
        @Override public boolean cannotClick() {
          return plots.records.isEmpty() || XY;
        }
      };
      tempCbs.add(cb.setInt(i));
    }

    tempCbs.get(0).setDesc("Plots the energy of the particles whose data is being collected.");
    tempCbs.get(1).setDesc("Plots the kinetic energy of the particles whose data is being collected.");
    tempCbs.get(2).setDesc("Plots the potential energy of the particles whose data is being collected.");
    tempCbs.get(3).setDesc("Plots the momentum of the particles whose data is being collected.");
    tempCbs.get(4).setDesc("Plots the angular momentum of the particles whose data is being collected.");

    plotDistCb = new checkBox.CheckBox(main, x + 2 * w, y + 5 * h, w / 2, h, "Distance") {
      @Override public void tweak() {
        setDesc("Plots the distance between two particles/origin.");
      }
      @Override public void action() {
        plotQts[5] = !plotQts[5];
      }
      @Override public boolean isDone() {
        return plotQts[5];
      }
      @Override public boolean cannotClick() {
        return (plots.records.isEmpty() || ENV.getGroup("quantities").size() > 2 || hist || XY) && !plotQts[5];
      }
    };
    plotXYCb = new checkBox.CheckBox(main, x + 2.5 * w, y + 5 * h, w / 2, h, "XY") {
      @Override public void tweak() {
        setDesc("Plots the x & y coordinates of a particle.");
      }
      @Override public void action() {
        if (!XY)
          resetPlotQts();
        XY = !XY;
      }
      @Override public boolean isDone() {
        return XY;
      }
      @Override public boolean cannotClick() {
        return (plots.records.isEmpty() || ENV.getGroup("quantities").size() != 1 || hist) && !XY;
      }
    };
    collectDataCb = new checkBox.CheckBox(main, x + 2 * w, y + 6 * h, w, h, "Collect data(G)") {
      @Override public void tweak() {
        setDesc("Collects the data of the particles and makes it available to plot.");
      }
      @Override public void action() {
        groupRoutine("quantities");
        if (!isPressingControl())
          qtsOnAddition = !qtsOnAddition;
      }
      @Override public boolean isDone() {
        return qtsOnAddition;
      }
      @Override public boolean hasToClick() {
        return !ENV.getGroup("quantities").isEmpty() && !isDone();
      }
    };
    histCb = new checkBox.CheckBox(main, x + 2 * w, y + 7 * h, w, h, "Distribution") {
      @Override public void tweak() {
        setDesc("Changes plot type to a distribution plot. Only one type of data will be plotted at once.");
      }
      @Override public void action() {
        if (!hist)
          resetPlotQts();
        hist = !hist;
      }
      @Override public boolean isDone() {
        return hist;
      }
    };
    clearMemCb = new checkBox.CheckBox(main, 1020 + w, 555, w / 4, h / 2, "Clear") {
      @Override public void action() {
        plots.records.clear();
        if (!collectDataCb.isDone() && !collectDataCb.hasToClick())
          resetPlotQts();
      }
      @Override public void tweak() {
        textSize = 15;
      }
      @Override public boolean isDone() {
        return plots.records.isEmpty();
      }
      @Override public boolean hasToClick() {
        return plots.records.size() == plotMemory;
      }
    };
    selCp.addSlider("plotMemory").setPosition(950, 555).setRange(100, 10000).setValue(1000).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Data memory").setColorLabel(color(255));
    selCp.addSlider("batches").setPosition(950, 555 + h / 2).setRange(10, 100).setValue(10).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Batches").setColorLabel(color(255));

    selCb = new checkBox.CheckBox(main, x, y, w, h, "Select") {
      @Override public void tweak() {
        setDesc("Toggles selection of particles on mouse click. Click and drag to create a selection rectangle.");
      }
      @Override public void action() {
        if (modes[1])
          resetModes();
        else {
          resetModes();
          modes[1] = true;
        }
        indexModes = 2;
      }
      @Override public boolean isDone() {
        return modes[1];
      }
    };
    selAllCb = new checkBox.CheckBox(main, x, y + h, w, h, "Select all") {
      @Override public void tweak() {
        setDesc("Selects all particles.");
      }
      @Override public void action() {
        ENV.select(ENV.getParticles());
        if (isControlling()) stopControlling(true);
      }
      @Override public boolean isDone() {
        for (Particle p : ENV.getParticles())
          if (!p.isSelected())
            return false;
        return true;
      }
      @Override public boolean cannotClick() {
        return ENV.isEmpty();
      }
    };
    deSelAllCb = new checkBox.CheckBox(main, x, y + 2 * h, w, h, "Deselect all") {
      @Override public void tweak() {
        setDesc("Deselects all particles.");
      }
      @Override public void action() {
        ENV.clearSelected();
        if (isControlling()) stopControlling(true);
      }
      @Override public boolean isDone() {
        for (Particle p : ENV.getParticles())
          if (p.isSelected())
            return false;
        return true;
      }
      @Override public boolean cannotClick() {
        return ENV.isEmpty();
      }
    };
    removeCb = new checkBox.CheckBox(main, x, y + 3 * h, w, h, "Remove") {
      @Override public void tweak() {
        setDesc("Removes selected particles. HOTKEY: R");
      }
      @Override public void action() {
        if (isControlling()) stopControlling(true);
        ENV.remove(ENV.getSelected());
      }
      @Override public boolean cannotClick() {
        return ENV.getSelected().isEmpty();
      }
    };
    controlCb = new checkBox.CheckBox(main, x, y + 4 * h, w, h, "Control") {
      @Override public void tweak() {
        setDesc("Sets a particle to be controlled. Press shift on the sim screen to control it. Drag to launch. HOTKEY: C");
      }
      @Override public void action() {
        if (isControlling())
          stopControlling(wasDynamic);
        else {
          resetModes();
          Particle p = ENV.getSelected().get(0);
          wasDynamic = p.isDynamic();
          ENV.setParticle("controlled", p.setDynamic(false));
        }
      }
      @Override public boolean isDone() {
        return isControlling();
      }
      @Override public boolean cannotClick() {
        return (ENV.getSelected().size() != 1 && !isControlling()) || (isFollowingCM() && pause);
      }
    };
    fixCb = new checkBox.CheckBox(main, x, y + 5 * h, w, h, "Toggle static") {
      @Override public void tweak() {
        setDesc("Sets selected particle to dynamic if they were static and viceversa. HOTKEY: E");
      }
      @Override public void action() {
        for (Particle p : ENV.getSelected())
          p.setDynamic(!p.isDynamic());
      }
      @Override public boolean cannotClick() {
        return ENV.getSelected().isEmpty();
      }
    };
    warpCb = new checkBox.CheckBox(main, x, y + 6 * h, w, h, "Warp to particle") {
      @Override public void tweak() {
        setDesc("Adjusts camera placement and zoom to focus on a particle's current position. Does not follow.");
      }
      @Override public void action() {
        resetCamCb.action();
        Particle p = ENV.getSelected().get(0);
        ENV.getBoundaries().getConstrainPos().sub(p.getPos());
        ENV.moveOrigin(p.getPos().copy());
        float r = 10;
        ENV.getVisualizer().setScaling(r / p.getRadius());
      }
      @Override public boolean cannotClick() {
        return ENV.getSelected().size() != 1;
      }
    };
    showDataCb = new checkBox.CheckBox(main, x, y + 7 * h, w, h, "Show data(G)") {
      @Override public void tweak() {
        setDesc("Shows the data of particles on screen: Mass, charge, velocity and energy");
      }
      @Override public void action() {
        groupRoutine("showData");
        if (!isPressingControl())
          showDataOnAddition = !showDataOnAddition;
      }
      @Override public boolean isDone() {
        return showDataOnAddition;
      }
      @Override public boolean hasToClick() {
        return !ENV.getGroup("showData").isEmpty() && !isDone();
      }
    };
    showDistCb = new checkBox.CheckBox(main, x, y + 8 * h, w, h, "Show distance(G)") {
      @Override public void tweak() {
        setDesc("Shows distance between other particles. Useless when having less than two particles.");
      }
      @Override public void action() {
        groupRoutine("showDist");
        if (!isPressingControl())
          showDistOnAddition = !showDistOnAddition;
      }
      @Override public boolean isDone() {
        return showDistOnAddition;
      }
      @Override public boolean hasToClick() {
        return !ENV.getGroup("showDist").isEmpty() && !isDone();
      }
    };
    previewCb = new checkBox.CheckBox(main, x, y + 10 * h, w, h, "Show particles") {
      @Override public void tweak() {
        setDesc("Shows the current particles on the simulation sorted, where they can be selected and removed.");
      }
      @Override public void action() {
        showPrev = !showPrev;
      }
      @Override public boolean isDone() {
        return showPrev;
      }
    };

    setMCb = new checkBox.CheckBox(main, x + w, y, w, h, "Set mass") {
      @Override public void tweak() {
        setDesc("Sets the mass of the selected particles to the current value in 'General'.");
      }
      @Override public void action() {
        for (Particle p : ENV.getSelected())
          if (isMDens) p.setMassDens(md * pow(10, ctePots[6]) * pow(selFacts[0], 3) / selFacts[2]);
          else p.setMass(md * pow(10, ctePots[6]) / selFacts[2]);
      }
      @Override public boolean cannotClick() {
        return ENV.getSelected().isEmpty();
      }
    };
    setCCb = new checkBox.CheckBox(main, x + w, y + h, w, h, "Set charge") {
      @Override public void tweak() {
        setDesc("Sets the charge of the selected particles to the current value in 'General'.");
      }
      @Override public void action() {
        for (Particle p : ENV.getSelected())
          if (isCDens) p.setChargeDens(cd * pow(10, ctePots[7]) * pow(selFacts[0], 3) / selFacts[3]);
          else p.setCharge(cd * pow(10, ctePots[7]) / selFacts[3]);
      }
      @Override public boolean cannotClick() {
        return ENV.getSelected().isEmpty();
      }
    };
    setRCb = new checkBox.CheckBox(main, x + w, y + 2 * h, w, h, "Set radius") {
      @Override public void tweak() {
        setDesc("Sets the radius of the selected particles to the current value in 'General'.");
      }
      @Override public void action() {
        for (Particle p : ENV.getSelected())
          p.setRadius(rd * pow(10, ctePots[8]) / selFacts[0]);
      }
      @Override public boolean cannotClick() {
        return ENV.getSelected().isEmpty();
      }
    };
    CMCb = new checkBox.CheckBox(main, x + w, y + 3 * h, w, h, "Follow CM(G)") {
      @Override public void tweak() {
        setDesc("Changes the frame of reference to the center of mass of the particles.");
      }
      @Override public void action() {
        groupRoutine("focus");
        if (!isPressingControl())
          followCMOnAddition = !followCMOnAddition;
        ENV.getVisualizer().setTranslate(width / 2, height / 2);
        if (isControlling() && isFollowingCM()) stopControlling(true);
      }
      @Override public boolean isDone() {
        return followCMOnAddition;
      }
      @Override public boolean hasToClick() {
        return !ENV.getGroup("focus").isEmpty() && !isDone();
      }
    };
    vecFCb = new checkBox.CheckBox(main, x + w, y + 5 * h, w, h, "Force field(G)") {
      @Override public void tweak() {
        setDesc("Displays the force field created by particles. Only works for interactions.");
      }
      @Override public void action() {
        groupRoutine("accelField");
        if (!isPressingControl())
          drawAFOnAddition = !drawAFOnAddition;
      }
      @Override public boolean isDone() {
        return drawAFOnAddition;
      }
      @Override public boolean hasToClick() {
        return !ENV.getGroup("accelField").isEmpty() && !isDone();
      }
    };
    contLCb = new checkBox.CheckBox(main, x + w, y + 6 * h, w, h, "Contour lines(G)") {
      @Override public void tweak() {
        setDesc("Displays the equipotential curves created by particles. Only works for interactions.");
      }
      @Override public void action() {
        groupRoutine("contLines");
        if (!isPressingControl())
          drawCLOnAddition = !drawCLOnAddition;
      }
      @Override public boolean isDone() {
        return drawCLOnAddition;
      }
      @Override public boolean hasToClick() {
        return !ENV.getGroup("contLines").isEmpty() && !isDone();
      }
    };
    relativizeCb = new checkBox.CheckBox(main, x + w, y + 7 * h, w, h, "Relativize") {
      @Override public void tweak() {
        setDesc("Relativize the magnitudes of the force field to adapt to the screen size.");
      }
      @Override public void action() {
        PVector[][] field = Physics.getAccelField2D(ENV.getGroup("accelField"), ENV.getBoundaries(), vecDetail);
        float[][] mag = new float[vecDetail][vecDetail];
        for (int i = 0; i < vecDetail; i++)
          for (int j = 0; j < vecDetail; j++)
            mag[i][j] = field[i][j].mag();
        tensors.Float.Matrix mat = new tensors.Float.Matrix(mag);
        accelMin = mat.min();
        accelMax = mat.max();
      }
      @Override public boolean cannotClick() {
        return ENV.getGroup("accelField").isEmpty();
      }
    };

    selCp.addSlider("vecDetail").setPosition(x + w, y + 8 * h).setRange(10, 100).setValue(10).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Force field detail").setColorLabel(color(255));
    selCp.addSlider("contDetail").setPosition(x + w, y + 8.5 * h).setRange(10, 100).setValue(10).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Contour lines detail").setColorLabel(color(255));
    selCp.addSlider("contVals").setPosition(x + w, y + 9 * h).setRange(10, 100).setValue(10).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Contour values").setColorLabel(color(255));
    selCp.addSlider("minEdge").setPosition(x + w, y + 9.5 * h).setRange(-5, 5).setValue(0).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Contour min edge").setColorLabel(color(255));
    selCp.addSlider("maxEdge").setPosition(x + w, y + 10 * h).setRange(-5, 5).setValue(0).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Contour max edge").setColorLabel(color(255));

    selectedCbs = new checkBox.CheckBox[] {selCb, selAllCb, deSelAllCb, removeCb, controlCb, fixCb, warpCb, showDataCb, 
      showDistCb, setMCb, setCCb, setRCb, CMCb, vecFCb, contLCb, previewCb, tempCbs.get(0), tempCbs.get(1), tempCbs.get(2), 
      tempCbs.get(3), tempCbs.get(4), collectDataCb, histCb, plotDistCb, clearMemCb, plotXYCb, relativizeCb};
    for (checkBox.CheckBox cb : selectedCbs) cb.setScale(scalingX, scalingY).tweak();
  }
  void toggleSelected() {
    for (checkBox.CheckBox cb : selectedCbs)
      if (cb.overlaps(mouseX, mouseY) && !cb.cannotClick())
        cb.action();
  }
  void showSelected() {
    push();
    textSize(22);
    text("Particle options", 250, 30);
    text("Field options", 480, 5.5 * h);
    text("Plot options", 650, 30);
    text("Preview options", 250, 10.5 * h);
    if (showPrev)
      showSelectedPreview();
    pop();
    for (checkBox.CheckBox cb : selectedCbs) cb.show();
    plots.drawSelected();
  }
  void showSelectedPreview() {
    int r = 10, mX = round(width / scalingX) - r, mY = round(height / scalingY) - r, xi = 250, yi = 25 * h / 2;
    ENV.saveConfig();
    ENV.getVisualizer().setScaling(1).setTranslate(width / 2, height / 2);

    List<Particle> toShow = new ArrayList<Particle>();
    int i = 0;
    previewPos.clear();
    for (int x = xi; x < mX; x += 16 * r)
      if (i >= ENV.getParticles().size()) break;
      else
        for (int y = yi; y < mY; y += 8 * r)
          if (i < ENV.getParticles().size()) {
            previewPos.add(new PVector(x, y));
            Particle p = ENV.getParticles().get(ENV.getParticles().size() - 1 - i++);
            toShow.add(p);
          } else
            break;
    float[] energies = new float[toShow.size()], radius = new float[toShow.size()];
    for (i = 0; i < toShow.size(); i++) {
      Particle p = toShow.get(i);
      radius[i] = p.getRadius();
      if (isFollowingCM()) energies[i] = p.getRelEnergy(ENV.getGroup("focus"));
      else energies[i] = p.getEnergy();
    }
    
    for (i = 0; i < toShow.size(); i++) toShow.get(i).setPos(ENV.transform(previewPos.get(i))).setRadiusRaw(r).getVisualizer().show(main, false);
    showData(main, toShow, energies);
    
    for (i = 0; i < toShow.size(); i++) toShow.get(i).setRadiusRaw(radius[i]);
    ENV.loadConfig();
  }
  void selectInPreview() {
    ENV.saveConfig();
    ENV.getVisualizer().setScaling(1).setTranslate(width / 2, height / 2);
    for (int i = 0; i < previewPos.size(); i++) {
      previewPos.get(i).x *= scalingX;
      previewPos.get(i).y *= scalingY;
      if (isMouseWithin(ENV.transform(previewPos.get(i)), 10)) {
        ENV.switchSelect(ENV.getParticles().get(max(previewPos.size(), ENV.getParticles().size()) - 1 - i));
        break;
      }
    }
    ENV.loadConfig();
  }

  void initIntegration() {
    int x = 250;
    int y = h;

    List<checkBox.CheckBox> tempCbs = new ArrayList<checkBox.CheckBox>();
    metList = ENV.getIntegrator().getMethodList();
    for (int i = 0; i < metList.length; i++) {
      checkBox.CheckBox cb = new checkBox.CheckBox(main, x, y + i * h, w, h, metList[i].toString()) {
        @Override public void action() {
          ENV.getIntegrator().setMethod(metList[getInt()]);
          softBodyEnv.getIntegrator().setMethod(metList[getInt()]);
        }
        @Override public boolean isDone() {
          return ENV.getIntegrator().getMethod() == metList[getInt()];
        }
      };
      tempCbs.add(cb.setInt(i));
    }
    int len = tempCbs.size();

    tempCbs.get(0).setDesc("Integrates solution with EULER method. Very inaccurate.");
    tempCbs.get(1).setDesc("Integrates solution with RK4 method. Accurate and efficient.");
    tempCbs.get(2).setDesc("Integrates solution with RK6 method. Very accurate, not that efficient.");
    tempCbs.get(3).setDesc("Integrates solution with RKF45 method. Very accurate, not that efficient. Can display error.");
    tempCbs.get(4).setDesc("Integrates solution with CK45 method. Very accurate, not that efficient. Can display error.");
    tempCbs.get(5).setDesc("Integrates solution with DOPRI45 method. Very accurate, not that efficient. Can display error.");

    pauseCb = new checkBox.CheckBox(main, x, y + ++len * h, w, h, "Pause") {
      @Override public void tweak() {
        setDesc("Pauses the simulation. HOTKEY: SPACEBAR.");
      }
      @Override public void action() {
        pause = !pause;
      }
      @Override public boolean isDone() {
        return pause;
      }
    };
    resetTimeCb = new checkBox.CheckBox(main, x, y + (++len + 3) * h, w, h, "Reset counters") {
      @Override public void tweak() {
        setDesc("Resets all counters. It is recommended to do it frecuently.");
      }
      @Override public void action() {
        runTimingCb.setInt(runTimingCb.getInt() - timesteps);
        time = 0;
        frames = 0;
        timesteps = 0;
        ENV.getIntegrator().resetError();
      }
    };
    reverseCb = new checkBox.CheckBox(main, x, y + (++len + 3) * h, w, h, "Reverse time") {
      @Override public void tweak() {
        setDesc("Reverses time: Backwards integration! You will go back in time.");
      }
      @Override public void action() {
        forward = !forward;
      }
      @Override public boolean isDone() {
        return !forward;
      }
    };
    runTimingCb = new checkBox.CheckBox(main, 800, y, w, h, "Enable timing") {
      @Override public void tweak() {
        setDesc("Sets a timer to control how many timesteps will pass until 'Run' gets disabled.");
      }
      @Override public void action() {
        isRunTiming = !isRunTiming;
        if (isRunTiming)
          setInt(runTimingCounter + timesteps);
      }
      @Override public boolean isDone() {
        if (isRunTiming && run && getInt() <= timesteps) {
          isRunTiming = false;
          runToggle.action();
        } else if (!run)
          setInt(runTimingCounter + timesteps);
        return isRunTiming;
      }
    };
    interPPCb = new checkBox.CheckBox(main, x, y + (++len + 3) * h, w, h, "Interpolate P-P collisions") {
      @Override public void action() {
        interpolPP = !interpolPP;
      }
      @Override public void tweak() {
        textSize = 17;
        setDesc("Interpolates collisions between particles in an attempt to deliver a more accurate result.");
      }
      @Override public boolean isDone() {
        return interpolPP;
      }
    };
    interBCb = new checkBox.CheckBox(main, x, y + (++len + 3) * h, w, h, "Interpolate boundary collisions") {
      @Override public void action() {
        interpolB = !interpolB;
      }
      @Override public void tweak() {
        textSize = 17;
        setDesc("Interpolates collisions on boundaries in an attempt to deliver a more accurate result.");
      }
      @Override public boolean isDone() {
        return interpolB;
      }
    };
    adaptToFramerateCb = new checkBox.CheckBox(main, 1150, 150, w, h, "Adapt timestep to framerate") {
      @Override public void tweak() {
        textSize = 17; 
        setDesc("Adapts the timestep to match the time elapsed between frames, so the elapsed time matches the real time.");
      }
      @Override public void action() {
        adaptToFramerate = !adaptToFramerate;
      }
      @Override public boolean isDone() {
        return adaptToFramerate;
      }
    };

    isPlaying = new boolean[ENV.getIsRec().length];
    for (int i = 0; i < ENV.getRecCount(); i++) {
      String name = "Record " + (i + 1);
      int xc = 800;
      checkBox.CheckBox record = new checkBox.CheckBox(main, xc, y + (3 + i / 2.0) * h, w / 2, h / 2, name) {
        @Override public void action() {
          if (ENV.getIsRec()[getInt()])
            ENV.stopRecording();
          else {
            ENV.stopRecording();
            ENV.startRecording(getInt());
          }
        }
        @Override public boolean isDone() {
          return ENV.getIsRec()[getInt()];
        }
        @Override public boolean cannotClick() {
          return ENV.isEmpty() || ENV.getCollider().getCollisionMode() == Collider.COLLISIONMODE.MERGE;
        }
        @Override public boolean hasToClick() {
          return !isDone() && ENV.hasRecording(getInt()) && ENV.getFrameCount(getInt()) > 0;
        }
      };
      checkBox.CheckBox play = new checkBox.CheckBox(main, xc + w / 2, y + (3 + i / 2.0) * h, w / 2, h / 2, "Play") {
        @Override public void action() {
          isPlaying[getInt()] = true;

          movieSpeed = 1;
          movieFrame = 0;

          reversedMovie = false;
          pausedMovie = false;

          intCp.hide();
          movieCp.show();

          PVector trans = ENV.getRecordings().getTranslates().get(Integer.toString(getInt()));
          float sc = ENV.getRecordings().getScales().get(Integer.toString(getInt()));
          movieEnv.clear().clearSelected().getVisualizer().setTranslate(trans.copy()).setScaling(sc);
          prevLenUnit = ENV.getRecordings().getStartingUnits(getInt())[0];
          for (Particle p : ENV.getRecordings().getActors().get(Integer.toString(getInt())))
            movieEnv.add(p.blindCopy());

          exitMovieCb.setInt(getInt());
          saveMousePos(movieEnv);
        }
        @Override public boolean cannotClick() {
          return !ENV.hasRecording(getInt()) || ENV.isRecordingEmpty(getInt());
        }
      };
      checkBox.CheckBox rem = new checkBox.CheckBox(main, xc + w, y + (3 + i / 2.0) * h, w / 2, h / 2, "Delete") {
        @Override public void action() {
          if (getInt() == ENV.indexRec()) ENV.stopRecording();
          ENV.removeRecording(getInt());
        }
        @Override public boolean cannotClick() {
          return !ENV.hasRecording(getInt());
        }
      };
      tempCbs.add(record.setInt(i));
      tempCbs.add(play.setInt(i));
      tempCbs.add(rem.setInt(i));
    }
    tempCbs.add(pauseCb);
    tempCbs.add(resetTimeCb);
    tempCbs.add(reverseCb);
    tempCbs.add(runTimingCb);
    tempCbs.add(interPPCb);
    tempCbs.add(interBCb);
    tempCbs.add(adaptToFramerateCb);

    intCp.addSlider("runTimingCounter").setPosition(800, y + h).setRange(100, 10000).setValue(100).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0)).setColorValueLabel(color(0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Timesteps to run").setColorLabel(color(255));

    intCp.addSlider("dtExp").setPosition(x + w, y).setRange(-10, 0).setValue(-2).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0)).setDecimalPrecision(4).setColorValueLabel(color(0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Timestep exponent").setColorLabel(color(255));
    intCp.addSlider("dpDtExp").setPosition(x + w, y + h).setRange(-10, 0).setValue(-2).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0)).setDecimalPrecision(4).setColorValueLabel(color(0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Draw path timestep exponent").setColorLabel(color(255));
    intCp.addSlider("dpLen").setPosition(x + w, y + 2 * h).setRange(1, 100).setValue(10).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Draw path length").setColorLabel(color(255));
    intCp.addSlider("mVel").setPosition(x + w, y + 3 * h).setRange(0.1, 100).setValue(1).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Mouse vel multiplier").setColorLabel(color(255));
    intCp.addSlider("intPerFrame").setPosition(x + w, y + 4 * h).setRange(1, 100).setValue(1).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Integrations per timestep").setColorLabel(color(255));
    intCp.addSlider("elasticity").setPosition(x + w, y + 5 * h).setRange(0, 1).setValue(1).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Elasticity of collisions").setColorLabel(color(255));
    intCp.addSlider("glide").setPosition(x + w, y + 6 * h).setRange(0, 1).setValue(1).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Glide of collisions").setColorLabel(color(255));

    int id = tempCbs.size();
    integCbs = new checkBox.CheckBox[id];
    for (int i = 0; i < id; i++)
      integCbs[i] = tempCbs.get(i);
    for (checkBox.CheckBox cb : integCbs) cb.setScale(scalingX, scalingY).tweak();
  }
  void toggleIntegration() {
    for (checkBox.CheckBox cb : integCbs)
      if (cb.overlaps(mouseX, mouseY) && !cb.cannotClick())
        cb.action();
  }
  void showIntegration() {
    push();
    String frameText = frameRate > 1 ? "FPS: " + round(frameRate) : "SPF: " + (round(1 / frameRate));
    text(frameText, (width - textWidth(frameText)) / scalingX, 25);
    textSize(22);
    text("Method selection", 250, 30);
    text("Integration options", 450, 30);
    text("'Run' timing options", 800, 30);
    text("Recording options", 800, 30 + 2.5 * h);
    text("Elapsed time: " + time * dispFacts[1] + " " + dispUnits[1], 250, 9.5 * h);
    text("Timesteps: " + timesteps, 250, 10 * h);
    text("Frames: " + frames, 250, 10.5 * h);
    text("Integration error: " + (ENV.getIntegrator().hasError() ? ENV.getIntegrator().getError() : "Unknown"), 250, 11 * h);
    text("Cumulative integration error: " + (ENV.getIntegrator().hasError() ?  ENV.getIntegrator().getCumulativeError() : "Unknown"), 250, 11.5 * h);
    textSize(15);
    for (int i = 0; i < 12; i++)
      if (ENV.hasRecording(i) && !ENV.isRecordingEmpty(i)) {
        float x = 810 + 3 * w / 2.0, y = (4.25 + i / 2.0) * h;
        text("Frames recorded: " + ENV.getFrameCount(i), x, y);
      }
    if (ENV.getCollider().getCollisionMode() == Collider.COLLISIONMODE.MERGE) text("Cannot record with merge collisions on", 800, 10.25 * h);
    textSize(20);
    text("Current timestep: " + timestep, 1150, 30);
    text("Integrations per frame: " + intPerFrame, 1150, 60);
    text("Apparent speed of simulation: " + timestep * frameRate * intPerFrame, 1150, 90);
    textSize(15);
    text("Tells you at which rate time passes in the simulation with respect real time.", 1150, 100, 450, 100);
    textSize(20);

    int wt = 750, ht = 1000;
    text("Each frame, time advances a number of timesteps depending on the number of integrations per frame. This number " + 
      "determines how many integrations are performed by frame. This allows you to increase the accuracy without " + 
      "decreasing the apparent speed at which things occur, at the cost of performance. The apparent speed considers this factor " + 
      "and the timestep to determine at which speed the simulation seems to be running.", 800, 11 * h, wt, ht);
    text("Press UP & DOWN to change the timestep and LEFT & RIGHT to change the integrations per frame.", 800, 15 * h, wt, ht);

    pop();
    for (checkBox.CheckBox cb : integCbs) cb.show();
  }
  void initMovie() {
    int x = width - w;
    int y = height - h;

    movieEnv = new Environment(main).setDim(Environment.DIMENSION.TWO);
    movieEnv.getVisualizer().setTranslate(width / 2, height / 2).setScaling((float) width / width);
    movieEnv.getBoundaries().setConstrainDim(width, height);

    exitMovieCb = new checkBox.CheckBox(main, x, y, w, h, "Exit") {
      @Override public void tweak() {
        setDesc("Exits the movie.");
      }
      @Override public void action() {
        isPlaying[getInt()] = false;
        intCp.show();
        movieCp.hide();
      }
    };
    pauseMovieCb = new checkBox.CheckBox(main, x - w, y, w, h, "Pause") {
      @Override public void tweak() {
        setDesc("Pauses the movie.");
      }
      @Override public void action() {
        pausedMovie = !pausedMovie;
      }
      @Override public boolean isDone() {
        return pausedMovie;
      }
    };
    reverseMovieCb = new checkBox.CheckBox(main, x - 2 * w, y, w, h, "Reverse") {
      @Override public void tweak() {
        setDesc("Reverses the movie.");
      }
      @Override public void action() {
        reversedMovie = !reversedMovie;
      }
      @Override public boolean isDone() {
        return reversedMovie;
      }
    };
    trailMovieCb = new checkBox.CheckBox(main, x - 3 * w, y, w, h, "Trails") {
      @Override public void tweak() {
        setDesc("Enables trails to the selected particles.");
      }
      @Override public void action() {
        List<Particle> pts = movieEnv.getSelected().isEmpty() ? movieEnv.getParticles() : movieEnv.getSelected();
        for (Particle p : pts)
          if (p.getVisualizer().hasTrail()) p.getVisualizer().noTrail();
          else p.getVisualizer().trail();
      }
    };

    movieCp.addSlider("movieSpeed").setPosition((width - w) / scalingX, (height - 3 * h / 2) / scalingY).setRange(1, 100).setValue(1).setSize(w, h / 2)
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("").setColorLabel(color(255));

    movieCbs = new checkBox.CheckBox[] {exitMovieCb, pauseMovieCb, reverseMovieCb, trailMovieCb};
    for (checkBox.CheckBox cb : movieCbs) cb.tweak();
  }
  void toggleMovie() {
    saveMousePos(movieEnv);
    for (checkBox.CheckBox cb : movieCbs)
      if (cb.overlaps(mouseX, mouseY) && !cb.cannotClick())
        cb.action();
  }
  void showMovie() {
    if (mousePressed && !isPressingShift()) drawSelRectAndCheck(movieEnv, isPressingControl());

    int index = indexPlaying();
    int totalFrames = movieEnv.getParticles().get(0).getRecord().getPositions().size();
    if (movieFrame >= totalFrames) {
      movieFrame = 0;
      prevLenUnit = ENV.getRecordings().getStartingUnits(index)[0];
      movieEnv.getVisualizer().deleteTrails();
    } else if (movieFrame < 0) {
      movieFrame = totalFrames - 1;
      movieEnv.getVisualizer().deleteTrails();
    }

    for (Particle p : movieEnv.getParticles())
      p.setPos(p.getRecord().getPositions().get(movieFrame));

    push();
    translate(movieEnv.getVisualizer().getTranslate().x, movieEnv.getVisualizer().getTranslate().y);
    scale(movieEnv.getVisualizer().getScaling(), - movieEnv.getVisualizer().getScaling());

    Map<Integer, String[]> units = ENV.getRecordings().getUnitTracker().get(Integer.toString(index));
    Map<int[], Integer> att = ENV.getRecordings().getAttachments().get(Integer.toString(index));

    String[] currentUnits = ENV.getRecordings().getStartingUnits(index);

    List<Integer> unitsKSet = new ArrayList<Integer>(units.keySet());
    for (int i = unitsKSet.size() - 1; i >= 0; i--) {
      Integer frame = unitsKSet.get(i);
      if (movieFrame >= frame) {
        currentUnits = units.get(frame);

        if (!prevLenUnit.equals(currentUnits[0])) {
          float fact = Units.getLengthFactor(prevLenUnit, currentUnits[0]);
          prevLenUnit = currentUnits[0];
          for (Particle p : movieEnv.getParticles()) p.setRadius(p.getRadius() * fact);
        }
        break;
      }
    }

    strokeWeight(2);    
    for (int[] i : att.keySet()) {
      Particle p1 = movieEnv.getParticles().get(i[0]), p2 = movieEnv.getParticles().get(att.get(i));
      stroke(p1.getColor());
      line(p1.getPos().x, p1.getPos().y, p2.getPos().x, p2.getPos().y);
    }
    pop();

    float mFact = dispFacts[2], cFact = dispFacts[3];
    float vFact = Units.getVelFactor(currentUnits[0], currentUnits[1], dispUnits[4], dispUnits[5]);
    float eFact = Units.getEnergyFactor(currentUnits[0], currentUnits[1], "kg", "m", "s", "kg") / energyUnits.get(dispUnits[6]);
    String vUnit = dispUnits[4] + "/" + dispUnits[5];
    String eUnit = dispUnits[6];

    push();
    textSize(12);
    for (Particle p : movieEnv.getSelected()) {
      fill(p.getColor());
      int h = 12;
      PVector pPos = p.getRecord().getPositions().get(movieFrame);
      PVector pos = movieEnv.invTransform(pPos.x + p.getRadius(), pPos.y + p.getRadius()), vel = p.getRecord().getVelocities().get(movieFrame);
      text("Mass: " + p.getMass() * mFact + " " + dispUnits[2], pos.x, pos.y);
      text("Charge: " + p.getCharge() * cFact + " " + dispUnits[3], pos.x, pos.y + h);
      text("Vx: " + vel.x * vFact + " " + vUnit, pos.x, pos.y + 2 * h);
      text("Vy: " + vel.y * vFact + " " + vUnit, pos.x, pos.y + 3 * h);
      text("Energy: " + p.getRecord().getEnergies().get(movieFrame) * eFact + " " + eUnit, pos.x, pos.y + 4 * h);
    }
    pop();

    movieEnv.getVisualizer().show();
    if (drawLimits()) movieEnv.getBoundaries().show();

    text("Frame: " + movieFrame + "/" + totalFrames, 5, 25);

    String frames = frameRate > 1 ? "FPS: " + round(frameRate) : "SPF: " + (round(1 / frameRate));
    text(frames, width - textWidth(frames), 25);

    if (!pausedMovie)
      if (reversedMovie) movieFrame -= movieSpeed;
      else movieFrame += movieSpeed;

    for (checkBox.CheckBox cb : movieCbs) cb.show();
  }

  void initShapes() {
    int x = 250;
    int y = h;

    List<checkBox.CheckBox> tempCbs = new ArrayList<checkBox.CheckBox>();
    shapesPrev = new boolean[3];
    for (int i = 0; i < shapesPrev.length; i++) {
      checkBox.CheckBox cb = new checkBox.CheckBox(main, x + w, y + i * h, w, h, "Preview shape") {
        @Override public void tweak() {
          setDesc("Shows a small preview of the shape");
        }
        @Override public void action() {
          if (shapesPrev[getInt()])
            resetShapesPrev();
          else {
            resetShapesPrev();
            shapesPrev[getInt()] = true;
          }
        }
        @Override public boolean isDone() {
          return shapesPrev[getInt()];
        }
      };
      tempCbs.add(cb.setInt(i));
    }

    boxCb = new checkBox.CheckBox(main, x, y, w, h, "Box") {
      @Override public void tweak() {
        setDesc("Arranges a bunch of particles into an empty box.");
      }
      @Override public void action() {
        int index = indexCustoms();
        float radius = anyCustoms() ? ENV.getCustoms().getPts().get(index).getRadius() : rd * pow(10, ctePots[8]) / selFacts[0];
        float sep = 2 * sqSep * radius;
        float still = (nPts - 1) * sep / 2;
        for (int i = 0; i < nPts; i++) {
          float iter = - (nPts - 1) * sep / 2 + i * sep;
          addShapeParticle(iter, still);
          addShapeParticle(iter, - still);
          if (i > 0 && i < nPts - 1) {
            addShapeParticle(still, iter);
            addShapeParticle( - still, iter);
          }
        }
      }
    };
    fBoxCb = new checkBox.CheckBox(main, x, y + h, w, h, "Filled box") {
      @Override public void tweak() {
        setDesc("Arranges a bunch of particles into a filled box.");
      }
      @Override public void action() {
        int index = indexCustoms();
        float radius = anyCustoms() ? ENV.getCustoms().getPts().get(index).getRadius() : rd * pow(10, ctePots[8]) / selFacts[0];
        float sep = 2 * sqSep * radius;
        for (int i = 0; i < nPts; i++)
          for (int j = 0; j < nPts; j++)
            addShapeParticle( - (nPts - 1) * sep / 2 + i * sep, - (nPts - 1) * sep / 2 + j * sep);
      }
    };
    circCb = new checkBox.CheckBox(main, x, y + 2 * h, w, h, "Circle") {
      @Override public void tweak() {
        setDesc("Arranges a bunch of particles into a configurable circular shape.");
      }
      @Override public void action() {
        for (int i = 0; i < rings; i++) {
          int index = indexCustoms();
          float radius = anyCustoms() ? ENV.getCustoms().getPts().get(index).getRadius() : rd * pow(10, ctePots[8]) / selFacts[0];
          float rd = radShape * radius;
          int n = floor(PI * radShape * (i + 1));
          for (int j = 0; j < n - 1; j++) {
            float th = TWO_PI * j / (n - 1);
            float x = rd * (i + 1) * cos(th);
            float y = rd * (i + 1) * sin(th);
            addShapeParticle(x, y);
          }
        }
      }
    };
    tempCbs.add(boxCb);
    tempCbs.add(fBoxCb);
    tempCbs.add(circCb);

    shapesCp.addSlider("nPts").setPosition(x + 2 * w, y).setRange(2, 50).setValue(0).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Particles").setColorLabel(color(255));
    shapesCp.addSlider("sqSep").setPosition(x + 2 * w, y + 0.5 * h).setRange(1, 10).setValue(1).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Square separation").setColorLabel(color(255));

    shapesCp.addSlider("rings").setPosition(x + 2 * w, y + 1.5 * h).setRange(1, 10).setValue(1).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Rings").setColorLabel(color(255));
    shapesCp.addSlider("radShape").setPosition(x + 2 * w, y + 2 * h).setRange(2, 50).setValue(1).setSize(round(w * scalingX), round(h * scalingY / 2))
      .setColorValue(0).setColorCaptionLabel(0).setColorForeground(color(255, 255, 0))
      .setColorActive(color(255, 255, 0, 130)).setColorBackground(color(255, 130)).setLabel("Radius").setColorLabel(color(255));

    shapesCbs = new checkBox.CheckBox[2 * shapesPrev.length];
    for (int i = 0; i < shapesCbs.length; i++) shapesCbs[i] = tempCbs.get(i);
    for (checkBox.CheckBox cb : shapesCbs) cb.setScale(scalingX, scalingY).tweak();
  }
  void toggleShapes() {
    for (checkBox.CheckBox cb : shapesCbs)
      if (cb.overlaps(mouseX, mouseY) && !cb.cannotClick())
        cb.action();
  }
  void showShapes() {
    push();
    textSize(22);
    int index = indexCustoms();
    color col = anyCustoms() ? ENV.getCustoms().getPts().get(index).getColor() : color(ptR, ptG, ptB);
    text("Shape selection", 250, 30);
    fill(col);
    float radius = anyCustoms() ? ENV.getCustoms().getPts().get(index).getRadius() : rd * pow(10, ctePots[8]) / selFacts[0];
    if (shapesPrev[0]) {
      float sep = 2 * sqSep * radius;

      float still = (nPts - 1) * sep / 2;
      for (int i = 0; i < nPts; i++) {
        float iter = - (nPts - 1) * sep / 2 + i * sep;
        PVector trans = ENV.getVisualizer().getTranslate();
        circle(iter + trans.x, trans.y - still, 2 * radius);
        circle(iter + trans.x, trans.y + still, 2 * radius);
        if (i > 0 && i < nPts - 1) {
          circle(trans.x + still, trans.y - iter, 2 * radius);
          circle(trans.x - still, trans.y - iter, 2 * radius);
        }
      }
    } else if (shapesPrev[1]) {
      float sep = 2 * sqSep * radius;
      for (int i = 0; i < nPts; i++)
        for (int j = 0; j < nPts; j++) {
          float x =  - (nPts - 1) * sep / 2 + i * sep, y = - (nPts - 1) * sep / 2 + j * sep;
          PVector trans = ENV.getVisualizer().getTranslate();
          circle(x + trans.x, trans.y - y, 2 * radius);
        }
    } else if (shapesPrev[2]) {
      for (int i = 0; i < rings; i++) {
        float rd = radShape * radius;
        int n = floor(PI * radShape * (i + 1));
        for (int j = 0; j < n - 1; j++) {
          float th = TWO_PI * j / (n - 1);
          float x = rd * (i + 1) * cos(th);
          float y = rd * (i + 1) * sin(th);
          PVector trans = ENV.getVisualizer().getTranslate();
          circle(x + trans.x, trans.y - y, 2 * radius);
        }
      }
    }
    pop();
    for (checkBox.CheckBox cb : shapesCbs) cb.show();
  }
  void addShapeParticle(float x, float y) {
    Particle p;
    if (anyCustoms()) {
      int index = indexCustoms();
      p = ENV.getCustoms().getPts().get(index).blindCopy().setPos(x, y);
    } else {
      float mDens = md * pow(10, ctePots[6]) / selFacts[2];
      float cDens = cd * pow(10, ctePots[7]) / selFacts[3];
      float radius = rd * pow(10, ctePots[8]) / selFacts[0];
      p = getParticleAddition(new PVector(x, y), mDens, cDens, radius, color(ptR, ptG, ptB));
    }
    p.getVisualizer().setTranslate(ENV.getVisualizer().getTranslate()).setScaling(ENV.getVisualizer().getScaling());
    addToDefaultGroups(p.setSelected(false));
    ENV.add(p);
  }

  void initDataManagement() {
    int x = 250;
    int y = h;

    List<checkBox.CheckBox> tempCbs = new ArrayList<checkBox.CheckBox>();

    for (int i = 0; i < ENV.getBackupCount(); i++) {
      String name = "Slot " + (i + 1);
      checkBox.CheckBox save = new checkBox.CheckBox(main, x, y + i * h / 2, w / 2, h / 2, name) {
        @Override public void action() {
          ENV.saveEnv(getInt());
        }
        @Override public boolean isDone() {
          return ENV.hasBackup(getInt());
        }
      };
      checkBox.CheckBox load = new checkBox.CheckBox(main, x + w / 2, y + i * h / 2, w / 2, h / 2, "Load") {
        @Override public void action() {
          ENV.loadEnv(getInt());
        }
        @Override public boolean cannotClick() {
          return !ENV.hasBackup(getInt());
        }
      };
      checkBox.CheckBox delete = new checkBox.CheckBox(main, x + 1.5 * w, y + i * h / 2, w / 2, h / 2, "Delete") {
        @Override public void action() {
          ENV.removeBackup(getInt());
        }
        @Override public boolean cannotClick() {
          return !ENV.hasBackup(getInt());
        }
      };
      checkBox.CheckBox ctes = new checkBox.CheckBox(main, x + w, y + i * h / 2, w / 2, h / 2, "Constants") {
        @Override public void action() {
          ENV.loadConstants(getInt());
        }
        @Override public boolean cannotClick() {
          return !ENV.hasBackup(getInt());
        }
      };
      checkBox.CheckBox prev = new checkBox.CheckBox(main, x + 2 * w, y + i * h / 2, w / 2, h / 2, "Preview") {
        @Override public void action() {
          if (ENV.getBckpPrev()[getInt()])
            ENV.resetBckpPrev();
          else {
            ENV.resetBckpPrev();
            ENV.getBckpPrev()[getInt()] = !ENV.getBckpPrev()[getInt()];
          }
        }
        @Override public boolean isDone() {
          return ENV.getBckpPrev()[getInt()];
        }
        @Override public boolean cannotClick() {
          return !ENV.hasBackup(getInt());
        }
      };
      tempCbs.add(save.setInt(i));
      tempCbs.add(load.setInt(i));
      tempCbs.add(ctes.setInt(i));
      tempCbs.add(delete.setInt(i));
      tempCbs.add(prev.setInt(i));
    }

    saveFramesCb = new checkBox.CheckBox(main, x + 2.5 * w, y, w, h, "Export frames") {
      @Override public void tweak() {
        setDesc("Saves the frames of the simulation to the data folder. Dramatically reduces performance!");
      }
      @Override public void action() {
        saveFrames = !saveFrames;
      }
      @Override public boolean isDone() {
        return saveFrames;
      }
    };
    saveDataCb = new checkBox.CheckBox(main, x + 2.5 * w, y + h, w, h, "Export data(G)") {
      @Override public void tweak() {
        setDesc("Saves the data of the particles to the data folder. The data will be conviniently ordered.");
      }
      @Override public void action() {
        groupRoutine("saveData");
        if (!isPressingControl())
          saveDataOnAddition = !saveDataOnAddition;
        if (doneSaveData) {
          doneSaveData = false;
          boolean exists = true;
          dataSetCount = 1;
          while (exists)
            if (new File(dataPath("particles_data/properties_set" + dataSetCount + ".txt")).exists())
              dataSetCount++;
            else
              exists = false;

          PrintWriter genDataOut = createWriter(dataPath("particles_data/properties_set" + dataSetCount + ".txt"));
          genDataOut.println("Properties corresponding to data set number " + dataSetCount);
          genDataOut.println("UNITS OF THIS DATA SET: " + dispUnits[0] + " " + dispUnits[1] + " " + dispUnits[2] + " " +
            dispUnits[3] + " " + dispUnits[4] + "/" + dispUnits[5] + " " + dispUnits[6]); 
          int i = 0;
          for (Particle p : ENV.getGroup("saveData")) {
            genDataOut.println("PARTICLE " + ++i + ": ");
            genDataOut.println("Mass: " + p.getMass() * dispFacts[2] + dispUnits[2]);
            genDataOut.println("Charge: " + p.getCharge() * dispFacts[3] + dispUnits[3]);
            genDataOut.println("Radius: " + p.getRadius() * dispFacts[0] + dispUnits[0]);
          }
          genDataOut.flush();
          genDataOut.close();
          outputPos = createWriter(dataPath("particles_data/positions_set" + dataSetCount + ".txt"));
          outputVel = createWriter(dataPath("particles_data/velocities_set" + dataSetCount + ".txt"));
          outputEnergy = createWriter(dataPath("particles_data/energies_set" + dataSetCount + ".txt"));
        }
      }
      @Override public boolean isDone() {
        return saveDataOnAddition;
      }
      @Override public boolean cannotClick() {
        return ENV.isEmpty();
      }
      @Override public boolean hasToClick() {
        return !ENV.getGroup("saveData").isEmpty() && !isDone();
      }
    };
    doneSaveDataCb = new checkBox.CheckBox(main, x + 3.5 * w, y + h, w / 2, h, "Done") {
      @Override public void tweak() {
        setDesc("Stops saving data and closes the file.");
      }
      @Override public void action() {
        outputPos.flush();
        outputPos.close();
        outputVel.flush();
        outputVel.close();
        outputEnergy.flush();
        outputEnergy.close();
        ENV.getGroup("saveData").clear();
        saveDataOnAddition = false;
        doneSaveData = true;
      }
      @Override public boolean cannotClick() {
        return doneSaveData;
      }
    };
    saveProgramCb = new checkBox.CheckBox(main, x + 2.5 * w, y + 2 * h, w, h, "Save session") {
      @Override public void tweak() {
        setDesc("Saves all your backups and custom particles, even if you exit the program.");
      }
      @Override public void action() {
        ENV.stopRecording();
        ENV.clearRecords();
        ENV.save(main);
        ENV.importRecordsFromTxt(main, ENV.getData());
      }
    };
    tempCbs.add(saveFramesCb);
    tempCbs.add(saveDataCb);
    tempCbs.add(doneSaveDataCb);
    tempCbs.add(saveProgramCb);

    dataCbs = new checkBox.CheckBox[tempCbs.size()];
    for (int i = 0; i < tempCbs.size(); i++) dataCbs[i] = tempCbs.get(i);
    for (checkBox.CheckBox cb : dataCbs) cb.setScale(scalingX, scalingY).tweak();
  }
  void toggleDataManagement() {
    for (checkBox.CheckBox cb : dataCbs)
      if (cb.overlaps(mouseX, mouseY) && !cb.cannotClick())
        cb.action();
  }
  void showDataManagement() {
    push();
    text("Backup options", 250, 30);
    text("Export options", 250 + 2.5 * w, 30);
    for (int i = 0; i < ENV.getBckpPrev().length; i++)
      if (ENV.getBckpPrev()[i]) {
        float x = 250, y = 7 * h, sc = 16 * 50.0 / width;
        for (Particle p : ENV.getBackup(i).getParticles()) {
          PVector pos = ENV.invTransform(p.getPos()).mult((float) width / width);
          push();
          translate(x, y);
          scale(sc);
          noFill();
          stroke(255);
          rect(0, 0, width, height);
          fill(p.getColor()); 
          noStroke();
          circle(pos.x, pos.y, 2 * p.getRadius());
          pop();
        }
        break;
      }
    text("Press 1,...,9 to save a backup", 250, 8 * h);
    text("Press 1,...,9 + CONTROL to load a backup", 250, 8.5 * h);
    text("Press 1,...,9 + BACKSPACE to delete a backup", 250, 9 * h);
    text("Press 1,...,9 + CONTROL + BACKSPACE to load constants", 250, 9.5 * h);
    pop();
    for (checkBox.CheckBox cb : dataCbs) cb.show();
  }

  void initUnits() {
    int x = 250;
    int y = h + 25;
    int w = 100;
    int h = 25;
    replenishMap();

    envUnits = new String[] {ENV.getUnits().getLengthUnit(), ENV.getUnits().getTimeUnit()};
    selUnits = new String[] {ENV.getUnits().getLengthUnit(), ENV.getUnits().getTimeUnit(), ENV.getUnits().getMassUnit(), ENV.getUnits().getChargeUnit()};
    dispUnits = new String[] {ENV.getUnits().getLengthUnit(), ENV.getUnits().getTimeUnit(), ENV.getUnits().getMassUnit(), ENV.getUnits().getChargeUnit(), 
      ENV.getUnits().getLengthUnit(), ENV.getUnits().getTimeUnit(), getEnergyUnits().get(0), getMomentumUnits().get(0), getAngularUnits().get(0)};

    selFacts = new float[] {1, 1, 1, 1};
    dispFacts = new float[] {1, 1, 1, 1, 1, 1, 1, 1};

    List<checkBox.CheckBox> tempCbs = new ArrayList<checkBox.CheckBox>();
    for (int i = 0; i < Units.getLengthUnits().size(); i++) {
      checkBox.CheckBox cb1 = new checkBox.CheckBox(main, x, y + i * h, w, h, Units.getLengthUnits().get(i)) {
        @Override public void action() {
          envUnits[0] = Units.getLengthUnits().get(getInt());
          if (ENV.anyRec()) ENV.getRecordings().trackUnit(ENV.indexRec(), ENV.getFrameCount(ENV.indexRec()), new String[]{envUnits[0], envUnits[1]});
          updateSystemLengthUnit();
        }
        @Override public boolean isDone() {
          return envUnits[0].equals(Units.getLengthUnits().get(getInt()));
        }
      };
      checkBox.CheckBox cb2 = new checkBox.CheckBox(main, x + 1.5 * this.w, y + i * h, w, h, Units.getLengthUnits().get(i)) {
        @Override public void action() {
          selUnits[0] = Units.getLengthUnits().get(getInt());
          selFacts[0] = ENV.getUnits().getLengthFactor(selUnits[0]);
        }
        @Override public boolean isDone() {
          return selUnits[0].equals(Units.getLengthUnits().get(getInt()));
        }
      };
      checkBox.CheckBox cb3 = new checkBox.CheckBox(main, x + 4 * this.w, y + i * h, w, h, Units.getLengthUnits().get(i)) {
        @Override public void action() {
          dispUnits[0] = Units.getLengthUnits().get(getInt());
          dispFacts[0] = ENV.getUnits().getLengthFactor(dispUnits[0]);
        }
        @Override public boolean isDone() {
          return dispUnits[0].equals(Units.getLengthUnits().get(getInt()));
        }
      };
      checkBox.CheckBox cb4 = new checkBox.CheckBox(main, x + 0.7 * i * w, 615, 0.7 * w, h, Units.getLengthUnits().get(i)) {
        @Override public void action() {
          dispUnits[4] = Units.getLengthUnits().get(getInt());
          dispFacts[4] = ENV.getUnits().getVelFactor(dispUnits[4], dispUnits[5]);
        }
        @Override public boolean isDone() {
          return dispUnits[4].equals(Units.getLengthUnits().get(getInt()));
        }
      };

      tempCbs.add(cb1.setInt(i));
      tempCbs.add(cb2.setInt(i));
      tempCbs.add(cb3.setInt(i));
      tempCbs.add(cb4.setInt(i));
    }
    for (int i = 0; i < Units.getTimeUnits().size(); i++) {
      checkBox.CheckBox cb1 = new checkBox.CheckBox(main, x + w, y + i * h, w, h, Units.getTimeUnits().get(i)) {
        @Override public void action() {
          envUnits[1] = Units.getTimeUnits().get(getInt());
          updateSystemTimeUnit();
        }
        @Override public boolean isDone() {
          return envUnits[1].equals(Units.getTimeUnits().get(getInt()));
        }
      };
      checkBox.CheckBox cb2 = new checkBox.CheckBox(main, x + 1.5 * this.w + w, y + i * h, w, h, Units.getTimeUnits().get(i)) {
        @Override public void action() {
          selUnits[1] = Units.getTimeUnits().get(getInt());
          selFacts[1] = ENV.getUnits().getTimeFactor(selUnits[1]);
        }
        @Override public boolean isDone() {
          return selUnits[1].equals(Units.getTimeUnits().get(getInt()));
        }
      };
      checkBox.CheckBox cb3 = new checkBox.CheckBox(main, x + 4 * this.w + w, y + i * h, w, h, Units.getTimeUnits().get(i)) {
        @Override public void action() {
          dispUnits[1] = Units.getTimeUnits().get(getInt());
          dispFacts[1] = ENV.getUnits().getTimeFactor(dispUnits[1]);
        }
        @Override public boolean isDone() {
          return dispUnits[1].equals(Units.getTimeUnits().get(getInt()));
        }
      };
      checkBox.CheckBox cb4 = new checkBox.CheckBox(main, x + 0.7 * i * w, 615 + h, 0.7 * w, h, Units.getTimeUnits().get(i)) {
        @Override public void action() {
          dispUnits[5] = Units.getTimeUnits().get(getInt());
          dispFacts[4] = ENV.getUnits().getVelFactor(dispUnits[4], dispUnits[5]);
        }
        @Override public boolean isDone() {
          return dispUnits[5].equals(Units.getTimeUnits().get(getInt()));
        }
      };
      tempCbs.add(cb1.setInt(i));
      tempCbs.add(cb2.setInt(i));
      tempCbs.add(cb3.setInt(i));
      tempCbs.add(cb4.setInt(i));
    }
    for (int i = 0; i < Units.getMassUnits().size(); i++) {
      checkBox.CheckBox cb1 = new checkBox.CheckBox(main, x + 1.5 * this.w + 2 * w, y + i * h, w, h, Units.getMassUnits().get(i)) {
        @Override public void action() {
          selUnits[2] = Units.getMassUnits().get(getInt());
          selFacts[2] = ENV.getUnits().getMassFactor(selUnits[2]);
        }
        @Override public boolean isDone() {
          return selUnits[2].equals(Units.getMassUnits().get(getInt()));
        }
      };
      checkBox.CheckBox cb2 = new checkBox.CheckBox(main, x + 4 * this.w + 2 * w, y + i * h, w, h, Units.getMassUnits().get(i)) {
        @Override public void action() {
          dispUnits[2] = Units.getMassUnits().get(getInt());
          dispFacts[2] = ENV.getUnits().getMassFactor(dispUnits[2]);
        }
        @Override public boolean isDone() {
          return dispUnits[2].equals(Units.getMassUnits().get(getInt()));
        }
      };
      tempCbs.add(cb1.setInt(i));
      tempCbs.add(cb2.setInt(i));
    }
    for (int i = 0; i < Units.getChargeUnits().size(); i++) {
      checkBox.CheckBox cb1 = new checkBox.CheckBox(main, x + 1.5 * this.w + 3 * w, y + i * h, w, h, Units.getChargeUnits().get(i)) {
        @Override public void action() {
          selUnits[3] = Units.getChargeUnits().get(getInt());
          selFacts[3] = ENV.getUnits().getChargeFactor(selUnits[3]);
        }
        @Override public boolean isDone() {
          return selUnits[3].equals(Units.getChargeUnits().get(getInt()));
        }
      };
      checkBox.CheckBox cb2 = new checkBox.CheckBox(main, x + 4 * this.w + 3 * w, y + i * h, w, h, Units.getChargeUnits().get(i)) {
        @Override public void action() {
          dispUnits[3] = Units.getChargeUnits().get(getInt());
          dispFacts[3] = ENV.getUnits().getChargeFactor(dispUnits[3]);
        }
        @Override public boolean isDone() {
          return dispUnits[3].equals(Units.getChargeUnits().get(getInt()));
        }
      };
      tempCbs.add(cb1.setInt(i));
      tempCbs.add(cb2.setInt(i));
    }
    for (int i = 0; i < energyUnits.size(); i++) {
      checkBox.CheckBox cb = new checkBox.CheckBox(main, x + 0.7 * i * w, 625 + 3 * h, w * 0.7, h, getEnergyUnits().get(i)) {
        @Override public void action() {
          dispUnits[6] = getEnergyUnits().get(getInt());
          dispFacts[5] = ENV.getUnits().getEnergyFactor("m", "s", "kg") / energyUnits.get(dispUnits[6]);
        }
        @Override public boolean isDone() {
          return dispUnits[6].equals(getEnergyUnits().get(getInt()));
        }
      };
      tempCbs.add(cb.setInt(i));
    }
    for (int i = 0; i < momentumUnits.size(); i++) {
      checkBox.CheckBox cb = new checkBox.CheckBox(main, x + 0.7 * i * w, 625 + 4 * h, w * 0.7, h, getMomentumUnits().get(i)) {
        @Override public void action() {
          dispUnits[7] = getMomentumUnits().get(getInt());
          dispFacts[6] = ENV.getUnits().getMomentumFactor("m", "s", "kg") / momentumUnits.get(dispUnits[7]);
        }
        @Override public boolean isDone() {
          return dispUnits[7].equals(getMomentumUnits().get(getInt()));
        }
      };
      tempCbs.add(cb.setInt(i));
    }
    for (int i = 0; i < angularUnits.size(); i++) {
      checkBox.CheckBox cb = new checkBox.CheckBox(main, x + 0.7 * i * w, 625 + 5 * h, w * 0.7, h, getAngularUnits().get(i)) {
        @Override public void action() {
          dispUnits[8] = getAngularUnits().get(getInt());
          dispFacts[7] = ENV.getUnits().getAngularMomentumFactor("m", "s", "kg") / angularUnits.get(dispUnits[8]);
        }
        @Override public boolean isDone() {
          return dispUnits[8].equals(getAngularUnits().get(getInt()));
        }
      };
      tempCbs.add(cb.setInt(i));
    }

    unitsCbs = new checkBox.CheckBox[tempCbs.size()];
    for (int i = 0; i < tempCbs.size(); i++) unitsCbs[i] = tempCbs.get(i);
    for (checkBox.CheckBox cb : unitsCbs) cb.setScale(scalingX, scalingY).tweak();
  }
  void toggleUnits() {
    for (checkBox.CheckBox cb : unitsCbs)
      if (cb.overlaps(mouseX, mouseY) && !cb.cannotClick())
        cb.action();
  }
  void showUnits() {
    push();
    textSize(22);
    text("Env units", 250, 30);
    text("Selection units", 550, 30);
    text("Display units", 1050, 30);
    text("Other quantities display units", 250, 575);
    textSize(18);
    text("Length", 250, 60);
    text("Time", 350, 60);
    text("Length", 550, 60);
    text("Time", 650, 60);
    text("Mass", 750, 60);
    text("Charge", 850, 60);
    text("Length", 1050, 60);
    text("Time", 1150, 60);
    text("Mass", 1250, 60);
    text("Charge", 1350, 60);
    text("Velocity", 250, 600);
    text("Energy, momentum & angular momentum", 250, 685);
    pop();
    for (checkBox.CheckBox cb : unitsCbs) cb.show();
  }

  void initInstructions() {

    int x = 250;
    int y = h;

    List<checkBox.CheckBox> tempCbs = new ArrayList<checkBox.CheckBox>();
    String[] names = new String[] {"Add particle", "Add soft body", "Select particle", "Groups(G)", "Plotting", 
      "Draw fields", "Units", "Backups & data", "Recording", "Integration methods", "Shapes", "Examples"};
    instrToggles = new boolean[names.length];
    for (int i = 0; i < names.length; i++) {
      checkBox.CheckBox cb = new checkBox.CheckBox(main, x, y + i * h / 1.5, w, h / 1.5, names[i]) {
        @Override public void action() {
          if (instrToggles[getInt()])
            resetInstrToggles();
          else {
            resetInstrToggles();
            instrToggles[getInt()] = true;
          }
        }
        @Override public boolean isDone() {
          return instrToggles[getInt()];
        }
      };
      tempCbs.add(cb.setInt(i));
    }

    examplesEnv = new Environment(main);
    float trX = 997, trY = height / (2 * scalingY);
    examplesEnv.setDim(Environment.DIMENSION.TWO).getVisualizer().setTranslate(trX, trY);

    exampleId = 0;
    totExamples = 5;
    arrowLeftCb = new checkBox.CheckBox(main, x + w + 10, y + 7.5 * h, w / 6, h / 2, "<-") {
      @Override public void action() {
        if (--exampleId < 0)
          exampleId = totExamples - 1;
        setExample(exampleId);
      }
    };
    arrowRightCb = new checkBox.CheckBox(main, x + w + 1050, y + 7.5 * h, w / 6, h / 2, "->") {
      @Override public void action() {
        if (++exampleId >= totExamples)
          exampleId = 0;
        setExample(exampleId);
      }
    };
    examplesCbs = new checkBox.CheckBox[] {arrowLeftCb, arrowRightCb};

    instrCbs = new checkBox.CheckBox[tempCbs.size()];
    for (int i = 0; i < tempCbs.size(); i++) instrCbs[i] = tempCbs.get(i);
    for (checkBox.CheckBox cb : instrCbs) cb.setScale(scalingX, scalingY).tweak();
    for (checkBox.CheckBox cb : examplesCbs) cb.setScale(scalingX, scalingY).tweak();
    setExample(0);
  }
  void toggleInstructions() {
    for (checkBox.CheckBox cb : instrCbs)
      if (cb.overlaps(mouseX, mouseY) && !cb.cannotClick())
        cb.action();
    if (instrToggles[11])
      for (checkBox.CheckBox cb : examplesCbs)
        if (cb.overlaps(mouseX, mouseY) && !cb.cannotClick())
          cb.action();
  }
  void showInstructions() {
    push();
    int x = 460, y = h;
    textSize(20);
    text("Quick guides", 250, 30);
    textSize(19);

    if (!anyInstr()) {
      int ht = 70, wt = round(width / scalingX) - x - 50;
      text("Key bindings & general info", x, 30);
      text("You can perform multiple actions, in which the mouse will behave differently. These are:" + 
        " 'Adding particle', 'Adding soft body', etc. You can switch between them manually" + 
        " from the settings, or with some of the keys listed below.", x, y, wt, ht);
      text("Press BACKSPACE while adding a particle to interrupt the action.", x, y + ht, wt, ht / 2);
      ht /= 2;
      text("Press SHIFT while adding a particle to reset its position before launching.", x, y + 3 * ht, wt, ht);
      text("Press SHIFT to control the camera: Zoom in or out or drag the screen.", x, y + 4 * ht, wt, ht);
      text("Press CONTROL to change the action of the groups checkboxes (see Groups(G)).", x, y + 5 * ht, wt, ht);
      text("Press CONTROL to modify the action of the sel checkboxes (in interactions).", x, y + 6 * ht, wt, ht);
      text("Press C to TOGGLE the control of a selected particle. (Must have selected only one particle!).", x, y + 7 * ht, wt, ht);
      text("To actually control it, you must press SHIFT, and the partile will move to the mouse position.", x, y + 8 * ht, wt, ht);
      text("Press R to remove the selected particles and CONTROL + R to delete all of them.", x, y + 9 * ht, wt, ht);
      text("Press A & D to switch between actions and W & S to switch between custom particles.", x, y + 10 * ht, wt, ht);
      text("Press W & S to switch between tabs (in settings).", x, y + 11 * ht, wt, ht);
      text("Press Q to attach the selected particles with springs.", x, y + 12 * ht, wt, ht);
      text("Press E to set a particle static or dynamic.", x, y + 13 * ht, wt, ht);
      text("Press B to add a bunch of particles scattered around the screen. The number of particles is regulated by the 'Add bunch' slider.", x, y + 14 * ht, wt, ht);
      text("Press UP & DOWN to change the timestep and LEFT & RIGHT to change the integrations per frame.", x, y + 15 * ht, wt, ht);
      text("Press CONTROL + S to select all particles.", x, y + 16 * ht, wt, ht);
      text("Press F to toggle mouse coordinates.", x, y + 17 * ht, wt, ht);
      text("Press 1,...,9 to save a backup.", x, y + 18 * ht, wt, ht);
      text("Press 1,...,9 + CONTROL to load a backup.", x, y + 19 * ht, wt, ht);
      text("Press 1,...,9 + BACKSPACE to delete a backup.", x, y + 20 * ht, wt, ht);
      text("Press 1,...,9 + CONTROL + BACKSPACE to load constants.", x, y + 21 * ht, wt, ht);
    } else if (instrToggles[0]) {
      int ht = 80, wt = round(width / scalingX) - x - 50;
      text("How to add a particle", x, 30);
      text("First, make sure you are 'Adding particle', by unchecking all other actions or, from the sim screen, " + 
        "navigating the actions with A and D until you see 'Adding particle'.", x, y, wt, ht);
      text("Click on the screen and drag the mouse to give the particle some momentum. You can interrupt this action " + 
        "by pressing BACKSPACE while dragging. You can predict some of the path of the particle by having 'Draw path' " + 
        "enabled in 'General'", x, y + ht, wt, ht);
      text("You can change all the properties of the particle you are adding in 'General'.", x, y + 2 * ht, wt, ht);
      text("To save a particle configuration click on 'Save' and the current particle configuration will be saved. " + 
        "These saved configuration will appear below where the 'Add' and 'Rem' (remove) tabs are placed.", x, y + 3 * ht, wt, ht);
      text("To add a custom particle, click on 'Add'. You can also select a custom particle in the sim window with " + 
        "the W and S keys while 'Adding particle' is enabled. To delete a custom particle, click on 'Rem'.", x, y + 4 * ht, wt, ht);
    } else if (instrToggles[1]) {
      int ht = 100, wt = round(width / scalingX) - x - 50;
      text("How to add a soft body", x, 30);
      text("First, make sure you are 'Adding soft body', by clicking on 'Add soft body' in 'Soft body' or, from the sim screen, " + 
        "navigating the actions with A and D until you see 'Adding soft body'.", x, y, wt, ht);
      text("Click on the screen to set the start point of the soft body. You will see the soft body  follow your mouse until " + 
        "you click again to set its end point. Once added to the simulation, the soft body will be dynamic.", x, y + ht, wt, ht);
      text("Before the addition, you can click on 'Preview' to see a preview of the soft body you are about to add. " + 
        "The added soft body will be identical to the model. You can control any of its nodes to see how it will behave in " + 
        "the simulation.", x, y + 2 * ht, wt, ht);
      text("You can change all of its properties in 'Soft body'. The terms of the soft body refers to the expression of the " + 
        "force of the springs attached to each particle in the soft body. By adding more terms, you are increasing the dependence " + 
        "in distance of the force. The decay value sets how smooth this increase is.", x, y + 3 * ht, wt, ht);
    } else if (instrToggles[2]) {
      int ht = 80, wt = round(width / scalingX) - x - 50;
      text("How to select a particle", x, 30);
      text("First, make sure you are 'Selecting particle', by clicking on 'Select' in 'Selected' or, from the sim screen, " + 
        "navigating the actions with A and D until you see 'Selecting particle'.", x, y, wt, ht);
      text("Click on the particles to select them, or drag the mouse to create a selection rectangle. " + 
        "You can press CONTROL while doing this to deselect the particles outside said rectangle.", x, y + ht, wt, ht);
      text("You can also select them by enabling the preview in 'Selected', " + 
        "and clicking the particles from there, without the need of 'Selecting particle' mode.", x, y + 2 * ht, wt, ht);
    } else if (instrToggles[3]) {
      int ht = 120, wt = round(width / scalingX) - x - 50;
      text("Groups (G) mechanic", x, 30);
      text("They allow to organize the particles by groups, in such a way that some features only apply to the " + 
        "particles belonging to a concrete group. All the checkboxes labeled with (G) share the same mechanic.", x, y, wt, ht);
      text("If you click on any of them, it will light up green, meaning that, from now on, every particle you add will " + 
        "be added automatically to that group. In the case, for example, of 'Show data(G)', the new particles will show " + 
        "their data on screen.", x, y + ht, wt, ht);
      text("If you click on any of them while pressing CONTROL, it will not add the particles by default. Instead, it will " + 
        "add the current selected particles in the simulation. If none are selected, the action will include all particles. If some of " + 
        "the selected particles are already in the group, only the ones that are not will be included. If, however, all of them " + 
        "are already in, the action will remove them.", x, y + 2 * ht, wt, ht);
      text("The checkbox will light up yellow if there are currently particles in the group, green if the particles are " + 
        "being added by default and blue otherwise. The green color will be prioritized.", x, y + 3 * ht, wt, ht);
    } else if (instrToggles[4]) {
      int ht = 90, wt = round(width / scalingX) - x - 50;
      text("Plotting", x, 30);
      text("It allows you to plot in a graph physical quantities and see how they evolve over time.", x, y, wt, ht);
      text("To be able to plot anything, you need to collect data from the particles. The corresponding checkbox works " + 
        "as a group, so you can choose from which particles the data will be plotted.", x, y + ht, wt, ht);
      text("If the histogram option is disabled, you will be able to plot many quantities simulatneously. " + 
        "The program will take the value of that quantity from every single corresponding particle at every timestep, " + 
        "add them and show the result as a new point on the graph.", x, y + 2 * ht, wt, ht);
      text("With the histogram option, you can plot the same quantities in a different way (a distribution plot). " + 
        "The program will choose a range of values (batches) for the selected quantity according to the particles. For every batch " + 
        "the plot will represent how many particles fall between the batch's ranges.", x, y + 3 * ht, wt, ht);
    } else if (instrToggles[5]) {
      int ht = 90, wt = round(width / scalingX) - x - 50;
      text("Force fields & contour lines", x, 30);
      text("It allows you to draw on screen the force fields an d potential contour lines created by particles " + 
        "due to their interactions.", x, y, wt, ht);
      text("The force field is a vector field showing how the corresponding particles will induce a force to a " + 
        "'unit particle' with mass, charge and radius equal to 1. The arrow will point towards the direction of the force with " + 
        "a magnitude proportional to its length.", x, y + ht, wt, ht);
      text("The contour lines represent regions of space where the potential produced by said particles " + 
        "remains constant. This means that each line has a potential value associated. The lines are " + 
        "equispaced potential-wise: The difference in potential between two adjacent lines is the same for all", x, y + 2 * ht, wt, ht);
      text("You can change the detail of both. This determines how the space is subdivided. High details" + 
        "will be more time consuming. You can also change the amount of contour values and the range in which these values are picked.", x, y + 3 * ht, wt, ht);
      text("It is useful to relativize the magnitudes of the force field to re-normalize in function of the minimum " + 
        "and maximum values of the mangitude.", x, y + 4 * ht, wt, ht);
    } else if (instrToggles[6]) {
      int ht = 120, wt = round(width / scalingX) - x - 50;
      text("Units", x, 30);
      text("Units are very useful to give some physical meaning to the simulation. There are 4 unit types:" + 
        "Length, Time, Mass, and Charge units. They are grouped in sections: Environmental, Selection and Display units.", x, y, wt, ht);
      text("Environmental units: The units of space and time the simulation will run with. If changed to, for example, " + 
        "UA and years from meters and seconds, the simulation will advance with timesteps measured in years (time will advance much faster)" + 
        "and if the boundaries' dimensions were 1920mx1080m, now they will be 1920UAx1080UA (a much larger space)", x, y + ht, wt, ht);
      text("Be careful changing these units. If you place 10 meter sized particles and you change the spacial units to " + 
        "micrometers, space will shrink! The particles will look incredibly big (they wont fit on screen). Similar " + 
        "time-related things can happen with the time units.", x, y + 2 * ht, wt, ht);
      text("Selection units: The units at which you will be adding elements to the simulation. When changing " + 
        "the properties of a particle or rope upon addition, the numbers will be at said units.", x, y + 3 * ht, wt, ht);
      text("Display units: The units at which the numbers will be when showing data, plotting, etc.", x, y + 4 * ht, wt, ht);
      text("These sections are independent. Changing the display or selection units wont affect the simulation at all.", x, y + 5 * ht, wt, ht);
    } else if (instrToggles[7]) {
      int ht = 90, wt = round(width / scalingX) - x - 50;
      text("Backups & data", x, 30);
      text("Backups allow you to save a concrete configuration of particles to be able to return to it later." + 
        "Click on any slot to create one and save the particles' positions and velocities as well as the constants, " + 
        "the groups configuration and the custom particles.", x, y, wt, ht);
      text("To load a backup click on 'Load' to load the positions, velocities etc. If you want to recover the " + 
        "physical constants, click on 'Constants'.", x, y + ht, wt, ht);
      text("You can also save the simulation frames manually (this is very time consuming!) by clicking on 'Save frames', " + 
        "or export the particles' data with 'Save data'.", x, y + 2 * ht, wt, ht);
      text("'Save data' will create a 'set' of data consisting in 4 txt files: 3 containing the particles' data such as " + 
        "their posisitions velocities and energies, and a fourth one containing a summary of their properties and the units of the data set.", x, y + 3 * ht, wt, ht);
    } else if (instrToggles[8]) {
      int ht = 90, wt = round(width / scalingX) - x - 50;
      text("Recording", x, 30);
      text("If you want to run a simulation that demands more computation time than the program can handle " + 
        "(this happens when the frame rate drops below 30), you can 'record' the simulation first and then " + 
        "play the result at 60 fps, no matter the number of interactions or particles.", x, y, wt, ht);
      text("You dont have to be at the sim window to do it! Clicking on 'run' will do (only if your settings " + 
        "are not in another window).", x, y + ht, wt, ht);
      text("To record press 'Record'. You wont be able to do it if there are no particles. Once recording, do not " + 
        "modify the number of particles or errors will occur. Pausing will pause the recording as well as unchecking 'run'.", x, y + 2 * ht, wt, ht);
    } else if (instrToggles[9]) {
      int ht = 90, wt = round(width / scalingX) - x - 50;
      text("Integration methods", x, 30);
      text("You can choose which method to use when integrating. This have different effects on efficiency and " + 
        "accuracy, depending on the order of integration (generally this order comes within the name: RK4, 4th order)", x, y, wt, ht);
      text("The order of integration tells you how the error gets reduced by modifying the timestep. " + 
        "For example, a 4th order method with a timestep dt means that the error is a function of dt^4 " + 
        "(with O notation: O(dt^4)). So if you reduce the timestep by 10, the error will shrink by 10000 (which is a lot)", x, y + ht, wt, ht);
      text("However, not always a high order order method is the best solution. Usually these methods require a lot of " + 
        "computation time as they have to call multiple time a function that gives all the particles' velocities and positions updates" + 
        "multiple times. A lower order method may be less accurate but much faster.", x, y + 2 * ht, wt, ht);
      text("EULER: A 1st order integration method. Very unaccurate and unstable, not recommended at all if you expect " + 
        "rigurous results.", x, y + 3 * ht, wt, ht);
      text("RK4: A 4th order Runge-Kutta integration method. Very accurate as well as efficient. The most recommended otion.", x, y + 4 * ht, wt, ht);
      text("RK6: A 6th order Runge-Kutta integration method. Very accurate but not very efficient.", x, y + 5 * ht, wt, ht);
      text("RKF45: A 5th order Runge-Kutta-Fehlberg method with a 4th order solution to estimate the error.", x, y + 6 * ht, wt, ht);
      text("CK45: A 5th order Cash-Karp method with a 4th order solution to estimate the error.", x, y + 7 * ht, wt, ht);
      text("DOPRI45: A 5th order Dormand-Prince method with a 4th order solution to estimate the error.", x, y + 8 * ht, wt, ht);
    } else if (instrToggles[10]) {
      int ht = 60, wt = round(width / scalingX) - x - 50;
      text("Shapes", x, 30);
      text("The shapes tab allows you to add particles arranged into different shapes, like boxes or circles.", x, y, wt, ht);
      text("You can see a preview by clicking on 'Preview shape' and modify the shapes with the sliders.", x, y + ht, wt, ht);
    } else if (instrToggles[11]) {
      x = 250;
      y = 9 * h;
      int ht = 600, wt = 340;
      textAlign(CENTER);
      text("Example " + (exampleId + 1), 997, 30);
      textAlign(CORNER);
      if (exampleId == 0)
        text("In this example, particles are scattered randomly across the window interacting with attractive long distance forces " + 
          "and repulsive short distance forces, leading into a situation where particles wobble around equilibrium. If you " + 
          "wait long enough, they will reach it, as drag is also enabled. You can repeat this scenario varying the number of particles " + 
          "and its properties, the interactions' constants etc.", x, y, wt, ht);
      else if (exampleId == 1)
        text("In this example, 3 particles orbit a massive static particle as a result of gravitational interaction. " + 
          "The small particles, however, also interact, although you can barely notice as their masses are very small. " + 
          "With the units system help, you could make a similar simulation but with real bodies of the solar system.", x, y, wt, ht);
      else if (exampleId == 2)
        text("In this example, particles are positioned precisely to form a square, a very ordered system with a low entropy. " + 
          "When we introduce a moving particle that collides with the square, you can see how all particles begin to scatter as " + 
          "the system tends to evolve to a more disordered state (high entropy), satisfying Maxwell-Boltzmann energy distribution. " + 
          "If you run this scenario on the sim screen, you can plot this distribution from the 'Advanced' tab.", x, y, wt, ht);
      else if (exampleId == 3)
        text("In this example, a soft body is simulated attaching a bunch of particles with springs. You can make your own " + 
          "changing the dampening, non lineal terms and stiffness of the springs, as well as the particles' properties.", x, y, wt, ht);
      else if (exampleId == 4)
        text("In this example, a bunch of particles are scattered randomly width random velocities, and one is selected to " + 
          "be followed by the camera. This allows you to change to any particles' center of mass reference frame, " + 
          "and see the how imaginary forces appear, or watch how a planet orbiting a star sees the orbits of other planets.", x, y, wt, ht);

      for (int i = 0; i < (exampleId == 3 ? 20 : 1); i++) {
        examplesEnv.getIntegrator().forward();
        examplesEnv.getCollider().runCollisions();
        examplesEnv.getBoundaries().constrain();
        if (exampleId == 4)
          examplesEnv.moveOrigin(examplesEnv.getParticles().get(0).getPos().copy());
      }

      examplesEnv.getVisualizer().showJoints().show();
      examplesEnv.getBoundaries().show(color(255, 150, 150));
      for (checkBox.CheckBox cb : examplesCbs) cb.show();
    }

    pop();
    for (checkBox.CheckBox cb : instrCbs) cb.show();
  }
  void setExample(int index) {
    examplesEnv.clear().clearInteractions().clearExternals().clearJoints().getIntegrator().setDt(0.01);
    examplesEnv.getBoundaries().setConstrainDim(780, 780).setConstrainPos(0, 0);
    if (index == 0) {
      PVector bound = PVector.div(examplesEnv.getBoundaries().getConstrainDim(), 2);
      int n = 10;
      for (int i = 0; i < n; i++) {
        Particle p = Particle.still(main, random( - bound.x, bound.x), random( - bound.y, bound.y), 1, 5, 10);
        p.getVisualizer().trail();
        color col = color(random(0, 255), random(0, 255), random(0, 255));
        examplesEnv.add(p.setColor(col));
      }
      Interaction rep = new Interaction() {
        @Override public PVector acceleration(Particle p1, Particle p2) {
          float cte = 150, mag = cte * p1.getCharge() * p2.getCharge() / (p2.getMass() * pow(p1.getPos().dist(p2.getPos()), 2));
          return PVector.sub(p2.getPos(), p1.getPos()).setMag(mag);
        }
      };
      Interaction att = new Interaction() {
        @Override public PVector acceleration(Particle p1, Particle p2) {
          float cte = 1, mag = p1.getCharge() * p2.getCharge() / (p2.getMass() * p1.getPos().dist(p2.getPos()));
          return PVector.sub(p1.getPos(), p2.getPos()).setMag(mag);
        }
      };
      ExternalForce drag = new ExternalForce() {
        @Override public PVector acceleration(Particle p) {
          float cte = 0.5;
          return PVector.mult(p.getVel(), - cte);
        }
      };
      examplesEnv.add(rep).add(att).add(drag).implementAll();
    } else if (index == 1) {
      Particle center = Particle.atZeroStill(main, 100, 0, 20).setDynamic(false).setColor(color(180, 255, 180));
      Particle p1 = new Particle(main, 100, 0, 0, 500, .6, 0, 10).setColor(color(180, 180, 255));
      Particle p2 = new Particle(main, - 300, 0, 0, -250, .6, 0, 10).setColor(color(100, 180, 180));
      Particle p3 = new Particle(main, 310, 0, 0, 320, .6, 0, 10).setColor(color(255, 255, 120));
      p1.getVisualizer().setTrailCapacity(200).trail();
      p2.getVisualizer().setTrailCapacity(200).trail();
      p3.getVisualizer().setTrailCapacity(200).trail();

      Interaction gravitation = new Interaction() {
        @Override public PVector acceleration(Particle p1, Particle p2) {
          float cte = 10, mag = cte * p1.getMass() / pow(p1.getPos().dist(p2.getPos()), 2);
          return PVector.sub(p1.getPos(), p2.getPos()).setMag(mag);
        }
      };

      examplesEnv.add(center).add(p1).add(p2).add(p3).add(gravitation).implementAll();
    } else if (index == 2) {
      int n = 10;
      float r = 10;
      for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++) {
          float x = - r * n + 2 * r * i, y = - r * n + 2 * r * j;
          examplesEnv.add(Particle.still(main, x, y, 1, 1, r).setColor(color(100, 255, 255)));
        }
      examplesEnv.add(new Particle(main, 150, -100, -400, 150, 1, 1, 10).setColor(color(150, 255, 150)));
    } else if (index == 3) {
      SoftBody sb = new SoftBody(main, 10, 10, 1, 1, 1, 10).setMass(1).setColor(color(255, 255, 180));
      float len = 200;
      sb.setVertex("LBD", -len, -len).setVertex("RBD", len, -len).setVertex("LTD", -len, len).setVertex("RTD", len, len).setCrossJoints(true);
      sb.init().locateAsVertices().setStiffness(100).setDampening(0.0001);

      ExternalForce grav = new ExternalForce() {
        @Override public PVector acceleration(Particle p) {
          return new PVector(0, -1000);
        }
      };
      examplesEnv.add(sb).add(grav).implementAll();
      int rand = 10;
      for (int i = 0; i < rand; i++)
        examplesEnv.getParticles().get(floor(random(100))).setVel(1000, 10000);
      examplesEnv.getIntegrator().setDt(0.0005);
    } else if (index == 4) {
      PVector bound = PVector.div(examplesEnv.getBoundaries().getConstrainDim(), 2);
      int n = 50;
      for (int i = 0; i < n; i++) {
        Particle p = new Particle(main, random( - bound.x, bound.x), random( - bound.y, bound.y), random( - 500, 500), random( - 500, 500), 1, 5, 10);
        color col = color(100, 255, 255);
        examplesEnv.add(p.setColor(col));
      }
      examplesEnv.getParticles().get(0).setColor(color(255, 255, 100));
    }
  }

  void hideCb() {
    for (int i = 0; i < globalShowToggles.length; i++) globalShowToggles[i] = false;
  }
  void hideSl() {
    for (ControlP5 cp5 : cps) cp5.hide();
  }
  void showCb(int index) {
    globalShowToggles[index] = true;
  }
  void showSl(int index) {
    cps[index].show();
  }
  void hide() {
    hideCb();
    hideSl();
  }
  void show(int index) {
    showCb(index);
    showSl(index);
  }
  boolean anyShowToggle() {
    for (int i = 0; i < globalShowToggles.length; i++)
      if (globalShowToggles[i])
        return true;
    return false;
  }
  void groupRoutine(String group) {
    if (!isPressingControl())
      return;

    List<Particle> pts = ENV.getGroup(group);
    if (ENV.getSelected().isEmpty()) {
      boolean allContained = !ENV.getParticles().isEmpty();
      for (Particle p : ENV.getParticles()) 
        if (!pts.contains(p)) {
          allContained = false; 
          break;
        }
      if (allContained) pts.clear();
      else for (Particle p : ENV.getParticles()) if (!pts.contains(p)) pts.add(p);
    } else {
      boolean allContained = true;
      for (Particle p : ENV.getSelected())
        if (!pts.contains(p)) {
          allContained = false;
          break;
        }
      if (allContained) for (Particle p : ENV.getSelected()) pts.remove(p);
      else for (Particle p : ENV.getSelected()) if (!pts.contains(p)) pts.add(p);
    }
  }
  void interRoutine(Interaction inter) {
    if (!isPressingControl())
      inter.includeInAddition(!inter.includedInAddition());
    else if (ENV.getSelected().isEmpty()) {
      boolean allContained = !ENV.getParticles().isEmpty();
      for (Particle p : ENV.getParticles()) 
        if (!p.isIn(inter)) {
          allContained = false; 
          break;
        }
      if (allContained) ENV.neglect(inter);
      else for (Particle p : ENV.getParticles()) if (!p.isIn(inter)) Environment.implement(p, inter);
    } else {
      boolean allContained = true;
      for (Particle p : ENV.getSelected())
        if (!p.isIn(inter)) {
          allContained = false;
          break;
        }
      if (allContained)
        Environment.neglect(ENV.getSelected(), inter);
      else
        Environment.implement(ENV.getSelected(), inter);
    }
  }
  void extRoutine(ExternalForce ext) {
    if (!isPressingControl())
      ext.includeInAddition(!ext.includedInAddition());
    else if (ENV.getSelected().isEmpty()) {
      boolean allContained = !ENV.getParticles().isEmpty();
      for (Particle p : ENV.getParticles()) 
        if (!p.isIn(ext)) {
          allContained = false; 
          break;
        }
      if (allContained) ENV.neglect(ext);
      else for (Particle p : ENV.getParticles()) if (!p.isIn(ext)) Environment.implement(p, ext);
    } else {
      boolean allContained = true;
      for (Particle p : ENV.getSelected())
        if (!p.isIn(ext)) {
          allContained = false;
          break;
        }
      if (allContained)
        Environment.neglect(ENV.getSelected(), ext);
      else
        Environment.implement(ENV.getSelected(), ext);
    }
  }

  void resetModes() {
    for (int i = 0; i < modes.length; i++) modes[i] = false;
  }
  void resetPlotQts() {
    for (int i = 0; i < plotQts.length; i++) plotQts[i] = false;
  }
  void resetInstrToggles() {
    for (int i = 0; i < instrToggles.length; i++) instrToggles[i] = false;
  }
  void resetShapesPrev() {
    for (int i = 0; i < shapesPrev.length; i++) shapesPrev[i] = false;
  }
  void resetToggleCustoms() {
    for (int i = 0; i < toggleCustoms.length; i++) toggleCustoms[i] = false;
  }
  boolean anyQts() {
    for (int i = 0; i < plotQts.length; i++) if (plotQts[i]) return true; 
    return false;
  }
  boolean anyInstr() {
    for (int i = 0; i < instrToggles.length; i++) if (instrToggles[i]) return true; 
    return false;
  }
  boolean anyCustoms() {
    for (int i = 0; i < toggleCustoms.length; i++) if (toggleCustoms[i]) return true;
    return false;
  }
  boolean anyPlaying() {
    for (int i = 0; i < isPlaying.length; i++) if (isPlaying[i]) return true;
    return false;
  }
  int indexPlaying() {
    for (int i = 0; i < isPlaying.length; i++) if (isPlaying[i]) return i;
    return - 1;
  }
  int indexCustoms() {
    for (int i = 0; i < toggleCustoms.length; i++) if (toggleCustoms[i]) return i;
    return - 1;
  }

  void updateSystemLengthUnit() {
    String prevLenUnit = ENV.getUnits().getLengthUnit();
    Units.setParticlesLengthUnit(ENV.getCustoms().getPts(), prevLenUnit, envUnits[0]);
    ENV.getUnits().setLengthUnit(envUnits[0]);
    //softBodyEnv.getUnits().setLengthUnit(envUnits[0]);
    selFacts[0] = ENV.getUnits().getLengthFactor(selUnits[0]);
    dispFacts[0] = ENV.getUnits().getLengthFactor(dispUnits[0]);
    dispFacts[4] = ENV.getUnits().getVelFactor(dispUnits[4], dispUnits[5]);
    dispFacts[5] = ENV.getUnits().getEnergyFactor("m", "s", "kg") / energyUnits.get(dispUnits[6]);
    dispFacts[6] = ENV.getUnits().getMomentumFactor("m", "s", "kg") / momentumUnits.get(dispUnits[7]);
    dispFacts[7] = ENV.getUnits().getAngularMomentumFactor("m", "s", "kg") / angularUnits.get(dispUnits[8]);
  }
  void updateSystemTimeUnit() {
    String prevTimeUnit = ENV.getUnits().getTimeUnit();
    Units.setParticlesTimeUnit(ENV.getCustoms().getPts(), prevTimeUnit, envUnits[1]);
    ENV.getUnits().setTimeUnit(envUnits[1]);
    softBodyEnv.getUnits().setTimeUnit(envUnits[1]);
    selFacts[1] = ENV.getUnits().getTimeFactor(selUnits[1]);
    dispFacts[1] = ENV.getUnits().getTimeFactor(dispUnits[1]);
    dispFacts[4] = ENV.getUnits().getVelFactor(dispUnits[4], dispUnits[5]);
    dispFacts[5] = ENV.getUnits().getEnergyFactor("m", "s", "kg") / energyUnits.get(dispUnits[6]);
    dispFacts[6] = ENV.getUnits().getMomentumFactor("m", "s", "kg") / momentumUnits.get(dispUnits[7]);
    dispFacts[7] = ENV.getUnits().getAngularMomentumFactor("m", "s", "kg") / angularUnits.get(dispUnits[8]);
  }

  boolean constrain() {
    return generalToggles[0];
  }
  boolean addStatic() {
    return generalToggles[1];
  }
  boolean drawLimits() {
    return generalToggles[2];
  }
  boolean collisions() {
    return generalToggles[3];
  }
  boolean merge() {
    return mergeCb.isDone();
  }
}
