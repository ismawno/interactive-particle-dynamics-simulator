void implementForces() {

  elRep = new Interaction("elRep") {
    @Override public PVector acceleration(Particle p1, Particle p2) {
      float cte = elRepCte * pow(10, ctePots[0]);
      float lenScale = ENV.getUnits().getLengthUnitScale(), chargeScale = ENV.getUnits().getChargeUnitScale(), energyScale = ENV.getUnits().getEnergyUnitScale();
      
      int exp = expRep;
      cte /= energyScale * pow(lenScale, exp - 1) / pow(chargeScale, 2);
      float mag = cte * p1.getCharge() * p2.getCharge() / (p2.getMass() * pow(p1.getPos().dist(p2.getPos()), exp));
      return PVector.sub(p2.getPos(), p1.getPos()).setMag(mag);
    }
    @Override public float potentialEnergy(Particle p1, Particle p2) {
      float cte = elRepCte * pow(10, ctePots[0]);
      float lenScale = ENV.getUnits().getLengthUnitScale(), chargeScale = ENV.getUnits().getChargeUnitScale(), energyScale = ENV.getUnits().getEnergyUnitScale();
      
      int exp = expRep;
      cte /= energyScale * pow(lenScale, exp - 1) / pow(chargeScale, 2);
      if (exp == 1)
        return - cte * p1.getCharge() * p2.getCharge() * log(p1.getPos().dist(p2.getPos()));
      return cte * p1.getCharge() * p2.getCharge() / ((exp - 1) * pow(p1.getPos().dist(p2.getPos()), exp - 1));
    }
  };
  elAt = new Interaction("elAt") {
    @Override public PVector acceleration(Particle p1, Particle p2) {
      float cte = elAtCte * pow(10, ctePots[1]);
      float lenScale = ENV.getUnits().getLengthUnitScale(), chargeScale = ENV.getUnits().getChargeUnitScale(), energyScale = ENV.getUnits().getEnergyUnitScale();
      
      int exp = expAt;
      cte /= energyScale * pow(lenScale, exp - 1) / pow(chargeScale, 2);
      float mag = cte * p1.getCharge() * p2.getCharge() / (p2.getMass() * pow(p1.getPos().dist(p2.getPos()), exp));
      return PVector.sub(p1.getPos(), p2.getPos()).setMag(mag);
    }
    @Override public float potentialEnergy(Particle p1, Particle p2) {
      float cte = elAtCte * pow(10, ctePots[1]);
      float lenScale = ENV.getUnits().getLengthUnitScale(), chargeScale = ENV.getUnits().getChargeUnitScale(), energyScale = ENV.getUnits().getEnergyUnitScale();
      
      int exp = expAt;
      cte /= energyScale * pow(lenScale, exp - 1) / pow(chargeScale, 2);
      if (exp == 1)
        return cte * p1.getCharge() * p2.getCharge() * log(p1.getPos().dist(p2.getPos()));
      return - cte * p1.getCharge() * p2.getCharge() / ((exp - 1) * pow(p1.getPos().dist(p2.getPos()), exp - 1));
    }
  };
  exp = new Interaction("exp") {
    @Override public PVector acceleration(Particle p1, Particle p2) {
      float cte = expCte1 * pow(10, ctePots[2]);
      float timeScale = ENV.getUnits().getTimeUnitScale(), massScale = ENV.getUnits().getMassUnitScale(), chargeScale = ENV.getUnits().getChargeUnitScale();
      
      float cteExp = expCte2;
      cte /= massScale / (pow(chargeScale, 2) * pow(timeScale, 2));
      float mag = cte * p1.getCharge() * p2.getCharge() * exp(cteExp * p1.getPos().dist(p2.getPos())) / p2.getMass();
      return PVector.sub(p2.getPos(), p1.getPos()).setMag(mag);
    }
    @Override public float potentialEnergy(Particle p1, Particle p2) {
      float cte = expCte1 * pow(10, ctePots[2]);
      float timeScale = ENV.getUnits().getTimeUnitScale(), massScale = ENV.getUnits().getMassUnitScale(), chargeScale = ENV.getUnits().getChargeUnitScale();
      
      float cteExp = expCte2;
      cte /= massScale / (pow(chargeScale, 2) * pow(timeScale, 2));
      return - cte * p1.getCharge() * p2.getCharge() * exp(cteExp * p1.getPos().dist(p2.getPos())) / cteExp;
    }
  };
  gravit = new Interaction("gravit") {
    @Override public PVector acceleration(Particle p1, Particle p2) {
      float cte = gravitCte * pow(10, ctePots[3]);
      float lenScale = ENV.getUnits().getLengthUnitScale(), massScale = ENV.getUnits().getMassUnitScale(), timeScale = ENV.getUnits().getTimeUnitScale();
      
      cte /= pow(lenScale, 3) / (massScale * pow(timeScale, 2));
      float mag = cte * p1.getMass() / pow(p1.getPos().dist(p2.getPos()), 2);
      return PVector.sub(p1.getPos(), p2.getPos()).setMag(mag);
    }
    @Override public float potentialEnergy(Particle p1, Particle p2) {
      float cte = gravitCte * pow(10, ctePots[3]);
      float lenScale = ENV.getUnits().getLengthUnitScale(), massScale = ENV.getUnits().getMassUnitScale(), timeScale = ENV.getUnits().getTimeUnitScale();
      
      cte /= pow(lenScale, 3) / (massScale * pow(timeScale, 2));
      return - cte * p1.getMass() * p2.getMass() / p1.getPos().dist(p2.getPos());
    }
  };
  grav = new ExternalForce("grav") {
    @Override public PVector acceleration(Particle p) {
      float cte = gravCte * pow(10, ctePots[4]);
      float lenScale = ENV.getUnits().getLengthUnitScale(), timeScale = ENV.getUnits().getTimeUnitScale();
      
      cte /= lenScale / pow(timeScale, 2);
      return new PVector(0, cte);
    }
    @Override public float potentialEnergy(Particle p) {
      float cte = gravCte * pow(10, ctePots[4]);
      float lenScale = ENV.getUnits().getLengthUnitScale(), timeScale = ENV.getUnits().getTimeUnitScale();
      
      cte /= lenScale / pow(timeScale, 2);
     return - cte * p.getMass() * p.getPos().y;
    }
  };
  drag = new ExternalForce("drag") {
    @Override public PVector acceleration(Particle p) {
      float cte = dragCte * pow(10, ctePots[5]);
      float exp = expVel;
      float massScale = ENV.getUnits().getMassUnitScale(), timeScale = ENV.getUnits().getTimeUnitScale(), lenScale = ENV.getUnits().getLengthUnitScale();
      
      cte /= massScale * pow(timeScale, exp - 2) / pow(lenScale, exp + 1);
      return PVector.mult(p.getVel(), - cte * pow(p.getVel().mag(), exp) * PI * p.getRadius() * p.getRadius() / p.getMass());
    }
  };
  ENV.add(elRep).add(elAt).add(exp).add(gravit).add(grav).add(drag);
}
