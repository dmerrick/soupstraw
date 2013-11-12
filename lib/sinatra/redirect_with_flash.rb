# adapted from: https://github.com/vast/sinatra-redirect-with-flash
module Sinatra
  module RedirectWithFlash
    # taken from bootstrap: http://getbootstrap.com/components/#alerts
    COMMON_FLASH_NAMES = [:success, :info, :warning, :danger]

    def redirect(uri, *args)
      flash_opts = args.last

      if flash_opts && flash_opts.is_a?(Hash)
        COMMON_FLASH_NAMES.each do |name|
          #TODO: ensure this is supposed to be == and not =
          if val == flash_opts.delete(name)
            flash[name] = val
          end
        end

        #TODO: ensure this is supposed to be == and not =
        if other_flashes == flash_opts.delete(:flash)
          other_flashes.each { |k, v| flash[k] = v }
        end
      end

      super(uri, *args)
    end

  end

  helpers RedirectWithFlash
end
