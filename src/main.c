#include "bmp.h"
#include "image.h"
#include "log.h"
#include <stdio.h>

static unsigned char sat(uint64_t x) {
  if (x < 256)
    return x;
  return 255;
}

float const matrix[9] = {
    /* Считаем сразу в BGR */
    .131f, .543f, .272f, /**/ .168f, .686f, .349f, /**/ .189f, .769f, .393f};

static void sepia_one(struct Rgb8 *pixel) {
  struct Rgb8 old = *pixel;
  pixel->r = sat(old.r * matrix[0] + old.g * matrix[1] + old.b * matrix[2]);
  pixel->g = sat(old.r * matrix[3] + old.g * matrix[4] + old.b * matrix[5]);
  pixel->b = sat(old.r * matrix[6] + old.g * matrix[7] + old.b * matrix[8]);
}

extern void sepia_asm(float const *matrix, struct Rgb8 *pixels, size_t size);

void sepia_sse(struct ImageRgb8 *img) {
  size_t i;
  size_t full_size = img->width * img->height;
  size_t sse_num = full_size / 4;
  if (sse_num)
    sepia_asm(matrix, img->pixels, sse_num);
  for (i = 4 * sse_num; i < full_size; ++i)
    sepia_one(&img->pixels[i]);
}

void sepia_no_sse(struct ImageRgb8 *img) {
  size_t i, full_size = img->width * img->height;
  for (i = 0; i < full_size; ++i)
    sepia_one(&img->pixels[i]);
}

int main(int argc, char **argv) {
  struct ImageRgb8 img;

  if (argc < 3) {
    log_err("Not enough arguments");
    return __LINE__;
  }

  if (from_bmp_path(&img, argv[1]))
    return __LINE__;

#define USE_SSE
#ifndef USE_SSE
  sepia_no_sse(&img);
#else
  sepia_sse(&img);
#endif
  /* image_bgr_to_rgb(&img); */
  /* image_rgb_to_bgr(&img); */

  if (to_bmp_path(&img, argv[2]))
    return __LINE__;

  destroy_image(&img);
  return 0;
}
