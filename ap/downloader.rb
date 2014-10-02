require 'net/ftp'
require 'fileutils'
require 'timeout'
require 'digest/md5'

module AP
  class Downloader

    def initialize(crawler)
      @crawler = crawler
    end

    def connect
      @ftp = Net::FTP.new(@crawler.ap_config['host'])
      @ftp.login(@crawler.ap_config['user'], @crawler.ap_config['pass'])
      @ftp.passive = true
    end

    def disconnect
      @ftp.close
    end

    def download_state(state)
      @crawler.logger.log "Downloading #{state}"
      ftp_dir = "/#{state}/dbready"
      local_dir = "#{@crawler.datadir}/#{state}"
      FileUtils.remove_dir("#{local_dir}", true) if @crawler.params[:clean]
      FileUtils.makedirs(local_dir) unless File.exists?(local_dir)

      # Downloaded files depend on parameters
      files = ["#{state}_Results.txt", "#{state}_Race.txt"]
      files += ["#{state}_Candidate.txt"] if @crawler.params[:initialize]

      download_files(files, ftp_dir, local_dir, state)
    end

  private

    def download_files(files, ftp_dir, local_dir, state)
      files.each do |file|
        local_file = "#{local_dir}/#{file}"

        begin
          timeout(20) do
            # Use the file's mtime on the ftp server to see if it changed before downloading
            old_tm = File.exists?("#{local_file}.mtime") ? File.read("#{local_file}.mtime") : nil
            new_tm = @ftp.mtime("#{ftp_dir}/#{file}").to_i.to_s
            next if new_tm == old_tm

            @ftp.getbinaryfile("#{ftp_dir}/#{file}", "#{local_file}", 1024)

            # Hash the old and new files to see if they changed (oftentimes, files on the ftp server will have a new timestamp but be unchanged)
            old_md5 = File.exists?("#{local_file}.md5") ? File.read("#{local_file}.md5") : nil
            new_md5 = Digest::MD5.hexdigest(File.read(local_file))
            next if old_md5 == new_md5

            # Record the downloaded files for processing by the importer
            @crawler.new_files << [local_file, new_tm, new_md5]
            @crawler.updated_states[state] ||= 1
          end

        # Trap timeouts and a transient ftp error seen on higher traffic nights so they don't halt the crawler
        rescue Exception, Timeout::Error => e
          if !e.to_s.include?("The system cannot find the file")
            @crawler.logger.err "FTP ERR for #{ftp_dir}/#{file}: #{e.to_s}"
            FileUtils.rm_f("#{local_dir}/#{file}")
            disconnect
            connect
            @crawler.new_files = []
            @crawler.updated_states.delete(state)
            return
          end
        end
      end
    end

  end
end
