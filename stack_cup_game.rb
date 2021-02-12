require 'set'

class StackCupGame
  attr_accessor :players

  TOTAL_CUPS = 2

  def initialize(**args)
    @players = args[:players]
    pass_out_cups
  end

  def pass_out_cups
    players.at_position(0).holds_cup = true
    players.at_position(players.size / TOTAL_CUPS).holds_cup = true
  end
end

class Circle
  attr_accessor :head, :size

  def initialize(values: [])
    @size = values.size
    @head = arrange(values)
  end

  def arrange(values)
    head = Node.new(values[0], nil)
    prev_node = head
    (1..values.size-1).each do |i|
      prev_node.right = Node.new(values[i], nil)
      prev_node = prev_node.right
    end
    prev_node.right = head
    head
  end

  def at_position(index)
    node = head
    index.times { node = node.right }
    node
  end

  Node = Struct.new(:value, :right)
end

class PlayersFactory
  def self.create_players(total_players:, players_probability:)
    total_players.times.map { 
      Player.new(shot_probability: players_probability) 
    }
  end
end

class Player
  attr_accessor :shot_probability, :is_first_shot, :holds_cup

  def initialize(shot_probability:)
    @shot_probability = shot_probability
    @is_first_shot = true
    @holds_cup = false
  end

  def take_shot
    is_first_shot = false if is_first_shot
    (rand % shot_probability) < shot_probability
  end

  def pass_cup
    holds_cup = false
  end

  def take_cup
    holds_cup = true
    is_first_shot = true
  end
end

class CircleUtil
  def self.print_circle(circle)
    object_ids = Set.new
    current_node = circle.head
    while !object_ids.include?(current_node.object_id)
      puts current_node.object_id.to_s
      object_ids.add(current_node.object_id)
      current_node = current_node.right
    end
  end
end

players = Circle.new(
  values: PlayersFactory.create_players(
    total_players: 6,
    players_probability: 0.5
  )
)
CircleUtil.print_circle(players)
