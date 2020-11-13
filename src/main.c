#include "bmp.h"
#include "image.h"
#include "log.h"
#include <stdio.h>

static unsigned char sat(uint64_t x) {
  if (x < 256)
    return x;
  return 255;
}

float const sepia_matrix[3][3] = {
    /* Считаем сразу в BGR */
    {.131f, .543f, .272f},
    {.168f, .686f, .349f},
    {.189f, .769f, .393f}};

static void sepia_one(struct Rgb8 *pixel) {
  struct Rgb8 old = *pixel;
  pixel->r = sat(old.r * sepia_matrix[0][0] + old.g * sepia_matrix[0][1] +
                 old.b * sepia_matrix[0][2]);
  pixel->g = sat(old.r * sepia_matrix[1][0] + old.g * sepia_matrix[1][1] +
                 old.b * sepia_matrix[1][2]);
  pixel->b = sat(old.r * sepia_matrix[2][0] + old.g * sepia_matrix[2][1] +
                 old.b * sepia_matrix[2][2]);
}

extern void sepia_asm(struct Rgb8 *pixels, size_t size);

void sepia_sse(struct ImageRgb8 *img) {
  size_t i;
  size_t full_size = img->width * img->height;
  size_t sse_num = full_size / 4;
  sepia_asm(img->pixels, sse_num);
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

  /* image_bgr_to_rgb(&img); */
  sepia_no_sse(&img);
  /* image_rgb_to_bgr(&img); */

  if (to_bmp_path(&img, argv[2]))
    return __LINE__;

  destroy_image(&img);
  return 0;
}
