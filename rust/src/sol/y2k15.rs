pub fn day1(steps: &str) -> Result<String, &str> {
    let result = steps.chars().fold(0, |acc, x| match x {
        '(' => acc + 1,
        ')' => acc - 1,
        _ => acc,
    });

    let answer = result.to_string();
    Ok(answer)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_day1() {
        assert_eq!(day1("(())"), Ok("0".to_string()));
        assert_eq!(day1("()()"), Ok("0".to_string()));
        assert_eq!(day1("((("), Ok("3".to_string()));
        assert_eq!(day1("(()(()("), Ok("3".to_string()));
        assert_eq!(day1("))((((("), Ok("3".to_string()));
        assert_eq!(day1("())"), Ok("-1".to_string()));
        assert_eq!(day1("))("), Ok("-1".to_string()));
        assert_eq!(day1(")))"), Ok("-3".to_string()));
        assert_eq!(day1(")())())"), Ok("-3".to_string()));
    }
}
