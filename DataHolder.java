import tensors.Float.*;
import spdsim.*;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.ObjectOutputStream;
import java.io.ObjectInputStream;
import java.io.Serializable;
import processing.core.*;

class DataHolder implements Serializable {

  int bCount, pCount, rCount;
  BackupSet backups;
  RecordingSet recordings;

  DataHolder() {
    bCount = 12;
    rCount = 12;
    pCount = 8;
    backups = new BackupSet(bCount);
    recordings = new RecordingSet(rCount);
  }
  void save(PApplet sketch) {
    try {
      FileOutputStream fileOut = new FileOutputStream(new File(sketch.dataPath("saves/save.txt")));
      ObjectOutputStream objectOut = new ObjectOutputStream(fileOut);

      objectOut.writeObject(this);

      objectOut.close();
      fileOut.close();
    } 
    catch (FileNotFoundException e) {
      throw new RuntimeException(e);
    } 
    catch (IOException e) {
      throw new RuntimeException(e);
    }
  }
  static DataHolder load(PApplet sketch) {
    try {
      FileInputStream fileIn = new FileInputStream(new File(sketch.dataPath("saves/save.txt")));
      ObjectInputStream objectIn = new ObjectInputStream(fileIn);

      DataHolder result = (DataHolder) objectIn.readObject();

      objectIn.close();
      fileIn.close();

      return result;
    } 
    catch (FileNotFoundException e) {
      throw new RuntimeException(e);
    } 
    catch (IOException e) {
      throw new RuntimeException(e);
    } 
    catch (ClassNotFoundException e) {
      throw new RuntimeException(e);
    }
  }
  void removeAllCopies(Environment ENV) {
    for (String name1 : backups.getPMData().keySet()) {
      EnvHolder MH = backups.getPMData().get(name1);
      for (Particle p : MH.getParticles())
        p.removeCopies();
      for (List<Particle> pts : MH.getInterLists())
        for (Particle p : pts)
          p.removeCopies();
      for (List<Particle> pts : MH.getExtsLists())
        for (Particle p : pts)
          p.removeCopies();
      for (Spring s : MH.getJoints()) {
        s.getFirst().removeCopies();
        s.getSecond().removeCopies();
      }
      for (String name2 : ENV.getGroups().keySet())
        for (Particle p : ENV.getGroups().get(name2))
          p.removeCopies();
      for (String name2 : ENV.getParticulars().keySet())
        ENV.getParticulars().get(name2).removeCopies();
    }
  }
  int getBCount() {
    return bCount;
  }
  int getPCount() {
    return pCount;
  }
  int getRCount() {
    return rCount;
  }
  BackupSet getBackups() {
    return backups;
  }
  RecordingSet getRecordings() {
    return recordings;
  }
}
