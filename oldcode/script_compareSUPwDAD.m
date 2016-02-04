load DadData

C = setinputparams();
C.delT=.2;
avec = C.pig;
svec = C.scg;

k = 10;
N = 100+2.^(4:10);
numIter = 10;

R2sup = zeros(length(N),numIter);
R2dad = zeros(length(N),numIter);

% create all training data
Num = max(N);
[Ytrain,TC_train] = simmotorneurons(Xtrain,Num,'base'); % create training set
permz = randperm(Num);

for j=1:numIter
for i=1:length(N)
    numN = N(i);
    wid = permz(1:numN);
    Ytr = Ytrain(:,wid); % take random subset of neurons
    magV = norms(Xtest')';
    theta_dir = atan2(Xtest(:,2),Xtest(:,1));
    Ytest = fwdneuronmodel(Xtest,TC_train.x0(wid),TC_train.pref_dir(wid),magV,theta_dir)'; % create test set (with same TCs)
    Winit = randn(numN,2)*0.01; % initialize W matrix 

    % solve supervised decoder problem
    %[Xnew,Wsup,FVALnew] = solvesubp(Ytr,Winit,Xtrain,1,'linear'); toc % assume linear model
    [Xnew,Wsup,FVALnew] = solvesubp(Ytr,Winit,Xtrain,1,'exp-baseline'); toc
    %Xrec = Ytest*Wsup;
    Xrec2 = Ytest*(pinv(Ytr)*Xtrain);
    %R2sup(:,i) = [evalR2(Xtest,Xrec), evalR2(Xtest,Xrec2)];
    R2sup(i,j) = evalR2(Xtest,Xrec2);
    
    % DAD
    Results = runsynthexpt(Xtest,Ttest,Xtrain,avec,svec,k,N,'base',Ytest);

    Xrec = Results.Xrec;
    R2dad(i,j) = evalR2(Xtest,Xrec);
    
end % end iter (i)
save('Results-1-11-16(1)')
end % end iter (j)

% figure; 
% subplot(1,3,1); colorData2014(Xtest,Ttest);
% title('Ground truth kinematics')
% subplot(1,3,2); colorData2014(Ytest*Wsup,Ttest); 
% title(['Supervised R2 = ', num2str(R2sup(1)), num2str(R2sup(2))])
% subplot(1,3,3); colorData2014(Xrec,Ttest); 
% title(['DAD R2 = ', num2str(R2dad)])