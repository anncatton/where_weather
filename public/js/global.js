$(document).ready(function() {

	// var EnterKey = 13;

	// function on_enter() {
	//   $(target).on("keyup", function(e) {
	//   if(e.which == EnterKey)
	//     $(this).trigger("enter");
	// 	});
	// }

	function dropMenu() {
		$("#search_results").show();
	}

	function raiseMenu() {
		$("#search_results").hide();
	}

	function populateDropDown(query) {
		raiseMenu();
		$.post('/location_search', {query: query}, function(data) {
				$("#search_results").html($(data.html));
				dropMenu();					
		});
	}

	$("#locations").on("select focus", function(event) {
		 if (this.value=="Start typing your location") this.value="";
	});

	$("#locations").blur(function(event) {
		raiseMenu();
	});

 	$("input").keyup(function(event) {
 		var $target = $(event.target);
 		var query = $target.val();
 		if (query.length >= 3) {
 			populateDropDown(query);
 		}
 	});

});

// so now what you want is access to an array of all the locations available to be looked up. one thing you will have to consider is all those
// towns that don't have an observing station and so will be based on nearby stations (i.e. loon lake). these are places you probably could look up on weather underground (for example) but you'd be seeing results from a nearby station