# Integrantes: Sharon Dahiana Ospina - Santiago Trujillo Cubides.

defmodule ComprobanteMensajeria do
  @meta_productividad 80
  @bonificacion_productividad 15_000

  # Solicita un código y muestra el comprobante si el repartidor existe.
  def solicitar_comprobante(servicios, liquidaciones, repartidores) do
    Util2.mostrar("\nIngrese el código del repartidor para generar su comprobante:", :mensaje)
    codigo = IO.gets("") |> texto_o_vacio() |> String.trim()

    case Enum.find(repartidores, &(&1.codigo == codigo)) do
      nil ->
        Util2.mostrar("El código no corresponde a ningún repartidor. El programa terminó normalmente.", :mensaje)

      repartidor ->
        liquidacion = Enum.find(liquidaciones, &(&1.codigo == codigo))
        imprimir_comprobante(repartidor, liquidacion, servicios)
    end
  end

  # Convierte el fin de entrada en texto vacío para poder continuar.
  defp texto_o_vacio(nil), do: ""

  # Convierte el fin de entrada en texto vacío para poder continuar.
  defp texto_o_vacio(texto), do: texto

  # Muestra el detalle diario y el neto del comprobante.
  def imprimir_comprobante(repartidor, liquidacion, servicios) do
    Util2.mostrar("\nCOMPROBANTE DE PAGO", :mensaje)
    Util2.mostrar("#{repartidor.nombre} - #{repartidor.codigo}", :mensaje)

    servicios_repartidor = Enum.filter(servicios, &(&1.repartidor == repartidor.codigo))
    dias = servicios_repartidor |> Enum.map(& &1.dia) |> Enum.uniq() |> Enum.sort()

    Enum.each(dias, fn dia ->
      servicios_dia = Enum.filter(servicios_repartidor, &(&1.dia == dia))
      kilometros = CalculosMensajeria.sumar_kilometros(servicios_dia)
      valor = Enum.map(servicios_dia, &LiquidacionMensajeria.valor_servicio/1) |> Enum.sum()
      bonificacion = if kilometros >= @meta_productividad, do: @bonificacion_productividad, else: 0

      Util2.mostrar(
        "Día #{dia}: #{numero(kilometros)} km | servicios: $#{numero(valor)} | bonificación: $#{numero(bonificacion)}",
        :mensaje
      )
    end)

    Util2.mostrar("Suma de servicios: $#{numero(liquidacion.valor_servicios)}", :mensaje)
    Util2.mostrar("Suma de bonificaciones: $#{numero(liquidacion.bonificaciones)}", :mensaje)
    Util2.mostrar("Alquiler de bicicleta: -$#{numero(liquidacion.alquiler)}", :mensaje)
    Util2.mostrar("Neto a pagar: $#{numero(liquidacion.neto)}", :mensaje)
  end

  # Formatea un número con dos decimales para mostrar dinero y distancias.
  # Formatea un número con dos decimales para mostrarlo en el reporte.
  defp numero(valor) do
    :erlang.float_to_binary(valor * 1.0, decimals: 2)
  end
end
