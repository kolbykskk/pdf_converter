uri = URI.parse(ENV["REDISTOGO_URL"] || "redis://localhost:1234/")
$redis = Redis.new(:host => uri.host, :port => uri.port)
