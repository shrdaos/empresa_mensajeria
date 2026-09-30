# Integrantes: Sharon Dahiana Ospina - Santiago Trujillo Cubides.
defmodule Util do
  @moduledoc """
  Módulo con funciones que se reutilizan
  - autor: Julián E. Gutiérrez P.
  - fecha: Junio del 2026
  - licencia: GNU GPL v3
  """

  @doc """
  Función para mostrar un mensaje en la pantalla.

  ## Parámetro

  - mensaje: texto que se le presenta al usuario

  ## Ejemplo

  iex> Util.mostrar_mensaje("Hola Mundo")

  o puede usar

  "Hola Mundo" |> Util.mostrar_mensaje()
  """
  def mostrar_mensaje(mensaje) do
    mensaje
    |> IO.puts()
  end

  @doc """
  Función para mostrar un mensaje de error

  ## Parámetro

  - mensaje: texto que se le presenta al usuario

  ## Ejemplo

  iex> Util.mostrar_error("error ...")

  o puede usar

  "error ..." |> Util.mostrar_error()
  """
  def mostrar_error(mensaje) do
    IO.puts(:standard_error, mensaje)
  end

  @doc """
  Función para ingresar un dato desde teclado sin repetir la lectura.

  ## Parámetro

  - mensaje: texto que se le presenta al usuario
  - tipo: identifica el tipo de dato: :texto, :entero o :real.

  ## Ejemplo

  El resultado siempre es una tupla, por ejemplo {:ok, "Ana"} o
  {:error, :formato_invalido}.

  o puede usar

  "Ingresar nombre: " |> Util.ingresar(:texto)
  "Ingresar edad: "   |> Util.ingresar(:entero)
  "Ingresar altura: " |> Util.ingresar(:real)
  """
  def ingresar(mensaje, :texto) do
    leer_texto(mensaje)
  end

  def ingresar(mensaje, :entero) do
    with {:ok, texto} <- leer_texto(mensaje),
         {numero, ""} <- Integer.parse(texto) do
      {:ok, numero}
    else
      _ -> {:error, :formato_invalido}
    end
  end

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
      _ ->
        {:error, :fin_entrada}
    end
  end

  # Lee una línea una sola vez y devuelve texto o un error de fin de entrada.
  defp leer_texto(mensaje) do
    case IO.gets(mensaje) do
      nil -> {:error, :fin_entrada}
      texto -> {:ok, String.trim(texto)}
    end
  end
end
