function T = erostable()
T = dir('*.txt');
T = readtable(T.name);