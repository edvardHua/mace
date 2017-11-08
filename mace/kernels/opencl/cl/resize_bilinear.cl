__kernel void resize_bilinear_nocache(__global const float *input, /* n * c, h, w */
                                      __global float *output /* n * c, h, w */,
                                      __private const float height_scale,
                                      __private const float width_scale,
                                      __private const int in_height,
                                      __private const int in_width) {
  const int c = get_global_id(0);
  const int h = get_global_id(1);
  const int w = get_global_id(2);
  const int channels = get_global_size(0);
  const int height = get_global_size(1);
  const int width = get_global_size(2);

  const float h_in = h * height_scale;
  const float w_in = w * width_scale;
  const int h_lower = max(0, (int) floor(h_in));
  const int h_upper = min(in_height - 1, h_lower + 1);
  const int w_lower = max(0, (int) floor(w_in));
  const int w_upper = min(in_width - 1, w_lower + 1);

  const float h_lerp = h_in - h_lower;
  const float w_lerp = w_in - w_lower;

  const float *input_base = input + c * in_height * in_width;
  float *output_base = output + c * height * width;

  float top_left = input_base[h_lower * in_width + w_lower];
  float top_right = input_base[h_lower * in_width + w_upper];
  float bottom_left = input_base[h_upper * in_width + w_lower];
  float bottom_right = input_base[h_upper * in_width + w_upper];

  const float top = top_left + (top_right - top_left) * w_lerp;
  const float bottom = bottom_left + (bottom_right - bottom_left) * w_lerp;
  output_base[h * width + w] = top + (bottom - top) * h_lerp;
}
