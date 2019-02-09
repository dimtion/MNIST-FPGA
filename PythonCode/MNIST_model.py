#!/usr/bin/env python3
import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from torchvision import datasets, transforms
from torch.autograd import Variable

import numpy as np


# Training settings
batch_size = 64
n_epochs = 30


model_name = "3layers.torch"
layer_sizes=(28 * 28, 40, 20, 10)
do_train = True
momentum = 0.5
learning_rate = 0.0005

train_dataset = datasets.MNIST(
    root="./mnist_data/", train=True, transform=transforms.ToTensor(), download=True
)

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
                        epoch,
                        100.0 * batch_id / len(train_loader),
                        loss.data,
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
            "\nTest set: Average loss: {:.4f}, Accuracy: {}/{} ({:.2f}%)\n".format(
                test_loss, correct, len(test_loader.dataset), accuracy
            )
        )
        return accuracy

    def save_torch(self, filename):
        torch.save(self.state_dict(), filename)

    def load_torch(self, filename):
        self.load_state_dict(torch.load(filename))
        self.eval()

def quantize_layer(weight, n_bits, shift):
    max_weight = weight.abs().max()
    quantum = 2**(torch.ceil(torch.log2(max_weight)) - n_bits - n_shift + 1)
    quantum = quantum.float()
    max_quantized = 2**(n_bits - 1) - 1

    quant_weigth = torch.round(weight / quantum)  # integer to binary
    quant_weigth = quant_weigth.clamp(-max_quantized - 1, max_quantized)  # clamp for storage
    quant_weigth = quant_weigth * quantum

    return quant_weigth

    

def main():
    model = Net(layer_sizes=layer_sizes)
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.SGD(model.parameters(), lr=learning_rate, momentum=momentum)
    try:
        model.load_torch(model_name)
        print("Model %s loaded" % model_name)
    except Exception:
        print("Model not found, creating a new one.")

    for epoch in range(1, n_epochs + 1):
        model.train_(epoch, train_loader, optimizer, criterion)
        if epoch % 10 == 0:
            model.test_(test_loader, criterion)

    model.save_torch(model_name)


if __name__ == "__main__":
    main()
