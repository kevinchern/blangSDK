package blang.mrf.hotpotts;

import blang.types.Plate;
import blang.types.Plated;
import blang.core.IntVar;
import blang.mrf.MRFGraph;

public class HPSamplerOptions {

  public static Plate<String> P;
  public static Plate<String> N;
  public static Plated<IntVar> X;
  public static Plated<MRFGraph> graph;
  
//  @DesignatedConstructor
//  public static HPSamplerOptions getInstance(@ConstructorArg(value = "filepath") String filepath) {
//    if (instance == null) {
//      instance = new HPSamplerOptions();
//      instance.g = new MRFGraph(filepath);
//    }
//    return instance;
//  }

  public HPSamplerOptions(Plate<String> plateP, Plated<MRFGraph> platedGraph, Plate<String> plateN, Plated<IntVar> platedX) {
    graph = platedGraph;
    P = plateP;
    N = plateN;
    X = platedX;
    return;
  }
  

}
