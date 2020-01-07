% Written by Sebastiano Vascon


function [HC,P] = gtg(R, P, maxIter, maxDiff)
%% GTNMF Game theoretic NMF clustering refiner
%
% Input:
% R         the similarity matrix of the dataset (nxn) with zero on the main diagonal
%
% P         the soft-assignment clustering of NMF (nxk)
%
% maxIter   the maximum number of iterations (default 200)
%
% maxDiff   the maximum difference between a step and the next (default 1e-5)
%
% Output:
% HC        the hard cluster assignment (max of the soft clustering)
%
% P        the refined initial soft cluster assignment
%
%%%%%%%%%%%%%%%%%%%%%

if nargin<3 || isempty(maxIter)
%     maxIter=2000;
    maxIter=10;
end

if nargin<4 || isempty(maxDiff)
    maxDiff=1e-5;
end

niter=0;
while true
    q = R*P;
    dummy = P.*q;
    dummySum = sum(dummy,2)+eps;
    pnew = dummy./dummySum; %bsxfun(@rdivide, dummy, dummySum);
    
    diff = norm(P(:)-pnew(:));
    
    P = pnew;
    niter = niter+1;
    
    if niter==maxIter || diff<maxDiff
        break;
    end
end

[~,HC] = max(P,[],2);

end
