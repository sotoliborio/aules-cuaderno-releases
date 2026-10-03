# Cuaderno AULES · Descargas

Aplicación local para organizar actividades, entregas y evaluación por resultados de aprendizaje y criterios de evaluación. Este repositorio contiene únicamente los instaladores y manifiestos de actualización. El código se mantiene en un repositorio privado.

## Descargar

Los paquetes verificados se publican en [Releases](https://github.com/sotoliborio/aules-cuaderno-releases/releases). Si todavía no aparece una release, la compilación inicial sigue en preparación.

- **Mac con Apple Silicon:** descarga `Cuaderno AULES.app.tar.gz`, descomprímelo y mueve la app a Aplicaciones.
- **Windows de 64 bits:** descarga el archivo terminado en `-setup.exe` y ejecuta el instalador.
- Mac con procesador Intel no está incluido en esta primera versión.

Esta es una primera versión de prueba. Los paquetes incorporan firma para las actualizaciones de Tauri, pero no tienen aún notarización de Apple ni certificado de firma de Windows; el sistema puede mostrar avisos. Las sumas SHA256 acompañan a cada versión.

## Tus datos y cuentas

La instalación empieza vacía. No incluye cursos, alumnado, notas, documentos de clase, contraseñas, tokens ni sesiones del autor. Los datos de cada profesor se guardan en su propio equipo. AULES se conecta con la cuenta del profesor y sus permisos reales.

Las correcciones con IA requieren instalar [Codex CLI](https://developers.openai.com/codex/cli/) y completar `codex login` con tu propia cuenta. La app no proporciona cuota de IA: se aplican los límites de tu cuenta. No se comparte la sesión del autor. El ordenador debe permanecer encendido durante las correcciones.

Las propuestas de IA son borradores que deben revisarse. Publicar notas en AULES es una acción explícita del profesor y depende de los permisos que permita su instancia.

## Actualizaciones

El botón de versión de la app permite buscar una actualización, consultar sus cambios e instalarla. Las actualizaciones se verifican mediante firma y se prepara una copia local del registro antes de instalar. Tus datos no se publican en este repositorio.

La actualización entre versiones todavía debe validarse con una segunda versión. Conserva una copia de tus datos antes de usar esta versión de prueba como único registro de evaluación.
