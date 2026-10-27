import argparse, hashlib, json, pathlib, subprocess, tempfile

parser=argparse.ArgumentParser(description="Check built shadow packages for GLES portability and unchanged native variants")
parser.add_argument("--qsb",type=pathlib.Path,required=True)
parser.add_argument("--packages",type=pathlib.Path,required=True)
parser.add_argument("--baseline",type=pathlib.Path)
parser.add_argument("--output",type=pathlib.Path,required=True)
args=parser.parse_args()
targets=["glsl,300es","glsl,130","glsl,140","glsl,150","glsl,330","hlsl,50","msl,12","spirv,100"]
report={"variants":[],"failures":[]}
with tempfile.TemporaryDirectory(prefix="qavsi-gles-check-") as temporary:
 def extract(pack,target,batch):
  output=pathlib.Path(temporary)/"extracted"
  command=["rtk",str(args.qsb),"-x",target,"-o",str(output)]
  if batch:command.append("-b")
  subprocess.run(command+[str(pack)],check=True,capture_output=True,text=True)
  return output.read_bytes()
 for name in ["shadow.vert","shadow.frag","blur_mask.vert","blur_mask.frag"]:
  pack=args.packages/(name+".qsb")
  for batch in ([False,True] if name.endswith(".vert") else [False]):
   for target in targets:
    data=extract(pack,target,batch)
    row={"shader":name,"batchable":batch,"target":target,"sha256":hashlib.sha256(data).hexdigest()}
    if target=="glsl,300es":
     if b"#version 300 es" not in data or b"noperspective" in data:
      report["failures"].append(f"{name} batchable={batch}: GLSL ES300 requires nonportable interpolation")
    elif args.baseline:
     row["baselineIdentical"]=data==extract(args.baseline/pack.name,target,batch)
     if not row["baselineIdentical"]:report["failures"].append(f"{name} batchable={batch}: native variant changed: {target}")
    report["variants"].append(row)
report["passed"]=not report["failures"]
args.output.write_text(json.dumps(report,indent=2)+"\n")
print(f"{len(report['variants'])} output variants; failures: {len(report['failures'])}")
for failure in report["failures"]:print(failure)
raise SystemExit(0 if report["passed"] else 1)
