getDataFromServer = function() {
	// Output manually written in Response
	sendRequest('/rest/duck/talk', function(xhr) {
		document.getElementById('response').innerHTML = 'Server said "' + xhr.responseText + '"';
	});

	// Object automatically serialized to JSON and written in Response
	sendRequest('/rest/duck/actions', function(xhr) {
      document.getElementById('response2').innerHTML = 'A duck can ' + xhr.responseText;
	});
}

sendRequest = function(url, callback) {
	var xhr = new XMLHttpRequest();
	xhr.open('GET', url, true);
	xhr.onload = function (e) {
	  if (xhr.readyState === 4) {
	    if (xhr.status === 200) {
	      callback(xhr);
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