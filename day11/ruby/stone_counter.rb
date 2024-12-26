initial_stones = [0, 7, 198844, 5687836, 58, 2478, 25475, 894]

def process_stones(stone_set, current_blink, num_blinks)
  split_point = 1000000
  (current_blink..num_blinks).each do |counter|
    if stone_set.length >= split_point
      first_half, second_half = stone_set.each_slice((stone_set.size / 2.0).round).to_a
      first_half = process_stones(first_half, counter, num_blinks)
      second_half = process_stones(second_half, counter, num_blinks)
      return first_half + second_half
    end
    stone_set = stone_set.flat_map do |stone|
      if stone == 0
        [1]
      elsif stone.to_s.length % 2 == 0
        stone_string = stone.to_s
        midpoint = (stone_string.length / 2.0).ceil
        first_half = stone_string[0...midpoint]
        second_half = stone_string[midpoint..-1]
        [first_half.to_i, second_half.to_i]
      else
        [stone * 2024]
      end
    end
    puts "Blink #{counter}: #{num_blinks}"
  end
  stone_set.length
end

$score_cache = {}

def score_stone(stone, current_blink, num_blinks, score)
  if current_blink == num_blinks
    score += 1
  else
    if stone == 0
      if $score_cache.key?([1, current_blink + 1])
        return $score_cache[[1, current_blink + 1]]
      end
      score = score_stone(1, current_blink + 1, num_blinks, score)
      $score_cache[[1, current_blink + 1]] = score
      return score
    elsif stone.to_s.length % 2 == 0
      stone_string = stone.to_s
      midpoint = (stone_string.length / 2.0).ceil
      first_half = stone_string[0...midpoint]
      second_half = stone_string[midpoint..-1]
      if $score_cache.key?([first_half.to_i, current_blink + 1])
        score1 = $score_cache[[first_half.to_i, current_blink + 1]]
      else
        score1 = score_stone(first_half.to_i, current_blink + 1, num_blinks, score)
        $score_cache[[first_half.to_i, current_blink + 1]] = score1
      end
      if $score_cache.key?([second_half.to_i, current_blink + 1])
        score2 = $score_cache[[second_half.to_i, current_blink + 1]]
      else
        score2 = score_stone(second_half.to_i, current_blink + 1, num_blinks, score)
        $score_cache[[second_half.to_i, current_blink + 1]] = score2
      end
      return score1 + score2
    else
      if $score_cache.key?([stone*2024, current_blink + 1])
        return $score_cache[[stone*2024, current_blink + 1]]
      end
      score = score_stone(stone*2024, current_blink + 1, num_blinks, score)
      $score_cache[[stone*2024, current_blink + 1]] = score
      return score
    end
  end
end



stone_set = initial_stones
num_blinks = 25
processed_stones_lnegth = process_stones(stone_set, 1, num_blinks)
puts "Total stones method 1: #{processed_stones_lnegth}"

stone_count = 0
stone_set.each do |stone|
  stone_count += score_stone(stone, 0, 75, 0)
end

puts "Total stones method 2: #{stone_count}"
