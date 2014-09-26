load "maze_explorer.rb"
require 'uri'
require 'pry'
class VirtualAnt

	attr_accessor :path,:state

	def initialize maze
		@path = []
		@maze = maze
		@path << @maze.start_node
		state = "Starting"
		@pheromone_total = 10

	end

	def move 

		current_node = @path.last
		
		if current_node.location_type == "Exit"
			@state = "Finished"

		else
			moves = current_node.exits.inject([]) do |acc,exit|
				number_of_votes = @maze.pheromone_level_on_edge current_node.location_id,exit
				
				number_of_votes.times { acc << exit }
				acc 
			end
			
			new_node_id = moves[rand(moves.length)]
			@path << @maze.nodes[new_node_id]

			if @path.length <= @maze.nodes.length * 100
				move
			else 
				@state = "Failed"
				puts "Too many moves (#{@path.length})"
			end
		end

	end

	def deposit_pheromone

		puts "Path length was #{@path.length}"
		if @path.length == 0
			puts "Cannot deposit pheromone on zero length path"
		else
			to_index = path.length-1
			from_index = path.length-2

			while from_index > 0
				to_node_id = @path[to_index].location_id
				from_node_id = @path[from_index].location_id
				pheromone_amount = 1
				@maze.deposit_pheromone_on_edge from_node_id,to_node_id,pheromone_amount
				to_index -=1
				from_index -=1
			end
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

	def to_s
		"Maze Node: id #{location_id},type#{location_type}"
	end

end

class Maze

	attr_accessor :nodes,:edges,:start_node,:finish_node

	def initialize nodes
		
		@nodes = nodes.values.inject({}) do |acc,it| 
			key = it["LocationId"]
			acc[key] = MazeNode.new(it) 	
			acc 
		end

		@edges = setup_edges @nodes
		@start_node = find_single_node_of_type "Start"
		@exit_node = find_single_node_of_type "Exit"
	end

	def find_single_node_of_type type_name
		@nodes.values.inject { |acc,node| acc = node if node.location_type == "Start"; acc }
	end

	def setup_edges nodes
		
		nodes.values.inject({}) do |acc,it|
			it.exits.each do |exit|
				key_pair = edge_key_for_nodes [exit,it.location_id]
				acc[key_pair] = {"PheromoneLevel" => 1} if acc[key_pair] == nil
			end
			acc
		end
	end

	def edge_key_for_nodes nodes
		nodes.sort!
		"#{nodes[0]},#{nodes[1]}"
	end

	def pheromone_level_on_edge from_node_id,to_node_id
		key = edge_key_for_nodes [from_node_id,to_node_id]
		edge = @edges[key]
		edge["PheromoneLevel"] ? edge["PheromoneLevel"] : nil
	end

	def deposit_pheromone_on_edge from_node_id,to_node_id,pheromone_amount
		key = edge_key_for_nodes [from_node_id,to_node_id]
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

	def log_pheromone_levels
		@edges.each_pair do |k,v|
			puts "Node level is #{v["PheromoneLevel"]}"
		end 
	end
end

class AntColonyExplorer < MazeExplorer

	def initialize maze_file_path
		
		puts "Initializing Maze JSON file at #{maze_file_path} for exploration using Ant Colony pathfinding"
		super maze_file_path
		@maze = Maze.new @nodes	
		ants = []

		100.times do |generation|
			ants = []
			puts "Starting new ant colony simulation"
			puts "Creating new ants"
			100.times { ants << VirtualAnt.new(@maze) }
			ants.each { |ant| ant.move }
			puts "ants have moved"
			ants.each { |ant| ant.deposit_pheromone if ant.state == "Finished" }
			puts "ants have deposited pheromone"
			shortest_length = ants[0].path.length
			ants.each { |ant| shortest_length = ant.path.length if ant.path.length < shortest_length and ant.state == "Finished" }
			
			@maze.log_pheromone_levels
	
			puts "Generation #{generation} - shortest path was #{shortest_length}" 
		end
		
	end

	def generate_the_ants number_of_ants
		puts "Generating #{number_of_ants} Ant#{number_of_ants != 1 ? "s":""}"
	end

	def release_the_ants 
		puts "Releasing Ants!"
	end

end

ant_explorer = AntColonyExplorer.new "easy_maze.json"