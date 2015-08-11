require 'trollop'
require 'yaml'
require 'aws/s3'

dir = "#{File.expand_path(File.dirname(__FILE__))}"
datadir = "#{dir}/data"

params = Trollop::options do
  opt :date, "Specify date of recording to upload (e.g. 20120521)", type: :string
end

@s3_config = YAML.load_file("#{dir}/config/s3.yml")
AWS::S3::Base.establish_connection!(access_key_id: @s3_config['access_key_id'], secret_access_key: @s3_config['secret_access_key'])

params[:date] = Dir.glob("#{datadir}/20*").reject{|f| f.index('.tar.gz')}.map{|f| f.split('/').last}.sort.last

puts "Gzipping and uploading replay from #{params[:date]}"
system "cd #{datadir} && tar -czf #{params[:date]}.tar.gz #{params[:date]}"
AWS::S3::Base.establish_connection!(access_key_id: @s3_config['access_key_id'], secret_access_key: @s3_config['secret_access_key'])
file = "#{datadir}/#{params[:date]}.tar.gz"
s3_file = "#{@s3_config['directory']}/#{params[:date]}.tar.gz"
AWS::S3::S3Object.store(s3_file, open(file), @s3_config['bucket'], access: :private)
