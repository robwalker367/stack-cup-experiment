require 'set'

class StackCupGame
  attr_accessor :players

  def initialize(**args)
    @players = args[:players]
  end
end

class Cups
  attr_accessor :players_with_cups

  def initialize(player_circle:)
    @player_circle = player_circle
  end

  def distribute_cups
    indices_of_cups = [0, player_circle.total_players / 2]
    indices_of_cups.each do |i|
      players_with_cups.append(player_circle.player_at_index(i))
    end
  end

  def pass_to_player(player_with_cup, player_to_pass_to)
    players_with_cups[players_with_cups.index(player_with_cup)] = player_to_pass_to
  end
end

class Player
  attr_accessor :shot_probability, :is_first_shot, :right_player, :left_player

  def initialize(shot_probability:)
    @shot_probability = shot_probability
    @right_player = nil
    @left_player = nil
    @is_first_shot = true
    @holds_cup = false
  end

  def take_shot
    is_first_shot = false if is_first_shot
    (rand % shot_probability) < shot_probability
  end
end

class PlayerCircle
  attr_accessor :total_players, :players

  def initialize(players: [])
    @total_players = players.size
    @players = players
  end

  def head
    @head ||= begin
      first_player = players[0]
      prev_player = first_player
      (total_players-1).times do |i|
        next_player = players[i+1]
        prev_player.right_player = next_player
        next_player.left_player = prev_player
        prev_player = next_player
      end
      prev_player.right_player = first_player
      first_player.left_player = prev_player
      first_player
    end
  end

  def player_at_index(index)
    player = head
    index.times do
      player = player.right_player
    end
    player
  end
end

class PlayerFactory
  def self.create_players(total_players:, players_probability:)
    total_players.times.map { 
      Player.new(shot_probability: players_probability) 
    }
  end
end

class Util
  def self.print_players(players)
    object_ids = Set.new
    current_node = players.head
    while !object_ids.include?(current_node.object_id)
      puts current_node.object_id.to_s
      object_ids.add(current_node.object_id)
      current_node = current_node.right_player
    end
  end
end

players = PlayerCircle.new(
  players: PlayerFactory.create_players(
    total_players: 6,
    players_probability: 0.5
  )
)
Util.print_players(players)
