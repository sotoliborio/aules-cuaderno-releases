import os,tempfile,subprocess,shutil,hashlib
from pathlib import Path
source=Path(__file__).resolve().parent.parent
for scenario in ('new','upgrade','blocked','current','offline','stopped','download','badchecksum'):
 with tempfile.TemporaryDirectory() as temp:
  root=Path(temp);(root/'bin').mkdir()
  for name in ('iniciar.sh','docker-compose.yml'):shutil.copy(source/name,root/name)
  (root/'.env').write_text('SETTING_PRESERVED=ok\nCUADERNO_IMAGE=cuaderno-aules:0.2.5\n')
  docker='''#!/bin/sh
printf '%s\\n' "$*" >> "$TEST_DIR/log"
case "$*" in
 'compose ps -a -q cuaderno') case "$SCENARIO" in new|download|badchecksum) ;; *) echo container-old;; esac;;
 'inspect --format {{.Config.Image}} container-old') if [ "$SCENARIO" = current ];then echo cuaderno-aules:0.2.8;else echo cuaderno-aules:0.2.5;fi;;
 'inspect --format {{.State.Running}} container-old') if [ "$SCENARIO" = stopped ];then echo false;else echo true;fi;;
 'image inspect cuaderno-aules:0.2.8') case "$SCENARIO" in download|badchecksum) exit 1;; esac;;
 *web_maintenance.py*) [ "$SCENARIO" != blocked ] || exit 1;;
esac
exit 0
'''
  fixture=b'test image bytes'
  checksum=hashlib.sha256(fixture).hexdigest()
  (root/'fixture').write_bytes(fixture)
  curl='''#!/bin/sh
[ "$SCENARIO" != offline ] || exit 1
url='';out=''
while [ "$#" -gt 0 ];do
 case "$1" in -o) shift;out=$1;; https://*) url=$1;; esac
 shift
done
case "$url" in
 */latest) printf '{"tag_name":"v0.2.8"}' > "$out";;
 */SHA256SUMS.txt) asset="cuaderno-aules-web-0.2.8-$(uname -m).tar.gz";case "$(uname -m)" in x86_64) asset=cuaderno-aules-web-0.2.8-amd64.tar.gz;; esac
 digest=$FIXTURE_SHA;[ "$SCENARIO" != badchecksum ] || digest=0000000000000000000000000000000000000000000000000000000000000000
 printf '%s  %s\\n' "$digest" "$asset" > "$out";;
 *.tar.gz) cp "$TEST_DIR/fixture" "$out";;
 *) exit 1;;
esac
'''
  for name,text in (('docker',docker),('curl',curl),('open','#!/bin/sh\nexit 0\n')):
   p=root/'bin'/name;p.write_text(text);p.chmod(0o755)
  env={**os.environ,'PATH':str(root/'bin')+':'+os.environ['PATH'],'TEST_DIR':temp,'SCENARIO':scenario,'FIXTURE_SHA':checksum}
  r=subprocess.run(['/bin/sh','iniciar.sh'],cwd=root,env=env,capture_output=True,text=True,timeout=15)
  log=(root/'log').read_text();settings=(root/'.env').read_text()
  assert 'SETTING_PRESERVED=ok' in settings
  if scenario in ('blocked','badchecksum'):
   assert r.returncode!=0 and 'compose up' not in log and 'cuaderno-aules:0.2.5' in settings
  else:
   assert r.returncode==0,(scenario,r.stderr,r.stdout)
   if scenario in ('upgrade','stopped'):assert log.index('web_maintenance.py backup')<log.index('compose up -d')
   if scenario in ('current','offline'):assert 'compose up' not in log and 'web_maintenance' not in log
   if scenario=='offline':assert 'cuaderno-aules:0.2.5' in settings
  if scenario=='download':assert 'load -i' in log and 'Descargando la versión 0.2.8' in r.stdout
  if scenario=='badchecksum':assert 'load -i' not in log
  print('OK',scenario)
