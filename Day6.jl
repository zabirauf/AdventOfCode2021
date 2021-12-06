### A Pluto.jl notebook ###
# v0.17.2

using Markdown
using InteractiveUtils

# ╔═╡ fe995cf0-17b8-49a1-9a8f-f423baf9ba2c
using PlutoUI

# ╔═╡ a10662df-3345-4079-b4da-9d60f42e15bc
function parse_file(io::IO)
	line = readline(io)
	return split(line, ",") .|> n -> parse(Int8, n)
end

# ╔═╡ 13889350-565a-11ec-052a-8b04d2d164d3
md"""
# Problem 1
"""

# ╔═╡ 483cc560-d648-49de-b611-0121dc8ce51e
function simulate_lanternfish(initial_state, number_of_days)
	simulated_state = copy(initial_state)

	while number_of_days > 0
		# Removed the initial optimization I thought of because
		# in practice it was approx. simulating everyday. So
		# removing it helped to remove the extra cost of finding min
		# making it faster
		days_to_simulate = 1 #min(min(simulated_state...)+1, number_of_days)

		simulated_state .-= days_to_simulate
		new_fish_to_generate = count(n -> n < 0, simulated_state)
		simulated_state[simulated_state .< 0] .= 6
		
		push!(simulated_state, repeat([8], new_fish_to_generate)...)
		
		number_of_days -= days_to_simulate
	end

	return length(simulated_state)
end

# ╔═╡ 738739e5-6b80-4d08-b1d6-6fdf7a48b5e4
with_terminal() do
	open("./Day6/prob_input.txt") do io
		initial_state = parse_file(io)
		@time simulate_lanternfish(initial_state, 80)
	end
end

# ╔═╡ df5e5830-d89e-4619-bac7-c874919eae69
md"""
# Problem 2
"""

# ╔═╡ 570305cb-ea4f-4953-a27e-2f4e20c1e17a
md"""
The previous solution was unoptimized as it was using arrays which kept on getting bigger and bigger and it also had to iterate over the evergrowing array on everyday to simulate. Instead of that brute force approach we optimized it by computing state before hand and simulating over that.
"""

# ╔═╡ d877cd8c-1b53-4e45-b4d4-c7eaf93ef99d
md"""
What we do is that as we know the life of a fish can be maximum `8` so we only need to maintain number of fishes who have life `[0,1,2,3,4,5,6,7,8]` and then we can just move the number of fished back and add new fishes. E.g. if there are $113$ fished who have life span of $3$ then we just $-113$ from state that is keeping track of lifespan of $3$ and add $+113$ to the state keeping track of lifespan of $2$.
"""

# ╔═╡ 713e4362-ba13-492a-baba-31524b68ff31
function simulate_lanternfish_optim(initial_state, number_of_days)
	NEW_FISH_LIFE = 8
	REJUVINATE_LIFE = 6
	computed_state = zeros(Int128, NEW_FISH_LIFE+1)
	for fish_life in initial_state
		# Plus 1 is because Julia is 1-based index
		computed_state[fish_life + 1] += 1
	end

	for _ in 1:number_of_days
		fish_recycled = computed_state[1]
		computed_state[1:NEW_FISH_LIFE] .= computed_state[2:NEW_FISH_LIFE+1]
		computed_state[NEW_FISH_LIFE + 1] = fish_recycled
		computed_state[REJUVINATE_LIFE + 1] += fish_recycled
	end

	return sum(computed_state)
end

# ╔═╡ 1af20975-9cf1-407d-978c-cfd284e642af
with_terminal() do
	open("./Day6/prob_input.txt") do io
		initial_state = parse_file(io)
		@time simulate_lanternfish_optim(initial_state, 256)
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
# ╠═fe995cf0-17b8-49a1-9a8f-f423baf9ba2c
# ╠═a10662df-3345-4079-b4da-9d60f42e15bc
# ╟─13889350-565a-11ec-052a-8b04d2d164d3
# ╠═483cc560-d648-49de-b611-0121dc8ce51e
# ╠═738739e5-6b80-4d08-b1d6-6fdf7a48b5e4
# ╟─df5e5830-d89e-4619-bac7-c874919eae69
# ╟─570305cb-ea4f-4953-a27e-2f4e20c1e17a
# ╟─d877cd8c-1b53-4e45-b4d4-c7eaf93ef99d
# ╠═713e4362-ba13-492a-baba-31524b68ff31
# ╠═1af20975-9cf1-407d-978c-cfd284e642af
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
