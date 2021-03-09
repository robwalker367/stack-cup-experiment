require 'set'

# TODO: Extract an experiment class from the game class
class StackCupGame
  attr_accessor :player_circle, :cups

  def initialize(**args)
    @player_circle = args[:player_circle]
    @cups = args[:cups]
  end

  def rounds_until_first_stack
    cups.distribute_cups(player_circle)
    round_count = 0
    while !cups.cup_was_stacked?
      do_round
      round_count += 1
    end
    round_count
  end

  def do_round
    cups.players_with_cups.each do |player|
      is_success = player.take_shot
      if player.is_first_shot && is_success
        next_player = cups.next_player_with_cup(player)
        cups.pass_cup_between(player, next_player.left_player)
      elsif is_success
        cups.pass_cup_between(player, player.right_player)
        player.is_first_shot = true
      else
        player.is_first_shot = false
      end
    end
  end
end

# TODO: refactor this class to follow SRP
class Cups
  attr_accessor :players_with_cups, :total_cups

  def initialize(total_cups:)
    @total_cups = total_cups
    @players_with_cups = []
  end

  def distribute_cups(player_circle)
    indices_of_cups = [0, player_circle.total_players / total_cups]
    indices_of_cups.each do |i|
      players_with_cups.append(player_circle.player_at_index(i))
    end
  end

  def pass_cup_between(player_with_cup, player_to_pass_to)
    players_with_cups[players_with_cups.index(player_with_cup)] = player_to_pass_to
  end

  def next_player_with_cup(player)
    players_with_cups[(players_with_cups.index(player) + 1) % players_with_cups.size]
  end

  def cup_was_stacked?
    players_with_cups.uniq.size < total_cups # TODO: This is janky
  end
end

class Player
  attr_accessor :shot_probability, :is_first_shot, :right_player, :left_player

  def initialize(shot_probability:)
    @shot_probability = shot_probability
    @right_player = nil
    @left_player = nil
    @holds_cup = false
    @is_first_shot = true
  end

  def take_shot
    rand < shot_probability # TODO: This could be extracted using the strategy pattern
  end
end

# TODO: Might not be the best class for this
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

  def self.avg_rounds_of_x_games(game_factory:, x:)
    running_sum = 0
    x.times do |i|
      game = game_factory.new_game
      running_sum += game.rounds_until_first_stack
    end
    running_sum / x
  end
end

class GameFactory
  attr_accessor :players_skill, :total_players, :total_cups

  def initialize(players_skill:, total_players:, total_cups:)
    @players_skill = players_skill
    @total_players = total_players
    @total_cups = total_cups
  end

  def new_game
    player_circle = PlayerCircle.new(
      players: PlayerFactory.create_players(
        total_players: 6,
        players_probability: 0.5
      )
    )
    cups = Cups.new(total_cups: 2)
    
    StackCupGame.new(player_circle: player_circle, cups: cups)
  end
end


avg_rounds = Util.avg_rounds_of_x_games(
  game_factory: GameFactory.new(
    players_skill: 0.5,
    total_players: 6,
    total_cups: 2
  ), 
  x: 10000
)

puts "Average rounds: " + avg_rounds.to_s
