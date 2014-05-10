clear all
clc

x = [1:10 11:5:31];
y = (x - repmat(mean(x,2),1,size(x,2)))./std(x,0,2);

diff = x' - circshift(x',1);
diff(1) = [];

diffy = y'- circshift(y',1);
diffy(1) = [];
figure
stem(diff,exp(-diff));
hold on
stem(diffy,exp(-diffy),'r');