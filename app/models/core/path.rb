# Class usefull to represent a way to move in a level.
#
# Pushes are represented by upper case and moves by lower case
# It could be written in COMPRESSED mode, but in this class, it's
# UNCOMPRESSED for rapidity and flexibility.
#
# In compressed mode, when many moves in one direction, letters are prefixed
# by numbers.
#
# example uncompressed mode : rrrllUUUUUruLLLdlluRRRRdr
# example compressed mode : 3r2l5Uru3Ld2lu4Rdr

class Core::Path

  attr_reader :pushes_count, :moves_count, :moves

  # Constructor for a empty path
  def initialize(path)
    @pushes_count = 0
    @moves_count  = 0
    @moves        = ''

    if path =~ /\d/
      create_from_compressed(path)
    else
      create_from_uncompressed(path)
    end
  end

  # Add move in a direction
  def add_move(direction)
    if is_valid_direction(direction)
      @moves_count += 1
      @moves       += direction.downcase
    end
  end

  # Add push in a direction
  def add_push(direction)
    if is_valid_direction(direction)
      @moves_count  += 1
      @pushes_count += 1
      @moves        += direction.upcase
    end
  end

  # Add displacement in a direction.
  # push or move is automatically assigned following of the letter-case of direction
  def add_displacement(direction)
    if is_valid_direction(direction)
      @pushes_count += 1 if direction =~ /[[:upper:]]/
      @moves_count  += 1
      @moves        += direction
    end
  end

  #  Get letter of last action (can be move or push)
  def last_move
    @moves[-1]
  end

  # Delete last move or push
  def delete_last_move
    if @moves_count > 0
      @moves = @moves[0..-2]
      @pushes_count -= 1 if last_move =~ /[[:upper:]]/
      @moves_count  -= 1
      true
    else
      false
    end
  end

  def uncompressed_string_path
    @moves
  end

  def compressed_string_path
    compress_path(@moves)
  end

  def to_s
    uncompressed_string_path
  end

  private

  # Compress a path (see description of class)
  def compress_path(uncompressed_path)
    compressed_path = ''

    # We loop on each cell of the uncompressed path
    length = uncompressed_path.length
    i = 0

    while i < length
      j = 0
      tabi = uncompressed_path[i]

      # while it's the same displacement and we're not in the end
      while tabi == uncompressed_path[i] && i < length
        # (Identical moves)+=1
        j = j + 1
        i = i + 1
      end

      # If there are many moves in one direction
      if j >= 2
        compressed_path += j.to_s
      end

      # In every case, add direction next to it
      compressed_path += tabi
    end

    compressed_path
  end

  # Uncompress a path (see description of Path class)
  def uncompress_path(compressed_path)
    uncompressed_path = ''
    length = compressed_path.length
    i = 0

    # While we're not in the end of compressed path
    while i < length
      cell = compressed_path[i]
      nbr_buffer = ''

      # if not decimal, only 1 move/push
      if cell =~ /\D/
        nbr_buffer += '1'
      end

      # if decimal, we put it in buffer to create a number like ['1', '2'] for 12
      while cell =~ /\d/
        nbr_buffer += cell
        i = i + 1
        cell = compressed_path[i]
      end

      # ... and then convert the string on integer
      nbr = nbr_buffer.to_i

      # write nbr times the move/push
      nbr.times do
        uncompressed_path += compressed_path[i]
      end

      i = i + 1
    end

    uncompressed_path
  end

  def is_valid_direction(direction)
    %w(u d l r).include? direction.downcase
  end

  def create_from_uncompressed(uncompressed_path)
    uncompressed_path.each_char do |char|
      add_displacement(char)
    end
  end

  def create_from_compressed(compressed_path)
    displacements = uncompress_path(compressed_path)

    displacements.each_char do |char|
      add_displacement(char)
    end
  end
end
