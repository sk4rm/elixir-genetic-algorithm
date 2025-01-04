defmodule Luggage do
  defstruct max_weight: 0, contents: []

  defmodule Item do
    defstruct name: "", weight: 0
  end

  defmodule Optimizer do
    defmodule Gene do
      defstruct [:item, activated: false]

      def print([%Gene{} | _] = genes) do
        Enum.reduce(genes, "", fn gene, acc ->
          acc <>
            if gene.activated do
              "1"
            else
              "0"
            end
        end)
        |> IO.puts()
      end
    end

    def optimize([]), do: []

    def optimize(%Luggage{} = luggage, [%Item{} | _] = items) do
      # Initialize
      pool = Enum.map(1..100, fn _ -> init(items) end)

      # Natural selection process (100 generations)
      pool =
        Enum.reduce(1..10, pool, fn _, acc ->
          # Mutate (clone previous pool, mutate it, then append)
          result =
            (Enum.map(acc, &mutate(&1)) ++ acc)

            # Rank by fitness
            |> Enum.sort_by(fn genes -> fitness(genes, luggage.max_weight) end, :desc)

            # Purge lesser half
            |> Enum.with_index()
            |> Enum.filter(fn {_, i} -> i < length(pool) end)
            |> Enum.map(fn {genes, _} -> genes end)

          # Visualizing the evolution
          result
          |> Enum.at(0)
          |> Gene.print()

          result
        end)

      best =
        pool
        |> Enum.at(0)
        |> Enum.filter(fn genes -> genes.activated end)
        |> Enum.map(fn genes -> genes.item end)

      # Ideal result:
      # [
      #   %Gene{item: %Luggage.Item{name: "Flower pot", weight: 2}, activated: true},
      #   %Gene{item: %Luggage.Item{name: "Paintbrush", weight: 1}, activated: true},
      #   %Gene{item: %Luggage.Item{name: "Pencil", weight: 1}, activated: true},
      #   %Gene{item: %Luggage.Item{name: "Sponge", weight: 5}, activated: true},
      #   %Gene{item: %Luggage.Item{name: "Toothbrush", weight: 1}, activated: true}
      # ]
      # |> fitness(luggage.max_weight)
      # |> IO.inspect()

      {:ok, best}
    end

    defp init([%Item{} | _] = items) do
      genes =
        items
        |> Enum.reverse()
        |> Enum.reduce([], fn %Item{} = item, acc ->
          [%Gene{item: item, activated: false} | acc]
        end)

      genes
    end

    defp mutate([%Gene{} | _] = genes) do
      index_to_mutate = :rand.uniform(length(genes))

      genes
      |> Enum.with_index()
      |> Enum.map(fn {%Gene{} = gene, i} ->
        if i == index_to_mutate do
          %Gene{gene | activated: !gene.activated}
        else
          gene
        end
      end)
    end

    defp fitness([%Gene{} | _] = genes, max_weight) do
      activated = Enum.filter(genes, fn gene -> gene.activated end)

      weight =
        Enum.reduce(activated, 0, fn %Gene{} = gene, acc ->
          acc + gene.item.weight
        end)

      if weight <= max_weight do
        weight * length(activated)
      else
        0
      end
    end
  end

  def weigh(%Luggage{contents: contents}) do
    Enum.reduce(contents, 0, fn %Item{weight: weight}, acc -> acc + weight end)
  end

  def put(%Luggage{} = luggage, %Item{} = item) do
    if luggage |> can_fit(item) do
      {:ok, %Luggage{luggage | contents: [item | luggage.contents]}}
    else
      {:error, :overweight}
    end
  end

  def can_fit(%Luggage{max_weight: max_weight} = luggage, %Item{weight: weight}) do
    weigh(luggage) + weight <= max_weight
  end
end
