
var csrf_token = $('meta[name="csrf-token"]').attr('content');
$.ajaxPrefilter(function(options, originalOptions, jqXHR){
    if (options.type.toLowerCase() === "post" || options.type.toLowerCase() === "put") {
        // initialize `data` to empty string if it does not exist
        options.data = options.data || "";

        // add leading ampersand if `data` is non-empty
        options.data += options.data?"&":"";

        // add _token entry
        options.data += "authenticity_token=" + encodeURIComponent(csrf_token);
    }
});


$(document).ready(function () {
	$(".delta-slider").slider();

	$(".generate-tag").on('click', function (event) {
		event.stopPropagation();
		$.ajax({
			url: event.target.href,
			type: 'put',
			success: function(result){
		    	showMessage(event.target.dataset.target, result.message, 'success')
		  	},
		  	error: function (result) {
		  		showMessage(event.target.dataset.target, result.message, 'danger')
		  	}
		});

		return false;
	});
})


function showMessage(id, message, type) {
	$(id).html(`<div class="alert-message alert-${type}">${message}</div>`);
	setTimeout(function() {
		$(id).html('');
	}, 2000);
}

