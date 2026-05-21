#!/usr/bin/env python3
"""
SpectgramDemo — Spectrogram Interactive Demo

Demonstrates how window type, window size, FFT size, and overlap
affect the spectrogram of linear chirps, sinusoids, or audio files.

Original MATLAB version (specgramdemo ver. 2.82), Georgia Tech.
Python / PyQt6 port, 2026.
"""

import sys
import os
import numpy as np
from scipy.signal.windows import hann, hamming, bartlett
import matplotlib
matplotlib.use('QtAgg')
from matplotlib.backends.backend_qtagg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure

from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget,
    QVBoxLayout, QHBoxLayout, QFormLayout,
    QLabel, QLineEdit, QSlider, QPushButton, QComboBox,
    QGroupBox, QStackedWidget, QSizePolicy, QFileDialog,
    QButtonGroup, QRadioButton,
)
from PyQt6.QtCore import Qt

VERSION = 'specgramdemo ver. 2.82'

# Default parameters
FS_DEFAULT       = 8000
NFFT_DEFAULT     = 512
WINSIZE_DEFAULT  = 256   # nfft / 2
NOVERLAP_DEFAULT = 128   # 50 % of window
DRANGE_DEFAULT   = 50
CHIRP_RATE_DEF   = 500.0
F0_DEF           = 100.0
T_END            = 4.04

WINDOW_TYPES  = ['Bartlett', 'Hamming', 'Hann', 'Rectangular']
OVERLAP_OPTS  = ['0 %', '25 %', '50 %', '75 %']   # % of windowsize
OVERLAP_FRACS = [0.0, 0.25, 0.50, 0.75]
DRANGE_OPTS   = [30, 40, 50, 60, 70, 80]
CMAP_NAMES    = ['Inverted Gray', 'Gray', 'Hot', 'Jet', 'Viridis']
CMAP_MPL      = ['gray_r',       'gray', 'hot', 'jet', 'viridis']


# ---------------------------------------------------------------------------
# Signal / STFT functions
# ---------------------------------------------------------------------------

def make_window(name: str, size: int) -> np.ndarray:
    n = name.lower()
    if n == 'hann':      return hann(size)
    if n == 'hamming':   return hamming(size)
    if n == 'bartlett':  return bartlett(size)
    return np.ones(size)   # rectangular


def chirp_signal(t: np.ndarray, f0: float, chirp_rate: float) -> np.ndarray:
    """Linear chirp: cos(π·α·t² + 2π·f0·t)."""
    return np.cos((np.pi * chirp_rate * t + 2 * np.pi * f0) * t)


def sum_of_sinusoids(amps, freqs, phases, t):
    s = np.zeros_like(t)
    for A, F, P in zip(amps, freqs, phases):
        s += A * np.sin(2 * np.pi * F * t + P)
    return s


def compute_stft(xx, nfft, fs, window, noverlap):
    """STFT matching spectgr_RWS_GUI.m; returns (B, F, T)."""
    L     = len(window)
    shift = L - noverlap
    xx    = np.asarray(xx, dtype=float).ravel()
    nseg  = 1 + (len(xx) - L) // shift
    B     = np.zeros((nfft // 2 + 1, nseg), dtype=complex)
    for i in range(nseg):
        n0       = i * shift
        B[:, i]  = np.fft.rfft(window * xx[n0: n0 + L], nfft)
    F = np.arange(nfft // 2 + 1) / nfft * fs
    T = (L / 2 + shift * np.arange(nseg)) / fs
    return B, F, T


def to_db(B, drange):
    BA    = 20 * np.log10(np.abs(B) + 1e-12)
    BAmax = BA.max()
    return np.clip(BA, BAmax - drange, BAmax)


# ---------------------------------------------------------------------------
# Main window
# ---------------------------------------------------------------------------

class SpectgramWindow(QMainWindow):

    def __init__(self):
        super().__init__()
        self.setWindowTitle(VERSION)

        # STFT parameters
        self.fs       = FS_DEFAULT
        self.nfft     = NFFT_DEFAULT
        self.winsize  = WINSIZE_DEFAULT
        self.noverlap = NOVERLAP_DEFAULT
        self.drange   = DRANGE_DEFAULT
        self.win_type = 'Hann'
        self.cmap_idx = 0          # Inverted Gray

        # Display state
        self.three_d  = False
        self.ft_mode  = False
        self.az, self.el = 0.0, 90.0

        # Signal state
        self.signal_type = 'LinearChirp'
        self.chirp_rate  = CHIRP_RATE_DEF
        self.f0          = F0_DEF
        self.amplitudes  = [1.0, 1.0]
        self.sinufreqs   = [500.0, 1500.0]
        self.phases      = [0.0, 0.0]

        # Audio
        self.audio_data = None
        self.audio_fs   = FS_DEFAULT

        # Computed signal
        self.t      = np.arange(0, T_END + 1 / self.fs, 1 / self.fs)
        self.signal = chirp_signal(self.t, self.f0, self.chirp_rate)

        self._build_ui()
        self._replot()

    # ------------------------------------------------------------------
    # UI
    # ------------------------------------------------------------------

    def _build_ui(self):
        central = QWidget()
        self.setCentralWidget(central)
        root = QHBoxLayout(central)
        root.setContentsMargins(4, 4, 4, 4)
        root.setSpacing(6)

        # ---- Left: plot area ----
        left = QVBoxLayout()
        root.addLayout(left, stretch=1)

        self.fig    = Figure(figsize=(7, 5))
        self.canvas = FigureCanvas(self.fig)
        self.canvas.setSizePolicy(QSizePolicy.Policy.Expanding,
                                  QSizePolicy.Policy.Expanding)
        left.addWidget(self.canvas, stretch=1)

        # Button row under the plot
        brow = QHBoxLayout()
        left.addLayout(brow)
        self.btn_play = QPushButton('▶ Play')
        self.btn_3d   = QPushButton('3D View')
        self.btn_3d.setCheckable(True)
        self.btn_ft   = QPushButton('FT at Click')
        self.btn_ft.setCheckable(True)
        self.lbl_status = QLabel('Spectrogram of Linear Chirp')
        self.lbl_status.setStyleSheet('color: blue;')
        self.lbl_status.setWordWrap(True)
        for w in [self.btn_play, self.btn_3d, self.btn_ft]:
            brow.addWidget(w)
        brow.addWidget(self.lbl_status, stretch=1)

        # ---- Right: controls ----
        right = QVBoxLayout()
        right.setSpacing(6)
        root.addLayout(right)

        # Signal type selector
        sig_grp = QGroupBox('Signal Type')
        sig_v = QVBoxLayout(sig_grp)
        self._sig_bg  = QButtonGroup(self)
        self._rb_chirp = QRadioButton('Linear Chirp')
        self._rb_sinus = QRadioButton('Sum of Sinusoids')
        self._rb_audio = QRadioButton('User Audio')
        self._rb_chirp.setChecked(True)
        for i, rb in enumerate([self._rb_chirp, self._rb_sinus, self._rb_audio]):
            self._sig_bg.addButton(rb, i)
            sig_v.addWidget(rb)
        right.addWidget(sig_grp)

        # Stacked signal-parameter panels
        self._stack = QStackedWidget()
        right.addWidget(self._stack)
        self._build_chirp_panel()
        self._build_sinus_panel()
        self._build_audio_panel()

        # STFT parameters
        stft_grp = QGroupBox('STFT Parameters')
        sf = QFormLayout(stft_grp)
        sf.setRowWrapPolicy(QFormLayout.RowWrapPolicy.WrapAllRows)

        self._cbo_win = QComboBox()
        self._cbo_win.addItems(WINDOW_TYPES)
        self._cbo_win.setCurrentText('Hann')
        sf.addRow('Window type:', self._cbo_win)

        self._edt_nfft = QLineEdit(str(self.nfft))
        self._edt_nfft.setMaximumWidth(80)
        sf.addRow('NFFT:', self._edt_nfft)

        self._edt_winsize = QLineEdit(str(self.winsize))
        self._edt_winsize.setMaximumWidth(80)
        sf.addRow('Window size:', self._edt_winsize)

        self._sld_win = QSlider(Qt.Orientation.Horizontal)
        self._sld_win.setRange(1, self.nfft - 1)
        self._sld_win.setValue(self.winsize)
        self._sld_win.setMinimumWidth(140)
        sf.addRow('', self._sld_win)

        self._cbo_overlap = QComboBox()
        self._cbo_overlap.addItems(OVERLAP_OPTS)
        self._cbo_overlap.setCurrentIndex(2)  # 50 %
        sf.addRow('Overlap %:', self._cbo_overlap)

        self._edt_noverlap = QLineEdit(str(self.noverlap))
        self._edt_noverlap.setMaximumWidth(80)
        sf.addRow('Overlap N:', self._edt_noverlap)

        self._edt_fs = QLineEdit(str(self.fs))
        self._edt_fs.setMaximumWidth(80)
        sf.addRow('Fs (Hz):', self._edt_fs)

        right.addWidget(stft_grp)

        # Display parameters
        disp_grp = QGroupBox('Display')
        df = QFormLayout(disp_grp)

        self._cbo_cmap = QComboBox()
        self._cbo_cmap.addItems(CMAP_NAMES)
        self._cbo_cmap.setCurrentIndex(0)
        df.addRow('Colormap:', self._cbo_cmap)

        self._cbo_drange = QComboBox()
        self._cbo_drange.addItems([f'{d} dB' for d in DRANGE_OPTS])
        self._cbo_drange.setCurrentIndex(2)  # 50 dB
        df.addRow('Dyn range:', self._cbo_drange)

        right.addWidget(disp_grp)
        right.addStretch()

        # Signals → slots
        self._sig_bg.idToggled.connect(self._signal_type_toggled)
        self.btn_play.clicked.connect(self._play)
        self.btn_3d.toggled.connect(self._toggle_3d)
        self.btn_ft.toggled.connect(self._toggle_ft)
        self._cbo_win.currentTextChanged.connect(lambda t: self._param_changed(win_type=t))
        self._sld_win.valueChanged.connect(self._winsize_slider)
        self._edt_winsize.returnPressed.connect(self._winsize_edit)
        self._cbo_overlap.currentIndexChanged.connect(self._overlap_pct_changed)
        self._edt_noverlap.returnPressed.connect(self._noverlap_edit)
        self._edt_nfft.returnPressed.connect(self._nfft_edit)
        self._edt_fs.returnPressed.connect(self._fs_edit)
        self._cbo_cmap.currentIndexChanged.connect(lambda i: self._param_changed(cmap_idx=i))
        self._cbo_drange.currentIndexChanged.connect(
            lambda i: self._param_changed(drange=DRANGE_OPTS[i]))
        self.canvas.mpl_connect('button_press_event', self._on_click)

    def _build_chirp_panel(self):
        w = QWidget()
        f = QFormLayout(w)
        self._edt_f0        = QLineEdit(str(self.f0))
        self._edt_chirprate = QLineEdit(str(self.chirp_rate))
        f.addRow('Start freq (Hz):', self._edt_f0)
        f.addRow('Chirp rate (Hz/s):', self._edt_chirprate)
        self._edt_f0.returnPressed.connect(self._chirp_param_changed)
        self._edt_chirprate.returnPressed.connect(self._chirp_param_changed)
        self._stack.addWidget(w)   # index 0

    def _build_sinus_panel(self):
        w = QWidget()
        f = QFormLayout(w)
        self._edt_amp   = QLineEdit('1 1')
        self._edt_freq  = QLineEdit('500 1500')
        self._edt_phase = QLineEdit('0 0')
        f.addRow('Amplitudes:', self._edt_amp)
        f.addRow('Freqs (Hz):', self._edt_freq)
        f.addRow('Phases (rad):', self._edt_phase)
        for e in [self._edt_amp, self._edt_freq, self._edt_phase]:
            e.returnPressed.connect(self._sinus_param_changed)
        self._stack.addWidget(w)   # index 1

    def _build_audio_panel(self):
        w = QWidget()
        v = QVBoxLayout(w)
        v.setSpacing(4)
        self._btn_load    = QPushButton('Load WAV…')
        self._lbl_audio   = QLabel('(no file loaded)')
        self._lbl_audio.setWordWrap(True)
        v.addWidget(self._btn_load)
        v.addWidget(self._lbl_audio)
        v.addStretch()
        self._btn_load.clicked.connect(self._load_audio)
        self._stack.addWidget(w)   # index 2

    # ------------------------------------------------------------------
    # Signal helpers
    # ------------------------------------------------------------------

    def _rebuild_signal(self):
        if self.signal_type == 'LinearChirp':
            self.t      = np.arange(0, T_END + 1 / self.fs, 1 / self.fs)
            self.signal = chirp_signal(self.t, self.f0, self.chirp_rate)
        elif self.signal_type == 'SumOfSinusoids':
            self.t      = np.arange(0, T_END + 1 / self.fs, 1 / self.fs)
            self.signal = sum_of_sinusoids(
                self.amplitudes, self.sinufreqs, self.phases, self.t)
        else:
            if self.audio_data is not None:
                self.signal = self.audio_data
                self.t      = np.arange(len(self.signal)) / self.audio_fs

    def _get_window(self):
        return make_window(self.win_type, self.winsize)

    # ------------------------------------------------------------------
    # Plotting
    # ------------------------------------------------------------------

    def _replot(self):
        self._rebuild_signal()
        cmap = CMAP_MPL[self.cmap_idx]

        B, F, T = compute_stft(
            self.signal, self.nfft, self.fs,
            self._get_window(), self.noverlap)
        BA = to_db(B, self.drange)

        self.fig.clf()

        if self.three_d:
            try:
                from mpl_toolkits.mplot3d import Axes3D  # noqa: F401
                ax = self.fig.add_subplot(111, projection='3d')
                Tg, Fg = np.meshgrid(T, F)
                ax.plot_surface(Tg, Fg, BA, cmap=cmap,
                                linewidth=0, antialiased=False)
                ax.set_xlabel('Time (s)', fontsize=9)
                ax.set_ylabel('Frequency (Hz)', fontsize=9)
                ax.set_zlabel('dB', fontsize=9)
                ax.view_init(elev=self.el, azim=self.az)
                ax.tick_params(labelsize=8)
            except Exception as e:
                self.lbl_status.setText(f'3D error: {e}')
                self.lbl_status.setStyleSheet('color: red;')
        else:
            ax = self.fig.add_subplot(111)
            extent = [T[0], T[-1], F[0], F[-1]]
            im = ax.imshow(BA, aspect='auto', origin='lower',
                           extent=extent, cmap=cmap)
            ax.set_xlabel('Time (s)', fontsize=9)
            ax.set_ylabel('Frequency (Hz)', fontsize=9)
            ax.tick_params(labelsize=8)
            self.fig.colorbar(im, ax=ax, label='dB', pad=0.02)

        self.fig.tight_layout(pad=0.8)
        self.canvas.draw_idle()

    def _plot_ft(self, t_click):
        B, F, T = compute_stft(
            self.signal, self.nfft, self.fs,
            self._get_window(), self.noverlap)
        idx = int(np.argmin(np.abs(T - t_click)))
        ba  = to_db(B[:, idx:idx+1], self.drange)[:, 0]

        self.fig.clf()
        ax = self.fig.add_subplot(111)
        ax.plot(F, ba)
        ax.grid(True)
        ax.set_xlabel('Frequency (Hz)', fontsize=9)
        ax.set_ylabel('Log Magnitude (dB)', fontsize=9)
        ax.set_title(f'FT slice at t = {T[idx]:.3f} s', fontsize=10)
        ax.tick_params(labelsize=8)
        self.fig.tight_layout(pad=0.8)
        self.canvas.draw_idle()
        self.lbl_status.setText(
            f'FT at t = {T[idx]:.3f} s — click again or toggle off')
        self.lbl_status.setStyleSheet('color: blue;')

    # ------------------------------------------------------------------
    # Parameter callbacks
    # ------------------------------------------------------------------

    def _param_changed(self, **kw):
        for k, v in kw.items():
            setattr(self, k, v)
        self._replot()

    def _signal_type_toggled(self, btn_id, checked):
        if not checked:
            return
        types  = ['LinearChirp', 'SumOfSinusoids', 'UserAudio']
        labels = ['Spectrogram of Linear Chirp',
                  'Spectrogram of Sum of Sinusoids',
                  'Spectrogram of Audio Signal']
        self.signal_type = types[btn_id]
        self._stack.setCurrentIndex(btn_id)
        self.lbl_status.setText(labels[btn_id])
        self.lbl_status.setStyleSheet('color: blue;')
        self._replot()

    def _winsize_slider(self, val):
        self.winsize = val
        self._edt_winsize.blockSignals(True)
        self._edt_winsize.setText(str(val))
        self._edt_winsize.blockSignals(False)
        self.noverlap = round(OVERLAP_FRACS[self._cbo_overlap.currentIndex()] * val)
        self._edt_noverlap.setText(str(self.noverlap))
        self._replot()

    def _winsize_edit(self):
        try:
            v = int(self._edt_winsize.text())
        except ValueError:
            return
        if not (1 <= v < self.nfft):
            self._status_err(f'Window size must be 1…{self.nfft - 1}')
            return
        self.winsize = v
        self._sld_win.blockSignals(True)
        self._sld_win.setValue(v)
        self._sld_win.blockSignals(False)
        self.noverlap = round(OVERLAP_FRACS[self._cbo_overlap.currentIndex()] * v)
        self._edt_noverlap.setText(str(self.noverlap))
        self._replot()

    def _overlap_pct_changed(self, idx):
        self.noverlap = round(OVERLAP_FRACS[idx] * self.winsize)
        self._edt_noverlap.setText(str(self.noverlap))
        self._replot()

    def _noverlap_edit(self):
        try:
            v = int(self._edt_noverlap.text())
        except ValueError:
            return
        if not (0 <= v < self.winsize):
            self._status_err('Noverlap must be < window size')
            return
        self.noverlap = v
        self._replot()

    def _nfft_edit(self):
        try:
            v = int(self._edt_nfft.text())
        except ValueError:
            return
        if v < 4:
            self._status_err('NFFT must be ≥ 4')
            return
        self.nfft = v
        # Clamp window size
        if self.winsize >= self.nfft:
            self.winsize = self.nfft // 2
            self._edt_winsize.setText(str(self.winsize))
        self._sld_win.setRange(1, self.nfft - 1)
        self._sld_win.blockSignals(True)
        self._sld_win.setValue(self.winsize)
        self._sld_win.blockSignals(False)
        self.noverlap = round(OVERLAP_FRACS[self._cbo_overlap.currentIndex()] * self.winsize)
        self._edt_noverlap.setText(str(self.noverlap))
        self._replot()

    def _fs_edit(self):
        if self.signal_type == 'UserAudio':
            return
        try:
            v = float(self._edt_fs.text())
        except ValueError:
            return
        if v > 0:
            self.fs = v
            self._replot()

    def _chirp_param_changed(self):
        try:
            self.f0         = float(self._edt_f0.text())
            self.chirp_rate = float(self._edt_chirprate.text())
            self._replot()
        except ValueError:
            pass

    def _sinus_param_changed(self):
        try:
            amps   = [float(x) for x in self._edt_amp.text().split()]
            freqs  = [float(x) for x in self._edt_freq.text().split()]
            phases = [float(x) for x in self._edt_phase.text().split()]
        except ValueError:
            return
        if len(amps) != len(freqs) or len(freqs) != len(phases):
            self._status_err('Amplitudes, Frequencies and Phases must have equal length')
            return
        self.amplitudes = amps
        self.sinufreqs  = freqs
        self.phases     = phases
        self._replot()

    def _load_audio(self):
        path, _ = QFileDialog.getOpenFileName(
            self, 'Open WAV file', '', 'WAV files (*.wav);;All files (*)')
        if not path:
            return
        try:
            from scipy.io import wavfile as wf
            sr, data = wf.read(path)
            if data.ndim > 1:
                data = data[:, 0]
            # Normalise to float [-1, 1]
            if np.issubdtype(data.dtype, np.integer):
                data = data.astype(float) / np.iinfo(data.dtype).max
            self.audio_data = data
            self.audio_fs   = sr
            self.fs         = sr
            self._edt_fs.setText(str(sr))
            name = os.path.basename(path)
            self._lbl_audio.setText(name)
            self.lbl_status.setText(f'Loaded: {name}')
            self.lbl_status.setStyleSheet('color: blue;')
            self._replot()
        except Exception as e:
            self._status_err(f'Load error: {e}')

    def _play(self):
        if self.signal is None:
            return
        try:
            import sounddevice as sd
            sd.play(self.signal, self.fs)
            self.lbl_status.setText('Playing…')
            self.lbl_status.setStyleSheet('color: blue;')
        except ImportError:
            self._status_err('Install sounddevice for audio playback')
        except Exception as e:
            self._status_err(f'Playback error: {e}')

    def _toggle_3d(self, checked):
        self.three_d = checked
        self.btn_ft.setEnabled(not checked)
        if checked:
            self.az, self.el = -25.0, 60.0
            if self.ft_mode:
                self.btn_ft.setChecked(False)
        else:
            self.az, self.el = 0.0, 90.0
        self._replot()

    def _toggle_ft(self, checked):
        self.ft_mode = checked
        if checked:
            self.lbl_status.setText(
                'Click on the spectrogram to see the FT slice at that time')
            self.lbl_status.setStyleSheet('color: blue;')
        else:
            self._replot()

    def _on_click(self, event):
        if not self.ft_mode or event.inaxes is None or self.three_d:
            return
        if event.xdata is not None:
            self._plot_ft(event.xdata)

    def _status_err(self, msg):
        self.lbl_status.setText(msg)
        self.lbl_status.setStyleSheet('color: red;')


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main():
    app = QApplication(sys.argv)
    win = SpectgramWindow()
    win.resize(1020, 640)
    win.show()
    sys.exit(app.exec())


if __name__ == '__main__':
    main()
