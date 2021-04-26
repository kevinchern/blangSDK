package mrf;

import java.util.List;

import blang.core.IntVar;
import briefj.collections.UnorderedPair;


public interface MRFInteractor {
  public int getNumClasses();
  public double logPotential(List<UnorderedPair<Integer, Integer>> edgeList, List<IntVar> classes);
  public double logEdgePotential(IntVar u, IntVar v);
  public double logNodeClassPotential(IntVar nodeClass, List<Integer> neighbours, List<IntVar> classes);
}
