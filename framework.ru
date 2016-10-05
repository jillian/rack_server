require_relative 'action'
require 'warden'

class Framework
	require 'rack'
	def self.app 

		failure_app = Proc.new { |env| ['401', {'Content-Type' => 'text/html'}, ["UNAUTHORIZED"]] }

		@app ||= begin
			Rack::Builder.new do 
				use Rack::Session::Cookie, secret: "MY_SECRET"

				# use Warden::Manager do |manager|
				# 	manager.default_strategies :password, :basic
				# 	manager.failure_app = failure_app
				# end

				map "/" do 
					run -> (env) { [404, {"Content-Type" => "text/plain"}, ["Whoops - page not found"]] }
				end
			end	
		end
	end
	# #<Rack::Builder:0x007fbcfb92d960 @warmup=nil, @run=nil, @map={"/"=>#<Proc:0x007fbcfb92d6b8@(irb):6>}, @use=[]>
end

def route(pattern, &block)
	Framework.app.map(pattern) do
		run Action.new(&block)
	end	
end

route "/hello" do
  "Hello #{params['name'] || "World"}!" 
end

route "/goodbye" do 
  status 500 
  "Goodbye cruel world!"
end

run Framework.app