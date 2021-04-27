package mrf;


import blang.inits.DesignatedConstructor;
import blang.inits.ConstructorArg ;


import java.util.List;
import java.util.Map;

import briefj.collections.UnorderedPair;

public class MRFGraph {
  
  
  public List<UnorderedPair<Integer, Integer>> edgeList;
  public Map<Integer, List<Integer>> neighbourList;

  public static MRFGraph instance = null;
  
  @DesignatedConstructor
  public static MRFGraph getInstance(
      @ConstructorArg(value = "filepath") String filepath
      ) {
    if (instance == null) {
      instance = new MRFGraph();
      instance.edgeList = MRFUtils.parseEdgeListToEdgeList(filepath);
      instance.neighbourList = MRFUtils.parseEdgeListToNeighboursList(filepath);
    }
    return instance;
  }
}
