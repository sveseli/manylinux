#!/bin/bash

# Stop at any error, show all commands
set -exuo pipefail

PREFIX=$1

# Get script directory
MY_DIR=$(dirname "${BASH_SOURCE[0]}")

# Some python's install as bin/python3. Make them available as
# bin/python.
export LD_LIBRARY_PATH=${PREFIX}/lib
if [ -e ${PREFIX}/bin/python3 ] && [ ! -e ${PREFIX}/bin/python ]; then
	ln -s python3 ${PREFIX}/bin/python
fi
PY_VER=$(${PREFIX}/bin/python -c "import sys; print('.'.join(str(v) for v in sys.version_info[:2]))")
PY_IMPL=$(${PREFIX}/bin/python -c "import sys; print(sys.implementation.name)")

# Install pinned packages for this python version.
# Use the already intsalled cpython pip to bootstrap pip if available
if [ -f /usr/local/bin/python${PY_VER} ]; then
	/usr/local/bin/python${PY_VER} -m pip --python ${PREFIX}/bin/python install -U --require-hashes -r ${MY_DIR}/requirements${PY_VER}.txt
else
	${PREFIX}/bin/python -m ensurepip
	${PREFIX}/bin/python -m pip install -U --require-hashes -r ${MY_DIR}/requirements${PY_VER}.txt
fi
if [ -e ${PREFIX}/bin/pip3 ] && [ ! -e ${PREFIX}/bin/pip ]; then
	ln -s pip3 ${PREFIX}/bin/pip
fi
# Create a symlink to PREFIX using the ABI_TAG in /opt/python/
ABI_TAG=$(${PREFIX}/bin/python ${MY_DIR}/python-tag-abi-tag.py)
ln -s ${PREFIX} /opt/python/${ABI_TAG}
# Make versioned python commands available directly in environment.
if [[ "${PY_IMPL}" == "cpython" ]]; then
	ln -s ${PREFIX}/bin/python /usr/local/bin/python${PY_VER}
fi
ln -s ${PREFIX}/bin/python /usr/local/bin/${PY_IMPL}${PY_VER}

# PVAPY stuff
IS_CP_ABI_TAG=`echo ${PREFIX} | grep cpython || /bin/true`
if [ ! -z "$IS_CP_ABI_TAG" ]; then
    echo "Installing PVAPY requirements for ${ABI_TAG}"
    PVAPY_ENV=/opt/pvapy/python-${PY_VER}
    mkdir -p $PVAPY_ENV/etc
    SETUP_FILE=$PVAPY_ENV/etc/setup.sh
    cat > $SETUP_FILE << EOF
#!/bin/sh
export LD_LIBRARY_PATH=/opt/python/${ABI_TAG}/lib
export PATH=/opt/python/${ABI_TAG}/bin:$PATH
EOF
    /opt/python/${ABI_TAG}/bin/python -m pip install -r ${MY_DIR}/requirements.pvapy.txt
fi

