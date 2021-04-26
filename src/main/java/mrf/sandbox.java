package mrf;

import java.util.List;
import java.util.Map;
import java.util.Random;

import blang.distributions.Generators;
import briefj.collections.UnorderedPair;
import mrf.hotpotts.HPSingle;

public class sandbox {
  public static void main(String[] args) {
    List<UnorderedPair<Integer, Integer>> edgeList = MRFUtils.parseEdgeListToEdgeList("data/edges.csv");
    Map<Integer, List<Integer>> nbrsList = MRFUtils.parseEdgeListToNeighboursList("data/edges.csv");
    System.out.println(edgeList);
    System.out.println(nbrsList);
    Random random = new Random();
    HPSingle interactor = new HPSingle(3);
    Generators.GibbsDiscreteMRF(random, interactor, edgeList, nbrsList, 5);
  }
}
