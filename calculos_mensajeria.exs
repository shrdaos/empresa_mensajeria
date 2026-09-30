# Integrantes: Sharon Dahiana Ospina - Santiago Trujillo Cubides.

defmodule CalculosMensajeria do
  @dias_operacion 1..6

  # Devuelve los kilómetros locales acumulados para cada día.
  def mapa_kilometros_por_dia(servicios) do
    Map.new(@dias_operacion, fn dia -> {dia, sumar_kilometros(Enum.filter(servicios, &(&1.dia == dia)))} end)
  end

  # Combina los kilómetros de dos empresas sumando los días coincidentes.
  def combinar_kilometros(kilometros_locales, kilometros_aliados) do
    Map.merge(kilometros_locales, kilometros_aliados, fn _dia, local, aliado -> local + aliado end)
  end

  # Suma las distancias de una lista de servicios.
  def sumar_kilometros(servicios) do
    servicios |> Enum.map(& &1.kilometros) |> Enum.sum()
  end

  # Ordena una lista según las opciones recibidas en una keyword list.
  def ranking(elementos, opciones) do
    campo = Keyword.get(opciones, :por, & &1)
    sentido = Keyword.get(opciones, :sentido, :desc)
    limite = Keyword.get(opciones, :limite, length(elementos))

    elementos
    |> Util2.ordenar(sentido, campo)
    |> Enum.take(limite)
  end
end
