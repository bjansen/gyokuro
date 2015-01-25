getDataFromServer = function() {
	var xhr = new XMLHttpRequest();
	xhr.open('GET', '/rest/duck/talk', true);
	xhr.onload = function (e) {
	  if (xhr.readyState === 4) {
	    if (xhr.status === 200) {
	      document.getElementById('response').innerHTML = 'Server said "' + xhr.responseText + '"';
	    } else {
	      console.error(xhr.statusText);
	    }
	  }
	};
	
	xhr.onerror = function (e) {
	  console.error(xhr.statusText);
	};
	
	xhr.send(null);
}