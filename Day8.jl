### A Pluto.jl notebook ###
# v0.17.3

using Markdown
using InteractiveUtils

# ╔═╡ 1a5cbd7e-0e66-477b-84df-8745516e1e60
using PlutoUI

# ╔═╡ 9b66ea18-e2cc-42df-b712-0d6af393e535
function sort_str(str)
	return str |> collect |> sort |> join
end	

# ╔═╡ 0055a315-0e4d-41d1-b34b-0f28b523e66e
function parse_line(line::String)
	signal_raw, output_raw = split(line, " | ")
	return (signal=sort_str.(split(signal_raw)), output=sort_str.(split(output_raw)))
end

# ╔═╡ 42ed89bb-e71c-41a7-9863-fdcb43741db2
function parse_file(io::IO)
	return [parse_line(line) for line in eachline(io)]
end

# ╔═╡ 278c7342-57e7-11ec-3fe4-b32b60f8783f
md"""
# Problem 1
"""

# ╔═╡ bbfe83ec-59b1-471a-a783-0179d7b0dcfa
function count_easy_digits(data)
	# 1 => 2, 4 => 4, 7 => 3, 8 => 7
	unique_lengths = [2, 3, 4, 7]

	outputs = cat(getindex.(data, 2)..., dims=1)
	output_lengths = length.(outputs)
	return count(l -> l in unique_lengths, output_lengths)
end

# ╔═╡ 69a8670b-1a66-45ef-ae93-332828ef6e48
with_terminal() do
	open("./Day8/prob_input.txt") do io
		data = parse_file(io)
		@time count_easy_digits(data)
	end
end

# ╔═╡ 12828f42-a7bd-4941-875f-698c7df8b1f2
md"""
# Problem 2
"""

# ╔═╡ 5a699caa-f84e-484c-b9f8-20a6c8bbf7ff
md"""
As the signals part of the input will allways go over each digit 0..9 which means we can gradually figure out which characters correspond to which numbers. Given the following as default

```
 aaaa
b    c
b    c
 dddd
e    f
e    f
 gggg
```

Now lets saw when we see `length(signal) == 2` then we know its $1$ and when its `length(signal) == 3` then its $7$. So we can figure out $a$ e.g.

```
ab: 1
dab: 7
```

So we know $d = a$. With the following signal input

```
acedgfb: 8
cdfbe: 5
gcdfa: 2
fbcad: 3
dab: 7
cefabd: 9
cdfgeb: 6
eafb: 4
cagedb: 0
ab: 1
```

So now if we sort $4$ then it will be `aefb` and then check among signals if `length.(signal) == 5` that the delta between $4$ and them should be only $1$.

In above example if we see the we get (lets sort for easy interpretation)

```
bcdef: 5
abcdf: 3

-----

abef: 4
```

As we know representation of $1 = ab$ so among $3$ and $5$ we can figure out which is which and by process of skipping $2$ we know that as well. So by now we have figured out $1,2,3,4,5,7,8$.

Now to distinguish between $0,6,9$ lets find a signal that does not have a $5$ signal in it. 

```
abcdef: 9
bcdefg: 6
abcdeg: 0

-----
bcdef: 5
```

So now we can see that $0 = abcdeg$. Now among those find all the ones which has chars of $4$ and that number will be $9$ and other will be $6$.

```
abcdef: 9
bcdefg: 6

----

abef: 4
```

We have figured out all the numbers.
"""

# ╔═╡ 92692fbc-e9e4-47ec-bf1b-d8102669d0ed
function get_delta_count(l, r)
	return length(r) - sum([c ∈ l for c in r])
end

# ╔═╡ ac7f2d99-c1f5-49fe-a742-f68f4a91143b
function find_signal_and_output(data)
	(signal, output) = data
	length_to_signal = let 
		signal_length = length.(signal)
		d = Dict()
		for (index, l) in enumerate(signal_length)
			val = get(d, l, [])
			push!(val, (index, signal[index]))
			d[l] = val
		end

		d
	end

	num1 = length_to_signal[2][1][2]
	num4 = length_to_signal[4][1][2]
	num_map = Dict(
		num1 => "1", 
		num4 => "4",
		length_to_signal[3][1][2] => "7",
		length_to_signal[7][1][2] => "8")

	# Find amoung 2,3,5
	signal_of_length_5 = getindex.(length_to_signal[5],2)
	sl5_delta_num4 = get_delta_count.(signal_of_length_5, num4)

	num2 = signal_of_length_5[findall(l -> l == 2, sl5_delta_num4)[1]]
	num_map[num2] = "2"

	num_3_or_5 = signal_of_length_5[findall(l -> l == 1, sl5_delta_num4)]
	sl3or5_delta_num1 = get_delta_count.(num_3_or_5, num1)

	num5_index = findall(l -> l == 1, sl3or5_delta_num1)[1]
	num3_index = num5_index == 1 ? 2 : 1
	num3 = num_3_or_5[num3_index]
	num5 = num_3_or_5[num5_index]
	num_map[num3] = "3"
	num_map[num5] = "5"

	# Find among 0,6,9
	signal_of_length_6 = getindex.(length_to_signal[6],2)
	sl6_delta_num5 = get_delta_count.(signal_of_length_6, num5)
	num0 = signal_of_length_6[findall(l -> l == 1, sl6_delta_num5)[1]]
	num_map[num0] = "0"

	num_6_or_9 = signal_of_length_6[findall(l -> l == 0, sl6_delta_num5)]
	sl6or9_delta_num4 = get_delta_count.(num_6_or_9, num4)
	#return sl6or9_delta_num4, num_6_or_9, sl6_delta_num5, num5, signal_of_length_6
	
	num9_index = findall(l -> l == 0, sl6or9_delta_num4)[1]
	num6_index = num9_index == 1 ? 2 : 1
	num_map[num_6_or_9[num9_index]] = "9"
	num_map[num_6_or_9[num6_index]] = "6"

	return [num_map[o] for o in output] |> join |> s -> parse(Int64, s)
end

# ╔═╡ 96c27f04-4362-4130-b329-921bdb09865f
with_terminal() do
	open("./Day8/prob_input.txt") do io
		data = parse_file(io)
		@time sum(find_signal_and_output.(data))
	end
end

# ╔═╡ 957e2f3e-13f7-427a-82dd-043d95f89b28
md"""
After working on the above solution, I realized that it was very cumbersome. Though it works but its super complicated and does it by hand, at least the part of figuring out patterns for all numbers. I'm pretty sure there is more easier approach so I would have instead explored finding the position of each of $a,b,c,d,e,f,g$ and then based on that figured out the number. I think that might have resulted in a simpler approach.
"""

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
# ╠═1a5cbd7e-0e66-477b-84df-8745516e1e60
# ╠═9b66ea18-e2cc-42df-b712-0d6af393e535
# ╠═0055a315-0e4d-41d1-b34b-0f28b523e66e
# ╠═42ed89bb-e71c-41a7-9863-fdcb43741db2
# ╟─278c7342-57e7-11ec-3fe4-b32b60f8783f
# ╠═bbfe83ec-59b1-471a-a783-0179d7b0dcfa
# ╠═69a8670b-1a66-45ef-ae93-332828ef6e48
# ╟─12828f42-a7bd-4941-875f-698c7df8b1f2
# ╟─5a699caa-f84e-484c-b9f8-20a6c8bbf7ff
# ╠═92692fbc-e9e4-47ec-bf1b-d8102669d0ed
# ╠═ac7f2d99-c1f5-49fe-a742-f68f4a91143b
# ╠═96c27f04-4362-4130-b329-921bdb09865f
# ╟─957e2f3e-13f7-427a-82dd-043d95f89b28
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
