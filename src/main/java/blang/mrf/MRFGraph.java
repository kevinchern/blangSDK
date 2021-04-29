package blang.mrf;


import blang.inits.DesignatedConstructor;
import blang.inits.ConstructorArg ;


import java.util.List;
import java.util.Map;

import briefj.collections.UnorderedPair;

public class MRFGraph {
  
  
  public List<UnorderedPair<String, String>> edgeList;
  public Map<String, List<String>> neighboursMap;

  @DesignatedConstructor
  public MRFGraph(@ConstructorArg(value = "filepath") String filepath) {
    edgeList = MRFUtils.parseEdgeListToEdgeList(filepath);
    neighboursMap = MRFUtils.parseEdgeListToNeighboursMap(filepath);
  }
}
