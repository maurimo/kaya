# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'require_bundle'
require 'test/unit'
require 'rubygems'
require 'mocha'
require_bundle 'ics', 'match_handler'
require 'games/games'
require 'ostruct'

class TestMatchHandler < Test::Unit::TestCase
  def test_creation
    user = mock("user")
    protocol = mock("protocol") do |x|
      x.expects(:add_observer)
    end
    
    handler = ICS::MatchHandler.new(user, protocol)
    handler.on_creating_game :game => Game.get(:chess),
                             :number => 37,
                             :white => { :name => 'hello' },
                             :black => { :name => 'world' }
    assert_equal 1, handler.matches.size
    match, info = handler.matches[37]
    assert_equal 37, info[:number]
  end
  
  def test_style12
    user = mock("user") do |x|
      x.expects(:reset)
      x.expects(:color=).with(:white)
      x.expects(:color).at_least_once.returns(:white)
      x.expects(:premove=)
      x.expects(:name=).with('hello')
      x.expects(:update)
    end
    protocol = mock("protocol") do |x|
      x.expects(:add_observer)
    end
    
    handler = ICS::MatchHandler.new(user, protocol)
    game = Game.get(:chess)
    handler.on_creating_game :game => game,
                             :icsapi => ICS::ICSApi.new(game),
                             :number => 37,
                             :white => { :name => 'hello' },
                             :black => { :name => 'world' }
    handler.on_style12 OpenStruct.new(
                         :game_number => 37,
                         :relation => ICS::Style12::Relation::MY_MOVE,
                         :state => Game.get(:chess).state.new.tap {|s| s.setup },
                         :move_index => 0)
                       
    assert_equal 1, handler.matches.size
    match, info = handler.matches[37]
    assert match.started?    
  end
end