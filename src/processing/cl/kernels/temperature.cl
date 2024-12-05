// ported by Renaud Bédard (@renaudbedard) from original code from Tanner
// Helland
// http://www.tannerhelland.com/4435/convert-temperature-rgb-algorithm-code/

// color space functions translated from HLSL versions on Chilli Ant (by Ian
// Taylor) http://www.chilliant.com/rgb2hsv.html

// licensed and released under Creative Commons 3.0 Attribution
// https://creativecommons.org/licenses/by/3.0/

// https://www.shadertoy.com/view/lsSXW1

// playing with this value tweaks how dim or bright the resulting image is
// #define LUMINANCE_PRESERVATION 0.75f

#define EPSILON 1e-10

float saturate(float v) { return clamp(v, 0.0f, 1.0f); }
float3 saturate_f3(float3 v) {
  return clamp(v, (float3)(0.0f), (float3)(1.0f));
}

float3 ColorTemperatureToRGB(float temperatureInKelvins) {
  float3 retColor;

  temperatureInKelvins =
      clamp(temperatureInKelvins, 1000.0f, 40000.0f) / 100.0f;

  if (temperatureInKelvins <= 66.0f) {
    retColor.x = 1.0f;
    retColor.y = saturate(0.39008157876901960784f * log(temperatureInKelvins) -
                          0.63184144378862745098f);
  } else {
    float t = temperatureInKelvins - 60.0f;
    retColor.x = saturate(1.29293618606274509804f * pow(t, -0.1332047592f));
    retColor.y = saturate(1.12989086089529411765f * pow(t, -0.0755148492f));
  }

  if (temperatureInKelvins >= 66.0f)
    retColor.z = 1.0f;
  else if (temperatureInKelvins <= 19.0f)
    retColor.z = 0.0f;
  else
    retColor.z =
        saturate(0.54320678911019607843f * log(temperatureInKelvins - 10.0f) -
                 1.19625408914f);

  return retColor;
}

float Luminance(float3 color) {
  float fmin = min(min(color.x, color.y), color.z);
  float fmax = max(max(color.x, color.y), color.z);
  return (fmax + fmin) / 2.0f;
}

float3 HUEtoRGB(float H) {
  float R = fabs(H * 6.0f - 3.0f) - 1.0f;
  float G = 2.0f - fabs(H * 6.0f - 2.0f);
  float B = 2.0f - fabs(H * 6.0f - 4.0f);
  return saturate_f3((float3)(R, G, B));
}

float3 HSLtoRGB(float3 HSL) {
  float3 RGB = HUEtoRGB(HSL.x);
  float C = (1.0f - fabs(2.0f * HSL.z - 1.0f)) * HSL.y;
  return (RGB - 0.5f) * C + (float3)(HSL.z);
}

float3 RGBtoHCV(float3 RGB) {
  // Based on work by Sam Hocevar and Emil Persson
  float4 P = (RGB.y < RGB.z) ? (float4)(RGB.z, RGB.y, -1.0f, 2.0f / 3.0f)
                             : (float4)(RGB.y, RGB.z, 0.0f, -1.0f / 3.0f);
  float4 Q = (RGB.x < P.x) ? (float4)(P.x, P.y, P.w, RGB.x)
                           : (float4)(RGB.x, P.y, P.z, P.x);
  float C = Q.x - fmin(Q.w, Q.y);
  float H = fabs((Q.w - Q.y) / (6.0f * C + EPSILON) + Q.z);
  return (float3)(H, C, Q.x);
}

float3 RGBtoHSL(float3 RGB) {
  float3 HCV = RGBtoHCV(RGB);
  float L = HCV.z - HCV.y * 0.5f;
  float S = HCV.y / (1.0f - fabs(L * 2.0f - 1.0f) + EPSILON);
  return (float3)(HCV.x, S, L);
}

__constant sampler_t sampler = CLK_NORMALIZED_COORDS_FALSE |
                               CLK_ADDRESS_CLAMP_TO_EDGE | CLK_FILTER_NEAREST;

__kernel void temperature(__read_only image2d_t src,
                          __write_only image2d_t dest, const float temperature,
                          const float factor,
                          const float luminance_preservation) {
  const int2 pos = {get_global_id(0), get_global_id(1)};
  float4 pixel = read_imagef(src, sampler, pos);

  float3 image = pixel.xyz;
  float3 colorTempRGB = ColorTemperatureToRGB(temperature);

  float originalLuminance = Luminance(image);
  float3 blended = mix(image, image * colorTempRGB, factor);
  float3 resultHSL = RGBtoHSL(blended);
  float3 luminancePreservedRGB =
      HSLtoRGB((float3)(resultHSL.x, resultHSL.y, originalLuminance));
  float3 finalColor =
      mix(blended, luminancePreservedRGB, luminance_preservation);
  // float3 finalColor = luminancePreservedRGB;

  write_imagef(dest, pos, (float4)(finalColor, pixel.w));
}