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

// don't like that now the menu flicks on and off when you're typing
	function populateDropDown(query) {
		raiseMenu();
		$.post('/location_search', {query: query}, function(data) {
				$("#search_results").html($(data.html));
				dropMenu();					
		});
	}

	function printLocation(query) {
		$.post('/location_search', {query: query}, function(data) {
			$("#query_location").html(data.first_match);
		});
	}

	$("#locations").on("select focus", function(event) {
		 if (this.value=="Start typing your location") this.value="";
	});

	$("#locations").blur(function(event) {
		raiseMenu();
	});

// right now this doesn't work because the query data is based on your partials, which returns more data than you want. you'll
// want it to use just the final selection of the user.
	$("#locations").blur(function(event) {
		$target = $(event.target);
		query = $target.val();
		printLocation(query);
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
// you're going to want to use something like the haversine formula to find the closest valid station