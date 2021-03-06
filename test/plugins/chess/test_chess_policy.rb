# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'test/unit'
require 'games/games'
require 'helpers/validation_helper'

class TestChessPolicy < Test::Unit::TestCase
  include ValidationHelper
  
  def setup
    @chess = Game.get(:chess)
    @policy = @chess.policy.new
    @state = @chess.state.new
  end
  
  def test_movable
    @state.setup
    
    assert_movable :movable, 4, 6
    assert_movable :premovable, 4, 1
    assert_not_movable 5, 5
  end
  
  def test_movable_empty
    assert_not_movable 2, 3
    assert_not_movable 7, 6
  end
  
  def test_movable_out_of_board
    assert_not_movable 23, 1
    assert_not_movable 6, 54
    assert_not_movable -7, 42
  end
  
  private
  
  def assert_movable(result, *args)
    assert_equal result, @policy.movable?(@state, unpack_point(*args))
  end
  
  def assert_not_movable(*args)
    assert !@policy.movable?(@state, unpack_point(*args))
  end
end
