### A Pluto.jl notebook ###
# v0.17.2

using Markdown
using InteractiveUtils

# ╔═╡ 404094b6-52df-11ec-0bfa-b9c6548fb58c
md"""
# Problem 1
"""

# ╔═╡ 98dfb17d-5b7f-4e9b-873e-4d78b969b2e2
lines = parse.(Int32, readlines("Day1/prob_1_input.txt")); lines[1:5]

# ╔═╡ fecc137a-6907-44d3-ba4e-e64ef6c48fdf
function count_larger_than_prev(nums::Array{Int32})
	count = 0
	for i in 2:length(nums)
		count += nums[i-1] < nums[i] ? 1 : 0
	end

	return count
end

# ╔═╡ 658bbe23-577e-43e9-9c33-45bbb47cbc43
count_larger_than_prev(lines)

# ╔═╡ 094f9913-f965-4abe-9a69-081d2b33f511
md"""
# Problem 2
"""

# ╔═╡ 7f39e519-ede7-43e1-aab0-0fa294dea6da
function count_larger_than_prev_rolling_window(nums::Array{Int32})
	count = 0
	prev_sum = sum(nums[1:3])
	for i in 4:length(nums)
		new_sum = sum(nums[i-2:i])
		count += prev_sum < new_sum ? 1 : 0
		prev_sum = new_sum
	end

	return count
end
		

# ╔═╡ a9b6041a-1df1-42a9-8eab-2f29ae88763e
count_larger_than_prev_rolling_window(lines)

# ╔═╡ Cell order:
# ╟─404094b6-52df-11ec-0bfa-b9c6548fb58c
# ╠═98dfb17d-5b7f-4e9b-873e-4d78b969b2e2
# ╠═fecc137a-6907-44d3-ba4e-e64ef6c48fdf
# ╠═658bbe23-577e-43e9-9c33-45bbb47cbc43
# ╟─094f9913-f965-4abe-9a69-081d2b33f511
# ╠═7f39e519-ede7-43e1-aab0-0fa294dea6da
# ╠═a9b6041a-1df1-42a9-8eab-2f29ae88763e
