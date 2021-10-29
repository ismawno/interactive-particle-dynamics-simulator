import tensors.Float.*;
import spdsim.*;
import controlP5.*;
import checkBox.*;
import grafica.*;
import java.io.File;
import java.util.List;
import java.util.Map;
import java.util.LinkedHashMap; 

void settings() {
  fullScreen();
}

void setup() {
  ENV = new BigEnv(this);
  ENV.setDim(Environment.DIMENSION.TWO).getVisualizer().setTranslate(width / 2, height / 2);
  implementForces();
  ENV.setGroup("showData").setGroup("showDist").setGroup("focus").setGroup("saveData");
  ENV.setGroup("accelField").setGroup("contLines").setGroup("quantities").setGroup("trails").setGroup("drawPath");

  new File(dataPath("")).mkdir();
  new File(dataPath("saves")).mkdir();

  TW = new Tweaks();
  int ratio = 100;
  TW.scalingX = width / (16.0 * ratio);
  TW.scalingY = height / (9.0 * ratio);
  TW.initialize();
}
void draw() {
  background(0);
  updateTimestep();

  if (settings)
    whileRunningSettingsWindow();
  else {
    whileRunningSimulation();

    if (isAddingParticle())
      whileParticleAddition();

    if (isAddingSoftBody())
      whileSoftBodyAddition();

    if (isControlling() && isPressingShift() && !isReleasing())
      whileControlling();

    if (isReleasing())
      whileReleasing();
  }
  
  TW.showSwitch();
}
