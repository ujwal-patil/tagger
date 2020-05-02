
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

	$(".downoad-delta").on('click', function (event) {
		event.stopPropagation();
		if (event.target.dataset.target) {
			var formTag = $(event.target.dataset.target).serialize();
			event.target.href = `${event.target.dataset.url}?${formTag}`;
		}
	});
})


function showMessage(id, message, type) {
	$(id).html(`<div class="alert-message alert-${type}">${message}</div>`);
	setTimeout(function() {
		$(id).html('');
	}, 2000);
}

