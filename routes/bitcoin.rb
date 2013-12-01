class Soupstraw < Sinatra::Base

  # redirect to to path specified in application.yml
  get '/bitcoins?/?' do
    redirect settings.app[:bitcoin_path]
  end

  # combine the total_earned data for two rigs
  # this allows the chart load to faster via AJAX
  get '/bitcoins/*+*/total_earned.json' do |id_a, id_b|
    content_type :json

    rig_a = MiningRig.find(id_a)
    rig_b = MiningRig.find(id_b)

    # use the same graph interval for both graphs
    graph_a = rig_a.average_earned_graph_data
    graph_b = rig_b.average_earned_graph_data(rig_a.effective_graph_interval)

    # this iterates over the graphed data for the first
    # rig, and adds to it the data from the second rig
    graph_data = graph_a.reduce({}) do |hash, key_and_value|
      date           = key_and_value.first
      total_earned_a = key_and_value.last
      total_earned_b = graph_b[date] || 0.0
      hash[date]     = total_earned_a + total_earned_b
      hash
    end

    graph_data.to_json
  end

  # matchs /bitcoins/1+2
  # (or another combination of rig_ids)
  get '/bitcoins/*+*' do |id_a, id_b|
    # get the last snapshots for both rigs
    snapshot_a = MiningRig.find(id_a).last_snapshot
    snapshot_b = MiningRig.find(id_b).last_snapshot

    @title = 'Bitcoin Earnings'
    @stats = snapshot_a + snapshot_b
    @graph_payload = "/bitcoins/#{id_a}+#{id_b}/total_earned.json"
    haml :'bitcoin/earnings'
  end

  # this allows the chart load to faster via AJAX
  get '/bitcoins/:rig_id/total_earned.json' do
    content_type :json

    rig_id = params[:rig_id]
    rig = MiningRig.find(rig_id)
    most_recent = rig.last_snapshot

    graph_data = rig.average_earned_graph_data
    graph_data[most_recent.created_at.to_s] = most_recent.total_earned
    graph_data.to_json
  end

  get '/bitcoins/:rig_id/last_snapshot.json' do
    rig = MiningRig.find(params[:rig_id])
    snapshot = rig.last_snapshot

    # list of attributes to include in the json
    #TODO: figure out how to do break_even(:usd) and break_even_progress(:usd)
    methods = %i(id btc_mined usd_value created_at btc_per_day usd_per_day total_earned break_even break_even_progress)
    methods.reduce({}) do |hash, method|
      hash[method] = snapshot.send(method)
      hash
    end.to_json
  end

  # this allows the chart load to faster via AJAX
  get '/bitcoins/:rig_id/btc_mined.json' do
    content_type :json

    rig = MiningRig.find(params[:rig_id])

    # format the data for chartkick
    rig.snapshots.group_by_hour(:created_at).maximum(:btc_mined).to_json
  end

  get '/bitcoins/:rig_id' do
    @rig_id = params[:rig_id] || 1
    rig = MiningRig.find(@rig_id)

    @title = 'Bitcoin Earnings'
    @stats = rig.last_snapshot
    @graph_payload = "/bitcoins/#{@rig_id}/total_earned.json"
    haml :'bitcoin/earnings'
  end

  #TODO: remove this route when people have updated their bookmarks
  get '/stats/*', auth: :user do
    redirect '/stats', info: 'Note: this URL has been changed.'
  end

  get '/stats/?', auth: :user do
    @title = 'Bitcoin Stats'
    @rigs = MiningRig.all.sort_by { |rig| rig.total_earned }.reverse
    haml :'bitcoin/stats'
  end

  get '/graphs/?', auth: :user do
    @rig_id = request[:rig_id] || 1
    redirect "/graphs/#{@rig_id}"
  end

  # this is a work in progress that only logged in users should see
  get '/graphs/:rig_id', auth: :user do
    @rig_id = params[:rig_id] || 1
    @title = 'Bitcoin Graphs'
    @graph_payload = "/bitcoins/#{@rig_id}/btc_mined.json"
    haml :'bitcoin/graphs'
  end

  get '/bladehealth', auth: :user do
    @title = 'Blade Health'
    response = home_api('/bladehealth')
    @miners = JSON.parse(response.body)
    @json_data = JSON.pretty_generate(@miners) if request[:with_json]
    haml :'bitcoin/bladehealth'
  end

end
