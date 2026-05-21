# _DSP First_ in Python

DSP demos from http://dspfirst.gatech.edu ported to Python.

## _DSP First_ book series

[James H. McClellan](https://en.wikipedia.org/wiki/James_H._McClellan),
[Ronald W. Schafer](https://en.wikipedia.org/wiki/Ronald_W._Schafer), and Mark A. Yoder wrote three books together


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
| Complex Numbers       | Appx. A | Appx. A |Appx. A |
| Programming in Matlab | Appx. B | Appx. B |Appx. B |
| Laboratory Projects   | Appx. C | Appx. C |Appx. C |
| Demos                 | Appx. D | Appx. D |Appx. D |

### About authors

* [James H. McClellan](https://en.wikipedia.org/wiki/James_H._McClellan), famous for Parks-McClellan algorithm .

  ![McClellan|200](img/mcclellan2013.jpg)

  _Computer-Based Exercises for Signal Processing Using MATLAB_, written by
  James H. McClellan, C. Sidney Burrus, [Alan V. Oppenheim](https://en.wikipedia.org/wiki/Alan_V._Oppenheim),
  Thomas W. Parks , Ronald W. Schafer, and Hans W. Schuessler.


* [Ronald W. Schafer](https://en.wikipedia.org/wiki/Ronald_W._Schafer) co-authored two DSP books with [Alan V. Oppenheim](https://en.wikipedia.org/wiki/Alan_V._Oppenheim), _Digital Signal Processing_ (1975) and _Discrete-Time Signal Processing_ (1989, 1999, 2009).

  ![](img/schafer.jpg)

## Demos

Install PyQt6 and dependencies.

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




