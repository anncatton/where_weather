$(document).ready(function() {

// this is good
	$("#locations").on("select focus", function(event) {
		 if (this.value=="Start typing your location") this.value="";
	});

	// $("#locations").focus(function(event) {
	// 	var $target = $(event.target);
	// 	$target.siblings('.cities').slideDown(300);
	// });

	function dropMenu(target) {
		var $target = $(target);
		$target.siblings('.cities').slideDown(300);
	}

	function raiseMenu(target) {
		var $target = $(target);
		$target.siblings(".cities").slideUp(300);
	}

		$("#locations").blur(function(event) {
	 		var $target = $(event.target);
	 		$target.siblings('.cities').slideUp(300);
	 	});
// maybe: need it to slideUp if $key.length < 3
 	$("input").keyup(function(event) {
 		var $target = $(event.target);
 		var $key = $target.val();
 		if ($key.length >= 3) 
 			dropMenu("input");
 		else
 			raiseMenu("input");
 	});
 	// 
 		// so now you need it to look for a match after you've got the 3 characters.
 		// the event fires after the 4th key is pressed, so i guess the value doesn't change until the next keypress

// when does a variable need to be created as a jquery object? i would assume just when you want to perform jquery actions on it...?
	$("#current_conditions").mouseenter(function(event) {
		var $city = $("input").val();
		console.log("You entered " + $city);
	});

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

// this does return the alert window twice
// $("input").blur(function(){
// 	alert("You entered " + this.value + "!");
// });

	var city_locations = [
		{ value: "Toronto", data: "Ontario, Canada" },
		{ value: "Paris", data: "France" },
		{ value: "Calgary", data: "Alberta, Canada" },
		{ value: "Loon Lake", data: "Saskatchewan, Canada" },
		{ value: "Dallas", data: "Texas, United States" },
		{ value: "Rome", data: "Italy" },
		{ value: "Istanbul", data: "Turkey" },
		{ value: "Copenhagen", data: "Denmark" },
		{ value: "Punta Catalina", data: "Chile" },
		{ value: "Mumbai", data: "India" },
		{ value: "Vancouver", data: "British Columbia, Canada" },
		{ value: "Kuala Lumpur", data: "Malaysia" },
		{ value: "Moscow", data: "Russia" },
		{ value: "Abu Dhabi", data: "United Arab Emirates" },
		{ value: "Tokyo", data: "Japan" },
		{ value: "Monrovia", data: "Liberia" },
		{ value: "Munich", data: "Germany" },
		{ value: "New York", data: "New York, United States" },
		{ value: "San Francisco", data: "California, United States" },
		{ value: "Brisbane", data: "Queensland, Australia" },
		{ value: "Halifax", data: "Nova Scotia, Canada" },
		{ value: "McMurdo Station", data: "Antarctica" },
		{ value: "Tabarka", data: "Tunisia" },
		{ value: "Brasov", data: "Romania" },
		{ value: "Edinburgh", data: "Scotland, United Kingdom" },
		{ value: "London", data: "England, United Kingdom" },
		{ value: "Shanghai", data: "China" },
		{ value: "Atalaya", data: "Peru"}
	];

});

// starting an autocomplete menu from scratch. what do you need?
// drop down menu
// regexp? the other guy had a grep command, which is similar, right?
// minimum characters (3)
// You can build your own that does not depend on JQuery UI, its a very simple idea of trigger field onchange(), issue an AJAX call to get result that matches what you typed so far, and populate some field with a div or drop down below or near it. And on select of the div or drop down, you populate your trigger field with selected value.
// create a drop down that is populated from where?
// if i'm doing an ajax request to find matches for the dropdown, where is that request being sent?

// what is it you're actually trying to do on this page? i keep losing track of that. you want to be able to input a place - and i think to
// start it should be a place from a preset list, just to simplify - find the weather for that place, then find the matches for that location.
// So, maybe start with either a list with 'links' for each location, that then return (inside the same page) the results for that location.
// Or, you can start with that autocomplete again, which i still think is a good idea because it's a good thing to know and is probably more use
// than links. the input users enter isn't going to be a link, it's going to be an input! the value from that input is going to inform the request
// sent to the server, which fires back the result.

