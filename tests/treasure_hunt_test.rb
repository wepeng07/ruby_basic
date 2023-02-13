require 'test/unit'
require 'test/unit/assertions'
require 'set'
require_relative "../treasure_hunt.rb"

class MyTest < Test::Unit::TestCase
  def test_room_creation
    room = Room.new(12)
    assert_equal(12, room.number, 'Expected room number 12')
    assert_equal([], room.neighbors, 'Expected room number 12 to have no neighbors')
    assert_equal([], room.hazards, 'Expected room number 12 to have no hazards')
  end

  def test_room_add_1
    room = Room.new(18)
    room.add('bats')
    assert_includes(room.hazards, 'bats', 'Expected room to have bats')
  end

  def test_room_add_2
    room = Room.new(16)
    room.add('bats')
    room.add('guard')
    assert_includes(room.hazards, 'bats', 'Expected room to have bats')
    assert_includes(room.hazards, 'guard', 'Expected room to have guard')
  end

  def test_room_add_3
    room = Room.new(10)
    room.add('bats')
    room.add('guard')
    refute_includes(room.hazards, 'pits', 'Expected room to not have pits')
    assert_includes(room.hazards, 'bats', 'Expected room to have bats')
    assert_includes(room.hazards, 'guard', 'Expected room to have guard')
  end

  def test_room_remove_1
    room = Room.new(18)
    room.add('bats')
    room.add('guard')
    room.remove('bats')
    refute_includes(room.hazards, 'bats', 'Expected bats to be removed')
    assert_includes(room.hazards, 'guard', 'Expected room to have guard')
  end

  def test_room_remove_2
    room = Room.new(18)
    room.add('bats')
    room.add('guard')
    assert_raises ValueError do
      room.remove('pits')
    end
  end

  def test_room_empty
    room = Room.new(11)
    assert(room.empty?, 'Expected room to have no hazards')
  end

  def test_room_not_empty
    room = Room.new(10)
    room.add('thing')
    assert(room.empty? == false, 'Expected room to have hazards')
  end

  def test_room_connect
    room1 = Room.new(19)
    room2 = Room.new(9)
    room1.connect(room2)
    assert_includes(room1.neighbors, room2, 'Expected room2 to be in neighbor of room1')
    assert_includes(room2.neighbors, room1, 'Expected room1 to be in neighbor of room2')
  end

  def test_room_safe_1
    room = Room.new(12)
    assert(room.safe?, 'Expected room to be safe as it has no hazards and neighbors')
  end

  def test_room_safe_2
    room = Room.new(13)
    room1 = Room.new(15)
    room2 = Room.new(7)
    assert(room.hazards.empty?)
    assert(room1.hazards.empty?)
    assert(room2.hazards.empty?)
    room.connect(room1)
    room.connect(room2)
    assert(room.safe?, 'Expected to room to be safe since room or neighbors have no hazards')
  end

  def test_room_safe_3
    room = Room.new(13)
    room1 = Room.new(15)
    room2 = Room.new(7)
    room2.add("bats")
    room.connect(room1)
    room1.connect(room2)
    assert(room.safe?, 'Expected to room to be safe since room or neighbors have no hazards')
  end

  def test_room_unsafe_1
    room = Room.new(17)
    room.add("dogs")
    room.add("cats")
    assert(room.safe? == false, 'Expected room to be unsafe since room has hazards')
  end

  def test_room_unsafe_2
    room = Room.new(17)
    room1 = Room.new(8)
    room1.add("dogs")
    room1.add("cats")
    room.connect(room1)
    room2 = Room.new(18)
    room2.add("bats")
    room.connect(room2)
    assert(room.safe? == false, 'Expected room to be unsafe since neighbors have hazards')
  end

  def test_room_unsafe_3
    room = Room.new(17)
    room1 = Room.new(8)
    room.connect(room1)
    room2 = Room.new(18)
    room2.add("bats")
    room.connect(room2)
    assert(room.safe? == false, 'Expected room to be unsafe since at least one neighbor has hazards')
  end

  def test_room_exits
    room = Room.new(3)
    room1 = Room.new(5)
    room2 = Room.new(20)
    room3 = Room.new(1)
    room.connect(room1)
    room.connect(room2)
    room.connect(room3)
    assert_includes(room.exits, room1.number, 'Expected room 5 to be exit for room 3')
    assert_includes(room.exits, room2.number, 'Expected room 20 to be exit for room 3')
    assert_includes(room.exits, room3.number, 'Expected room 1 to be exit for room 3')
  end

  def test_room_exits_absent
    room = Room.new(3)
    room1 = Room.new(5)
    room2 = Room.new(20)
    room3 = Room.new(1)
    room.connect(room1)
    room.connect(room2)
    room1.connect(room3)
    assert_includes(room.exits, room1.number, 'Expected room 5 to be exit for room 3')
    assert_includes(room.exits, room2.number, 'Expected room 20 to be exit for room 3')
    refute_includes(room.exits, room3.number, 'Expected room 1 to not be in exit for room 3')
  end

  def test_room_empty_exits
    room = Room.new(9)
    assert_empty(room.exits, 'Expected room to have no exits')
  end

  def test_room_neighbor
    room = Room.new(17)
    room1 = Room.new(5)
    room2 = Room.new(15)
    room3 = Room.new(18)
    room.connect(room1)
    room.connect(room2)
    room.connect(room3)
    assert_equal(room1, room.neighbor(5), "Expected room 5!")
    assert_equal(room2, room.neighbor(15), "Expected room 15!")
    assert_equal(room3, room.neighbor(18), "Expected room 18!")
  end

  def test_room_neighbor_nil
    room = Room.new(17)
    room1 = Room.new(5)
    room2 = Room.new(15)
    room3 = Room.new(18)
    room.connect(room1)
    room.connect(room2)
    room.connect(room3)
    assert_true(room.neighbor(21).nil?, "Expected neighbor to be absent!")
  end

  def test_room_random_neighbor
    room = Room.new(17)
    room1 = Room.new(5)
    room2 = Room.new(15)
    room3 = Room.new(18)
    room.connect(room1)
    room.connect(room2)
    room.connect(room3)
    assert_includes(room.neighbors, room.random_neighbor, "Expected random neighbor of room 17!")
  end

  def test_room_no_random_neighbor
    room = Room.new(5)
    assert_raises IndexError do
      room.random_neighbor
    end
  end

  def test_cave_rooms
    cave = Cave.new
    (1..20).each do |r|
      assert_equal(r, cave.room(r).number, "Expected room #{r} to be in cave")
    end
  end

  def test_cave_connections
    cave = Cave.new
    (1..20).each { |r|
      refute_empty(cave.room(r).neighbors.select { |n| n.neighbors.include?(cave.room(r)) })
    }
  end

  def test_cave_random_room
    cave = Cave.new
    room = cave.random_room
    assert_equal(room, cave.room(room.number), 'Expected random room to be in cave')
  end

  def test_cave_add_hazards_1
    cave = Cave.new
    cave.add_hazard("bats", 5)
    hazards = []
    (1..20).map { |x| cave.room(x).hazards.each { |h| hazards.append(h) } }
    assert_equal(5, hazards.length, 'Expected cave to have 5 bats')
  end

  def test_cave_add_hazards_2
    cave = Cave.new
    cave.add_hazard("pits", 8)
    hazards = []
    (1..20).map { |x| cave.room(x).hazards.each { |h| hazards.append(h) } }
    assert_equal(8, hazards.length, 'Expected cave to have 8 bats')
  end

  def test_cave_room_with_bats
    cave = Cave.new
    room = cave.room(7)
    room.add("bats")
    assert_equal(room, cave.room_with("bats"), "Expected room #{room.number} in cave to have bats")
  end

  def test_cave_room_with_no_bats
    cave = Cave.new
    assert_nil(cave.room_with("bats"), 'Expected cave to have no bats')
  end

  def test_cave_move
    cave = Cave.new
    room1 = cave.room(13)
    room2 = cave.room(19)
    room1.add("hazard")
    cave.move("hazard", room1, room2)
    assert_includes(room2.hazards, "hazard", 'Expected hazards to be in room2')
    refute_includes(room1.hazards, "hazard", 'Expected hazards to not be in room1')
  end

  def test_cave_move_absent_hazard
    cave = Cave.new
    room1 = cave.room(13)
    room2 = cave.room(19)
    room1.add("bats")
    assert_raises ValueError do
      cave.move("hazard", room1, room2)
    end
  end

  def test_cave_entrance
    cave = Cave.new
    room = cave.entrance
    assert_empty(room.hazards, 'Expected entrance to have no hazards')
    assert_true(room.neighbors.all? { |n| n.hazards.empty? })
  end

  def test_player_enter_empty_room
    encountered = Set.new
    player = Player.new
    room = Room.new(18)
    player.encounter :guard do
      encountered.add('The guard killed you!')
    end
    player.encounter :bats do
      encountered.add('The bats whisked you away!')
    end
    player.enter(room)
    assert_empty(encountered, 'Expected player to encounter no hazards in an empty room')
  end

  def test_player_enter_empty_room_nonempty_neighbors
    encountered = Set.new
    player = Player.new
    room = Room.new(18)
    room1 = Room.new(19)
    room1.add(:guard)
    room2 = Room.new(9)
    room2.add(:bats)
    room.connect(room1)
    room.connect(room2)
    player.encounter :guard do
      encountered.add('The guard killed you!')
    end
    player.encounter :bats do
      encountered.add('The bats whisked you away!')
    end
    player.enter(room)
    assert_empty(encountered, 'Expected player to encounter no hazards in an empty room with neighbors with hazards')
  end

  def test_player_enter_guard_room
    encountered = Set.new
    player = Player.new
    room = Room.new(18)
    room.add(:guard)
    player.encounter :guard do
      encountered.add('The guard killed you!')
    end
    player.encounter :bats do
      encountered.add('The bats whisked you away!')
    end
    player.enter(room)
    assert_equal(Set.new.add('The guard killed you!'), encountered, 'Expected player to encounter guard')
  end

  def test_player_enter_bats_room
    encountered = Set.new
    player = Player.new
    room = Room.new(18)
    room.add(:bats)
    player.encounter :guard do
      encountered.add('The guard killed you!')
    end
    player.encounter :bats do
      encountered.add('The bats whisked you away!')
    end
    player.enter(room)
    assert_equal(Set.new.add('The bats whisked you away!'), encountered, 'Expected player to encounter bats')
  end

  def test_player_enter_multihazards_room_1
    encountered = Set.new
    player = Player.new
    room = Room.new(18)
    room.add(:bats)
    room.add(:guard)
    player.encounter :bats do
      encountered.add('The bats whisked you away!')
    end
    player.encounter :guard do
      encountered.add('The guard killed you!')
    end
    player.enter(room)
    assert_equal(Set.new.add('The bats whisked you away!'), encountered, 'Expected player to encounter bats')
  end

  def test_player_enter_multihazards_room_2
    encountered = Set.new
    player = Player.new
    room = Room.new(18)
    room.add(:bats)
    room.add(:guard)
    player.encounter :guard do
      encountered.add('The guard killed you!')
    end
    player.encounter :bats do
      encountered.add('The bats whisked you away!')
    end
    player.enter(room)
    assert_equal(Set.new.add('The guard killed you!'), encountered, 'Expected player to encounter bats')
  end

  def test_player_explore_room_with_empty_neighbors
    sensed = Set.new
    player = Player.new
    player.sense :pits do
      sensed.add('You feel a cold wind blowing from a nearby cabin')
    end
    room = Room.new(19)
    room1 = Room.new(13)
    room2 = Room.new(17)
    room.connect(room1)
    room.connect(room2)
    player.enter(room)
    player.explore_room
    assert_empty(sensed, 'Expecting to sense nothing')
  end

  def test_player_explore_room_with_pit_neighbors
    sensed = Set.new
    player = Player.new
    player.sense :pits do
      sensed.add('You feel a cold wind blowing from a nearby cabin')
    end
    room = Room.new(19)
    room1 = Room.new(13)
    room2 = Room.new(17)
    room2.add(:pits)
    room.connect(room1)
    room.connect(room2)
    player.enter(room)
    player.explore_room
    assert_equal(Set.new.add('You feel a cold wind blowing from a nearby cabin'), sensed, 'Expecting to sense pits')
  end

  def test_player_explore_room_with_multihazard_neighbors
    sensed = Set.new
    player = Player.new
    player.sense :pits do
      sensed.add('You feel a cold wind blowing from a nearby cabin')
    end
    player.sense :bats do
      sensed.add('You feel bats!')
    end
    room = Room.new(19)
    room1 = Room.new(13)
    room1.add(:bats)
    room2 = Room.new(17)
    room2.add(:pits)
    room.connect(room1)
    room.connect(room2)
    player.enter(room)
    player.explore_room
    assert_equal(Set.new(['You feel a cold wind blowing from a nearby cabin', 'You feel bats!']), sensed, 'Expecting to sense pitsand bats')
  end

  def test_player_act_1
    acted = Set.new
    player = Player.new
    player.action :move do |dest|
      acted.add("Move to #{dest}")
    end
    player.action :shoot do |dest|
      acted.add("Shot at #{dest}")
    end
    room = Room.new(16)
    player.act(:move, room)
    assert_equal(Set.new.add("Move to #{room}"), acted, "Expected to move to room #{room.number}")
  end

  def test_player_act_2
    acted = Set.new
    player = Player.new
    player.action :move do |dest|
      acted.add("Move to #{dest}")
    end
    player.action :shoot do |dest|
      acted.add("Shot at #{dest}")
    end
    room = Room.new(2)
    player.act(:shoot, room)
    assert_equal(Set.new.add("Shot at #{room}"), acted, "Expected to shoot at room #{room.number}")
  end

  def test_player_act_absent
    acted = Set.new
    player = Player.new
    player.action :move do |dest|
      acted.add("Move to #{dest}")
    end
    player.action :shoot do |dest|
      acted.add("Shot at #{dest}")
    end
    room = Room.new(12)
    assert_raises KeyError do
      player.act(:startle, room)
    end
  end
end
