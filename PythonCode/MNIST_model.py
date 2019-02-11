#!/usr/bin/env python3
import os
import copy
import itertools
from functools import lru_cache

import numpy


import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from torch.utils.data.dataset import Dataset
from torchvision import datasets, transforms
from torch.autograd import Variable

from scipy.ndimage.interpolation import map_coordinates
from scipy.ndimage.filters import gaussian_filter

import numpy as np

# Training settings
batch_size = 64
n_epochs = 50

do_train = False
do_quant = True
do_save_fpga = True

# model_name = "models/32_16_10_unquant-97.02.torch"
model_name = "models/40_20_10_quant-97.04.torch"
# layer_sizes = (28 * 28, 32, 16, 10)
layer_sizes = (28 * 28, 40, 20, 10)
shift = (0, 0, 0)  # 40_20_10
# shift = (1, 1, 0)  # 32_16_10
momentum = 0.8
learning_rate = 0.0001

# For VHDL
output_quant = "weights"


class ElasticDataset(Dataset):
    def __init__(self, source, alpha, sigma, random_state=None):
        self.source = source
        self.alpha = alpha
        self.sigma = sigma
        self.random_state = random_state

    def __len__(self):
        return len(self.source)

    @lru_cache(maxsize=None)
    def __getitem__(self, index):
        origin, s = self.source[index]
        transf = self._transform(origin, self.alpha, self.sigma, self.random_state)
        return (transf, s)

    @staticmethod
    def _transform(image, alpha, sigma, random_state=None):
        """Elastic deformation of images as described in [Simard2003]_.
        .. [Simard2003] Simard, Steinkraus and Platt, "Best Practices for
           Convolutional Neural Networks applied to Visual Document Analysis", in
           Proc. of the International Conference on Document Analysis and
           Recognition, 2003.
        """
        if random_state is None:
            random_state = numpy.random.RandomState(None)

        origin_shape = image.shape
        image = image[0, :]
        shape = image.shape
        dx = (
            gaussian_filter(
                (random_state.rand(*shape) * 2 - 1), sigma, mode="constant", cval=0
            )
            * alpha
        )
        dy = (
            gaussian_filter(
                (random_state.rand(*shape) * 2 - 1), sigma, mode="constant", cval=0
            )
            * alpha
        )

        x, y = numpy.arange(shape[0]), numpy.arange(shape[1])
        indices = numpy.reshape(y + dy, (-1, 1)), numpy.reshape(x + dx, (-1, 1))

        img = map_coordinates(image, indices, order=1).reshape(shape)
        output = numpy.zeros(origin_shape)
        output[0, :] = img
        return torch.from_numpy(output).float()


train_dataset = datasets.MNIST(
    root="./mnist_data/", train=True, transform=transforms.ToTensor(), download=True
)
# train_dataset += ElasticDataset(train_dataset, .1, .1)


test_dataset = datasets.MNIST(
    root="./mnist_data/", train=False, transform=transforms.ToTensor()
)

# Data Loader (Input Pipeline)
train_loader = torch.utils.data.DataLoader(
    dataset=train_dataset, batch_size=batch_size, shuffle=True
)

test_loader = torch.utils.data.DataLoader(
    dataset=test_dataset, batch_size=batch_size, shuffle=False
)


class Net(nn.Module):
    def __init__(self, layer_sizes=(28 * 28, 40, 20, 10)):
        super(Net, self).__init__()
        self.layer_sizes = layer_sizes
        self.layers = [
            nn.Linear(layer_sizes[i], layer_sizes[i + 1])
            for i in range(len(layer_sizes) - 1)
        ]
        self.l1 = self.layers[0]
        self.l2 = self.layers[1]
        self.l3 = self.layers[2]

    def forward(self, x):
        x = x.view(-1, self.layer_sizes[0])
        for layer in [self.l1, self.l2]:
            x = F.relu(layer(x))
        x = self.l3(x)
        return x

    def train_(self, epoch, train_loader, optimizer, criterion):
        correct = 0
        for batch_id, (data, target) in enumerate(train_loader):
            data, target = Variable(data), Variable(target)

            # Zero the gradiant
            optimizer.zero_grad()

            # Forward then backward
            output = self(data)
            loss = criterion(output, target)
            loss.backward()
            optimizer.step()

            prediction = output.data.max(1, keepdim=True)[1]
            tensor_correct = prediction.eq(target.data.view_as(prediction)).cpu()
            for value in tensor_correct:
                correct += value[0].double()

            if batch_id % 1000 == 0:
                print(
                    "Train Epoch: {} ({:.0f}%)\tLoss: {:.6f}".format(
                        epoch, 100.0 * batch_id / len(train_loader), loss.data
                    )
                )

        accuracy = correct / len(train_loader.dataset)
        return accuracy

    def test_(self, test_loader, criterion):
        self.eval()
        test_loss = 0
        correct = 0

        for data, target in test_loader:
            data, target = Variable(data), Variable(target)
            output = self(data)

            test_loss += criterion(output, target).data
            prediction = output.data.max(1, keepdim=True)[1]

            tensor_correct = prediction.eq(target.data.view_as(prediction)).cpu()
            for value in tensor_correct:
                correct += value[0].double()

        test_loss /= len(test_loader.dataset)
        accuracy = 100.0 * correct / len(test_loader.dataset)
        print(
            "\nTest set: Average loss: {:.4f}, Accuracy: {}/{} ({:.2f}%)".format(
                test_loss, correct, len(test_loader.dataset), accuracy
            )
        )
        return accuracy

    def save_torch(self, filename):
        torch.save(self.state_dict(), filename)

    def load_torch(self, filename):
        self.load_state_dict(torch.load(filename))
        self.eval()


def quantize_layer(weight, n_bits, n_shift):
    max_weight = weight.abs().max()
    quantum = 2 ** (torch.ceil(torch.log2(max_weight)) - n_bits - n_shift + 1)
    quantum = quantum.float()
    max_quantized = 2 ** (n_bits - 1) - 1

    quant_weigth = torch.round(weight / quantum)  # integer to binary
    quant_weigth = quant_weigth.clamp(
        -max_quantized - 1, max_quantized
    )  # clamp for storage
    quant_weigth = quant_weigth # * quantum

    return quant_weigth


def quant_model(model, n_bits, shift):
    q_model = copy.deepcopy(model)
    q_model.l1.weight.data = quantize_layer(q_model.l1.weight.data, n_bits, shift[0])
    q_model.l1.bias.data = quantize_layer(q_model.l1.bias.data, n_bits, shift[0])
    q_model.l2.weight.data = quantize_layer(q_model.l2.weight.data, n_bits, shift[1])
    q_model.l2.bias.data = quantize_layer(q_model.l2.bias.data, n_bits, shift[1])
    q_model.l3.weight.data = quantize_layer(q_model.l3.weight.data, n_bits, shift[2])
    q_model.l3.bias.data = quantize_layer(q_model.l3.bias.data, n_bits, shift[2])
    return q_model


def best_shift(model, n_bits, test_loader, criterion):
    score_grid = {}
    best_score = 0
    best_score_k = None
    best_model = None
    for s1, s2, s3 in itertools.product(range(n_bits), range(n_bits), range(n_bits)):
        print((s1, s2, s3))
        q_model = quant_model(model, n_bits, (s1, s2, s3))
        acc = q_model.test_(test_loader, criterion)
        score_grid[(s1, s2, s3)] = acc
        if acc > best_score:
            best_score = acc
            best_score_k = (s1, s2, s3)
            best_model = q_model

    return best_score_k, best_model


def write_layer(weight, bias, filename, word_size):
    files = []
    n_files = word_size

    bias_file = open(filename + "_bias.lut", "w")
    for i in range(n_files):
        f = open(filename + "_%i.lut" % i, "w")
        files.append(f)

    for neuron in weight:
        for i, weight in enumerate(neuron):
            # print(filename, n_files, i % word_size)
            f = files[i % word_size]
            f.write("%i\n" % int(weight.numpy()))

    for neuron in bias:
        bias_file.write("%i\n" % int(neuron.numpy()))

    for f in files:
        f.close()


def write_weigths(model, folder, model_name):
    os.system("mkdir -p %s" % os.path.join(folder, model_name))
    write_layer(
        model.l1.weight.data,
        model.l1.bias.data,
        os.path.join(folder, model_name, "l1"),
        word_size=28,
    )
    write_layer(
        model.l2.weight.data,
        model.l2.bias.data,
        os.path.join(folder, model_name, "l2"),
        word_size=20,
    )
    write_layer(
        model.l3.weight.data,
        model.l3.bias.data,
        os.path.join(folder, model_name, "l3"),
        word_size=20,
    )


def main():
    model = Net(layer_sizes=layer_sizes)
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.SGD(model.parameters(), lr=learning_rate, momentum=momentum)
    try:
        model.load_torch(model_name)
        print("Model %s loaded" % model_name)
    except Exception:
        print("Model not found, creating a new one.")

    if do_train:
        for epoch in range(1, n_epochs + 1):
            model.train_(epoch, train_loader, optimizer, criterion)
            if epoch % 10 == 0:
                model.test_(test_loader, criterion)
        model.save_torch(model_name)

    model.test_(test_loader, criterion)

    if do_quant:
        n_bits = 5
        # quant = (1, 1, 0)
        quant = shift
        q_model = quant_model(model, n_bits, quant)
        # quant, q_model = best_shift(model, n_bits, test_loader, criterion)
        # q_model = Net(layer_sizes=layer_sizes)
        # q_model.load_torch("q_%i_" % n_bits + model_name)

        print("Best shift %i bits: %i, %i, %i" % (n_bits, *quant))
        q_model.test_(test_loader, criterion)
        q_model.save_torch(model_name + "q_%i" % n_bits)

        # n_bits = 4
        # quant = shift
        # q_model = quant_model(model, n_bits, quant)
        # quant, q_model = best_shift(model, n_bits, test_loader, criterion)
        # print("Best shift %i bits: %i, %i, %i" % (n_bits, *quant))
        # q_model.test_(test_loader, criterion)
        # q_model.test_(test_loader, criterion)
        # q_model.save_torch(model_name + "q_&%i" % n_bits)

        # finally adapt the weights

    if do_save_fpga:
        write_weigths(q_model, output_quant, model_name)


if __name__ == "__main__":
    main()
