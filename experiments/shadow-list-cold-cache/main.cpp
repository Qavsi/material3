#include <QCommandLineParser>
#include <QElapsedTimer>
#include <QEventLoop>
#include <QFile>
#include <QGuiApplication>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QOpenGLContext>
#include <QQmlApplicationEngine>
#include <QQuickGraphicsConfiguration>
#include <QQuickItem>
#include <QQuickWindow>
#include <QScreen>
#include <QSignalSpy>
#include <QSurfaceFormat>
#include <QSysInfo>
#include <QTest>
#include <QTimer>
#include <rhi/qrhi.h>
#include <algorithm>
#include <cmath>
#include <ctime>
#include <dlfcn.h>
#include <mutex>

static QJsonObject distribution(QList<double> values)
{
    if (values.isEmpty()) return {{"samples",0}};
    std::sort(values.begin(), values.end());
    auto p = [&](double q) { return values[std::clamp(qsizetype(std::ceil(q*values.size()))-1,qsizetype(0),values.size()-1)]; };
    double sum=0; int over25=0,over33=0,over50=0;
    for(double v:values){sum+=v;over25+=v>25;over33+=v>33;over50+=v>50;}
    return {{"samples",int(values.size())},{"mean",sum/values.size()},{"p50",p(.5)},
        {"p95",p(.95)},{"p99",p(.99)},{"max",values.last()},
        {"over25",over25},{"over33",over33},{"over50",over50}};
}
static void waitEvents(int ms)
{
    QEventLoop loop; QTimer timer; timer.setSingleShot(true); timer.setTimerType(Qt::PreciseTimer);
    QObject::connect(&timer,&QTimer::timeout,&loop,&QEventLoop::quit);timer.start(ms);loop.exec();
}
static QList<QQuickItem*> named(QQuickItem *root,const QString &name)
{
    QList<QQuickItem*> result;if(root->objectName()==name)result.append(root);
    for(auto *child:root->childItems())result.append(named(child,name));return result;
}
using Counter=quint64(*)();
struct Samples {
    std::mutex mutex; QElapsedTimer clock; bool recording=false; bool exposureLost=false;
    double syncStart=0,renderStart=0,lastFrame=0,phaseStart=0,firstFrameQueued=0; int frames=0;
    QList<double> intervals,sync,render,gpu,draws;QString gpuName;bool timestamps=false;
    void (*resetDraw)()=nullptr;Counter readDraw=nullptr;
    double now()const{return clock.nsecsElapsed()/1e6;}
};
int main(int argc,char**argv)
{
    const auto self=distribution({1,2,3,4});
    if(self.value("p50").toDouble()!=2 || self.value("p95").toDouble()!=4)return 90;
    if(argc==2 && QByteArray(argv[1])=="--self-test")return 0;
    bool gl=false;for(int i=1;i<argc;++i)gl|=QByteArray(argv[i])=="opengl";
    if(gl){QSurfaceFormat format;format.setVersion(3,3);format.setProfile(QSurfaceFormat::CoreProfile);QSurfaceFormat::setDefaultFormat(format);}
    QQuickWindow::setGraphicsApi(gl?QSGRendererInterface::OpenGL:QSGRendererInterface::Metal);
    QGuiApplication app(argc,argv);app.setApplicationName("Qavsi shadow list study");
    QCommandLineParser cli;cli.addHelpOption();cli.addOptions({
        {"backend","metal or opengl","backend","metal"},
        {"scene","controls, controls-off, blur-same, blur-mixed","scene","controls"},
        {"drawcalls","Separate instrumented draw-call run"},
        {"output","JSON output","file"},{"snapshot","Validation PNG","file"}});cli.process(app);
#ifndef QT_NO_DEBUG
    qCritical()<<"Release build required";return 2;
#endif
    const QString kind=cli.value("scene");
    if(!QStringList{"metal","opengl"}.contains(cli.value("backend")) || !QStringList{"controls","controls-off","blur-same","blur-mixed"}.contains(kind) || cli.value("output").isEmpty())return 2;
    QScreen *left=nullptr;
    for(auto *screen:app.screens())if(screen->geometry().left()<0 && screen->availableGeometry().width()>=1800 && screen->availableGeometry().height()>=950 && (!left||screen->geometry().left()<left->geometry().left()))left=screen;
    if(!left){qCritical()<<"Left display unavailable; no other display will be used";return 3;}
    QQmlApplicationEngine engine;engine.addImportPath(STUDY_IMPORT_DIR);QStringList warnings;
    QObject::connect(&engine,&QQmlEngine::warnings,&engine,[&](const QList<QQmlError>&errors){for(const auto&e:errors)warnings.append(e.toString());});
    engine.setInitialProperties({{"sceneKind",kind},{"previewArea",left->availableGeometry()}});
    engine.load(QUrl::fromLocalFile(QStringLiteral(STUDY_QML_DIR "/Scene.qml")));
    auto *window=engine.rootObjects().isEmpty()?nullptr:qobject_cast<QQuickWindow*>(engine.rootObjects().first());
    if(!window){qCritical()<<warnings;return 4;}
    window->setScreen(left);QQuickGraphicsConfiguration config;config.setTimestamps(true);window->setGraphicsConfiguration(config);
    Samples data;data.clock.start();
    if(cli.isSet("drawcalls")){
        data.resetDraw=reinterpret_cast<void(*)()>(dlsym(RTLD_DEFAULT,"study_draw_reset"));
        data.readDraw=reinterpret_cast<Counter>(dlsym(RTLD_DEFAULT,"study_draw_read"));
        if(!data.resetDraw||!data.readDraw){qCritical()<<"Draw-call counter not injected";return 5;}
    } else if(dlsym(RTLD_DEFAULT,"study_draw_read")){qCritical()<<"Instrumented timing is forbidden";return 5;}
    QObject::connect(window,&QQuickWindow::beforeSynchronizing,window,[&]{std::lock_guard lock(data.mutex);data.syncStart=data.now();},Qt::DirectConnection);
    QObject::connect(window,&QQuickWindow::afterSynchronizing,window,[&]{std::lock_guard lock(data.mutex);if(data.recording)data.sync.append(data.now()-data.syncStart);},Qt::DirectConnection);
    QObject::connect(window,&QQuickWindow::beforeRendering,window,[&]{
        std::lock_guard lock(data.mutex);data.renderStart=data.now();if(data.resetDraw)data.resetDraw();
        if(auto *rhi=window->rhi()){
            data.gpuName=QString::fromUtf8(rhi->driverInfo().deviceName);data.timestamps=rhi->isFeatureSupported(QRhi::Timestamps);
            if(data.recording&&window->swapChain()){
                const double ms=window->swapChain()->currentFrameCommandBuffer()->lastCompletedGpuTime()*1000;
                if(std::isfinite(ms)&&ms>0)data.gpu.append(ms);
            }
        }
    },Qt::DirectConnection);
    QObject::connect(window,&QQuickWindow::afterRendering,window,[&]{
        std::lock_guard lock(data.mutex);if(data.recording){data.render.append(data.now()-data.renderStart);if(data.readDraw)data.draws.append(data.readDraw());}
    },Qt::DirectConnection);
    QObject::connect(window,&QQuickWindow::frameSwapped,window,[&]{
        std::lock_guard lock(data.mutex);const auto now=data.now();if(data.recording){if(data.frames>0)data.intervals.append(now-data.lastFrame);else data.firstFrameQueued=now-data.phaseStart;++data.frames;}data.lastFrame=now;
    },Qt::DirectConnection);
    QObject::connect(window,&QWindow::visibleChanged,window,[&](bool v){if(!v)data.exposureLost=true;});
    window->show();if(!QTest::qWaitForWindowExposed(window,4000))return 6;waitEvents(800);
    if(window->rendererInterface()->graphicsApi()!=(gl?QSGRendererInterface::OpenGL:QSGRendererInterface::Metal) || window->screen()!=left || !left->availableGeometry().contains(window->geometry()))return 6;
    const auto cells=named(window->contentItem(),"study.cell");
    if(cells.size()!=50)return 6;
    for(auto *cell:cells)if(!cell->isVisible() || !QRectF(QPointF(),QSizeF(window->size())).contains(cell->mapRectToScene(cell->boundingRect()).adjusted(-48,-48,48,48)))return 6;
    const bool controls=kind.startsWith("controls");
    const auto native=named(window->contentItem(),"study.control");
    if(native.size()!=(controls?50:0))return 6;
    if(kind=="controls-off"){
        const auto elevations=named(window->contentItem(),"material3.elevation");if(elevations.size()!=50)return 6;
        for(auto *e:elevations)e->setVisible(false);
        waitEvents(150);
    }
    Counter misses=reinterpret_cast<Counter>(dlsym(RTLD_DEFAULT,"study_cache_misses"));
    Counter conv=reinterpret_cast<Counter>(dlsym(RTLD_DEFAULT,"study_convolution_ns"));
    if(!misses||!conv)return 6;
    QJsonArray phases;
    auto measure=[&](const QString&name,int sampleMs,bool once)->bool{
        const auto cacheBefore=misses(),convBefore=conv();const auto cpuStart=std::clock();QElapsedTimer wall;wall.start();
        {std::lock_guard lock(data.mutex);data.intervals.clear();data.sync.clear();data.render.clear();data.gpu.clear();data.draws.clear();data.frames=0;data.firstFrameQueued=0;data.phaseStart=data.now();data.recording=true;}
        bool finished=true;
        if(once){QSignalSpy completion(window,SIGNAL(animationFinished()));QMetaObject::invokeMethod(window,"startOnce");finished=!completion.isEmpty()||completion.wait(4000);}
        else waitEvents(sampleMs);
        const double elapsed=wall.nsecsElapsed()/1e6,cpu=(std::clock()-cpuStart)*1000./CLOCKS_PER_SEC;
        std::lock_guard lock(data.mutex);data.recording=false;
        if(!finished||data.frames<(once?1:20)||!window->isExposed()||data.exposureLost||!warnings.isEmpty() || (data.readDraw && (data.draws.isEmpty()||data.draws.last()<=0))){qCritical()<<"Invalid phase"<<name<<data.frames<<warnings;return false;}
        phases.append(QJsonObject{{"phase",name},{"wallMs",elapsed},{"cpuMs",cpu},{"cpuMsPerFrame",cpu/data.frames},{"frames",data.frames},{"firstFrameQueuedMs",data.firstFrameQueued},
            {"frameMs",distribution(data.intervals)},{"syncElapsedMs",distribution(data.sync)},{"renderElapsedMs",distribution(data.render)},
            {"gpuMs",distribution(data.gpu)},{"drawCalls",distribution(data.draws)},
            {"cornerCacheMisses",double(misses()-cacheBefore)},{"convolutionMs",double(conv()-convBefore)/1e6}});
        return true;
    };
    if(!controls){
        if(!measure("first-0-to-12",0,true))return 7;
        // Populate every half-pixel sigma bucket outside the timed region.
        for(int bucket=1;bucket<=29;++bucket){window->setProperty("phase",bucket*.5/14.4);waitEvents(34);}
        window->setProperty("phase",.001);window->setProperty("startPhase",.001);waitEvents(80);
        const auto cached=misses();
        if(!measure("warm-retained-cache",0,true))return 7;
        if(misses()!=cached){qCritical()<<"Warm phase generated new corner textures";return 7;}
        window->setProperty("phase",0.0);window->setProperty("startPhase",0.0);waitEvents(100);
        if(!measure("repeat-after-zero",0,true))return 7;
        window->setProperty("cycling",true);window->setProperty("heartbeat",true);waitEvents(800);
    } else {window->setProperty("heartbeat",true);waitEvents(800);}
    if(!measure("steady",cli.isSet("drawcalls")?600:4000,false))return 7;
    window->setProperty("cycling",false);window->setProperty("heartbeat",false);window->setProperty("phase",.5);waitEvents(100);
    const auto image=window->grabWindow();if(image.isNull())return 8;
    int shadowPixels=0;
    for(auto *cell:cells){const auto pos=cell->mapToScene(QPointF(cell->width()/2,cell->height()+1))*image.devicePixelRatio();if(window->color().red()-image.pixelColor(qRound(pos.x()),qRound(pos.y())).red()>=2)++shadowPixels;}
    if(cli.isSet("snapshot")&&!image.save(cli.value("snapshot")))return 8;
    if(shadowPixels!=(kind=="controls-off"?0:50)){
        qCritical()<<"Shadow pixel gate failed"<<shadowPixels;
        const auto elevations=named(window->contentItem(),"material3.elevation");
        qCritical()<<"Elevation count"<<elevations.size();
        if(!elevations.isEmpty()){auto *e=elevations.first();qCritical()<<e->size()<<e->mapToScene(QPointF())<<e->property("targetElevation")<<e->property("rendererName")<<e->property("hardware")<<e->isVisible();}
        return 8;
    }
    QJsonObject output{{"scene",kind},{"backend",cli.value("backend")},{"qt",qVersion()},{"os",QSysInfo::prettyProductName()},
        {"gpu",data.gpuName},{"gpuTimestampsSupported",data.timestamps},{"build","Release"},{"count",50},{"nativeControls",native.size()},
        {"shadowPixelCount",shadowPixels},{"screen",left->name()},{"window",QJsonArray{window->x(),window->y(),window->width(),window->height()}},
        {"refreshHz",left->refreshRate()},{"dpr",window->devicePixelRatio()},{"drawCallDiagnostic",cli.isSet("drawcalls")},{"qmlWarnings",warnings.size()},
        {"gpuTiming","asynchronous completed-frame QRhi times; not paired to current CPU frame"},
        {"cacheProbe","Frozen copy only: atomic miss counter + steady_clock around convolution; production unchanged"},
        {"warmPolicy","All sigma buckets preloaded; 0.012dp start retains cache ownership; zero misses required"},{"phases",phases}};
    QFile file(cli.value("output"));if(!file.open(QIODevice::WriteOnly))return 9;file.write(QJsonDocument(output).toJson());return 0;
}
