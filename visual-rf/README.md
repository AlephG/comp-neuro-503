# Reverse correlation and visual receptive fields

## Part I: Reverse correlation with a 1D input
The function `oned.m` simulates the response of a neuron to a stimulus sequence at a single point in space by filtering the input and applying a static nonlinearity. The filter is recovered by computing the cross-correlation of the ouput of the neuron and the input using <img src="https://render.githubusercontent.com/render/math?math=Q_{rs}(\tau)= \frac{1}{T} \int^T_0 dtr(t)s(t+\tau)">.

## Part II: Spike-triggered averaging with a 3D input

