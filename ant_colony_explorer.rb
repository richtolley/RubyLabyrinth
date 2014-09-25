load "maze_explorer.rb"
require 'uri'
class VirtualAnt

	attr_accessor :path

	def initialize start_node
		@current_location = start_node_id
		@path = []
		@path << start_node

	end

	def move node_dict

		potential_moves = node_dict["Exits"]
		potential_moves.each do |move_id|



		end

	end

	def probability_for_move_node move_node 
		move_node["PheromoneLevel"]
	end

end

class Maze

	attr_accessor :nodes,:edges

	def initialize nodes
		@nodes = nodes
		@edges = setup_edges
		@start_node = find_start_node 
	end

	def find_start_node_id
		start_node = nil
		@nodes.each_pair { |key,dict| start_id = dict if dict["LocationType"] == "Start" }
		start_node 
	end

	def setup_edges
		edges = {}
		@nodes.each_pair do |key,dict|
			dict["Exits"].each do |ex|
				ex_id = URI(ex).path.split('/').last
				key_pair = edge_key_for_nodes [key,ex_id]
				edges[key_pair] = {"PheromoneLevel" => 0} if @edges[key_pair] == nil
			end
		end
		edges
	end

	def edge_key_for_nodes nodes
		nodes.sort!
		"#{nodes[0]},#{nodes[1]}"

	end

	def pheromone_level_on_edge from_node,to_node
		key = edge_key_for_nodes [from_node,to_node]
		edge = @edges[key]
		edge["PheromoneLevel"] ? edge["PheromoneLevel"] : nil
	end

	def deposit_pheromone_on_edge from_node_to_node,pheromone_amount
		key = edge_key_for_nodes [from_node,to_node]
		edge = @edges[key]
		if edge
			current_level = edge["PheromoneLevel"]
			if current_level
				edge["PheromoneLevel"] = current_level + pheromone_amount
			else
				edge["PheromoneLevel"] = pheromone_amount
			end
		else
			puts "Error, no edge found for key #{key}"
		end
	end
end

class AntColonyExplorer < MazeExplorer

	def initialize maze_file_path
		
		"Initialize Maze JSON file at #{maze_file_path} for exploration using Ant Colony pathfinding"
		super maze_file_path
		@maze = Maze.new @nodes	
	end

	

	def find_start_node_id

		start_id = nil
		@nodes.each_pair { |key,dict| start_id = key if dict["LocationType"] == "Start" }
		start_id

	end

	def generate_the_ants number_of_ants
		puts "Generating #{number_of_ants} Ant#{number_of_ants != 1 ? "s":""}"
	end

	def release_the_ants 
		puts "Releasing Ants!"
	end

end

ant_explorer = AntColonyExplorer.new "easy_maze.json"