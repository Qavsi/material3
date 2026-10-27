import hashlib,io,json,pathlib,subprocess,sys,tarfile
root=pathlib.Path(__file__).resolve().parent
kit=root.parents[1]
inputs=json.loads((root/'inputs.json').read_text())
destination=pathlib.Path(sys.argv[1]);destination.mkdir(exist_ok=False)
for name,repo,revision in [('material3',kit,inputs['material3Revision']),('icons',kit.parent/'icons',inputs['iconsRevision'])]:
 target=destination/name;target.mkdir()
 data=subprocess.check_output(['rtk','proxy','git','-C',str(repo),'archive',revision])
 with tarfile.open(fileobj=io.BytesIO(data)) as archive:archive.extractall(target,filter='data')
for relative,expected in inputs['shadowSourceSha256'].items():
 assert hashlib.sha256((destination/'material3'/relative).read_bytes()).hexdigest()==expected
p=destination/'material3/src/Qavsi/Material3/Style/internal/shadows/blurmaskmaterial.cpp'
s=p.read_text();offset=s.index('namespace qavsi::shadow::blur')
s=s[:offset]+"""#include <atomic>
#include <chrono>
static std::atomic<quint64> studyMisses{0}, studyConvolutionNs{0};
extern "C" Q_DECL_EXPORT quint64 study_cache_misses() { return studyMisses.load(); }
extern "C" Q_DECL_EXPORT quint64 study_convolution_ns() { return studyConvolutionNs.load(); }

"""+s[offset:]
needle='    fill_rrect_corner_cutout(pixels, sigma, radius);'
assert s.count(needle)==1
s=s.replace(needle,"""    const auto studyStart = std::chrono::steady_clock::now();
    fill_rrect_corner_cutout(pixels, sigma, radius);
    studyConvolutionNs.fetch_add(std::chrono::duration_cast<std::chrono::nanoseconds>(
        std::chrono::steady_clock::now() - studyStart).count());
    studyMisses.fetch_add(1);""")
p.write_text(s)
print('Frozen sources prepared:',destination)
