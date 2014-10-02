module AP
  class Crawler

    STATES = ["AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"]
    attr_accessor :dir, :datadir, :params, :env, :ap_config, :logger, :downloader, :importer, :replayer, :new_files, :updated_states

    def initialize(dir, params)
      @dir = dir
      @datadir = "#{@dir}/data"
      @params = params
      @ap_config = YAML::load(File.open("#{@dir}/config/ap.yml"))
      @env = @ap_config['environment'] && @ap_config['environment'].size > 0 ? @ap_config['environment'] : "development"

      # Set some defaults from config file
      @params[:interval] = @ap_config['interval'] if @params[:interval].nil?
      @params[:states] = @ap_config['states'] if @params[:states].nil?
      @params[:states] = (@params[:states] == 'all' ? STATES : (STATES & @params[:states].split(",")))

      # Some parameters are dependent on others
      @params[:replay] = true if @params[:replaydate] && @params[:replaydate].size > 0
      @params[:replaytimefrom] = (@params[:replaytimefrom] || @params[:replaytime] || 0).to_i
      @params[:replaytimeto] = (@params[:replaytimeto] || @params[:replaytime] || 999999).to_i
      @params[:initialize] = true if @params[:replay]
      @params[:once] = true if @params[:initialize] && !@params[:record] && !@params[:replay]
      @params[:clean] = true if @params[:record]
      @params[:initialize] = true if @params[:record]

      @logger = AP::Logger.new
      @downloader = AP::Downloader.new(self)
      @importer = AP::Importer.new(self)
      @replayer = AP::Replayer.new(self)
      @posthook = AP::Posthook.new(self) if defined?(AP::Posthook)
    end

    def crawl
      while true do
        tm_start = Time.now.to_i

        begin
          @updated_states = {}
          @params[:replay] ? @replayer.replay_start : @downloader.connect
          @replayer.record_start if @params[:record]
          @params[:states].each_with_index do |state, i|
            @new_files = []

            # Download state from FTP server or stored replay
            @params[:replay] ? @replayer.replay_state(state) : @downloader.download_state(state)

            # If any files changed, import the state
            if @new_files.size > 0
              @importer.import_state(state)
              @replayer.record_state(state) if @params[:record]
            end

            # Run posthook if a) this is the last state and any state changed b) this state changed and we're running posthook for every state, c) posthook param is set
            if (i == @params[:states].size - 1 && @updated_states.size > 0) || (@new_files.size > 0 && params[:posthookall]) || @params[:posthook]
              @posthook.run
              @params[:posthook] = false
            end
          end
          @params[:replay] ? @replayer.replay_end : @downloader.disconnect

          # Sleep for a bit after the first round of a replay so you can ctrl-Z and do whatever
          if @params[:initialize] && @params[:replay]
            @logger.log "Sleeping at initial state *************"
            sleep 5
          end
        rescue AbortException => e
          @logger.err e.to_s
          raise e
        rescue Exception => e
          # Reconnect to mysql if connection dropped, otherwise, log any errors and continue
          @importer.connect if e.to_s.include?('MySQL server has gone away')
          @logger.err e.to_s
        end

        @params[:clean] = false
        @params[:initialize] = false if @params[:record] || @params[:replay]
        break if @params[:once] || (@params[:replay] && @replayer.done)

        # Sleep for remaining time
        s = @params[:interval] - (Time.now.to_i - tm_start)
        @logger.log "Sleeping for #{s} seconds" if s > 0
        sleep(s < 0 ? 0 : s)
      end
    end

  end
end
