# Integrantes: Sharon Dahiana Ospina - Santiago Trujillo Cubides.

# Datos de ejemplo del parcial: 10 repartidores, 4 zonas, 84 servicios válidos
# y dos servicios inválidos por cada motivo de rechazo.
defmodule Datos do
  @doc "Devuelve los repartidores de la empresa y si usan bicicleta alquilada."
  def repartidores do
    [
      %{codigo: "M01", nombre: "Ana Torres", bicicleta: true},
      %{codigo: "M02", nombre: "David López", bicicleta: false},
      %{codigo: "M03", nombre: "Laura Gómez", bicicleta: true},
      %{codigo: "M04", nombre: "Carlos Ruiz", bicicleta: false},
      %{codigo: "M05", nombre: "Sofía Rojas", bicicleta: true},
      %{codigo: "M06", nombre: "Mateo Castro", bicicleta: false},
      %{codigo: "M07", nombre: "Valentina Díaz", bicicleta: true},
      %{codigo: "M08", nombre: "Juan Pérez", bicicleta: false},
      %{codigo: "M09", nombre: "Camila Arias", bicicleta: false},
      %{codigo: "M10", nombre: "Andrés León", bicicleta: false}
    ]
  end

  @doc "Devuelve las cuatro zonas y su área en kilómetros cuadrados."
  def zonas do
    [
      %{id: "Z1", nombre: "Centro", area: 6.5},
      %{id: "Z2", nombre: "Norte", area: 10.2},
      %{id: "Z3", nombre: "Sur", area: 8.4},
      %{id: "Z4", nombre: "Occidente", area: 12.0}
    ]
  end

  @doc "Construye una lista de 84 servicios válidos y 10 servicios de prueba inválidos."
  def servicios do
    servicios_validos =
      for dia <- 1..6, indice <- 1..14 do
        numero_repartidor = rem(indice - 1, 10) + 1
        numero_zona = rem(indice + dia - 2, 4) + 1

        kilometros =
          cond do
            indice <= 4 -> 42
            indice >= 11 -> 41
            true -> 26 + rem(indice + dia, 6)
          end

        retraso =
          case rem(indice + dia, 6) do
            0 -> -5
            1 -> 5
            2 -> 12
            3 -> 35
            _ -> 2
          end

        %{
          repartidor: "M" <> String.pad_leading(Integer.to_string(numero_repartidor), 2, "0"),
          zona: "Z#{numero_zona}",
          dia: dia,
          kilometros: kilometros,
          retraso: retraso
        }
      end

    servicios_invalidos = [
      %{repartidor: "M99", zona: "Z1", dia: 1, kilometros: 10, retraso: 0},
      %{repartidor: "M98", zona: "Z2", dia: 2, kilometros: 15, retraso: 0},
      %{repartidor: "M01", zona: "Z99", dia: 1, kilometros: 10, retraso: 0},
      %{repartidor: "M02", zona: "Z98", dia: 2, kilometros: 10, retraso: 0},
      %{repartidor: "M03", zona: "Z1", dia: 0, kilometros: 10, retraso: 0},
      %{repartidor: "M04", zona: "Z1", dia: 7, kilometros: 10, retraso: 0},
      %{repartidor: "M05", zona: "Z1", dia: 1, kilometros: 0, retraso: 0},
      %{repartidor: "M06", zona: "Z1", dia: 1, kilometros: 46, retraso: 0},
      %{repartidor: "M07", zona: "Z1", dia: 1, kilometros: 10, retraso: -31},
      %{repartidor: "M08", zona: "Z1", dia: 1, kilometros: 10, retraso: 181}
    ]

    servicios_validos ++ servicios_invalidos
  end
end
