initializeServiceForm = function() {
  discountValidFrom('.service_discount_valid_from');
  discountValidTo('.service_discount_valid_to');
  discountPublicFrom('.service_discount_public_from');
  discountPublicTo('.service_discount_public_to');
  wordsLength('#service_description');
  displayVariantClick('#new-service-pricing-link', 'new');
  displayVariantClick('#service-pricing-list .item', 'edit');

  promoDays('.service_promo_days_valid');
  deleteTreatment('.delete-treatment');
  selectedGender('#serviceGender button');
  activeDay('.cb-active-day');

  $('button.modal_close').on('click', function(e) {
    e.preventDefault();
    $('.modal-backdrop').not('#new-service-pricing-level').remove();
    $('.modal-body').not('[dom="delete"]').remove();
    $('.modal').not('#new-service-pricing-level').modal('hide');
    removeLoadingOverlay();
  });
};

discountValidFrom = function(selector) {
  $(selector).datepicker({
    changeMonth:true,
    format:"dd-mm-yyyy",
    minDate:0, //today
    onClose: function(selectedDate) {
      $(this).find(".service_discount_valid_to").datepicker("option","minDate",selectedDate );
    }
  });
};

discountValidTo = function(selector) {
  $(selector).datepicker({
    defaultDate:"+1d",
    changeMonth:true,
    format:"dd-mm-yyyy",
    minDate:0, //today
    onClose: function(selectedDate) {
      $(".service_discount_valid_from").datepicker("option","maxDate",selectedDate);
      $(".service_discount_public_from").datepicker("option","maxDate",selectedDate);
      $(".service_discount_public_to").datepicker("option","maxDate",selectedDate);
    }
  });
};

discountPublicFrom = function(selector) {
  $(selector).datepicker({
    //defaultDate: "+1w",
    changeMonth:true,
    format:"dd-mm-yyyy",
    minDate:0, //today
    onClose: function(selectedDate) {
      $(".service_discount_public_to").datepicker("option","minDate",selectedDate );
    }
  });
};

discountPublicTo = function(selector) {
  $(selector).datepicker({
    defaultDate:"+1d",
    changeMonth:true,
    format:"dd-mm-yyyy",
    minDate:0, //today
    onClose: function(selectedDate) {
      $(".service_discount_public_from").datepicker("option","maxDate",selectedDate);
    }
  });
};

promoDays = function(selector) {
  $(selector).datepicker({
    format:"dd-mm-yyyy",
    onClose: function(selectedDate) {
      if($(this).hasClass('promo_from')) {
        $(this).closest('.input-daterange').find('.promo_to').datepicker("option","minDate",selectedDate);
      }
    }
  });
};

wordsLength = function(selector) {
  $(selector).on("keyup keydown", function() {
    return $(this).closest('div.controls').find('span span').html(1000 - $(this).val().length);
  });
};

displayVariantClick = function(selector, action) {
  $(document).on('click', selector, function() {
    $('form#new_service_pricing_level').get(0).reset();
    $('#new_service_pricing_level .control-group.error').removeClass('error')
    $('form#new_service_pricing_level').find('.help-inline').remove();

    if (action == 'new') {
      var duration = $('#service_pricing_level_duration_value');
      var price = $('#service_pricing_level_price');
      
      if (duration.val().length > 0) {
        $('#new-service-pricing-level').modal({ backdrop: 'static', keyboard: false});
        duration.closest(".control-group").removeClass("error");
        $('#delete').hide();
      } else {
        duration.closest(".control-group").addClass("error");
      }
    } else {
      $('#element_id').val($(this).attr('id'));
      $('#new-service-pricing-level').modal({ backdrop: 'static', keyboard: false});
      $('#delete').show();
      setVariantValue($(this))
    }
  });
};

getVariantValue = function(data) {
  console.log(data);
  $('.pricing_level_id').val(data['pricing_level']);
  $('.service_pricing_level_price').val(data['price']);
  $('.service_pricing_level_duration_value').val(data['duration_value']);
  $('.service_pricing_level_sale_price').val(data['sale_price']);
  $('.service_discount_valid_from').val(data['discount_valid_from']);
  $('.service_discount_valid_to').val(data['discount_valid_to']);
  $('.service_discount_public_from').val(data['discount_public_from']);
  $('.service_discount_public_to').val(data['discount_public_to']);
  $('#delete-service-pricing-level').data('item', data['element_id']);

  if(data['pricing_level'] == 'Standard'){
    $(".select-variant-level").addClass('hide');
  }else{
    $(".select-variant-level").removeClass('hide');
  }

};

setVariantValue = function(variant) {
  var data = {
    "pricing_level": variant.find(".pricing-level-name").data("pricing-level"),
    "price": variant.find(".pricing-level-price").data("price"),
    "sale_price": variant.find(".sale_price").data("sale-price"),
    "duration_value": variant.find(".pricing-level-duration").data("duration-value"),
    "duration_unit": variant.find(".pricing-level-duration").data("duration-unit"),
    "discount_valid_from": variant.find(".pricing-level-valid-from").data("discount-valid-from"),
    "discount_valid_to": variant.find(".pricing-level-valid-to").data("discount-valid-to"),
    "discount_public_from": variant.find(".pricing-level-public-from").data("discount-public-from"),
    "discount_public_to": variant.find(".pricing-level-public-to").data("discount-public-to"),
    "element_id": variant.attr("id")
  };
      
  getVariantValue(data)
};

deleteTreatment = function(selector) {
  $(selector).on('click', function() {
    $('#cancel-modal').modal({ backdrop: 'static', keyboard: false});
    service = $(this).parents('.service').not('.ui-sortable');
    
    var name =
      service.find('[dom="name"]').text() || $('#treatment_des_treatment').val();
    var duration =
      service.find('[dom="duration"]').text() || (($('#service_pricing_level_duration_value').val()) + ' min');
    var price =
      service.find('[dom="price"]').text() || ('\u20ac ' + $('#service_pricing_level_price').val());
    var id = service.data('group') || $('#treatment_s_treatment_id').val();

    $('[dom="detail"]').text(name + ' (' + price + ', durata ' + duration + ')');
    $('[dom="delete_treatment"]').attr('href', '/settings/services/' + id)
  });
};


validateServiceForm = function(selector, selectorTab) {
  elements = $(selector + ' input.validate, ' + selector + ' select.validate');
  for (var t = 0; t < elements.length; t++) validateFormField(elements[t]);
  form = $(selector), form.find(".error").length > 0 && $(selectorTab + " a:first").tab("show");
};

selectedGender = function(selector) {
  $(selector).on('click', function() {
    var gender = $(this).eq(0).data("value");
    $('[name="treatment[gender]"]:checked').removeAttr("checked"), $("input[value=" + gender + "]").prop("checked", !0)
  });
};

activeDay = function(selector) {
  $(selector).on('click', function() {
    cbDestroy = $(this).parent().find('.cb-destroy-day');
    
    if ($(this).is(':checked')) 
      cbDestroy.prop('checked', false);
    else
      cbDestroy.prop('checked', true);
  });
};

deleteTreatment('.delete-treatment');

$('.edit-treatment-btn').on('click', function(){
  loadingOverlay();
});