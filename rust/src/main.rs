mod sol;
use dotenv::dotenv;

fn main() {
    dotenv().ok();
    let year = match std::env::args().nth(1) {
        Some(year) => match year.parse::<i32>() {
            Ok(year) => year,
            Err(_) => {
                println!("Please provide a valid year");
                std::process::exit(1);
            }
        },
        None => {
            println!("Please provide a year");
            std::process::exit(1);
        }
    };
    let day = match std::env::args().nth(2) {
        Some(day) => match day.parse::<i32>() {
            Ok(day) => day,
            Err(_) => {
                println!("Please provide a valid day");
                std::process::exit(1);
            }
        },
        None => {
            println!("Please provide a day");
            std::process::exit(1);
        }
    };

    let url = format!("https://adventofcode.com/{}/day/{}/input", year, day);

    let cookie = match std::env::var("AOC_SESSION") {
        Ok(cookie) => cookie,
        Err(_) => {
            println!("Please provide a cookie");
            std::process::exit(1);
        }
    };
    let client = reqwest::blocking::Client::new();
    let input = match client
        .get(&url)
        .header("Cookie", format!("session={}", cookie))
        .send()
    {
        Ok(input) => match input.text() {
            Ok(input) => input.to_string(),
            Err(_) => {
                println!("Please provide a valid cookie");
                std::process::exit(1);
            }
        },
        Err(_) => {
            println!("Please provide a valid cookie");
            std::process::exit(1);
        }
    };

    let result = match year{
        2015 => match day {
            1 => sol::y2k15::day1(&input),
            2 => sol::y2k15::day2(&input),
            3 => sol::y2k15::day3(&input),
            _ => {
                println!("I haven't solved that day yet");
                std::process::exit(1);
            }
        },
        _ => {
            println!("I haven't solved that year yet");
            std::process::exit(1);
        }
    };

    match result {
        Ok(answer) => println!("{}", answer),
        Err(err) => println!("{}", err),
    }
}
