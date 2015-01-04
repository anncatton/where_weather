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

	function fetchRegionAndCountry(query) {
		$.get('/location_search', {query: query}, function(data) {
			if (data.length === 0) {
				console.log("That city is not in the database");
			} else {
				data.forEach(function(element) {
					console.log("You entered " + element.city + ", " + element.region + ". Station ID is " + element.station);
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

 	$("input").keyup(function(event) {
 		var $target = $(event.target);
 		var query = $target.val();
 		if (query.length >= 4) {
 			fetchRegionAndCountry(query);
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
