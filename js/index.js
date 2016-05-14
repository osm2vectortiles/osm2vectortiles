/* Navbar-top */

function init() {
  /* Navbar Hamburger */
  var navsideBtn = document.querySelector('.navside-btn');
  if (navsideBtn) {
    navsideBtn.addEventListener(
            'click', openMenu
            );
    var bg = document.createElement('div');
    bg.setAttribute('class', 'navside-bg');
    bg.addEventListener('click', openMenu);
    document.body.appendChild(bg);
  }

  function openMenu() {
    var menu = document.querySelector('.navside').classList;
    if (menu.contains('open')) {
      menu.remove('open');
      bg.classList.remove('open');
    } else {
      menu.add('open');
      bg.classList.add('open');
    }
  }

  /* Navbar-top */
  var navMobileBtn = document.querySelector('#nav-mobile-btn');
  if (navMobileBtn) {
    navMobileBtn.onclick = function() {
      var navMobileNav = document.getElementById('nav-mobile-nav');
      var navMobileBtn = document.getElementById('nav-mobile-btn');
      if (navMobileNav.className === 'active') {
        navMobileNav.className = '';
        navMobileBtn.className = '';
      } else {
        navMobileNav.className = 'active';
        navMobileBtn.className = 'active';
      }
    };
  }

  function getData(url, callback) {
    var xmlHttp = new XMLHttpRequest();
    xmlHttp.onreadystatechange = function() {
        if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
          var data = [];
          var rowArray = xmlHttp.responseText.split('\n');
          for (var i = 1; i < rowArray.length; i++) {
              var currentRow = rowArray[i].split('\t');
              data.push({
                "extract" : currentRow[0],
                "country" : currentRow[1],
                "city" : currentRow[2]
              });
          }
          callback(data);
        }
    }
    xmlHttp.open("GET", url, true); // true for asynchronous
    xmlHttp.send(null);
  }

  var search_countries = document.querySelector('#search_countries');
  if (search_countries) {
    search_countries.onkeyup = function() {
      var searchText = search_countries.value.toLowerCase();
      var countries = document.querySelector('#country').children;
      for(var i = 1; i <= countries.length - 1; ++i) {
        var element = countries[i];
        var countryName = element.children[0].children[0].textContent.toLowerCase();
        if(!( countryName.indexOf(searchText) != -1 )) {
          element.style.display = 'none';
        } else {
          element.style.display = 'block';
        }
      }
    }
  }

  var country = document.querySelector('#country');
  if(country) {
    var template = '<div class="col12 download-item"><div class="col4 download-title" onclick="{{{ link }}}">{{ title }}</div><div class="col2" onclick="{{{ link }}}">{{ size }}</div><div class="col6 clipboard"><input id="{{ extract_name }}" class="clipboard-input" value="{{ url }}"><button class="clipboard-button hint--bottom hint--rounded" data-clipboard-target="#{{ extract_name }}" onclick="setHint(this, \'Copied!\')" onmouseout="setHint(this, \'Copy to clipboard\')"><img src="/img/clipboard-black.svg" class="clipboard-img" alt="Copy to clipboard"></button></div></div>';
    Mustache.parse(template);
    getData("https://raw.githubusercontent.com/osm2vectortiles/osm2vectortiles/master/src/create-extracts/country_extracts.tsv", function(data) {
      data.forEach(function(d) {
        var data = {
          "link": "location.href='https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v1.0/extracts/" + d.extract + ".mbtiles'",
          "url": "https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v1.0/extracts/" + d.extract + ".mbtiles",
          "extract_name": d.extract,
          "title": d.country,
          "size": "20 MB"
        };
        var element = document.createElement("div");
        element.innerHTML = Mustache.render(template, data);
        document.querySelector("#country").appendChild(element);
      });
    });
  }

  var search_cities = document.querySelector('#search_cities');
  if (search_cities) {
    search_cities.onkeyup = function() {
      var searchText = search_cities.value.toLowerCase();
      var cities = document.querySelector('#city').children;
      for(var i = 1; i <= cities.length - 1; ++i) {
        var element = cities[i];
        var countryName = element.children[0].children[0].textContent.toLowerCase();
        if(!( countryName.indexOf(searchText) != -1 )) {
          element.style.display = 'none';
        } else {
          element.style.display = 'block';
        }
      }
    }
  }

  var city = document.querySelector('#city');
  if(city) {
    var template = '<div class="col12 download-item"><div class="col4 download-title" onclick="{{{ link }}}">{{ title }}</div><div class="col2" onclick="{{{ link }}}">{{ size }}</div><div class="col6 clipboard"><input id="{{ extract_name }}" class="clipboard-input" value="{{ url }}"><button class="clipboard-button hint--bottom hint--rounded" data-clipboard-target="#{{ extract_name }}" onclick="setHint(this, \'Copied!\')" onmouseout="setHint(this, \'Copy to clipboard\')"><img src="/img/clipboard-black.svg" class="clipboard-img" alt="Copy to clipboard"></button></div></div>';
    Mustache.parse(template);
    getData("https://raw.githubusercontent.com/osm2vectortiles/osm2vectortiles/master/src/create-extracts/city_extracts.tsv", function(data) {
      data.forEach(function(d) {
        var data = {
          "link": "location.href='https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v1.0/extracts/" + d.extract + ".mbtiles'",
          "url": "https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v1.0/extracts/" + d.extract + ".mbtiles",
          "extract_name": d.extract,
          "title": d.country + ", " + d.city,
          "size": "20 MB"
        };
        var element = document.createElement("div");
        element.innerHTML = Mustache.render(template, data);
        document.querySelector("#city").appendChild(element);
      });
    });
  }

  // instantiate download clipboard
  new Clipboard('.clipboard-button');
}
window.onload = init;

function showPlanet() {
  document.querySelector("#city").style.display = "none";
  document.querySelector("#country").style.display = "none";
  document.querySelector("#planet").style.display = "block";
}

function showCountry() {
  document.querySelector("#city").style.display = "none";
  document.querySelector("#country").style.display = "block";
  document.querySelector("#planet").style.display = "none";
}

function showCity() {
  document.querySelector("#city").style.display = "block";
  document.querySelector("#country").style.display = "none";
  document.querySelector("#planet").style.display = "none";
}

function setHint(element, hint) {
  element.setAttribute("data-hint", hint)
}
