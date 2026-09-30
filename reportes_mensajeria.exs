# Integrantes: Sharon Dahiana Ospina - Santiago Trujillo Cubides.

defmodule ReportesMensajeria do
  @dias_operacion 1..6
  @meta_diaria 500

  # Muestra los servicios rechazados y las cantidades agrupadas por motivo.
  def reportar_rechazos(rechazados) do
    Util2.mostrar("\nR1. SERVICIOS RECHAZADOS", :mensaje)

    if rechazados == [] do
      Util2.mostrar("No hubo servicios rechazados.", :mensaje)
    else
      Enum.each(rechazados, fn rechazo ->
        Util2.mostrar("#{inspect(rechazo.servicio)} -> #{rechazo.motivo}", :mensaje)
      end)
    end

    motivos = [
      :repartidor_desconocido,
      :zona_desconocida,
      :dia_invalido,
      :kilometros_fuera_de_rango,
      :retraso_invalido
    ]

    Enum.each(motivos, fn motivo ->
      cantidad = Enum.count(rechazados, fn rechazo -> rechazo.motivo == motivo end)
      Util2.mostrar("#{motivo}: #{cantidad}", :mensaje)
    end)
  end

  # Muestra kilómetros y densidad de recorrido por zona.
  def reportar_zonas(servicios, zonas) do
    Util2.mostrar("\nR2. RECORRIDO POR ZONA", :mensaje)

    resumen =
      Enum.map(zonas, fn zona ->
        kilometros =
          servicios
          |> Enum.filter(fn servicio -> servicio.zona == zona.id end)
          |> Enum.map(fn servicio -> servicio.kilometros end)
          |> Enum.sum()

        %{zona: zona.nombre, kilometros: kilometros, densidad: kilometros / zona.area}
      end)

    resumen
    |> Util2.ordenar(:desc, & &1.densidad)
    |> Enum.each(fn fila ->
      Util2.mostrar(
        "#{fila.zona}: #{numero(fila.kilometros)} km; densidad #{numero(fila.densidad)} km/km²",
        :mensaje
      )
    end)
  end

  # Muestra el recorrido diario, el cumplimiento de la meta y la combinación aliada.
  def reportar_dias(servicios) do
    Util2.mostrar("\nR3. RECORRIDO DIARIO DE LA EMPRESA", :mensaje)
    kilometros_por_dia = CalculosMensajeria.mapa_kilometros_por_dia(servicios)

    Enum.each(@dias_operacion, fn dia ->
      kilometros = Map.get(kilometros_por_dia, dia, 0)
      estado = if kilometros >= @meta_diaria, do: "Sí alcanzó la meta", else: "No alcanzó la meta"
      Util2.mostrar("Día #{dia}: #{numero(kilometros)} km. #{estado} de #{@meta_diaria} km.", :mensaje)
    end)

    metas_alcanzadas =
      Enum.count(@dias_operacion, fn dia -> Map.get(kilometros_por_dia, dia, 0) >= @meta_diaria end)

    Util2.mostrar("¿Se alcanzó todos los días?: #{metas_alcanzadas == 6}", :mensaje)
    Util2.mostrar("¿Se alcanzó al menos un día?: #{metas_alcanzadas > 0}", :mensaje)

    empresa_aliada = %{1 => 580.5, 2 => 430, 3 => 510, 5 => 625, 7 => 180}
    combinado = CalculosMensajeria.combinar_kilometros(kilometros_por_dia, empresa_aliada)
    Util2.mostrar("Kilómetros combinados con la empresa aliada: #{inspect(combinado)}", :mensaje)
    Util2.mostrar("Map.merge/2 reemplazaría los valores repetidos; Map.merge/3 permite sumarlos.", :mensaje)
    Util2.mostrar("El día 7 se conserva porque solo aparece en el mapa de la empresa aliada.", :mensaje)
  end

  # Imprime las liquidaciones ordenadas por neto descendente.
  def reportar_liquidaciones(liquidaciones) do
    Util2.mostrar("\nR4. LIQUIDACIÓN SEMANAL", :mensaje)

    liquidaciones
    |> CalculosMensajeria.ranking(por: & &1.neto, sentido: :desc)
    |> Enum.with_index(1)
    |> Enum.each(fn {fila, posicion} ->
      Util2.mostrar(
        "#{posicion}. #{fila.nombre} (#{fila.codigo}) | km: #{numero(fila.kilometros)} | " <>
          "servicios: $#{numero(fila.valor_servicios)} | bonificaciones: $#{numero(fila.bonificaciones)} | " <>
          "alquiler: $#{numero(fila.alquiler)} | neto: $#{numero(fila.neto)}",
        :mensaje
      )
    end)
  end

  # Muestra todos los repartidores empatados en primer lugar por día.
  def reportar_ganadores_diarios(servicios, repartidores) do
    Util2.mostrar("\nR5. MAYOR DISTANCIA POR DÍA", :mensaje)

    ganadores_por_dia =
      Enum.map(@dias_operacion, fn dia ->
        resumen =
          Enum.map(repartidores, fn repartidor ->
            kilometros =
              servicios
              |> Enum.filter(&(&1.repartidor == repartidor.codigo and &1.dia == dia))
              |> CalculosMensajeria.sumar_kilometros()

            %{codigo: repartidor.codigo, nombre: repartidor.nombre, kilometros: kilometros}
          end)

        primero = resumen |> CalculosMensajeria.ranking(por: & &1.kilometros, sentido: :desc, limite: 1) |> hd()
        ganadores = Enum.filter(resumen, &(&1.kilometros == primero.kilometros))
        Util2.mostrar("Día #{dia}: #{formatear_ganadores(ganadores)} con #{numero(primero.kilometros)} km", :mensaje)
        {dia, ganadores}
      end)

    apariciones =
      Enum.flat_map(ganadores_por_dia, fn {_dia, ganadores} -> Enum.map(ganadores, & &1.codigo) end)

    frecuencias = Enum.frequencies(apariciones)

    if map_size(frecuencias) == 0 do
      Util2.mostrar("No hubo ganadores para contar.", :mensaje)
    else
      mayor_cantidad = frecuencias |> Map.values() |> Enum.max()

      mejores =
        Enum.filter(frecuencias, fn {_codigo, cantidad} -> cantidad == mayor_cantidad end)
        |> Enum.map(fn {codigo, _cantidad} -> codigo end)

      nombres = Enum.filter(repartidores, &(&1.codigo in mejores))
      Util2.mostrar(
        "Más primeros lugares (#{mayor_cantidad}): " <>
          Enum.map_join(nombres, ", ", &"#{&1.nombre} (#{&1.codigo})"),
        :mensaje
      )
    end
  end

  # Busca el menor retraso promedio ponderado entre quienes tienen tres servicios.
  def reportar_puntualidad(servicios, repartidores) do
    Util2.mostrar("\nR6. MEJOR PUNTUALIDAD PONDERADA", :mensaje)

    candidatos =
      Enum.map(repartidores, fn repartidor ->
        servicios_repartidor = Enum.filter(servicios, &(&1.repartidor == repartidor.codigo))
        distancia = CalculosMensajeria.sumar_kilometros(servicios_repartidor)

        retraso_ponderado =
          if distancia == 0 do
            nil
          else
            suma_ponderada =
              servicios_repartidor
              |> Enum.map(fn servicio -> servicio.retraso * servicio.kilometros end)
              |> Enum.sum()

            suma_ponderada / distancia
          end

        %{
          codigo: repartidor.codigo,
          nombre: repartidor.nombre,
          cantidad_servicios: length(servicios_repartidor),
          retraso_ponderado: retraso_ponderado
        }
      end)
      |> Enum.filter(&(&1.cantidad_servicios >= 3))

    case candidatos do
      [] ->
        Util2.mostrar("No hay repartidores con al menos tres servicios válidos.", :mensaje)

      _ ->
        mejor = Enum.min_by(candidatos, & &1.retraso_ponderado)

        Util2.mostrar(
          "#{mejor.nombre} (#{mejor.codigo}), retraso ponderado: #{numero(mejor.retraso_ponderado)} minutos.",
          :mensaje
        )
    end
  end

  # Muestra el total pagado y el promedio pagado por kilómetro.
  def reportar_totales(liquidaciones, servicios) do
    Util2.mostrar("\nR7. TOTALES DE LA SEMANA", :mensaje)
    total_pagado = Enum.map(liquidaciones, & &1.neto) |> Enum.sum()
    total_kilometros = CalculosMensajeria.sumar_kilometros(servicios)
    promedio = if total_kilometros == 0, do: 0, else: total_pagado / total_kilometros
    Util2.mostrar("Total pagado: $#{numero(total_pagado)}", :mensaje)
    Util2.mostrar("Costo promedio pagado por kilómetro: $#{numero(promedio)}", :mensaje)
  end

  # Lista quienes tienen al menos un servicio válido en todas las zonas.
  def reportar_cobertura(servicios, repartidores, zonas) do
    Util2.mostrar("\nR8. REPARTIDORES CON SERVICIOS EN TODAS LAS ZONAS", :mensaje)

    cobertura =
      Enum.filter(repartidores, fn repartidor ->
        Enum.all?(zonas, fn zona ->
          Enum.any?(servicios, fn servicio ->
            servicio.repartidor == repartidor.codigo and servicio.zona == zona.id
          end)
        end)
      end)

    if cobertura == [] do
      Util2.mostrar("Ningún repartidor cubrió todas las zonas.", :mensaje)
    else
      Enum.each(cobertura, fn repartidor ->
        Util2.mostrar("#{repartidor.nombre} (#{repartidor.codigo})", :mensaje)
      end)
    end
  end

  # Formatea un número con dos decimales para mostrarlo en el reporte.
  defp numero(valor) do
    :erlang.float_to_binary(valor * 1.0, decimals: 2)
  end

  # Une los nombres y códigos de las personas empatadas.
  defp formatear_ganadores(ganadores) do
    Enum.map_join(ganadores, ", ", &"#{&1.nombre} (#{&1.codigo})")
  end
end
