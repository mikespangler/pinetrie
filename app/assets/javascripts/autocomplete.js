$( document ).ready(function(){

  $( "#form" ).keyup(function( event ) {
    var form_input = $("#form").val();
    console.log( form_input );

    $.post( "/people", { user_input: form_input })
      .done(function( redis_list ) {
        console.log( redis_list );
        $( "#redis_list" ).text(redis_list);
      });
  });
});

