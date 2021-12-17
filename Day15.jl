### A Pluto.jl notebook ###
# v0.17.3

using Markdown
using InteractiveUtils

# ╔═╡ 20b41c73-d878-41d8-8f71-55f25ba61f40
using PlutoUI

# ╔═╡ e4edad3b-7a12-4f91-81a0-cea89c9dd7e2
function parse_file(io::IO)
	lines = readlines(io)
	chars_on_lines = split.(lines, "")
	numbers = [parse.(Int8, col) for col in chars_on_lines]

	hcat(numbers...)'
end

# ╔═╡ fd7e83e8-5d67-11ec-3fb7-412662203424
md"""
# Problem 1
"""

# ╔═╡ 56d8f5f0-5bd8-4b99-ace0-af097ee3a499
md"""
**Previous failed attempts**
"""

# ╔═╡ 703f5ac9-8f98-4a35-a7fd-4e757957c148
md"""
The following assumes that you can only go **right** or **down** but after solving and submitting answer that assumption was invalid which I already knew but wanted to valited
"""

# ╔═╡ c6c5e204-7cfb-4797-8ca4-65c14a19719b
function get_lowest_risk_path_dr(risk_matrix)
	total_rows, total_cols = size(risk_matrix)
	low_cost_path = zeros(Int8, total_rows, total_cols)

	for row in total_rows:-1:1
		for col in total_cols:-1:1
			right_risk = col + 1 > total_cols ? nothing : low_cost_path[row, col+1]
			down_risk = row + 1 > total_rows ? nothing : low_cost_path[row+1, col]

			min_risk = 0
			if right_risk != nothing && down_risk != nothing
				min_risk = min(right_risk, down_risk)
			elseif right_risk != nothing
				min_risk = right_risk
			elseif down_risk != nothing
				min_risk = down_risk
			end
			
			low_cost_path[row, col] = risk_matrix[row, col] + min_risk
		end
	end
	low_cost_path
end

# ╔═╡ 6788b280-dc3d-485c-a764-654015081212
function get_lowest_risk_path_ul(risk_matrix)
	total_rows, total_cols = size(risk_matrix)
	low_cost_path = zeros(Int8, total_rows, total_cols)

	for row in 1:total_rows
		for col in 1:total_cols
			left_risk = col - 1 < 1 ? nothing : low_cost_path[row, col-1]
			up_risk = row - 1 < 1 ? nothing : low_cost_path[row-1, col]

			min_risk = 0
			if left_risk != nothing && up_risk != nothing
				min_risk = min(left_risk, up_risk)
			elseif left_risk != nothing
				min_risk = left_risk
			elseif up_risk != nothing
				min_risk = up_risk
			end
			
			low_cost_path[row, col] = risk_matrix[row, col] + min_risk
		end
	end
	low_cost_path
end

# ╔═╡ 304c4d09-dc2c-4cf3-aeb2-615ab7758969
function get_lowest_risk_path(risk_matrix)
	dr_risk_mx = get_lowest_risk_path_dr(risk_matrix)
	ul_risk_mx = get_lowest_risk_path_ul(risk_matrix)

	total_rows, total_cols = size(risk_matrix)
	low_cost_path = zeros(Int8, total_rows, total_cols)

	for row in total_rows:-1:1
		for col in total_cols:-1:1
			curr_risk = risk_matrix[row, col]
			dr_risk = dr_risk_mx[row, col] - curr_risk
			ul_risk = ul_risk_mx[row, col] - curr_risk

			low_cost_path[row, col] = curr_risk + min(dr_risk, ul_risk)
		end
	end

	low_cost_path
end

# ╔═╡ 8e6d017f-4318-4449-b61b-9ad06e28acfc
md"""
The following uses recursion (with memoization) but that would result into deep tree but lets see if that is fine for the problem or not.
"""

# ╔═╡ 72c988b7-204c-4a4a-a728-e2546790a707
function get_lowest_risk_path_recur(lowest_risk, row, col; visited_path = [])
	(total_rows, total_cols) = size(lowest_risk)
	if ((row == total_rows && col == total_cols))
		return (risk = lowest_risk[row, col], path = [(row, col)])
	end

	indexes_to_visit = filter(!=(nothing), [
		(col + 1 > total_cols ? nothing : (row, col + 1)),
		(row + 1 > total_rows ? nothing : (row + 1, col)),
		(col -1 < 1 ? nothing : (row, col - 1)),
		(row - 1 < 1 ? nothing : (row - 1, col))
	])

	push!(visited_path, (row, col))
	min_risk = 1000000
	path = []
	for (r,c) in indexes_to_visit
		if ((r, c) ∈ visited_path)
			continue
		end

		(calculated_risk, calculated_path) = get_lowest_risk_path_recur(lowest_risk, r, c; visited_path)
		if calculated_risk < min_risk
			@show calculated_risk, calculated_path, r, c
			min_risk = calculated_risk
			path = calculated_path
		end
		
	end

	deleteat!(visited_path, findall(==((row, col)),visited_path))
	return (risk = min_risk + lowest_risk[row, col], path = vcat([(row, col)], path))
end

	

# ╔═╡ 6858a18b-0c2b-419d-b489-a342727f91e4
md"""
#### Solving through Dijkstra's Algorithm
"""

# ╔═╡ b99d9b4e-806a-4356-93cd-518a9aab4861
md"""
Though I was aware that Dijkstra will certainly solve the problem but my previous attempts were to figure out some algorithm on my own without revising Dijkstra but then after few attempts I lost patience and brushed up Dijkstra to write up the solution
"""

# ╔═╡ 7601b7f4-c85e-424a-9d62-add76ba4e2e4
function get_lowest_risk_path_dijkstra(risk_matrix)
	total_rows, total_cols = size(risk_matrix)

	get_adjacent_edges(row, col) = filter(!=(nothing), [
		(col + 1 > total_cols ? nothing : (row, col + 1)),
		(row + 1 > total_rows ? nothing : (row + 1, col)),
		(col -1 < 1 ? nothing : (row, col - 1)),
		(row - 1 < 1 ? nothing : (row - 1, col))
	])

	# For checking if we have already calculated distance
	intree = similar(risk_matrix, Bool)
	intree .= false

	# Distance for each vertex
	distance = similar(risk_matrix, Int)
	distance .= typemax(Int)

	# For later figuring out the path, getting the parent of vertex
	parent = Dict{Tuple{Int, Int}, Tuple{Int, Int}}()

	distance[1, 1] = 0
	v = (1,1)

	while v != (total_rows, total_cols)
		r, c = v
		intree[r, c] = true
		edges = get_adjacent_edges(r, c)

		for (nr, nc) ∈ edges
			if distance[nr, nc] > distance[r, c] + risk_matrix[nr, nc]
				distance[nr, nc] = distance[r, c] + risk_matrix[nr, nc]
				parent[(nr, nc)] = (r, c)
			end
		end

		v = (1, 1)
		dist = typemax(Int)
		for row in 1:total_rows
			for col in 1:total_cols
				if intree[row, col] == false && distance[row, col] < dist
					dist = distance[row, col]
					v = (row, col)
				end
			end
		end
	end

	distance, parent
end

# ╔═╡ 0bb6d40a-207b-4283-9440-fd6a2f62d3cf
with_terminal() do
	open("./Day15/prob_input.txt") do io
		risk_matrix = parse_file(io)
		@time dist, _ = get_lowest_risk_path_dijkstra(risk_matrix)
		dist[end, end]
	end
end

# ╔═╡ 562c3921-cba2-4216-9a0c-d3b52154f6bf
md"""
# Problem 2
"""

# ╔═╡ dfa51308-99dd-41d6-bd95-521071d083fb
function create_bigger_matrix(risk_matrix, multiply_factor = (5, 5))
	orig_rows, orig_cols = size(risk_matrix)
	total_rows, total_cols = (orig_rows, orig_cols) .* multiply_factor
	new_matrix = zeros(Int8, total_rows, total_cols)
	new_matrix[1:orig_rows, 1:orig_cols] .= risk_matrix

	# First doing rows
	for r in 1:total_rows
		for c in 1:orig_cols
			if new_matrix[r, c] != 0
				continue
			end

			new_matrix[r, c] = new_matrix[r-orig_rows, c] == 9 ? 1 : new_matrix[r-orig_rows, c] + 1
		end
	end

	# Now doing cols
	for r in 1:total_rows
		for c in orig_cols+1:total_cols
			if new_matrix[r, c] != 0
				continue
			end

			new_matrix[r, c] = new_matrix[r, c-orig_cols] == 9 ? 1 : new_matrix[r, c-orig_cols] + 1
		end
	end
	

	new_matrix
end

# ╔═╡ 7c47b50e-d8b1-4d0e-abfb-b3d170273162
md"""
Though Dijkstra works great, I was curious to see if Bellman Ford algorithm will work better but it will take much more time than Dijkstra due to the huge size of array as it has to iterate $$|V| - 1$$ over the number of edges which in this case would be approx. $$TotalRows\times TotalCols \times 4$$.
"""

# ╔═╡ 6c304b7b-45ba-492b-b4df-7bb3c4b0c7ad
function get_lowest_risk_path_bellmanford(risk_matrix)
	total_rows, total_cols = size(risk_matrix)

	get_adjacent_edges(row, col) = filter(!=(nothing), [
		(col + 1 > total_cols ? nothing : (row, col + 1)),
		(row + 1 > total_rows ? nothing : (row + 1, col)),
		(col -1 < 1 ? nothing : (row, col - 1)),
		(row - 1 < 1 ? nothing : (row - 1, col))
	])

	# For checking if we have already calculated distance
	intree = similar(risk_matrix, Bool)
	intree .= false

	# Distance for each vertex
	distance = similar(risk_matrix, Int)
	distance .= typemax(Int)

	# For later figuring out the path, getting the parent of vertex
	parent = Dict{Tuple{Int, Int}, Tuple{Int, Int}}()

	distance[1, 1] = 0
	v = (1,1)

	for _ in 1:(total_rows * total_cols)-1
	for r in 1:total_rows
		for c in 1:total_cols
			edges = get_adjacent_edges(r, c)
	
			for (nr, nc) ∈ edges
				if distance[nr, nc] > distance[r, c] + risk_matrix[nr, nc]
					distance[nr, nc] = distance[r, c] + risk_matrix[nr, nc]
					parent[(nr, nc)] = (r, c)
				end
			end
		end
	end
	end

	distance, parent
end

# ╔═╡ 394d4a20-a45e-4139-aeff-a4c8dfa822c7
with_terminal() do
	open("./Day15/prob_test_input.txt") do io
		risk_matrix = parse_file(io)
		risk_matrix = create_bigger_matrix(risk_matrix)
		@time dist, _ = get_lowest_risk_path_dijkstra(risk_matrix)
		dist[end, end]
	end
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
PlutoUI = "~0.7.22"
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
git-tree-sha1 = "565564f615ba8c4e4f40f5d29784aa50a8f7bbaf"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.22"

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
# ╠═20b41c73-d878-41d8-8f71-55f25ba61f40
# ╠═e4edad3b-7a12-4f91-81a0-cea89c9dd7e2
# ╟─fd7e83e8-5d67-11ec-3fb7-412662203424
# ╟─56d8f5f0-5bd8-4b99-ace0-af097ee3a499
# ╟─703f5ac9-8f98-4a35-a7fd-4e757957c148
# ╟─c6c5e204-7cfb-4797-8ca4-65c14a19719b
# ╟─6788b280-dc3d-485c-a764-654015081212
# ╟─304c4d09-dc2c-4cf3-aeb2-615ab7758969
# ╟─8e6d017f-4318-4449-b61b-9ad06e28acfc
# ╟─72c988b7-204c-4a4a-a728-e2546790a707
# ╟─6858a18b-0c2b-419d-b489-a342727f91e4
# ╟─b99d9b4e-806a-4356-93cd-518a9aab4861
# ╠═7601b7f4-c85e-424a-9d62-add76ba4e2e4
# ╠═0bb6d40a-207b-4283-9440-fd6a2f62d3cf
# ╟─562c3921-cba2-4216-9a0c-d3b52154f6bf
# ╠═dfa51308-99dd-41d6-bd95-521071d083fb
# ╟─7c47b50e-d8b1-4d0e-abfb-b3d170273162
# ╟─6c304b7b-45ba-492b-b4df-7bb3c4b0c7ad
# ╠═394d4a20-a45e-4139-aeff-a4c8dfa822c7
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
