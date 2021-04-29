package blang.mcmc;

import java.util.List;
import bayonet.distributions.Random;
import bayonet.math.NumericalUtils;

import blang.core.LogScaleFactor;
import blang.core.WritableIntVar;
import blang.distributions.Generators;


public class IntGibbsSampler implements Sampler
{
  @SampledVariable
  protected WritableIntVar variable;
  
  @ConnectedFactor
  protected List<LogScaleFactor> numericFactors;
  
  private final Integer numClasses;
  
  
  private IntGibbsSampler(Integer numClasses) 
  {
    this.numClasses = numClasses;
  }
  
  public static IntGibbsSampler build(WritableIntVar variable, List<LogScaleFactor> numericFactors, Integer numClasses)
  {
    IntGibbsSampler result = new IntGibbsSampler(numClasses);
    result.variable = variable;
    result.numericFactors = numericFactors;
    return result;
  }
  
  public void execute(Random random)
  {
    double logSum = Double.NEGATIVE_INFINITY;
    double[] discreteDistribution = new double[this.numClasses];

    // Accumulate normalization constant and populate in discreteDistribution
    for (int i = 0; i < this.numClasses; i++) {
      discreteDistribution[i] = logDensityAt(i);
      logSum = NumericalUtils.logAdd(logSum, discreteDistribution[i]);
    }
    // Normalize distribution
    for (int i = 0; i < this.numClasses; i++) {
      discreteDistribution[i] -= logSum;
    }
    
    variable.set(Generators.categorical(random, discreteDistribution));
  }
  
  
  private double logDensityAt(int x)
  {
    variable.set(x);
    return logDensity();
  }
  
  private double logDensity() {
    double sum = 0.0;
    for (LogScaleFactor f : numericFactors)
      sum += f.logDensity();
    return sum;
  }

}