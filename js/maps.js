document.addEventListener("DOMContentLoaded", function() {
	var bright = document.getElementById("vector-bright");
	if(bright) {
		if (!mapboxgl.supported()) {
			var vectorMapContainer = document.getElementById("vector-map");
			vectorMapContainer.innerHTML = 'Your browser does not support Mapbox GL. Either your browser does not support WebGL or it is disabled, please check <a href="https://get.webgl.org/">http://get.webgl.org</a> for more information.'
		} else {
			var vectorMap = new mapboxgl.Map({
			    container: 'vector-map',
			    style: 'https://raw.githubusercontent.com/osm2vectortiles/mapbox-gl-styles/master/styles/bright-v9-cdn.json',
			    center: [8.5456, 47.3739],
			    zoom: 11
			}).addControl(new mapboxgl.Navigation());
			vectorMap.scrollZoom.disable();
			var selectedStyle = 0;
		}
	}

	if(bright) {
		bright.onclick = function(e) {
			e.preventDefault();
	        e.stopPropagation();
	        vectorMap.setStyle('https://raw.githubusercontent.com/osm2vectortiles/mapbox-gl-styles/master/styles/bright-v9-cdn.json');
			document.querySelector("#bright").style.display = "block";
			document.querySelector("#basic").style.display = "none";
			document.querySelector("#streets").style.display = "none";
			document.querySelector("#dark").style.display = "none";
			document.querySelector("#light").style.display = "none";
			selectedStyle = 0;
		}
	}
	var basic = document.getElementById("vector-basic");
	if(basic) {
		basic.onclick = function(e) {
			e.preventDefault();
	        e.stopPropagation();
	        vectorMap.setStyle('https://raw.githubusercontent.com/osm2vectortiles/mapbox-gl-styles/master/styles/basic-v9-cdn.json');
			document.querySelector("#bright").style.display = "none";
			document.querySelector("#basic").style.display = "block";
			document.querySelector("#streets").style.display = "none";
			document.querySelector("#dark").style.display = "none";
			document.querySelector("#light").style.display = "none";
			selectedStyle = 1;
		}
	}
	var streets = document.getElementById("vector-streets");
	if(streets) {
		streets.onclick = function(e) {
			e.preventDefault();
	        e.stopPropagation();
	        vectorMap.setStyle('https://raw.githubusercontent.com/osm2vectortiles/mapbox-gl-styles/master/styles/streets-v9-cdn.json');
			document.querySelector("#bright").style.display = "none";
			document.querySelector("#basic").style.display = "none";
			document.querySelector("#streets").style.display = "block";
			document.querySelector("#dark").style.display = "none";
			document.querySelector("#light").style.display = "none";
			selectedStyle = 2;
		}
	}
	var dark = document.getElementById("vector-dark");
	if(dark) {
		dark.onclick = function(e) {
			e.preventDefault();
	        e.stopPropagation();
	        vectorMap.setStyle('https://raw.githubusercontent.com/osm2vectortiles/mapbox-gl-styles/master/styles/dark-v9-cdn.json');
			document.querySelector("#bright").style.display = "none";
			document.querySelector("#basic").style.display = "none";
			document.querySelector("#streets").style.display = "none";
			document.querySelector("#dark").style.display = "block";
			document.querySelector("#light").style.display = "none";
			selectedStyle = 3;
		}
	}
	var light = document.getElementById("vector-light");
	if(light) {
		light.onclick = function(e) {
			e.preventDefault();
	        e.stopPropagation();
	        vectorMap.setStyle('https://raw.githubusercontent.com/osm2vectortiles/mapbox-gl-styles/master/styles/light-v9-cdn.json');
			document.querySelector("#bright").style.display = "none";
			document.querySelector("#basic").style.display = "none";
			document.querySelector("#streets").style.display = "none";
			document.querySelector("#dark").style.display = "none";
			document.querySelector("#light").style.display = "block";
			selectedStyle = 4;
		}
	}
	// instantiate map clipboard
	new Clipboard('.map-clipboard-button', {
	    text: function(trigger) {
	        return document.getElementsByClassName("gist-data")[selectedStyle].innerText;
	    }
	});
});

function showCopiedHint() {
	var mapClipboardText = document.querySelector("#map-clipboard-text")
	mapClipboardText.innerText = "Copied to clipboard!";
	setTimeout(function(){
		mapClipboardText.innerText = "Copy example";
	}, 800);
}
