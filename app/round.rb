require 'yaml'

class Round
  attr_reader :winner

  def initialize(game, view, human, ai)
    @game = game
    @view = view
    @players = [human, ai]
    @turn = 0
    @winner = nil
  end

  def setup
    user_piece = @view.ask_for_piece
    @players.first.piece = user_piece
    user_piece == 'X' ? ai_piece = 'O' : ai_piece = 'X'
    @players.last.piece = ai_piece
    @turn = @view.ask_for_order - 1
    start
  end

  def start
    @view.show_start(current_turn)
    until @game.over?
      get_next_move(current_turn)
      if @game.winner
        declare_winner(@game.winner)
      elsif @game.draw?
        declare_draw
      else
        change_turn
      end
    end
  end

  def change_turn
    @turn == 1 ? @turn = 0 : @turn = 1
  end

  def current_turn
    @players[@turn]
  end

  def get_next_move(player)
    @view.print_board(@game)
    @view.show_turn(player)
    move = player.next_move(@game)
    until @game.valid_move?(move, player.piece)
      @view.show_invalid_move(@game, player)
      move = player.next_move(@game)
    end
    @game.make_move(move, player.piece)
  end

  def declare_winner(piece)
    @winner = player_with_piece(piece)
    @view.print_board(@game)
    @view.show_winner(@winner)
    finish
  end

  def player_with_piece(piece)
    @players.find { |player| player.piece == piece }
  end

  def declare_draw
    @view.print_board(@game)
    @view.show_draw
    finish
  end

  def finish
    save_game
    @view.show_record(record)
  end

  def record
    YAML.load_file('record.yaml')
  end

  def save_game
    record = YAML.load_file('record.yaml')
    if @winner
      strategy_name = @winner.class.name.split('::').last
      record[strategy_name] ? record[strategy_name] += 1 : record[strategy_name] = 1
    else
      record['Draws'] += 1
    end
    File.open('record.yaml', 'w') { |f| YAML.dump(record, f) }
  end
end

