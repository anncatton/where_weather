$(document).ready(function() {

	// var EnterKey = 13;

	// function on_enter() {
	//   $(target).on("keyup", function(e) {
	//   if(e.which == EnterKey)
	//     $(this).trigger("enter");
	// 	});
	// }

	function dropMenu(target) {
		var $target = $(target);
		$target.siblings(".cities").slideDown(300);
	}

	function raiseMenu(target) {
		var $target = $(target);
		$target.siblings(".cities").slideUp(300);
	}

// right now your where_app select method is returning an array of matches, which you then turn into json, and that becomes
// 'data' in these .get functions you're using here
	function populateDropDown(query) {
		// call .html on these 3 parameters to write their values to <li>
		$.post('/location_search', {query: query}, function(data) {
			// var $target = $("li");
				if (data.length === 0) {
					var element = document.createElement("li");
					var $target = $(element);
					$("ul").append($target);
					$target.html("That city is not in the database.");				
				} else {
					data.forEach(function(ea) {
					var element = document.createElement("li");
					var $target = $(element);
					$("ul").append($target);
						$target.html(ea.city + ", " + ea.region + ", " + ea.country);
					});
				}
		});
	}		

	$("#locations").on("select focus", function(event) {
		 if (this.value=="Start typing your location") this.value="";
	});

	$("#locations").blur(function(event) {
		var $target = $(event.target);
		$target.siblings(".cities").slideUp(300);
	});

 	$("input").keyup(function(event) {
 		var $target = $(event.target);
 		var query = $target.val();
 		if (query.length >= 3) {
 			dropMenu("input");
 		}
 		else {
 			raiseMenu("input");
 		}
 	});

// so now i'm thinking that what you want to happen now, is instead of writing the data to the console, you would use
// that to populate your dropdown menu
// maybe make the function thats doing that into a separate function to call once a set of conditions has been met
 	$("input").keyup(function(event) {
 		var $target = $(event.target);
 		var query = $target.val();
 		if (query.length >= 4) {
 			populateDropDown(query);
 		}
 	});

	// $("#current_conditions").mouseenter(function(event) {
	// 	var $city = $("input").val();
	// 	console.log("You entered " + $city);
	// });

// $( "#results" ).on( "mouseenter", {
//     city: "Toronto",
//     region: "ON, Canada"
// }, function( event ) {
//     console.log( "event data: " + event.data.city + ", " + event.data.region );
// });

// so in this case the separate events become the arguments for that particular element
	// $("#results").on({
	// 	mouseenter: function() {
	// 		alert("You entered results!");
	// 	},
	// event: function() {
	// 	do something();
	// },
	// 	mouseleave: function() {
	// 		alert("You left results!");
	// 	},
	// 	click: function() {
	// 		alert("You clicked on results!");
	// 	}
	// });

});

// so now what you want is access to an array of all the locations available to be looked up. one thing you will have to consider is all those
// towns that don't have an observing station and so will be based on nearby stations (i.e. loon lake). these are places you probably could look up on weather underground (for example) but you'd be seeing results from a nearby station
