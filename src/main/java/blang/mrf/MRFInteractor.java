package blang.mrf;

import java.util.List;

import blang.core.IntVar;
import blang.types.Plate;
import blang.types.Plated;
import briefj.collections.UnorderedPair;


public interface MRFInteractor {
  public int getNumClasses();
  public double logPotential(List<UnorderedPair<Integer, Integer>> edgeList, List<IntVar> classes);
  public double logEdgePotential(IntVar u, IntVar v);
  public double logNodeClassPotential(IntVar nodeClass, List<String> neighbours, Plated<IntVar> classes, Plate<String> N);
}
