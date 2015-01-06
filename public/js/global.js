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

// // right now your where_app select method is returning an array of matches, which you then turn into json, and that becomes
// // 'data' in these .get functions you're using here
// 	function populateDropDown(query) {
// 		// call .html on these 3 parameters to write their values to <li>
// 		$.post('/location_search', {query: query}, function(data) {
// 			// var $target = $("li");
// 			$("ul").empty();
// 				if (data.length === 0) {
// 					var element = document.createElement("li");
// 					var $target = $(element);
// 					$("ul").prepend($target);
// 						$target.html("That city is not in the database.");				
// 				} else {
// 					data.forEach(function(ea) {
// 						var element = document.createElement("li");
// 						var $target = $(element);
// 						$("ul").prepend($target);
// 						$target.html(ea.city + ", " + ea.region + ", " + ea.country);
// 					});
// 				}
// 		});
// 	}		

	// right now your where_app select method is returning an array of matches, which you then turn into json, and that becomes
// 'data' in these .get functions you're using here
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
		var $target = $(event.target);
		$target.siblings(".cities").slideUp(300);
	});

 	// $("input").keyup(function(event) {
 	// 	var $target = $(event.target);
 	// 	var query = $target.val();
 	// 	if (query.length >= 3) {
 	// 		dropMenu("input");
 	// 	}
 	// 	else {
 	// 		raiseMenu("input");
 	// 	}
 	// });

 	$("input").keyup(function(event) {
 		var $target = $(event.target);
 		var query = $target.val();
 		if (query.length >= 4) {
 			populateDropDown(query);
 		}
 	});

});

// so now what you want is access to an array of all the locations available to be looked up. one thing you will have to consider is all those
// towns that don't have an observing station and so will be based on nearby stations (i.e. loon lake). these are places you probably could look up on weather underground (for example) but you'd be seeing results from a nearby station