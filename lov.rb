def roll
	rand(6) + 1
end

def roll_n(n)
	Array.new(n) { roll }
end

def boss_die(dice)
	if dice.empty? then
		0
	else
		dice.max
	end
end

def dice_value(dice)
	dice.reduce(:+)
end

def reorg(r, g, b, y)
	dice = { :r => roll_n(r), 
			 :g => roll_n(g), 
			 :b => roll_n(b),
			 :y => roll_n(y) }
	# puts dice.inspect

	value = dice_value(dice[:r] + dice[:g] + dice[:b] + dice[:y])
	boss_dice = Hash[dice.map { |color, dice| [color, boss_die(dice)] }]
	# puts boss_dice.inspect

	# find boss
	boss = nil
	boss_die = 0
	rolloff = false

	boss_dice.each do |color, die|
		if die > boss_die then
			boss = color
			boss_die = die
			rolloff = false
		elsif die == boss_die then
			rolloff = true
		end
	end

	if rolloff then
		# rolloff!
		return reorg(r, g, b, y)
	end

	return { :boss => boss, :value => value, :dice => dice }
end

def reorg_monte_carlo(r, g, b, y, n)
	boss_times = {:r => 0, :g => 0, :b => 0, :y => 0}
	total_value = 0

	n.times do
		result = reorg(r, g, b, y)

		boss_times[result[:boss]] += 1
		total_value += result[:value]
	end

	odds = Hash[boss_times.map { |color, times| [color, times.to_f / n.to_f] }]
	exp_value = total_value.to_f / n.to_f

	return { :odds => odds, :exp_value => exp_value }
end

MAX_CASINO_SIZE = 9

def sweep_space(n)
	all_casinos = (0..MAX_CASINO_SIZE).to_a.repeated_permutation(4).select do |r, g, b, y|
		r >= g and g >= b and b >= y and 
			(r + g + b + y >= 1) and (r + g + b + y <= MAX_CASINO_SIZE)
	end

	puts "r,g,b,y,r odds,g odds,b odds,y odds,expected value"

	all_casinos.each do |r, g, b, y|
		results = reorg_monte_carlo(r, g, b, y, n)

		puts "#{r}, #{g}, #{b}, #{y}, #{results[:odds][:r]}, #{results[:odds][:g]}, #{results[:odds][:b]}, #{results[:odds][:y]}, #{results[:exp_value]}"
	end
end

if __FILE__ == $0 then
	sweep_space(ARGV[0].to_i)
end