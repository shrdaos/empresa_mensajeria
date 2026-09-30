# Informe de apoyo — Parcial 1: Jugutier

> Antes de entregar: agreguen los nombres reales de los integrantes en el encabezado de cada `.exs`, revisen el documento, ejecuten el programa y escriban su propia reflexión sobre el uso de IA. Este informe es una guía verificable, no reemplaza la sustentación ni el PDF solicitado.

## Diseño y colecciones (Parte A)

- Los repartidores, zonas y servicios se guardan en **listas de mapas**. Cada mapa representa un registro y sus claves nombradas (`:codigo`, `:zona`, `:dia`, etc.) hacen explícito el significado de cada dato. No se definen structs.
- Los reportes se calculan con `Enum` y comprehensions `for`. El mapa de kilómetros diarios usa el número del día como clave para consultar fácilmente sus kilómetros.
- El código está separado por responsabilidad: `validacion_mensajeria.exs`, `calculos_mensajeria.exs`, `liquidacion_mensajeria.exs`, `reportes_mensajeria.exs` y `comprobante_mensajeria.exs`. `mensajeria.exs` coordina el orden de ejecución.
- Las funciones que validan, filtran, ordenan y calculan valores son puras: reciben datos y devuelven resultados sin leer teclado ni imprimir. La interacción y los reportes de pantalla usan `IO` y `Util2.mostrar/2`.
- `with` encadena las cinco validaciones en el orden del enunciado y detiene la revisión en el primer `{:error, motivo}`. `case` separa las alternativas de entrada y de búsqueda; `cond` elige el ajuste de pago según el retraso; `if` resuelve decisiones sencillas.
- `ranking/2` recibe una keyword list. Por ejemplo, `ranking(filas, por: & &1.neto, sentido: :desc, limite: 5)` ordena por neto descendente y deja los cinco primeros. `:por`, `:sentido` y `:limite` son opciones configurables.

## Validación y caso de error

`convertir_entrada/1` valida primero el formato (cinco campos; día entero; kilómetros y retraso numéricos). Después `validar_servicio/3` revisa existencia del repartidor, existencia de la zona, día, kilómetros y retraso. Por ejemplo, un registro con repartidor existente, zona existente, día `0`, kilómetros `0` y retraso `200` produce `{:error, :dia_invalido}`: se devuelve el primer motivo, aunque tenga más errores.

Los datos de ejemplo tienen 84 servicios válidos y 10 rechazados: dos por cada uno de los cinco motivos. Los servicios inválidos se muestran en R1 y no se utilizan en los demás cálculos.

## R6: retraso promedio ponderado

El promedio simple trata todos los servicios con el mismo peso. El ponderado multiplica cada retraso por los kilómetros de ese servicio y divide por los kilómetros totales. Por eso pueden diferir; un servicio más largo aporta más a la medida y representa más distancia recorrida expuesta a ese retraso.

Ejemplo de los datos del programa, repartidora M05: sus seis servicios tienen kilómetros `26, 27, 28, 29, 30, 31` y retrasos `-5, 5, 12, 35, 2, 2` minutos.

- Promedio simple: `(-5 + 5 + 12 + 35 + 2 + 2) / 6 = 8,5` minutos.
- Promedio ponderado: `((-5×26) + (5×27) + (12×28) + (35×29) + (2×30) + (2×31)) / (26+27+28+29+30+31) = 1478 / 171 ≈ 8,64` minutos.

No son iguales porque los retrasos no están asociados a distancias iguales. En este ejemplo, el envío de 35 minutos de retraso y 29 km pesa más que el de 5 minutos de adelanto y 26 km. Un resultado negativo también es válido y sería mejor que uno positivo porque significa adelanto.

## `Map.merge/3` (Parte C)

El mapa aliado tiene kilómetros en los días 1, 2, 3, 5 y 7. `Map.merge/2` conserva las claves de ambos mapas, pero cuando una clave aparece en los dos, deja el valor del segundo mapa y reemplaza el primero. Eso perdería los kilómetros locales de los días coincidentes.

Con los datos de ejemplo, el mapa local es `%{1 => 503, 2 => 503, 3 => 503, 4 => 503, 5 => 503, 6 => 503}`. `Map.merge/2` produciría `%{1 => 580.5, 2 => 430, 3 => 510, 4 => 503, 5 => 625, 6 => 503, 7 => 180}`.

`combinar_kilometros/2` usa `Map.merge/3` y suma los valores de las claves repetidas. El resultado es `%{1 => 1083.5, 2 => 933, 3 => 1013, 4 => 503, 5 => 1128, 6 => 503, 7 => 180}`. El día 7 no se elimina: como solo está en el mapa aliado, queda en el resultado con 180 km. El programa imprime el mapa combinado en R3.

## Medición

El programa mide con `:timer.tc/1` el tiempo empleado por `validar_lista/3` y lo imprime en microsegundos. En una ejecución de prueba local se observó un tiempo inferior a 1.000 μs para los 94 registros iniciales; el tiempo varía por equipo y carga, por lo que deben ejecutar varias veces y anotar sus propios valores y condiciones. La medición excluye la lectura interactiva y los reportes.

## Uso de inteligencia artificial y bitácora

- **Uso registrado:** se solicitó a un asistente de IA ayuda para organizar y comentar una solución Elixir que respete las restricciones del parcial. Se revisó el código ejecutándolo y se comprobaron la cantidad de servicios, los motivos de rechazo, los reportes, el ingreso adicional y el comprobante.
- **Precaución aplicada:** se adaptaron los lectores de `Util` y `Util2` para que hagan una sola lectura, conviertan con `Integer.parse/1` o `Float.parse/1` y devuelvan tuplas; no usan `try/rescue` ni reintentos recursivos. El programa principal reutiliza `Util2.mostrar/2` y `Util2.ordenar/3`, y valida su entrada con conversiones seguras.
- **Para completar por el grupo:** registren fecha, cambio realizado por cada integrante, un error que encontraron al probar y cómo lo corrigieron. Escriban una reflexión propia sobre qué sugirió la IA, qué verificaron y qué pueden explicar o modificar sin ayuda. No presenten una reflexión ficticia.

## Ejecución

Desde la carpeta del proyecto:

```sh
elixir -r Util2.ex -r datos.exs -r validacion_mensajeria.exs -r calculos_mensajeria.exs -r liquidacion_mensajeria.exs -r reportes_mensajeria.exs -r comprobante_mensajeria.exs mensajeria.exs
```

El programa pide un servicio adicional (o Enter para omitirlo) y, al final, el código para el comprobante. No necesita Mix, dependencias externas ni archivos de entrada/salida.
