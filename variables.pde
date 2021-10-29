//Global
BigEnv ENV;
PApplet main = this;
Tweaks TW;
Plots plots;
PrintWriter outputPos, outputVel, outputEnergy;
PImage simScreenshot;
PFont font;
PVector mousePos;

boolean[] modes = new boolean[2]; //addSb, select
boolean[] keys = new boolean[14]; //control, shift, backspace, r, c, spacebar, q, b, e, up, down, left, right, f
boolean[] keysDigits = new boolean[12];
boolean run, settings, drawMouseCoords;
String[] globalNames;
String prompt = "";
int promptLifeSpan = 120, promptLife = 120;

int indexGlobal, indexModes, indexCustoms;
float time = 0;
private static final Object lock = new Object();

//Movie
int movieSpeed, movieFrame;
boolean pausedMovie, reversedMovie;
String prevLenUnit;
Environment movieEnv;

//General
transient Interaction elRep, elAt, exp, gravit;
transient ExternalForce grav, drag;

int[] ctePots;
float md, cd, rd, ptR, ptG, ptB;
float elRepCte, elAtCte, expCte1, expCte2, gravitCte, gravCte, dragCte;
int addBunch, trailsCap, trailsLen;
int expRep = 2, expAt = 1, expVel = 1;
boolean dynBox, showOrigin, drawTrailsOnAddition, drawPathOnAddition;
boolean isMDens, isCDens;

float minPlot, maxPlot;
int ptsPlot;

//SoftBodies
SoftBody toBeAdded;
int[] valSbPots;
int terms, decay, wdth = 10, hght = 1, wMult = 1, hMult = 1;
float mdSb, cdSb, rdSb, stiffness, sbR, sbG, sbB, damp;
boolean crJoints = true, autoAdjustEq = true, relFixed = true, isSbMDens, isSbCDens, showPrevSb;

//Selected
boolean[] plotQts;
int vecDetail, contDetail, contVals, plotMemory, batches;
float minEdge, maxEdge, accelMin, accelMax;
boolean showDataOnAddition, showDistOnAddition, followCMOnAddition, drawAFOnAddition, drawCLOnAddition, 
  showPrev, hist, qtsOnAddition, XY, wasDynamic;

//Integration
boolean[] isPlaying;
float dpLen, mVel, elasticity, glide, timestep;
int intPerFrame, dtExp, dpDtExp, timesteps, dataSetCount, frames, runTimingCounter;
boolean pause, forward = true, isRunTiming, interpolPP, interpolB, adaptToFramerate;

//Data
boolean saveFrames, saveDataOnAddition, doneSaveData = true;

//Shapes
boolean[] shapesPrev;
int rings, nPts;
float sqSep, radShape;

//Units
String[] envUnits, selUnits, dispUnits;
float[] selFacts, dispFacts;
Map<String, Float> energyUnits = new LinkedHashMap<String, Float>();
Map<String, Float> momentumUnits = new LinkedHashMap<String, Float>();
Map<String, Float> angularUnits = new LinkedHashMap<String, Float>();

void replenishMap() {
  energyUnits.put("J", 1.0);
  energyUnits.put("meV", 1.602e-22);
  energyUnits.put("eV", 1.602e-19);
  energyUnits.put("keV", 1.602e-16);
  energyUnits.put("MeV", 1.602e-13);
  energyUnits.put("GeV", 1.602e-9);
  energyUnits.put("TeV", 1.602e-6);
  energyUnits.put("nJ", 1e-9);
  energyUnits.put("uJ", 1e-6);
  energyUnits.put("mJ", 1e-3);
  energyUnits.put("kJ", 1e3);
  energyUnits.put("MJ", 1e6);
  energyUnits.put("GJ", 1e9);
  energyUnits.put("TJ", 1e12);

  momentumUnits.put("N*s", 1.0);
  momentumUnits.put("meV/c", 5.343e-31);
  momentumUnits.put("eV/c", 5.343e-25);
  momentumUnits.put("keV/c", 5.343e-22);
  momentumUnits.put("MeV/c", 5.343e-19);
  momentumUnits.put("GeV/c", 5.343e-16);
  momentumUnits.put("TeV/c", 5.343e-13);
  momentumUnits.put("nN*s", 1e-9);
  momentumUnits.put("uN*s", 1e-6);
  momentumUnits.put("mN*s", 1e-3);
  momentumUnits.put("kN*s", 1e3);
  momentumUnits.put("MN*s", 1e6);
  momentumUnits.put("GN*s", 1e9);
  momentumUnits.put("TN*s", 1e12);

  angularUnits.put("J*s", 1.0);
  angularUnits.put("mhbar", 1.054e-37);
  angularUnits.put("hbar", 1.054e-34);
  angularUnits.put("khbar", 1.054e-31);
  angularUnits.put("Mhbar", 1.054e-28);
  angularUnits.put("Ghbar", 1.054e-25);
  angularUnits.put("Thbar", 1.054e-22);
  angularUnits.put("nJ*s", 1e-9);
  angularUnits.put("uJ*s", 1e-6);
  angularUnits.put("mJ*s", 1e-3);
  angularUnits.put("kJ*s", 1e3);
  angularUnits.put("MJ*s", 1e6);
  angularUnits.put("GJ*s", 1e9);
  angularUnits.put("TJ*s", 1e12);
}
List<String> getEnergyUnits() {
  return new ArrayList<String>(energyUnits.keySet());
}
List<String> getMomentumUnits() {
  return new ArrayList<String>(momentumUnits.keySet());
}
List<String> getAngularUnits() {
  return new ArrayList<String>(angularUnits.keySet());
}
