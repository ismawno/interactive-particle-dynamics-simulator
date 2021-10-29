class BigEnv extends Environment {

  BackupSet backups;
  CustomParticles customs;

  DataHolder DH;

  BigEnv(PApplet sketch) {
    super(sketch);
    retrieveData();
  }
  void retrieveData() {
    if (new File(dataPath("saves/save.txt")).exists()) {
      DH = load(main);

      DH.getBackups().setParent(main);
      DH.getRecordings().setParent(main);
      for (String name : DH.getBackups().getCustoms().keySet())
        DH.getBackups().getCustoms().get(name).setParent(main);
    } else DH = new DataHolder();

    setBackups(DH.getBackups().getPMData());

    backups = new BackupSet(DH.getBCount());
    customs = new CustomParticles(DH.getPCount());
  }
  void saveEnv(int index) {
    super.saveEnv(Integer.toString(index));

    BackupSet.upload(index, DH, TW.genCp, expRep, expAt, expVel, ctePots, selUnits, dispUnits);
    CustomParticles.upload(index, DH, customs);    
  }
  void loadEnv(int index) {
    super.loadEnv(Integer.toString(index));

    CustomParticles.download(index, DH, customs);
    BackupSet.download(index, DH, this, envUnits, selUnits, dispUnits);

    TW.updateSystemLengthUnit();
    TW.updateSystemTimeUnit();
    
    TW.resetToggleCustoms(); 
  }
  void loadConstants(int index) {
    int[] exps = new int[3];
    BackupSet.downloadConstants(index, DH, TW.genCp, ctePots, exps);
    expRep = exps[0];
    expAt = exps[1];
    expVel = exps[2];
  }

  void exportRecordsToTxt(PApplet sketch) {
    for (String name : DH.getRecordings().getActors().keySet()) {
      Particle[] recording = DH.getRecordings().getActors().get(name);

      //new File(sketch.dataPath("saves/rec_mem" + name + ".txt")).delete();
      PrintWriter recMem = sketch.createWriter(sketch.dataPath("saves/rec_mem" + name + ".txt"));
      for (Particle p : recording) {
        String x = "", y = "", vx = "", vy = "", e = "";
        for (PVector pos : p.getRecord().getPositions()) {
          x += pos.x + ",";
          y += pos.y + ",";
        }
        for (PVector vel : p.getRecord().getVelocities()) {
          vx += vel.x + ",";
          vy += vel.y + ",";
        }
        for (Float E : p.getRecord().getEnergies())
          e += E.floatValue() + ",";
        recMem.println(x);
        recMem.println(y);
        recMem.println(vx);
        recMem.println(vy);
        recMem.println(e);
        p.getRecord().clear();
      }
      recMem.flush();
      recMem.close();
    }
  }
  void importRecordsFromTxt(PApplet sketch, DataHolder DH) {
    for (String name : DH.getRecordings().getActors().keySet()) {
      Particle[] record = DH.getRecordings().getActors().get(name);

      String[] data = loadStrings(sketch.dataPath("saves/rec_mem" + name + ".txt"));
      for (int i = 0; i < data.length; i += 5) {
        Particle p = record[i / 5];
        String[] x = split(data[i + 0], ',');
        String[] y = split(data[i + 1], ',');
        String[] vx = split(data[i + 2], ',');
        String[] vy = split(data[i + 3], ',');
        String[] e = split(data[i + 4], ',');
        for (int j = 0; j < x.length - 1; j++) {
          p.getRecord().getPositions().add(new PVector(Float.parseFloat(x[j]), Float.parseFloat(y[j])));
          p.getRecord().getVelocities().add(new PVector(Float.parseFloat(vx[j]), Float.parseFloat(vy[j])));
          p.getRecord().getEnergies().add(Float.parseFloat(e[j]));
        }
      }
    }
  }
  void save(PApplet sketch) {
    //DH.removeAllCopies(this);
    exportRecordsToTxt(sketch);
    DH.save(sketch);
  }
  DataHolder load(PApplet sketch) {
    DataHolder DH = DataHolder.load(sketch);
    if (DH.getRecordings().getActors().isEmpty()) return DH;

    importRecordsFromTxt(sketch, DH);
    return DH;
  }

  void removeBackup(int index) {
    super.removeBackup(Integer.toString(index));
    backups.getPrevToggles()[index] = false;
    DH.getBackups().getCustoms().remove(Integer.toString(index));
  }
  void removeRecording(int index) {
    DH.getRecordings().getActors().remove(Integer.toString(index));
    DH.getRecordings().getIsRec()[index] = false;
  }
  void startRecording(int index) {
    
    DH.getRecordings().getIsRec()[index] = true;
    DH.getRecordings().getAttachments().put(Integer.toString(index), new HashMap<int[], Integer>());
    DH.getRecordings().getUnitTracker().put(Integer.toString(index), new HashMap<Integer, String[]>());
    DH.getRecordings().setStartingUnit(index, new String[]{getUnits().getLengthUnit(), getUnits().getTimeUnit()});
    DH.getRecordings().getTranslates().put(Integer.toString(index), getVisualizer().getTranslate().copy());
    DH.getRecordings().getScales().put(Integer.toString(index), getVisualizer().getScaling());

    Particle[] record = new Particle[getParticles().size()];
    for (int i = 0; i < record.length; i++) {
      Particle p1 = getParticles().get(i);
      record[i] = p1;
    }
    for (Spring s : getJoints())
        DH.getRecordings().attach(index, getParticles().indexOf(s.getFirst()), getParticles().indexOf(s.getSecond()));
    DH.getRecordings().getActors().put(Integer.toString(index), record);
  }
  void stopRecording() {
    for (int i = 0; i < DH.getRecordings().getIsRec().length; i++)
      if (DH.getRecordings().getIsRec()[i]) {
        if (isRecordingEmpty(i)) removeRecording(i);
        else
          for (int j = 0; j < getRecording(i).length; j++)
            getRecording(i)[j] = getRecording(i)[j].blindCopy();
        DH.getRecordings().getIsRec()[i] = false;
        clearRecords();
        break;
      }
  }
  Particle[] getRecording(int index) {
    return DH.getRecordings().getActors().get(Integer.toString(index));
  }
  boolean hasBackup(int index) {
    return super.hasBackup(Integer.toString(index));
  }
  boolean hasRecording(int index) {
    return DH.getRecordings().getActors().containsKey(Integer.toString(index));
  }
  boolean isRecordingEmpty(int index) {
    return DH.getRecordings().getActors().get(Integer.toString(index))[0].getRecord().getPositions().isEmpty();
  }
  boolean overlaps() {
    for (int i = 0; i < getParticles().size(); i++)
      for (int j = i + 1; j < getParticles().size(); j++) {
        Particle p1 = getParticles().get(i), p2 = getParticles().get(j);
        if (p1.overlaps(p2)) return true;
      }
    return false;
  }
  void resetBckpPrev() {
    for (int i = 0; i < backups.getPrevToggles().length; i++) backups.getPrevToggles()[i] = false;
  }

  EnvHolder getBackup(int index) {
    return super.getBackup(Integer.toString(index));
  }
  int getBackupCount() {
    return backups.getCount();
  }
  int getRecCount() {
    return DH.getRecordings().getCount();
  }
  int getFrameCount(int index) {
    return DH.getRecordings().getActors().get(Integer.toString(index))[0].getRecord().getPositions().size();
  }
  boolean[] getBckpPrev() {
    return backups.getPrevToggles();
  }
  boolean[] getIsRec() {
    return DH.getRecordings().getIsRec();
  }
  boolean anyRec() {
    return DH.getRecordings().anyRec();
  }
  int indexRec() {
    return DH.getRecordings().indexRec();
  }
  DataHolder getData() {
    return DH;
  }
  CustomParticles getCustoms() {
    return customs;
  }
  RecordingSet getRecordings() {
    return DH.getRecordings();
  }
}
