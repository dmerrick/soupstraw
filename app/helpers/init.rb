# enable redirections with little messages
Soupstraw.helpers Sinatra::RedirectWithFlash

# helpers specific to soupstraw
require_relative 'soupstraw_helpers'
Soupstraw.helpers SoupstrawHelpers

# enable partials
require_relative 'render_partial'
Soupstraw.helpers RenderPartial

# enable bitcoin methods
require_relative 'bitcoin'
Soupstraw.helpers Bitcoin

# enable healthcheck methods
require_relative 'healthchecks'
Soupstraw.helpers Healthchecks
