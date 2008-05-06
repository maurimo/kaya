module Chess
  class Validator
    def initialize(state)
      @state = state
    end
  
    def [](move)
      return false unless @state.board.valid? move.src
      return false unless @state.board.valid? move.dst
      return false if move.dst == move.src
      
      piece = @state.board[move.src]
      return false unless piece and piece.color == @state.turn
      
      target = @state.board[move.dst]
      return false if piece.same_color_of(target)
    
      m = "validate_#{piece.type}"
      if respond_to? m
        send(m, piece, target, move)
      else
        false
      end
    end
    
    def validate_pawn(piece, target, move)
      dir = @state.direction(piece.color)
      if target
        move.delta.y == dir.y and
        move.delta.x.abs == 1
      else
        case move.delta.y
        when dir.y
          move.delta.x == 0
        when dir.y * 2
          valid = move.src.y == @state.row(1, piece.color) and 
                  move.delta.x == 0 and 
                  not @state.board[move.src + dir]
          move.type = :en_passant_trigger if valid
          valid
        else
          false
        end
      end
    end
    
    def validate_king(piece, target, move)
      move.delta.x.abs <= 1 and 
      move.delta.y.abs <= 1
    end
    
    def validate_bishop(piece, target, move)
      range = move.range
      range.diagonal? and
      @state.board.clear_path? range
    end
    
    def validate_rook(piece, target, move)
      range = move.range
      range.parallel? and
      @state.board.clear_path? range
    end
    
    def validate_queen(piece, target, move)
      range = move.range
      range.valid? and
      @state.board.clear_path? range
    end
    
    def validate_knight(piece, target, move)
      [move.delta.x.abs, move.delta.y.abs].sort == [1, 2]
    end
  end
end
