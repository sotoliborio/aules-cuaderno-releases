# Cuaderno AULES · Web local

La versión actual es **0.2.5**. La aplicación se utiliza en el navegador y se ejecuta en tu propio equipo mediante Docker. Sustituye a los antiguos instaladores de escritorio y no necesita el servidor Render.

## Novedades de 0.2.5

- Inicio por doble clic con búsqueda de actualizaciones, copia de seguridad y conservación de datos.
- Bloqueo de la actualización mientras hay tareas IA activas; vuelve a iniciar al terminar.
- Importación de CE expresados sobre el módulo, convertidos al porcentaje de cada RA desde la vista previa.
- Lectura de tablas PDF de evaluación, sin confundir las columnas Empresa/Instituto.
- Conectar Codex durante la importación y volver conservando el archivo y los campos.
- Volver a extraer con IA y conservar el resultado anterior si falla.

## Descargar e iniciar

### Elige tu sistema

- **[DESCARGAR PARA MAC](https://github.com/sotoliborio/aules-cuaderno-releases/releases/download/v0.2.5/Instalar-Cuaderno-AULES-Mac-0.2.5.zip)** — Intel y Apple Silicon; incluye iniciar.command.
- **[DESCARGAR PARA WINDOWS](https://github.com/sotoliborio/aules-cuaderno-releases/releases/download/v0.2.5/Instalar-Cuaderno-AULES-Windows-0.2.5.zip)** — incluye iniciar.bat.

**Descarga un ZIP de instalación. No descargues ni descomprimas los TAR.GZ ARM64/AMD64:** son archivos técnicos que el lanzador obtiene automáticamente. Ambos Mac usan el mismo ZIP.

[Versión y cambios](https://github.com/sotoliborio/aules-cuaderno-releases/releases/tag/v0.2.5)

1. Instala [Docker Desktop](https://www.docker.com/products/docker-desktop/) y ábrelo. Revisa sus condiciones de uso para tu organización. Linux puede utilizar Docker Engine y Compose.
2. Descomprime el paquete web en una carpeta estable.
3. Mac: abre `iniciar.command`. Windows: abre `iniciar.bat` (PowerShell debe permitir el script local conforme a la política de tu equipo). Linux: ejecuta `sh iniciar.sh`.
4. El primer arranque descarga y comprueba la imagen para tu arquitectura. Puede tardar varios minutos. Abre **http://localhost:3000** cuando se confirme el arranque.

Se incluyen Python, Node y Codex CLI; no necesitas instalarlos por separado. Imágenes Linux para AMD64 (Intel/AMD) y ARM64 (Apple Silicon/Windows ARM). La compilación y el arranque se verifican en Linux para ambas arquitecturas; el lanzador de Windows requiere validación en un equipo Windows real.

## Tus cuentas y tus datos

- La instalación comienza vacía. No incluye alumnado, cursos, entregas, programaciones, contraseñas, tokens ni sesiones del autor.
- Elige sabores, conecta tu propia cuenta de AULES e importa los cursos con su programación. La app solicita el token directamente a AULES mediante HTTPS.
- Recordar sesión guarda tokens en el volumen local; no guarda tu contraseña en un archivo. Las credenciales y tokens de AULES no se envían a la IA.
- Para preparar rúbricas o corregir con IA, conecta **tu propia cuenta de Codex** desde Ajustes → Sistema. Estar conectado en otro chat no conecta esta instalación. Se aplica la cuota de tu cuenta.
- El acceso de Codex por código requiere habilitar «Inicio de sesión con código de dispositivo» en [Seguridad de ChatGPT](https://chatgpt.com/#settings/Security). Después pulsa Conectar Codex para obtener un código nuevo y autorízalo en el enlace mostrado. No compartas códigos ni sesiones.
- Las funciones IA envían a OpenAI las evidencias necesarias; las propuestas son borradores que debes revisar. Introduce las calificaciones en AULES y utiliza la comparación del cuaderno para comprobar que coinciden. La app no publica calificaciones.

## Actualizar, detener y conservar datos

**Desde esta versión basta con abrir iniciar.command (Mac) o iniciar.bat (Windows).** El lanzador consulta la última versión pública y, si hay una actualización, la descarga, comprueba su integridad y crea una copia de seguridad antes de aplicarla. Conserva cursos, calificaciones y sesiones en el volumen local. Si hay tareas IA activas, se detiene y explica que debes volver a iniciar al terminar. Si GitHub no responde, inicia la versión instalada sin actualizar.

**Para pasar desde 0.2.4 o anterior:** descarga el ZIP nuevo y descomprímelo en la misma carpeta, sustituyendo los lanzadores y docker-compose.yml; conserva .env si lo tienes. Después abre iniciar.command o iniciar.bat. Esta descarga inicial incorpora la búsqueda automática para las siguientes versiones. También puedes usar actualizar.command o actualizar.bat: realizan el mismo proceso.

Los datos se guardan en el volumen Docker `cuaderno-aules_cuaderno-aules-data`, fuera del paquete. Mantén una copia externa. `docker compose down` conserva datos; **no utilices `docker compose down -v`**, que los elimina. Cierra Docker solo cuando no haya correcciones en curso.

El registro de las antiguas versiones de escritorio no se traslada automáticamente. Conserva sus datos y solicita ayuda para migrarlos antes de borrarlos. La nueva distribución no sobrescribe ese registro.

## Móvil

Puedes acceder mediante Tailscale Serve privado con HTTPS. El equipo y Docker deben estar encendidos. No expongas el puerto en Internet. Cada instalación está diseñada para un docente; no es un servidor compartido para varias cuentas.

## Cambios de esta versión

- Nueva distribución web local con Docker para ambas arquitecturas; escritorio y Render dejan de formar parte de la instalación.
- Navegación unificada, sin barra inferior duplicada; fichas y formularios más legibles en móvil.
- Importación de rúbricas CSV de AULES, HTML o texto con vista previa e historial.
- Opciones de corrección separadas de calificación; avisos sencillos y detalles técnicos desplegables.
- Conexión a Codex accesible desde la preparación de rúbricas.

El repositorio contiene lanzadores y documentación pública; el desarrollo se mantiene en el repositorio privado. Las imágenes distribuidas contienen el código de ejecución Python y no datos docentes. SHA256SUMS permite comprobar las descargas; no sustituye una firma independiente.

## Ayuda para la primera instalación

**Mac:** descarga el ZIP del enlace anterior (no el ZIP de código de GitHub), descomprímelo y conserva la carpeta completa. Abre Docker Desktop y espera a que indique que está funcionando. Abre iniciar.command; no abras los archivos TAR.GZ de las imágenes. Si macOS no permite abrir el lanzador descargado, prueba clic derecho → Abrir y revisa Privacidad y seguridad; no desactives la protección del sistema. Al finalizar se abrirá el navegador.

**Windows:** instala Docker Desktop y sigue sus indicaciones para WSL 2/virtualización; puede requerir reinicio. Descomprime el ZIP con Extraer todo; no ejecutes el lanzador dentro del ZIP. Abre Docker Desktop, espera a que esté listo y abre iniciar.bat. El lanzador ejecuta PowerShell con permiso limitado a ese proceso, sin cambiar la configuración permanente. Las políticas de un centro pueden bloquearlo; en ese caso consulta con su responsable. Al finalizar se abrirá el navegador.

**Si no arranca:** conserva el mensaje de la ventana del lanzador y compártelo sin credenciales. Comprueba que Docker está abierto y que ninguna otra aplicación ocupa el puerto 3000. La primera descarga es de unos 320 MB; necesita conexión a Internet. No cierres Docker durante correcciones. No borres el volumen de datos al actualizar.

Verificado: construcción y arranque de las imágenes Linux AMD64/ARM64, integridad de descargas y pruebas automáticas de la aplicación. No se certifica instalación en todos los modelos de Mac/Windows; la instalación completa en Windows real está pendiente.
