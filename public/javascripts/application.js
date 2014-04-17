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

});
