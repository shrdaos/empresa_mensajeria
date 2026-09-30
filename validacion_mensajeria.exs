# Integrantes: Sharon Dahiana Ospina - Santiago Trujillo Cubides.

defmodule ValidacionMensajeria do
  @dias_operacion 1..6
  @maximo_kilometros_servicio 45

  # Revisa una lista completa y la separa en servicios aceptados y rechazados.
  def validar_lista(servicios, repartidores, zonas) do
    resultados =
      Enum.map(servicios, fn servicio ->
        {servicio, validar_servicio(servicio, repartidores, zonas)}
      end)

    validos =
      for {_servicio, {:ok, servicio_validado}} <- resultados,
          do: servicio_validado

    rechazados =
      for {servicio, {:error, motivo}} <- resultados,
          do: %{servicio: servicio, motivo: motivo}

    {validos, rechazados}
  end

  # Aplica las cinco reglas de validación en el orden establecido.
  def validar_servicio(servicio, repartidores, zonas) do
    with :ok <- validar_repartidor(servicio, repartidores),
         :ok <- validar_zona(servicio, zonas),
         :ok <- validar_dia(servicio),
         :ok <- validar_kilometros(servicio),
         :ok <- validar_retraso(servicio) do
      {:ok, servicio}
    end
  end

  # Comprueba que el repartidor del servicio exista.
  defp validar_repartidor(servicio, repartidores) do
    existe = Enum.any?(repartidores, fn repartidor -> repartidor.codigo == servicio.repartidor end)
    if existe, do: :ok, else: {:error, :repartidor_desconocido}
  end

  # Comprueba que la zona del servicio exista.
  defp validar_zona(servicio, zonas) do
    existe = Enum.any?(zonas, fn zona -> zona.id == servicio.zona end)
    if existe, do: :ok, else: {:error, :zona_desconocida}
  end

  # Verifica que el día sea un entero entre 1 y 6.
  defp validar_dia(servicio) do
    dia = Map.get(servicio, :dia)
    if is_integer(dia) and dia in @dias_operacion, do: :ok, else: {:error, :dia_invalido}
  end

  # Comprueba que la distancia sea mayor que cero y no supere 45 km.
  defp validar_kilometros(servicio) do
    kilometros = Map.get(servicio, :kilometros)

    if is_number(kilometros) and kilometros > 0 and
         kilometros <= @maximo_kilometros_servicio do
      :ok
    else
      {:error, :kilometros_fuera_de_rango}
    end
  end

  # Verifica que el retraso esté entre -30 y 180 minutos.
  defp validar_retraso(servicio) do
    retraso = Map.get(servicio, :retraso)

    if is_number(retraso) and retraso >= -30 and retraso <= 180 do
      :ok
    else
      {:error, :retraso_invalido}
    end
  end

  # Solicita una vez el servicio opcional y lo agrega si su formato y reglas son válidos.
  def ingresar_servicio(servicios_validos, rechazados, repartidores, zonas) do
    Util2.mostrar(
      "\nIngrese un servicio adicional (repartidor;zona;dia;kilometros;retraso)\no Enter para omitir:",
      :mensaje
    )

    entrada = IO.gets("")

    case entrada do
      nil ->
        Util2.mostrar("No se ingresó un servicio (fin de la entrada).", :mensaje)
        {servicios_validos, rechazados}

      texto ->
        texto = String.trim(texto)

        if texto == "" do
          Util2.mostrar("No se ingresó un servicio.", :mensaje)
          {servicios_validos, rechazados}
        else
          case convertir_entrada(texto) do
            {:error, :formato_invalido} ->
              Util2.mostrar("Servicio rechazado: formato inválido.", :mensaje)
              {servicios_validos, rechazados}

            {:ok, servicio} ->
              case validar_servicio(servicio, repartidores, zonas) do
                {:ok, servicio_validado} ->
                  Util2.mostrar("Servicio agregado correctamente.", :mensaje)
                  {servicios_validos ++ [servicio_validado], rechazados}

                {:error, motivo} ->
                  Util2.mostrar("Servicio rechazado por la regla: #{motivo}.", :mensaje)
                  nuevo_rechazo = %{servicio: servicio, motivo: motivo}
                  {servicios_validos, rechazados ++ [nuevo_rechazo]}
              end
          end
        end
    end
  end

  # Convierte los cinco campos escritos por el usuario en un mapa de servicio.
  def convertir_entrada(texto) do
    case String.split(texto, ";") do
      [repartidor, zona, dia_texto, kilometros_texto, retraso_texto] ->
        with {:ok, dia} <- convertir_entero(dia_texto),
             {:ok, kilometros} <- convertir_numero(kilometros_texto),
             {:ok, retraso} <- convertir_numero(retraso_texto) do
          {:ok,
           %{
             repartidor: String.trim(repartidor),
             zona: String.trim(zona),
             dia: dia,
             kilometros: kilometros,
             retraso: retraso
           }}
        else
          _ -> {:error, :formato_invalido}
        end

      _ ->
        {:error, :formato_invalido}
    end
  end

  # Convierte el texto a entero y devuelve un error si no es válido.
  defp convertir_entero(texto) do
    case Integer.parse(String.trim(texto)) do
      {numero, ""} -> {:ok, numero}
      _ -> {:error, :formato_invalido}
    end
  end

  # Convierte el texto a entero o decimal sin usar excepciones.
  defp convertir_numero(texto) do
    texto = String.trim(texto)

    case Integer.parse(texto) do
      {numero, ""} ->
        {:ok, numero}

      _ ->
        case Float.parse(texto) do
          {numero, ""} -> {:ok, numero}
          _ -> {:error, :formato_invalido}
        end
    end
  end
end
