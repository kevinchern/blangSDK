package blang.mrf.hotpotts;

import java.util.List;

import blang.core.IntVar;
import blang.core.RealVar;
import blang.inits.experiments.tabwriters.TidilySerializable;
import blang.inits.experiments.tabwriters.TidySerializer.Context;
import blang.mcmc.Samplers;
import blang.types.Plate;
import blang.types.Plated;
import blang.mrf.MRFInteractor;
import blang.mrf.hotpotts.HPSingleSampler;

import briefj.collections.UnorderedPair;

@Samplers(HPSingleSampler.class)
public class HPSingle implements MRFInteractor, RealVar, TidilySerializable {
  
  private double beta = 0.5;
  private int numClasses;
  
  public HPSingle(int numClasses) {
    this.setNumClasses(numClasses);
  }

  public HPSingle(double beta, int numClasses) {
    this.beta = beta;
    this.setNumClasses(numClasses);
  }
  

  @Override
  public double doubleValue() {
    return beta;
  }


  @Override
  public double logPotential(List<UnorderedPair<Integer, Integer>> edgeList, List<IntVar> classes) {
    double logpot = 0;
    for (UnorderedPair<Integer, Integer> edge : edgeList) {
      logpot += logEdgePotential(classes.get(edge.getFirst()), classes.get(edge.getSecond()));
    }
    return logpot;
  }


  @Override
  public double logEdgePotential(IntVar u, IntVar v) {
    if (u.intValue() < 0 || v.intValue() < 0) {
      return Double.NEGATIVE_INFINITY;
    }
    if (u.intValue() >= numClasses || v.intValue() >= numClasses) {
      return Double.NEGATIVE_INFINITY;
    }
    double b = u.intValue() == v.intValue() ? beta : 1 - beta;
    return b;
  }

  public double getBeta() {
    return beta;
  }

  public void setBeta(double beta) {
    this.beta = beta;
  }


  public int getNumClasses() {
    return numClasses;
  }

  public void setNumClasses(int numClasses) {
    this.numClasses = numClasses;
  }

  @Override
  public void serialize(Context context) {
    context.recurse(beta, "beta", 0);    
  }

  @Override
  public double logNodeClassPotential(IntVar nodeClass, List<String> neighbours, Plated<IntVar> classes, Plate<String> N) {
    double logp = 0;
    for (String neighbour : neighbours) {
      logp += logEdgePotential(nodeClass, classes.get(N.index(neighbour)));
    }
    return logp;
  }


}
