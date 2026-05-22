#!/usr/bin/env python3
"""
Filter Design Demo
PyQt6 port of filterdesign.m (DSP First spfirst toolbox, Rev 2.86)

Supports:
  FIR: Window design (10 window types incl. Kaiser) and Parks-McClellan
  IIR: Butterworth LP / HP / BP / BR via scipy bilinear-transform design
Views: Magnitude, Phase, Impulse Response, Pole-Zero
"""

import sys
import warnings
import numpy as np
from scipy import signal
import matplotlib
matplotlib.use('QtAgg')
from matplotlib.backends.backend_qtagg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure
from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QGridLayout, QLabel, QLineEdit, QPushButton, QComboBox, QRadioButton,
    QButtonGroup, QCheckBox, QGroupBox, QFrame, QStatusBar,
    QFileDialog, QSizePolicy,
)
from PyQt6.QtCore import Qt
from PyQt6.QtGui import QAction


# ─────────────────────────────────────────────────────────────────────────────
# Pure-math helpers (no Qt)
# ─────────────────────────────────────────────────────────────────────────────

def _sinc_lp(wc, diff):
    """sin(wc·d)/(π·d)  with  limit wc/π at d=0."""
    with np.errstate(invalid='ignore', divide='ignore'):
        out = np.where(diff == 0, wc / np.pi, np.sin(wc * diff) / (np.pi * diff))
    return out


def fir_ideal_impulse(filt_name, M, Wp1, Ws1, Wp2, Ws2, use_midpoint=False):
    """Ideal FIR impulse response h[n], n=0…M (length M+1)."""
    n = np.arange(M + 1)
    d = n - M / 2.0
    Wc1 = (Wp1 + Ws1) / 2 if use_midpoint else Wp1
    Wc2 = (Wp2 + Ws2) / 2 if use_midpoint else Wp2

    if filt_name == 'Lowpass':
        return _sinc_lp(Wc1 * np.pi, d)
    if filt_name == 'Highpass':
        return _sinc_lp(np.pi, d) - _sinc_lp(Wc1 * np.pi, d)
    if filt_name == 'Bandpass':
        return _sinc_lp(Wc2 * np.pi, d) - _sinc_lp(Wc1 * np.pi, d)
    if filt_name == 'Bandreject':
        return _sinc_lp(np.pi, d) - _sinc_lp(Wc2 * np.pi, d) + _sinc_lp(Wc1 * np.pi, d)
    return np.zeros(M + 1)


def compute_window(M, win_name, alpha_win=2.5, beta=0.0):
    """Window function of length M+1."""
    N = M + 1
    n = np.arange(N)

    if win_name == 'Rectangular':
        return np.ones(N)
    if win_name == 'Bartlett':
        return np.bartlett(N)
    if win_name == 'Hann':
        return np.hanning(N)
    if win_name == 'Hamming':
        return np.hamming(N)
    if win_name == 'Blackman':
        return np.blackman(N)
    if win_name == 'Gaussian':
        return np.exp(-0.5 * ((alpha_win * (n - M / 2) / (M / 2)) ** 2))
    if win_name == 'Dolph-Chebyshev':
        if M < 3:
            return np.ones(N)
        try:
            k = np.arange(M)
            bdc = np.cosh(np.arccosh(10 ** alpha_win) / (M - 1))
            arg = np.clip(bdc * np.cos(np.pi * k / (M - 1)), -1e15, 1e15)
            wf = ((-1) ** k) * np.cos(M * np.arccos(arg)) / np.cosh(M * np.arccosh(bdc))
            w = np.abs(np.fft.ifft(wf))
            w /= w.max()
            return np.append(w, w[0])
        except Exception:
            return np.ones(N)
    if win_name == 'BarcTemes':
        alpha_bt = 3.0
        C = np.arccosh(10 ** alpha_bt)
        bt = np.cosh(C / M)
        A, B = np.sinh(C), np.cosh(C)
        y = (M + 1) * np.arccos(bt * np.cos(np.pi * n / M))
        num = A * np.cos(y) + B * (y * np.sin(y) / C)
        den = (C + A * B) * ((y / C) ** 2 + 1)
        with warnings.catch_warnings():
            warnings.simplefilter('ignore')
            wf = ((-1) ** n) * num / den
        w = np.abs(np.fft.ifft(wf))
        if w.max() > 0:
            w /= w.max()
        return w
    if win_name == 'Lanczos':
        half = M / 2
        arg = (n - half) * np.pi / (M + 1)
        return np.where(n == round(half), 1.0, np.sin(arg) / arg)
    if win_name == 'Kaiser':
        return np.kaiser(N, beta)
    return np.ones(N)


# ─────────────────────────────────────────────────────────────────────────────
# Main window
# ─────────────────────────────────────────────────────────────────────────────

class FilterDesignApp(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle('Filter Design')
        self.resize(1080, 700)

        # ── state ──────────────────────────────────────────────────────────
        self.filt_type   = 'FIR'       # 'FIR' | 'IIR'
        self.filt_name   = 'Lowpass'   # filter shape
        self.design_name = 'Window'    # 'Window' | 'Parks-McClellan'
        self.win_name    = 'Hamming'
        self.alpha_win   = 2.5
        self.plot_type   = 'Magnitude' # 'Magnitude'|'Phase'|'Impulse'|'PoleZero'
        self.x_mode      = 'Hz'        # 'Hz' | 'Norm'
        self.y_mode      = 'Mag'       # 'Mag' | 'dB'
        self.auto_order  = False       # only active for Kaiser/PM/IIR
        self.show_grid   = False
        self.kaiser_r    = ''          # 'Rpass'|'Rstop' – which ripple drives Kaiser

        # ── filter results ─────────────────────────────────────────────────
        self.b          = np.array([1.0])
        self.a          = np.array([1.0])
        self.H_complex  = np.array([1.0 + 0j])
        self.w_rad      = np.array([0.0])   # 0 … π
        self.total_res  = np.array([1.0])   # impulse response
        self.imp_res    = np.array([1.0])   # ideal (pre-window) response
        self.winfun     = np.array([1.0])
        self.beta_k     = 0.0               # Kaiser β
        self.filter_title = ''

        # ── parameters ─────────────────────────────────────────────────────
        self.params = dict(Fsamp=8000.0, Fpass1=1000.0, Fstop1=1500.0,
                           Fpass2=2500.0, Fstop2=3000.0,
                           Rpass=0.05, Rstop=0.044, Order=20)

        self._build_ui()
        self._build_menus()
        self._connect()
        self._update_visibility()
        self._set_defaults()
        self._design_and_plot()

    # =========================================================================
    # UI construction
    # =========================================================================
    def _build_ui(self):
        cw = QWidget()
        self.setCentralWidget(cw)
        lay = QHBoxLayout(cw)
        lay.setContentsMargins(4, 4, 4, 4)
        lay.setSpacing(6)

        # canvas (left, expandable)
        self._make_canvas()
        lay.addWidget(self.canvas, stretch=3)

        sep = QFrame()
        sep.setFrameShape(QFrame.Shape.VLine)
        lay.addWidget(sep)

        # control panel (right, fixed width)
        lay.addWidget(self._make_controls(), stretch=0)

        self.status_bar = QStatusBar()
        self.setStatusBar(self.status_bar)
        self.status_lbl = QLabel('Ready')
        self.status_bar.addWidget(self.status_lbl)

    def _make_canvas(self):
        self.fig = Figure(figsize=(7.5, 5.5))
        self.ax  = self.fig.add_subplot(111)
        self.fig.tight_layout(pad=1.8)
        self.canvas = FigureCanvas(self.fig)
        self.canvas.setMinimumWidth(420)
        self.canvas.setSizePolicy(QSizePolicy.Policy.Expanding,
                                  QSizePolicy.Policy.Expanding)

    def _make_controls(self):
        panel = QWidget()
        panel.setFixedWidth(248)
        lay = QVBoxLayout(panel)
        lay.setContentsMargins(4, 4, 4, 4)
        lay.setSpacing(5)

        # ── FIR / IIR ──────────────────────────────────────────────────────
        gb = QGroupBox('Filter Class')
        hl = QHBoxLayout(gb)
        self.rb_fir = QRadioButton('FIR'); self.rb_fir.setChecked(True)
        self.rb_iir = QRadioButton('IIR')
        bg = QButtonGroup(self)
        bg.addButton(self.rb_fir); bg.addButton(self.rb_iir)
        hl.addWidget(self.rb_fir); hl.addWidget(self.rb_iir)
        lay.addWidget(gb)

        # ── Filter shape ───────────────────────────────────────────────────
        r = QHBoxLayout()
        r.addWidget(QLabel('Filter:'))
        self.cb_filter = QComboBox()
        self.cb_filter.addItems(['Lowpass','Highpass','Bandpass','Bandreject'])
        r.addWidget(self.cb_filter)
        lay.addLayout(r)

        # ── Design method (FIR only) ───────────────────────────────────────
        self.w_design = QWidget()
        dl = QHBoxLayout(self.w_design); dl.setContentsMargins(0,0,0,0)
        dl.addWidget(QLabel('Method:'))
        self.cb_design = QComboBox()
        self.cb_design.addItems(['Window','Parks-McClellan'])
        dl.addWidget(self.cb_design)
        lay.addWidget(self.w_design)

        # ── Window type ────────────────────────────────────────────────────
        self.w_window = QWidget()
        wl = QHBoxLayout(self.w_window); wl.setContentsMargins(0,0,0,0)
        wl.addWidget(QLabel('Window:'))
        self.cb_window = QComboBox()
        self.cb_window.addItems(['Rectangular','Bartlett','Hann','Hamming',
                                  'Blackman','Gaussian','Dolph-Chebyshev',
                                  'BarcTemes','Lanczos','Kaiser'])
        self.cb_window.setCurrentText('Hamming')
        wl.addWidget(self.cb_window)
        lay.addWidget(self.w_window)

        # ── Alpha (Gaussian / Dolph-Chebyshev) ────────────────────────────
        self.w_alpha = QWidget()
        al = QHBoxLayout(self.w_alpha); al.setContentsMargins(0,0,0,0)
        al.addWidget(QLabel('Alpha:'))
        self.ed_alpha = QLineEdit('2.5')
        al.addWidget(self.ed_alpha)
        lay.addWidget(self.w_alpha)
        self.w_alpha.hide()

        # ── Parameter grid ─────────────────────────────────────────────────
        pb = QGroupBox('Parameters')
        pg = QGridLayout(pb)
        pg.setVerticalSpacing(3); pg.setHorizontalSpacing(4)

        def mkrow(label, val, units='Hz'):
            l = QLabel(label)
            e = QLineEdit(str(val)); e.setMaximumWidth(78)
            u = QLabel(units)
            return l, e, u

        row = 0
        self.lbl_fs,  self.ed_fs,  self.u_fs  = mkrow('F_samp', 8000)
        pg.addWidget(self.lbl_fs,  row, 0); pg.addWidget(self.ed_fs,  row, 1); pg.addWidget(self.u_fs,  row, 2)

        row += 1
        self.lbl_fp1, self.ed_fp1, self.u_fp1 = mkrow('F_pass', 1000)
        pg.addWidget(self.lbl_fp1, row, 0); pg.addWidget(self.ed_fp1, row, 1); pg.addWidget(self.u_fp1, row, 2)

        row += 1
        self.lbl_fs1, self.ed_fs1, self.u_fs1 = mkrow('F_stop', 1500)
        pg.addWidget(self.lbl_fs1, row, 0); pg.addWidget(self.ed_fs1, row, 1); pg.addWidget(self.u_fs1, row, 2)

        row += 1
        self.lbl_fp2, self.ed_fp2, self.u_fp2 = mkrow('F_pass 2', 2500)
        pg.addWidget(self.lbl_fp2, row, 0); pg.addWidget(self.ed_fp2, row, 1); pg.addWidget(self.u_fp2, row, 2)

        row += 1
        self.lbl_fs2, self.ed_fs2, self.u_fs2 = mkrow('F_stop 2', 3000)
        pg.addWidget(self.lbl_fs2, row, 0); pg.addWidget(self.ed_fs2, row, 1); pg.addWidget(self.u_fs2, row, 2)

        row += 1
        self.lbl_rp,  self.ed_rp,  self.u_rp  = mkrow('δ_pass', 0.05,  '')
        pg.addWidget(self.lbl_rp,  row, 0); pg.addWidget(self.ed_rp,  row, 1); pg.addWidget(self.u_rp,  row, 2)

        row += 1
        self.lbl_rs,  self.ed_rs,  self.u_rs  = mkrow('δ_stop', 0.044, '')
        pg.addWidget(self.lbl_rs,  row, 0); pg.addWidget(self.ed_rs,  row, 1); pg.addWidget(self.u_rs,  row, 2)

        row += 1
        self.lbl_ord = QLabel('Order')
        self.ed_ord  = QLineEdit('20'); self.ed_ord.setMaximumWidth(78)
        pg.addWidget(self.lbl_ord, row, 0); pg.addWidget(self.ed_ord, row, 1, 1, 2)

        row += 1
        self.chk_auto = QCheckBox('Auto Order')
        self.chk_auto.setChecked(False)
        pg.addWidget(self.chk_auto, row, 0, 1, 3)

        lay.addWidget(pb)

        # Kaiser β display
        self.lbl_beta = QLabel('')
        self.lbl_beta.setStyleSheet('color: #004499; font-size: 10px;')
        lay.addWidget(self.lbl_beta)
        self.lbl_beta.hide()

        # ── View buttons ───────────────────────────────────────────────────
        vb = QGroupBox('View')
        vg = QGridLayout(vb); vg.setSpacing(3)
        self.btn_mag   = QPushButton('Magnitude')
        self.btn_phase = QPushButton('Phase')
        self.btn_imp   = QPushButton('Impulse')
        self.btn_pz    = QPushButton('Pole-Zero')
        for b in (self.btn_mag, self.btn_phase, self.btn_imp, self.btn_pz):
            b.setMaximumHeight(28)
        vg.addWidget(self.btn_mag,   0, 0); vg.addWidget(self.btn_phase, 0, 1)
        vg.addWidget(self.btn_imp,   1, 0); vg.addWidget(self.btn_pz,    1, 1)
        lay.addWidget(vb)

        lay.addStretch()
        return panel

    def _build_menus(self):
        mb = self.menuBar()

        fm = mb.addMenu('File')
        a = QAction('Export Coefficients (.npz)…', self)
        a.triggered.connect(self._export)
        fm.addAction(a)
        fm.addSeparator()
        a = QAction('Exit', self)
        a.triggered.connect(self.close)
        fm.addAction(a)

        vm = mb.addMenu('View')
        self.act_norm = QAction('Normalized Frequency (0–1)', self)
        self.act_norm.setCheckable(True)
        self.act_norm.triggered.connect(self._toggle_x)
        vm.addAction(self.act_norm)

        self.act_db = QAction('Magnitude (dB)', self)
        self.act_db.setCheckable(True)
        self.act_db.triggered.connect(self._toggle_y)
        vm.addAction(self.act_db)

        vm.addSeparator()
        self.act_grid = QAction('Grid', self)
        self.act_grid.setCheckable(True)
        self.act_grid.triggered.connect(self._toggle_grid)
        vm.addAction(self.act_grid)

    def _connect(self):
        self.rb_fir.toggled.connect(self._on_type)
        self.rb_iir.toggled.connect(self._on_type)
        self.cb_filter.currentTextChanged.connect(self._on_filter)
        self.cb_design.currentTextChanged.connect(self._on_design)
        self.cb_window.currentTextChanged.connect(self._on_window)
        self.ed_alpha.editingFinished.connect(self._on_alpha)

        for ed in (self.ed_fs, self.ed_fp1, self.ed_fs1, self.ed_fp2, self.ed_fs2):
            ed.editingFinished.connect(self._on_freq_edited)

        self.ed_rp.editingFinished.connect(lambda: self._on_ripple('Rpass'))
        self.ed_rs.editingFinished.connect(lambda: self._on_ripple('Rstop'))
        self.ed_ord.editingFinished.connect(self._on_order)
        self.chk_auto.stateChanged.connect(self._on_auto)

        self.btn_mag.clicked.connect(lambda: self._switch('Magnitude'))
        self.btn_phase.clicked.connect(lambda: self._switch('Phase'))
        self.btn_imp.clicked.connect(lambda: self._switch('Impulse'))
        self.btn_pz.clicked.connect(lambda: self._switch('PoleZero'))

    # =========================================================================
    # Control-state management
    # =========================================================================
    def _on_type(self):
        new = 'FIR' if self.rb_fir.isChecked() else 'IIR'
        if new == self.filt_type:
            return
        self.filt_type = new
        self.cb_filter.blockSignals(True)
        if new == 'FIR':
            shape = self.filt_name.replace('Butterworth ', '')
            self.cb_filter.clear()
            self.cb_filter.addItems(['Lowpass','Highpass','Bandpass','Bandreject'])
            self.cb_filter.setCurrentText(shape)
            self.filt_name = shape
        else:
            shape = self.filt_name
            bname = f'Butterworth {shape}'
            self.cb_filter.clear()
            self.cb_filter.addItems(['Butterworth Lowpass','Butterworth Highpass',
                                     'Butterworth Bandpass','Butterworth Bandreject'])
            self.cb_filter.setCurrentText(bname)
            self.filt_name = bname
        self.cb_filter.blockSignals(False)
        self._update_visibility()
        self._set_defaults()
        self._design_and_plot()

    def _on_filter(self, name):
        self.filt_name = name
        self._update_visibility()
        self._set_defaults()
        self._design_and_plot()

    def _on_design(self, name):
        self.design_name = name
        self._update_visibility()
        self._set_defaults()
        self._design_and_plot()

    def _on_window(self, name):
        self.win_name = name
        if name == 'Gaussian':
            self.alpha_win = 2.5; self.ed_alpha.setText('2.5')
        elif name == 'Dolph-Chebyshev':
            self.alpha_win = 3.0; self.ed_alpha.setText('3.0')
        self._update_visibility()
        self._set_defaults()
        self._design_and_plot()

    def _on_alpha(self):
        try:
            v = float(self.ed_alpha.text())
            if v > 0:
                self.alpha_win = v
        except ValueError:
            self.ed_alpha.setText(str(self.alpha_win))
        self._design_and_plot()

    def _on_freq_edited(self):
        self._read_params()
        self._design_and_plot()

    def _on_ripple(self, which):
        self.kaiser_r = which
        self._read_params()
        self._design_and_plot()

    def _on_order(self):
        try:
            v = int(float(self.ed_ord.text()))
            if v > 0:
                self.params['Order'] = v
        except ValueError:
            self.ed_ord.setText(str(self.params['Order']))
        self._design_and_plot()

    def _on_auto(self):
        self.auto_order = self.chk_auto.isChecked()
        self.ed_ord.setEnabled(not self.auto_order)
        self._design_and_plot()

    # ─── visibility ──────────────────────────────────────────────────────────
    def _update_visibility(self):
        fn = self.filt_name
        is_fir    = self.filt_type == 'FIR'
        is_iir    = not is_fir
        is_kaiser = is_fir and self.win_name == 'Kaiser'
        is_pm     = is_fir and self.design_name == 'Parks-McClellan'
        is_window = is_fir and self.design_name == 'Window'
        is_band   = 'Bandpass' in fn or 'Bandreject' in fn

        self.w_design.setVisible(is_fir)
        self.w_window.setVisible(is_fir and is_window)
        self.w_alpha.setVisible(is_fir and is_window and
                                self.win_name in ('Gaussian','Dolph-Chebyshev'))

        need_stop1 = is_kaiser or is_pm or is_iir
        self._vis([self.lbl_fs1, self.ed_fs1, self.u_fs1], need_stop1)
        self._vis([self.lbl_fp2, self.ed_fp2, self.u_fp2], is_band)
        self._vis([self.lbl_fs2, self.ed_fs2, self.u_fs2], is_band and need_stop1)

        need_r = is_kaiser or is_iir
        self._vis([self.lbl_rp, self.ed_rp, self.u_rp], need_r)
        self._vis([self.lbl_rs, self.ed_rs, self.u_rs], need_r)

        need_auto = is_kaiser or is_pm or is_iir
        self.chk_auto.setVisible(need_auto)
        self.lbl_beta.setVisible(is_kaiser)

        # order editability
        if not need_auto:
            self.auto_order = False
            self.ed_ord.setEnabled(True)
        else:
            self.ed_ord.setEnabled(not self.auto_order)

        # label text
        has_spec = is_kaiser or is_pm or is_iir
        if is_band:
            self.lbl_fp1.setText('F_pass 1' if has_spec else 'F_cutoff 1')
            self.lbl_fs1.setText('F_stop 1')
            self.lbl_fp2.setText('F_pass 2' if has_spec else 'F_cutoff 2')
            self.lbl_fs2.setText('F_stop 2')
        else:
            self.lbl_fp1.setText('F_pass' if has_spec else 'F_cutoff')
            self.lbl_fs1.setText('F_stop')

        # units
        u = 'π' if self.x_mode == 'Norm' else 'Hz'
        for lbl in (self.u_fp1, self.u_fs1, self.u_fp2, self.u_fs2):
            lbl.setText(u)

    def _vis(self, widgets, show):
        for w in widgets:
            w.setVisible(show)

    # ─── default parameters ──────────────────────────────────────────────────
    def _set_defaults(self):
        fs = self.params['Fsamp']
        fn = self.filt_name
        if 'Lowpass' in fn:
            self.params.update(Fpass1=round(2*fs/16), Fstop1=round(3*fs/16))
        elif 'Highpass' in fn:
            self.params.update(Fpass1=round(3*fs/16), Fstop1=round(2*fs/16))
        elif 'Bandpass' in fn:
            self.params.update(Fpass1=round(3*fs/16), Fstop1=round(2*fs/16),
                               Fpass2=round(5*fs/16), Fstop2=round(7*fs/16))
        elif 'Bandreject' in fn:
            self.params.update(Fpass1=round(2*fs/16), Fstop1=round(3*fs/16),
                               Fpass2=round(7*fs/16), Fstop2=round(5*fs/16))
        self._refresh_fields()

    def _refresh_fields(self):
        p = self.params
        self.ed_fs.setText(f'{p["Fsamp"]:.0f}')
        if self.x_mode == 'Norm':
            h = p['Fsamp'] / 2
            self.ed_fp1.setText(f'{p["Fpass1"]/h:.4f}')
            self.ed_fs1.setText(f'{p["Fstop1"]/h:.4f}')
            self.ed_fp2.setText(f'{p["Fpass2"]/h:.4f}')
            self.ed_fs2.setText(f'{p["Fstop2"]/h:.4f}')
        else:
            self.ed_fp1.setText(f'{p["Fpass1"]:.1f}')
            self.ed_fs1.setText(f'{p["Fstop1"]:.1f}')
            self.ed_fp2.setText(f'{p["Fpass2"]:.1f}')
            self.ed_fs2.setText(f'{p["Fstop2"]:.1f}')
        self.ed_ord.setText(str(int(p['Order'])))
        if self.y_mode == 'dB':
            rp, rs = p['Rpass'], p['Rstop']
            self.ed_rp.setText(f'{20*np.log10(max(1-rp,1e-10)):.2f}')
            self.ed_rs.setText(f'{20*np.log10(max(rs,1e-10)):.2f}')
        else:
            self.ed_rp.setText(f'{p["Rpass"]:.5f}')
            self.ed_rs.setText(f'{p["Rstop"]:.5f}')

    def _read_params(self):
        p = self.params
        def sf(ed, lo=None, hi=None):
            try:
                v = float(ed.text())
                if lo is not None and v < lo: return
                if hi is not None and v > hi: return
                return v
            except ValueError:
                return None

        v = sf(self.ed_fs, lo=1)
        if v: p['Fsamp'] = v
        fs = p['Fsamp']
        half = fs / 2

        if self.x_mode == 'Norm':
            for ed, key in ((self.ed_fp1,'Fpass1'),(self.ed_fs1,'Fstop1'),
                            (self.ed_fp2,'Fpass2'),(self.ed_fs2,'Fstop2')):
                v = sf(ed, lo=0, hi=1)
                if v is not None: p[key] = v * half
        else:
            for ed, key in ((self.ed_fp1,'Fpass1'),(self.ed_fs1,'Fstop1'),
                            (self.ed_fp2,'Fpass2'),(self.ed_fs2,'Fstop2')):
                v = sf(ed, lo=0, hi=half*0.9999)
                if v is not None: p[key] = v

        if self.y_mode == 'dB':
            v = sf(self.ed_rp)
            if v is not None and v < 0: p['Rpass'] = abs(1 - 10**(v/20))
            v = sf(self.ed_rs)
            if v is not None and v < 0: p['Rstop'] = 10**(v/20)
        else:
            v = sf(self.ed_rp, lo=1e-6, hi=0.499)
            if v is not None: p['Rpass'] = v
            v = sf(self.ed_rs, lo=1e-6, hi=0.499)
            if v is not None: p['Rstop'] = v

        v = sf(self.ed_ord, lo=1)
        if v is not None: p['Order'] = int(v)

    # =========================================================================
    # Filter Design
    # =========================================================================
    def _design_and_plot(self):
        try:
            self._read_params()
            if self.filt_type == 'FIR':
                if self.design_name == 'Window':
                    self._fir_window()
                else:
                    self._fir_pm()
            else:
                self._iir_butter()
            self._do_plot()
            self._status('Ready')
        except Exception as e:
            self._status(f'Design error: {e}', error=True)

    def _norm(self):
        """Return (Wp1, Ws1, Wp2, Ws2) normalized 0–1 where 1 = Nyquist."""
        p = self.params; h = p['Fsamp'] / 2
        return p['Fpass1']/h, p['Fstop1']/h, p['Fpass2']/h, p['Fstop2']/h

    # ── FIR Window ────────────────────────────────────────────────────────────
    def _fir_window(self):
        p = self.params
        Wp1, Ws1, Wp2, Ws2 = self._norm()
        is_k = self.win_name == 'Kaiser'

        if is_k:
            delta = (p['Rpass'] if self.kaiser_r == 'Rpass' else
                     p['Rstop'] if self.kaiser_r == 'Rstop' else
                     min(p['Rpass'], p['Rstop']))
            A = -20 * np.log10(max(delta, 1e-10))
            if A > 50:   beta = 0.1102 * (A - 8.7)
            elif A < 21: beta = 0.0
            else:        beta = 0.5842*(A-21)**0.4 + 0.07886*(A-21)
            self.beta_k = beta
            self.lbl_beta.setText(f'Kaiser β = {beta:.4f}')

            if self.auto_order:
                A2 = max(A, 8.001)
                fn = self.filt_name
                if fn in ('Lowpass','Highpass'):
                    dW = abs(Wp1-Ws1) * np.pi
                    M = int(np.ceil((A2-8)/(2.285*dW)))
                else:
                    dW = min(abs(Wp1-Ws1), abs(Wp2-Ws2)) * np.pi
                    M = int(np.ceil((A2-8)/(2.285*dW)))
                if fn == 'Bandreject' and M % 2 != 0:
                    M += 1
                p['Order'] = M+1
                self.ed_ord.setText(str(M+1))
            else:
                M = p['Order'] - 1
            use_mid = True
        else:
            M = p['Order'] - 1
            beta = 0.0
            use_mid = False

        M = max(M, 2)
        self.imp_res = fir_ideal_impulse(self.filt_name, M, Wp1, Ws1, Wp2, Ws2, use_mid)
        self.winfun  = compute_window(M, self.win_name, self.alpha_win, beta)
        self.total_res = self.imp_res * self.winfun
        self.b = self.total_res
        self.a = np.array([1.0])

        self.w_rad, self.H_complex = signal.freqz(self.b, [1], worN=512)
        order_str = p['Order']
        self.filter_title = (f'{self.filt_name} FIR Filter '
                             f'(Window: {self.win_name}), Order {order_str}')

    # ── FIR Parks-McClellan ───────────────────────────────────────────────────
    def _fir_pm(self):
        p = self.params
        fs = p['Fsamp']; half = fs/2
        N = p['Order']
        if N % 2 == 0:       # PM needs odd length (even order)
            N += 1; p['Order'] = N; self.ed_ord.setText(str(N))

        fn = self.filt_name
        eps = half * 1e-4
        def clamp(f): return max(eps, min(half - eps, f))

        if fn == 'Lowpass':
            f1, f2 = clamp(p['Fpass1']), clamp(p['Fstop1'])
            if f1 >= f2: f2 = f1 + eps*10
            bands, des = [0, f1, f2, half], [1, 0]
        elif fn == 'Highpass':
            f1, f2 = clamp(p['Fstop1']), clamp(p['Fpass1'])
            if f1 >= f2: f1 = max(eps, f2 - eps*10)
            bands, des = [0, f1, f2, half], [0, 1]
        elif fn == 'Bandpass':
            s1 = clamp(p['Fstop1']); p1 = clamp(p['Fpass1'])
            p2 = clamp(p['Fpass2']); s2 = clamp(p['Fstop2'])
            bands, des = [0, s1, p1, p2, s2, half], [0, 1, 0]
        else:   # Bandreject
            p1 = clamp(p['Fpass1']); s1 = clamp(p['Fstop1'])
            s2 = clamp(p['Fstop2']); p2 = clamp(p['Fpass2'])
            bands, des = [0, p1, s1, s2, p2, half], [1, 0, 1]

        b = signal.remez(N, bands, des, fs=fs)
        self.b = b; self.a = np.array([1.0])
        self.total_res = b; self.imp_res = b
        self.winfun = np.ones(len(b))
        self.w_rad, self.H_complex = signal.freqz(b, [1], worN=512)
        self.filter_title = f'{fn} FIR Filter (Parks-McClellan), Order {N}'

    # ── IIR Butterworth ───────────────────────────────────────────────────────
    def _iir_butter(self):
        p = self.params
        Wp1, Ws1, Wp2, Ws2 = self._norm()
        fn = self.filt_name
        eps = 1e-4

        def clip(x): return float(np.clip(x, eps, 1-eps))
        Wp1, Ws1, Wp2, Ws2 = clip(Wp1), clip(Ws1), clip(Wp2), clip(Ws2)

        rp = max(p['Rpass'], 1e-4)
        rs = max(p['Rstop'], 1e-4)
        rp_db = max(0.01, -20*np.log10(max(1-rp, 1e-10)))
        rs_db = max(rp_db+0.5, -20*np.log10(max(rs, 1e-10)))

        if 'Lowpass' in fn:
            if self.auto_order:
                N, Wn = signal.buttord(Wp1, Ws1, rp_db, rs_db)
                N = min(int(N), 20); p['Order'] = N
                self.ed_ord.setText(str(N))
            else:
                N, Wn = p['Order'], Wp1
            b, a = signal.butter(N, Wn, btype='low')
            title = f'Butterworth Lowpass Filter, Order {N}'

        elif 'Highpass' in fn:
            if self.auto_order:
                N, Wn = signal.buttord(Wp1, Ws1, rp_db, rs_db)
                N = min(int(N), 20); p['Order'] = N
                self.ed_ord.setText(str(N))
            else:
                N, Wn = p['Order'], Wp1
            b, a = signal.butter(N, Wn, btype='high')
            title = f'Butterworth Highpass Filter, Order {N}'

        elif 'Bandpass' in fn:
            if Wp1 >= Wp2: Wp2 = Wp1 + eps
            if Ws1 >= Wp1: Ws1 = max(eps, Wp1 - eps)
            if Ws2 <= Wp2: Ws2 = min(1-eps, Wp2 + eps)
            if self.auto_order:
                N, _ = signal.buttord([Wp1, Wp2], [Ws1, Ws2], rp_db, rs_db)
                N = min(int(N), 10)
                p['Order'] = 2*N; self.ed_ord.setText(str(2*N))
            else:
                N = max(1, p['Order']//2); p['Order'] = 2*N
            b, a = signal.butter(N, [Wp1, Wp2], btype='band')
            title = f'Butterworth Bandpass Filter, Order {p["Order"]}'

        elif 'Bandreject' in fn:
            if Wp1 >= Wp2: Wp2 = Wp1 + eps
            if Ws1 <= Wp1: Ws1 = Wp1 + eps
            if Ws2 >= Wp2: Ws2 = max(Ws1+eps, Wp2 - eps)
            if Ws1 >= Ws2: Ws1 = Ws2 - eps
            if self.auto_order:
                N, _ = signal.buttord([Wp1, Wp2], [Ws1, Ws2], rp_db, rs_db)
                N = min(int(N), 10)
                p['Order'] = 2*N; self.ed_ord.setText(str(2*N))
            else:
                N = max(1, p['Order']//2); p['Order'] = 2*N
            b, a = signal.butter(N, [Ws1, Ws2], btype='bandstop')
            title = f'Butterworth Bandreject Filter, Order {p["Order"]}'
        else:
            b, a, title = np.array([1.0]), np.array([1.0]), 'Unknown'

        # normalize to unit peak
        _, H = signal.freqz(b, a, worN=512)
        mx = np.max(np.abs(H))
        if mx > 1e-10:
            b = b / mx

        self.b = b; self.a = a
        self.w_rad, self.H_complex = signal.freqz(b, a, worN=512)

        imp = np.zeros(50); imp[0] = 1.0
        self.total_res = signal.lfilter(b, a, imp)
        self.imp_res   = self.total_res.copy()
        self.winfun    = np.ones(len(self.total_res))
        self.filter_title = title

    # =========================================================================
    # Plotting
    # =========================================================================
    def _do_plot(self):
        {'Magnitude': self._plot_mag,
         'Phase':     self._plot_phase,
         'Impulse':   self._plot_imp,
         'PoleZero':  self._plot_pz}[self.plot_type]()
        self.canvas.draw_idle()

    def _freq_xdata(self):
        """(xdata, xlabel, xlim) for the current x_mode."""
        w = self.w_rad
        fs = self.params['Fsamp']
        if self.x_mode == 'Hz':
            return w/np.pi*(fs/2), 'Frequency (Hz)', (0, fs/2)
        return w/np.pi, 'Normalized Frequency (×π rad/sample)', (0, 1)

    def _to_x(self, f_hz):
        """Convert frequency in Hz to current x-axis units."""
        if self.x_mode == 'Hz':
            return f_hz
        return f_hz / (self.params['Fsamp']/2)

    def _plot_mag(self):
        self.ax.cla()
        p = self.params
        freq, xlabel, xlim = self._freq_xdata()
        H = self.H_complex

        if self.y_mode == 'Mag':
            y = np.abs(H)
            ylabel, ylim = 'Magnitude', (-0.1, 1.25)
            self.ax.axhline(0, color='#00aa00', linewidth=0.8)
            self._draw_spec_lines()
        else:
            y = np.abs(H); y[y < 1e-12] = 1e-12
            y = 20 * np.log10(y)
            ylabel, ylim = 'Magnitude (dB)', (-80, 10)

        self.ax.plot(freq, y, 'b-', linewidth=1.5)
        self.ax.set_xlabel(xlabel)
        self.ax.set_ylabel(ylabel)
        self.ax.set_xlim(xlim)
        self.ax.set_ylim(ylim)
        self.ax.set_title(self.filter_title)
        self.ax.grid(self.show_grid)
        self.fig.tight_layout(pad=1.5)

    def _draw_spec_lines(self):
        """Red specification lines on linear-magnitude plot."""
        p   = self.params
        fn  = self.filt_name
        rp  = p['Rpass']
        rs  = p['Rstop']
        fmx = self._to_x(p['Fsamp']/2)
        f1  = self._to_x(p['Fpass1'])
        s1  = self._to_x(p['Fstop1'])
        f2  = self._to_x(p['Fpass2'])
        s2  = self._to_x(p['Fstop2'])

        fn_type = self.filt_type
        is_k   = fn_type == 'FIR' and self.win_name == 'Kaiser'
        is_pm  = fn_type == 'FIR' and self.design_name == 'Parks-McClellan'
        is_iir = fn_type == 'IIR'
        full   = is_k or is_pm or is_iir   # show full spec boxes vs cutoff lines

        kw = dict(color='r', linewidth=1.5)

        if 'Lowpass' in fn:
            if full:
                self.ax.plot([0,f1], [1+rp,1+rp], **kw)
                self.ax.plot([0,f1], [1-rp,1-rp], **kw)
                self.ax.plot([s1,fmx], [rs,rs], **kw)
            else:
                self.ax.axvline(f1, color='r', linewidth=1.5, linestyle='--')
        elif 'Highpass' in fn:
            if full:
                self.ax.plot([f1,fmx], [1+rp,1+rp], **kw)
                self.ax.plot([f1,fmx], [1-rp,1-rp], **kw)
                self.ax.plot([0,s1], [rs,rs], **kw)
            else:
                self.ax.axvline(f1, color='r', linewidth=1.5, linestyle='--')
        elif 'Bandpass' in fn:
            if full:
                self.ax.plot([f1,f2], [1+rp,1+rp], **kw)
                self.ax.plot([f1,f2], [1-rp,1-rp], **kw)
                self.ax.plot([0,s1], [rs,rs], **kw)
                self.ax.plot([s2,fmx], [rs,rs], **kw)
            else:
                self.ax.axvline(f1, color='r', linewidth=1.5, linestyle='--')
                self.ax.axvline(f2, color='r', linewidth=1.5, linestyle='--')
        elif 'Bandreject' in fn:
            if full:
                self.ax.plot([0,f1],  [1+rp,1+rp], **kw)
                self.ax.plot([0,f1],  [1-rp,1-rp], **kw)
                self.ax.plot([f2,fmx],[1+rp,1+rp], **kw)
                self.ax.plot([f2,fmx],[1-rp,1-rp], **kw)
                self.ax.plot([s1,s2], [rs,rs], **kw)
            else:
                self.ax.axvline(f1, color='r', linewidth=1.5, linestyle='--')
                self.ax.axvline(f2, color='r', linewidth=1.5, linestyle='--')

    def _plot_phase(self):
        self.ax.cla()
        freq, xlabel, xlim = self._freq_xdata()
        _, H = signal.freqz(self.b, self.a, worN=512)
        phase = np.unwrap(np.angle(H)) / np.pi

        self.ax.plot(freq, phase, 'b-', linewidth=1.5)
        self.ax.set_xlabel(xlabel)
        self.ax.set_ylabel('Unwrapped Phase (×π rad)')
        self.ax.set_xlim(xlim)
        self.ax.set_title(f'Phase Response, Order {self.params["Order"]}')
        self.ax.grid(self.show_grid)
        self.fig.tight_layout(pad=1.5)

    def _plot_imp(self):
        self.ax.cla()
        h = self.total_res
        N = len(h)
        n = np.arange(N)

        # stem
        for ni, hi in zip(n, h):
            self.ax.plot([ni, ni], [0, hi], 'b-', linewidth=0.9)
        self.ax.plot(n, h, 'bo', markersize=4, markerfacecolor='b')
        self.ax.axhline(0, color='#00aa00', linewidth=0.8)

        # window overlay for FIR window designs
        if (self.filt_type == 'FIR' and self.design_name == 'Window'
                and len(self.winfun) == len(self.imp_res)):
            mx = np.max(np.abs(self.imp_res))
            if mx > 1e-12:
                xs = np.linspace(0, N-1, 300)
                wi = np.interp(xs, n, self.winfun * mx)
                self.ax.plot(xs, wi, 'k:', linewidth=1.2, label='Window envelope')
                self.ax.legend(fontsize=8)

        self.ax.set_xlabel('Sample index  n')
        self.ax.set_ylabel('h[n]')
        self.ax.set_title('Impulse Response')
        self.ax.set_xlim(-1, N + 1)
        self.ax.grid(self.show_grid)
        self.fig.tight_layout(pad=1.5)

    def _plot_pz(self):
        self.ax.cla()
        b, a = self.b, self.a

        # unit circle + axes
        th = np.linspace(0, 2*np.pi, 500)
        self.ax.plot(np.cos(th), np.sin(th), 'k:', linewidth=0.8)
        self.ax.axhline(0, color='k', linestyle=':', linewidth=0.8)
        self.ax.axvline(0, color='k', linestyle=':', linewidth=0.8)

        # zeros
        if len(b) > 1:
            Z = np.roots(b)
            Z = Z[(np.abs(Z) > 1e-8) & (np.abs(Z) < 1e8)]
        else:
            Z = np.array([])
        # poles
        P = np.roots(a) if len(a) > 1 else np.array([])

        if len(Z):
            self.ax.plot(Z.real, Z.imag, 'bo', markersize=9,
                        markerfacecolor='none', markeredgewidth=1.5,
                        label=f'Zeros ({len(Z)})')
        if len(P):
            self.ax.plot(P.real, P.imag, 'bx', markersize=11,
                        markeredgewidth=2, label=f'Poles ({len(P)})')

        all_r = ([np.abs(Z).max()] if len(Z) else []) + \
                ([np.abs(P).max()] if len(P) else [])
        mx = min(max(1.2, max(all_r, default=1.2) * 1.25), 8.0)

        self.ax.set_xlim(-mx, mx); self.ax.set_ylim(-mx, mx)
        self.ax.set_aspect('equal', adjustable='box')
        self.ax.set_xlabel('Real'); self.ax.set_ylabel('Imaginary')
        self.ax.set_title(f'Pole-Zero Plot, Order {self.params["Order"]}')
        if len(Z) or len(P):
            self.ax.legend(fontsize=9)
        self.ax.grid(self.show_grid)
        self.fig.tight_layout(pad=1.5)

    # =========================================================================
    # View / Menu actions
    # =========================================================================
    def _switch(self, view):
        self.plot_type = view
        self._do_plot()

    def _toggle_x(self, checked):
        self.x_mode = 'Norm' if checked else 'Hz'
        u = 'π' if checked else 'Hz'
        for lbl in (self.u_fp1, self.u_fs1, self.u_fp2, self.u_fs2):
            lbl.setText(u)
        self._refresh_fields()
        self._do_plot()

    def _toggle_y(self, checked):
        self.y_mode = 'dB' if checked else 'Mag'
        p = self.params
        if checked:
            self.ed_rp.setText(f'{20*np.log10(max(1-p["Rpass"],1e-10)):.2f}')
            self.ed_rs.setText(f'{20*np.log10(max(p["Rstop"],1e-10)):.2f}')
            self.u_rp.setText('dB'); self.u_rs.setText('dB')
        else:
            self.ed_rp.setText(f'{p["Rpass"]:.5f}')
            self.ed_rs.setText(f'{p["Rstop"]:.5f}')
            self.u_rp.setText(''); self.u_rs.setText('')
        if self.plot_type == 'Magnitude':
            self._do_plot()

    def _toggle_grid(self, checked):
        self.show_grid = checked
        self._do_plot()

    def _export(self):
        path, _ = QFileDialog.getSaveFileName(
            self, 'Export Filter Coefficients', 'filter_coeffs',
            'NumPy archive (*.npz);;All files (*)')
        if path:
            if not path.endswith('.npz'):
                path += '.npz'
            np.savez(path, b=self.b, a=self.a)
            self._status(f'Saved: {path}')

    def _status(self, msg, error=False):
        self.status_lbl.setStyleSheet(f'color: {"red" if error else "black"}')
        self.status_lbl.setText(msg)


# ─────────────────────────────────────────────────────────────────────────────
def main():
    app = QApplication(sys.argv)
    win = FilterDesignApp()
    win.show()
    sys.exit(app.exec())


if __name__ == '__main__':
    main()
