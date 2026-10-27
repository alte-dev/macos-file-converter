#ifndef WebPBridge_h
#define WebPBridge_h

#include <stdlib.h>
#include <stdint.h>
#include "webp/encode.h"

/// Encodes an RGBA pixel buffer into a highly optimized WebP byte buffer for websites.
/// Uses method=6, multi-pass entropy analysis, spatial noise shaping (SNS),
/// autofilter, and Sharp YUV for maximum file size reduction without visual quality loss.
static inline int AlteEncodeWebP(
    const uint8_t* rgba,
    int width,
    int height,
    int stride,
    float quality,
    uint8_t** outBuffer,
    size_t* outSize
) {
    if (!rgba || width <= 0 || height <= 0 || !outBuffer || !outSize) {
        return 0;
    }

    WebPConfig config;
    if (!WebPConfigPreset(&config, WEBP_PRESET_PHOTO, quality)) {
        return 0;
    }

    if (quality >= 99.5f) {
        // Lossless WebP with maximum compression effort
        WebPConfigLosslessPreset(&config, 9);
        config.thread_level = 1;
    } else {
        // Smart Website Lossy Optimization: smallest possible size with imperceptible quality loss
        config.quality = quality;
        config.method = 6;              // Max compression analysis (0=fast, 6=max compression/quality ratio)
        config.pass = 6;                // Multi-pass entropy optimization
        config.sns_strength = 80;       // Spatial Noise Shaping to preserve sharp edges & textures
        config.filter_strength = 60;    // Deblocking filter strength
        config.filter_sharpness = 0;    // Sharpest filtering
        config.autofilter = 1;          // Auto-adjust filter strength per macroblock
        config.use_sharp_yuv = 1;       // Crisp RGB->YUV420 conversion (prevents color bleeding on edges/text)
        config.alpha_compression = 1;   // Compress transparency channel
        config.alpha_quality = 90;      // High-precision transparency
        config.thread_level = 1;        // Enable multi-threaded encoding
    }

    if (!WebPValidateConfig(&config)) {
        return 0;
    }

    WebPPicture pic;
    if (!WebPPictureInit(&pic)) {
        return 0;
    }

    pic.use_argb = 1;
    pic.width = width;
    pic.height = height;

    // Unpremultiply CoreGraphics premultipliedLast RGBA buffer for semi-transparent pixels
    size_t bufSize = (size_t)stride * (size_t)height;
    uint8_t* unpremultiplied = (uint8_t*)malloc(bufSize);
    if (!unpremultiplied) {
        WebPPictureFree(&pic);
        return 0;
    }
    for (int y = 0; y < height; ++y) {
        const uint8_t* srcRow = rgba + y * stride;
        uint8_t* dstRow = unpremultiplied + y * stride;
        for (int x = 0; x < width * 4; x += 4) {
            uint8_t a = srcRow[x + 3];
            if (a == 255 || a == 0) {
                dstRow[x + 0] = srcRow[x + 0];
                dstRow[x + 1] = srcRow[x + 1];
                dstRow[x + 2] = srcRow[x + 2];
                dstRow[x + 3] = a;
            } else {
                uint32_t r = ((uint32_t)srcRow[x + 0] * 255 + (a >> 1)) / a;
                uint32_t g = ((uint32_t)srcRow[x + 1] * 255 + (a >> 1)) / a;
                uint32_t b = ((uint32_t)srcRow[x + 2] * 255 + (a >> 1)) / a;
                dstRow[x + 0] = (uint8_t)(r > 255 ? 255 : r);
                dstRow[x + 1] = (uint8_t)(g > 255 ? 255 : g);
                dstRow[x + 2] = (uint8_t)(b > 255 ? 255 : b);
                dstRow[x + 3] = a;
            }
        }
    }

    int imported = WebPPictureImportRGBA(&pic, unpremultiplied, stride);
    free(unpremultiplied);
    if (!imported) {
        WebPPictureFree(&pic);
        return 0;
    }

    WebPMemoryWriter writer;
    WebPMemoryWriterInit(&writer);
    pic.writer = WebPMemoryWrite;
    pic.custom_ptr = &writer;

    int ok = WebPEncode(&config, &pic);
    WebPPictureFree(&pic);

    if (!ok) {
        WebPMemoryWriterClear(&writer);
        return 0;
    }

    *outBuffer = writer.mem;
    *outSize = writer.size;
    return 1;
}

static inline void AlteFreeWebP(uint8_t* buffer) {
    WebPFree(buffer);
}

#endif /* WebPBridge_h */
