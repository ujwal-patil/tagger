//= require jquery
//= require jquery_ujs


$(document).ready(function () {
	initCustomFileInput();

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
	}, 4000);
}

function initCustomFileInput() {
	// Add the following code if you want the name of the file appear on select
	$(".custom-file-input").on("change", function() {
	  var fileName = $(this).val().split("\\").pop();
	  $(this).siblings(".custom-file-label").addClass("selected").html(fileName);
	});
}
