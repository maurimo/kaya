require 'observer_utils'
require 'history'

module Player
  include Observer
end

class Match
  include Observable
  
  attr_reader :game
  attr_reader :history
  attr_reader :index
  attr_reader :kind
  
  def initialize(game, kind = :local)
    @game = game
    @players = { } # player => ready
    @history = nil
    @kind = kind
  end
  
  def register(player)
    return false if @history
    return false if @players.has_key?(player)
    return false if complete?
    return false unless @game.players.include?(player.color)
    
    @players[player] = false
    fire :complete if complete?
    true
  end
  
  def start(player)
    return false if @history
    return false unless complete?
    return false unless @players[player] == false
    
    @players[player] = true
    if @players.values.all?
      state = @game.state.new
      state.setup
      @history = History.new(state)
      @index = 0
      fire :started
    end

    true
  end
  
  def move(player, move, state = nil)
    return false unless @history
    # if player is nil, assume the current player is moving
    if player == nil
      player = current_player
    else
      return false unless @players.has_key?(player)
      return false unless player.color == @history.state.turn
    end

    validate = @game.validator.new(@history.state)
    valid = validate[move]
    return false unless valid

    old_state = @history.state
    state = old_state.dup
    state.perform! move
    @history.add_move(state, move)
    @index += 1
    
    broadcast player, :move => {
      :player => player,
      :move => move,
      :state => state,
      :old_state => old_state }
    true
  end
  
  def complete?
    @game.players.all? do |c| 
      @players.keys.find {|p| p.color == c }
    end
  end
  
  def started?
    ! ! @history
  end
  
  def state
    @history.state
  end
  
  private
  
  def broadcast(player, event)
    fire event
    @players.each_key do |p|
      p.update any_to_event(event) unless p == player
    end
  end
  
  def current_player
    @players.keys.find {|p| p.color == state.turn }
  end
end