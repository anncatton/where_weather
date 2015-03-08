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

	var timeout;
 	$(".location_input").keyup(function(event) {

 		var $target = $(event.target);
 		var $targetParent = $target.closest(".location_menu");

 		if (event.keyCode == '40') {
 			var currentlySelectedListItem = $targetParent.find(".result.selected");
 			var listItemToSelect = currentlySelectedListItem.next('.result');

// checks if selection is on last item in list
 			if ($(listItemToSelect).index() == -1) {
 				listItemToSelect = $targetParent.find(".result").first();
 				$(currentlySelectedListItem).removeClass("selected");
 				$(listItemToSelect).addClass("selected");
 			}
// for every other position on the list
 			else {
 				$(currentlySelectedListItem).removeClass("selected");
 				$(listItemToSelect).addClass("selected");
 			}

// for up arrow navigation
 		} else if (event.keyCode == '38') {

	 			var currentlySelectedListItem = $targetParent.find(".result.selected");
	 			var listItemToSelect = currentlySelectedListItem.prev('.result');

	 			if ($(currentlySelectedListItem).index() == 0) {
	 				$(currentlySelectedListItem).removeClass("selected");
	 				listItemToSelect = $targetParent.find(".result").last();
	 				$(listItemToSelect).addClass("selected");
	 			} else {
	 				$(currentlySelectedListItem).removeClass("selected");
	 				$(listItemToSelect).addClass("selected");
	 			}
	 		} else {

// for all other keys
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

});