require 'set'

class PlayerCircle
  attr_accessor :num_players, :p_players

  def initialize(**args)
    @num_players = args[:num_players]
    @p_players = args[:p_players]
  end

  def head
    @head ||= begin
      head = Node.new(players[0], nil)
      prev_node = head
      (1..num_players-1).each do |i|
        prev_node.right = Node.new(players[i], nil)
        prev_node = prev_node.right
      end
      prev_node.right = head
      head
    end
  end

  def players
    @players ||= num_players.times.map { Player.new(p_players) }
  end

  Node = Struct.new(:player, :right)
end

class Player
  attr_accessor :p_shot, :is_first_shot
  def initialize(p_shot)
    @p_shot = p_shot
    @is_first_shot = true
  end
end

class CircleUtil
  def self.print_circle(circle_head)
    object_ids = Set.new
    current_node = circle_head
    while !object_ids.include?(current_node.object_id)
      puts current_node.object_id.to_s
      object_ids.add(current_node.object_id)
      current_node = current_node.right
    end
  end
end

c = PlayerCircle.new(num_players: 6, p_players: 0.5)
CircleUtil.print_circle(c.head)
