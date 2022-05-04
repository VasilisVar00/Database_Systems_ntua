function customer_visit(){
  var input_data = {
    nfc_id: $("#nfc_id").val(),
  };
  console.log(input_data);
  event.preventDefault();

  $.ajax({
    url: "customers_result",
    type: "POST",
    contentType: "application/json",
    dataType: "html",
    data: JSON.stringify(input_data),
    success: function(data){
      $("#demo").html(data);
    },
  });
}
