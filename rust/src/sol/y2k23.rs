pub fn day1(input: &str) -> Result<String, &str> {
    let mut result: Vec<u32> = Vec::new();
    let mut result2: Vec<u32> = Vec::new();
    let re =
        regex::Regex::new(r"((one)|(two)|(three)|(four)|(five)|(six)|(seven)|(eight)|(nine)|(\d))")
            .unwrap();
    for line in input.lines() {
        // traverse the line simultaneously front and back
        let mut front = 0;
        let mut back = line.len() - 1;
        let mut first_digit: Option<char> = None;
        let mut last_digit: Option<char> = None;
        let first_digit2: Option<char> = match re.find(line).unwrap().as_str() {
            "one" => Some('1'),
            "two" => Some('2'),
            "three" => Some('3'),
            "four" => Some('4'),
            "five" => Some('5'),
            "six" => Some('6'),
            "seven" => Some('7'),
            "eight" => Some('8'),
            "nine" => Some('9'),
            n => Some(n.chars().nth(0).unwrap()),
        };
        let mut last_digit2: Option<char> = None;
        while front < back {
            let front_char = line.chars().nth(front).unwrap();
            let back_char = line.chars().nth(back).unwrap();
            if first_digit.is_none() {
                if front_char.is_digit(10) {
                    first_digit = Some(front_char);
                } else {
                    front += 1;
                }
            }
            if last_digit2.is_none() {
                let substr = &line[back..];
                //dbg!(substr);
                if re.is_match(substr) {
                    last_digit2 = match re.find(substr).unwrap().as_str() {
                        "one" => Some('1'),
                        "two" => Some('2'),
                        "three" => Some('3'),
                        "four" => Some('4'),
                        "five" => Some('5'),
                        "six" => Some('6'),
                        "seven" => Some('7'),
                        "eight" => Some('8'),
                        "nine" => Some('9'),
                        n => Some(n.chars().nth(0).unwrap()),
                    };
                    // dbg!(last_digit2);
                }
            }
            if last_digit.is_none() {
                if back_char.is_digit(10) {
                    last_digit = Some(back_char);
                    if last_digit2.is_none() {
                        last_digit2 = Some(back_char);
                        dbg!(last_digit2);
                    }
                } else {
                    back -= 1;
                }
            }
            if first_digit.is_some() && last_digit.is_some() {
                break;
            }
        }
        if last_digit2.is_none() {
            last_digit2 = match re.find(line[back..].trim()).unwrap().as_str() {
                "one" => Some('1'),
                "two" => Some('2'),
                "three" => Some('3'),
                "four" => Some('4'),
                "five" => Some('5'),
                "six" => Some('6'),
                "seven" => Some('7'),
                "eight" => Some('8'),
                "nine" => Some('9'),
                n => Some(n.chars().nth(0).unwrap()),
            };
        }
        //dbg!(format!("{} {}", first_digit.unwrap_or(' '), last_digit.unwrap_or(' ')));
        match (first_digit, last_digit) {
            (Some(_), Some(_)) => result.push(
                format!("{}{}", first_digit.unwrap(), last_digit.unwrap())
                    .parse::<u32>()
                    .unwrap(),
            ),
            (Some(_), None) => result.push(
                format!(
                    "{}{}",
                    first_digit.unwrap(),
                    line.chars().nth(back).unwrap()
                )
                .parse::<u32>()
                .unwrap(),
            ),
            (None, Some(_)) => result.push(
                format!(
                    "{}{}",
                    last_digit.unwrap(),
                    line.chars().nth(front).unwrap()
                )
                .parse::<u32>()
                .unwrap(),
            ),
            (None, None) => result.push(
                (line.chars().nth(front).unwrap().to_digit(10).unwrap() as u32)
                    * 11,
            ),
        }
        dbg!(format!(
            "{}: {} {}",
            line,
            first_digit2.unwrap_or(' '),
            last_digit2.unwrap_or(' ')
        ));
        result2.push(
            format!(
                "{}{}",
                first_digit2.unwrap_or(' '),
                last_digit2.unwrap_or(' ')
            )
            .parse::<u32>()
            .unwrap(),
        );
    }
    // dbg!(&result);
    //dbg!(&result2);
    let sum: u32 = result.iter().sum();
    let sum2: u32 = result2.iter().sum();
    Ok(format!("part 1: {}\npart 2: {}", sum, sum2))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_day1() {
        let input = "1abc23\n\
                     123\n\
                     12";
        assert_eq!(day1(input), Ok("part 1: 38\npart 2: 38".to_string()));
    }

    #[test]
    fn test_day1_1() {
        let input = "1abc2\n\
                     pqr3stu8vwx\n\
                     a1b2c3d4e5ef\n\
                     treb7uchet";
        assert_eq!(day1(input), Ok("part 1: 142\npart 2: 142".to_string()));
    }

    #[test]
    fn test_day1_2() {
        let input = "two1nine\n\
                     eightwo1three\n\
                     abcone2threexyz\n\
                     xtwone3four\n\
                     4nineeightseven2\n\
                     zoneight234\n\
                     7pqrstsixteen";
        assert_eq!(day1(input), Ok("part 1: 220\npart 2: 281".to_string()));
    }
}

pub fn day2(input: &str) -> Result<String, &str> {
    let constraints = std::collections::HashMap::from([
        ("red", 12),
        ("green", 13),
        ("blue", 14),
    ]);
    let mut power_sum = 0;
    let result = input.lines().fold(0, |acc, line| {
        let line_parts = line.split(":").collect::<Vec<&str>>();
        let draws = line_parts[1].trim().split(";");
        let game = line_parts[0].trim().split(" ").collect::<Vec<&str>>()[1]
            .parse::<u32>()
            .unwrap();
        let mut is_valid_game = true;
        let mut min_rgb = std::collections::HashMap::from([
            ("red", 0),
            ("green", 0),
            ("blue", 0),
        ]);
        for draw in draws {
            let balls = draw.trim().split(",").collect::<Vec<&str>>();
            min_rgb = balls.iter().fold(min_rgb, |mut acc, ball| {
                let ball_parts = ball.trim().split(" ").collect::<Vec<&str>>();
                let color = ball_parts[1];
                let number = ball_parts[0].parse::<u32>().unwrap();
                acc.insert(
                    color,
                    std::cmp::max(*acc.get(color).unwrap(), number),
                );
                acc
            });
            let is_possible = balls.iter().all(|ball| {
                dbg!(ball);
                let ball_parts = ball.trim().split(" ").collect::<Vec<&str>>();
                let color = ball_parts[1];
                let number = ball_parts[0].parse::<u32>().unwrap();
                dbg!(color, number);
                dbg!(constraints.get(color).unwrap() >= &number);
                constraints.get(color).unwrap() >= &number
            });
            if !is_possible {
                is_valid_game = false;
            }
        }
        power_sum += min_rgb.values().fold(1, |acc, x| acc * x);
        if is_valid_game {
            acc + game
        } else {
            acc
        }
    });
    Ok(format!("part 1: {}\npart 2: {}", result, power_sum))
}

#[cfg(test)]
mod tests2 {
    use super::*;

    #[test]
    fn test_day2() {
        let input = "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green\n\
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue\n\
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red\n\
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red\n\
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green";
        assert_eq!(day2(input), Ok("part 1: 8\npart 2: 2286".to_string()));
    }
}


pub fn day3(input: &str) -> Result<String, &str> {
    let line_length = input.lines().nth(0).unwrap().len();
    dbg!(input.lines().nth(0).unwrap()[23..].parse::<u16>().unwrap());
    let finder = regex::Regex::new(r"(\d{1,3})|([[:punct:]--[.]])").unwrap();
    let mut prev_line: Option<regex::Match> = None;

    let result = input.lines().fold(0, |acc, line| {
        let current_line: std::collections::HashMap<regex::Match, bool> =
            std::collections::HashMap::new();
        finder
            .find_iter(line)
            .for_each(|x| {
                current_line.insert(
                    x,
                    finder.find_iter(line).any(|y| {
                        y.end() == x.start() - 1 || y.start() == x.end() + 1
                    }),
                )
            });
        acc
    });

    Ok("part 1: 0\npart 2: 0".to_string())
}
