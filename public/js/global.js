$(document).ready(function() {


  // 	function createMarker(position, map, title, id) {

	 //    var marker = new google.maps.Marker({
	 //      position: position,
	 //      map: map,
	 //      title: title,
	 //      id: id,
	 //    });

  //   	matchMarkers.push(marker);
  //   	return marker;
  // 	}

	 //  function createMarkerInfo(content) {
	 //    var markerInfo = new google.maps.InfoWindow({
	 //      content: content
	 //    });
	 //    return markerInfo;
	 //  }

	 //  function addAListener(marker, markerInfo){
	 //    marker.addListener('click', function() {
	 //      markerInfo.open(map, marker);
	 //    });
	 //  }

		// if (matchMarkers.length !== 0) {
		// 	addMarkers(matchMarkers);
		// }

	function dropMenu() {
		$('.search-results').show();
	};

	function raiseMenu() {
		$('.search-results').hide();
	};

	function populateDropDown(query) {
		raiseMenu();
		$.get('/location_search', {query: query}, function(data) {
				$('.search-results').html($(data.html));
				dropMenu();	
		});
	};

	var timeout;

 	$('.location-input').keyup(function(event) {

 		var $target = $(event.target);
 		var $targetParent = $target.closest('.location-menu');

// for down arrow
 		if (event.keyCode == 40) {
 			var currentlySelectedListItem = $targetParent.find('.drop-down-item.selected');
 			var listItemToSelect = currentlySelectedListItem.next('.drop-down-item');

// checks if selection is on last item in list
 			if ($(listItemToSelect).index() == -1) {
 				listItemToSelect = $targetParent.find('.drop-down-item').first();
 				$(currentlySelectedListItem).removeClass('selected');
 				$(listItemToSelect).addClass('selected');
 			}
// for every other position on the list
 			else {
 				$(currentlySelectedListItem).removeClass('selected');
 				$(listItemToSelect).addClass('selected');
 			}

// for up arrow navigation. when you use up arrow it also sends the input cursor back to the beginning
 		} else if (event.keyCode == 38) {

 			var currentlySelectedListItem = $targetParent.find('.drop-down-item.selected');
 			var listItemToSelect = currentlySelectedListItem.prev('.drop-down-item');

 			if ($(currentlySelectedListItem).index() == 0) {
 				$(currentlySelectedListItem).removeClass('selected');
 				listItemToSelect = $targetParent.find('.drop-down-item').last();
 				$(listItemToSelect).addClass('selected');
 			} else {
 				$(currentlySelectedListItem).removeClass('selected');
 				$(listItemToSelect).addClass('selected');
 			}

 		} else if (event.keyCode == 13) {

 			var currentlySelectedLink = $targetParent.find('.drop-down-item.selected a');
 			if ($target.val().length > 2) {
	 			if (currentlySelectedLink.length > 0) {
	 				window.location.href = currentlySelectedLink.attr('href');
	 			}
 			}
 		} else {

// for all other keys
	 		var handleKeyup = function() {
	 			var query = $target.val();
	 			if (query.length >= 3) {
	 				populateDropDown(query);
	 			} else {
	 				raiseMenu();
	 			}

	 		};
	 		
	 		clearTimeout(timeout);
	 		timeout = setTimeout(handleKeyup, 200);
	 	}
    
 	});

});