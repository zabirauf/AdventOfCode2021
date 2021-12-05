### A Pluto.jl notebook ###
# v0.17.2

using Markdown
using InteractiveUtils

# ╔═╡ b3a0a793-4d54-415b-ab61-9f6f01c81d15
using PlutoUI

# ╔═╡ 536d9246-6163-49ec-9094-03e87230dd49
function parse_line(line)
	return (split(line, " -> ") 
			.|> x -> split(x, ",") 
			.|> n -> parse(Int16, n))
end

# ╔═╡ 6d7a2a45-cc0b-4270-9f24-907c4400c163
function points_in_between(p1, p2)
	x1, y1 = p1[1], p1[2]
	x2, y2 = p2[1], p2[2]

	if x1 == x2
		return y1 < y2 ? tuple.(x1, y1:y2) : tuple.(x1, y2:y1)
	elseif y1 == y2
		return x1 < x2 ? tuple.(x1:x2, y1) : tuple.(x2:x1, y1)
	else
		# Its a diagonal, solves #Problem 2
		xrange = x1:(x1 < x2 ? 1 : -1):x2
		yrange = y1:(y1 < y2 ? 1 : -1):y2
		return tuple.(xrange, yrange)
	end
end

# ╔═╡ 099f84bc-5587-11ec-3c0c-515a4b5ec3f8
md"""
# Problem 1
"""

# ╔═╡ a004d979-8888-4703-92f0-132c4a098537
function is_horizontal_or_vertical(locs)
	p1, p2 = locs[1], locs[2]

	return p1[1] == p2[1] || p1[2] == p2[2]
end

# ╔═╡ 9175ece1-88d6-4a82-b1cd-6581c2200ed8
function get_dangerous_areas(vents_locs; LW = 1000)
	vent_points = zeros(Int16, LW*LW)

	# Removed dict as it was taking upto 1.0M allocation and 30 MiB.
	# With array its taking only 2K allocation and 5.2 MiB
	# vent_points = Dict()

	function update_point_value!(p)
		key = p[2] * LW + p[1]
		vent_points[key] += 1
	end

	for locs in vents_locs
		(points_in_between(locs[1], locs[2])
		.|> update_point_value!)
	end

	return count(n -> n >= 2, values(vent_points))
end

# ╔═╡ 16eb2346-8fec-4476-b472-86a12752cddb
with_terminal() do
	open("./Day5/prob_input.txt") do io
		 vents_locs = [parse_line(line) for line in eachline(io)]
		 vents_locs = filter(is_horizontal_or_vertical, vents_locs)
		 @time get_dangerous_areas(vents_locs)
	end
end

# ╔═╡ c6f0dabb-c884-407f-ae11-f422fbd5ee8b
md"""
# Problem 2
"""

# ╔═╡ 99268d0a-c421-4ed0-8d9f-5f132e2feb8a
with_terminal() do
	open("./Day5/prob_input.txt") do io
		 vents_locs = [parse_line(line) for line in eachline(io)]
		 @time get_dangerous_areas(vents_locs)
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
# ╠═b3a0a793-4d54-415b-ab61-9f6f01c81d15
# ╠═536d9246-6163-49ec-9094-03e87230dd49
# ╠═6d7a2a45-cc0b-4270-9f24-907c4400c163
# ╟─099f84bc-5587-11ec-3c0c-515a4b5ec3f8
# ╠═a004d979-8888-4703-92f0-132c4a098537
# ╠═9175ece1-88d6-4a82-b1cd-6581c2200ed8
# ╠═16eb2346-8fec-4476-b472-86a12752cddb
# ╟─c6f0dabb-c884-407f-ae11-f422fbd5ee8b
# ╠═99268d0a-c421-4ed0-8d9f-5f132e2feb8a
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
