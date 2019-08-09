initializeCustomerForm = function (){
  // $('a.event-link').on('click', function() {
  //   var type = $(this).attr('dom');

  //   if (type === 'new')
  //     $('#newCustomer').modal({ backdrop: 'static', keyboard: false});
  //   else
  //     $('#editCustomer').modal({ backdrop: 'static', keyboard: false});
  // });

  $('#new-customer-button').on('click', function() {
    $('#newCustomer').modal({ backdrop: 'static', keyboard: false});
  });

  $('#edit-customer-button').on('click', function() {
    $('#editCustomer').modal({ backdrop: 'static', keyboard: false});
  });

  $('#customer_birthday, #edit_customer_birthday').datepicker({
    changeMonth: true,
    changeYear: true,
    yearRange: new Date().getFullYear()-80 + ":" + new Date().getFullYear(),
    dateFormat: 'DD, MM d, yy'
  });

  $('.birthday').datepicker({
    changeMonth: true,
    changeYear: true,
    yearRange: new Date().getFullYear()-80 + ":" + new Date().getFullYear(),
    dateFormat: 'dd-mm-yy'
  });

  $('#customer_name').val($('#service_booking_user_id').val())
  $(".customer-cell").intlTelInput({defaultCountry: "it", preferredCountries: ["ae", "us", "gb"]});

  $('#male').click(function() {
    $('#user_gender_true').prop("checked", true);
    // $('input[type="radio"]').not(':checked').prop("checked", true);
  });

  $('#female').click(function() {
    $('#customer_gender_false').prop("checked", true);
    // $('input[type="radio"]').not(':checked').prop("checked", true);
  });

  $('.delete-customer').on('click', function() {
    $('#cancel-modal').modal({ backdrop: 'static', keyboard: false});
    var id = $('#customer_user_id').val();
    var name = $('[dom="name"]').val();
    var surname = $('[dom="surname"]').val();
    $('[dom="detail"]').text(name + ' ' + surname);
    $('[dom="delete_customer"]').attr('href', '/customers/' + id);
  });

  validateServiceForm = function(selector, selectorTab) {
    elements = $(selector + ' input.validate');
    for (var t = 0; t < elements.length; t++) validateFormField(elements[t]);
    form = $(selector), form.find(".error").length > 0 && $(selectorTab + "a:first").tab("show");
  }
  
  $('#newCustomer').on('hidden', function () {
    $('#new_customer .error').removeClass('error')
    $('.help-inline').remove();
    $('form#new_customer').get(0).reset();
  });
}

validateCustomerForm = function(formId){
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
      "customer[name]": {
        "presence": [
          { "message": "obbligatorio" }
        ]
      },
      "customer[surname]": { 
        "presence": [
          { "message": "obbligatorio"}
        ]
      },
      "customer[email]": {
        "format": [
          { 
            "message": "non valido", 
            "with": { 
              "source": "^[^@\\s]+@([^@\\s]+\\.)+[^@\\s]+$",
              "options": "" 
            },
            "allow_blank": true
          }
        ]
      }
    }
  };
}

$('#editCustomer').on('hidden.bs.modal', function () { 
  $("form#edit_customer").get(0).reset();
  $('#editCustomer .help-inline').remove();

  try {
    $("form#edit_customer").resetClientSideValidations();
  } catch(err) {}
});

$('#newCustomer').on('hidden.bs.modal', function () { 
  $("form#new_customer").get(0).reset();
  $('#newCustomer .help-inline').remove();

  try {
    $("form#new_customer").resetClientSideValidations();
  } catch(err) {}
});

$("#upload_excel_file").change(function () {
  $("#excel-format-notice .notice").empty(); // To remove the previous error message

  var file = this.files[0];

  if(file){
    var ext = file.name.match(/\.([^\.]+)$/)[1]
    var fileType = file.type;
    
    if((ext == 'xls' && (file.type === '' || file.type === "application/vnd.ms-excel")) || 
      (ext == 'xlsx' && fileType == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')){
      $('#excel-format-notice').addClass('hide');
      $("form#upload_excel input[type='submit']").removeAttr('disabled');
      return true;
    } else {
      $('#excel-format-notice').removeClass('hide');
      $("form#upload_excel input[type='submit']").attr('disabled', 'disabled');
      return false;
    }
  }
});

initializeCustomerForm();

$(document).ready(function(){
  validateCustomerForm('new_customer');
  validateCustomerForm('edit_customer');
});