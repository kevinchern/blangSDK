package blang.mrf.hotpotts;

import blang.inits.ConstructorArg;
import blang.inits.DesignatedConstructor;
import blang.mrf.MRFUtils;
import blang.mrf.MRFGraph;

public class HPSamplerOptions {

  public MRFGraph g;
  public static HPSamplerOptions instance = null;
  
  @DesignatedConstructor
  public static HPSamplerOptions getInstance(@ConstructorArg(value = "filepath") String filepath) {
    if (instance == null) {
      instance = new HPSamplerOptions();
      instance.g = new MRFGraph(filepath);
    }
    return instance;
  }

}
