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
			window.selectedStyle = 0;
		}
	}

	var basic = document.getElementById("vector-basic");
	if(bright && basic) {
		var styles = ["#bright", "#basic"];
		var styleUrl = "https://raw.githubusercontent.com/osm2vectortiles/mapbox-gl-styles/master/styles/";
		addOnClickEventListener(bright, vectorMap, styleUrl + "bright-v9-cdn.json", 0, styles);
		addOnClickEventListener(basic, vectorMap, styleUrl + "basic-v9-cdn.json", 1, styles);
	}

	// instantiate map clipboard
	new Clipboard('.map-clipboard-button', {
	    text: function(trigger) {
	        return document.getElementsByClassName("gist-data")[selectedStyle].innerText;
	    }
	});
});

function addOnClickEventListener(element, vectorMap, styleUrl, selectedStyle, styles) {
	element.onclick = function(e) {
		e.preventDefault();
        e.stopPropagation();
        vectorMap.setStyle(styleUrl);
        window.selectedStyle = selectedStyle;
        for(var i = 0; i < styles.length; i++) {
			if(selectedStyle === i) {
				document.querySelector(styles[i]).style.display = "block";
			} else {
				document.querySelector(styles[i]).style.display = "none";
			}
        }
	}
}

function showCopiedHint() {
	var mapClipboardText = document.querySelector("#map-clipboard-text")
	mapClipboardText.innerText = "Copied to clipboard!";
	setTimeout(function(){
		mapClipboardText.innerText = "Copy example";
	}, 800);
}
