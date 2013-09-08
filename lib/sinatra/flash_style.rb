# monkey-patched to use twitter bootstrap alerts
module Sinatra
  module Flash
    module Style
      def styled_flash(key=:flash)
        return "" if flash(key).empty?
        id = (key == :flash ? "flash" : "flash_#{key}")
        messages = flash(key).collect {|message| "  <div class='alert alert-#{message[0]}'>#{message[1]}</div>\n"}
        "<div id='#{id}'>\n" + messages.join + "</div>"
      end
    end
  end
end