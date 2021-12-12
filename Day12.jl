### A Pluto.jl notebook ###
# v0.17.3

using Markdown
using InteractiveUtils

# ╔═╡ cddb8fc0-e669-4ee3-aa6a-ca0bead5f797
using PlutoUI, SparseArrays

# ╔═╡ 9a43ed95-3429-4fe7-b59a-687545d62bb2
function parse_line(line)
	return split(line, "-")
end

# ╔═╡ f702795f-6248-49fd-b492-b15a59bea7ce
function parse_file(io::IO)
	return [parse_line(line) for line in eachline(io)]
end

# ╔═╡ 243ada36-4bd1-4795-b693-c07cb6601009
@enum CaveType LargeCave SmallCave

# ╔═╡ 277658d9-4985-439e-aab8-308adb6dad8e
struct Cave
	symbol::String
	cave_type::CaveType
	connections::Vector{Cave}
end

# ╔═╡ 71587e54-f551-4799-9c5d-da8c8ac250fb
struct CaveGraph
	graph::Dict{String, Cave}
end

# ╔═╡ 31ee1b11-bd3e-4045-b8b7-e42767a6862e
get_cave_type(symbol) = match(r"^[A-Z]+$", symbol) != nothing ? LargeCave : SmallCave

# ╔═╡ 5656e7ef-20b0-41cc-aef3-48ed59a2e267
function create_graph(connections)::CaveGraph
	graph = CaveGraph(Dict{String, Cave}())

	for (lhs, rhs) in connections
		lhs_cave = get(graph.graph, lhs, Cave(lhs, get_cave_type(lhs), []))
		rhs_cave = get(graph.graph, rhs, Cave(rhs, get_cave_type(rhs), []))

		push!(lhs_cave.connections, rhs_cave)
		push!(rhs_cave.connections, lhs_cave)

		graph.graph[lhs] = lhs_cave
		graph.graph[rhs] = rhs_cave
	end

	return graph
end

# ╔═╡ 291c8a77-212c-45e1-809b-93aeadf61795
begin
	const START_SYMBOL = "start"
	const END_SYMBOL = "end"

	START_SYMBOL, END_SYMBOL
end

# ╔═╡ 5c98ee3c-5b0a-11ec-1d41-c7c47bfb9414
md"""
# Problem 1
"""

# ╔═╡ ee8dfb78-dc61-4f32-900d-2871d5fc2ea1
function calculate_unique_paths(cave::Cave, caves_explored::Dict{String, Bool})
	if cave.symbol == END_SYMBOL
		return 1
	end

	caves_explored[cave.symbol] = true

	unique_path = 0
	for connected_cave in cave.connections
		if connected_cave.cave_type == SmallCave && get(caves_explored,connected_cave.symbol, false) == true
			# Skip small caves that have already been explored
			continue
		end
		unique_path += calculate_unique_paths(connected_cave, caves_explored)
	end
		
	caves_explored[cave.symbol] = false
	return unique_path
end

# ╔═╡ a4c6c06f-bc65-4512-9a6d-b3357610682a
function calculate_unique_paths(graph::CaveGraph)
	caves_explored = Dict{String, Bool}()
	start_cave = graph.graph[START_SYMBOL]
	caves_explored[START_SYMBOL] = true

	return calculate_unique_paths(start_cave, caves_explored)
end

# ╔═╡ 404e0e47-6c8a-4c6a-af82-2c47928853ad
with_terminal() do
	open("./Day12/prob_input.txt") do io
		connections = parse_file(io)
		@time graph = create_graph(connections)
		@time calculate_unique_paths(graph)
	end
end

# ╔═╡ d159a15e-f1c1-4310-be63-e62bbc0f8988
md"""
# Problem 2
"""

# ╔═╡ 54bda8f0-c8f1-4967-8eb5-a97e9ec3d547
fib(n) = n <= 1 ? n : fib(n-1) + fib(n-2)

# ╔═╡ dabf5a6a-e48c-46bc-83e0-0162cb6d4495
md"""
In this problem we have the option of visting **only one** small cave twice but all other small caves in the path should be visted once. The only exceptions are `"start"` and `"end"` state.

What we do is that we we discover path we maintain a state in that path context which checks if we already visited a small cave in previous part of path more than once. If we have then don't try going to another small cave twice.

In the rescursive function that state is represented as `used_extra_hop`.

We also change our exploration dictionary from `Bool` to `Int` as in case of `Bool` if we visit that node twice then it can be set to false when we get out of it once, even though its still in the previous path so that can lead to an infinite recursion
"""

# ╔═╡ 4c3bf2f3-be86-410e-9b23-7b92ea7ecf63
function calculate_unique_paths_prob2(cave::Cave, caves_explored::Dict{String, Int}, used_extra_hop::Bool)
	if cave.symbol == END_SYMBOL
		# If we got to end then stop further path finding as
		# it's the terminal state
		return 1
	end

	caves_explored[cave.symbol] += 1

	unique_path = 0
	for connected_cave in cave.connections
		if connected_cave.symbol == START_SYMBOL
			# Skip going to start as it can only be visited once
			continue
		end
		
		added_extra_hop = used_extra_hop
		# 1. If the cave is `LargeCave` it will fail all these conditions
		#    and we can continue with exploring path.
		# 2. If its a `SmallCave` then
		#    a. If we have visited this node once or more AND we have previously
		#       explored a `SmallCave` twice then skip. (BTW if it has been 
		#       visited twice then `added_extra_hop` will be `true` but if its
		#       visited only once then it could be either `true` or `false)
		#    b. If the small cave has only been visited once AND we have previously
		#       not explored a `SmallCave` twice then explore it.
		#    c. If it doesnt meet **a** and **b** then it means its either `LargeCave`
		#       or a `SmallCave` we have not explored before or if we have explored
		#       before then we can't explore twice because this or some other cave
		#       was explored twice before.
		if (connected_cave.cave_type == SmallCave && 
			get(caves_explored,connected_cave.symbol, 0) >= 1 &&
			added_extra_hop == true)
			continue
		elseif (connected_cave.cave_type == SmallCave && 
			get(caves_explored,connected_cave.symbol, 0) == 1 &&
			added_extra_hop == false)
			added_extra_hop = true
		end
		
		unique_path += calculate_unique_paths_prob2(
			connected_cave, caves_explored, added_extra_hop)
	end

	caves_explored[cave.symbol] -= 1
	return unique_path
end

# ╔═╡ 66bcf1f5-e53b-445c-a6df-af857096f26d
function calculate_unique_paths_prob2(graph::CaveGraph)
	caves_explored = Dict{String, Int}()
	map(sym -> caves_explored[sym] = false, collect(keys(graph.graph)))
	
	start_cave = graph.graph[START_SYMBOL]

	return calculate_unique_paths_prob2(start_cave, caves_explored, false)
end

# ╔═╡ 88b06d6b-1864-46f5-ab6d-3fb4960116ba
with_terminal() do
	open("./Day12/prob_input.txt") do io
		connections = parse_file(io)
		@time graph = create_graph(connections)
		@time calculate_unique_paths_prob2(graph)
	end
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

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

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

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

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

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
# ╠═cddb8fc0-e669-4ee3-aa6a-ca0bead5f797
# ╟─9a43ed95-3429-4fe7-b59a-687545d62bb2
# ╟─f702795f-6248-49fd-b492-b15a59bea7ce
# ╠═243ada36-4bd1-4795-b693-c07cb6601009
# ╠═277658d9-4985-439e-aab8-308adb6dad8e
# ╠═71587e54-f551-4799-9c5d-da8c8ac250fb
# ╠═31ee1b11-bd3e-4045-b8b7-e42767a6862e
# ╠═5656e7ef-20b0-41cc-aef3-48ed59a2e267
# ╟─291c8a77-212c-45e1-809b-93aeadf61795
# ╟─5c98ee3c-5b0a-11ec-1d41-c7c47bfb9414
# ╠═ee8dfb78-dc61-4f32-900d-2871d5fc2ea1
# ╠═a4c6c06f-bc65-4512-9a6d-b3357610682a
# ╠═404e0e47-6c8a-4c6a-af82-2c47928853ad
# ╟─d159a15e-f1c1-4310-be63-e62bbc0f8988
# ╠═54bda8f0-c8f1-4967-8eb5-a97e9ec3d547
# ╟─dabf5a6a-e48c-46bc-83e0-0162cb6d4495
# ╠═4c3bf2f3-be86-410e-9b23-7b92ea7ecf63
# ╠═66bcf1f5-e53b-445c-a6df-af857096f26d
# ╠═88b06d6b-1864-46f5-ab6d-3fb4960116ba
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
