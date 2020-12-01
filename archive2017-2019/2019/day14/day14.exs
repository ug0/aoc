defmodule Day14 do
  def part1(str) do
    str
    |> parse_reactions()
    |> minimal_ore_for_fuel(1)
  end

  @large_fuel_amount 100_000_000
  @ore_amount 1_000_000_000_000
  def part2(str) do
    recipe = str |> parse_reactions()

    binary_search(1, @large_fuel_amount, fn fuel_amount ->
      case minimal_ore_for_fuel(recipe, fuel_amount) do
        @ore_amount -> :eq
        amount when amount > @ore_amount -> :gt
        _ -> :lt
      end
    end)
  end

  defp binary_search(min, max, _fun) when max - min <= 1 do
    min
  end

  defp binary_search(min, max, fun) do
    n = div(min + max, 2)

    case fun.(n) do
      :eq -> n
      :lt -> binary_search(n, max, fun)
      :gt -> binary_search(min, n, fun)
    end
  end

  defp minimal_ore_for_fuel(recipe, fuel_amount) do
    initial_materials_for_product(recipe, {%{"FUEL" => fuel_amount}, %{}})
    |> elem(0)
    |> Map.fetch!("ORE")
  end

  defp initial_materials_for_product(recipe, {materials, waste}) do
    case transform(recipe, {materials, waste}) do
      {^materials, ^waste} -> {materials, waste}
      {materials, waste} -> initial_materials_for_product(recipe, {materials, waste})
    end
  end

  defp transform(recipe, {materials, waste}) do
    {materials, waste} = reduce_waste(materials, waste)

    Enum.reduce(materials, {%{}, waste}, fn {chemical, qty}, {materials_acc, waste_acc} ->
      case materials_acc do
        %{^chemical => n} ->
          {%{materials_acc | chemical => n + qty}, waste_acc}

        _ ->
          {materials, waste} = materials_for_output(recipe, {chemical, qty})
          {merge_materials(materials_acc, materials), merge_materials(waste_acc, waste)}
      end
    end)
  end

  defp reduce_waste(materials, waste) do
    Enum.reduce(waste, {materials, waste}, fn {chemical, qty}, {materials_acc, waste_acc} ->
      case materials_acc do
        %{^chemical => n} when n >= qty ->
          {%{materials_acc | chemical => n - qty}, Map.delete(waste_acc, chemical)}

        %{^chemical => n} ->
          {Map.delete(materials_acc, chemical), %{waste_acc | chemical => qty - n}}

        _ ->
          {materials_acc, waste_acc}
      end
    end)
  end

  defp merge_materials(acc, materials) do
    Enum.reduce(materials, acc, fn {chemical, qty}, acc ->
      Map.update(acc, chemical, qty, &(&1 + qty))
    end)
  end

  defp materials_for_output(_recipe, {"ORE", qty}) do
    {[{"ORE", qty}], []}
  end

  defp materials_for_output(recipe, {chemical, qty}) do
    {{_, n}, input} = Enum.find(recipe, fn {{c, _}, _} -> c == chemical end)

    x = ceil(qty / n)

    case x * n do
      ^qty -> {Enum.into(input, %{}, fn {c, q} -> {c, q * x} end), %{}}
      total -> {Enum.into(input, %{}, fn {c, q} -> {c, q * x} end), %{chemical => total - qty}}
    end
  end

  defp parse_reactions(str) do
    str
    |> String.splitter("\n", trim: true)
    |> Enum.into(%{}, fn line ->
      [input, output] = String.split(line, " => ")

      {
        parse_materials(output),
        input |> String.splitter(", ") |> Enum.map(&parse_materials/1)
      }
    end)
  end

  defp parse_materials(str) do
    {qty, " " <> chemical} = Integer.parse(str)

    {chemical, qty}
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day14Test do
      use ExUnit.Case

      test "part1" do
        assert Day14.part1("""
               10 ORE => 10 A
               1 ORE => 1 B
               7 A, 1 B => 1 C
               7 A, 1 C => 1 D
               7 A, 1 D => 1 E
               7 A, 1 E => 1 FUEL
               """) == 31

        assert Day14.part1("""
               9 ORE => 2 A
               8 ORE => 3 B
               7 ORE => 5 C
               3 A, 4 B => 1 AB
               5 B, 7 C => 1 BC
               4 C, 1 A => 1 CA
               2 AB, 3 BC, 4 CA => 1 FUEL
               """) == 165

        assert Day14.part1("""
               157 ORE => 5 NZVS
               165 ORE => 6 DCFZ
               44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
               12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
               179 ORE => 7 PSHF
               177 ORE => 5 HKGWZ
               7 DCFZ, 7 PSHF => 2 XJWVT
               165 ORE => 2 GPVTF
               3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT
               """) == 13312

        assert Day14.part1("""
               2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG
               17 NVRVD, 3 JNWZP => 8 VPVL
               53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL
               22 VJHF, 37 MNCFX => 5 FWMGM
               139 ORE => 4 NVRVD
               144 ORE => 7 JNWZP
               5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC
               5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV
               145 ORE => 6 MNCFX
               1 NVRVD => 8 CXFTF
               1 VJHF, 6 MNCFX => 4 RFSQX
               176 ORE => 6 VJHF
               """) == 180_697

        assert Day14.part1("""
               171 ORE => 8 CNZTR
               7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL
               114 ORE => 4 BHXH
               14 VRPVC => 6 BMBT
               6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL
               6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT
               15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW
               13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW
               5 BMBT => 4 WPTQ
               189 ORE => 9 KTJDG
               1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP
               12 VRPVC, 27 CNZTR => 2 XDBXC
               15 KTJDG, 12 BHXH => 5 XCVML
               3 BHXH, 2 VRPVC => 7 MZWV
               121 ORE => 7 VRPVC
               7 XCVML => 6 RJRHP
               5 BHXH, 4 VRPVC => 5 LTCX
               """) == 2_210_736
      end

      test "part2" do
        assert Day14.part2("""
               157 ORE => 5 NZVS
               165 ORE => 6 DCFZ
               44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
               12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
               179 ORE => 7 PSHF
               177 ORE => 5 HKGWZ
               7 DCFZ, 7 PSHF => 2 XJWVT
               165 ORE => 2 GPVTF
               3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT
               """) == 82_892_753

        assert Day14.part2("""
               2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG
               17 NVRVD, 3 JNWZP => 8 VPVL
               53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL
               22 VJHF, 37 MNCFX => 5 FWMGM
               139 ORE => 4 NVRVD
               144 ORE => 7 JNWZP
               5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC
               5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV
               145 ORE => 6 MNCFX
               1 NVRVD => 8 CXFTF
               1 VJHF, 6 MNCFX => 4 RFSQX
               176 ORE => 6 VJHF
               """) == 5_586_022

        assert Day14.part2("""
               171 ORE => 8 CNZTR
               7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL
               114 ORE => 4 BHXH
               14 VRPVC => 6 BMBT
               6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL
               6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT
               15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW
               13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW
               5 BMBT => 4 WPTQ
               189 ORE => 9 KTJDG
               1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP
               12 VRPVC, 27 CNZTR => 2 XDBXC
               15 KTJDG, 12 BHXH => 5 XCVML
               3 BHXH, 2 VRPVC => 7 MZWV
               121 ORE => 7 VRPVC
               7 XCVML => 6 RJRHP
               5 BHXH, 4 VRPVC => 5 LTCX
               """) == 460_664
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day14.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day14.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
