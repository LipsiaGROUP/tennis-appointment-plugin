mobileDefault = function(selector) {
  $(selector).intlTelInput({
    defaultCountry: "it",
    preferredCountries: ["ae", "us", "gb"]
  });
};

checkboxDays = function(selector) {
  $(selector).on('click', function() {
    cbDestroy = $(this).parents('td').find('.cb-destroy-hour');
    
    if ($(this).is(':checked')) 
      cbDestroy.prop('checked', false);
    else
      cbDestroy.prop('checked', true);
  })
};

validateServiceForm = function(selector, selectorTab) {
  elements = $(selector + ' input.validate');
  for (var t = 0; t < elements.length; t++) validateFormField(elements[t]);
  form = $(selector), form.find(".error").length > 0 && $(selectorTab + "a:first").tab("show");
}

$('#new_operator_button').on('click', function() {
  $('#newEmployee').modal({backdrop: 'static', keyboard: false});
  mobileDefault('#operator_mobile');
});

validateOperatorForm = function(formId){
  if(window.ClientSideValidations === undefined) window.ClientSideValidations = {};

  window.ClientSideValidations.disabled_validators = [];
  window.ClientSideValidations.number_format = { "separator": ".", "delimiter" : "," };

  if(window.ClientSideValidations.patterns === undefined) window.ClientSideValidations.patterns = {};

  window.ClientSideValidations.patterns.numericality= /^(-|\+)?(?:\d+|\d{1,3}(?:\,\d{3})+)(?:\.\d*)?$/;

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
      "operator[operator_name]": { 
        "presence": [{ "message": "obbligatorio" }] 
      },
      "operator[email]": { 
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
      },
      "operator[role]": {
        "presence": [
          { "message": "obbligatorio" }
        ]
      }
    }
  };
}

$('#editEmployee').on('hidden.bs.modal', function () { 
  try {
    $("form#edit_employee").resetClientSideValidations();
  } catch(err) {}
});

$('#newEmployee').on('hidden.bs.modal', function () { 
  $("form#new_employee").get(0).reset();
  $('#newEmployee .help-inline').remove();

  try {
    $("form#new_employee").resetClientSideValidations();
  } catch(err) {}
});

checkboxDays('.cb-active-day');

$(document).ready(function(){
  validateOperatorForm('new_employee');
});