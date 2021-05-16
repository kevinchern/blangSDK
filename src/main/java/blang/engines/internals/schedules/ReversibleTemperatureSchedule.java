package blang.engines.internals.schedules;

import bayonet.smc.ParticlePopulation;
import blang.inits.Arg;
import blang.inits.DefaultValue;
import blang.runtime.SampledModel;

public class ReversibleTemperatureSchedule implements TemperatureSchedule
{
  @Arg        @DefaultValue("100")
  public int nTemperatures = 100;
  public static int iteration = 0;

  @Override
  public double nextTemperature(ParticlePopulation<SampledModel> population, double temperature, double maxAnnealingParameter)
  {
    if (nTemperatures < 1)
      throw new RuntimeException("Number of temperatures should be positive: " + nTemperatures);
    double k = 10;
    double freq = 0;
    double time = iteration / (double) nTemperatures;
    double t = Math.pow(time, k);
    double result = t / 3.0 * (Math.sin(t * freq * 2.0 * Math.PI + Math.PI / 2.0) + 2.0);
    iteration += 1;
    return Math.min(maxAnnealingParameter, result);
  }
}