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
    let total_paper: u32 = input.lines().fold(0, |acc, x| {
        let mut dims: Vec<u32> = x.split('x').map(|x| match x.parse::<u32>() {
            Ok(x) => x,
            Err(_) => 0,
        }).collect();
        dims.sort();
        let faces = [dims[0] * dims[1], dims[1] * dims[2], dims[2] * dims[0]];
        acc + 2 * faces.iter().sum::<u32>() + match faces.iter().min() {
            Some(x) => x,
            None => &0,
        }
    });
    let total_paper = total_paper.to_string();
    Ok(total_paper)
}

#[cfg(test)]
mod tests2 {
    use super::*;

    #[test]
    fn test_day2() {
        assert_eq!(day2("2x3x4"), Ok("58".to_string()));
        assert_eq!(day2("1x1x10"), Ok("43".to_string()));
        assert_eq!(day2("2x3x4\n1x1x10"), Ok("101".to_string()));
        assert_eq!(day2("2x3x4\n1x1x10\n2x3x4"), Ok("159".to_string()));
    }
}
