require 'json'

class MazeExplorer

	def initialize maze_file_path
		json_file = File.open maze_file_path,"r"
		@nodes = JSON.parse(json_file.read)
	end
end



