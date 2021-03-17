function [u_dmd] = calc_dmd(f,r)
% Compute the dmd
% input: f - data matrix, r - rank
% output: u_dmd = dmd'ed u

[nim, resxy] = size(f);
t=linspace(0,nim,nim); dt=t(2)-t(1);
% x = linspace(0,resxy,resxy);
 
% figure(2)
% subplot(4,3,1), plot(diag(s)/sum(diag(s)),'ko','Linewidth',[2])
% subplot(4,1,2), plot(t,v(:,1)/max(v(:,1)),t,v(:,2)/max(v(:,2)),'Linewidth',[2])
% subplot(4,1,3), plot(x,u(:,1)/max(u(:,1)),'Linewidth',[2])
% subplot(4,1,4), plot(x,u(:,2)/max(u(:,2)),'Linewidth',[2])

X = f.'; X1 = X(:,1:end-1); X2 = X(:,2:end);
[U2,Sigma2,V2] = svd(X1,'econ'); U=U2(:,1:r); Sigma=Sigma2(1:r,1:r); V=V2(:,1:r);
 
% DMD J-Tu decomposition:  Use this one
    
Atilde = U'*X2*V/Sigma;    
[W,D] = eig(Atilde);    
Phi = X2*V/Sigma*W;
    
mu = diag(D);
omega = log(mu)/dt;

u0=f(1,:).';
y0 = Phi\u0;  % pseudo-inverse initial conditions
u_modes = zeros(r,length(t));
for iter = 1:length(t)
     u_modes(:,iter) =(y0.*exp(omega*t(iter)));
end
u_dmd = Phi*u_modes;