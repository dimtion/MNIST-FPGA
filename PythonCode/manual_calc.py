#!/usr/bin/env python

import numpy as np

WEIGHTS = "weights/models/40_20_10_quant-97.23.torch/"
# WEIGHTS = "weights/models/40_20_10_unquant-97.50.torch/"
IMAGES = ["../VHDL/testbench_files/PixelData2/PixelData%i.tb" % i for i in range(10000)]
TARGETS_ = "../VHDL/testbench_files/PixelData2/Targets.tb"
with open(TARGETS_) as f:
    TARGETS = np.array([int(t.strip()) for t in f])
    

l1_w = np.zeros((28, 28*40))
l1_b = np.zeros((40,))
l2_w = np.zeros((20, 40*20))
l2_b = np.zeros((20,))
l3_w = np.zeros((20, 20*10))
l3_b = np.zeros((10,))
pixels = np.zeros((28*28))

def quantize(values, n_bits, n_shift):
   # return values
   max_w = np.abs(values).max()
   q = 2 ** (np.ceil(np.log2(max_w)) - n_bits - n_shift + 1)
   q = 2 ** 5
   max_quant = 2 **(n_bits - 1) - 1

   quant_w = np.floor(values / q)
   quant_w = np.clip(quant_w, -max_quant - 1, max_quant)
   return quant_w

QUANT_W = 0
QUANT_IMG = 0
QUANT_l = 12
for lut in range(28):
    f = open(WEIGHTS + "/l1_%i.lut" % lut)
    for neuron, l in enumerate(f):
        l1_w[lut, neuron] = float(l.strip()) / 2**QUANT_W

with open(WEIGHTS + "/l1_bias.lut") as f:
    for n, b in enumerate(f):
        l1_b[n] = float(b.strip()) / 2**QUANT_W
        # print(l1_b[n])

for lut in range(20):
    f = open(WEIGHTS + "/l2_%i.lut" % lut)
    for neuron, l in enumerate(f):
        l2_w[lut, neuron] = float(l.strip()) / 2**QUANT_W

with open(WEIGHTS + "/l2_bias.lut") as f:
    for n, b in enumerate(f):
        l2_b[n] = float(b.strip()) / 2**QUANT_W

for lut in range(20):
    f = open(WEIGHTS + "/l3_%i.lut" % lut)
    for neuron, l in enumerate(f):
        l3_w[lut, neuron] = float(l.strip()) / 2**QUANT_W

with open(WEIGHTS + "/l3_bias.lut") as f:
    for n, b in enumerate(f):
        l3_b[n] = float(b.strip()) / 2**QUANT_W

def test_image(image):
    with open(image) as p_image:
        for i, p in enumerate(p_image):
            pixels[i] = float(p.strip()) / 2**QUANT_IMG

    acc = 0
    neuron = 0
    l1_res = np.zeros(40)
    for word in range(28*40):
        p = word % 28
        # print(l1_w[:, word])  # first word W
        prod = l1_w[:, word] * pixels[p*28:(p+1)*28]
        #print("MUL", prod)
        # print(prod.sum())
        # etage 1
        prod1 = prod[::2] + prod[1::2]
        #print("1",prod1)
        # etage 2
        prod2 = prod1[::2] + prod1[1::2]
        #print("2", prod2)
        # etage 3
        prod3 = prod2[:6:2] + prod2[1:6:2]
        #print("3 ", prod3)
        # print(prod3)
        # etage 4

        # prod3 = prod2[:6:2] + prod2[1:6:2]
        # print(prod3)
        # prod = np.maximum(prod, np.zeros((28,)))
        # print(l1_w[:, word])
        # print(prod)
        # print(prod.sum())
        #print("ACC:",prod.sum())
        acc += prod.sum()
        if p == 27:
            acc += l1_b[neuron]
            #print("L1 n%i acc:%f" % (neuron, acc))
            #print("L1 n%i neu:%f" % (neuron, max(0, acc)))
            l1_res[neuron] = max(0, acc)
            acc = 0
            neuron += 1
    # print("----- L1 -----")
    # print(l1_res)
    l1_res = quantize(l1_res, QUANT_l, 0)
    # print(l1_res)

    # print("----- L2 -----")
    acc = 0
    neuron = 0
    l2_res = np.zeros(20)
    for word in range(2*20):
        p = word % 2  # 2 = n_words
        #print("W", l2_w[:, word])
        #print("V", l1_res[p*20: (p+1)*20])
        prod = l2_w[:, word] * l1_res[p*20: (p+1)*20]
        acc += prod.sum()
        if p == 1:
            acc += l2_b[neuron]
            l2_res[neuron] = max(0, acc)
            acc = 0
            neuron +=1
    # print(l2_res)
    l2_res = quantize(l2_res, QUANT_l, 0)
    # print(l2_res)

    # print("----- L3 -----")
    acc = 0
    neuron = 0
    l3_res = np.zeros(10)
    for word in range(10):
        p = word % 1  # 1 = n_words
        #print("W", l3_w[:, word])
        #print("V", l2_res[p*20: (p+1)*20])
        prod = l3_w[:, word] * l2_res[p*20: (p+1)*20]
        acc += prod.sum()
        if p == 0:
            acc += l3_b[neuron]
            l3_res[neuron] = acc
            acc = 0
            neuron +=1
    # print(l3_res)
    l3_res = quantize(l3_res, QUANT_l, 0)
    # print(l3_res)
    # print(np.argmax(l3_res))
    return np.argmax(l3_res)

if __name__ == "__main__":
    found = np.zeros(TARGETS.shape)
    for i, (img, t) in enumerate(zip(IMAGES, TARGETS)):
        if True:
            # print("===============================")
            p = test_image(img)
            # print(p, t)
            found[i] = p == t
        #break
    print(np.sum(found) / i * 100)

