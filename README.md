# Cuaderno AULES

La versión actual es **0.3.1**. Cuaderno AULES es una aplicación de escritorio para Mac y Windows. Se instala como cualquier otro programa, se abre desde su icono y se actualiza con un botón.

## Descargar

- **[DESCARGAR PARA MAC](https://github.com/sotoliborio/aules-cuaderno-releases/releases/download/v0.3.1/Cuaderno-AULES-0.3.1-Mac.dmg)**: Mac con chip de Apple (M1 o posterior).
- **[DESCARGAR PARA WINDOWS](https://github.com/sotoliborio/aules-cuaderno-releases/releases/download/v0.3.1/Cuaderno-AULES-0.3.1-Windows.exe)**: Windows 10 y 11 de 64 bits.

[Versión y cambios](https://github.com/sotoliborio/aules-cuaderno-releases/releases/tag/v0.3.1)

## Instalar

**Mac**

1. Abre el archivo `.dmg` y arrastra **Cuaderno AULES** a la carpeta Aplicaciones.
2. La primera vez, macOS puede avisar de que no puede comprobar el desarrollador. Abre Ajustes del Sistema → Privacidad y seguridad y pulsa **Abrir igualmente**. Solo hay que hacerlo una vez.

**Windows**

1. Ejecuta el instalador. Se instala para tu usuario, sin permisos de administrador.
2. Si Windows SmartScreen avisa, pulsa **Más información** → **Ejecutar de todas formas**. Solo hay que hacerlo una vez.

## Primeros pasos

1. Abre Cuaderno AULES desde su icono.
2. En **Ajustes → AULES**, conecta tu cuenta e importa tus cursos con su programación.
3. Para corregir con IA, en **Ajustes → Inteligencia artificial** pulsa **Descargar Codex** o **Descargar Claude** (unos 160 o 175 MB, una sola vez) y conecta **tu propia cuenta**. Se aplica la cuota de tu cuenta.
   - Codex necesita activar «Inicio de sesión con código de dispositivo» en [Seguridad de ChatGPT](https://chatgpt.com/#settings/Security).

## Actualizar

En **Ajustes → General**, pulsa **Buscar actualizaciones** y después **Instalar y reiniciar**. Antes de instalar se comprueba que no haya correcciones en curso y se guarda una copia de tu cuaderno. La actualización está firmada y se comprueba antes de instalarla; tus cursos y notas no se tocan.

## Tus datos

- La app empieza vacía. No incluye alumnado, cursos, entregas, contraseñas ni sesiones de nadie.
- Todo se guarda en tu equipo, en la carpeta privada de la aplicación:
  - Mac: `~/Library/Application Support/es.aules.cuaderno.escritorio`
  - Windows: `%APPDATA%\es.aules.cuaderno.escritorio`
- Haz copias de esa carpeta de vez en cuando.
- Tu contraseña de AULES no se guarda en ningún archivo. Las credenciales y los tokens no se envían a la IA.
- Las funciones de IA envían al proveedor elegido (OpenAI o Anthropic) las evidencias necesarias para corregir. Las propuestas son borradores que revisas tú. Solo el parcial por RA se publica en el libro de calificaciones de AULES, y siempre a petición tuya.
- La vista de documentos Writer usa LibreOffice si lo tienes instalado. Sin él, el cuaderno lee el texto del documento igualmente.

## Si algo falla

- Si la app no abre, ciérrala y vuelve a abrirla; solo puede haber una copia abierta.
- Conserva el mensaje que aparezca y compártelo sin contraseñas ni datos del alumnado.
- `SHA256SUMS.txt` permite comprobar las descargas.

El desarrollo se mantiene en un repositorio privado. Este repositorio solo publica los instaladores.
