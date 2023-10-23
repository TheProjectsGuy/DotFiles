#!/bin/bash

watch -n 60 'squeue -u $USER -o "%.10i %.15j %.3t %.10M %.4C  %20S %9g %.8a %.7m  %N(%r)"'
