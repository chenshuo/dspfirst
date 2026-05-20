#!/usr/bin/env python3
"""
PhraceDemo — Phasor Race Drill

Timed quiz on phasor / complex-number operations.  Six question types:

  Complex    — Add two complex amplitudes given in polar form
  Sinusoid   — Add two sinusoids at the same frequency
  Real Part  — Simplify Re{(a+jb)e^{jωt}} to cosine form
  Spectrum   — Convert between cosine and two-sided exponential form
  Sampling   — Find x[n] = x(nTs) for a given cosine and Ts
  Z-Transform — Identify pole/zero locations from H(z)

Original MATLAB version by J. McClellan et al. (Georgia Tech, 2001–2015).
Python / PyQt6 port, 2026.
"""

import sys
import cmath
import math
import numpy as np
from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget,
    QVBoxLayout, QHBoxLayout,
    QLabel, QPushButton, QCheckBox, QComboBox,
    QSizePolicy, QButtonGroup, QRadioButton, QGroupBox,
)
from PyQt6.QtCore import Qt, QTimer
from PyQt6.QtGui import QAction
import matplotlib
matplotlib.use('QtAgg')
from matplotlib.backends.backend_qtagg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure
import matplotlib.gridspec as gridspec

VERSION = '1.16'

# ---------------------------------------------------------------------------
# String formatters — produce matplotlib mathtext-compatible strings
# ---------------------------------------------------------------------------

def _ns(x, nd=3):
    return f'{x:.{nd}g}'

def polar_form(z, nd=3):
    """Return dict with Mag / Phi (N·π) / PhiRad strings for complex z."""
    TOL = 1e-7
    r, phi = abs(z), cmath.phase(z)
    if abs(r)           < TOL: r   = 0.0
    if abs(phi)         < TOL: phi = 0.0
    if abs(phi - math.pi) < TOL: phi =  math.pi
    if abs(phi + math.pi) < TOL: phi = -math.pi

    mag_s = '0' if r == 0 else _ns(r, nd)

    if phi == 0:
        phi_s = '0'
    elif phi == math.pi:
        phi_s = r'\pi'
    elif phi == -math.pi:
        phi_s = r'-\pi'
    else:
        phi_s = _ns(phi / math.pi, nd) + r'\pi'

    return {'Mag': mag_s, 'Phi': phi_s, 'PhiRad': _ns(phi, nd)}


def exp_form(mag_s, phi_s, wt_s=''):
    """Build mathtext string for exponential form, e.g. 1.5e^{j0.5\\pi}."""
    if phi_s in ('0', '-0', ''):
        phase = ''
    elif phi_s.startswith('-'):
        phase = r'e^{-j' + phi_s[1:] + '}'
    else:
        phase = r'e^{j' + phi_s + '}'

    freq = ''
    if wt_s:
        if wt_s.startswith('-'):
            freq = r'e^{-j' + wt_s[1:] + '}'
        else:
            freq = r'e^{j' + wt_s + '}'

    body = phase + freq
    if mag_s == '0':
        return '0'
    if mag_s == '1' and body:
        return body
    return (mag_s + body) if body else mag_s


def cos_form(mag_s, phi_s, wt_s):
    """Build mathtext string for cosine form, e.g. 1.5\\cos(5\\pi t + 0.5\\pi)."""
    if phi_s in ('0', '-0', ''):
        phase = ''
    elif phi_s.startswith('-'):
        phase = r' - ' + phi_s[1:]
    else:
        phase = r' + ' + phi_s

    body = r'\cos(' + wt_s + phase + ')'
    if mag_s == '0':
        return '0'
    return body if mag_s == '1' else mag_s + body


def rect_form(z, nd=3):
    """Build mathtext string for rectangular form, e.g. 1.5 + j2."""
    TOL = 1e-7
    x, y = z.real, z.imag
    for val, ref in ((x, 0), (x, 1), (x, -1), (y, 0), (y, 1), (y, -1)):
        pass  # just iterate
    x = round(x, 10); y = round(y, 10)
    if abs(x) < TOL: x = 0.0
    if abs(y) < TOL: y = 0.0
    if abs(x - 1) < TOL: x = 1.0
    if abs(y - 1) < TOL: y = 1.0
    if abs(x + 1) < TOL: x = -1.0
    if abs(y + 1) < TOL: y = -1.0

    sx = _ns(x, nd)
    if x == 0:
        if y == 0:  return '0'
        if y == 1:  return 'j'
        if y == -1: return '-j'
        return ('j' + _ns(y, nd)) if y > 0 else ('-j' + _ns(-y, nd))
    else:
        if y == 0:  return sx
        if y == 1:  return sx + ' + j'
        if y == -1: return sx + ' - j'
        return (sx + ' + j' + _ns(y, nd)) if y > 0 else (sx + ' - j' + _ns(-y, nd))


def zpoly_str(c):
    """Polynomial in z^{-1}: c[0] + c[1]z^{-1} + c[2]z^{-2} + ..."""
    TOL = 1e-6
    c = np.real(np.asarray(c, float))
    terms = []
    for i, v in enumerate(c):
        if abs(v) < TOL:
            continue
        av  = abs(v)
        sgn = '+' if v > 0 else '-'
        cs  = '' if av == 1 else f'{av:.3g}'
        if i == 0:
            terms.append(f'{v:.3g}')
        elif i == 1:
            terms.append(f' {sgn} {cs}z^{{-1}}')
        else:
            terms.append(f' {sgn} {cs}z^{{-{i}}}')
    return ''.join(terms).strip().lstrip('+').strip() if terms else '0'


# ---------------------------------------------------------------------------
# Question data
# ---------------------------------------------------------------------------

class QuestionData:
    __slots__ = ('test_type', 'title', 'question', 'question2',
                 'question_line', 'question_den',
                 'answer', 'rect_question', 'rect_answer',
                 'alt_answers', 'poles', 'zeros', 'show_rect_btn')

    def __init__(self):
        self.test_type     = ''
        self.title         = ''
        self.question      = ''
        self.question2     = ''   # second line (Sinusoid)
        self.question_line = ''   # fraction bar (ZTransform)
        self.question_den  = ''   # denominator / Ts line
        self.answer        = ''
        self.rect_question = ''
        self.rect_answer   = ''
        self.alt_answers: list = []
        self.poles:        list = []
        self.zeros:        list = []
        self.show_rect_btn = False


def _pick(lst):
    return lst[np.random.randint(len(lst))]


def _fmt_phi(phi):
    return _ns(phi / math.pi, 3) + r'\pi'


def generate_question(test_type: str, level: str) -> QuestionData:
    ALL_TYPES = ['Complex', 'Sinusoid', 'RealPart', 'Spectrum', 'Sampling', 'ZTransform']
    if test_type == 'All':
        test_type = _pick(ALL_TYPES)

    if level == 'Novice':
        r_pool     = [1.0, 1.5, 2.0, 2.5, 3.0]
        theta_pool = [math.pi/6, math.pi/4, math.pi/3, math.pi/2, math.pi]
    else:
        r_pool     = [0.5, 1.0, 1.5, 2.0]
        theta_pool = ([math.pi * k / 4 for k in range(-4, 5) if k != 0] +
                      [math.pi * k / 3 for k in range(-3, 4) if k != 0])

    r1, theta1 = _pick(r_pool), _pick(theta_pool)
    r2, theta2 = _pick(r_pool), _pick(theta_pool)
    for _ in range(20):
        if abs((theta1 - theta2) % (2 * math.pi)) > 1e-5:
            break
        theta2 = _pick(theta_pool)

    z1    = cmath.rect(r1, theta1)
    z2    = cmath.rect(r2, theta2)
    z_sum = z1 + z2

    pf1   = polar_form(z1)
    pf2   = polar_form(z2)
    pf_s  = polar_form(z_sum)

    q = QuestionData()
    q.test_type = test_type

    # ---- Complex ----
    if test_type == 'Complex':
        q.title         = 'Complex: Adding Complex Amplitudes'
        q.question      = exp_form(pf1['Mag'], pf1['Phi']) + r' + ' + exp_form(pf2['Mag'], pf2['Phi'])
        q.answer        = (exp_form(pf_s['Mag'], pf_s['Phi'])
                           + r'  \;\mathrm{or}\;  ' + exp_form(pf_s['Mag'], pf_s['PhiRad']))
        q.rect_question = rect_form(z1) + ' + ' + rect_form(z2)
        q.rect_answer   = rect_form(z_sum)
        q.show_rect_btn = True

    # ---- Sinusoid ----
    elif test_type == 'Sinusoid':
        freq = np.random.randint(1, 10)
        wt   = rf'{freq}\pi t'
        q.title    = 'Sinusoid: Adding Sinusoids'
        q.question = cos_form(pf1['Mag'], pf1['Phi'], wt) + r'  +  \ldots'
        q.question2 = cos_form(pf2['Mag'], pf2['Phi'], wt)
        q.answer   = cos_form(pf_s['Mag'], pf_s['Phi'], wt)
        phi_s      = cmath.phase(z_sum)
        q.alt_answers = [cos_form(pf_s['Mag'], _fmt_phi(phi_s + 2 * math.pi * k), wt)
                         for k in range(1, 6)]

    # ---- Real Part ----
    elif test_type == 'RealPart':
        freq = np.random.randint(1, 10)
        wt   = rf'{freq}\pi t'
        q.title    = r'Real Part: Simplify $\mathrm{Re}\{\ldots\}$ to cosine'
        q.question = (r'\mathrm{Re}\{(' + rect_form(z2) + r')e^{j' + wt + r'}\}')
        q.answer   = cos_form(pf2['Mag'], pf2['Phi'], wt)
        q.alt_answers = [cos_form(pf2['Mag'], _fmt_phi(theta2 + 2 * math.pi * (k - 3)), wt)
                         for k in range(5)]

    # ---- Spectrum ----
    elif test_type == 'Spectrum':
        freq = np.random.randint(1, 10)
        wt   = rf'{freq}\pi t'
        cos2exp  = np.random.rand() > 0.5
        plus_dc  = np.random.rand() > 0.5
        dc_s     = str(np.random.randint(1, 21))
        half     = r1 / 2
        pf_h     = polar_form(cmath.rect(half,  theta1))
        pf_hc    = polar_form(cmath.rect(half, -theta1))
        if cos2exp:
            q.title   = 'Spectrum: Write in exponential form'
            cos_q     = cos_form(pf1['Mag'], pf1['Phi'], wt)
            q.question = (dc_s + r' + ' + cos_q) if plus_dc else cos_q
            ans = (exp_form(pf_h['Mag'], pf_h['Phi'], wt)
                   + r' + ' + exp_form(pf_hc['Mag'], pf_hc['Phi'], '-' + wt))
            q.answer  = (dc_s + r' + ' + ans) if plus_dc else ans
        else:
            q.title    = 'Spectrum: Reduce to cosine form'
            pos_e      = exp_form(pf_h['Mag'],  pf_h['Phi'],  wt)
            neg_e      = exp_form(pf_hc['Mag'], pf_hc['Phi'], '-' + wt)
            q.question = (dc_s + r' + ' + pos_e + r' + ' + neg_e) if plus_dc \
                         else (pos_e + r' + ' + neg_e)
            cos_a      = cos_form(pf1['Mag'], pf1['Phi'], wt)
            q.answer   = (dc_s + r' + ' + cos_a) if plus_dc else cos_a

    # ---- Sampling ----
    elif test_type == 'Sampling':
        q.title   = r'Sampling: Find $x[n]$ after C/D conversion'
        freq_n    = int(np.random.randint(1, 6))
        omega0    = freq_n * math.pi
        wt_cont   = rf'{freq_n}\pi t'
        denom     = int(_pick([2, 4, 6, 8, 10]))
        T_s       = 1.0 / denom
        g         = math.gcd(freq_n, denom)
        num_r, den_r = freq_n // g, denom // g
        if den_r == 1:
            wn_s = rf'{num_r}\pi n'
        elif num_r == 1:
            wn_s = rf'\frac{{\pi}}{{{den_r}}}n'
        else:
            wn_s = rf'\frac{{{num_r}\pi}}{{{den_r}}}n'
        show_fs      = (level == 'Pro' and np.random.rand() > 0.5)
        q.question   = r'x(t) = ' + cos_form(pf1['Mag'], pf1['Phi'], wt_cont)
        q.question_den = (rf'f_s = {1/T_s:.4g}' if show_fs else rf'T_s = {T_s:.4g}')
        q.answer     = r'x[n] = ' + cos_form(pf1['Mag'], pf1['Phi'], wn_s)

    # ---- Z-Transform ----
    elif test_type == 'ZTransform':
        q.title = r'Z-Transform: Plot poles and zeros on $z$-plane'
        if level == 'Novice':
            choices = [np.array([1.]), np.array([1., 1.]), np.array([1., -1.]),
                       np.array([1., 2., 1.]), np.array([1., -2., 1.]),
                       np.array([1., 0., 1.]),  np.array([1., 0., -1.])]
            a = _pick(choices)
            b = _pick(choices)
            for _ in range(30):
                if len(b) <= len(a) and not np.array_equal(a, b):
                    break
                b = _pick(choices)
        else:
            asize = np.random.randint(2, 4)
            bsize = np.random.randint(1, asize + 1)
            a = np.random.randint(1, 3, asize).astype(float)
            b = np.random.randint(1, 3, bsize).astype(float)

        q.question     = zpoly_str(b)
        q.question_den = zpoly_str(a)
        q.question_line = '─' * (max(len(q.question), len(q.question_den)) + 6)
        q.answer       = ''
        q.poles        = list(np.roots(a))
        q.zeros        = list(np.roots(b))

    return q


# ---------------------------------------------------------------------------
# Main window
# ---------------------------------------------------------------------------

class PhraceWindow(QMainWindow):

    TEST_TYPES = ['Complex', 'Sinusoid', 'RealPart', 'Spectrum',
                  'Sampling', 'ZTransform', 'All']

    def __init__(self):
        super().__init__()
        self.q:            QuestionData | None = None
        self._elapsed      = 0.0
        self._running      = False
        self._answer_vis   = False
        self._show_rect    = False
        self._alt_idx      = 0
        self._level        = 'Novice'
        self._test_type    = 'Complex'

        self._qtimer = QTimer(self)
        self._qtimer.setInterval(100)
        self._qtimer.timeout.connect(self._tick)

        self._init_ui()
        self._init_plots()
        self._new_question()

    # ------------------------------------------------------------------
    # UI
    # ------------------------------------------------------------------

    def _init_ui(self):
        self.setWindowTitle(f'Phasor Race  v{VERSION}')
        central = QWidget()
        self.setCentralWidget(central)
        root = QVBoxLayout(central)
        root.setSpacing(4)

        # --- Top options bar ---
        top = QHBoxLayout()
        top.addWidget(QLabel('Test type:'))
        self.combo_type = QComboBox()
        self.combo_type.addItems(self.TEST_TYPES)
        self.combo_type.currentTextChanged.connect(self._type_changed)
        top.addWidget(self.combo_type)

        top.addSpacing(20)
        lvl_grp = QGroupBox()
        lvl_grp.setFlat(True)
        lvl_lay = QHBoxLayout(lvl_grp)
        lvl_lay.setContentsMargins(0, 0, 0, 0)
        self._lvl_bg = QButtonGroup(self)
        for txt in ('Novice', 'Pro'):
            rb = QRadioButton(txt)
            rb.setChecked(txt == 'Novice')
            self._lvl_bg.addButton(rb)
            lvl_lay.addWidget(rb)
        self._lvl_bg.buttonClicked.connect(
            lambda btn: setattr(self, '_level', btn.text()))
        top.addWidget(lvl_grp)
        top.addStretch()
        root.addLayout(top)

        # --- Canvas ---
        self.fig    = Figure(figsize=(9, 5))
        self.canvas = FigureCanvas(self.fig)
        self.canvas.setSizePolicy(QSizePolicy.Policy.Expanding,
                                  QSizePolicy.Policy.Expanding)
        root.addWidget(self.canvas)

        # --- Timer row ---
        self.lbl_timer = QLabel('TIMER:  0.0 secs')
        self.lbl_timer.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.lbl_timer.setStyleSheet('font-size: 13pt; color: navy;')
        root.addWidget(self.lbl_timer)

        # --- Button row ---
        btn_row = QHBoxLayout()
        for label, slot in (
            ('▶  Start',        self._start),
            ('■  Stop',         self._stop),
            ('Show Answer',     self._show_answer),
            ('New Question',    self._new_question),
        ):
            b = QPushButton(label)
            b.clicked.connect(slot)
            btn_row.addWidget(b)
            setattr(self, '_btn_' + label.split()[-1].lower(), b)
        root.addLayout(btn_row)

        # --- Option row ---
        opt_row = QHBoxLayout()
        self.cb_rect = QCheckBox('Show Rectangular Form')
        self.cb_rect.toggled.connect(self._rect_toggled)
        opt_row.addWidget(self.cb_rect)
        self.btn_alt = QPushButton('Alternate Answers')
        self.btn_alt.clicked.connect(self._next_alt)
        self.btn_alt.setVisible(False)
        opt_row.addWidget(self.btn_alt)
        opt_row.addStretch()
        root.addLayout(opt_row)

        self._build_menu()

    def _build_menu(self):
        mb   = self.menuBar()
        file = mb.addMenu('&File')
        a    = QAction('E&xit', self)
        a.triggered.connect(self.close)
        file.addAction(a)

        lvl  = mb.addMenu('&Level')
        for name in ('Novice', 'Pro'):
            a = QAction(name, self, checkable=True)
            a.setChecked(name == 'Novice')
            a.triggered.connect(lambda checked, n=name: self._set_level(n))
            lvl.addAction(a)
        self._level_actions = lvl.actions()

    # ------------------------------------------------------------------
    # Plot initialisation
    # ------------------------------------------------------------------

    def _init_plots(self):
        gs = gridspec.GridSpec(1, 2, figure=self.fig,
                               width_ratios=[3, 2],
                               left=0.03, right=0.97, top=0.97, bottom=0.03)
        self.ax_q = self.fig.add_subplot(gs[0, 0])
        self.ax_z = self.fig.add_subplot(gs[0, 1])
        for ax in (self.ax_q, self.ax_z):
            ax.axis('off')

    # ------------------------------------------------------------------
    # Event handlers
    # ------------------------------------------------------------------

    def _type_changed(self, txt):
        self._test_type = txt

    def _set_level(self, name):
        self._level = name
        for a in self._level_actions:
            a.setChecked(a.text() == name)
        for btn in self._lvl_bg.buttons():
            btn.setChecked(btn.text() == name)

    def _rect_toggled(self, on):
        self._show_rect = on
        self._draw()

    def _tick(self):
        self._elapsed += 0.1
        self.lbl_timer.setText(f'TIMER:  {self._elapsed:.1f} secs')

    def _start(self):
        if self._running:
            return
        self._running    = True
        self._elapsed    = 0.0
        self._answer_vis = False
        self._qtimer.start()
        self._draw()

    def _stop(self):
        if not self._running:
            return
        self._running = False
        self._qtimer.stop()
        self._draw()

    def _show_answer(self):
        if self._running or self.q is None:
            return
        self._answer_vis = True
        self._alt_idx    = 0
        self._draw()
        if self.q.test_type == 'ZTransform' and self.q.poles is not None:
            self._draw_zplane(self.q.zeros, self.q.poles)

    def _new_question(self):
        if self._running:
            return
        self._qtimer.stop()
        self._running    = False
        self._elapsed    = 0.0
        self._answer_vis = False
        self._alt_idx    = 0
        self.lbl_timer.setText('TIMER:  0.0 secs')
        self.q = generate_question(self._test_type, self._level)

        # Rect form checkbox: only relevant for Complex
        self.cb_rect.setVisible(self.q.show_rect_btn)
        self.cb_rect.setChecked(False)
        self._show_rect = False

        # Alternate Answers button: Sinusoid / RealPart
        self.btn_alt.setVisible(bool(self.q.alt_answers))
        self.btn_alt.setText('Alternate Answers')

        self._draw()

    def _next_alt(self):
        if self.q is None or not self.q.alt_answers or not self._answer_vis:
            return
        self._alt_idx = (self._alt_idx % len(self.q.alt_answers))
        # Override answer display to show alternate
        self._draw(alt_override=self.q.alt_answers[self._alt_idx])
        self._alt_idx += 1

    # ------------------------------------------------------------------
    # Display
    # ------------------------------------------------------------------

    def _mt(self, s):
        """Wrap s in $...$ for mathtext if not already wrapped."""
        s = s.strip()
        if not s:
            return ''
        if s.startswith('$') and s.endswith('$'):
            return s
        return '$' + s + '$'

    def _draw(self, alt_override=None):
        ax = self.ax_q
        ax.clear()
        ax.axis('off')
        T = ax.transAxes

        q = self.q
        if q is None:
            self.canvas.draw_idle()
            return

        # Title
        ax.text(0.5, 0.95, q.title,
                ha='center', va='top', transform=T,
                fontsize=12, fontweight='bold')

        # Question body
        is_ztrans  = q.test_type == 'ZTransform'
        has_den    = bool(q.question_den) and not is_ztrans

        if is_ztrans:
            # Fraction: numerator / line / denominator
            ax.text(0.5, 0.72, r'$H(z) = $',
                    ha='center', va='center', transform=T, fontsize=12)
            ax.text(0.5, 0.62, self._mt(q.question),
                    ha='center', va='center', transform=T, fontsize=15)
            ax.plot([0.20, 0.80], [0.52, 0.52], 'k-', lw=1.5,
                    transform=T, clip_on=False)
            ax.text(0.5, 0.44, self._mt(q.question_den),
                    ha='center', va='center', transform=T, fontsize=15)
        else:
            # Use rect form if requested
            use_rect  = self._show_rect and q.show_rect_btn
            q_text    = q.rect_question if use_rect else q.question
            y_q       = 0.66 if has_den else (0.63 if q.question2 else 0.60)
            ax.text(0.5, y_q, self._mt(q_text),
                    ha='center', va='center', transform=T, fontsize=15)
            if q.question2:
                ax.text(0.5, y_q - 0.13, self._mt(q.question2),
                        ha='center', va='center', transform=T, fontsize=15)
            if has_den:
                ax.text(0.5, 0.49, self._mt(q.question_den),
                        ha='center', va='center', transform=T, fontsize=14)

        # Separator
        ax.plot([0.05, 0.95], [0.35, 0.35], color='gray', lw=0.8,
                transform=T, clip_on=False)

        # Answer / hint
        if self._running:
            ax.text(0.5, 0.20,
                    "Timer running…  press  ■ Stop  when done.",
                    ha='center', va='center', transform=T,
                    fontsize=11, color='gray', style='italic')
        elif self._answer_vis and (q.answer or is_ztrans):
            use_rect = self._show_rect and q.show_rect_btn
            ans_text = (q.rect_answer if use_rect else
                        (alt_override if alt_override else q.answer))
            if ans_text:
                ax.text(0.5, 0.20, self._mt(ans_text),
                        ha='center', va='center', transform=T,
                        fontsize=14, color='darkblue')
            if is_ztrans:
                ax.text(0.5, 0.10, '(see z-plane →)',
                        ha='center', va='center', transform=T,
                        fontsize=10, color='gray', style='italic')
        else:
            ax.text(0.5, 0.20,
                    "Press  'Show Answer'  or  'New Question'",
                    ha='center', va='center', transform=T,
                    fontsize=11, color='gray', style='italic')

        # Z-plane: clear when not showing answer
        if not (is_ztrans and self._answer_vis):
            self.ax_z.clear()
            self.ax_z.axis('off')

        self.canvas.draw_idle()

    def _draw_zplane(self, zeros, poles):
        ax = self.ax_z
        ax.clear()
        ax.set_aspect('equal', adjustable='datalim')

        all_pts = list(zeros) + list(poles)
        rmax = max((abs(z) for z in all_pts), default=1.0)
        lim  = max(1.4, math.ceil(rmax * 10) / 10 + 0.2)

        # Background
        th = np.linspace(0, 2 * math.pi, 300)
        ax.plot(np.cos(th), np.sin(th), 'k:', lw=1)
        ax.axhline(0, color='k', lw=0.5, ls=':')
        ax.axvline(0, color='k', lw=0.5, ls=':')

        if zeros:
            zr, zi = zip(*((z.real, z.imag) for z in zeros))
            ax.plot(zr, zi, 'ro', ms=10, mew=2, fillstyle='none', label='zeros')
        if poles:
            pr, pi_ = zip(*((p.real, p.imag) for p in poles))
            ax.plot(pr, pi_, 'kx', ms=12, mew=2.5, label='poles')

        ax.set_xlim(-lim, lim)
        ax.set_ylim(-lim, lim)
        ax.set_xlabel('Re(z)', fontsize=9)
        ax.set_ylabel('Im(z)', fontsize=9)
        ax.set_title('Pole-Zero Plot', fontsize=10)
        ax.tick_params(labelsize=8)
        self.canvas.draw_idle()


# ---------------------------------------------------------------------------

if __name__ == '__main__':
    app = QApplication(sys.argv)
    win = PhraceWindow()
    win.resize(1000, 620)
    win.show()
    sys.exit(app.exec())
