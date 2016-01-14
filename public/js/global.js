$(document).ready(function() {

	$(".location_input").on("select focus", function(event) {
		// if ($(this).prop('placeholder') == 'Start typing your location') {
		// 	$(this).value ="";
		// 	dropMenu();
		// }
		 if (this.placeholder=="Start typing your location") this.value="";
		 dropMenu();
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

// for down arrow
 		if (event.keyCode == 40) {
 			var currentlySelectedListItem = $targetParent.find(".drop-down-item.selected");
 			var listItemToSelect = currentlySelectedListItem.next('.drop-down-item');

// checks if selection is on last item in list
 			if ($(listItemToSelect).index() == -1) {
 				listItemToSelect = $targetParent.find(".drop-down-item").first();
 				$(currentlySelectedListItem).removeClass("selected");
 				$(listItemToSelect).addClass("selected");
 			}
// for every other position on the list
 			else {
 				$(currentlySelectedListItem).removeClass("selected");
 				$(listItemToSelect).addClass("selected");
 			}

// for up arrow navigation. when you use up arrow it also sends the input cursor back to the beginning
 		} else if (event.keyCode == 38) {

 			var currentlySelectedListItem = $targetParent.find(".drop-down-item.selected");
 			var listItemToSelect = currentlySelectedListItem.prev('.drop-down-item');

 			if ($(currentlySelectedListItem).index() == 0) {
 				$(currentlySelectedListItem).removeClass("selected");
 				listItemToSelect = $targetParent.find(".drop-down-item").last();
 				$(listItemToSelect).addClass("selected");
 			} else {
 				$(currentlySelectedListItem).removeClass("selected");
 				$(listItemToSelect).addClass("selected");
 			}

 		} else if (event.keyCode == 13) {
 			var currentlySelectedLink = $targetParent.find(".drop-down-item.selected a");
 			window.location = currentlySelectedLink.attr("href");
 			
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

// raises menu before you can click link. will this matter once you have selection without cursor?
	// $(".location_input").blur(function(event) {
	// 	raiseMenu();
	// });

});