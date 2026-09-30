# Integrantes: Sharon Dahiana Ospina - Santiago Trujillo Cubides.
defmodule Util2 do
  # Imprime un mensaje normal en la salida estándar.
  def mostrar(mensaje, :mensaje), do: IO.puts(mensaje)

  # Imprime un mensaje en la salida estándar de errores.
  def mostrar(mensaje, :error), do: IO.puts(:standard_error, mensaje)

  # Ordena una colección por el valor que devuelve la función obtener_campo.
  def ordenar(coleccion, sentido \\ :asc, obtener_campo \\ & &1) do
    Enum.sort_by(coleccion, obtener_campo, sentido)
  end

  # Devuelve los textos que empiezan por el prefijo indicado.
  def aplicar_filtro_inicial(coleccion, inicial) do
    Enum.filter(coleccion, &String.starts_with?(&1, inicial))
  end

  # Devuelve los textos que no superan la longitud indicada.
  def aplicar_filtro_longitud(coleccion, longitud) do
    Enum.filter(coleccion, &(String.length(&1) <= longitud))
  end

  # Convierte los elementos de la colección en mensajes con un formato configurable.
  def convertir_coleccion_mensajes(
    coleccion,
    formato \\ fn elemento -> "- #{elemento}\n" end
  ) do
    Enum.map(coleccion, formato)
  end



  # Lee una línea de texto y devuelve su contenido en una tupla.
  def ingresar(mensaje, :texto) do
    leer_texto(mensaje)
  end

  # Lee un entero una sola vez; los errores se devuelven como tuplas.
  def ingresar(mensaje, :entero) do
    with {:ok, texto} <- leer_texto(mensaje),
         {numero, ""} <- Integer.parse(texto) do
      {:ok, numero}
    else
      {:error, motivo} -> {:error, motivo}
      _ -> {:error, :formato_invalido}
    end
  end

  # Lee un entero o decimal una sola vez y devuelve el resultado en una tupla.
  def ingresar(mensaje, :real) do
    with {:ok, texto} <- leer_texto(mensaje) do
      case Integer.parse(texto) do
        {numero, ""} ->
          {:ok, numero}

        _ ->
          case Float.parse(texto) do
            {numero, ""} -> {:ok, numero}
            _ -> {:error, :formato_invalido}
          end
      end
    else
      {:error, motivo} ->
        {:error, motivo}
    end
  end

  # Lee una línea sin reintentarla y controla el fin de entrada.
  defp leer_texto(mensaje) do
    case IO.gets(mensaje) do
      nil -> {:error, :fin_entrada}
      texto -> {:ok, String.trim(texto)}
    end
  end
end
