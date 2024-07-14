# lede-baby-names-viz
## Methodology
For each name, state, and year, analysts calculated the percentage of all U.S. babies given that name that year who were 
born in that state. The equivalent rate for the percentage of all babies born in the U.S. that year who were born in that state regardless of name was also calculated in order to adjust for population density. For example, a given row might contain the percentage of Michaels born in California
versus the percentage of all babies born in California. Dividing the first by the second yielded the relative 'regionality' of the
name that year: ie, the degree to which that name was more or less common in that state compared to the country as a whole.

## Data Source
State-specific data courtesy of the U.S. Social Security Administration 
(https://www.ssa.gov/oact/babynames/limits.html)

## Attribution
Base map courtesy of Highcharts (https://jsfiddle.net/gh/get/jquery/1.11.0/highslide-software/highcharts.com/tree/master/samples/mapdata/countries/us/us-all)

## Further Development
No mobile version exists as of now, and one should be built time allowing, perhaps with a horizontal slider
instead of a vertical scroll effect.
