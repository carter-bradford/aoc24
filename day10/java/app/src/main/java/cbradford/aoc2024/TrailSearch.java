/*
 * This source file was generated by the Gradle 'init' task
 */
package cbradford.aoc2024;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class TrailSearch {

    public record MapWithTrailHeads(List<List<Integer>> map, List<TrailStep> trailHeads) {
    }

    public record TrailStep(int elevation, int x, int y) {
    }

    public record TrailPathNode(TrailStep step, List<TrailPathNode> children) {
    }

    public MapWithTrailHeads LoadMap(String filename) throws IOException {
        List<List<Integer>> map = new ArrayList<>();
        List<TrailStep> trailHeads = new ArrayList<>();
        BufferedReader reader = new BufferedReader(new FileReader(filename));
        String line;
        int rowNum = 0;
        while ((line = reader.readLine()) != null) {
            List<Integer> row = new ArrayList<>();
            for (int i = 0; i < line.length(); i++) {
                var cell = Character.getNumericValue(line.charAt(i));
                row.add(cell);
                if (cell == 0)
                    trailHeads.add(new TrailStep(cell, i, rowNum));
            }
            map.add(row);
            rowNum++;
        }
        reader.close();
        return new MapWithTrailHeads(map, trailHeads);
    }


    public int countPeaks(TrailPathNode node, Set<String> uniqueNodes) {
        if (node == null) {
            return 0;
        }
        int count = 0;
        if (node.step().elevation() == 9) {
            String key = node.step().x() + "," + node.step().y();
            if (!uniqueNodes.contains(key)) {
                uniqueNodes.add(key);
                count = 1;
            }
        }

        if (node.children == null || node.children.isEmpty()) {
            return count;
        }

        for (TrailPathNode child : node.children) {
            count += countPeaks(child, uniqueNodes);
        }
        return count;
    }

    public int countTrails(TrailPathNode node) {
        if (node == null) {
            return 0;
        }
        int count = node.step().elevation() == 9 ? 1 : 0;

        if (node.children == null || node.children.isEmpty()) {
            return count;
        }

        for (TrailPathNode child : node.children) {
            count += countTrails(child);
        }
        return count;
    }

    public TrailPathNode FindPath(List<List<Integer>> map, TrailStep start, TrailPathNode parent) {
        TrailPathNode node = new TrailPathNode(start, new ArrayList<>());
        if (parent != null) {
            parent.children().add(node);
        }
        int x = start.x();
        int y = start.y();
        int elevation = start.elevation();
        if (elevation == 9) {
            return node;
        }
        int goalElevation = elevation + 1;
        if (x > 0 && map.get(y).get(x - 1) == goalElevation) {
            FindPath(map, new TrailStep(goalElevation, x - 1, y), node);
        }
        if (x < map.get(y).size() - 1 && map.get(y).get(x + 1) == goalElevation) {
            FindPath(map, new TrailStep(goalElevation, x + 1, y), node);
        }
        if (y > 0 && map.get(y - 1).get(x) == goalElevation) {
            FindPath(map, new TrailStep(goalElevation, x, y - 1), node);
        }
        if (y < map.size() - 1 && map.get(y + 1).get(x) == goalElevation) {
            FindPath(map, new TrailStep(goalElevation, x, y + 1), node);
        }
        return node;
    }

    public static void main(String[] args) {
        try {
            TrailSearch trailSearch = new TrailSearch();
            var mapWithTrailHeads = trailSearch.LoadMap("/Users/carterbradford/tech-stuff/aoc-2024/day10/java/trailmap.txt");
            long numberOfPaths = 0;
            long numberOfTrails = 0;
            for (var trailHead : mapWithTrailHeads.trailHeads) {
                TrailPathNode pathTree = trailSearch.FindPath(mapWithTrailHeads.map, trailHead, null);
                // Count the number of nodes in the path tree with elevation == 9
                numberOfPaths += trailSearch.countPeaks(pathTree, new HashSet<String>());
                numberOfTrails += trailSearch.countTrails(pathTree);
            }
            System.out.println("Number of paths: " + numberOfPaths);
            System.out.println("Number of trails: " + numberOfTrails);

        } catch (IOException e) {
            System.out.println("Error reading file: " + e.getMessage());
            System.exit(-1);
        }
    }
}
