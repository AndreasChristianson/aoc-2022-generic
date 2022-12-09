use std::collections::HashMap;
use std::fs::File;
use std::io::{self, BufRead};
use std::path::Path;

use regex::Regex;

struct State {
}

#[derive(Eq, PartialEq, Hash, Clone, Debug)]
struct Position {
    row: i32,
    col: i32,
}

fn to_pair(line: String) -> (char, i32) {
    let pattern = Regex::new(r"^([RUDL]) (\d+)$").unwrap();
    let caps = pattern.captures(&line).unwrap();
    return (
        caps[1].chars().nth(0).unwrap(),
        caps[2].parse::<i32>().unwrap(),
    );
}

fn to_pairs(file: &str) -> Vec<(char, i32)> {
    let mut result = Vec::new();
    if let Ok(lines) = read_lines(file) {
        for line in lines {
            if let Ok(string) = line {
                result.push(to_pair(string))
            }
        }
    }
    return result;
}
fn adjacent(left: &Position, right: &Position) -> bool {
    if (left.row - right.row).abs() > 1 || (left.col - right.col).abs() > 1 {
        return false;
    }

    return true;
}

fn main() {
    let pairs = to_pairs("input.txt");
    let mut state: HashMap<Position, State> = HashMap::new();
    let mut rope = Vec::new();
    for _ in 0..10 {
        rope.push(Position { row: 0, col: 0 })
    }

    for (direction, distance) in pairs.iter() {
        // println!("{} {}", direction, distance);
        let dir = match direction {
            'R' => (0, 1),
            'L' => (0, -1),
            'U' => (-1, 0),
            'D' => (1, 0),
            _ => panic!("unknown instruction"),
        };
        for _ in 0..*distance {
            rope[0].row += dir.0;
            rope[0].col += dir.1;
            for i in 1..rope.len() {
                if !adjacent(&rope[i - 1], &rope[i]) {
                    rope[i].row += (rope[i - 1].row - rope[i].row).max(-1).min(1);
                    rope[i].col += (rope[i - 1].col - rope[i].col).max(-1).min(1);
                }
            }
            let last = rope.last().unwrap();
            // println!("head: {:?}, tail: {:?}", rope[0], last);
            state.insert(
                Position {
                    row: last.row,
                    col: last.col,
                },
                State { },
            );
        }
    }
    println!("visited: {}", state.values().count());
}

fn read_lines<P>(filename: P) -> io::Result<io::Lines<io::BufReader<File>>>
where
    P: AsRef<Path>,
{
    let file = File::open(filename)?;
    Ok(io::BufReader::new(file).lines())
}
