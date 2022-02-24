

set -ex



f2py -h
python -c "import numpy as np; np.test(verbose=3, durations=50, extra_argv=['-k', 'not (_not_a_real_test or test_sincos_float32)', ''])"
exit 0
