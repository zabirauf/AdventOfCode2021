### A Pluto.jl notebook ###
# v0.17.3

using Markdown
using InteractiveUtils

# ╔═╡ f90ea9fd-d607-4e2d-8dc5-c3db88e79d8d
begin
	using PlutoUI
	using DataStructures
end

# ╔═╡ 33391766-ca23-48f8-a20e-e08134fc74da
function parse_file(io::IO)
	return [collect(line) for line in eachline(io)]
end

# ╔═╡ 474eaa7d-f432-493b-afcb-661e0077f08a
is_starting_char(c) = c == '{' || c == '(' || c == '<' || c == '['

# ╔═╡ 16efd634-55e4-47ef-817c-62143c811262
is_ending_char(c) = c == '}' || c == ')' || c == '>' || c == ']'

# ╔═╡ 423d30d6-f130-4965-8fe5-eafad2ec80c8
function is_corresponding_ending_char(open, close)
	return ((open == '{' && close == '}')
		|| (open == '(' && close == ')')
		|| (open == '<' && close == '>')
		|| (open == '[' && close == ']'))
end

# ╔═╡ 1a7c8d03-a329-4dc3-83b9-321e8e3f73b9
function get_first_illegal_char(chars)
	s = Stack{Char}()
	for c in chars
		if is_starting_char(c)
			push!(s, c)
		elseif length(s) == 0
			return c
		else
			expected_starting_char = pop!(s)
			if !is_corresponding_ending_char(expected_starting_char, c)
				return c
			end
		end
	end
	return nothing
end

# ╔═╡ 88a32fb0-5975-11ec-2425-c56f3e1c018d
md"""
# Problem 1
"""

# ╔═╡ 043113a6-fbe2-4bac-9cc9-a2bd1e58b469
prob1_score_map = Dict(')' => 3, ']' => 57, '}' => 1197, '>' => 25137)

# ╔═╡ 918aada4-0b3b-4ad2-959d-6b32a1cebc4a
function get_illegal_chars(lines)
	return get_first_illegal_char.(lines) |> l -> filter(cs -> cs != nothing, l)
end

# ╔═╡ 8dc8cf89-3817-4920-94ef-9dacdd72e011
with_terminal() do
	open("./Day10/prob_input.txt") do io
		lines = parse_file(io)
		@time illegal_chars = get_illegal_chars(lines)
		map(c -> prob1_score_map[c], illegal_chars) |> sum
	end
end

# ╔═╡ 904ce7bf-1c8c-4f26-813d-92a506c2f08f
md"""
# Problem 2
"""

# ╔═╡ 520e4d32-4aea-4614-b6f8-e921ccff6e91
prob2_score_map = Dict(')' => 1, ']' => 2, '}' => 3, '>' => 4)

# ╔═╡ 0ecc2b6a-2523-4e79-8cce-7051baf36eb7
function get_closing_char(c)
	if c == '{'
		return '}'
	elseif c == '('
		return ')'
	elseif c == '<'
		return '>'
	elseif c == '['
		return ']'
	end

	error("Invalid char $(c)")
end

# ╔═╡ 770b7471-f521-4d5b-8e3f-2414f5c8aeed
function get_legal_lines(lines)
	illegal_lines = get_first_illegal_char.(lines)
	legal_lines_index = findall(c -> c == nothing, illegal_lines)
	lines[legal_lines_index]
end

# ╔═╡ 162d2a42-172b-4c76-a226-7fb3acf793a7
function get_closing_chars_for_legal_line(chars)
	s = Stack{Char}()
	for c in chars
		if is_starting_char(c)
			push!(s, c)
		else
			# As we will only get legal lines so making that assumption
			pop!(s)
		end
	end

	return [get_closing_char(c) for c in s]
end

# ╔═╡ 3b1bdf51-bb88-468b-9afc-f5d0c49c7d6c
function get_score_for_line(closing_chars)
	scores = map(c -> prob2_score_map[c], closing_chars)

	score = 0
	for s in scores
		score = (score * 5) + s
	end

	return score
end

# ╔═╡ 209a1d4f-8584-433f-91bb-3f30a5835d26
function get_median_score_for_completion(lines)
	closing_chars_per_line = get_closing_chars_for_legal_line.(lines)
	scores_per_line = get_score_for_line.(closing_chars_per_line)
	sort!(scores_per_line)

	mid_index = Int(floor(length(scores_per_line)/2)) + 1
	return scores_per_line[mid_index]
end


# ╔═╡ 292b86ae-4952-4f55-a0f2-aa217a7b392d
with_terminal() do
	open("./Day10/prob_input.txt") do io
		lines = parse_file(io)
		legal_lines = get_legal_lines(lines)
		@time get_median_score_for_completion(legal_lines)
	end
end

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
# ╠═f90ea9fd-d607-4e2d-8dc5-c3db88e79d8d
# ╠═33391766-ca23-48f8-a20e-e08134fc74da
# ╠═474eaa7d-f432-493b-afcb-661e0077f08a
# ╠═16efd634-55e4-47ef-817c-62143c811262
# ╠═423d30d6-f130-4965-8fe5-eafad2ec80c8
# ╠═1a7c8d03-a329-4dc3-83b9-321e8e3f73b9
# ╟─88a32fb0-5975-11ec-2425-c56f3e1c018d
# ╠═043113a6-fbe2-4bac-9cc9-a2bd1e58b469
# ╠═918aada4-0b3b-4ad2-959d-6b32a1cebc4a
# ╠═8dc8cf89-3817-4920-94ef-9dacdd72e011
# ╟─904ce7bf-1c8c-4f26-813d-92a506c2f08f
# ╠═520e4d32-4aea-4614-b6f8-e921ccff6e91
# ╠═0ecc2b6a-2523-4e79-8cce-7051baf36eb7
# ╠═770b7471-f521-4d5b-8e3f-2414f5c8aeed
# ╠═162d2a42-172b-4c76-a226-7fb3acf793a7
# ╠═3b1bdf51-bb88-468b-9afc-f5d0c49c7d6c
# ╠═209a1d4f-8584-433f-91bb-3f30a5835d26
# ╠═292b86ae-4952-4f55-a0f2-aa217a7b392d
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
