package blang.engines.internals.schedules;

import bayonet.smc.ParticlePopulation;
import blang.inits.Arg;
import blang.inits.DefaultValue;
import blang.runtime.SampledModel;

public class SCurveTemperatureSchedule implements TemperatureSchedule
{
  @Arg        @DefaultValue("100")
  public int nTemperatures = 100;
  public static int iteration = 0;

  @Arg @DefaultValue("1.5")
  public double   d = 1.5;

  @Override
  public double nextTemperature(ParticlePopulation<SampledModel> population, double temperature, double maxAnnealingParameter)
  {
    if (nTemperatures < 1)
      throw new RuntimeException("Number of temperatures should be positive: " + nTemperatures);
    double time = iteration / (double) nTemperatures;
    double denom = 1 + Math.pow((time / (1 - time)), -d);
    iteration += 1;
    return 1.0 / denom;
  }
}