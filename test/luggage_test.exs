defmodule LuggageTest do
  use ExUnit.Case
  doctest Luggage

  test "adds an item" do
    luggage = %Luggage{max_weight: 1}
    toothbrush = %Luggage.Item{name: "Toothbrush", weight: 1}
    flower_pot = %Luggage.Item{name: "Flower pot", weight: 2}

    {:ok, luggage} = Luggage.put(luggage, toothbrush)
    [^toothbrush | []] = luggage.contents

    {:error, _} = Luggage.put(luggage, flower_pot)
    [^toothbrush | []] = luggage.contents

    luggage = %{luggage | max_weight: 3}
    {:ok, luggage} = Luggage.put(luggage, flower_pot)
    [^flower_pot, ^toothbrush | []] = luggage.contents
  end

  test "optimizes maximum items to put in luggage" do
    toothbrush = %Luggage.Item{name: "Toothbrush", weight: 1}
    flower_pot = %Luggage.Item{name: "Flower pot", weight: 2}
    paintbrush = %Luggage.Item{name: "Paintbrush", weight: 1}
    heavy_rock = %Luggage.Item{name: "Heavy Rock", weight: 6}
    sponge = %Luggage.Item{name: "Sponge", weight: 5}
    pencil = %Luggage.Item{name: "Pencil", weight: 1}

    luggage = %Luggage{max_weight: 10}
    items = [toothbrush, flower_pot, paintbrush, heavy_rock, sponge, pencil]

    {:ok, optimized} = Luggage.Optimizer.optimize(luggage, items)
    expected = [toothbrush, flower_pot, paintbrush, sponge, pencil]

    assert Enum.frequencies(optimized) == Enum.frequencies(expected)
  end
end
