#include "bmp.h"
#include "image.h"
#include "log.h"
#include <stdio.h>

int main(int argc, char **argv) {
  struct ImageRgb8 src;
  struct ImageRgb8 dst;

  if (argc < 3) {
    log_err("Not enough arguments");
    return __LINE__;
  }

  if (from_bmp_path(&src, argv[1]))
    return __LINE__;

  /* BMP сохраняет изображения в BGR и снизу вверх */
  /* image_bgr_to_rgb(&src);
  image_mirror_v(&src);
  image_rotate_clockwise(&src, &dst);

  image_bgr_to_rgb(&dst);
  image_mirror_v(&dst); */
  if (image_rotate_counter_clockwise(&src, &dst))
    return __LINE__;
  if (to_bmp_path(&dst, argv[2]))
    return __LINE__;

  destroy_image(&src);
  destroy_image(&dst);
  return 0;
}
