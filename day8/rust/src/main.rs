use std::fs::File;
use std::io::{self, BufRead};
use std::path::Path;
use std::collections::HashMap;
use std::collections::HashSet;

fn read_map(file_path: &str) -> io::Result<Vec<Vec<char>>> {
    let path = Path::new(file_path);
    let file = File::open(&path)?;
    let reader = io::BufReader::new(file);

    let mut matrix = Vec::new();

    for line in reader.lines() {
        let line = line?;
        let row: Vec<char> = line.chars().collect();
        matrix.push(row);
    }

    Ok(matrix)
}

fn process_matrix(matrix: &Vec<Vec<char>>) -> HashMap<char, Vec<((usize, usize), (usize, usize))>> {
    let mut char_positions: HashMap<char, Vec<(usize, usize)>> = HashMap::new();

    for (i, row) in matrix.iter().enumerate() {
        for (j, &ch) in row.iter().enumerate() {
            if ch != '.' {
                char_positions.entry(ch).or_insert(Vec::new()).push((i, j));
            }
        }
    }

    let mut char_combinations: HashMap<char, Vec<((usize, usize), (usize, usize))>> = HashMap::new();

    for (ch, positions) in char_positions {
        let mut combinations = Vec::new();
        for i in 0..positions.len() {
            for j in i + 1..positions.len() {
                combinations.push((positions[i], positions[j]));
            }
        }
        char_combinations.insert(ch, combinations);
    }

    char_combinations
}

fn find_antinodes(character_coordinate_pairs: HashMap<char, Vec<((usize, usize), (usize, usize))>>, matrix_size_y: usize, matrix_size_x: usize) -> usize {
    let mut unique_antinode_pairs: HashSet<((i32, i32), (i32, i32))> = HashSet::new();

    for (_ch, pairs) in character_coordinate_pairs {
        for &((y1, x1), (y2, x2)) in &pairs {
            let x_diff = x1 as i32 - x2 as i32;
            let y_diff: i32 = y1 as i32 - y2 as i32;
            let a1_x = x1 as i32 + x_diff;
            let a1_y = y1 as i32 + y_diff;
            if a1_x >= 0 && a1_y >= 0 && a1_x < matrix_size_x as i32 && a1_y < matrix_size_y as i32 {
                unique_antinode_pairs.insert(((a1_y, a1_x), (a1_y, a1_x)));
            }
            let a2_x = x2 as i32 - x_diff;
            let a2_y = y2 as i32 - y_diff;
            if a2_x >= 0 && a2_y >= 0 && a2_x < matrix_size_x as i32 && a2_y < matrix_size_y as i32 {
                unique_antinode_pairs.insert(((a2_y, a2_x), (a2_y, a2_x)));
            }
        }
    }

    unique_antinode_pairs.len()
}

fn find_antinode_method2(character_coordinate_pairs: HashMap<char, Vec<((usize, usize), (usize, usize))>>, matrix_size_y: usize, matrix_size_x: usize) -> usize {
    let mut unique_antinode_pairs: HashSet<((i32, i32), (i32, i32))> = HashSet::new();

    for (_ch, pairs) in character_coordinate_pairs {
        for &((y1, x1), (y2, x2)) in &pairs {
            // Both elements of the pair are antinodes.   Add them.
            unique_antinode_pairs.insert(((y1 as i32, x1 as i32), (y1 as i32, x1 as i32)));
            unique_antinode_pairs.insert(((y2 as i32, x2 as i32), (y2 as i32, x2 as i32)));
            let x_diff = x1 as i32 - x2 as i32;
            let y_diff: i32 = y1 as i32 - y2 as i32;
            let mut a1_x = x1 as i32 + x_diff;
            let mut a1_y = y1 as i32 + y_diff;
            while a1_x >= 0 && a1_y >= 0 && a1_x < matrix_size_x as i32 && a1_y < matrix_size_y as i32 {
                unique_antinode_pairs.insert(((a1_y, a1_x), (a1_y, a1_x)));
                a1_x += x_diff;
                a1_y += y_diff;
            }
            let mut a2_x = x2 as i32 - x_diff;
            let mut a2_y = y2 as i32 - y_diff;
            while a2_x >= 0 && a2_y >= 0 && a2_x < matrix_size_x as i32 && a2_y < matrix_size_y as i32 {
                unique_antinode_pairs.insert(((a2_y, a2_x), (a2_y, a2_x)));
                a2_x -= x_diff;
                a2_y -= y_diff;
            }
        }
    }

    unique_antinode_pairs.len()
}

fn main() -> io::Result<()> {
    let file_path = "/Users/carterbradford/tech-stuff/aoc-2024/day8/rust/map.txt";
    let matrix = read_map(file_path)?;

    let character_combinations = process_matrix(&matrix);
    let anti_node_count = find_antinodes(character_combinations.clone(), matrix.len(), matrix[0].len());
    println!("Antinode count: {}", anti_node_count);

    let anti_node_count_method2 = find_antinode_method2(character_combinations.clone(), matrix.len(), matrix[0].len());
    println!("Antinode count method 2: {}", anti_node_count_method2);
    Ok(())
}
