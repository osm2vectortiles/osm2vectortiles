document.addEventListener("DOMContentLoaded", function() {
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

	function formatTimestamp(timestampString) {
		var weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
		var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
		var date = new Date(timestampString);
		return weekdays[date.getUTCDay()] + ", " + date.getUTCDate() + " " + months[date.getUTCMonth()] + " " + date.getUTCFullYear() + " at " + date.getUTCHours() + ":" + date.getUTCMinutes() + " UTC";
	}

	function getSizeByExtractName(bucketMetadata, extractName) {
		for(var i = 0; i < bucketMetadata.length; i++) {
			var bucketMetadataName = bucketMetadata[i].children[0].innerHTML;
			if(bucketMetadataName === extractName) {
				return bytesToSize(bucketMetadata[i].children[3].innerHTML);
			}
		}
		return "0 MB";
	}

	function addKeyupEventListener(element, selector) {
		element.onkeyup = function() {
		  var searchText = element.value.toLowerCase();
		  var items = document.querySelector(selector).children;
		  for(var i = 1; i <= items.length - 1; ++i) {
		    var item = items[i];
		    var itemName = item.children[0].children[0].textContent.toLowerCase();
		    if(!( itemName.indexOf(searchText) != -1 )) {
		      item.style.display = 'none';
		    } else {
		      item.style.display = 'block';
		    }
		  }
		}
	}

	function renderItems(url, template, bucketMetadata, selector) {
		getExtractMetadata(url, function(data) {
			data.forEach(function(d) {
				if(selector === "#city-list") {
					var title = d.country + ", " + d.city;
				} else {
					var title = d.country;
				}
				var data = {
				  "link": "location.href='https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v2.0/extracts/" + d.extract + ".mbtiles'",
				  "url": "https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v2.0/extracts/" + d.extract + ".mbtiles",
				  "extract_name": d.extract,
				  "title": title,
				  "size": getSizeByExtractName(bucketMetadata, "v2.0/extracts/" + d.extract + ".mbtiles")
				};
				var element = document.createElement("div");
				element.innerHTML = Mustache.render(template, data);
				document.querySelector(selector).appendChild(element);
			});
		});
	}

	var search_countries = document.querySelector('#search_countries');
	var search_cities = document.querySelector('#search_cities');
	if (search_cities && search_countries) {
		addKeyupEventListener(search_countries, "#country-list");
		addKeyupEventListener(search_cities, "#city-list");
	}

	var country = document.querySelector('#country-list');
	var city = document.querySelector('#city-list');
	if(country && city) {
		var metadataUrl = "https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/?prefix=v2.0/extracts/";
		getBucketMetadata(metadataUrl, function(bucketMetadata) {
			document.querySelector("#timestamp").innerHTML = formatTimestamp(bucketMetadata[0].children[1].innerHTML);
			var template = '<div class="col12 download-item"><div class="col4 download-title" onclick="{{{ link }}}">{{ title }}</div><div class="col2" onclick="{{{ link }}}">{{ size }}</div><div class="col6 clipboard"><input id="{{ extract_name }}" class="clipboard-input" value="{{ url }}"><button class="clipboard-button hint--bottom hint--rounded" data-clipboard-target="#{{ extract_name }}" onclick="setHint(this, \'Copied!\')" onmouseout="setHint(this, \'Copy to clipboard\')"><img src="/img/clipboard-black.svg" class="clipboard-img" alt="Copy to clipboard"></button></div></div>';
			Mustache.parse(template);
			var extractUrl = "https://raw.githubusercontent.com/osm2vectortiles/osm2vectortiles/master/src/create-extracts/";
			renderItems(extractUrl + "country_extracts.tsv", template, bucketMetadata, "#country-list");
			renderItems(extractUrl + "city_extracts.tsv", template, bucketMetadata, "#city-list");
		});
	}

	// instantiate download clipboard
	new Clipboard('.clipboard-button');
});

var downloadSections = ["city", "country", "planet"];
function showSection(selectedSection) {
	downloadSections.forEach(function(downloadSection) {
		if(selectedSection === downloadSection) {
			document.querySelector("#" + downloadSection + "-nav").style.backgroundColor = "#F3F3F3";
			document.querySelector("#" + downloadSection + "-list").style.display = "block";
		} else {
			document.querySelector("#" + downloadSection + "-nav").style.backgroundColor = "#FBFBFB";
			document.querySelector("#" + downloadSection + "-list").style.display = "none";
		}
	});
}

function setHint(element, hint) {
  element.setAttribute("data-hint", hint)
}
