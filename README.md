# _DSP First_ in Python

DSP demos from http://dspfirst.gatech.edu ported to Python, using Claude Code.

## Demos

Install PyQt6 and dependencies first.

```sh
pip install PyQt6 numpy scipy matplotlib
```

### Sinusoids Drill

```sh
$ ./sindrill.py
```

| Matlab | Python |
| --- | --- |
| ![](img/sindrill_matlab.png) | ![](img/sindrill_python.png) |


### Phasor Race

```sh
$ ./phrace.py
```

| Matlab | Python |
| --- | --- |
| ![](img/phrace_matlab.png) | ![](img/phrace_python.png) |


### ZDrill

```sh
$ ./zdrill.py
```

| Matlab | Python |
| --- | --- |
| ![](img/zdrill_matlab.png) | ![](img/zdrill_python.png) |

### Discrete LTI System demo

```sh
$ ./dltidemo.py
```

| Matlab | Python |
| --- | --- |
| ![](img/dltidemo_matlab.png) | ![](img/dltidemo_python.png) |

### Continuous LTI System demo

```sh
$ ./cltidemo.py
```

| Matlab | Python |
| --- | --- |
| ![](img/cltidemo_matlab.png) | ![](img/cltidemo_python.png) |


### Fourier series demo

```sh
$ ./fseriesdemo.py
```

| Matlab | Python |
| --- | --- |
| ![](img/fseriesdemo_matlab.png) | ![](img/fseriesdemo_python.png) |

### Complex Spin demo

```sh
$ ./cspin.py
```

| Matlab | Python |
| --- | --- |
| ![](img/cspin_matlab.png) | ![](img/cspin_python.png) |

### Discrete Convolution demo

```sh
$ ./dconvdemo.py
```

| Matlab | Python |
| --- | --- |
| ![](img/dconvdemo_matlab.png) | ![](img/dconvdemo_python.png) |

### Continuous Convolution demo

```sh
$ ./cconvdemo.py
```

| Matlab | Python |
| --- | --- |
| ![](img/cconvdemo_matlab.png) | ![](img/cconvdemo_python.png) |

### Filter Design demo

```sh
$ ./filterdesign.py
```

| Matlab | Python |
| --- | --- |
| ![](img/filterdesign_matlab.png) | ![](img/filterdesign_python.png) |

### Pole-Zero demo

```sh
$ ./pezdemo.py
```

| Matlab | Python |
| --- | --- |
| ![](img/pezdemo_matlab.png) | ![](img/pezdemo_python.png) |

### Spectrogram demo

```sh
$ ./specgramdemo.py
```

| Matlab | Python |
| --- | --- |
| ![](img/specgramdemo_matlab.png) | ![](img/specgramdemo_python.png) |

### Continuous-Discrete Sampling Demo

```sh
$ ./con2dis.py
```

| Matlab | Python |
| --- | --- |
| ![](img/con2dis_matlab.png) | ![](img/con2dis_python.png) |


## _DSP First_ book series

[James H. McClellan](https://en.wikipedia.org/wiki/James_H._McClellan),
[Ronald W. Schafer](https://en.wikipedia.org/wiki/Ronald_W._Schafer),
and [Mark A. Yoder](https://www.rose-hulman.edu/academics/faculty/yoder-mark-yoder.html)
wrote three books together, the first 6 chapters are almost the same, as well as two chapters on $z$-Transforms and IIR Filters.

* _DSP First: A Multimedia Approach_ (523 pp.) was published in 1998, focused almost entirely on the digital domain.
* _Signal Processing First_ (512 pp.)published in 2003 expanded the original book, adding several chapters covering Continuous-Time Linear Time-Invariant (LTI) systems, the Continuous-Time Fourier Transform (CTFT), and analog filtering/modulation/sampling. It was designed to serve as a complete, single-semester course covering _both_ analog and digital concepts.
* [_DSP First, second edition_](https://www.pearson.com/se/Nordics-Higher-Education/subject-catalogue/engineering/mcclellan-digital-signal-processing-first-2e-ge.html) (592 pp.) features three new chapters on Discrete-Time Fourier Transform, The Discrete Fourier Transform, and the Fourier Series.


| Chapters | _DSP First: A Multimedia Approach_ (1st Ed, 1998) | _Signal Processing First_ (2003)| _DSP First_ <br>(2nd Ed, 2016) |
| --- | --- | --- | --- |
| Introduction              | Chap. 1 | Chap. 1 | Chap. 1 |
| Sinusoids                 | Chap. 2 | Chap. 2 | Chap. 2 |
| Spectrum Representation   | Chap. 3 | Chap. 3 | Chap. 3 |
| Sampling & Aliasing       | Chap. 4 | Chap. 4 | Chap. 4 |
| FIR Filters               | Chap. 5 | Chap. 5 | Chap. 5 |
| Frequency Response of FIR Filters | Chap. 6 | Chap. 6 | Chap. 6 |
| Discrete-Time Fourier Transform   |         |         | Chap. 7 |
| Discrete Fourier Transform        |         |         | Chap. 8 |
| $z$-Transforms                    | Chap. 7 | Chap. 7  | Chap. 9 |
| IIR Filters                       | Chap. 8 |Chap. 8|Chap. 10|
| Continuous-Time Signals and LTI Systems   |   | Chap. 9   |   |
| Frequency Response                        |   | Chap. 10  |   |
| Continuous-Time Fourier Transform         |   | Chap. 11 |  |
| Filtering, Modulation, and Sampling       |   | Chap. 12 |  |
| Computing the Spectrum                    |   | Chap. 13 |  |
| Spectrum Analysis                         | Chap. 9 |||
| Complex Numbers       | Appx. A | Appx. A | Appx. A |
| Programming in Matlab | Appx. B | Appx. B | Appx. B |
| Laboratory Projects   | Appx. C | Appx. C | [Labs online](https://dspfirst.gatech.edu/labs.html) |
| CD-ROM Demos          | Appx. D | Appx. D | [Demos online](https://dspfirst.gatech.edu/demos.html) |
| Fourier Series        |         |         | Appx. C |

### Other books by the authors

* [James H. McClellan](https://en.wikipedia.org/wiki/James_H._McClellan), known for [Parks-McClellan FIR filter design algorithm](https://en.wikipedia.org/wiki/Parks%E2%80%93McClellan_filter_design_algorithm).

  ![McClellan|200](img/mcclellan2013.jpg)

  _Computer-Based Exercises for Signal Processing Using MATLAB 5_, written by
  James H. McClellan, C. Sidney Burrus, [Alan V. Oppenheim](https://en.wikipedia.org/wiki/Alan_V._Oppenheim),
  [Thomas W. Parks](https://en.wikipedia.org/wiki/Thomas_W._Parks), Ronald W. Schafer, and Hans W. Schuessler, 1994.


* [Ronald W. Schafer](https://en.wikipedia.org/wiki/Ronald_W._Schafer) co-authored two DSP books with [Alan V. Oppenheim](https://en.wikipedia.org/wiki/Alan_V._Oppenheim), _Digital Signal Processing_ (1975) and _Discrete-Time Signal Processing_ (1<sup>st</sup> ed. 1989, 2<sup>nd</sup> ed. 1999, 3<sup>rd</sup> ed. 2009).

  ![](img/schafer.jpg)

* [Mark A. Yoder](https://www.rose-hulman.edu/academics/faculty/yoder-mark-yoder.html) wrote [_BeagleBone Cookbook_](https://www.beagleboard.org/projects/cookbook),
built [campanion website for _Discrete-Time Signal Processing 3e_](https://www.rose-hulman.edu/DSPFirst/dtsp/contents/index.htm), and maintains [Signal Processing First website](https://www.rose-hulman.edu/DSPFirst/visible3/contents/index.htm).

  ![](img/yoder.jpg)

