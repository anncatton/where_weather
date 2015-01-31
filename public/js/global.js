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

// this for the drop down menu
// don't like that now the menu flicks on and off when you're typing
	function populateDropDown(query) {
		raiseMenu();
		$.get('/location_search', {query: query}, function(data) {
				$("#search_results").html($(data.html));
				dropMenu();					
		});
	}

// this is to display the chosen location in the current locations div
	function printLocation(query) {
		$.get('/location_search', {query: query}, function(data) {
			$("#query_location").html(data.first_match);
		});
	}

	$("#location_input").on("select focus", function(event) {
		 if (this.value=="Start typing your location") this.value="";
	});

	$("#location_input").blur(function(event) {
		$target = $(event.target);
		query = $target.val();
		if (query.length > 0) {
			printLocation(query);
		}
		else {
			$("#query_location").html("");
		}
		raiseMenu();
	});

 	$("#location_input").keyup(function(event) {
 		var $target = $(event.target);
 		var query = $target.val();
 		if (query.length >= 3) {
 			populateDropDown(query);
 		}
 	});

});

// do you use the same approach in js as you would with css - that you try to stick to class and id references, not element types (like <h3>
// or <span>)?
// i guess also you have to look at the particular conditions in which you're applying styles - does it make more sense to apply a style to a
// certain class or id, or would it work better if applied all of a certain element?

// so now what you want is access to an array of all the locations available to be looked up. one thing you will have to consider is all those
// towns that don't have an observing station and so will be based on nearby stations (i.e. loon lake). these are places you probably could look up on weather underground (for example) but you'd be seeing results from a nearby station
// you're going to want to use something like the haversine formula to find the closest valid station