// Adapted from QmlMaterial 229bc3e6 (MIT), copyright (c) 2024-2025 hypengw.
// Skia-derived Gaussian model (BSD-3-Clause); see third_party/shadow-reference.
#pragma once

#include <QSGMaterial>
#include <QSGTexture>
#include <QVector2D>
#include <QVector4D>
#include <array>
#include <list>
#include <memory>
#include <unordered_map>

class QQuickWindow;

namespace qavsi::shadow::blur {

struct CornerTexture {
    std::unique_ptr<QSGTexture> texture;
    float margin = 0;
    float extent = 0;
    float sigma = 0;
};

class TextureCache {
public:
    explicit TextureCache(QQuickWindow *window);
    bool initialize();
    QSGTexture *profile() const { return m_profile.get(); }
    std::shared_ptr<CornerTexture> corner(float sigma, float radius);

private:
    struct Entry {
        std::shared_ptr<CornerTexture> texture;
        std::list<quint64>::iterator recency;
        std::size_t bytes;
    };
    QQuickWindow *m_window;
    std::unique_ptr<QSGTexture> m_profile;
    std::unordered_map<quint64, Entry> m_corners;
    std::list<quint64> m_recency;
    std::size_t m_cachedBytes = 0;
};

std::shared_ptr<TextureCache> acquireTextureCache(QQuickWindow *window);
bool safeCutout(float sigma, float radius);

class Material final : public QSGMaterial {
public:
    explicit Material(std::shared_ptr<TextureCache> cache);
    QSGMaterialType *type() const override;
    QSGMaterialShader *createShader(QSGRendererInterface::RenderMode) const override;
    int compare(const QSGMaterial *other) const override;
    bool setAppearance(float newSigma, QVector2D newSize, QVector4D newRadii);
    QSGTexture *profileTexture() const { return m_cache->profile(); }
    const CornerTexture *cornerTexture(int index) const { return m_corners[index].get(); }

    float sigma = 0;
    QVector2D rectSize;
    QVector4D radii;

private:
    std::shared_ptr<TextureCache> m_cache;
    std::array<std::shared_ptr<CornerTexture>, 4> m_corners;
};

class Shader final : public QSGMaterialShader {
public:
    Shader();
    bool updateUniformData(RenderState &state, QSGMaterial *newMaterial,
                           QSGMaterial *oldMaterial) override;
    void updateSampledImage(RenderState &state, int binding, QSGTexture **texture,
                            QSGMaterial *newMaterial, QSGMaterial *oldMaterial) override;
};

} // namespace qavsi::shadow::blur
