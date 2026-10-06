# Cuaderno AULES · Web local

La versión actual es **0.2.1**. La aplicación se utiliza en el navegador y se ejecuta en tu propio equipo mediante Docker. Sustituye a los antiguos instaladores de escritorio y no necesita el servidor Render.

## Descargar e iniciar

[Descargar paquete web 0.2.1](https://github.com/sotoliborio/aules-cuaderno-releases/releases/download/v0.2.1/Cuaderno-AULES-web-0.2.1.zip) · [Versión y cambios](https://github.com/sotoliborio/aules-cuaderno-releases/releases/tag/v0.2.1)

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
- Las funciones IA envían a OpenAI las evidencias necesarias; las propuestas son borradores que debes revisar. Publicar calificaciones es una acción explícita y depende de los permisos de AULES.

## Actualizar, detener y conservar datos

Descarga y descomprime el paquete nuevo **en la misma carpeta**, conserva `.env` si lo tienes y ejecuta `sh actualizar.sh` (Windows: abre actualizar.bat). El lanzador crea una copia SQLite antes de actualizar y se detiene si hay trabajos IA activos.

Windows, antes de actualizar: `docker compose exec -T cuaderno python /opt/cuaderno/outputs/aules-evaluacion/web_maintenance.py backup`.

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
