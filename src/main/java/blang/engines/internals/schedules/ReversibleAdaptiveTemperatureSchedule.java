package blang.engines.internals.schedules;

import org.apache.commons.math3.analysis.UnivariateFunction;
import org.apache.commons.math3.analysis.solvers.PegasusSolver;

import bayonet.smc.ParticlePopulation;
import blang.engines.internals.EngineStaticUtils;
import blang.inits.Arg;
import blang.inits.DefaultValue;
import blang.runtime.SampledModel;

public class ReversibleAdaptiveTemperatureSchedule implements TemperatureSchedule
{
  
  private double threshold = 0.8;
  
  @Override
  public double nextTemperature(ParticlePopulation<SampledModel> population, double temperature, double maxAnnealingParameter)
  {
    UnivariateFunction objective = objective(population, temperature);
    
    if (population.getRelativeESS() > threshold) {
      double nextTemperature = objective.value(maxAnnealingParameter) >= 0 ? 
        maxAnnealingParameter :
        new PegasusSolver().solve(100, objective, temperature, maxAnnealingParameter);
      return nextTemperature;
    } else {
      double nextTemperature = new PegasusSolver().solve(100, objective, 0, temperature);
      return nextTemperature;
    }
  }

  private UnivariateFunction objective(ParticlePopulation<SampledModel> population, double temperature)
  {
    double previousRelativeESS = population.getRelativeESS();
    return previousRelativeESS > threshold ?
        (double proposedNextTemperature) -> EngineStaticUtils.relativeESS(population, temperature, proposedNextTemperature, false) - 0.9999 * previousRelativeESS:
        (double proposedNextTemperature) -> EngineStaticUtils.relativeESS(population, temperature, proposedNextTemperature, false) - threshold;
  }
}