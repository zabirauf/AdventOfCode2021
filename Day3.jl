### A Pluto.jl notebook ###
# v0.17.2

using Markdown
using InteractiveUtils

# ╔═╡ ca4cae83-57ff-47a1-83df-b5db7b3342ff
using PlutoUI

# ╔═╡ 1b10d8d0-53f3-11ec-1644-2d224b0bf81b
md"""
# Problem 1
"""

# ╔═╡ ef81936e-6db7-4b90-b410-0d9bcccdfa11
function parse_submarine_telemetry(io::IO)
	bitCount = zeros(Int, 12)
	length = 0
	for line in eachline(io)
		parsed_bits = collect.(line) |> x -> parse.(Int8, x)
		bitCount .+= parsed_bits
		length += 1
	end

	gamma = (map(x -> x > (length-x) ? 1 : 0, bitCount)
				|> join
				|> b -> parse(Int, b, base=2))

	epsilon = (map(x -> x > (length-x) ? 0 : 1, bitCount) 
				|> join
				|> b -> parse(Int, b, base=2))

	return (gamma, epsilon)
end

# ╔═╡ 89c3ff6c-ce98-43a9-9cd9-da116ed6c281
 open("./Day3/prob_1_input.txt") do io

	 with_terminal() do
		@time (gamma, epsilon) = parse_submarine_telemetry(io)
		gamma*epsilon
	end
end

# ╔═╡ 0e2de1cb-ffd4-4432-8f0b-9db8d8ca31c0
md"""
# Problem 2
"""

# ╔═╡ e7df0cc8-afaa-4604-9dab-28712cd888fa
function isone(x) x == 1 end

# ╔═╡ 9c7eba44-5804-4486-987c-0a51506dc52d
function parse_submarine_vitals(bin_arr::Vector{Vector{Int8}})
	length_binaries = length(bin_arr)
	BITS = length(bin_arr[1])
	
	onesIndex = [[] for _ in 1:BITS]
	get_ones_indexes = x -> findall(isone, x)
	
	for (index, bits) in enumerate(bin_arr)
		push!.(onesIndex[get_ones_indexes(bits)], index)
	end

	oxygen = 1:length_binaries
	co2 = 1:length_binaries
	
	for index in 1:BITS
		in_ones_index(val) = val ∈ onesIndex[index]
		in_zeros_index(val) = val ∉ onesIndex[index]
		
		if (length(oxygen) > 1)
			oxygenBitCountOnes = filter(in_ones_index, oxygen) |> length
			oxygenBitCountZeros = length(oxygen) - oxygenBitCountOnes
			oxygen = filter(
				oxygenBitCountOnes >= oxygenBitCountZeros
				? in_ones_index
				: in_zeros_index, 
				oxygen)
		end

		if (length(co2) > 1)
			co2BitCountOnes = filter(in_ones_index, co2) |> length
			co2BitCountZeros = length(co2) - co2BitCountOnes
			co2 = filter(
				co2BitCountZeros <= co2BitCountOnes
				? in_zeros_index
				: in_ones_index, 
				co2)
		end
	end
		
	join_and_parse_bin(barr) = join(barr) |> b -> parse(Int, b, base=2)
	join_and_parse_bin(bin_arr[oxygen[1]]), join_and_parse_bin(bin_arr[co2[1]])
end
	

# ╔═╡ 78617f4c-067f-4b5a-b34c-e565aad1c19d
open("./Day3/prob_1_input.txt") do io
	with_terminal() do
		@time bin_arr = [collect.(line) |> x-> parse.(Int8, x) for line in eachline(io)]

		@time (oxygen, co2) = parse_submarine_vitals(bin_arr)
		oxygen * co2
	end
	
end

# ╔═╡ f44c2613-4423-4ece-8a55-4cc37797b674
5410338

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
# ╠═ca4cae83-57ff-47a1-83df-b5db7b3342ff
# ╟─1b10d8d0-53f3-11ec-1644-2d224b0bf81b
# ╠═ef81936e-6db7-4b90-b410-0d9bcccdfa11
# ╠═89c3ff6c-ce98-43a9-9cd9-da116ed6c281
# ╟─0e2de1cb-ffd4-4432-8f0b-9db8d8ca31c0
# ╠═e7df0cc8-afaa-4604-9dab-28712cd888fa
# ╠═9c7eba44-5804-4486-987c-0a51506dc52d
# ╠═78617f4c-067f-4b5a-b34c-e565aad1c19d
# ╠═f44c2613-4423-4ece-8a55-4cc37797b674
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
