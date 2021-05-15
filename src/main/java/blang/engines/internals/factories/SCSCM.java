package blang.engines.internals.factories;

import org.eclipse.xtext.xbase.lib.Pair;

import bayonet.distributions.Random;
import bayonet.smc.ParticlePopulation;
import blang.engines.AdaptiveJarzynski;
import blang.engines.internals.PosteriorInferenceEngine;
import blang.inits.Arg;
import blang.inits.DefaultValue;
import blang.inits.GlobalArg;
import blang.inits.experiments.ExperimentResults;
import blang.inits.experiments.tabwriters.TidySerializer;
import blang.io.BlangTidySerializer;
import blang.runtime.Runner;
import blang.runtime.SampledModel;
import blang.runtime.internals.objectgraph.GraphAnalysis;
import briefj.BriefParallel;

import blang.System;

/**
 * Sequential Change of Measure implementation.
 */
public class SCSCM extends AdaptiveJarzynski implements PosteriorInferenceEngine
{
  @GlobalArg public ExperimentResults results = new ExperimentResults();
  
  SampledModel model;
  
  @Override
  public void setSampledModel(SampledModel model) 
  { 
    this.model = model;
  }

  @SuppressWarnings("unchecked")
  @Override
  public void performInference() 
  {
    // create approx
    ParticlePopulation<SampledModel> approximation = getApproximation(model);
    
    // write Z estimate
    double logNormEstimate = approximation.logNormEstimate();
    System.out.println("Log normalization constant estimate: " + logNormEstimate);
    results.getTabularWriter(Runner.LOG_NORMALIZATION_ESTIMATE).write(
        Pair.of(Runner.LOG_NORMALIZATION_ESTIMATOR, "SCM"),
        Pair.of(TidySerializer.VALUE, logNormEstimate)
      );
    
    // resample & rejuvenate the last iteration to simplify processing downstream
    if (!isUniform(approximation)) // could happen if there were zero-weight particles in last round
      approximation = approximation.resample(random, resamplingScheme);
    
    // write samples
    BlangTidySerializer tidySerializer = new BlangTidySerializer(results.child(Runner.SAMPLES_FOLDER)); 
    BlangTidySerializer densitySerializer = new BlangTidySerializer(results.child(Runner.SAMPLES_FOLDER)); 
    BlangTidySerializer logIncrementalWeightSerializer = new BlangTidySerializer(results.child(Runner.SAMPLES_FOLDER));
    BlangTidySerializer logWeightSerializer = new BlangTidySerializer(results.child(Runner.SAMPLES_FOLDER));
    int particleIndex = 0;
    for (SampledModel model : approximation.particles)  
    {
      model.getSampleWriter(tidySerializer).write(Pair.of(Runner.sampleColumn, particleIndex)); 
      densitySerializer.serialize(model.logDensity(), "logDensity", Pair.of(Runner.sampleColumn, particleIndex));
      logIncrementalWeightSerializer.serialize(logIncrementalWeightsMatrix.get(particleIndex), "logIncrementalWeight", Pair.of(Runner.sampleColumn, particleIndex));
      logWeightSerializer.serialize(logWeightsMatrix.get(particleIndex), "logWeight", Pair.of(Runner.sampleColumn, particleIndex));
      particleIndex++;
    }
  }
  
  public static boolean isUniform(ParticlePopulation<?> pop)
  {
    for (int i = 0; i < pop.nParticles(); i++) 
      if (pop.getNormalizedWeight(i) != 1.0 / ((double) pop.nParticles()))
        return false;
    return true;
  }
  
  @Override
  public void check(GraphAnalysis analysis) 
  {
    // TODO: may want to check forward simulators ok
    return;
  }
  
  public static final String
  
    propagationFileName = "propagation",
    resamplingFileName = "resampling",
    
    essColumn = "ess",
    logNormalizationColumn = "logNormalization",
    iterationColumn = "iteration",
    annealingParameterColumn = "annealingParameter";

  @Override
  protected void recordPropagationStatistics(int iteration, double temperature, double ess) {
    results.child(Runner.MONITORING_FOLDER).getTabularWriter(propagationFileName).write(
        Pair.of(iterationColumn, iteration),
        Pair.of(annealingParameterColumn, temperature),
        Pair.of(essColumn, ess)
    );
    super.recordPropagationStatistics(iteration, temperature, ess);
  }

  @Override
  protected void recordResamplingStatistics(int iteration, double temperature, double logNormalization) {
    results.child(Runner.MONITORING_FOLDER).getTabularWriter(resamplingFileName).write(
        Pair.of(iterationColumn, iteration),
        Pair.of(annealingParameterColumn, temperature),
        Pair.of(logNormalizationColumn, logNormalization)
    );
    super.recordResamplingStatistics(iteration, temperature, logNormalization);
  }
}
