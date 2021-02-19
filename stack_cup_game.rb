require 'set'

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
      is_success = player.made_shot?
      if is_success
        cups.pass_cup(player, player.right_player)
      end
    end
  end
end

class Cups
  attr_accessor :players_with_cups, :total_cups

  def initialize(total_cups:)
    @total_cups = total_cups
  end

  def distribute_cups(player_circle)
    indices_of_cups = [0, player_circle.total_players / total_cups]
    indices_of_cups.each do |i|
      players_with_cups.append(player_circle.player_at_index(i))
    end
  end

  def pass_cup(player_with_cup, player_to_pass_to)
    players_with_cups[players_with_cups.index(player_with_cup)] = player_to_pass_to
  end

  def cup_was_stacked?
    players_with_cups.size < total_cups
  end
end

class Player
  attr_accessor :shot_probability, :right_player, :left_player

  def initialize(shot_probability:)
    @shot_probability = shot_probability
    @right_player = nil
    @left_player = nil
    @holds_cup = false
  end

  def made_shot?
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

player_circle = PlayerCircle.new(
  players: PlayerFactory.create_players(
    total_players: 6,
    players_probability: 0.5
  )
)

game = StackCupGame.new(
  player_circle: player_circle,
  cups: Cups.new(total_cups: 2)
)

puts game.rounds_until_first_stack
