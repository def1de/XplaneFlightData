#!/bin/bash
# Launch the X-Plane Aircraft MFD

cd "$(dirname "$0")"

# Activate virtual environment if it exists
if [ -d "my_env" ]; then
    source my_env/bin/activate
fi

python3 aircraft_mfd.py

