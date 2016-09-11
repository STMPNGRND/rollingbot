#include <iostream>
#include <string>
#include <complex>

#include <alsa/asoundlib.h>
#include <fftw3.h>
#include <Eigen/Dense>

#include <sndfile.hh>

using namespace std;
using namespace Eigen;

#include "alsa_audio.hpp"

void init_alsa(AlsaAudio &alsa, string dev_name)
{
  alsa.open(dev_name.c_str(), SND_PCM_STREAM_CAPTURE);

  alsa.set(snd_pcm_hw_params_set_access, SND_PCM_ACCESS_RW_INTERLEAVED);
  alsa.set(snd_pcm_hw_params_set_format, SND_PCM_FORMAT_FLOAT_LE);

  alsa.set(snd_pcm_hw_params_set_rate,     16000, 0);
  alsa.set(snd_pcm_hw_params_set_channels,     2   );
  alsa.set(snd_pcm_hw_params_set_periods,      3, 0);

  snd_pcm_uframes_t nbuffer = 2048;
  alsa.set(snd_pcm_hw_params_set_buffer_size_near, &nbuffer);

  alsa.prepare();  
}

int main(int argc, char *argv[])
{
  // parameters
  if (argc < 2) {
    cout << argv[0] << " [string:dev_name]" << endl;
    return 1;
  }
  int n_frame = 512;
  int n_it = 10;
  int n_resolution = 9;

  float mic_distance = 0.075;

  // output
  ArrayXf dsbf(n_resolution);

  // initialize ALSA
  AlsaAudio alsa;
  init_alsa(alsa, string(argv[1]));

  ArrayXXf rec(2, n_frame);

  SndfileHandle sfr(argv[2]);

  // initialize FFT
  int n_freq = n_frame / 2 + 1;

  ArrayXXcf spec(n_freq, 2);

  ArrayXXf hamming(1, n_frame);
  for (int n=0;n<n_frame;n++) hamming(n) = 0.54 - 0.46 * cos(2 * M_PI * (float)n / (n_frame-1));
  ArrayXXf fft_buf(1, n_frame);
  fftwf_plan fft_plan_l = fftwf_plan_dft_r2c_1d(n_frame, fft_buf.data(), (fftwf_complex*)spec.col(0).data(), FFTW_ESTIMATE);
  fftwf_plan fft_plan_r = fftwf_plan_dft_r2c_1d(n_frame, fft_buf.data(), (fftwf_complex*)spec.col(1).data(), FFTW_ESTIMATE);

  // initialize steering vector
  ArrayXXcf st_vec(n_freq, n_resolution);
  for (int d=0;d<n_resolution;d++) {
    double tdoa = mic_distance / 340. * sin(M_PI * (float)d / (n_resolution - 1) - 0.5 * M_PI);
    // cout << tdoa << endl;
    for (int f=0;f<n_freq;f++) {
      st_vec(f, d) = exp(complex<float>(0, 2*M_PI * 8000 * (float)f / (n_freq-1) * tdoa));
    }
  }

  IOFormat fmt(3, DontAlignCols, ",");

  // main loop
  while (true) {
    dsbf.setZero();

    for (int it=0;it<n_it;it++) {
      // capture recording
      alsa.read(rec, n_frame);
      sfr.readf(rec.data(), n_frame);
      
      // conduct FFT
      fft_buf = hamming * rec.row(0);
      fftwf_execute(fft_plan_l);
      
      fft_buf = hamming * rec.row(1);
      fftwf_execute(fft_plan_r);
      
      // conduct DSBF
      dsbf += (spec.col(0).replicate(1, n_resolution) + st_vec * spec.col(1).replicate(1, n_resolution)).abs2().block(10, 0, 220, n_resolution).colwise().mean().transpose();
      // dsbf += spec.col(0) * spec.col(1).conjugate();
    }

    // output DSBF result
    dsbf = (dsbf - dsbf.mean()).unaryExpr([](float x){ return x > 0 ? x : 0; });
    // cout << dsbf.transpose().format(fmt) << endl;
    cout << "{\"data\":[" << dsbf.transpose().format(fmt) << "]}" << endl;
  }
}
