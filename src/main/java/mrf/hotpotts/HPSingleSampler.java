package mrf.hotpotts;

import java.util.List;
import java.util.Map;

import bayonet.distributions.Random;
import blang.core.IntVar;
import blang.core.LogScaleFactor;
import blang.distributions.Generators;
import blang.mcmc.Sampler;
import briefj.collections.UnorderedPair;
import blang.mcmc.ConnectedFactor;
import blang.mcmc.SampledVariable;

public class HPSingleSampler implements Sampler {
  @SampledVariable HPSingle hpSingle;
  @ConnectedFactor List<LogScaleFactor> numericFactors;
  // TODO: Constructor to set number of DMH iterations
  int numGibbsIterations;
  List<UnorderedPair<Integer, Integer>> edgeList;
  Map<Integer, List<Integer>> neighbourList;

  @Override
  /**
   * Metropolis algorithm with Uniform(0, 1) proposal
    TODO: currently using logDensity + manually computing logPotential.
          Implication 1: when using hierarchical extensions, the partition functions will no longer cancel (?).
          Implication 2: will have to sample, say, patient class and beta in one sampler.
   */
  public void execute(Random rand) {
    // Current beta
    double currentLogDensity = logDensity();
    double currentBeta = hpSingle.getBeta();

    // Proposed beta
    double proposedBeta = Generators.uniform(rand, 0, 1);
    hpSingle.setBeta(proposedBeta);
    double proposedLogDensity = logDensity();
    List<IntVar> auxiliaryClasses = Generators.GibbsDiscreteMRF(rand, hpSingle, edgeList, neighbourList, numGibbsIterations);
    double proposedAuxLogPotential = hpSingle.logPotential(edgeList, auxiliaryClasses);
    // Current Beta
    hpSingle.setBeta(currentBeta);
    double currentAuxLogPotential = hpSingle.logPotential(edgeList, auxiliaryClasses);
    
    double logRatio = Math.min(0, proposedLogDensity - currentLogDensity + currentAuxLogPotential - proposedAuxLogPotential);
    double logU = Math.log(rand.nextDouble());
    if (logU <= logRatio) {
      hpSingle.setBeta(proposedBeta);
    }

    return;
  }
  
  private double logDensity() {
    double sum = 0.0;
    for (LogScaleFactor f : numericFactors)
      sum += f.logDensity();
    return sum;
  }

  

}
