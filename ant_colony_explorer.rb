load "maze_explorer.rb"
require 'uri'
require 'pry'
class VirtualAnt

	attr_accessor :path

	def initialize start_node,maze
		@current_location = start_node_id
		@path = []
		@path << start_node
		@maze = maze
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

class MazeNode

	attr_accessor :location_id,:location_type,:exits

	def initialize json_dict

		@location_type = json_dict["LocationType"]
		@location_id = json_dict["LocationId"]
		
		@exits = json_dict["Exits"].inject([]) do |acc,it|
			acc << URI(it).path.split('/').last
			acc
		end

	end

end

class Maze

	attr_accessor :nodes,:edges

	def initialize nodes
		
		@nodes = nodes.values.inject({}) do |acc,it| 
			key = it["LocationId"]
			acc[key] = MazeNode.new(it) 	
			acc 
		end

		@edges = setup_edges @nodes
		@start_node = find_single_node_of_type "Start"
		@exit_node = find_single_node_of_type "Exit"
		puts @start_node.location_id
		puts @exit_node.location_id
	end

	def find_single_node_of_type type_name
		@nodes.values.inject { |acc,node| acc = node if node.location_type == "Start"; acc }
	end

	def setup_edges nodes
		
		nodes.values.inject({}) do |acc,it|
			it.exits.each do |exit|
				key_pair = edge_key_for_nodes [exit,it.location_id]
				acc[key_pair] = {"PheromoneLevel" => 0} if acc[key_pair] == nil
			end
			acc
		end
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

	def deposit_pheromone_on_edge from_node,to_node,pheromone_amount
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