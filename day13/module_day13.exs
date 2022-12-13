defmodule Day13 do
  def eval(line) do
    {code, _} = Code.eval_string(line)
    code
  end

  def consider(pair) do
    [left, right] = pair

    cond do
      is_list(left) && is_list(right) ->
        truthiness =
          Enum.find(
            Enum.zip_with([left, right], fn [l, r] -> Day13.consider([l, r]) end),
            0,
            fn ele -> ele != 0 end
          )

        if truthiness == 0 do
          cond do
            length(left) < length(right) ->
              1

            length(left) > length(right) ->
              -1

            true ->
              0
          end
        else
          truthiness
        end

      is_list(left) && !is_list(right) ->
        Day13.consider([left, [right]])

      !is_list(left) && is_list(right) ->
        Day13.consider([[left], right])

      !is_list(left) && !is_list(right) ->
        cond do
          left < right ->
            1

          left > right ->
            -1

          true ->
            0
        end

      true ->
        throw("error")
    end
  end

  def compare(left, right) do
    result = Day13.consider([left, right])

    cond do
      result == 1 -> :lt
      result == -1 -> :gt
      result == 0 -> :eq
    end
  end
end
