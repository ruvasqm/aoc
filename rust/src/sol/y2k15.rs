pub fn day1(steps: &str) -> Result<String, &str> {
    let mut b_flag = false;
    let mut first_basement = "None";
    let mut counter = 1;
    let result = steps.chars().fold(0, |acc, x| match x {
        '(' => {
            if !b_flag {
                counter += 1;
            }
            acc + 1
        }
        ')' => {
            if !b_flag && acc == 0 {
                b_flag = true;
            } else if !b_flag {
                counter += 1;
            }
            acc - 1
        }
        _ => acc,
    });
    let counter = counter.to_string();
    first_basement = if b_flag { &counter } else { first_basement };
    let answer = format!(
        "final floor: {}\nfirst basement: {}",
        result, first_basement
    );
    Ok(answer)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_day1() {
        assert_eq!(
            day1("(()))"),
            Ok("final floor: -1\nfirst basement: 5".to_string())
        );
        assert_eq!(
            day1("))()"),
            Ok("final floor: -2\nfirst basement: 1".to_string())
        );
        assert_eq!(
            day1(")))"),
            Ok("final floor: -3\nfirst basement: 1".to_string())
        );
        assert_eq!(
            day1(")(()(()"),
            Ok("final floor: 1\nfirst basement: 1".to_string())
        );
        assert_eq!(
            day1(")"),
            Ok("final floor: -1\nfirst basement: 1".to_string())
        );
    }
}

pub fn day2(input: &str) -> Result<String, &str> {
    let mut total_ribbon: u32 = 0;
    let total_paper: u32 = input.lines().fold(0, |acc, x| {
        let mut dims: Vec<u32> = x
            .split('x')
            .map(|x| match x.parse::<u32>() {
                Ok(x) => x,
                Err(_) => 0,
            })
            .collect();
        dims.sort();
        total_ribbon += 2 * (dims[0] + dims[1]) + dims[0] * dims[1] * dims[2];
        acc + 2 * (dims[0] * dims[1] + dims[1] * dims[2] + dims[2] * dims[0]) + dims[0] * dims[1]
    });
    let total_paper = total_paper.to_string();
    let total_ribbon = total_ribbon.to_string();
    let answer = format!(
        "total paper: {}\ntotal ribbon: {}",
        total_paper, total_ribbon
    );
    Ok(answer)
}

#[cfg(test)]
mod tests2 {
    use super::*;

    #[test]
    fn test_day2() {
        assert_eq!(
            day2("2x3x4"),
            Ok("total paper: 58\ntotal ribbon: 34".to_string())
        );
        assert_eq!(
            day2("1x1x10"),
            Ok("total paper: 43\ntotal ribbon: 14".to_string())
        );
        assert_eq!(
            day2("2x3x4\n1x1x10"),
            Ok("total paper: 101\ntotal ribbon: 48".to_string())
        );
        assert_eq!(
            day2("2x3x4\n1x1x10\n2x3x4\n1x1x10"),
            Ok("total paper: 202\ntotal ribbon: 96".to_string())
        );
    }
}

pub fn day3(input: &str) -> Result<String, &str> {
    let mut houses: std::collections::HashMap<(i32, i32), u32> =
        std::collections::HashMap::new();
    let mut santa = (0, 0);
    houses.insert(santa, 1);
    let presents = input.chars().fold(1, |acc, x| {
        santa = match x {
            '^' => (santa.0, santa.1 + 1),
            'v' => (santa.0, santa.1 - 1),
            '>' => (santa.0 + 1, santa.1),
            '<' => (santa.0 - 1, santa.1),
            _ => santa,
        };
        if houses.contains_key(&santa) {
            houses.insert(santa, houses[&santa] + 1);
        } else {
            houses.insert(santa, 1);
        }
        acc + 1
    });

    let mut next_houses: std::collections::HashMap<(i32, i32), u32> =
        std::collections::HashMap::new();
    let mut next_santa = (0, 0);
    let mut robo_santa = (0, 0);
    next_houses.insert(next_santa, 2);// robo is here too
    let next_presents = input.chars().enumerate().fold(2, |acc, (i, x)| {
        if i % 2 == 0 {
            next_santa = match x {
                '^' => (next_santa.0, next_santa.1 + 1),
                'v' => (next_santa.0, next_santa.1 - 1),
                '>' => (next_santa.0 + 1, next_santa.1),
                '<' => (next_santa.0 - 1, next_santa.1),
                _ => next_santa,
            };
            if next_houses.contains_key(&next_santa) {
                next_houses.insert(next_santa, next_houses[&next_santa] + 1);
            } else {
                next_houses.insert(next_santa, 1);
            }
        } else {
            robo_santa = match x {
                '^' => (robo_santa.0, robo_santa.1 + 1),
                'v' => (robo_santa.0, robo_santa.1 - 1),
                '>' => (robo_santa.0 + 1, robo_santa.1),
                '<' => (robo_santa.0 - 1, robo_santa.1),
                _ => robo_santa,
            };
            if next_houses.contains_key(&robo_santa) {
                next_houses.insert(robo_santa, next_houses[&robo_santa] + 1);
            } else {
                next_houses.insert(robo_santa, 1);
            }
        }
        acc + 1
    });
    let answer = format!(
        "This year Santa visited {} houses and delivered {} presents.\n\
        Next year Santa and Robo-Santa visited {} houses and delivered {} presents.",
        houses.len(),
        presents,
        next_houses.len(),
        next_presents
    );
    Ok(answer)
}

#[cfg(test)]
mod tests3 {
    use super::*;

    #[test]
    fn test_day3() {
        assert_eq!(
            day3("^v"),
            Ok("This year Santa visited 2 houses and delivered 3 presents.\n\
                Next year Santa and Robo-Santa visited 3 houses and delivered 4 presents.".to_string())
        );
        assert_eq!(
            day3("^>v<"),
            Ok("This year Santa visited 4 houses and delivered 5 presents.\n\
                Next year Santa and Robo-Santa visited 3 houses and delivered 6 presents.".to_string())
        );
        assert_eq!(
            day3("^v^v^v^v^v"),
            Ok("This year Santa visited 2 houses and delivered 11 presents.\n\
                Next year Santa and Robo-Santa visited 11 houses and delivered 12 presents.".to_string())
        );
    }
}
