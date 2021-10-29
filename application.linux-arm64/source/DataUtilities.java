import tensors.Float.*;
import spdsim.*;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.io.Serializable;
import processing.core.PApplet;
import processing.core.PVector;
import controlP5.*;

class BackupSet implements Serializable {

  int count;
  boolean[] prev;
  Map<String, float[][]> ctes;
  Map<String, String[][]> units;
  Map<String, EnvHolder> PMData;
  Map<String, CustomParticles> customsList;

  BackupSet(int count) {
    this.count = count;
    prev = new boolean[count];
    ctes = new HashMap<String, float[][]>();
    units = new HashMap<String, String[][]>();
    PMData = new HashMap<String, EnvHolder>();
    customsList = new HashMap<String, CustomParticles>();
  }

  void setParent(PApplet sketch) {
    for (String name : PMData.keySet())
      for (Particle p : PMData.get(name).getParticles())
        p.getVisualizer().setParent(sketch);
  }

  static void upload(int index, DataHolder DH, ControlP5 cp, int expRep, int expAt, int expVel, int[] ctePots, String[] sel, String[] disp) {
    String[] names = new String[] {"elRepCte", "elAtCte", "expCte1", "expCte2", "gravitCte", "gravCte", "dragCte"};
    float[][] ctes = new float[2][];
    ctes[0] = new float[names.length + 3];
    ctes[1] = new float[ctePots.length];

    for (int i = 0; i < names.length; i++) ctes[0][i] = cp.getController(names[i]).getValue();
    for (int i = 0; i < ctePots.length; i++) ctes[1][i] = ctePots[i];
    ctes[0][names.length + 0] = expRep;
    ctes[0][names.length + 1] = expAt;
    ctes[0][names.length + 2] = expVel;
    DH.getBackups().getCtes().put(Integer.toString(index), ctes);

    String[][] units = new String[2][];
    units[0] = new String[sel.length];
    units[1] = new String[disp.length];
    for (int i = 0; i < sel.length; i++) units[0][i] = sel[i];
    for (int i = 0; i < disp.length; i++) units[1][i] = disp[i];
    DH.getBackups().getUnits().put(Integer.toString(index), units);
  }
  static void download(int index, DataHolder DH, Environment ENV, String[] env, String[] sel, String[] disp) {
    env[0] = ENV.getUnits().getLengthUnit();
    env[1] = ENV.getUnits().getTimeUnit();

    String[][] toLoad = DH.getBackups().getUnits().get(Integer.toString(index));
    for (int i = 0; i < toLoad[0].length; i++)
      sel[i] = toLoad[0][i];
    for (int i = 0; i < toLoad[1].length; i++)
      disp[i] = toLoad[1][i];
  }
  static void downloadConstants(int index, DataHolder DH, ControlP5 cp, int[] ctePots, int[] exps) {
    String[] names = new String[] {"elRepCte", "elAtCte", "expCte1", "expCte2", "gravitCte", "gravCte", "dragCte"};

    float[][] toLoad = DH.getBackups().getCtes().get(Integer.toString(index));
    for (int i = 0; i < names.length; i++)
      cp.getController(names[i]).setValue(toLoad[0][i]);
    exps[0] = (int) toLoad[0][names.length + 0];
    exps[1] = (int) toLoad[0][names.length + 1];
    exps[2] = (int) toLoad[0][names.length + 2];

    for (int i = 0; i < names.length; i++)
      ctePots[i] = (int) toLoad[1][i];
  }

  int getCount() {
    return count;
  }
  boolean[] getPrevToggles() {
    return prev;
  }
  Map<String, float[][]> getCtes() {
    return ctes;
  }
  Map<String, String[][]> getUnits() {
    return units;
  }
  Map<String, EnvHolder> getPMData() {
    return PMData;
  }
  Map<String, CustomParticles> getCustoms() {
    return customsList;
  }
}
class RecordingSet implements Serializable {

  int count;
  boolean[] isRec;
  Map<String, Particle[]> actors;
  Map<String, Map<int[], Integer>> attachments;
  Map<String, Map<Integer, String[]>> unitTracker;
  Map<String, String[]> startingUnits;
  Map<String, PVector> translates;
  Map<String, Float> scales;

  RecordingSet(int count) {
    this.count = count;
    isRec = new boolean[count];
    actors = new HashMap<String, Particle[]>();
    attachments = new HashMap<String, Map<int[], Integer>>();
    unitTracker = new LinkedHashMap<String, Map<Integer, String[]>>();
    startingUnits = new HashMap<String, String[]>();
    translates = new HashMap<String, PVector>();
    scales = new HashMap<String, Float>();
  }
  void attach(int index, int a, int b) {
    
    Map<int[], Integer> attachment = attachments.get(Integer.toString(index));
    attachment.put(new int[] {a}, b);
  }
  void trackUnit(int index, int frame, String[] unit) {
    unitTracker.get(Integer.toString(index)).put(frame, unit);
  }
  void setStartingUnit(int index, String[] unit) {
    startingUnits.put(Integer.toString(index), unit);
  }
    
  void setParent(PApplet sketch) {
    for (String name : actors.keySet())
      for (Particle p : actors.get(name))
        p.getVisualizer().setParent(sketch);
  }

  boolean anyRec() {
    for (int i = 0; i < isRec.length; i++) if (isRec[i]) return true;
    return false;
  }
  int indexRec() {
    for (int i = 0; i < isRec.length; i++) if (isRec[i]) return i;
    return -1;
  }
  int getCount() {
    return count;
  }
  boolean[] getIsRec() {
    return isRec;
  }
  Map<String, Particle[]> getActors() {
    return actors;
  }
  String[] getStartingUnits(int index) {
   return startingUnits.get(Integer.toString(index)); 
  }
  Map<String, Map<int[], Integer>> getAttachments() {
    return attachments;
  }
  Map<String, Map<Integer, String[]>> getUnitTracker() {
    return unitTracker;
  }
  Map<String, PVector> getTranslates() {
   return translates; 
  }
  Map<String, Float> getScales() {
   return scales; 
  }
}

class CustomParticles implements Serializable {

  List<Particle> particles;
  CustomParticles(int count) {
    particles = new ArrayList<Particle>(count);
  }
  void setParent(PApplet sketch) {
    for (Particle p : particles)
      p.getVisualizer().setParent(sketch);
  }

  static void upload(int index, DataHolder DH, CustomParticles customs) {
    DH.getBackups().getCustoms().put(Integer.toString(index), new CustomParticles(DH.getPCount()));
    for (Particle p : customs.getPts())
      DH.getBackups().getCustoms().get(Integer.toString(index)).getPts().add(p.blindCopy());
  }
  static void download(int index, DataHolder DH, CustomParticles customs) {
    customs.getPts().clear();
    for (Particle p : DH.getBackups().getCustoms().get(Integer.toString(index)).getPts())
      customs.getPts().add(p.blindCopy());
  }

  List<Particle> getPts() {
    return particles;
  }
}
