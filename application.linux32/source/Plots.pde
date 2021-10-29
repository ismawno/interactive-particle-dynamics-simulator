class Plots {

  PApplet sketch;
  GPlot generalPlot, selectedPlot, selectedHist, selectedXY;
  GLayer[] selectedLayers;

  List<float[]> records;
  Plots(PApplet sketch) {
    this.sketch = sketch;
    records = new ArrayList<float[]>(plotMemory);

    float xg = 950 * TW.scalingX, yg = 0, wg = sketch.width - xg, hg = 555 * TW.scalingY;
    float xs = 900 * TW.scalingX, ys = 0, ws = sketch.width - xs, hs = 555 * TW.scalingY;
    generalPlot = new GPlot(sketch, xg, yg, wg, hg);
    selectedPlot = new GPlot(sketch, xs, ys, ws, hs);
    selectedHist = new GPlot(sketch, xs, ys, ws, hs);
    selectedXY = new GPlot(sketch, xs, ys, ws, hs);
    selectedHist.startHistograms(GPlot.VERTICAL);

    generalPlot.getTitle().setText("Potential of the interaction vs distance to particle (display units)");
    generalPlot.getXAxis().getAxisLabel().setText("Distance");
    generalPlot.getYAxis().getAxisLabel().setText("Potential");

    selectedPlot.getTitle().setText("Selected quantities vs elapsed time (display units)");
    selectedPlot.getXAxis().getAxisLabel().setText("Time");
    selectedPlot.getYAxis().getAxisLabel().setText("Quantity");

    selectedHist.getTitle().setText("Distribution plot: Number of particles vs selected quantity (display units)");
    selectedHist.getXAxis().getAxisLabel().setText("Quantity");
    selectedHist.getYAxis().getAxisLabel().setText("Particles");

    selectedXY.getTitle().setText("Position plot: Tracking of the particle's x & y coordinates (display units)");
    selectedXY.getXAxis().getAxisLabel().setText("X");
    selectedXY.getYAxis().getAxisLabel().setText("Y");

    GPointsArray pts = new GPointsArray();
    selectedPlot.addLayer("Energy", pts);
    selectedPlot.addLayer("KEnergy", pts);
    selectedPlot.addLayer("PEnergy", pts);
    selectedPlot.addLayer("Momentum", pts);
    selectedPlot.addLayer("AMomentum", pts);
    selectedPlot.addLayer("Distance", pts);
    selectedLayers = new GLayer[] {selectedPlot.getLayer("Energy"), selectedPlot.getLayer("KEnergy"), selectedPlot.getLayer("PEnergy"), 
      selectedPlot.getLayer("Momentum"), selectedPlot.getLayer("AMomentum"), selectedPlot.getLayer("Distance")};

    selectedPlot.getLayer("Energy").setLineColor(color(150, 0, 255));
    selectedPlot.getLayer("Energy").setPointColor(color(150, 0, 255));
    selectedPlot.getLayer("Energy").setPointSize(1);
    selectedPlot.getLayer("Energy").setLineWidth(2);

    selectedPlot.getLayer("KEnergy").setLineColor(color(255, 0, 0));
    selectedPlot.getLayer("KEnergy").setPointColor(color(255, 0, 0));
    selectedPlot.getLayer("KEnergy").setPointSize(1);
    selectedPlot.getLayer("KEnergy").setLineWidth(2);

    selectedPlot.getLayer("PEnergy").setLineColor(color(0, 0, 255));
    selectedPlot.getLayer("PEnergy").setPointColor(color(0, 0, 255));
    selectedPlot.getLayer("PEnergy").setPointSize(1);
    selectedPlot.getLayer("PEnergy").setLineWidth(2);

    selectedPlot.getLayer("Momentum").setLineColor(color(0, 255, 0));
    selectedPlot.getLayer("Momentum").setPointColor(color(0, 255, 0));
    selectedPlot.getLayer("Momentum").setPointSize(1);
    selectedPlot.getLayer("Momentum").setLineWidth(2);

    selectedPlot.getLayer("AMomentum").setLineColor(color(255, 120, 0));
    selectedPlot.getLayer("AMomentum").setPointColor(color(255, 120, 0));
    selectedPlot.getLayer("AMomentum").setPointSize(1);
    selectedPlot.getLayer("AMomentum").setLineWidth(2);

    selectedPlot.getLayer("Distance").setLineColor(color(0));
    selectedPlot.getLayer("Distance").setPointColor(color(0));
    selectedPlot.getLayer("Distance").setPointSize(1);
    selectedPlot.getLayer("Distance").setLineWidth(2);

    selectedHist.setLineColor(color(0, 255, 0));
    selectedHist.setPointColor(color(0, 255, 0));
    selectedHist.setPointSize(1);
    selectedHist.setLineWidth(2);
  }

  void setPointsGeneral() {
    int nPts = ptsPlot;
    float min = minPlot, max = maxPlot;
    float[] xPoints = Vector.linspace(min, max, nPts).get(), yPoints = new float[nPts];

    float mDens = md * pow(10, ctePots[6]) / selFacts[2];
    float cDens = cd * pow(10, ctePots[7]) / selFacts[3];
    float radius = rd * pow(10, ctePots[8]) / selFacts[0];
    Particle test = getParticleAddition(new PVector(0, 0), mDens, cDens, radius, -1);
    for (Interaction inter : ENV.getInteractions())
      if (inter.includedInAddition())
        for (int i = 0; i < nPts; i++)
          yPoints[i] += inter.potField(test, xPoints[i] / dispFacts[0], 0) * dispFacts[5];
    generalPlot.setPoints(new GPointsArray(xPoints, yPoints));
  }
  void drawGeneral() {
    sketch.push();
    sketch.scale(1 / TW.scalingX, 1 / TW.scalingY);
    setPointsGeneral();
    generalPlot.defaultDraw();
    sketch.pop();
  }

  void setPointsSpecific(GLayer layer, int ind) {
    float[] xPoints = new float[records.size()], yPoints = new float[records.size()];
    int j = 0;
    for (float[] qts : records) {
      xPoints[j] = qts[0];
      yPoints[j++] = qts[ind];
    }
    selectedPlot.setPoints(new GPointsArray(xPoints, yPoints), layer.getId());
  }
  void clear(GLayer layer) {
    for (int i = layer.getPoints().getNPoints() - 1; i >= 0; i--)
      selectedPlot.removePoint(i, layer.getId());
  }
  void setPointsSelected() {
    for (int i = 0; i < selectedLayers.length; i++)
      if (plotQts[i])
        setPointsSpecific(selectedLayers[i], i + 1);
      else
        clear(selectedLayers[i]);
  }
  void setPointsXY() {
    float[] xPoints = new float[records.size()], yPoints = new float[records.size()];
    int j = 0;
    for (float[] qts : records) {
      xPoints[j] = qts[7];
      yPoints[j++] = qts[8];
    }
    selectedXY.setPoints(new GPointsArray(xPoints, yPoints));
  }
  void setHistogram() {
    List<Particle> pts = ENV.getGroup("quantities");
    float qts[] = new float[pts.size()];
    float allQts[][] = new float[5][pts.size()];
    int index = 0;

    float eFact = dispFacts[5];
    float momFact = dispFacts[6];
    float angFact = dispFacts[7];
    for (Particle p : pts)
      if (isFollowingCM()) {
        List<Particle> rel = ENV.getGroup("focus");
        allQts[0][index] = p.getRelEnergy(rel) * eFact;
        allQts[1][index] = p.getRelKineticEnergy(rel) * eFact;
        allQts[2][index] = p.getPotentialEnergy() * eFact;
        allQts[3][index] = p.getRelMomentum(rel).mag() * momFact;
        allQts[4][index++] = p.getRelAngularMomentum(rel).mag() * angFact;
      } else {
        allQts[0][index] = p.getEnergy() * eFact;
        allQts[1][index] = p.getKineticEnergy() * eFact;
        allQts[2][index] = p.getPotentialEnergy() * eFact;
        allQts[3][index] = p.getMomentum().mag() * momFact;
        allQts[4][index++] = p.getAngularMomentum().mag() * angFact;
      }
    for (int i = 0; i < plotQts.length; i++)
      if (plotQts[i]) {
        qts = allQts[i];
        break;
      }

    Vector qtsVec = new Vector(qts);
    float maxQ = qtsVec.max(), minQ = qtsVec.min();
    float[] borders = Vector.linspace(minQ, maxQ, batches + 1).get();

    int[] batch = new int[batches];
    for (int i = 0; i < qts.length; i++)
      for (int j = 0; j < batches; j++)
        if ((qts[i] > borders[j] || (j == 0 && qts[i] >= borders[j])) && qts[i] <= borders[j + 1]) {
          batch[j]++;
          break;
        }
    GPointsArray points = new GPointsArray(batches);
    for (int i = 0; i < batches; i++)
      points.add((borders[i] + borders[i + 1]) / 2, batch[i]);
    selectedHist.setPoints(points);
  }
  void drawSelected() {
    sketch.push();
    sketch.scale(1 / TW.scalingX, 1 / TW.scalingY);
    if (hist) {
      if (TW.anyQts() && !ENV.getGroup("quantities").isEmpty())
        setHistogram();
      selectedHist.beginDraw();
      selectedHist.drawBackground();
      selectedHist.drawBox();
      selectedHist.drawXAxis();
      selectedHist.drawYAxis();
      selectedHist.drawTitle();
      selectedHist.drawHistograms();
      selectedHist.endDraw();
    } else if (XY) {
      setPointsXY();
      selectedXY.defaultDraw();
    } else {
      setPointsSelected();
      selectedPlot.defaultDraw();
    }
    sketch.pop();
  }

  void updateRecords() {
    float[] qts = new float[9];
    List<Particle> pts = ENV.getGroup("quantities");
    qts[0] = time * dispFacts[1];
    float eFact = dispFacts[5];
    float momFact = dispFacts[6];
    float angFact = dispFacts[7];
    float lenFact = dispFacts[0];
    if (!isFollowingCM()) {
      qts[2] = Physics.getKineticEnergy(pts) * eFact;
      qts[3] = Physics.getPotentialEnergy(ENV, pts) * eFact;
      qts[1] = qts[2] + qts[3];
      qts[4] = Physics.getMomentum(pts).mag() * momFact;
      qts[5] = Physics.getAngularMomentum(pts).mag() * angFact;
    } else {
      List<Particle> rel = ENV.getGroup("focus");
      qts[2] = Physics.getRelKineticEnergy(pts, rel) * eFact;
      qts[3] = Physics.getPotentialEnergy(ENV, pts) * eFact;
      qts[1] = qts[2] + qts[3];
      qts[4] = Physics.getRelMomentum(pts, rel).mag() * momFact;
      qts[5] = Physics.getRelAngularMomentum(pts, rel).mag() * angFact;
    }
    if (pts.size() > 1)
      qts[6] = pts.get(0).getPos().dist(pts.get(1).getPos()) * lenFact;
    else if (!pts.isEmpty()) {
      qts[6] = pts.get(0).getPos().mag() * lenFact;
      qts[7] = pts.get(0).getPos().x * lenFact;
      qts[8] = pts.get(0).getPos().y * lenFact;
    }
    records.add(qts);
    while (records.size() > plotMemory)
      records.remove(0);
  }
}
