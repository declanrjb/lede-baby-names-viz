function dict_vals(dict) {
    var values = Object.keys(dict).map(function(key){
        var float_form = parseFloat(dict[key]);
        if (isNaN(float_form)) {
          return dict[key];
        } else {
          return float_form;
        }
    });
    return values;
  }

function updateMap(year,name,topology) {
    console.log('updating map');
    var file_name = 'names/' + name + '/' + year.toString() + '.csv';
    d3.csv(file_name).then(function(result) {
      for (var i=0; i<result.length; i++) {
        result[i] = dict_vals(result[i]);
      }
      // Create the chart
      Highcharts.mapChart('container', {
          chart: {
              map: topology
          },

          title: {
            text: null
        },

          subtitle: {
              text: 'Source map: <a href="https://code.highcharts.com/mapdata/countries/us/us-all.topo.json">United States of America</a>'
          },

          mapNavigation: {
              enabled: true,
              buttonOptions: {
                  verticalAlign: 'bottom'
              }
          },

          colorAxis: {
              min: 0,
              minColor: '#ffffff',
              maxColor: '#000000'
          },

          series: [{
              data: result,
              name: 'Popularity of Name in this Region',
              states: {
                  hover: {
                      color: '#BADA55'
                  }
              },
              dataLabels: {
                  enabled: true,
                  format: '{point.name}'
              }
          }]
      });
    });
}

  Number.prototype.clamp = function(min, max) {
    return Math.min(Math.max(this, min), max);
  };
  var nameSelect = document.querySelector('#single-select');

    d3.csv('names/names_list.csv').then(function(result) {
        for (var i=0; i<result.length; i++) {
            result[i] = dict_vals(result[i])[0];
        }
        var allNames = result;

        newOption = document.createElement('option');
        newOption.setAttribute('value','michael');
        newOption.textContent = 'Michael';
        nameSelect.appendChild(newOption);

        for (var i=0; i<allNames.length; i++) {
            if (!(allNames[i] == 'Michael')) {
                newOption = document.createElement('option');
                newOption.setAttribute('value',allNames[i].toLowerCase());
                newOption.textContent = allNames[i];
                nameSelect.appendChild(newOption);
            } 
        }
    })

async function asyncCall() {
    const topology = await fetch(
        'https://code.highcharts.com/mapdata/countries/us/us-all.topo.json'
    ).then(response => response.json());

    // Prepare demo data. The data is joined to map using value of 'hc-key'
    // property by default. See API docs for 'joinBy' for more info on linking
    // data and map.
    var year = 1910;
    updateMap(year,nameSelect.selectedOptions[0].value,topology);

    var shuttle = document.querySelector('.shuttle');
    var shuttleText = document.querySelector('.shuttle-text');
    var shuttleProgress = 0;

    nameSelect.onclick = function() {
        console.log('hello world');
        updateMap(year,nameSelect.selectedOptions[0].value,topology);
    }

  addEventListener("wheel", (event) => {
    if ((event.deltaY >= 10)) {
      year += 1;
      year = year.clamp(1910,2023);
    } else if ((event.deltaY <= -10)) {
      year -= 1;
      year = year.clamp(1910,2023);
    }

    if (-10 <= event.deltaY <= 10) {
        shuttleProgress = (year - 1910) / 113;
        shuttleHeight = 20 + (shuttleProgress * 650);
        shuttle.style.top = shuttleHeight.toString() + 'px';
        shuttleText.textContent = year;

        updateMap(year,nameSelect.selectedOptions[0].value,topology);
    }
  });
}

asyncCall();


   
