//= require jquery
//= require jquery_ujs


$(document).ready(function () {
	initCustomFileInput();

	window.downloadDelta = function (event) {
		event.stopPropagation();
		var xhr;

		if (event.target.dataset.target) {
			var formTag = $(event.target.dataset.target).serialize();
			
			xhr = $.ajax({
		        url: `${event.target.dataset.delta}?${formTag}&format=html`,
		        method: 'GET',
		        xhrFields: {
		            responseType: 'text'
		        },
		        success: function (data) {
		        	downloadFile(data);
		        	$(event.target.dataset.body).load(event.target.dataset.url); 
		        }
		    });
		}

		return false;
		
		function downloadFile(data) {
			var disposition = xhr.getResponseHeader('content-disposition');
	        var matches = /"([^"]*)"/.exec(disposition);
	        var filename = (matches != null && matches[1] ? matches[1] : 'file.json');

	        if (filename.endsWith('.json')) {
	        	data = JSON.stringify(data, null, 2)
	        }

		    const file = new File([data], { type: "application/json" });
	       	var a = document.createElement('a');
	        var url = window.URL.createObjectURL(file);
	        a.href = url;
	        a.download = filename;
	        document.body.append(a);
	        a.click();
	        a.remove();
	        window.URL.revokeObjectURL(url);
		}
	}
})


function showMessage(id, message, type) {
	$(id).html(`<div class="alert-message alert-${type}">${message}</div>`);
	setTimeout(function() {
		$(id).html('');
	}, 4000);
}

function initCustomFileInput() {
	// Add the following code if you want the name of the file appear on select
	$(".custom-file-input").on("change", function() {
	  var fileName = $(this).val().split("\\").pop();
	  $(this).siblings(".custom-file-label").addClass("selected").html(fileName);
	});
}

