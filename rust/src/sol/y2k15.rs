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
