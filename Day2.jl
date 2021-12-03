### A Pluto.jl notebook ###
# v0.17.2

using Markdown
using InteractiveUtils

# ╔═╡ 406dbd9c-147d-4ef1-ba55-26331969f7ba
function parse_line(line::String)
	words = split(line)

	return (words[1], parse(Int32, words[2]))
end

# ╔═╡ 072e2ea8-5335-11ec-20cd-4d8bb45ce3fb
md"""
# Problem 1
"""

# ╔═╡ 716db1fa-5d05-4908-a371-ca1ed73760ef
function calculate_position(io::IO)
	horizontal, depth = 0, 0
	for line in eachline(io)
		(direction, val) = parse_line(line)
		if (direction == "forward")
			horizontal += val
		else
			depth += (direction == "down") ? val : -val
		end
	end

	return (horizontal, depth)
end
		

# ╔═╡ 845085c7-6a2b-4711-a737-bebcc8d112f1
open("./Day2/prob_1_input.txt") do io
	(horizontal, depth) = calculate_position(io)

	horizontal * depth
end

# ╔═╡ 76aa797f-4623-4028-a750-b797b13ac428
md"""
# Problem 2
"""

# ╔═╡ aee479d0-ceab-4120-b9d1-9fac251885ee
function calculate_aim_position(io::IO)
	horizontal, depth, aim = 0, 0, 0
	for line in eachline(io)
		(direction, val) = parse_line(line)
		if (direction == "forward")
			horizontal += val
			depth += aim * val
		else
			aim += (direction == "down") ? val : -val
		end
	end

	return (horizontal, depth)
end

# ╔═╡ 578a6384-faec-4dff-9c52-a32b533ab382
open("./Day2/prob_1_input.txt") do io
	(horizontal, depth) = calculate_aim_position(io)

	horizontal * depth
end

# ╔═╡ Cell order:
# ╠═406dbd9c-147d-4ef1-ba55-26331969f7ba
# ╟─072e2ea8-5335-11ec-20cd-4d8bb45ce3fb
# ╠═716db1fa-5d05-4908-a371-ca1ed73760ef
# ╠═845085c7-6a2b-4711-a737-bebcc8d112f1
# ╟─76aa797f-4623-4028-a750-b797b13ac428
# ╠═aee479d0-ceab-4120-b9d1-9fac251885ee
# ╠═578a6384-faec-4dff-9c52-a32b533ab382
