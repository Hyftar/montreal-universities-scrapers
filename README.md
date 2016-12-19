# University programs / courses scrapers

This is a collection of University website scrapers/crawlers to get data on all the
courses such as title, course number, number of credits for a program / course, url to the
course webpage, and level of the course.

## Usage

To use the scripts, just pull the data from the website (as HTML) using `ruby crawler.rb`
in the respective folder. Then, execute the *parser* using `ruby parser.rb` to extract
the information from `data.html` and to generate a *JSON* file.

## Disclaimer

- There's a high chance that one of the University updates their website meaning it will
likely break its respective *crawler* / *parser* / *scraper*. I will attempt to maintain
them so they always work with the most recent website updates, otherwise, feel free
to fork the repo and create a pull request!

- While using the crawlers is legal, I am not responsible for any lawsuit obtained using one of the crawlers. Please use at your
own risk.

## License

This software is licensed under the [MIT license](https://opensource.org/licenses/MIT).
