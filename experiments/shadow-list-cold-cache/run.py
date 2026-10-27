import hashlib, json, os, pathlib, random, signal, subprocess, sys, time
root=pathlib.Path(__file__).resolve().parent
build=pathlib.Path(sys.argv[1]) if len(sys.argv)>1 else pathlib.Path('/private/tmp/qavsi-shadow-list-study-20261027/build')
exe=build/'shadow-list-study.app/Contents/MacOS/shadow-list-study'
out=pathlib.Path(sys.argv[2]) if len(sys.argv)>2 else root/'results'; out.mkdir(exist_ok=True)
require_reuse='--require-cache-reuse' in sys.argv
probe=subprocess.run(['rtk',str(exe),'--self-test'],capture_output=True,text=True)
assert probe.returncode==0,probe.stderr
cases=[]
for backend,repeats in [('metal',3),('opengl',1)]:
 for scene in ['controls-off','controls','blur-same','blur-mixed']:
  for repeat in range(repeats):cases.append((backend,scene,repeat,False))
 for scene in ['controls-off','controls','blur-same','blur-mixed']:cases.append((backend,scene,0,True))
# Diagnostics are separate and excluded from timing summaries.
random.Random(20261027).shuffle(cases)
manifest={'executableSha256':hashlib.sha256(exe.read_bytes()).hexdigest(),'cases':cases,'runs':[]}
for backend,scene,repeat,diagnostic in cases:
 name=f'{backend}-{scene}-{repeat}'+('-drawcalls' if diagnostic else '')
 path=out/(name+'.json')
 if path.exists():
  print('EXISTS; refusing to mix series:',path,flush=True);sys.exit(2)
 cmd=['rtk',str(exe),'--backend',backend,'--scene',scene,'--output',str(path),'--snapshot',str(out/(name+'.png'))]
 env=os.environ.copy();env['QSG_RENDER_LOOP']='basic' if backend=='opengl' else 'threaded';env['QT_LOGGING_RULES']='qt.qml.connections=false'
 env.pop('DYLD_INSERT_LIBRARIES',None)
 if require_reuse:cmd.append('--require-cache-reuse')
 if diagnostic:
  env['DYLD_INSERT_LIBRARIES']=str(build/'libdrawcounter.dylib');cmd.append('--drawcalls')
 print('START',name,flush=True)
 start=time.time()
 process=subprocess.Popen(cmd,env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True)
 try:
  stdout,stderr=process.communicate(timeout=45)
 except subprocess.TimeoutExpired:
  os.killpg(process.pid,signal.SIGTERM);stdout,stderr=process.communicate();stderr+='\nTIMED OUT'
 run=process
 (out/(name+'.log')).write_text(stdout+stderr)
 manifest['runs'].append({'name':name,'exit':run.returncode,'wallSeconds':time.time()-start})
 (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
 if run.returncode or not path.exists():
  print('FAILED',name,run.returncode,stderr[-2500:],flush=True);sys.exit(1)
 value=json.loads(path.read_text())
 assert value['qmlWarnings']==0 and value['count']==50
 print('PASS',name,flush=True)
print('COMPLETE',len(cases),flush=True)
