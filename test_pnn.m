clear all
clc
input = [repmat(-1,1,10), 1    ];
target = [repmat(1,1,10), 2  ];
net = newpnn_test(input,ind2vec(target), sqrt(-log(.5)));
net_ref = newpnn(input,ind2vec(target), sqrt(-log(.5)));
vec2ind(sim(net,0.1))
vec2ind(sim(net_ref,0.1))