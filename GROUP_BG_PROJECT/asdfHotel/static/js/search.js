function myFunction(){
  var input_data = {
    service: $("#service").val(),
    charge_time: $("#charge_time").val(),
    cost: $("#cost").val(),
  };
  console.log(input_data);
  event.preventDefault();

  $.ajax({
    url: "search_result",
    type: "POST",
    contentType: "application/json",
    dataType: "html",
    data: JSON.stringify(input_data),
    success: function(data){
      $("#demo").html(data);
    },
  });
}
