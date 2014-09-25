require 'trollop'

dir = "#{File.expand_path(File.dirname(__FILE__))}"
Dir["#{dir}/ap/*.rb"].each {|f| require f }
Dir["#{dir}/posthook/*.rb"].each {|f| require f }

params = Trollop::options do
  opt :states, "Comma-separated states to download", :type => :string, :default => nil
  opt :initialize, "Create initial set of results records", :default => false
  opt :once, "Only download and import data once", :default => false
  opt :clean, "Clean the data directories for specified states before downloading", :default => false
  opt :interval, "Interval (in seconds) at which AP data will be downloaded", :type => :int, :default => nil
  opt :posthook, "Run posthook after first import, even if results didn't change", :default => false
  opt :posthookall, "Run posthook after importing each state", :default => false
  opt :record, "Record this run", :default => false
  opt :replay, "Replay the most recent run", :default => false
  opt :replaydate, "Specify date of replay to run (e.g. 20120521)", :type => :string
  opt :replaytime, "Set the results to their state at the specified time", :default => nil, :type => :string
  opt :replaytimefrom, "Run the replay from the specified time onward", :default => nil, :type => :string
  opt :replaytimeto, "Run the replay up to the specified time", :default => nil, :type => :string
end

AP::Crawler.new(dir, params).crawl
