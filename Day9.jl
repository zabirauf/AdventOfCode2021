### A Pluto.jl notebook ###
# v0.17.3

using Markdown
using InteractiveUtils

# ╔═╡ 2f31f995-6912-4e0f-a15b-d60475ead9c2
using PlutoUI

# ╔═╡ 7cbe7b32-d48f-4ec9-98fd-8290f699ac27
function parse_line(line)
	return split(line, "") .|> x -> parse(Int8, x)
end

# ╔═╡ e6d9e1aa-835f-453c-bff5-2af65126b602
function parse_file(io::IO)
	parsed_lines = [parse_line(line) for line in eachline(io)]
	return hcat(parsed_lines...)'
end

# ╔═╡ 56ce6882-cea3-4538-b68e-4a85d413997a
function get_adjacent_indexes(row, col, size)
	(total_rows, total_cols) = size
	return ([
		(row, max(1, col-1)) # Left
		(min(total_rows, row+1), col) # Down
		(row, min(total_cols, col+1)) # Right
		(max(1, row-1), col) # Up
	] |> indexes -> filter(i -> i != (row, col), indexes))
end

# ╔═╡ 717b0ffc-e7e6-4ecb-b279-160aa014d6fb
function is_lowest_point(floor_heights, row, col, size)
	for (adj_row, adj_col) in get_adjacent_indexes(row, col, size)
		if floor_heights[row, col] >= floor_heights[adj_row, adj_col]
			return false
		end
	end

	return true
end

# ╔═╡ a337fb2a-58b3-11ec-1ece-d19469cc4ca0
md"""
# Problem 1
"""

# ╔═╡ cb1367bf-3c21-4cb4-b0cc-3e0643e8b5d4
function find_low_points(floor_heights)
	data_size = size(floor_heights)
	(total_rows, total_cols) = data_size

	risk_level = 0
	for row in 1:total_rows
		for col in 1:total_cols
			if is_lowest_point(floor_heights, row, col, data_size)
				risk_level += floor_heights[row, col] + 1
			end
		end
	end

	return risk_level
end

# ╔═╡ b8f6d8cd-4ddb-4a39-9de2-9c7519892a19
with_terminal() do
	open("./Day9/prob_input.txt") do io
		floor_heights = parse_file(io)
		@time find_low_points(floor_heights)
	end
end

# ╔═╡ 2f7ba442-c9cc-4840-9cbe-63ad0d179f62
md"""
# Problem 2
"""

# ╔═╡ 9d3ea07e-d6ba-4249-8fdc-cf0d66a512b6
# This is DFS
function find_basin_size((row, col), data_size, floor_heights; explored=zeros(Bool, data_size...))
	if explored[row, col] == true
		return 0
	end

	curr_val = floor_heights[row, col]
	explored[row, col] = true
	adjacent_indexes = filter(
		function(pos)
			(r, c) = pos
			(explored[r, c] == false && 
			floor_heights[r, c] < 9 &&
			floor_heights[r, c] > curr_val)
		end,
		get_adjacent_indexes(row, col, data_size))

	adj_basin_sizes = [
		find_basin_size(ai, data_size, floor_heights; explored) 
			for ai in adjacent_indexes]
	return length(adj_basin_sizes) > 0 ? (sum(adj_basin_sizes) + 1) : 1
end

# ╔═╡ 4fe3fdec-4c85-4128-920a-ec74c5b654b9
function find_basin_sizes_simple(floor_heights)
	data_size = size(floor_heights)
	(total_rows, total_cols) = data_size
	return [find_basin_size((row, col), data_size, floor_heights) for col in 1:total_cols for row in 1:total_rows]
end

# ╔═╡ 5e937749-e810-44c0-9991-a5981602426b
md"""
The `find_basin_sizes_simple` is a basic Depth First Search so it makes for simpler code though its doesn't use memory efficiently. The reason is that we are exploring all the points and doing recursion at each point which consumes more memory due to maintaining call stack.
Instead we can use the solution from previous problem and first find lowest_points and then do Depth First Search from that. 
"""

# ╔═╡ da5c275a-62e4-4217-81eb-abcc13943a65
function find_basin_sizes_optim(floor_heights)
	data_size = size(floor_heights)
	(total_rows, total_cols) = data_size

	lowest_points = []
	for row in 1:total_rows
		for col in 1:total_cols
			if is_lowest_point(floor_heights, row, col, data_size)
				push!(lowest_points, (row, col))
			end
		end
	end

	return [find_basin_size(lp, data_size, floor_heights) for lp in lowest_points]
end

# ╔═╡ 8924f1fc-3fbc-4e0e-870e-e5b2e129caad
with_terminal() do
	open("./Day9/prob_input.txt") do io
		floor_heights = parse_file(io)
		@time basin_sizes = find_basin_sizes_simple(floor_heights) |> sort
		reduce(*, basin_sizes[end-2:end])
	end
end

# ╔═╡ b188c07b-36da-4c08-84ee-27c7434b4d30
# Using optimized solution
with_terminal() do
	open("./Day9/prob_input.txt") do io
		floor_heights = parse_file(io)
		@time basin_sizes = find_basin_sizes_optim(floor_heights) |> sort
		reduce(*, basin_sizes[end-2:end])
	end
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
PlutoUI = "~0.7.21"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "abb72771fd8895a7ebd83d5632dc4b989b022b5b"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.2"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "ae4bbcadb2906ccc085cf52ac286dc1377dceccc"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.2"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "b68904528fd538f1cb6a3fbc44d2abdc498f9e8e"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.21"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╠═2f31f995-6912-4e0f-a15b-d60475ead9c2
# ╠═7cbe7b32-d48f-4ec9-98fd-8290f699ac27
# ╠═e6d9e1aa-835f-453c-bff5-2af65126b602
# ╠═56ce6882-cea3-4538-b68e-4a85d413997a
# ╠═717b0ffc-e7e6-4ecb-b279-160aa014d6fb
# ╟─a337fb2a-58b3-11ec-1ece-d19469cc4ca0
# ╠═cb1367bf-3c21-4cb4-b0cc-3e0643e8b5d4
# ╠═b8f6d8cd-4ddb-4a39-9de2-9c7519892a19
# ╟─2f7ba442-c9cc-4840-9cbe-63ad0d179f62
# ╠═9d3ea07e-d6ba-4249-8fdc-cf0d66a512b6
# ╠═4fe3fdec-4c85-4128-920a-ec74c5b654b9
# ╟─5e937749-e810-44c0-9991-a5981602426b
# ╠═da5c275a-62e4-4217-81eb-abcc13943a65
# ╠═8924f1fc-3fbc-4e0e-870e-e5b2e129caad
# ╠═b188c07b-36da-4c08-84ee-27c7434b4d30
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
