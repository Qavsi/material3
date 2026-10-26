// Adapted from QmlMaterial (MIT), copyright (c) 2024-2025 hypengw.
// Skia-derived shadow math (BSD-3-Clause); see third_party/shadow-reference.
#pragma once

#include <QSGMaterial>
#include <QSGTexture>
#include <memory>

class QQuickWindow;

namespace qavsi::shadow {

struct ShadowTexture {
    std::unique_ptr<QSGTexture> texture;
};

std::shared_ptr<ShadowTexture> acquireShadowTexture(QQuickWindow *window);

class ShadowMaterial final : public QSGMaterial {
public:
    explicit ShadowMaterial(std::shared_ptr<ShadowTexture> texture);
    QSGMaterialType *type() const override;
    QSGMaterialShader *createShader(QSGRendererInterface::RenderMode) const override;
    int compare(const QSGMaterial *other) const override;
    QSGTexture *texture() const;

private:
    std::shared_ptr<ShadowTexture> m_texture;
};

class ShadowShader final : public QSGMaterialShader {
public:
    ShadowShader();
    bool updateUniformData(RenderState &state, QSGMaterial *newMaterial,
                           QSGMaterial *oldMaterial) override;
    void updateSampledImage(RenderState &state, int binding, QSGTexture **texture,
                            QSGMaterial *newMaterial, QSGMaterial *oldMaterial) override;
};

} // namespace qavsi::shadow
