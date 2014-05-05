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

  function try_local_before_redirecting(path) {
    api_url = "http://10.0.1.2:9595" + path

    $.get( api_url, function() {
      alert( "success" );
    }).fail(function() {
      alert( "error" );
    });
  }

  $("a#ajax-test").click(function() {
    path = $(this).attr('href');
    try_local_before_redirecting(path);
  });

});
