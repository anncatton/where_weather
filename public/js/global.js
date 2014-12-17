 $(document).ready(function() {

	$("input").focus(function(event) {
		 if (this.value=="Start typing your location") this.value="";
	});

	var city_locations = [
		{ value: "Toronto", data: "Ontario, Canada" },
		{ value: "Paris", data: "France" },
		{ value: "Calgary", data: "Alberta, Canada" },
		{ value: "Loon Lake", data: "Saskatchewan, Canada" },
		{ value: "Dallas", data: "Texas, United States" },
		{ value: "Rome", data: "Italy" },
		{ value: "Istanbul", data: "Turkey" },
		{ value: "Copenhagen", data: "Denamrk" },
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

 		// 	// position: { my : "left top", at: "left bottom" },

		// "my" the corner of the drop down menu; "at" is which corner of the input field the menu is aligned at

	$( "#locations" ).autocomplete({
    source: city_locations,
    minLength: 2,
    select: function( event, ui ) {
      alert( ui.item ?
        "Selected: " + ui.item.value + ", " + ui.item.data :
        "Nothing selected, input was " + this.value );
    },
    messages: {
     	noResults: '',
    }
  });

});