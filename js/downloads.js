function init() {
	function getExtractMetadata(url, callback) {
		var xmlHttp = new XMLHttpRequest();
		xmlHttp.onreadystatechange = function() {
		    if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
		      var data = [];
		      var rowArray = xmlHttp.responseText.split('\n');
		      for (var i = 1; i < rowArray.length - 1; i++) {
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

	function getBucketMetadata(url, callback) {
		var xmlHttp = new XMLHttpRequest();
		xmlHttp.onreadystatechange = function() {
		    if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
		      callback(xmlHttp.responseXML.getElementsByTagName("Contents"));
		    }
		}
		xmlHttp.open("GET", url, true); // true for asynchronous
		xmlHttp.send(null);
	}

	function bytesToSize(bytes) {
	    var sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
	    if (bytes == 0) return 'n/a';
	    var i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)));
	    if (i == 0) return bytes + ' ' + sizes[i];
	    return (bytes / Math.pow(1024, i)).toFixed(1) + ' ' + sizes[i];
	};

	function getSizeByExtractName(bucketMetadata, extractName) {
		for(var i = 0; i < bucketMetadata.length; i++) {
			var bucketMetadataName = bucketMetadata[i].children[0].innerHTML;
			if(bucketMetadataName === extractName) {
				return bytesToSize(bucketMetadata[i].children[3].innerHTML);
			}
		}
		return "0 MB";
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
		var url = "https://s3-eu-west-1.amazonaws.com/osm2vectortiles-downloads/metadata.xml"; // https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/?prefix=v1.0/extracts/
		getBucketMetadata(url, function(bucketMetadata) {
			var template = '<div class="col12 download-item"><div class="col4 download-title" onclick="{{{ link }}}">{{ title }}</div><div class="col2" onclick="{{{ link }}}">{{ size }}</div><div class="col6 clipboard"><input id="{{ extract_name }}" class="clipboard-input" value="{{ url }}"><button class="clipboard-button hint--bottom hint--rounded" data-clipboard-target="#{{ extract_name }}" onclick="setHint(this, \'Copied!\')" onmouseout="setHint(this, \'Copy to clipboard\')"><img src="/img/clipboard-black.svg" class="clipboard-img" alt="Copy to clipboard"></button></div></div>';
			Mustache.parse(template);
			getExtractMetadata("https://raw.githubusercontent.com/osm2vectortiles/osm2vectortiles/master/src/create-extracts/country_extracts.tsv", function(data) {
				data.forEach(function(d) {
					var data = {
					  "link": "location.href='https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v1.0/extracts/" + d.extract + ".mbtiles'",
					  "url": "https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v1.0/extracts/" + d.extract + ".mbtiles",
					  "extract_name": d.extract,
					  "title": d.country,
					  "size": getSizeByExtractName(bucketMetadata, "v1.0/extracts/" + d.extract + ".mbtiles")
					};
					var element = document.createElement("div");
					element.innerHTML = Mustache.render(template, data);
					document.querySelector("#country").appendChild(element);
				});
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
		var url = "https://s3-eu-west-1.amazonaws.com/osm2vectortiles-downloads/metadata.xml";
		getBucketMetadata(url, function(bucketMetadata) {
			var template = '<div class="col12 download-item"><div class="col4 download-title" onclick="{{{ link }}}">{{ title }}</div><div class="col2" onclick="{{{ link }}}">{{ size }}</div><div class="col6 clipboard"><input id="{{ extract_name }}" class="clipboard-input" value="{{ url }}"><button class="clipboard-button hint--bottom hint--rounded" data-clipboard-target="#{{ extract_name }}" onclick="setHint(this, \'Copied!\')" onmouseout="setHint(this, \'Copy to clipboard\')"><img src="/img/clipboard-black.svg" class="clipboard-img" alt="Copy to clipboard"></button></div></div>';
			Mustache.parse(template);
			getExtractMetadata("https://raw.githubusercontent.com/osm2vectortiles/osm2vectortiles/master/src/create-extracts/city_extracts.tsv", function(data) {
				data.forEach(function(d) {
					var data = {
					  "link": "location.href='https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v1.0/extracts/" + d.extract + ".mbtiles'",
					  "url": "https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v1.0/extracts/" + d.extract + ".mbtiles",
					  "extract_name": d.extract,
					  "title": d.country + ", " + d.city,
					  "size": getSizeByExtractName(bucketMetadata, "v1.0/extracts/" + d.extract + ".mbtiles")
					};
					var element = document.createElement("div");
					element.innerHTML = Mustache.render(template, data);
					document.querySelector("#city").appendChild(element);
				});
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