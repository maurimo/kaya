class Table < Qt::GraphicsView
  attr_reader :elements

  Theme = Struct.new(:pieces, :board, :layout)

  def initialize(scene, loader, parent)
    super(@scene = scene, parent)
    @loader = loader
  end
  
  def reset(game)
    # destroy old elements
    if @elements
      @scene.remove_element(@elements[:board])
      @elements[:pools].each do |col, pool|
        @scene.remove_element(pool)
      end
      @elements[:clocks].each do |col, clock|
        @scene.remove_element(clock)
      end
    end
    
    # load theme
    @theme = Theme.new
    @theme.pieces = @loader.
      get_matching((game.keywords || []) + %w(pieces)).
      new(:game => game, :shadow => true)
    @theme.board = @loader.
      get_matching(%w(board), game.keywords || []).
      new(:game => game)
    @theme.layout = @loader.
      get_matching(%w(layout), game.keywords || []).
      new(game)

    # recreate elements
    @elements = { }
    @elements[:board] = Board.new(@scene, @theme, game)
    @elements[:pools] = if game.respond_to? :pool
      game.players.inject({}) do |res, player|
        res[player] = Pool.new(@scene, @theme, game)
        res
      end
    else
      {}
    end
    clock_class = @loader.get_matching(%w(clock))
    @elements[:clocks] = game.players.inject({}) do |res, player|
      res[player] = clock_class.new(scene)
      res
    end
    
    # relayout elements
    unless @scene.scene_rect.isNull
      @theme.layout.layout(@scene.scene_rect, @elements)
    end
  end
  
  def resizeEvent(e)
    r = Qt::RectF.new(0, 0, e.size.width, e.size.height)
    @scene.scene_rect = r
    if @elements
      @theme.layout.layout(r, @elements)
    end
  end
end
