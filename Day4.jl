### A Pluto.jl notebook ###
# v0.17.2

using Markdown
using InteractiveUtils

# ╔═╡ a1ec9ca6-f727-41ba-a40b-90d02cadffcc
using PlutoUI

# ╔═╡ 12e140b2-3d6a-4cff-aaed-88acc4127688
function parse_board_line(nums)
	return getindex.(nums, [i:i+1 for i in 1:3:14]) .|> n -> parse(Int8, n)
end

# ╔═╡ 62491476-3bb5-4cb4-9e79-a583b245a8d3
function parse_file(lines; square_matrix_size = 5)
	choosen_numbers = split(lines[1], ",") .|> n -> parse(Int8, n)
	board_line_ranges = [i:i+4 for i in 3:6:length(lines)]

	function create_matrix(board_line_range)
		return (lines[board_line_range]
			.|> parse_board_line
			|> x -> hcat(x...)')
	end

	return (choosen_numbers, create_matrix.(board_line_ranges))
end
	

# ╔═╡ 7d1e46b6-54c7-11ec-368e-f75897fc5485
md"""
# Problem 1
"""

# ╔═╡ 9cb9f0a4-99eb-465a-881b-e1b35f312c83
function isbingo(board)
	rows, cols = size(board)
	for r in 1:rows
		if (all(board[r,:] .== -1))
			return true
		end
	end

	for c in 1:cols
		if (all(board[:, c] .== -1))
			return true
		end
	end

	return false
end
	

# ╔═╡ f6cc7b2f-f0b1-409f-9282-efb434e958fa
function simulate_bingo_games!(nums, boards)
	for num in nums
		(boards
			.|> b -> b[b .== num] .= -1)
		won_bingo = findall(isbingo, boards)

		if (length(won_bingo) >= 1)
			return num, boards[won_bingo][1]
		end
	end

end

# ╔═╡ 4572320a-de29-49ca-a642-10f422e2bb69
 open("./Day4/prob_input.txt") do io

	 with_terminal() do
		lines = [line for line in eachline(io)]
		nums, boards = parse_file(lines)
		@time num, winning_board = simulate_bingo_games!(nums, boards)
		winning_board[winning_board .== -1] .= 0
		num * sum(vcat(winning_board...))
	 end
end

# ╔═╡ 8f134a84-1388-4d15-9dc8-b51131459f38
md"""
# Problem 2
"""

# ╔═╡ bb3821de-7fa9-49aa-8e5e-eb106a7726d8
function simulate_bingo_games_to_end!(nums, boards)
	remaining_boards = length(boards)
	for num in nums
		(boards
			.|> b -> b[b .== num] .= -1)
		won_bingo = findall(isbingo, boards)
		remaining_boards -= length(won_bingo)

		updated_boards = filter(bi -> bi ∉ won_bingo, eachindex(boards))

		if (remaining_boards == 0)
			return num, boards[won_bingo][1]
		end

		boards = boards[updated_boards]
	end

end

# ╔═╡ c6372434-e3d6-47b7-b061-7094e5a87c93
 open("./Day4/prob_input.txt") do io

	 with_terminal() do
		lines = [line for line in eachline(io)]
		nums, boards = parse_file(lines)
		@time num, winning_board = simulate_bingo_games_to_end!(nums, boards)
		
		winning_board[winning_board .== -1] .= 0
		num * sum(vcat(winning_board...))
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
# ╠═a1ec9ca6-f727-41ba-a40b-90d02cadffcc
# ╟─12e140b2-3d6a-4cff-aaed-88acc4127688
# ╟─62491476-3bb5-4cb4-9e79-a583b245a8d3
# ╟─7d1e46b6-54c7-11ec-368e-f75897fc5485
# ╠═9cb9f0a4-99eb-465a-881b-e1b35f312c83
# ╠═f6cc7b2f-f0b1-409f-9282-efb434e958fa
# ╠═4572320a-de29-49ca-a642-10f422e2bb69
# ╟─8f134a84-1388-4d15-9dc8-b51131459f38
# ╠═bb3821de-7fa9-49aa-8e5e-eb106a7726d8
# ╠═c6372434-e3d6-47b7-b061-7094e5a87c93
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
