require 'aws/s3'
require 'yaml'

module AP
  class Replayer

    attr_accessor :done, :timekeys, :timekey_idx

    def initialize(crawler)
      @crawler = crawler
      @done = false
      @timekey_idx = 0
      @timekey_states = []
    end

    def replay_start
      raise AbortException, "Can't run replays in production environment" if ['production', 'internal'].include?(@crawler.env)

      get_replay if @timekey_idx == 0

      while true
        timekey = @timekeys[@timekey_idx]
        @archive_dir = "#{@crawler.datadir}/#{@crawler.params[:replaydate]}/#{timekey}"
        @timekey_states = Dir.glob("#{@archive_dir}/*").map{|d| d.split('/').last}.uniq
        @timekey_states = @timekey_states & @crawler.params[:states] if @crawler.params[:states]
        break if @timekey_states.size > 0 || @timekey_idx >= @timekeys.size - 1
        @timekey_idx += 1
      end

      @crawler.logger.log "Started replaying #{timekey}"
    end

    def replay_state(state_abbr)
      return unless @timekey_states.index(state_abbr)

      state_dir = "#{@crawler.datadir}/#{state_abbr}"
      system "mkdir -p #{state_dir}"
      state_archive_dir = "#{@archive_dir}/#{state_abbr}"
      files = ["#{state_abbr}_Results.txt", "#{state_abbr}_Race.txt", "#{state_abbr}_Candidate.txt"]
      files.each do |file|
        archive_file = "#{state_archive_dir}/#{file.split('/').last}"
        next unless File.exists?(archive_file)
        local_file = "#{state_dir}/#{file.split('/').last}"
        system("cp #{archive_file} #{local_file}")
        @crawler.new_files << [local_file, nil, nil]
      end
      @crawler.updated_states[state_abbr] ||= 1
    end

    def replay_end
      @timekey_idx += 1
      @done = true if @timekey_idx >= @timekeys.size
      @crawler.logger.log "Finished replaying"
    end

    def record_start
      @dt1 = Time.now.strftime('%Y%m%d')
      @dt2 = Time.now.strftime('%H%M%S')
    end

    def record_state(state_abbr)
      @crawler.logger.log "Recording #{state_abbr}"
      record_state_files(state_abbr, @crawler.new_files.select{|file| file.first.index("#{state_abbr}_")}, @dt1, @dt2)
    end

  private

    def get_replay
      download_latest_from_s3 if File.exists?("#{@crawler.dir}/config/s3.yml")
      @crawler.params[:replaydate] = Dir.glob("#{@crawler.datadir}/20*").reject{|f| f.index('.tar.gz')}.map{|f| f.split('/').last}.sort.last unless @crawler.params[:replaydate]
      if @crawler.params[:replaydate].nil?
        raise AbortException, "No replay was found locally or on s3, exiting"
      end
      if !File.exists?("#{@crawler.datadir}/#{@crawler.params[:replaydate]}/")
        raise AbortException, "A replay for #{@crawler.params[:replaydate]} was not found"
      end
      @timekeys = Dir.glob("#{@crawler.datadir}/#{@crawler.params[:replaydate]}/*").map{|d| d.split('/').last}.uniq.sort
      @timekeys.select! { |x| x.to_i >= @crawler.params[:replaytimefrom] && x.to_i <= @crawler.params[:replaytimeto] }
    end

    def download_latest_from_s3
      @s3_config = YAML.load_file("#{@crawler.dir}/config/s3.yml")
      begin
        AWS::S3::Base.establish_connection!(access_key_id: @s3_config['access_key_id'], secret_access_key: @s3_config['secret_access_key'])
        bucket = AWS::S3::Bucket.find(@s3_config['bucket'])
        s3_files = bucket.objects(prefix: "#{@s3_config['directory']}/").map{|o| o.key.split('/')[1, 1].first}
      rescue Exception => e
        raise AbortException, e.to_s
      end
      if s3_files.size == 0
        raise AbortException, "No replays were found on s3 in the bucket and directory specified"
      end
      s3_date = @crawler.params[:replaydate] || s3_files.sort.last.split('.').first

      local_gzip = "#{@crawler.datadir}/#{s3_date}.tar.gz"
      unless File.exist?(local_gzip)
        puts "Downloading replay from #{s3_date}..."
        s3_object = bucket.objects(prefix: "#{@s3_config['directory']}/#{s3_date}.tar.gz").first
        if s3_object.nil?
          raise AbortException, "A replay from #{s3_date} wasn't found on s3"
        end
        File.open(local_gzip, 'w') {|f| f.write(s3_object.value)}
        system "tar -zxvf #{local_gzip} -C #{@crawler.datadir}/"
      end
    end

    def record_state_files(state_abbr, files, dt1, dt2)
      archive_dir = "#{@crawler.datadir}/#{dt1}/#{dt2}/#{state_abbr}/"
      system "mkdir -p #{archive_dir}"
      files.each do |file|
        archive_file = "#{archive_dir}#{file.first.split('/').last}"
        system "cp #{file.first} #{archive_file}"
      end
    end

  end
end
