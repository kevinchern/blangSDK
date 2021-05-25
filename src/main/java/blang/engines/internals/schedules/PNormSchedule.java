package blang.engines.internals.schedules;

import bayonet.smc.ParticlePopulation;
import blang.inits.Arg;
import blang.inits.DefaultValue;
import blang.runtime.SampledModel;


/**
 * Function taken from:
 * https://math.stackexchange.com/a/677083/634859
 */
public class PNormSchedule implements TemperatureSchedule
{
  @Arg        @DefaultValue("100")
  public int nTemperatures = 100;
  public static int iteration = 0;

  @Arg @DefaultValue("1.5")
  public double   d = 1.5;

  @Override
  public double nextTemperature(ParticlePopulation<SampledModel> population, double temperature, double maxAnnealingParameter)
  {
    iteration += 1;
    if (nTemperatures < 1)
      throw new RuntimeException("Number of temperatures should be positive: " + nTemperatures);
    double time = iteration / (double) nTemperatures;
    if (d == 0) {
      return time;
    }
    double twoToD = Math.pow(2, d);
    double factorOne = 1.0 / (twoToD - 1.0); 
    double factorTwo = twoToD / ((twoToD - 1) * (1 - time) + 1) - 1;
    double result = factorOne * factorTwo;
    return result;
  }
}