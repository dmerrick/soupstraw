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
  $('#wall-remote-tooltip').tooltip('show')

});
