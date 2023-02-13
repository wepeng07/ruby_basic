class ValueError < RuntimeError
end

class Cave
  attr_accessor :rooms, :no_hazards_rooms

  def initialize()
    @edges = [[1, 2], [2, 10], [10, 11], [11, 8], [8, 1], [1, 5], [2, 3], [9, 10], [20, 11], [7, 8], [5, 4],
                      [4, 3], [3, 12], [12, 9], [9, 19], [19, 20], [20, 17], [17, 7], [7, 6], [6, 5], [4, 14], [12, 13],
                      [18, 19], [16, 17], [15, 6], [14, 13], [13, 18], [18, 16], [16, 15], [15, 14]]
    @rooms = 20.times.map { |i| Room.new(i+1) }
    @edges.each { |edge| room(edge[0]).connect(room(edge[1]))}
  end

  def room(number)
    rooms[number - 1]
  end

  def random_room
    rooms.sample
  end

  def get_no_hazard_room(h)
    loop do
      room = @rooms.sample
      return room unless room.has?(h)
    end
  end

  def add_hazard(h, n)
    n.times do
      get_no_hazard_room(h).add(h)
    end
  end

  def room_with(hazard)
    @rooms.find { |room| room.has?(hazard) }
  end

  def move(hazard, frm, to)
    raise ValueError unless frm.has?(hazard)

    frm.remove(hazard)
    to.add(hazard)
  end

  def entrance
    rooms.find { |room| room.safe? }
  end
end

class Player
  attr_accessor :senses, :encounters, :actions, :room

  def initialize
    @encounters = {}
    @actions    = {}
    @senses     = {}
  end

  def sense(hazard, &callback)
    senses[hazard.to_s] = callback
  end

  def encounter(hazard, &callback)
    encounters[hazard.to_s] = callback
  end

  def action(act, &callback)
    actions[act.to_s] = callback
  end

  def enter(room)
    @room = room
    return if room.safe?

    if room.self_safe?
      explore_room.each do |hazard|
        callback = senses[hazard]
        callback&.call
      end
    else
      encounters.each do |hazard, callback|
        return callback.call if room.has?(hazard) && callback
      end
    end
  end

  def explore_room
    room.neighbors.map(&:hazards).flatten.uniq
  end

  def act(action, destination)
    action   = action.to_s
    callback = actions[action]
    raise KeyError if callback.nil?

    callback.call(destination)
  end
end

class Room
  attr_accessor :number, :hazards, :neighbors

  def initialize(number)
    @number    = number
    @hazards   = []
    @neighbors = []
  end

  def add(hazard)
    hazards.push(hazard.to_s)
  end

  def has?(hazard)
    hazards.include?(hazard.to_s)
  end

  def remove(hazard)
    raise ValueError unless has?(hazard)

    hazards.delete(hazard.to_s)
  end

  def empty?
    hazards.empty?
  end

  def safe?
   return false unless self_safe?

   neighbors.map(&:self_safe?).all?
  end

  def connect(other_room)
    neighbors.push(other_room)
    other_room.neighbors.push(self)
  end
  
  def exits
    neighbors.map(&:number)
  end
    
  def neighbor(number)
    neighbors.find{ |room| room.number == number}
  end

  def random_neighbor
    raise IndexError, 'neighbors is empty' if neighbors.empty?

    neighbors[rand(neighbors.length)]
  end

  def self_safe?
    empty?
  end
end


class Console
  def initialize(player, narrator)
    @player   = player
    @narrator = narrator
  end

  def show_room_description
    @narrator.say "-----------------------------------------"
    @narrator.say "You are in room #{@player.room.number}."

    @player.explore_room

    @narrator.say "Exits go to: #{@player.room.exits.join(', ')}"
  end

  def ask_player_to_act
    actions = {"m" => :move, "s" => :shoot, "i" => :inspect }

    accepting_player_input do |command, room_number|
      @player.act(actions[command], @player.room.neighbor(room_number))
    end
  end

  private

  def accepting_player_input
    @narrator.say "-----------------------------------------"
    command = @narrator.ask("What do you want to do? (m)ove or (s)hoot?")

    unless ["m","s"].include?(command)
      @narrator.say "INVALID ACTION! TRY AGAIN!"
      return
    end

    dest = @narrator.ask("Where?").to_i

    unless @player.room.exits.include?(dest)
      @narrator.say "THERE IS NO PATH TO THAT ROOM! TRY AGAIN!"
      return
    end

    yield(command, dest)
  end
end

class Narrator
  def say(message)
    $stdout.puts message
  end

  def ask(question)
    print "#{question} "
    $stdin.gets.chomp
  end

  def tell_story
    yield until finished?

    say "-----------------------------------------"
    describe_ending
  end

  def finish_story(message)
    @ending_message = message
  end

  def finished?
    !!@ending_message
  end

  def describe_ending
    say @ending_message
  end
end
