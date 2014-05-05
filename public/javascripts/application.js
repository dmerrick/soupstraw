$(document).ready(function() {

  // open external links in a new window
  hostname = window.location.hostname
  $("a[href^=http]")
    .not("a[href*='" + hostname + "']")
    .addClass('link external')
    .attr('target', '_blank');

  // make iPad wall remote more responsive
  $(function() {
    FastClick.attach(document.body);
  });

  // show the wall remote tooltip
  // (if we add more text, consider using a popover)
  $('#wall-remote-tooltip').tooltip('show');


  // try connecting to the API endpoint on the local network,
  // and if that fails, redirect to the path
  function try_local_before_redirecting(path) {

    // try the local API endpoint first
    api_url = "http://10.0.1.2:9595" + path
    //alert(api_url);

    // FIXME: maybe try getJSON()?
    $.ajax({
      url: api_url,
      dataType: "jsonp",
      success: function (data) {

        // local request worked,
        // so we need to stop right here
        alert("ajax worked; stopping");

      },
      failure: function (data) {

        // local request failed,
        // so redirect to the path
        alert("ajax failed");
        //window.location = path;

      }
    });

  } // end try_local_before_redirecting()

  // actually attach the function to the buttons
  // this is just an example selector for now
  // (only the volume up button uses it right now)
  $("a#ajax-test").click(function(e) {
    // FIXME: use this magic? ...
    //e.stopPropagation();
    path = $(this).attr('href');
    try_local_before_redirecting(path);
    // FIXME: ... or this magic?
    //return false;
  });

  function try_local_before_redirecting(path) {
    api_url = "http://10.0.1.2:9595" + path

    $.get( api_url, function() {
      alert( "success" );
    }).fail(function() {
      alert( "error" );
    })
  }

  $("a#ajax-test").click(function() {
    path = $(this).attr('href')
    try_local_before_redirecting(path);
  });

});
