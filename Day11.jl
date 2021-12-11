### A Pluto.jl notebook ###
# v0.17.3

using Markdown
using InteractiveUtils

# ╔═╡ acf93a06-f267-492d-a7e4-b7ef4d7d76e6
begin
	using PlutoUI
	using DataStructures
end

# ╔═╡ 9b4b3db2-cafa-419c-bd4c-3a873d00ffc9
function parse_line(line)
	return split(line, "") .|> x -> parse(Int8, x)
end

# ╔═╡ 4204f48a-cd9a-4354-85d6-72e8fec2609f
function parse_file(io::IO)
	return hcat([parse_line(line) for line in eachline(io)]...)'
end

# ╔═╡ f8da1464-6467-4985-a20b-a7f939c5c0ef
function simulate_and_find_flash_count!(energy_levels)
	flashed_state = similar(energy_levels, Bool)
	flashed_state .= false

	tr, tc = size(energy_levels)
	Ifirst, Ilast, Iunit = CartesianIndex(1,1), CartesianIndex(tr, tc), CartesianIndex(1, 1)

	# Step 1: Increase everything by unit 1
	energy_levels .+= 1
	R = findall(n -> n >= 10, energy_levels)
	queue = Queue{CartesianIndex}()
	map(I -> enqueue!(queue, I), R)
	energy_levels[R] .= 0
	flashed_state[R] .= true
	flash_count = length(R)
	while length(queue) > 0
		I = dequeue!(queue)
		# Step 2: For the flashing ones increase adjacent by 1
		for J in max(Ifirst, I-Iunit):min(Ilast, I+Iunit)
			if J == I || flashed_state[J] == true
				continue
			end

			energy_levels[J] += 1

			# Step 3: If the adjacent also needs to flash then add them to queue
			if energy_levels[J] >= 10
				flash_count+=1
				energy_levels[J] = 0
				flashed_state[J] = true
				enqueue!(queue, J)
			end
		end
	end

	flash_count
end

# ╔═╡ 2c8a36c2-5a53-11ec-0d8c-8fa39662cc35
md"""
# Problem 1
"""

# ╔═╡ c0665ceb-363e-48a6-b8cc-ece7deed4e1f
function simulate_and_find_flash_counts!(energy_levels; steps = 100)
	sum([simulate_and_find_flash_count!(energy_levels) for _ in 1:steps])
end

# ╔═╡ f6a5bb96-1f2f-475b-bdb9-c8f410b87a73
with_terminal() do
	open("./Day11/prob_input.txt") do io
		energy_levels = parse_file(io)
		@time simulate_and_find_flash_counts!(energy_levels; steps=100), energy_levels
	end
end

# ╔═╡ 2d26e9d7-3c9f-4104-ac53-e4ed10f17be9
md"""
# Problem 2
"""

# ╔═╡ bf0fed46-6b19-47c2-985b-d729f82ac106
function simulate_and_find_when_all_flash!(energy_levels; max_steps = 10_000)

	has_all_flashed = false
	current_step = 0

	while has_all_flashed == false && current_step <= max_steps
		current_step += 1
		simulate_and_find_flash_count!(energy_levels)

		has_all_flashed = all(energy_levels .== 0)
	end

	if (current_step > max_steps)
		error("Reached max number of steps :(")
	end

	return current_step
end

# ╔═╡ b4b78f2f-e612-49ef-8dcd-df035a992601
with_terminal() do
	open("./Day11/prob_input.txt") do io
		energy_levels = parse_file(io)
		@time simulate_and_find_when_all_flash!(energy_levels), energy_levels
	end
end

# ╔═╡ f0cb7c53-c228-430f-ac99-6306d81ef982
md"""
Though above solved the problem bu I want to to see if I can remove the extra step of checking all zeros after a step. As we get the flash_count afterwards so we can simply check if $$FlashCount = TotalRows \times TotalColumns$$.
"""

# ╔═╡ d544856c-bb85-453d-b601-583fdc6ce312
function simulate_and_find_when_all_flash_optim!(energy_levels; max_steps = 10_000)

	has_all_flashed = false
	current_step = 0
	tr, tc = size(energy_levels)

	while has_all_flashed == false && current_step <= max_steps
		current_step += 1
		has_all_flashed = simulate_and_find_flash_count!(energy_levels) == tr*tc
	end

	if (current_step > max_steps)
		error("Reached max number of steps :(")
	end

	return current_step
end

# ╔═╡ 5035ab78-1677-460b-b582-d31616ed9fd2
with_terminal() do
	open("./Day11/prob_input.txt") do io
		energy_levels = parse_file(io)
		@time simulate_and_find_when_all_flash_optim!(energy_levels), energy_levels
	end
end

# ╔═╡ c4b2c1a6-2d87-4a8e-9733-6464f50fed2d
md"""
The perf gain isn't hugely difference but it did remove approx. **0.7k** memory usage
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataStructures = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
DataStructures = "~0.18.10"
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

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "dce3e3fea680869eaa0b774b2e8343e9ff442313"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.40.0"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "7d9d316f04214f7efdbb6398d545446e246eff02"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.10"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

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

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

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

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

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
# ╠═acf93a06-f267-492d-a7e4-b7ef4d7d76e6
# ╠═9b4b3db2-cafa-419c-bd4c-3a873d00ffc9
# ╠═4204f48a-cd9a-4354-85d6-72e8fec2609f
# ╠═f8da1464-6467-4985-a20b-a7f939c5c0ef
# ╟─2c8a36c2-5a53-11ec-0d8c-8fa39662cc35
# ╠═c0665ceb-363e-48a6-b8cc-ece7deed4e1f
# ╠═f6a5bb96-1f2f-475b-bdb9-c8f410b87a73
# ╟─2d26e9d7-3c9f-4104-ac53-e4ed10f17be9
# ╠═bf0fed46-6b19-47c2-985b-d729f82ac106
# ╠═b4b78f2f-e612-49ef-8dcd-df035a992601
# ╟─f0cb7c53-c228-430f-ac99-6306d81ef982
# ╠═d544856c-bb85-453d-b601-583fdc6ce312
# ╠═5035ab78-1677-460b-b582-d31616ed9fd2
# ╟─c4b2c1a6-2d87-4a8e-9733-6464f50fed2d
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
