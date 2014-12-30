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
			if (data.length == 0) {
				console.log("That city is not in the database");
			} else {
				var firstMatch = data[0]; // this is because the matching method returns an array with one element, so that would be array[0]
				console.log("You entered " + firstMatch.city + ", " + firstMatch.region + ". Station ID is " + firstMatch.station );
			// do something with this data;
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
 		if (query.length >= 3) 
 			dropMenu("input");
 		else
 			raiseMenu("input");
 	});

 	$("input").blur(function(event) {
  	var $target = $(event.target);
  	var query = $target.val();
 		fetchRegionAndCountry(query);
 		// send the value of input to the server to return data for that value
 	});

//  	$.ajax({
//   url: '/location_search',
//   data: ,
//   success: success,
//   dataType: dataType
// });

// .load( url [, data ] [, complete ] )
// the value of the input will be what's used to search the 'database' for a matching station

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

// starting an autocomplete menu from scratch. what do you need?
// drop down menu
// regexp? the other guy had a grep command, which is similar, right?
// You can build your own that does not depend on JQuery UI, its a very simple idea of trigger field onchange(), issue an AJAX call to get result that matches what you typed so far, and populate some field with a div or drop down below or near it. And on select of the div or drop down, you populate your trigger field with selected value.
// create a drop down that is populated from where?
// if i'm doing an ajax request to find matches for the dropdown, where is that request being sent?

// what is it you're actually trying to do on this page? i keep losing track of that. you want to be able to input a place - and i think to
// start it should be a place from a preset list, just to simplify - find the weather for that place, then find the matches for that location.
// So, maybe start with either a list with 'links' for each location, that then return (inside the same page) the results for that location.
// Or, you can start with that autocomplete again, which i still think is a good idea because it's a good thing to know and is probably more use
// than links. the input users enter isn't going to be a link, it's going to be an input! the value from that input is going to inform the request
// sent to the server, which fires back the result.

