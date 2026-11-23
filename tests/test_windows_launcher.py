"""Regresiones del lanzador de Windows: los avisos de Docker en stderr no deben detenerlo."""
import re
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parent.parent / 'iniciar.ps1'


class WindowsLauncher(unittest.TestCase):
    def setUp(self):
        self.raw = SCRIPT.read_bytes()
        self.text = self.raw.decode('utf-8-sig')

    def test_utf8_bom_for_windows_powershell(self):
        self.assertTrue(self.raw.startswith(b'\xef\xbb\xbf'), 'Windows PowerShell 5.1 necesita BOM para leer los acentos')

    def test_docker_is_only_called_through_tolerant_helpers(self):
        body = self.text.split('if (!(Get-Command docker', 1)[1]
        direct = [line for line in body.splitlines() if re.match(r'\s*(?:\$\w+\s*=\s*)?docker\s', line)]
        self.assertEqual(direct, [], 'Cada llamada a docker debe pasar por Invoke-Docker*')
        for helper in ('Invoke-DockerQuiet', 'Invoke-DockerOutput', 'Invoke-DockerVisible'):
            block = self.text.split('function ' + helper, 1)[1].split('\n}', 1)[0]
            self.assertIn("$ErrorActionPreference = 'Continue'", block)

    def test_missing_image_and_stopped_docker_are_handled(self):
        self.assertIn('(Invoke-DockerQuiet image inspect', self.text)
        self.assertIn('Docker Desktop.exe', self.text)
        self.assertIn('Esperando a Docker Desktop', self.text)


if __name__ == '__main__':
    unittest.main()
