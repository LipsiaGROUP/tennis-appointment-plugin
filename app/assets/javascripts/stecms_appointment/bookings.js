initializeServiceForm = function() {
  showDatePicker('input[id^=service_booking_schedule_date]');
  validationAlert('#save-event');
};

initializeBusyTimeForm = function() {
  showDatePicker('input[id^=employee_schedule_status_busy_date_start]');
}

showDatePicker = function(selector) {
  date_ = new Date();
  $(selector).datepicker({minDate:date_, dateFormat:'DD, d MM yy'})
  // setSelectedDateTime("service");
};

validationAlert = function(selector) {
  $(selector).on('click',function(){
    if ( !($('#service_booking_service_id').val().length > 0 &&
      !isNaN($('#service_booking_service_id').val())) ) {
        bootbox.alert("Selezionare un trattamento");
        //alert('Selezionare un trattamento');
        return false;
    }

    if ($('#service_booking_booking_type').val().length > 0 || ($('#service_booking_user_id').val().length > 0 && !isNaN($('#service_booking_user_id').val()))) {
        return true;
    } else {
        bootbox.alert("Selezionare un cliente");
        //alert('Selezionare un cliente');
        return false;
    }
  });
};

validateBusyTimeForm = function(formId){
  if(window.ClientSideValidations === undefined) window.ClientSideValidations = {};
  window.ClientSideValidations.disabled_validators = [];
  window.ClientSideValidations.number_format = { "separator": ".", "delimiter": "," };

  if(window.ClientSideValidations.patterns === undefined) window.ClientSideValidations.patterns = {};

  window.ClientSideValidations.patterns.numericality = /^(-|\+)?(?:\d+|\d{1,3}(?:\,\d{3})+)(?:\.\d*)?$/;

  if(window.ClientSideValidations.forms === undefined) window.ClientSideValidations.forms = {};

  window.ClientSideValidations.forms[formId] = {
    "type": "SimpleForm::FormBuilder",
    "error_class": "help-inline",
    "error_tag": "span", 
    "wrapper_error_class": "error", 
    "wrapper_tag": "div",
    "wrapper_class": "control-group",
    "wrapper": "bootstrap",
    "validators": {
      "booking[schedule_date]": {
        "presence": [
          { "message": "obbligatorio" }
        ]
      },
      "booking[operator_id]": { 
        "presence": [
          { "message": "obbligatorio" }
        ]
      }
    }
  }
};

setBookingDateTime = function(e) {
  weekDaysIt = ['Domenica', 'Lunedi', 'Martedi', 'Mercoledi', 'Giovedi', 'Venerdi', 'Sabato']
  monthNamesIt = ['Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno', 'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre']

  date = dayDate, day = date.getDay(), date_ = date.getDate(), hour = date.getHours(), mins = date.getMinutes(), h = date.getHours(), h = h < 10 ? "0" + h : h, m = date.getMinutes(), m = m < 10 ? "0" + m : m, s = date.getSeconds(), s = s < 10 ? "0" + s : s, t = h + ":" + m + ":" + s;
  var i = (formatDate(date.toString()), weekDaysIt[date.getDay()] + ", " + date.getDate() + " " + monthNamesIt[date.getMonth()] + " " + date.getFullYear());
  "busy" == e ? (busyEndTime = setBusyEndTime(date, 1), null == selectedEmployee && (date = $("#booking_calendar").fullCalendar("getDate"), t = setStartTime(date), busyEndTime = setBusyEndTime(date, 2)), $("#employee_schedule_status_busy_date_start").val(i), $("#employee_schedule_status_busy_time_start_5i").val(t), $("#employee_schedule_status_busy_time_end_5i").val(busyEndTime)) : (null == selectedEmployee && (date = $("#booking_calendar").fullCalendar("getDate"), t = setStartTime(date)), $("#" + e + "_booking_schedule_date").val(i), $("#" + e + "_booking_schedule_time_5i").val(t))
}

alertStatusNoShow = function() {
  bootbox.alert("L\'appuntamento non &egrave; ancora trascorso. Non puoi selezionare questa opzione.");
  removeLoadingOverlay();
}

$('#btnNewBooking, #btnNewBusyTime').on('click', function(){
  $('#new-booking').modal('hide');
});

$("#blockTime").on('hidden.bs.modal', function(){
  $("#blockTime .new-block-form").html('');
});

$('#newAppointment').on('hidden', function () {
  $('#newCustomer').remove();
  $('#editCustomer').remove();
  $('.new-form form').remove();
  selectedEmployee = null;
});