$(document).ready(function() {

	$(".location_input").on("select focus", function(event) {
		 if (this.value=="Start typing your location") this.value="";
	});

	function dropMenu() {
		$(".search_results").show();
	};

	function raiseMenu() {
		$(".search_results").hide();
	};

// this for the drop down menu
	function populateDropDown(query) {
		raiseMenu();
		$.get('/location_search', {query: query}, function(data) {
				$(".search_results").html($(data.html));
				dropMenu();	
		});
	};

	// function checkKey(event) {

 //    // if (event.keyCode == '38') {
 //    //     // up arrow
 //    // }
 //    if (event.keyCode == '40') {
 						// down arrow
 //    }
	// }

	var timeout;
 	$(".location_input").keyup(function(event) {

 		var $target = $(event.target);

 		if (event.keyCode == '40') {
 			var $targetParent = $target.closest(".location_menu");
 			var currentlySelectedListItem = $targetParent.find(".result.selected");
 			var listItemToSelect = currentlySelectedListItem.next('.result');

 			if ($(listItemToSelect).index() == -1 ) {
 				listItemToSelect = $targetParent.find(".result").first();
 				$(currentlySelectedListItem).removeClass("selected");
 				$(listItemToSelect).addClass("selected");
 			}
 			else {
 				$(currentlySelectedListItem).removeClass("selected");
 				$(listItemToSelect).addClass("selected");
 			}

 		} else {

	 		var handleKeyup = function() {
	 			var query = $target.val();
	 			if (query.length >= 3) {
	 				populateDropDown(query);
	 			}
	 		};
	 		clearTimeout(timeout);
	 		timeout = setTimeout(handleKeyup, 200);
	 	}
    
 	});

// need to put in a function for using arrow and enter keys to select from dropdown list
// check to see if down arrow key has been pressed - which number is down arrow?
// if no list item is selected, select the first one
// if the first one is selected, select the next one
// when an item is selected, you add a "selected" class to that list item

});