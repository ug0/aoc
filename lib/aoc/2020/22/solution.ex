defmodule Aoc.Y2020.D22 do
  use Aoc.Input

  defmodule Deck do
    def new(cards) do
      :queue.from_list(cards)
    end

    def draw_card(deck) do
      :queue.out(deck)
    end

    def insert_cards(deck, cards) do
      :queue.join(deck, new(cards))
    end

    def size(deck) do
      :queue.len(deck)
    end

    def slice(deck, n) do
      n |> :queue.split(deck) |> elem(0)
    end

    def score(deck) do
      deck
      |> :queue.reverse()
      |> :queue.to_list()
      |> Stream.with_index(1)
      |> Stream.map(fn {n, i} -> n * i end)
      |> Enum.sum()
    end
  end

  defmodule Combat do
    def winner({deck1, deck2}) do
      case {Deck.draw_card(deck1), Deck.draw_card(deck2)} do
        {{:empty, _}, _} ->
          deck2

        {_, {:empty, _}} ->
          deck1

        {{{:value, card1}, new_deck1}, {{:value, card2}, new_deck2}} ->
          {new_deck1, new_deck2}
          |> move_cards(card1, card2)
          |> winner()
      end
    end

    defp move_cards({deck1, deck2}, card1, card2) when card1 > card2 do
      {Deck.insert_cards(deck1, [card1, card2]), deck2}
    end

    defp move_cards({deck1, deck2}, card1, card2) do
      {deck1, Deck.insert_cards(deck2, [card2, card1])}
    end
  end

  defmodule RecursiveCombat do
    def winner(decks) do
      winner(decks, MapSet.new())
    end

    defp winner({deck1, _deck2} = decks, seen) do
      if MapSet.member?(seen, decks) do
        {deck1, nil}
      else
        round(decks, seen)
      end
    end

    defp round({deck1, deck2} = decks, seen) do
      case {Deck.draw_card(deck1), Deck.draw_card(deck2)} do
        {{:empty, _}, {_, _}} ->
          {nil, deck2}

        {{_, _}, {:empty, _}} ->
          {deck1, nil}

        {{{:value, card1}, new_deck1}, {{:value, card2}, new_deck2}} ->
          round_winner =
            if Deck.size(new_deck1) >= card1 and Deck.size(new_deck2) >= card2 do
              winner({Deck.slice(new_deck1, card1), Deck.slice(new_deck2, card2)})
            else
              card1 > card2
            end

          {new_deck1, new_deck2}
          |> move_cards(round_winner, card1, card2)
          |> winner(MapSet.put(seen, decks))
      end
    end

    defp move_cards({deck1, deck2}, true = _winner1, card1, card2) do
      {Deck.insert_cards(deck1, [card1, card2]), deck2}
    end

    defp move_cards({deck1, deck2}, false = _winner2, card1, card2) do
      {deck1, Deck.insert_cards(deck2, [card2, card1])}
    end

    defp move_cards({deck1, deck2}, {_winner1, nil}, card1, card2) do
      {Deck.insert_cards(deck1, [card1, card2]), deck2}
    end

    defp move_cards({deck1, deck2}, {nil, _winner2}, card1, card2) do
      {deck1, Deck.insert_cards(deck2, [card2, card1])}
    end
  end

  alias __MODULE__.{Deck, Combat, RecursiveCombat}

  def part1(str \\ nil) do
    (str || input())
    |> parse_input()
    |> Enum.map(&Deck.new/1)
    |> List.to_tuple()
    |> Combat.winner()
    |> score()
    |> IO.inspect()
  end

  def part2(str \\ nil) do
    (str || input())
    |> parse_input()
    |> Enum.map(&Deck.new/1)
    |> List.to_tuple()
    |> RecursiveCombat.winner()
    |> score()
    |> IO.inspect()
  end

  defp score({winner, nil}), do: Deck.score(winner)
  defp score({nil, winner}), do: Deck.score(winner)
  defp score(winner), do: Deck.score(winner)

  defp parse_input(str) do
    str
    |> String.splitter("\n\n", trim: true)
    |> Enum.map(fn "Player " <> <<_, ?:, ?\n, s::binary>> ->
      s |> String.splitter("\n", trim: true) |> Enum.map(&String.to_integer/1)
    end)
  end
end
