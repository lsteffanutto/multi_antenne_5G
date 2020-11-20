clear all; close all; 

clc;

data=load('data.mat');
Fs=data.Fs;

[nb_sources] = separation(signaux_micros, Fs)

