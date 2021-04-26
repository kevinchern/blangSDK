package mrf;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;

import blang.core.IntVar;
import blang.inits.providers.CoreProviders;
import briefj.collections.UnorderedPair;
import briefj.BriefIO;

public class MRFUtils {
  
  public static HashMap<Integer, List<Integer>> parseEdgeListToNeighboursList(String filepath) {
    // TODO: handle case where vertices are not an enumeration from 0,...,n-1

    HashSet<Integer> vertices = new HashSet<Integer>();
    for (List<String> line : BriefIO.readLines(filepath).splitCSV()) {
      Integer nodeA = CoreProviders.parse_int(line.get(0));
      Integer nodeB = CoreProviders.parse_int(line.get(1));
      vertices.add(nodeA);
      vertices.add(nodeB);
    }

    HashMap<Integer, List<Integer>> result = new HashMap<Integer, List<Integer>>();
    for (Integer vertex : vertices) {
      result.put(vertex, new ArrayList<Integer>());
    }

    for (List<String> line : BriefIO.readLines(filepath).splitCSV()) {
      Integer nodeA = CoreProviders.parse_int(line.get(0));
      Integer nodeB = CoreProviders.parse_int(line.get(1));
      result.get(nodeA).add(nodeB);
      result.get(nodeB).add(nodeA);
    }

    return result;
  }
  
  public static List<UnorderedPair<Integer, Integer>> parseEdgeListToEdgeList(String filepath) {
    List<UnorderedPair<Integer, Integer>> result = new ArrayList<UnorderedPair<Integer, Integer>>();
    for (List<String> line : BriefIO.readLines(filepath).splitCSV()) {
      Integer nodeA = CoreProviders.parse_int(line.get(0));
      Integer nodeB = CoreProviders.parse_int(line.get(1));
      result.add(new UnorderedPair<Integer, Integer>(nodeA, nodeB));
    }
    return result;
  }
  
  /**
   * Returns an int[] of counts of interaction types.  
   * @param edges
   * @param classes
   * @param numClasses
   * @return
   */
  public static int[] countEdgeTypes
  (List<UnorderedPair<Integer, Integer>> edgeList, List<IntVar> classes, int numClasses) {

    int numInteractionTypes = numClasses * (numClasses + 1) / 2;
    int[] result = new int[numInteractionTypes];
    Arrays.fill(result, 0);
    for (UnorderedPair<Integer, Integer> edge : edgeList) {
      IntVar u = classes.get(edge.getFirst());
      IntVar v = classes.get(edge.getSecond());
      int index = hotPottsIndicesToIndex(u.intValue(), v.intValue(), numClasses);
      result[index] += 1;
    }

    return result;
  }
  
  public static int hotPottsIndicesToIndex(int i, int j, int numClasses) {
    if (i > j)  {
      int temp = i;
      i = j;
      j = temp;
    }
    return (int)(numClasses * i - (i - 1) * i / 2 + j - i);
  }
  
}
