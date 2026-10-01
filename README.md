# Liquidación semanal de una empresa de mensajería

Aplicación de consola escrita en Elixir para validar servicios de entrega, calcular la liquidación semanal de los repartidores y generar reportes y comprobantes. Los datos de entrada de la ejecución están definidos como datos de ejemplo en el código.

## Requisitos y ejecución

- Elixir instalado y disponible en el terminal (`elixir --version`).
- No se necesitan Mix, dependencias externas ni archivos de entrada adicionales.
- Ejecutar desde la carpeta del proyecto:

```sh
elixir mensajeria.exs
```

El archivo principal carga sus dependencias mediante `Code.require_file/1`, por lo que no hace falta enumerar los archivos con opciones `-r`.

Durante la ejecución se puede ingresar un servicio adicional o presionar Enter para omitirlo. Al final, el programa solicita el código de un repartidor para mostrar su comprobante. Si la entrada estándar termina, el programa continúa sin un servicio adicional y no genera comprobante.

## Flujo del programa

1. Carga los repartidores, las zonas y los servicios de ejemplo.
2. Valida cada servicio y separa los aceptados de los rechazados. Mide e informa el tiempo de validación inicial.
3. Ofrece ingresar un servicio adicional con el formato `repartidor;zona;dia;kilometros;retraso`, por ejemplo `M01;Z1;1;12.5;5`. La entrada se procesa una vez; un formato o dato inválido se informa sin volver a preguntar.
4. Genera los reportes de rechazos, recorridos, liquidaciones y desempeño.
5. Solicita el código de un repartidor e imprime el detalle de su comprobante, si existe.

## Datos y reglas

`Datos` define 10 repartidores, cuatro zonas y 94 servicios iniciales: 84 servicios válidos (14 por cada uno de los seis días) y 10 inválidos de prueba (dos por cada motivo de rechazo). Cada servicio es un mapa con repartidor, zona, día, kilómetros y retraso. Los repartidores y las zonas también se representan con listas de mapas; no se usan structs.

Un servicio se valida en este orden y se rechaza por el primer error encontrado:

1. El código del repartidor existe.
2. El identificador de la zona existe.
3. El día es un entero entre 1 y 6.
4. Los kilómetros son numéricos, mayores que cero y como máximo 45.
5. El retraso está entre -30 y 180 minutos, inclusive.

Los servicios rechazados no participan en los cálculos. Un servicio adicional debe contener cinco campos separados por punto y coma; el día debe ser entero y kilómetros y retraso pueden ser enteros o decimales.

## Liquidación

- La tarifa inicial es de $2.500 por kilómetro.
- El pago por servicio se ajusta según el retraso: hasta 0 minutos (incluido), bonificación del 8%; de 1 a 10 minutos, tarifa completa; de 11 a 30 minutos, descuento del 10%; más de 30 minutos, descuento del 25%.
- Se suman $15.000 por cada día en que el repartidor recorra al menos 80 km.
- A quienes usan bicicleta alquilada se les descuentan $10.000 por cada día trabajado.
- El neto es el valor de los servicios más las bonificaciones, menos el alquiler.

## Reportes

La ejecución muestra estos resultados en consola:

- **R1. Servicios rechazados:** detalle de rechazos y conteo por motivo.
- **R2. Recorrido por zona:** kilómetros y densidad de recorrido (kilómetros por km²), ordenados por densidad descendente.
- **R3. Recorrido diario:** kilómetros por día, cumplimiento de la meta diaria de 500 km y combinación con los kilómetros de una empresa aliada. Los días coincidentes se suman mediante `Map.merge/3` y también se conserva el día 7 de la empresa aliada.
- **R4. Liquidación semanal:** pago, bonificaciones, alquiler y neto por repartidor, ordenados por neto descendente.
- **R5. Mayor distancia por día:** repartidor o repartidores con más kilómetros cada día y quienes acumulan más primeros lugares.
- **R6. Mejor puntualidad ponderada:** menor retraso promedio ponderado por kilómetros entre repartidores con al menos tres servicios válidos.
- **R7. Totales de la semana:** total pagado y costo promedio pagado por kilómetro.
- **R8. Cobertura:** repartidores con al menos un servicio válido en cada zona.
- **Comprobante:** kilómetros, valor de servicios y bonificación por día, además de los totales, alquiler y neto del repartidor seleccionado.

## Archivos

- `mensajeria.exs`: punto de entrada y coordinación de la ejecución.
- `datos.exs`: datos de ejemplo de repartidores, zonas y servicios.
- `validacion_mensajeria.exs`: validación de servicios y lectura de un servicio adicional.
- `calculos_mensajeria.exs`: cálculos de kilómetros, combinación de mapas y rankings.
- `liquidacion_mensajeria.exs`: cálculo de pagos, bonificaciones, alquiler y neto.
- `reportes_mensajeria.exs`: reportes R1 a R8.
- `comprobante_mensajeria.exs`: selección de repartidor y generación del comprobante.
- `Util2.ex`: funciones de entrada, salida y ordenamiento usadas por la aplicación.
- `Util.ex`: módulo auxiliar alternativo; no lo carga el punto de entrada.
- `INFORME.md`: informe complementario sobre el diseño y algunos cálculos del proyecto.
- `Documento de Entrega - Parcial 1_ Liquidación Semanal de Empresa de Mensajería.pdf`: documento de entrega asociado al proyecto.

Los resultados se imprimen en la terminal; la aplicación no crea archivos de reporte ni conserva cambios de datos entre ejecuciones.
