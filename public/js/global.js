$(document).ready(function() {

	// var EnterKey = 13;

	// function on_enter() {
	//   $(target).on("keyup", function(e) {
	//   if(e.which == EnterKey)
	//     $(this).trigger("enter");
	// 	});
	// }

	$("#location_input").on("select focus", function(event) {
		 if (this.value=="Start typing your location") this.value="";
	});

	function dropMenu() {
		$("#search_results").show();
	};

	function raiseMenu() {
		$("#search_results").hide();
	};

// this for the drop down menu
	function populateDropDown(query) {
		raiseMenu();
		$.get('/location_search', {query: query}, function(data) {
				$("#search_results").html($(data.html));
				dropMenu();	
		});
	};

	var timeout;
 	$("#location_input").keyup(function(event) {

 		var handleKeyup = function() {
    	var $target = $(event.target);
 			var query = $target.val();
 			if (query.length >= 3) {
 				populateDropDown(query);
 			}
 		};
 		clearTimeout(timeout);
 		timeout = setTimeout(handleKeyup, 200);
    
 	});

});
