require 'net/http'
require 'json'

#Uses the Digitas Labyrinth API to fetch nodes for a maze in json form

class MazeNodeFetcher

	attr_accessor :verbose_logging,:nodes

	def initialize base_url = 'labyrinth.digitaslbi.com',maze_name = '/Maze/Location/easy/'
		@base_url = base_url
		@maze_name = maze_name
		@verbose_logging = false
	end

	def fetch_all_nodes_in_maze
		@nodes = {}
		fetch_node "#{@maze_name}start"
	end 

	def fetch_node node_path
		node_id = node_path.gsub(@maze_name,"")
		if @nodes[node_id] == nil

			puts "Requesting node json for path #{node_path}" if @verbose_logging == true
			json_string = Net::HTTP.get(@base_url, node_path + '/json')
			
			json_node = JSON.parse(json_string)
			node_id = json_node["LocationId"]
			@nodes[node_id] = json_node
			json_node["Exits"].each { |exit| fetch_node exit }
		end
	end

	def write_to_json_file file_path
		out_file = File.open file_path,"w"
		json_str = JSON.generate @nodes
		out_file.write json_str
	end
end

# fetcher = MazeNodeFetcher.new 
# fetcher.verbose_logging = true
# fetcher.fetch_all_nodes_in_maze
# fetcher.write_to_json_file "easy_maze.json"

