# Integrantes: Sharon Dahiana Ospina - Santiago Trujillo Cubides.

defmodule LiquidacionMensajeria do
  @tarifa_kilometro 2_500
  @meta_productividad 80
  @bonificacion_productividad 15_000
  @alquiler_bicicleta 10_000

  # Calcula servicios, bonos, alquiler y neto de cada repartidor.
  def calcular_liquidaciones(servicios, repartidores) do
    Enum.map(repartidores, fn repartidor ->
      servicios_repartidor = Enum.filter(servicios, &(&1.repartidor == repartidor.codigo))

      kilometros = CalculosMensajeria.sumar_kilometros(servicios_repartidor)

      valor_servicios =
        servicios_repartidor
        |> Enum.map(&valor_servicio(&1))
        |> Enum.sum()

      dias_trabajados = servicios_repartidor |> Enum.map(& &1.dia) |> Enum.uniq()

      bonificaciones =
        Enum.count(dias_trabajados, fn dia ->
          kilometros_dia(servicios_repartidor, dia) >= @meta_productividad
        end) * @bonificacion_productividad

      alquiler = if repartidor.bicicleta, do: length(dias_trabajados) * @alquiler_bicicleta, else: 0
      neto = valor_servicios + bonificaciones - alquiler

      %{
        codigo: repartidor.codigo,
        nombre: repartidor.nombre,
        bicicleta: repartidor.bicicleta,
        kilometros: kilometros,
        valor_servicios: valor_servicios,
        bonificaciones: bonificaciones,
        alquiler: alquiler,
        neto: neto
      }
    end)
  end

  # Calcula el pago de un servicio con el ajuste correspondiente a su retraso.
  def valor_servicio(servicio) do
    valor_inicial = servicio.kilometros * @tarifa_kilometro

    cond do
      servicio.retraso <= 0 -> valor_inicial * 1.08
      servicio.retraso <= 10 -> valor_inicial
      servicio.retraso <= 30 -> valor_inicial * 0.90
      true -> valor_inicial * 0.75
    end
  end

  # Suma los kilómetros de una persona en un día para revisar la bonificación.
  defp kilometros_dia(servicios, dia) do
    servicios
    |> Enum.filter(&(&1.dia == dia))
    |> CalculosMensajeria.sumar_kilometros()
  end
end
