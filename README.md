# Cuaderno AULES · Descargas

Aplicación local para organizar actividades, entregas y evaluación por resultados de aprendizaje y criterios de evaluación. Este repositorio contiene únicamente los instaladores y manifiestos de actualización. El código se mantiene en un repositorio privado.

## Descargar

La versión de prueba actual es **[0.1.8](https://github.com/sotoliborio/aules-cuaderno-releases/releases/tag/v0.1.8)**. Consulta también todas las [Releases](https://github.com/sotoliborio/aules-cuaderno-releases/releases).

- **Mac con Apple Silicon:** [descarga el paquete](https://github.com/sotoliborio/aules-cuaderno-releases/releases/latest/download/Cuaderno-AULES.app.tar.gz), descomprímelo y mueve la app a Aplicaciones.
- **Windows de 64 bits:** [descarga el instalador 0.1.8](https://github.com/sotoliborio/aules-cuaderno-releases/releases/download/v0.1.8/Cuaderno-AULES_0.1.8_x64-setup.exe) y ejecuta el instalador.
- Mac con procesador Intel no está incluido en los paquetes actuales.

Esta es una versión de prueba. Los paquetes incorporan firma para las actualizaciones de Tauri, pero no tienen aún notarización de Apple ni certificado de firma de Windows; el sistema puede mostrar avisos. Las sumas SHA256 acompañan a cada versión.

## Novedades de 0.1.8

- «Evaluación Continua» sustituye a «Seguimiento» en el selector de convocatoria.
- Las notas confirmadas de AULES alimentan los CE explícitos como notas globales heredadas, conservando las opciones de solo nota global.
- Importación por actividad si una consulta de notas en lote falla.
- Unidades numeradas y selección progresiva de instrumentos, porcentajes visibles y validación inmediata del total del 100 %.

## Tus datos y cuentas

La instalación empieza vacía. No incluye cursos, alumnado, notas, documentos de clase, contraseñas, tokens ni sesiones del autor. Los datos de cada profesor se guardan en su propio equipo. AULES se conecta con la cuenta del profesor y sus permisos reales.

Las correcciones con IA requieren instalar [Codex CLI](https://developers.openai.com/codex/cli/) y completar `codex login` con tu propia cuenta. La app no proporciona cuota de IA: se aplican los límites de tu cuenta. No se comparte la sesión del autor. El ordenador debe permanecer encendido durante las correcciones.

Las propuestas de IA son borradores que deben revisarse. Publicar notas en AULES es una acción explícita del profesor y depende de los permisos que permita su instancia.

## Actualizaciones

El botón de versión de la app permite buscar una actualización, consultar sus cambios e instalarla. Las actualizaciones se verifican mediante firma y se prepara una copia local del registro antes de instalar. Tus datos no se publican en este repositorio.

El canal publica la versión 0.1.8 y se han verificado las firmas y los SHA256 de los paquetes. La instalación mediante el actualizador entre versiones todavía está pendiente de comprobación completa. Conserva una copia de tus datos antes de usar esta versión de prueba como único registro de evaluación.

La versión 0.1.1 corrige la firma del paquete Mac. La 0.1.0 tenía la firma del ejecutable sin sellar los recursos y podía aparecer como dañada. Utiliza la versión actual, 0.1.8. Si macOS pide autorización por falta de notarización, consulta Ajustes del Sistema → Privacidad y seguridad → Abrir igualmente. La firma ad hoc no sustituye la notarización de Apple.
