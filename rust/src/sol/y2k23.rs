pub fn day1(input: &str) -> Result<String, &str> {
    let mut result: Vec<u32> = Vec::new();
    let mut result2: Vec<u32> = Vec::new();
    let re = regex::Regex::new(r"((one)|(two)|(three)|(four)|(five)|(six)|(seven)|(eight)|(nine)|(\d))").unwrap();
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
            (Some(_), Some(_)) => result.push(format!("{}{}", first_digit.unwrap(), last_digit.unwrap()).parse::<u32>().unwrap()),
            (Some(_), None) => result.push(format!("{}{}", first_digit.unwrap(), line.chars().nth(back).unwrap()).parse::<u32>().unwrap()),
            (None, Some(_)) => result.push(format!("{}{}", last_digit.unwrap(), line.chars().nth(front).unwrap()).parse::<u32>().unwrap()),
            (None, None) => result.push((line.chars().nth(front).unwrap().to_digit(10).unwrap() as u32) * 11),
        }
        dbg!(format!("{}: {} {}",line, first_digit2.unwrap_or(' '), last_digit2.unwrap_or(' ')));
        result2.push(format!("{}{}", first_digit2.unwrap_or(' '), last_digit2.unwrap_or(' ')).parse::<u32>().unwrap());
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
