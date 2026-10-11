import os,tempfile,subprocess,shutil
from pathlib import Path
source=Path(__file__).resolve().parent.parent
for scenario in ('new','upgrade','blocked','current','offline','stopped'):
 with tempfile.TemporaryDirectory() as temp:
  root=Path(temp);(root/'bin').mkdir()
  for name in ('iniciar.sh','docker-compose.yml'):shutil.copy(source/name,root/name)
  (root/'.env').write_text('SETTING_PRESERVED=ok\nCUADERNO_IMAGE=cuaderno-aules:0.2.4\n')
  docker='''#!/bin/sh
printf '%s\\n' "$*" >> "$TEST_DIR/log"
case "$*" in
 'compose ps -a -q cuaderno') [ "$SCENARIO" = new ] || echo container-old;;
 'inspect --format {{.Config.Image}} container-old') if [ "$SCENARIO" = current ];then echo cuaderno-aules:0.2.5;else echo cuaderno-aules:0.2.4;fi;;
 'inspect --format {{.State.Running}} container-old') if [ "$SCENARIO" = stopped ];then echo false;else echo true;fi;;
 *web_maintenance.py*) [ "$SCENARIO" != blocked ] || exit 1;;
esac
exit 0
'''
  curl='''#!/bin/sh
[ "$SCENARIO" != offline ] || exit 1
while [ "$#" -gt 0 ];do if [ "$1" = -o ];then shift;printf '{"tag_name":"v0.2.5"}' > "$1";fi;shift;done
'''
  for name,text in (('docker',docker),('curl',curl),('open','#!/bin/sh\nexit 0\n')):
   p=root/'bin'/name;p.write_text(text);p.chmod(0o755)
  env={**os.environ,'PATH':str(root/'bin')+':'+os.environ['PATH'],'TEST_DIR':temp,'SCENARIO':scenario}
  r=subprocess.run(['sh','iniciar.sh'],cwd=root,env=env,capture_output=True,text=True,timeout=15)
  log=(root/'log').read_text();settings=(root/'.env').read_text()
  assert 'SETTING_PRESERVED=ok' in settings
  if scenario=='blocked':
   assert r.returncode!=0 and 'compose up' not in log and 'cuaderno-aules:0.2.4' in settings
  else:
   assert r.returncode==0,(scenario,r.stderr,r.stdout)
   if scenario in ('upgrade','stopped'):assert log.index('web_maintenance.py backup')<log.index('compose up -d')
   if scenario in ('current','offline'):assert 'compose up' not in log and 'web_maintenance' not in log
   if scenario=='offline':assert 'cuaderno-aules:0.2.4' in settings
  print('OK',scenario)
