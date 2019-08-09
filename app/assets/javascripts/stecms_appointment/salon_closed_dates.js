date_ = new Date();

initializeServiceForm = function() {
	startDate('#closed_date_start_date');
	endDate('#closed_date_end_date');

	$('button.modal_close').on('click', function(e) {
	  e.preventDefault();
	  $('.modal-backdrop').remove();
	  // $('.modal-body').not('[dom="delete"]').remove();
	  $('.modal').modal('hide');
	});
};

startDate = function(selector) {
	$(selector).datepicker({
    minDate: date_,
    //format: 'DD, MM d yy',
    format: "dd-mm-yyyy",
    onClose: function(selectedDate) {
      $("#closed_date_end_date").datepicker("option","minDate",selectedDate );
    }
	});
};

endDate = function(selector) {
	$(selector).datepicker({
  	minDate: date_,
  	//format: 'DD, MM d yy'
  	format: "dd-mm-yyyy"
	});
};

$('.modal').on('hidden', function () {
  $('.new-form').html('');
  $('.edit-form').html('');
});