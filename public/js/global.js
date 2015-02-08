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
// don't like that now the menu flicks on and off when you're typing - i think this is just because it's running slow, for every
// keyup there's a get request
// would you be able to do version that just did one request, got an array of possible matches, then shifted off the ones that
// no longer match after each subsequent keyup?
	function populateDropDown(query) {
		raiseMenu();
		console.log('location_search request');
		$.get('/location_search', {query: query}, function(data) {
				console.log('location_search has responded');
				$("#search_results").html($(data.html));
				dropMenu();	
		});
	};

	var timeout;
	console.log("setting up keypress handler");
 	$("#location_input").keypress(function(event) { // this might be slowing webpage down cuz it sends a search request for every keyup

 		var handleKeyup = function() {
 			console.log("handling keyup");
    	var $target = $(event.target);
 			var query = $target.val();
 			if (query.length >= 3) {
 				populateDropDown(query);
 			}
 		};
 		console.log("clear timeout");
 		clearTimeout(timeout);
 		console.log("setting timeout");
 		timeout = setTimeout(handleKeyup, 1000);
    
 	});

});

// do you use the same approach in js as you would with css - that you try to stick to class and id references, not element types (like <h3>
// or <span>)?
// i guess also you have to look at the particular conditions in which you're applying styles - does it make more sense to apply a style to a
// certain class or id, or would it work better if applied all of a certain element?
