# Integrantes: escriban aquí los nombres de todas las personas del grupo.
# Ejecutar desde esta carpeta con:
# elixir -r Util2.ex -r datos.exs -r validacion_mensajeria.exs -r calculos_mensajeria.exs -r liquidacion_mensajeria.exs -r reportes_mensajeria.exs -r comprobante_mensajeria.exs mensajeria.exs

defmodule Mensajeria do
  @doc "Coordina la validación, los reportes y el comprobante al terminar."
  def ejecutar do
    Util2.mostrar("LIQUIDACIÓN SEMANAL - EMPRESA DE MENSAJERÍA", :mensaje)

    {tiempo_validacion, {servicios_validos, rechazados}} =
      :timer.tc(fn ->
        ValidacionMensajeria.validar_lista(Datos.servicios(), Datos.repartidores(), Datos.zonas())
      end)

    Util2.mostrar("Servicios válidos iniciales: #{length(servicios_validos)}", :mensaje)
    Util2.mostrar("Servicios rechazados iniciales: #{length(rechazados)}", :mensaje)
    Util2.mostrar("Tiempo de validación: #{tiempo_validacion} microsegundos", :mensaje)

    {servicios_validos, rechazados} =
      ValidacionMensajeria.ingresar_servicio(
        servicios_validos,
        rechazados,
        Datos.repartidores(),
        Datos.zonas()
      )

    ReportesMensajeria.reportar_rechazos(rechazados)
    ReportesMensajeria.reportar_zonas(servicios_validos, Datos.zonas())
    ReportesMensajeria.reportar_dias(servicios_validos)

    liquidaciones = LiquidacionMensajeria.calcular_liquidaciones(servicios_validos, Datos.repartidores())
    ReportesMensajeria.reportar_liquidaciones(liquidaciones)
    ReportesMensajeria.reportar_ganadores_diarios(servicios_validos, Datos.repartidores())
    ReportesMensajeria.reportar_puntualidad(servicios_validos, Datos.repartidores())
    ReportesMensajeria.reportar_totales(liquidaciones, servicios_validos)
    ReportesMensajeria.reportar_cobertura(servicios_validos, Datos.repartidores(), Datos.zonas())

    ComprobanteMensajeria.solicitar_comprobante(
      servicios_validos,
      liquidaciones,
      Datos.repartidores()
    )
  end
end

Mensajeria.ejecutar()
